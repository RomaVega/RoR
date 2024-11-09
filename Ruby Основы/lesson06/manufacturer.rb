# frozen_string_literal: true

module Manufacturer
  attr_accessor :manufacturer_name

  MANUFACTURERS = [
    'CRRC Corporation Limited', 'Alstom', 'Siemens Mobility', 'Bombardier Transportation',
    'Stadler Rail AG', 'Hyundai Rotem', 'Kawasaki Heavy Industries', 'Hitachi Rail',
    'CAF (Construcciones y Auxiliar de Ferrocarriles)', 'CJSC Transmashholding (TMH)'
  ].freeze

  def set_manufacturer
    puts 'Chose a manufacturer from the list:'
    list_manufacturers
    choice = gets.to_i - 1
    if choice.between?(0, MANUFACTURERS.size - 1)
      self.manufacturer_name = MANUFACTURERS[choice]
      puts
      puts clr("Manufacturer set to: #{manufacturer_name} ✓", 32)
    else
      puts
      puts 'Invalid choice. Please, select manufacturer from the list:'
    end
  end

  def get_manufacturer
    return puts 'Manufacturer not set.' if @trains.empty?

    puts 'List of trains and their manufacturers:'
    @trains.each do |train|
      manufacturer = train.manufacturer_name || 'not set.'
      puts clr("Train №#{train.number} - Manufacturer: #{manufacturer}", 37)
    end
  end

  private

  def list_manufacturers
    MANUFACTURERS.each_with_index do |manufacturer, index|
      puts clr("#{index + 1} - #{manufacturer}", 37)
    end
  end
end