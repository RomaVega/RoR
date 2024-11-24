require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class PassengerWagon < Wagon
  attr_reader :seats

  include Validation
  include TextFormatter

  def initialize
    @type = 'passenger'
    @seats = 30
    puts clr("\nWagon #{@type} with #{@seats} vacant seats added ✓", 32)
    super
  end
  
  def take_seat
    puts "One seat in wagon #{self} is taken. #{@seats -= 1} seats left."
  end

  def seats_occupied
    puts "Occupied seat(s): #{30 - @seats}"
  end

  def seats_available
    puts "Available seat(s): #{@seats}"
  end
end