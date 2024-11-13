# frozen_string_literal: true

# This method changes text style and color
module TextFormatter
  def clr(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end
end

def red_clr(message)
  clr(message, 91)
end