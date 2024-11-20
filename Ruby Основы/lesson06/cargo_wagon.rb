require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class CargoWagon < Wagon

  include Validation
  include TextFormatter

  def initialize
    @type = 'cargo'
    super
  end
end
