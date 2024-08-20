print "Enter a:"
a = gets.chomp.to_i
print "Enter b:"
b = gets.chomp.to_i
print "Enter c:"
c = gets.chomp.to_i

d = (b**2 - 4*a*c)

if d > 0
  x1 = (-b + Math.sqrt(d)) / 2*a
  x2 = (-b - Math.sqrt(d)) / 2*a
  puts "d = #{d}"
  puts "x1 = #{x1}"
  puts "x2 = #{x2}"
 
  elsif d == 0
  x1 = (-b + Math.sqrt(d)) / 2*a
  x2 = (-b - Math.sqrt(d)) / 2*a
  puts "d = #{d}"
  puts "x1 = #{x1}"

  else puts "Квадратных корней нет"
end
