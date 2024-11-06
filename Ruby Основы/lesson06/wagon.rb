require_relative 'manufacturer'

class Wagon
  attr_reader :type

  include Manufacturer

end
