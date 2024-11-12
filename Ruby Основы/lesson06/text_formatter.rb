# frozen_string_literal: true

# This method changes text style and color
module TextFormatter
  def clr(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end
end

def red_error(message)
  puts "#{clr(message, 31)}"
end