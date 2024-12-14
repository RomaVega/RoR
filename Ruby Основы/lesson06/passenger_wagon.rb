require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class PassengerWagon < Wagon
  attr_reader :seats

  include Validation
  include TextFormatter

  def initialize
    super
    @type = 'passenger'
    @seats_total = []
    @seats_occupied = []
    @seats_available = []
  end

  def set_seats
    puts "\nSet number of seats for this passenger wagon (33, 55 or 77):"
    seats = gets.chomp.to_i
    validate_passenger_volume(seats)
    @seats_total = seats
    @seats_occupied = 0
    @seats_available = seats
    puts clr("\nPassenger wagon added and number of total seats set to: #{@seats_total} ✓", 32)
    self # Возвращаем объект
  rescue ArgumentError => e
    print red_clr("\n#{e}")
    retry
  end
  
  def take_seat
    @seats_available = @seats_total -= 1
    @seats_occupied += 1
    puts clr("\nOne seat is taken ✓", 32)
    puts "\nAvailable seats left: #{@seats_available}"
  end

  def seats_occupied
    @seats_occupied
  end

  def seats_available
    @seats_available
  end
end