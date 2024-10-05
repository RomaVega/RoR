# frozen_string_literal: true

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
class Main
  def initialize
    @stations_intermediate = []
    @stations = []
    @trains = []
    @routes = []
  end

  def select_from_collection(collection)
    # Выбор по индексу, а не по именам
    loop do
      index = gets.chomp.to_i
      return collection[index] if index >= 0 && index < collection.length

      puts 'Wrong choice. Please chose a number from the list!'
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
      when 1
        create_station
      when 2
        create_train
      when 3
        manage_route
      when 4
        assign_route
      when 5
        add_wagon
      when 6
        detach_wagon
      when 7
        move_train
      when 8
        list_stations_and_trains
      when 0
        break
      else
        puts 'Wrong number!'
      end
    end
  end

  def create_station
    puts 'What is the name of the station?'
    name = gets.chomp
    puts
    station = Station.new(name)
    @stations_intermediate << station
    puts "Station #{name} was created ✓"
  end

  def create_train
    puts 'What is the train number?'
    number = gets.chomp
    puts
    puts 'Select the type of the train:'
    puts '1 - passenger train'
    puts '2 - cargo train'
    choice = gets.chomp.to_i
    puts

    case choice
    when 1
      type = 'passenger'
      train = Train.new(number, type)
      @trains << train
      puts "#{type} train №#{number} was created ✓"
    when 2
      type = 'cargo'
      train = Train.new(number, type)
      @trains << train
      puts "#{type} train №#{number} was created ✓"
    else
      puts 'Wrong choice. Train was not created ×'
    end
  end

  def manage_route
    puts 'Select the action:'
    puts '1 - create a route'
    puts '2 - add a station to the route'
    puts '3 - delete a station from the route'
    choice = gets.chomp.to_i
    puts

    case choice

    when 1
      puts 'Enter the first station:'
      first_station_name = gets.chomp
      puts
      first_station = Station.new(first_station_name)
      puts 'Enter the last station:'
      last_station_name = gets.chomp
      puts
      last_station = Station.new(last_station_name)
      route = Route.new(first_station, last_station)
      @routes << route
      @stations << first_station
      @stations << last_station
      puts 'Route created ✓'
      puts "First station: #{first_station.name}"
      puts "Last station: #{last_station.name}"

    when 2
      if @routes.empty?
        puts 'No routes available. Please create a route first!'
      else
        # Вывод списка маршрутов для выбора, куда добавить станцию:
        puts 'Chose the route to which would you like to add a station:'
        @routes.each_with_index do |route, index|
          puts "#{index} - route from #{route.stations.first.name} to #{route.stations.last.name}"
        end
        route_index = gets.chomp.to_i
        puts
        route = @routes[route_index]
        puts 'Pick the station you want to add to the route:'
        @stations_intermediate.each_with_index do |station, index|
          puts "#{index} - #{station.name}"
        end
        intermediate_station_index = gets.chomp.to_i
        puts
        intermediate_station = @stations_intermediate[intermediate_station_index]
        route.add_station(intermediate_station)
      end

    when 3
      # Вывод списка маршрутов для выбора, откуда удалить станцию:
      if @routes.empty?
        puts 'No available route. Create a route first!'
        return
      end

      puts 'Chose the route from which would you like to delete a station:'
      @routes.each_with_index do |route, index|
        puts "#{index} - route from #{route.stations.first.name} to #{route.stations.last.name}"
      end
      route_index = gets.chomp.to_i
      puts
      route = @routes[route_index]

      if route.stations.length <= 2
        puts 'No intermediate stations to delete on this route!'
        return
      end

      if route == route.stations.first || route == route.stations.last
        puts 'You cannot delete the first or last station!'
        return
      end

      puts 'Chose the station that you would like to delete:'
      route.stations.each_with_index do |station, index|
        next if index == 0 || index == route.stations.length - 1
        puts "#{index} - #{station.name}"
      end

      station = select_from_collection(route.stations)
      route.delete_station(station)
    end
  end

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
    # Добавлять вагоны к поезду
    if @trains.empty?
      puts 'There are no trains available. Create the train first!'
    else
      puts 'Pick the train to which you would like to add a wagon:'
      @trains.each_with_index do |train, index|
        puts "#{index} - #{train.type} train №#{train.number}"
      end
    end

    train_choice = gets.chomp.to_i
    puts

    if @trains[train_choice].nil?
      puts 'Wrong choice!'
      return
    end

    case @trains[train_choice].type
    when 'passenger'
      wagon = PassengerWagon.new
    when 'cargo'
      wagon = CargoWagon.new
    else
      puts 'Unknown type of train!'
      return
    end
    @trains[train_choice].add_wagon(wagon)
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