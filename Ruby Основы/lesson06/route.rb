class Route
  # Выводит список всех станций по порядку от начальной до конечной
  attr_reader :stations

  include InstanceCounter
  include TextFormatter

  # Имеет начальную и конечную станцию, а также список промежуточных станций
  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    puts clr("Route from #{first_station.name} to #{last_station.name} created ✓", 32)
    # Увеличиваем счетчик при создании нового экземпляра
    register_instance
  end

  # Добавляет промежуточную станцию в список
  def add_station(station)
    @stations.insert(-2, station)
    puts clr("Station #{station.name} added to the route ✓", 32)
  end

  # Удаляет промежуточную станцию из списка
  def delete_station(station)
    if station != @stations.first && station != @stations.last && @stations.include?(station)
      @stations.delete(station)
      puts
      puts clr("Station #{station.name} deleted from the route ×", 31)
    end
  end

  def list_stations
    puts 'List of stations on the selected route:'
    @stations.each do |station|
      puts station.name
    end
  end
end