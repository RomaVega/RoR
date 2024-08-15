print "What is your name?"
name = gets.chomp
print "What is your height?"
height = Integer(gets.chomp)
opt = ((height - 110)*1.15).to_i
print "#{name}, your optimal weight is: #{opt}"
