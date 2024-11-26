# frozen_string_literal: true

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
# Main class that provides the core CLI functionality
class Main
  attr_accessor :stations

  def initialize
    @stations = []
    @trains = []
    @routes = []
  end

  def start
    loop do
      puts "\nChose an action:"
      puts '----------------'
      puts '1 - create a station'
      puts '2 - create a train'
      puts '3 - create a route / add / delete stations'
      puts '4 - assign a route to the train'
      puts '5 - add wagons to the train'
      puts '6 - detach wagons from the train'
      puts '7 - move train along the route'
      puts '8 - list stations / trains on stations'
      choice = gets.chomp.to_i
      puts
      case choice
      when 1 then create_station
      when 2 then create_train
      when 3 then manage_route
      when 4 then assign_route
      when 5 then add_wagon
      when 6 then detach_wagon
      when 7 then move_train
      when 8 then list_stations_and_trains
      else
        puts 'Invalid number. Enter a number from the menu!'
      end
    end
  end

  def create_station
    puts 'What is the name of the station?'
    name = gets.chomp.strip
    puts
    return puts "Station '#{name}' already exists!" if @stations.any? { |station| station.name == name }

    @stations << Station.new(name)
    puts "Station #{name} was created ✓"
  end

  def create_train
    puts 'What is the train number?'
    number = gets.chomp.strip
    puts
    puts 'Select a type of the train:'
    puts '1 - passenger train'
    puts '2 - cargo train'
    train_type = gets.chomp.to_i
    puts
    case train_type
    when 1 then create_passenger_train(number)
    when 2 then create_cargo_train(number)
    else
      puts 'Invalid choice. Train was not created ×'
    end
  end

  def create_passenger_train(number)
    @trains << Train.new(number, 'passenger')
    puts "Passenger train №#{number} was created ✓"
  end

  def create_cargo_train(number)
    @trains << Train.new(number, 'cargo')
    puts "Cargo train №#{number} was created ✓"
  end

  def manage_route
    puts 'Select an action:'
    puts '1 - create a route'
    puts '2 - add a station to the route'
    puts '3 - delete a station from the route'
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
    return puts 'No trains available. Create a train first!' if @trains.empty?
    return puts 'No routes available. Create a route first!' if @routes.empty?

    puts 'Select a train you would like to assign a route to:'
    list_available_trains
    train = select_from_collection(@trains)
    puts
    puts "Chose a route you want to assign to the train №#{train.number}:"
    list_all_routes
    route = select_from_collection(@routes)
    puts
    puts "Route from #{route.stations.first.name} to #{route.stations.last.name}:"
    puts "was assigned to the #{train.type} train №#{train.number} ✓"
    puts
    train.accept_route(route)
  end

  def add_wagon
    return puts 'No trains available. Create a train first!' if @trains.empty?

    puts 'Select the train you would like to add a wagon:'
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
    return puts 'No trains available. Create the train first!' if @trains.empty?

    puts 'Pick the train from which would you like to detach a wagon:'
    list_available_trains
    train_choice = select_from_collection(@trains)
    puts
    return puts 'No wagons to detach. Add wagons first!' if train_choice.wagons.empty?

    last_wagon = train_choice.wagons.last
    train_choice.detach_wagons(last_wagon)
  end

  def move_train
    return puts 'No trains to move. Create a train and assign a route to it first!' if @trains.empty?

    puts 'Pick a train that you would like to move:'
    list_available_trains
    train = select_from_collection(@trains)
    puts
    return puts 'Train cannot move without assigned route. Assign the route to this train first!' if train.route.nil?

    puts
    puts 'Would you like to go forward or backward?'
    puts '1 - move backward'
    puts '2 - move forward'
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
    return puts 'No stations found. Create a station or a route first!' if @stations.empty?

    puts 'List of all stations with number of trains on each:'
    @stations.each_with_index do |station, index|
      puts "#{index + 1} - #{station.name}, number of trains: #{station.trains.size}"
    end
    puts
    puts 'Pick any station to see the list of trains parked on it:'

    station = select_from_collection(@stations)
    puts
    puts "List of trains parked on the station #{station.name}:"
    station.list_all_trains
  end

  private

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
      puts "#{index + 1} - #{train.type} train, wagons: #{train.wagons.size}"
    end
  end

  def list_all_routes
    @routes.each_with_index do |route, index|
      puts "#{index + 1} - route from #{route.stations.first.name} to #{route.stations.last.name}"
    end
  end

  def list_stations_with_index
    @stations.each_with_index do |station, index|
      puts "#{index + 1} - #{station.name}"
    end
  end

  def list_routes_with_index
    @routes.each_with_index do |route, index|
      puts "#{index + 1} - route from #{route.stations.first.name} to #{route.stations.last.name}"
    end
  end

  def list_intermediate_stations_with_index(route)
    intermediate_stations = route.stations[1..-2]
    return if intermediate_stations.empty?

    intermediate_stations.each_with_index do |station, index|
      puts "#{index + 1} - #{station.name}"
    end
  end

  def list_available_stations(stations)
    stations.each_with_index do |station, index|
      puts "#{index + 1} - #{station.name}"
    end
  end
end
main = Main.new
main.start