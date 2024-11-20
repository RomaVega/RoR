require_relative 'route'
require_relative 'station'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'manufacturer'
require_relative 'validation'
require_relative 'text_formatter'

class Train
  attr_reader :number, :type, :wagons, :speed, :route

  NUMBER_FORMAT = /^([a-zа-я\d]{3}|[a-zа-я\d]-[a-zа-я\d]{2})$/i.freeze

  include Manufacturer
  include InstanceCounter
  include TextFormatter
  include Validation

  # Класс переменная для хранения всех созданных поездов
  @trains = []

  # Метод класса для доступа к @trains
  def self.all
    @trains
  end

  # Метод класса для поиска поезда по номеру
  def self.find(number)
    @trains.find { |train| train.number == number }
  end

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
        puts red_clr("\nWagon #{type} detached ×")
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
      # Поезд, прибывший на станцию, удаляется из её списка припаркованных в ней поездов:
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
    puts # \n - ни тут ни там не работают почему-то. Поэтому этот puts нет возможности убрать.
    input_empty?(:number, 'Train number')
    raise 'Invalid format! Should be: 3-33, 333, LLL or L-LL' if @number !~ NUMBER_FORMAT
  end

  # Метод сделан приватным так как используется только внутри класса для перемещения по маршруту.
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