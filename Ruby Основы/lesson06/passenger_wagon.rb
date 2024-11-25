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
    puts clr("\nWagon #{@type} with #{@seats} seats added ✓", 32)
  end

  def set_seats
    puts "\nSet number of seats for this passenger wagon (30, 35 or 50):"
    seats = gets.chomp.to_i
    validate_passenger_volume(seats)
    @seats_total = seats
    @seats_occupied = 0
    @seats_available = seats
    puts clr("\nNumber of total seats set to: #{@seats_total} ✓", 32)
    self # Возвращаем объект
  rescue ArgumentError => e
    print red_clr("\n#{e}")
    retry
  end
  
  def take_seat
    @seats_available = @seats_total -= 1
    @seats_occupied += 1
    puts "\nOne seat in wagon #{self} is taken. #{@seats_available} available seats left."
  end

  def seats_occupied
    @seats_occupied
  end

  def seats_available
    @seats_available
  end
end