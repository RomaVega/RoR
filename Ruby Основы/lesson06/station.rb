class Station
  attr_reader :name, :trains, :stations

  include InstanceCounter

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
    puts "Train №#{train.number} arrived to the station #{@name} ✓"
  end

  # Может отправлять поезда
  # (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции):
  def dispatch(train)
    @trains.delete(train)
    puts "Train №#{train.number} dispatched from the station #{@name} ×"
  end

  # Может возвращать список всех поездов на станции, находящиеся в текущий момент:
  def list_all_trains
    @trains.each do |train|
      puts "Type: #{train.type}, wagons: #{train.wagons.size}"
    end
  end

  # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских:
  def list_trains_by_type(type)
    trains_by_type = @trains.select { |train| train.type == type }
    puts "Trains on the station: #{@name}, type: '#{type}':"
    trains_by_type.each { |train| puts "Train №#{train.number}" }
  end
end