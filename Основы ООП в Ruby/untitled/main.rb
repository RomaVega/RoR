# frozen_string_literal: true

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
class Main
  def initialize
    @stations = []
    @trains = []
    @routes = []
  end

  def start
    loop do
      puts "\nChose an action:"
      puts '----------------'
      puts '1 - create a station.'
      puts '2 - create a train.'
      puts '3 - create a route & add/delete stations.'
      puts '4 - assign a route to the train.'
      puts '5 - add wagons to the train.'
      puts '6 - detach wagons from the train.'
      puts '7 - move train along the route.'
      puts '8 - list stations / trains on stations.'
      puts

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
        puts 'Wrong number.'
      end
    end
  end

  def create_station
    puts 'What is the name of the station?'
    name = gets.chomp
    station = Station.new(name)
    @stations << station
    puts "Station #{name} was created."
  end

  def create_train
    puts 'What is the train number?'
    number = gets.chomp
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
      puts "#{type} train №#{number} was created."
    when 2
      type = 'cargo'
      train = Train.new(number, type)
      @trains << train
      puts "#{type} train №#{number} was created."
    else
      puts 'Wrong choice. Train was not created.'
    end
  end

  def manage_route
    puts 'Select the action:'
    puts '1 - create a route.'
    puts '2 - add a station to the route.'
    puts '3 - delete a station from the route.'
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
      puts 'Route created ✓'
      puts "First station is: #{first_station.name}"
      puts "Last station is: #{last_station.name}"

    when 2
      if @routes.empty?
        puts 'No routes available. Please create a route first.'
      else
        # Вывод списка маршрутов для выбора, куда добавить станцию:
        puts 'Chose the route to which would you like to add a station:'
        @routes.each_with_index do |route, index|
          puts "#{index} - route from #{route.stations.first.name} to #{route.stations.last.name}"
        end
        route_index = gets.chomp.to_i
        puts
        route = @routes[route_index]
        puts 'Enter the name of the station you want to add to the route:'
        name = gets.chomp
        puts
        intermediate_station = Station.new(name)
        route.add_station(intermediate_station)
      end

    when 3
      # Вывод списка маршрутов для выбора, откуда удалить станцию:
      puts 'Chose the route from which would you like to delete a station'
      puts '(you cannot delete first and last stations):'
      @routes.each_with_index do |route, index|
        puts "#{index} - route from #{route.stations.first.name} to #{route.stations.last.name}"
      end
      route_index = gets.chomp.to_i
      puts
      route = @routes[route_index]
      route.list_stations
      puts 'Type the name of the station that you would like to delete:'
      name = gets.chomp
      station.delete_station(name)
      puts
      puts "Station #{station} deleted."
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
    train = @trains[train_number]
    if train.nil?
      puts 'Wrong choice. Chose an existing train from the list.'
      return
    end
    puts "Chose the route you want to assign to the train №#{train.number}:"
    @routes.each_with_index do |route, index|
      puts "#{index} - the route from #{route.stations.first.name} to #{route.stations.last.name}"
    end
    route_index = gets.chomp.to_i
    route = @routes[route_index]
    if route.nil?
      puts 'Wrong choice. Chose an existing route from the list.'
      return
    end
    puts "Route from #{route.stations.first.name} to #{route.stations.last.name} was assigned to the #{train.type} train №#{train.number}."
    train.accept_route(route)
  end
end
main = Main.new
main.start