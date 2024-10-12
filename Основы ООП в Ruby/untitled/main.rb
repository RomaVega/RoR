# frozen_string_literal: true
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'

class Main
  attr_accessor :stations

  def initialize
    @stations = []
    @trains = []
    @routes = []
  end

  def select_from_collection(collection)
    # Выбор по индексу, а не по именам
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
    if @stations.any? { |station| station.name == name }
      puts "Station '#{name}' already exists!"
    else
      station = Station.new(name)
      @stations << station
      puts "Station #{name} was created ✓"
    end
  end

  def create_train
    puts 'What is the train number?'
    number = gets.chomp.strip
    puts
    puts 'Select the type of the train:'
    puts '1 - passenger train'
    puts '2 - cargo train'
    choice = gets.chomp.to_i
    puts

    case choice
    when 1
      train = Train.new(number, 'passenger')
      @trains << train
      puts "Passenger train №#{number} was created ✓"
    when 2
      train = Train.new(number, 'cargo')
      @trains << train
      puts "Cargo train №#{number} was created ✓"
    else
      puts 'Invalid choice. Train was not created ×'
    end
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
    when 2 then add_a_station_to_the_route
    when 3 then delete_a_station_from_the_route
    else
      puts 'Invalid choice!'
    end
  end

  def create_a_route
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
      route = Route.new(first_station, last_station)
      @routes << route
    end
  end

  def add_a_station_to_the_route
    if @routes.empty?
      puts 'No routes available. Please, create a route first!'
    else
      puts 'Chose the route to which would you like to add a station:'
      list_routes_with_index
      route = select_from_collection(@routes)
      puts
      puts 'Pick the station you would like to add to the route:'
      available_stations = @stations - [route.stations.first, route.stations.last]
      list_available_stations(available_stations)
      intermediate_station = select_from_collection(available_stations)
      puts
      route.add_station(intermediate_station)
    end
  end

  def delete_a_station_from_the_route
    if @routes.empty?
      puts 'No available route. Create a route first!'
      return
    end

    puts 'Select the route from which would you like to delete a station:'
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

  def assign_route
    train = select_train
    return unless train

    route = select_route
    return unless route

    train.accept_route(route)
    puts "Route from '#{route.stations.first.name}' to #{route.stations.last.name}:"
    puts "was assigned to train №#{train_number} ✓"
  end

  def add_wagon
    train = select_train
    return unless train

  end

  private

  def select_route
    if @routes.empty?
      puts 'No available routes. Create a route first!'
      return nil
    end

    puts 'Chose the route from which would you like to delete a station:'
    @routes.each_with_index do |route, index|
      puts "#{index} - route from #{route.stations.first.name} to #{route.stations.last.name}"
    end

    route_index = gets.chomp.to_i
    puts
    route = @routes[route_index]

    unless route
      puts 'Invalid route selection!'
      return nil
    end

    #route
  end

  def select_intermediate_station(route)
    if route.stations.length <= 2
      puts 'No intermediate stations to delete on this route!'
      return nil
    end

    puts 'Chose the station that you would like to delete:'
    route.stations.each_with_index do |station, index|
      next if index.zero? || index == route.stations.length - 1

      puts "#{index} - #{station.name}"
    end
    station_index = gets.chomp.to_i
    station = route[station_index]

    unless station
      puts 'Wrong choice!'
      return nil
    end

  end

  public

  def assign_route
    # Назначать маршрут поезду
    if @trains.empty?
      puts 'There are no trains available. Create the train first!'
      return
    end

    if @routes.empty?
      puts 'There are no routes available. Create the route first!'
      return
    end

    puts 'Pick a train to which you would like to assign a route:'
    @trains.each_with_index do |train, index|
      puts "#{index} - #{train.type} train №#{train.number}"
    end
    train_number = gets.chomp.to_i
    puts
    train = @trains[train_number]
    if train.nil?
      puts 'Wrong choice. Chose an existing train from the list!'
      return
    end

    puts "Chose the route you want to assign to the train №#{train.number}:"
    @routes.each_with_index do |route, index|
      puts "#{index} - the route from #{route.stations.first.name} to #{route.stations.last.name}"
    end

    route_index = gets.chomp.to_i
    route = @routes[route_index]

    if route.nil?
      puts 'Wrong choice. Chose an existing route from the list!'
      return
    end

    puts "Route from #{route.stations.first.name} to #{route.stations.last.name}:"
    puts "was assigned to the #{train.type} train №#{train.number} ✓"
    train.accept_route(route)
  end

  def add_wagon
    train = select_train
    return unless train

    wagon = if train.is_a?('passenger')
              PassengerWagon.new
            elsif train.is_a?(cargo)
              CargoWagon.new
            else
              puts 'Unknown train type!'
              return
            end
    train.add_wagon(wagon)
    puts "Wagon added to train №#{train.number} ✓"
  end

  def detach_wagon
    # Отцеплять вагоны от поезда
    if @trains.empty?
      puts 'There are no trains available. Create the train first!'
    else
      puts 'Pick the train from which would you like to detach a wagon:'
      @trains.each_with_index do |train, index|
        puts "#{index} - #{train.type} train №#{train.number}"
      end
    end
    train_choice_index = gets.chomp.to_i
    puts
    train = @trains[train_choice_index]
    last_wagon = train.wagons.last
    train.detach_wagons(last_wagon)
  end

  def move_train
    # Перемещать поезд по маршруту вперед и назад
    puts 'Pick a train that you would like to move:'
    @trains.each_with_index do |train, index|
      puts "#{index} - #{train.type} train №#{train.number}"
    end
    train_choice_index = gets.chomp.to_i
    puts
    train = @trains[train_choice_index]
    puts 'Would you like to go forward or backward?'
    puts '0 - move forward'
    puts '1 - move backward'
    direction_choice = gets.chomp.to_i
    puts
    case direction_choice
    when 0
      train.move_forward
    when 1
      train.move_backward
    else
      puts 'Wrong choice!'
    end
  end

  # Просматривать список станций и список поездов на станции
  def list_stations_and_trains
    if @stations.empty?
      puts 'No stations found. Create a station or a route first!'
    else
      puts 'List of all stations:'
      @stations.each_with_index do |station, index|
        puts "#{index} - #{station.name}, number of trains: #{station.trains.size}"
      end
      puts
      puts 'Pick any station to see the list of trains parked on it:'
      station_choice_index = gets.chomp.to_i
      puts
      selected_station = @stations[station_choice_index]

      puts "List of trains parked on the station #{selected_station.name}:"
      selected_station.list_all_trains
    end
  end
end
main = Main.new
main.start