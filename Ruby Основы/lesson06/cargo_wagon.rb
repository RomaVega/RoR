require_relative 'wagon'
require_relative 'validation'
class CargoWagon < Wagon

  include Validation

  def initialize
    @type = 'cargo'
    super
  end
end
