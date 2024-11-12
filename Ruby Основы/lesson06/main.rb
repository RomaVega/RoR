# frozen_string_literal: true
require_relative 'text_formatter'
require_relative 'instance_counter'
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'validation'

# Main class that provides the core CLI functionality
class Main
  attr_accessor :stations

  include Manufacturer
  include TextFormatter
  include Validation

  def initialize
    @stations = []
    @trains = []
    @routes = []
  end

  def main_menu
    loop do
      display_total_stations_trains_routes
      show_menu
      choice = get_choice
      take_action(choice)
    end
  end

  def create_station
    name = prompt_station_name
    return station_exists_message(name) if station_exists?(name)

    add_station(name)
    display_created_station(name)
    list_all_stations
  end

  def create_train
    number = prompt_train_number
    train_type = prompt_train_type
    add_train(number, train_type)
  rescue RuntimeError => e
    red_error("\nError: #{e.message}")
  end

  def manage_route
    user_choice = prompt_route_managing_options
    process_route_management_option(user_choice)
  end

  def create_a_route
    return puts "\nAt least 2 stations are required to create a route. Create some stations!" if @stations.size < 2

    first_station = prompt_for_station("\nPick the first station:")
    last_station = prompt_for_station("\nPick the last station:")
    if last_station == first_station
      puts "\nFirst station cannot be the same as the last station!"
    else
      @routes << Route.new(first_station, last_station)
    end
  end

  def add_station_to_route
    return puts "\nNo routes available. Create a route first!" if @routes.empty?
    return puts "\nNo stations available to add. \nCreate another station first!" if @stations.size < 3

    route = prompt_for_route("\nChose a route to which would you like to add a station:")
    puts "\nPick a station you would like to add to the route:"
    available_stations = @stations - [route.stations.first, route.stations.last]
    list_available_stations(available_stations)
    selected_station = select_from_collection(available_stations)
    route.add_station(selected_station) if selected_station
  end

  def delete_station_from_route
    return puts "\nNo available routes. Create a route first!" if @routes.empty?

    route = prompt_for_route('Select a route from which would you like to delete a station:')
    return unless route

    intermediate_stations = route.stations[1..-2]
    if intermediate_stations.empty?
      puts "\nNo intermediate stations to delete on this route."
    else
      station = prompt_for_station_to_delete(intermediate_stations)
      route.delete_station(station)
    end
  end

  def assign_route
    return puts "\nNo trains available. Create a train first!" if @trains.empty?
    return puts "\nNo routes available. Create a route first!" if @routes.empty?

    puts "\nSelect a train you would like to assign a route to:"
    list_available_trains
    train = select_from_collection(@trains)
    puts "\nChose a route you want to assign to the train №#{train.number}:"
    list_all_routes
    route = select_from_collection(@routes)
    puts clr("\nRoute from #{route.stations.first.name} to #{route.stations.last.name} assigned to:", 32)
    puts clr("#{train.type.capitalize} train №#{train.number} ✓", 32)
    train.accept_route(route)
  end

  def add_wagon
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nSelect the train you would like to add a wagon:"
    list_available_trains
    train = select_from_collection(@trains)
    wagon = if train.type == 'passenger'
              PassengerWagon.new
            elsif train.type == 'cargo'
              CargoWagon.new
            else
              puts "\nPick from the list!"
              return
            end
    train.add_wagon(wagon)
  end

  def detach_wagon
    return puts "\nNo trains available. Create the train first!" if @trains.empty?

    puts "\nPick the train from which would you like to detach a wagon:"
    list_available_trains
    train_choice = select_from_collection(@trains)
    return puts "\nNo wagons to detach. Add wagons first!" if train_choice.wagons.empty?

    last_wagon = train_choice.wagons.last
    train_choice.detach_wagons(last_wagon)
  end

  def move_train
    return puts "\nNo trains to move. Create a train and assign a route to it first!" if @trains.empty?

    puts "\nPick a train that you would like to move:"
    list_available_trains
    train = select_from_collection(@trains)
    return puts "\nTrain cannot move without assigned route. Assign the route to this train first!" if train.route.nil?

    puts "\nWould you like to go forward or backward?"
    puts clr('1 - move backward', 37)
    puts clr('2 - move forward', 37)
    direction_choice = gets.chomp.to_i
    case direction_choice
    when 1 then train.move_backward
    when 2 then train.move_forward
    else
      puts "\nWrong choice!"
    end
  end

  def list_stations_and_trains
    return puts "\nNo stations found. Create a station or a route first!" if @stations.empty?

    puts "\nList of all stations with number of trains on each:"
    @stations.each_with_index do |station, index|
      puts clr("#{index + 1} - #{station.name}, number of trains: #{station.trains.size}", 37)
    end
    puts "\nPick any station to see the list of trains parked on it:"

    station = select_from_collection(@stations)
    puts "\nList of trains parked on the station #{station.name}:"
    station.list_all_trains
  end

  def set_get_manufacturer
    return puts "\nNo trains or wagons found. Create a train first!" if @trains.empty?

    puts "\nWould you like to set the manufacturer name or display it?"
    puts clr('1 - set', 37)
    puts clr('2 - display', 37)
    set_or_get_user_choice = gets.chomp.to_i
    case set_or_get_user_choice
    when 1
      puts "\nSelect a train to set its manufacturer:"
      list_available_trains
      train = select_from_collection(@trains)
      train.set_manufacturer
    when 2 then get_manufacturer
    else
      puts "\nWrong choice!"
    end
  end

  def find_train_by_number
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nEnter the train number you want to find:"
    train_number = gets.chomp.strip
    train = Train.find(train_number)
    if train
      puts clr("\nTrain found ✓", 32)
      puts "№#{train.number}, Type: #{train.type}, Wagons: #{train.wagons.size}"
    else
      puts clr("\nTrain with number #{train_number} not found ×", 91)
    end
  end

  private

  def display_total_stations_trains_routes
    puts "\n┌───────────────────┐"
    puts "│ Stations total: \e[5m#{Station.instances}\e[0m │"
    puts "│ Trains total: \e[5m#{Train.instances}\e[0m   │"
    puts "│ Routes total: \e[5m#{Route.instances}\e[0m   │"
    puts '└───────────────────┘'
  end

  def get_choice
    puts "\nChose an action:"
    gets.chomp.to_i
  end

  def show_menu
    puts clr("\n        \e[1mMENU\e[0m\n", 36)
    menu_items = [
      'create a station',
      'create a train',
      'create a route / add / delete stations',
      'assign a route to the train',
      'add wagons to the train',
      'detach wagons from the train',
      'move train along the route',
      'list stations / trains on stations',
      'set / get manufacturer name',
      'find a train by its number'
    ]
    menu_items.each_with_index do |item, index|
      puts clr("#{index + 1} - #{item}", 97)
    end
  end

  def take_action(choice)
    case choice
    when 1 then create_station
    when 2 then create_train
    when 3 then manage_route
    when 4 then assign_route
    when 5 then add_wagon
    when 6 then detach_wagon
    when 7 then move_train
    when 8 then list_stations_and_trains
    when 9 then set_get_manufacturer
    when 10 then find_train_by_number
    else
      puts "\nInvalid number. Enter a number from the menu!"
    end
  end

  # create_station methods:
  def prompt_station_name
    puts "\nWhat is the name of the station?"
    gets.chomp.strip
  end

  def station_exists_message(name)
    puts "\nStation '#{name}' already exists!"
  end

  def station_exists?(name)
    @stations.any? { |station| station.name == name }
  end

  def add_station(name)
    @stations << Station.new(name)
  end

  def display_created_station(name)
    puts clr("\nStation #{name} created ✓", 32)
  end

  # create_train methods:
  def prompt_train_number
    puts "\nWhat is the train number (5 characters)?"
    gets.chomp.strip
  end

  def prompt_train_type
    puts "\nSelect a type of the train:"
    puts clr('1 - passenger train', 37)
    puts clr('2 - cargo train', 37)
    gets.chomp.to_i
  end

  def add_train(number, train_type)
    raise clr('Invalid choice. Train was not created ×', 91) unless [1, 2].include? train_type

    if train_type == 1
      create_passenger_train(number)
    else
      create_cargo_train(number)
    end
  end

  def create_passenger_train(number)
    @trains << Train.new(number, 'passenger')
    puts clr("\nPassenger train №#{number} created ✓", 32)
  rescue RuntimeError => e
    puts clr("Error: #{e.message}", 31)
  end

  def create_cargo_train(number)
    @trains << Train.new(number, 'cargo')
    puts clr("\nCargo train №#{number} created ✓", 32)
  rescue RuntimeError => e
    puts clr("Error: #{e.message}", 31)
  end

  # manage_route methods:
  def prompt_route_managing_options
    puts "\nSelect an action:"
    puts clr('1 - create a route', 37)
    puts clr('2 - add a station to the route', 37)
    puts clr('3 - delete a station from the route', 37)
    gets.chomp.to_i
  end

  def process_route_management_option(user_choice)
    case user_choice
    when 1 then create_a_route
    when 2 then add_station_to_route
    when 3 then delete_station_from_route
    else
      puts "\nInvalid choice!"
    end
  end

  # create_a_route methods:
  def prompt_for_station(message)
    puts "\n#{message}"
    list_stations_with_index
    selected_station = select_from_collection(@stations)
    puts "\nInvalid last station selection!" unless selected_station
    selected_station
  end

  # add_station_to_route methods:
  def prompt_for_route(message)
    puts "\n#{message}"
    list_routes_with_index
    selected_route = select_from_collection(@routes)
    puts "\nInvalid route selection!" unless selected_route
    selected_route
  end

  # delete_station_from_route methods:
  def prompt_for_route(message)
    puts "#{message}"
    list_routes_with_index
    selected_route = select_from_collection(@routes)
    puts "\nInvalid route selection!" unless selected_route
    selected_route
  end

  def prompt_for_station_to_delete(stations)
    puts "\nSelect the station you would like to delete:"
    list_available_stations(stations)
    selected_station = select_from_collection(stations)
    puts "\nInvalid station selection!" unless selected_station
    selected_station
  end

  # lists and selectors:
  def list_all_stations
    puts "\nList of all stations:"
    Station.all.each { |station| puts clr(station.name, 37) }
  end

  def select_from_collection(collection)
    loop do
      index = gets.chomp.to_i - 1
      return collection[index] if index >= 0 && index < collection.length

      puts "\nInvalid choice. Please, chose a number from the list!"
    end
  end

  def select_from_intermediate_elements(collection)
    intermediate_elements = collection[1..-2]
    if intermediate_elements.empty?
      puts "\nNo intermediate stations found!"
      return
    end

    loop do
      index = gets.chomp.to_i - 1
      return intermediate_elements[index] if index >= 0 && index < intermediate_elements.length

      puts "\nInvalid choice. Please, chose a number from the list!"
    end
  end

  def list_available_trains
    @trains.each_with_index do |train, index|
      puts clr("#{index + 1} - #{train.type} train, wagons: #{train.wagons.size}",37)
    end
  end

  def list_all_routes
    @routes.each_with_index do |route, index|
      puts clr("#{index + 1} - route from #{route.stations.first.name} to #{route.stations.last.name}", 37)
    end
  end

  def list_stations_with_index
    @stations.each_with_index do |station, index|
      puts clr("#{index + 1} - #{station.name}", 37)
    end
  end

  def list_routes_with_index
    @routes.each_with_index do |route, index|
      puts clr("#{index + 1} - route from #{route.stations.first.name} to #{route.stations.last.name}", 37)
    end
  end

  def list_intermediate_stations_with_index(route)
    intermediate_stations = route.stations[1..-2]
    return if intermediate_stations.empty?

    intermediate_stations.each_with_index do |station, index|
      puts clr("#{index + 1} - #{station.name}",37)
    end
  end

  def list_available_stations(stations)
    stations.each_with_index do |station, index|
      puts clr("#{index + 1} - #{station.name}",37)
    end
  end

end
main = Main.new
main.main_menu
cargo_wagon = CargoWagon.new
puts cargo_wagon.inspect