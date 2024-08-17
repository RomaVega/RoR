print "Please, input triangle's first side length: "
tr_first_side = gets.chomp.to_f
print "Please, input triangle's second side length: "
tr_second_side = gets.chomp.to_f
print "Please, input triangle's third side length: "
tr_third_side = gets.chomp.to_f

if tr_third_side == tr_second_side && tr_second_side == tr_first_side
   puts "Triangle is equilateral"
end

if tr_third_side > tr_second_side && tr_third_side > tr_first_side
hypotenuse = tr_third_side
  if hypotenuse**2 == tr_second_side**2 + tr_first_side**2
  puts "Triangle is right"
    else puts "Triangle is not right"
  end
  elsif tr_second_side > tr_third_side && tr_second_side > tr_first_side
  hypotenuse = tr_second_side
  if hypotenuse**2 == tr_third_side**2 + tr_first_side**2
  puts "Triangle is right"
    else "Triangle is not right"
  end
    else
    hypotenuse = tr_first_side
      if hypotenuse**2 == tr_second_side**2 + tr_third_side**2
      puts "Triangle is right"
      else "Triangle is not right"
      end
end

 
