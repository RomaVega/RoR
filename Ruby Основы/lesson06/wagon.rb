require_relative 'manufacturer'

class Wagon
  attr_reader :type

  include Manufacturer

end

class PassengerWagon < Wagon
  def initialize
    @type = 'passenger'
  end
end

class CargoWagon < Wagon
  def initialize
    @type = 'cargo'
  end
end
