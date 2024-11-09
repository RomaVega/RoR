# frozen_string_literal: true
require_relative 'text_formatter'
require_relative 'instance_counter'
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'

# Main class that provides the core CLI functionality
class Main
  attr_accessor :stations

  include Manufacturer
  include TextFormatter

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
    puts "\nWhat is the name of the station?"
         name = gets.chomp.strip
    puts
    return puts "Station '#{name}' already exists!" if @stations.any? { |station| station.name == name }

    @stations << Station.new(name)
    puts clr("Station #{name} created ✓", 32)
    puts "\nList of all stations:"
    Station.all.each { |station| puts clr(station.name, 37) }
  end

  def create_train
    puts "\nWhat is the train number?"
    number = gets.chomp.strip
    puts "\nSelect a type of the train:"
    puts clr('1 - passenger train', 37)
    puts clr('2 - cargo train', 37)
    train_type = gets.chomp.to_i
    puts
    case train_type
    when 1 then create_passenger_train(number)
    when 2 then create_cargo_train(number)
    else
      puts clr('Invalid choice. Train was not created ×', 31)
    end
  end

  def create_passenger_train(number)
    @trains << Train.new(number, 'passenger')
    puts clr("Passenger train №#{number} created ✓", 32)
  end

  def create_cargo_train(number)
    @trains << Train.new(number, 'cargo')
    puts clr("Cargo train №#{number} created ✓", 32)
  end

  def manage_route
    puts "\nSelect an action:"
    puts clr('1 - create a route', 37)
    puts clr('2 - add a station to the route', 37)
    puts clr('3 - delete a station from the route', 37)
    choice = gets.chomp.to_i
    puts
    case choice
    when 1 then create_a_route
    when 2 then add_station_to_route
    when 3 then delete_station_from_route
    else
      puts 'Invalid choice!'
    end
  end

  def create_a_route
    return puts 'At least 2 stations are required to create a route. Create some stations!' if @stations.size < 2

    puts 'Pick the first station:'
    list_stations_with_index
    first_station = select_from_collection(@stations)
    puts
    return puts 'Invalid first station selection!' unless first_station

    puts 'Pick the last station:'
    list_stations_with_index
    last_station = select_from_collection(@stations)
    puts
    return puts 'Invalid last station selection!' unless last_station

    if last_station == first_station
      puts 'First station cannot be the same as the last station!'
    else
      @routes << Route.new(first_station, last_station)
    end
  end

  def add_station_to_route
    return puts 'No routes available. Please, create a route first!' if @routes.empty?

    puts 'Chose the route to which would you like to add a station:'
    list_routes_with_index
    route = select_from_collection(@routes)
    puts
    available_stations = @stations - [route.stations.first, route.stations.last]
    return puts 'No stations available to add. Create a station first!' if available_stations.empty?

    puts 'Pick the station you would like to add to the route:'
    list_available_stations(available_stations)
    intermediate_station = select_from_collection(available_stations)
    puts
    route.add_station(intermediate_station)
  end

  def delete_station_from_route
    return puts 'No available routes. Create a route first!' if @routes.empty?

    puts 'Select a route from which would you like to delete a station:'
    list_routes_with_index
    route_choice = select_from_collection(@routes)
    intermediate_stations = route_choice.stations[1..-2]

    if intermediate_stations.empty?
      puts "\nNo intermediate stations to delete on this route."
    else
      puts "\nSelect the station you would like to delete:"
      list_intermediate_stations_with_index(route_choice)
      station_to_delete = select_from_intermediate_elements(route_choice.stations)
      route_choice.delete_station(station_to_delete)
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
    puts
    wagon = if train.type == 'passenger'
              PassengerWagon.new
            elsif train.type == 'cargo'
              CargoWagon.new
            else
              puts 'Unknown train type!'
              return
            end
    train.add_wagon(wagon)
  end

  def detach_wagon
    return puts "\nNo trains available. Create the train first!" if @trains.empty?

    puts "\nPick the train from which would you like to detach a wagon:"
    list_available_trains
    train_choice = select_from_collection(@trains)
    puts
    return puts 'No wagons to detach. Add wagons first!' if train_choice.wagons.empty?

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
    puts
    case direction_choice
    when 1 then train.move_backward
    when 2 then train.move_forward
    else
      puts 'Wrong choice!'
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
    puts
    case set_or_get_user_choice
    when 1
      puts 'Select a train to set its manufacturer:'
      list_available_trains
      train = select_from_collection(@trains)
      puts
      train.set_manufacturer
    when 2 then get_manufacturer
    else
      puts 'Wrong choice!'
    end
  end

  def find_train_by_number
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nEnter the train number you want to find:"
    train_number = gets.chomp.strip
    puts
    train = Train.find(train_number)
    if train
      puts clr('Train found ✓', 32)
      puts "№#{train.number}, Type: #{train.type}, Wagons: #{train.wagons.size}"
    else
      puts clr("Train with number #{train_number} not found ×", 31)
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
    puts clr("\n        \e[1mMENU\e[0m", 36)
    puts
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
      puts 'Invalid number. Enter a number from the menu!'
    end
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
      puts 'No intermediate stations found!'
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