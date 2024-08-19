print "Please, input triangle's first side length: "
tr_first_side = gets.chomp.to_i
print "Please, input triangle's second side length: "
tr_second_side = gets.chomp.to_i
print "Please, input triangle's third side length: "
tr_third_side = gets.chomp.to_i


# Проверка равностороннего теугольника 
if tr_third_side == tr_second_side && tr_second_side == tr_first_side
   puts "Triangle is equilateral"
   return
end

# Проверка на нулевые вводы
if tr_third_side == 0 || tr_second_side == 0 || tr_first_side == 0
   puts "Triangle side cannot be zero"
   return
end

# Проверка 3ей стороны, является ли она гипотенузой
if tr_third_side > tr_second_side && tr_third_side > tr_first_side
   hypotenuse = tr_third_side

# Вложенная проверка по теореме Пифагора
   if hypotenuse**2 == tr_second_side**2 + tr_first_side**2
      puts "Triangle is right"
   else
      puts "Triangle is not right"
   end

# Проверка 2ой стороны, является ли она гипотенузой
elsif tr_second_side > tr_third_side && tr_second_side > tr_first_side
  hypotenuse = tr_second_side

# Вложенная проверка по теореме Пифагора  
    if hypotenuse**2 == tr_third_side**2 + tr_first_side**2
      puts "Triangle is right"
    else 
      puts "Triangle is not right"
     end

# Проверка 1ой стороны, является ли она гипотенузой 
elsif tr_first_side > tr_second_side && tr_first_side > tr_third_side
  hypotenuse = tr_first_side

# Вложенная проверка по теореме Пифагора
  if hypotenuse**2 == tr_second_side**2 + tr_third_side**2
    puts "Triangle is right"
  else 
    puts "Triangle is not right"
  end
end


 
