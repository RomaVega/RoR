# frozen_string_literal: true
require 'byebug'
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

  MENU = {
    'create a station' => 'create_station',
    'create a train' => 'create_train',
    'create a route / add / delete stations' => 'manage_route',
    'assign a route to the train' => 'assign_route',
    'add wagons to the train' => 'add_wagon',
    'detach wagons from the train' => 'detach_wagons',
    'move train along the route' => 'move_train',
    'list stations / trains / wagons' => 'list_stations_trains_wagons',
    'set / get manufacturer name' => 'set_get_manufacturer',
    'find a train by its number' => 'find_train_by_number',
    'occupy seats / load wagons' => 'occupy_load_wagons'
  }.freeze


  def main_menu
    loop do
      display_totals
      show_menu
      choice = get_choice
      take_action(choice)
    end
  end

  def create_station
    name = prompt_station_name
    add_station(name)
    list_all_stations
  rescue StandardError => e
    red_clr("\nError: #{e.message}")
    retry
  end

  def create_train
    number = prompt_train_number
    train_type = prompt_train_type
    return puts red_clr("\nInvalid input!") unless %w[passenger cargo].include?(train_type)

    add_train(number, train_type)
  rescue StandardError => e
    red_clr("\nError: #{e.message}")
    retry
  end

  def manage_route
    user_choice = prompt_route_managing_options
    process_route_management_option(user_choice)
  end

  def create_a_route
    return puts "\nAt least 2 stations are required to create a route. Create some stations!" if @stations.size < 2

    first_station = prompt_for_station("\nPick the first station:")
    last_station = prompt_for_station("\nPick the last station:")
    @routes << Route.new(first_station, last_station)
  rescue RuntimeError => e
    red_clr("\nError: #{e.message}")
    retry
  end

  def add_station_to_route
    ensure_routes_and_stations_exist
    route = prompt_for_route("\nChose a route to which would you like to add a station:")
    puts "\nPick a station you would like to add to the route:"
    available_stations = @stations - [route.stations.first, route.stations.last]
    list_available_stations(available_stations)
    selected_station = select_from_collection(available_stations)
    route.add_station(selected_station) if selected_station
  end

  def delete_station_from_route
    return puts "\nNo available routes. Create a route first!" if @routes.empty?

    route = prompt_for_route("\nSelect a route from which would you like to delete a station:")
    return unless route

    delete_intermediate_station(route)
  end

  def assign_route
    ensure_routes_and_stations_exist
    puts "\nSelect a train you would like to assign a route to:"
    list_available_trains
    train = select_from_collection(@trains)
    puts "\nChose a route you want to assign to the train №#{train.number}:"
    list_all_routes
    select_route(train)
  end

  def add_wagon
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nSelect a train you would like to add a wagon to:"
    list_available_trains
    train = select_from_collection(@trains)
    wagon = attach_wagon(train)
    train.add_wagon(wagon)
  end

  def detach_wagons
    return puts "\nNo trains available. Create the train first!" if @trains.empty?

    puts "\nPick the train from which would you like to detach a wagon:"
    list_available_trains
    train_choice = select_from_collection(@trains)
    return puts "\nNo wagons to detach. Add wagons first!" if train_choice.wagons.empty?

    last_wagon = train_choice.wagons.last
    train_choice.detach_wagon(last_wagon)
  end

  def move_train
    return puts "\nNo trains to move. Create a train and assign a route to it first!" if @trains.empty?

    puts "\nPick a train that you would like to move:"
    list_available_trains
    train = select_from_collection(@trains)
    return puts "\nTrain cannot move without assigned route. Assign the route to this train first!" if train.route.nil?

    direction_choice(train)
  end

  def list_stations_trains_wagons
    if @stations.empty? || @routes.empty?
      return puts "\nCreate some stations, a train and assign at least one route first!"
    end

    list_stations_with_trains
    station = prompt_for_station_with_trains
    puts "\nPick any train to see it's list of wagons:"
    trains = station.list_all_trains
    train = select_from_collection(trains)
    list_passenger_or_cargo_wagons(train)
  end

  def set_get_manufacturer
    return puts "\nNo trains or wagons found. Create a train first!" if @trains.empty?

    puts "\nWould you like to set the manufacturer name or display it?"
    puts clr('1 - set', 37)
    puts clr('2 - display', 37)
    set_or_get_manufacturer
  end

  def find_train_by_number
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nEnter the train number you want to find:"
    train_number = gets.chomp.strip
    find_train(train_number)
  end

  def occupy_load_wagons
    return puts "\nNo trains available. Create a train first!" if @trains.empty?

    puts "\nPick any train to see it's list of wagons:"
    list_available_trains
    train = select_from_collection(@trains)
    list_passenger_or_cargo_wagons(train)
    wagon = train.select_wagon
    select_and_fill(wagon)
  end

  private

  def display_totals
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
    MENU.each_with_index do |(item, _method), index|
      puts clr("#{index + 1} - #{item}", 97)
    end
  end

  def take_action(choice)
    if choice.between?(1, MENU.size)
      selected_method = MENU.values[choice - 1]
      send(selected_method)
    else
      puts "\nInvalid number. Enter a number from the menu!"
    end
  end

  # create_station methods:
  def prompt_station_name
    puts "\nWhat is the name of the station?"
    gets.chomp.strip
  end

  def add_station(name)
    @stations << Station.new(name)
  end

  # create_train methods:
  def prompt_train_number
    puts "\nSet the train number \n(allowed formats: 333 3-33 LLL L-LL)"
    gets.chomp.strip
  end

  def prompt_train_type
    puts "\nSelect a type of the train:"
    puts clr('1 - passenger train', 37)
    puts clr('2 - cargo train', 37)
    { 1 => 'passenger', 2 => 'cargo' }[gets.chomp.to_i]
  end

  def add_train(number, train_type)
    if train_type == 'passenger'
      create_passenger_train(number)
    elsif train_type == 'cargo'
      create_cargo_train(number)
    end
  end

  def create_passenger_train(number)
    @trains << Train.new(number, 'passenger')
    puts clr("Passenger train №#{number} created ✓", 32)
  rescue RuntimeError => e
    puts clr("Error: #{e.message}", 31)
  end

  def create_cargo_train(number)
    @trains << Train.new(number, 'cargo')
    puts clr("Cargo train №#{number} created ✓", 32)
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

      puts red_clr("\nInvalid choice. Please, chose a number from the list!")
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
      puts clr("#{index + 1} - #{train.type.capitalize} train №#{train.number}, wagons: #{train.wagons.size}", 37)
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

  def list_stations_with_trains
    puts "\nList of all stations with number of trains on each:"
    @stations.each_with_index do |station, index|
      puts clr("#{index + 1} - Station '#{station.name}', number of trains: #{station.trains.size}", 37)
    end
  end

  def prompt_for_station_with_trains
    puts "\nPick any station to see the list of trains and wagons parked at it:"
    select_from_collection(@stations)
  end

  def list_passenger_or_cargo_wagons(train)
    puts "\n#{train.type.capitalize} train №#{train.number}:"
    if train.type == 'passenger'
      train.list_passenger_wagons
    elsif train.type == 'cargo'
      train.list_cargo_wagons
    end
  end

  def attach_wagon(train)
    if train.type == 'passenger'
      PassengerWagon.new.set_seats
    elsif train.type == 'cargo'
      CargoWagon.new.set_volume
    else
      puts "\nPick from the list!"
      nil
    end
  end

  def direction_choice(train)
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

  def delete_intermediate_station(route)
    intermediate_stations = route.stations[1..-2]
    if intermediate_stations.empty?
      puts "\nNo intermediate stations to delete on this route."
    else
      station = prompt_for_station_to_delete(intermediate_stations)
      route.delete_station(station)
    end
  end

  def select_route(train)
    route = select_from_collection(@routes)
    puts clr("\nRoute from #{route.stations.first.name} to #{route.stations.last.name} assigned to:", 32)
    puts clr("#{train.type.capitalize} train №#{train.number} ✓", 32)
    train.accept_route(route)
  end

  def set_or_get_manufacturer
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

  def find_train(train_number)
    train = Train.find(train_number)
    if train
      puts clr("\nTrain found ✓", 32)
      puts "№#{train.number}, Type: #{train.type}, Wagons: #{train.wagons.size}"
    else
      puts red_clr("\nTrain with number #{train_number} not found ×")
    end
  end

  def select_and_fill(wagon)
    if wagon.type == 'passenger'
      wagon.take_seat
    elsif wagon.type == 'cargo'
      wagon.load_volume
    end
  rescue NoMethodError => e
    puts red_clr('No wagon to fill. Attach a wagon first!')
  end

  def ensure_routes_and_stations_exist
    return puts "\nNo routes available. Create a route first!" if @routes.empty?
    return puts "\nNo stations available to add. \nCreate another station first!" if @stations.size < 3
  end

end
main = Main.new
main.main_menu