require_relative 'wagon'
require_relative 'validation'
class PassengerWagon < Wagon

  include Validation

  def initialize
    @type = 'passenger'
    super
  end
end