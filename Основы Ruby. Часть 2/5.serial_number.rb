# Заданы три числа, которые обозначают число, месяц, год (запрашиваем у пользователя).
# Найти порядковый номер даты, начиная отсчет с начала года.
# Учесть, что год может быть високосным.
# (Запрещено использовать встроенные в ruby методы для этого вроде Date#yday или Date#leap?)

puts "Input date"
date = gets.chomp.to_i
puts "Input month"
month = gets.chomp.to_i
puts "Input year"
year = gets.chomp.to_i

days_in_normal_year = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
days_in_leap_year = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

if year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
  serial_number = days_in_leap_year[0...month - 1].sum + date.to_i
  print "Serial number is: #{serial_number}"
else
  serial_number = days_in_normal_year[0...month - 1].sum + date.to_i
  print "Serial number is: #{serial_number}"
end



