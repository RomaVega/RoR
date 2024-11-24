require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class CargoWagon < Wagon
  attr_reader :volume

  include Validation
  include TextFormatter

  def initialize
    @type = 'cargo'
    @volume = 100
    puts clr("\nWagon #{@type} with #{@volume}% free space added ✓", 32)
    super
  end

  def load(amount)
    @volume -= amount
    puts "Loaded volume: #{amount}"
  end
  
  def available_volume
    puts "Available volume: #{@volume}"
  end

  def occupied_volume
    puts "Occupied volume: #{100 - @volume}"
  end
end
