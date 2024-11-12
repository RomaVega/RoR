require_relative 'validation'
class Route
  attr_reader :stations

  include InstanceCounter
  include TextFormatter
  include Validation

  # Имеет начальную и конечную станцию, а также список промежуточных станций
  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    puts clr("\nRoute from #{first_station.name} to #{last_station.name} created ✓", 32)
    # Увеличиваем счетчик при создании нового экземпляра
    register_instance
    # Проверяем уникальность маршрута, различие в начальной и конечной станциях
    validate!
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
      puts clr("\nStation #{station.name} deleted from the route ×", 91)
    end
  end

  def list_stations
    puts "\nList of stations on the selected route:"
    @stations.each do |station|
      puts station.name
    end
  end

  def validate!
    validate_not_empty(:stations, 'Stations')
    raise clr('Starting and ending stations must be different!', 91) if @stations.first == @stations.last
  end
end