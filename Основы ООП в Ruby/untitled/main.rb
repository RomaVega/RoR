# frozen_string_literal: true

require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'

# Создаём станции
station1 = Station.new('Москва')
station2 = Station.new('Тула')
station3 = Station.new('Орел')

# Создаём маршрут
route = Route.new(station1, station3)
route.add_station(station2)

# Создаём поезда
train1 = Train.new('001A', 'passenger')
train2 = Train.new('002B', 'cargo')

# Назначаем маршруты поездам
train1.accept_route(route)
train2.accept_route(route)

# Создаём вагоны
passenger_wagon = PassengerWagon.new
cargo_wagon = CargoWagon.new

# Прицепляем вагоны к поездам
train1.add_wagon(passenger_wagon)
train2.add_wagon(cargo_wagon)

# Пытаемся прицепить неправильный вагон
train1.add_wagon(cargo_wagon) # Должно выдать сообщение об ошибке

# Отправляем поезда по маршруту
train1.move_forward
train2.move_forward

# Выводим список поездов на станции
station2.list_all_trains