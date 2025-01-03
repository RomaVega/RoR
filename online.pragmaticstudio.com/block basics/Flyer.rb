# frozen_string_literal: true
class Flyer
  attr_reader :name, :email, :miles_flown

  def initialize(name, email, miles_flown)
    @name = name
    @email = email
    @miles_flown = miles_flown
  end

  def to_s
    "#{name} (#{email}): #{miles_flown}"
  end
end

flyers = []
1.upto(5) do |number|
  flyers << Flyer.new("Flyer #{number}", "#{number}@gmail.com", "#{number}"*10)
end
puts flyers

1.step(9,2) do |number|
  puts "#{number} situp"
  puts "#{number} pushup"
  puts "#{number} pullup"
end