# Чтобы иметь доступ к маршрутам:
require_relative 'route'
# Чтобы обновлять списки поездов на станции:
require_relative 'station'

class Train
  # Может возвращать номер вагона, тип, кол-во вагонов и текущую скорость:
  attr_reader :number, :type, :wagons, :speed

  # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов,
  # эти данные указываются при создании экземпляра класса:
  def initialize(number, type, wagons)
    @number = number
    @type = type
    @wagons = wagons
    @speed = 0
  end

  # Может набирать скорость:
  def speed_up(value)
    @speed += value
    puts "Speed up to: #{@speed}"
  end

  # Может тормозить (сбрасывать скорость до нуля):
  def stop
    @speed = 0
    puts 'Train stopped'
  end
  
  # Может прицеплять/отцеплять вагоны
  # (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов).
  # Прицепка/отцепка вагонов может осуществляться только если поезд не движется:
  def add_wagon
    if @speed.zero?
      @wagons += 1
      "Train length (number of wagons) increased by 1. Total: #{@wagons}"
    else
      'Cannot attach wagons while train is moving!'
    end
  end
  def detach_wagons
    if @speed.zero? && @wagons.positive?
      @wagons -= 1
      "Train length (number of wagons) reduced by 1. Total: #{@wagons}"
    else
      'Cannot detach wagons, train is either moving or not attached!'
    end
  end

  # Может принимать маршрут следования (объект класса Route):
  def accept_route(route)
    @route = route
    # При назначении маршрута поезду,
    # он автоматически помещается на первую станцию в маршруте:
    @current_station_index = 0
    # Поезд, прибывший на станцию, добавляется в её список припаркованных в ней поездов:
    current_station.let_train_in(self)
    puts "Маршрут принят. Поезд назодится на станции #{current_station.name}"
  end

  # Может перемещаться между станциями, указанными в маршруте.
  # Перемещение возможно вперед и назад, но только на 1 станцию за раз:
  def move_forward
    if next_station
      # Поезд, прибывший на станцию, удаляется из её списока припаркованных в ней поездов:
      current_station.dispatch(self)
      @current_station_index += 1
      current_station.let_train_in(self)
      puts "Поезд прибыл на станцию #{current_station.name}."
    else
      puts "Поезд уже на конечной станции маршрута #{current_station.name}."
    end
  end
  def move_backward
    if previous_station
      current_station.dispatch(self)
      @current_station_index -= 1
      current_station.let_train_in(self)
      puts "Поезд прибыл на станцию #{current_station.name}."
    else
      puts 'Поезд находится на начальной станции маршрута.'
    end
  end

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