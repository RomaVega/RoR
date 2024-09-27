class Route
  # Выводит список всех станций по порядку от начальной до конечной
  attr_reader :stations

  # Имеет начальную и конечную станцию, а также список промежуточных станций
  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
  end

  # Добавляет промежуточную станцию в список
  def add_station(station)
    @stations.insert(-2, station)
    puts "Station #{station.name} added to the route."
  end

  # Удаляет промежуточную станцию из списка
  def delete_station(station)
    if station != @stations.first && station != @stations.last && @stations.include?(station)
      @stations.delete(station)
      puts "Station #{station.name} deleted from the route."
    else
      puts "Station #{station.name} cannot be deleted or is not found in the route."
    end
  end

  def list_stations
    puts 'Станции маршрута:'
    @stations.each { |station| puts station.name}
  end
end