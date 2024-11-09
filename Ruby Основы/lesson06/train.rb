require_relative 'route'
require_relative 'station'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'manufacturer'

class Train
  attr_reader :number, :type, :wagons, :speed, :route

  include InstanceCounter
  include TextFormatter

  # Класс переменная для хранения всех соданных поездов
  @trains = []

  # Метод класса для доступа к @trains
  def self.all
    @trains
  end

  # Метод класса для поиска поезда по номеру
  def self.find(number)
    @trains.find { |train| train.number == number }
  end

  include Manufacturer

  def initialize(number, type)
    @number = number
    @type = type
    @speed = 0
    @wagons = []
    @route = nil
    @current_station_index = 0
    # Добавляем текущий объект поезда в список всех поездов
    self.class.all << self
    # Увеличиваем счетчик при создании нового экземпляра
    register_instance
    # Проверяем имя станции: что оно не пустое, не состоит из пробелов и >3 символов
    validate!
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def speed_up(value)
    @speed += value
    puts "\nSpeed up to: #{@speed}"
  end

  def stop
    @speed = 0
    puts "\nTrain stopped"
  end

  def add_wagon(wagon)
    if @speed.zero?
      if wagon.type == @type
        @wagons << wagon
        puts clr("\nWagon #{wagon.type} attached ✓", 32)
        puts "Wagons total: #{@wagons.size}"
      else
        puts "\nType of wagon doesnt match the type of the train!"
      end
    else
      puts "\nCannot attach wagons while train is moving!"
    end
  end

  def detach_wagons(wagon)
    if @speed.zero?
      if @wagons.include?(wagon)
        @wagons.delete(wagon)
        puts clr("\nWagon #{type} detached ×", 91)
        puts "Wagons total: #{@wagons.size}"
      else
        "\nSuch wagon is not found on this train!"
      end
    else
      "\nCannot detach wagons, train is either moving or not attached!"
    end
  end

  def accept_route(route)
    @route = route
    @current_station_index = 0
    # Поезд, прибывший на станцию, добавляется в её список припаркованных в ней поездов:
    current_station.let_train_in(self)
  end

  # Может перемещаться между станциями, указанными в маршруте.
  # Перемещение возможно вперед и назад, но только на 1 станцию за раз:
  def move_forward
    if next_station
      # Поезд, прибывший на станцию, удаляется из её списока припаркованных в ней поездов:
      current_station.dispatch(self)
      @current_station_index += 1
      current_station.let_train_in(self)
    else
      puts "\nTrain is already on the last station of the route: #{current_station.name}!"
    end
  end

  def move_backward
    if previous_station
      current_station.dispatch(self)
      @current_station_index -= 1
      current_station.let_train_in(self)
    else
      puts "\nTrain is already on the first station of the route!"
    end
  end

  private

  def validate!
    raise 'Train cannot be empty' if number.nil? || number.strip.empty?
    raise 'Train number must be at least 5 characters' if number.length < 3
    raise 'Train type must be either "passenger" or "cargo"' unless %w[passenger cargo].include?(type)
  end

  # Метод сделан приватным так как используется только внутри класса для перемещения по маршруту.
  # Возвращать предыдущую станцию, текущую, следующую, на основе маршрута:
  def previous_station
    @route.stations[@current_station_index - 1] if @route && @current_station_index > 0
  end

  def current_station
    @route.stations[@current_station_index]
  end

  def next_station
    @route.stations[@current_station_index + 1] if @route && @current_station_index < @route.stations.length - 1
  end

end