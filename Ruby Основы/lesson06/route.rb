require_relative 'validation'
class Route
  attr_reader :stations

  include InstanceCounter
  include TextFormatter
  include Validation

  @@all_routes = []

  # Метод класса для хранения всех маршрутов
  def self.all_routes
    @@all_routes
  end
  # Имеет начальную и конечную станцию, а также список промежуточных станций
  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    # Увеличиваем счетчик при создании нового экземпляра
    register_instance
    # Проверяем уникальность маршрута, различие в начальной и конечной станциях
    validate!
    # Добавляем маршрут в массив, если он прошёл проверку
    @@all_routes << self
    puts clr("\nRoute from #{first_station.name} to #{last_station.name} created ✓", 32)
  end

  # Добавляет промежуточную станцию в список
  def add_station(station)
    @stations.insert(-2, station)
    puts clr("\nStation #{station.name} added to the route ✓", 32)
  end

  # Удаляет промежуточную станцию из списка
  def delete_station(station)
    if station != @stations.first && station != @stations.last && @stations.include?(station)
      @stations.delete(station)
      puts red_clr("\nStation #{station.name} deleted from the route ×")
    end
  end

  def list_stations
    puts "\nList of stations on the selected route:"
    @stations.each do |station|
      puts station.name
    end
  end

  def validate!
    input_empty?(:stations, 'Station')
    raise red_clr('Starting and ending stations must be different!') if @stations.first == @stations.last
    raise red_clr('This route already exists!') if route_exists?
  end

  private

  def route_exists?
    self.class.all_routes.any? do |route|
      route.stations.first == @stations.first && route.stations.last == @stations.last
    end
  end
end