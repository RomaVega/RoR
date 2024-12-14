require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class CargoWagon < Wagon
  attr_reader :volume

  include Validation
  include TextFormatter

  def initialize
    super
    @type = 'cargo'
    @volume_total = []
    @volume_occupied = []
    @volume_available = []
  end

  def set_volume
    puts "\nSet volume for this cargo wagon (1-100):"
    volume = gets.chomp.to_i
    validate_cargo_volume(volume)
    @volume_total = volume
    @volume_occupied = 0
    @volume_available = volume
    puts clr("\nCargo wagon added and volume set to: #{@volume_total} ✓", 32)
    self # Возвращаем объект
  rescue ArgumentError => e
    print red_clr("\n#{e}")
    retry
  end

  def load_volume
    puts "\nHow much do you want to load on this wagon (1-#{@volume_available})?"
    amount = gets.chomp.to_i
    validate_loading_input(amount)
    @volume_occupied += amount
    @volume_available = @volume_total - amount
    puts clr("\nVolume loaded ✓", 32)
    puts "\nVolume available: #{@volume_available}"
  rescue ArgumentError => e
    print red_clr("\n#{e}")
    retry
  end
  
  def available_volume
    @volume_available
  end

  def occupied_volume
    @volume_occupied
  end
end
