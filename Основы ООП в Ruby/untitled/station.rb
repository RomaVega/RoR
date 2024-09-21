class Station
  attr_reader :name, :trains
  # Имеет название, которое указывается при ее создании:
  def initialize(station_name)
    @name = station_name
    @trains = []
  end

  # Может принимать поезда (по одному за раз):
  def let_train_in(train)
    @trains << train
  end

  # Может отправлять поезда
  # (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции):
  def dispatch(train)
    @trains.delete(train)
  end

  # Может возвращать список всех поездов на станции, находящиеся в текущий момент:
  def list_all_trains
    puts "Поезда на станции #{@name}:"
    @trains.each { |train| puts "Поезд №#{train.number}, тип: #{train.type}, вагонов: #{train.wagons}" }
  end

  # Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских:
  def list_trains_by_type(type)
    trains_by_type = @trains.select { |train| train.type == type }
    puts "Поезда на станции #{@name} типа '#{type}':"
    trains_by_type.each { |train| puts "Поезд №#{train.number}" }
  end

end