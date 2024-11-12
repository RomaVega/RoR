require_relative 'validation'
class Station
  attr_reader :name, :trains, :stations

  include InstanceCounter
  include TextFormatter
  include Validation

  # Класс переменная для хранения всех созданных станций
  @stations = []

  # Метод класса для доступа к @stations
  def self.all
    @stations
  end

  # Имеет название, которое указывается при ее создании:
  def initialize(station_name)
    @name = station_name
    @trains = []
    # Добавляем текущий объект станции в список всех станций
    self.class.all << self
    # Увеличиваем счетчик при создании нового экземпляра
    register_instance
  end

  # Может принимать поезда (по одному за раз):
  def let_train_in(train)
    @trains << train
    puts clr("\nTrain №#{train.number} arrived to station #{@name} ✓", 32)
  end

  # Может отправлять поезда
  # (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции):
  def dispatch(train)
    @trains.delete(train)
    puts clr("\nTrain №#{train.number} dispatched from station #{@name} ×", 91)
  end

  # Может возвращать список всех поездов на станции, находящиеся в текущий момент:
  def list_all_trains
    @trains.each do |train|
      puts clr("Type: #{train.type}, wagons: #{train.wagons.size}", 37)
    end
  end

  # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских:
  def list_trains_by_type(type)
    trains_by_type = @trains.select { |train| train.type == type }
    puts clr("\nTrains on the station: #{@name}, type: '#{type}':", 37)
    trains_by_type.each { |train| puts "Train №#{train.number}" }
  end
end