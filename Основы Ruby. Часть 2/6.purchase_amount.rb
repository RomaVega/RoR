# Сумма покупок. Пользователь вводит поочередно:
# 1. название товара,
# 2. цену за единицу и
# 3. кол-во купленного товара (может быть нецелым числом).
# Пользователь может ввести произвольное кол-во товаров до тех пор,
# пока не введет "стоп" в качестве названия товара. На основе введенных данных требуетеся:
# Заполнить и вывести на экран хеш, ключами которого являются названия товаров,
# а значением - вложенный хеш, содержащий цену за единицу товара и кол-во купленного товара.
# Также вывести итоговую сумму за каждый товар.
# Вычислить и вывести на экран итоговую сумму всех покупок в "корзине".

items_price_pcs = {}
items_total_price = {}
total_cost = 0.0

loop do
  puts 'Input name of the item or type "стоп" / "stop" to exit:'
  item = gets.chomp
  break if item == 'stop' || item == 'стоп'

  puts 'Input price of the item'
  price = gets.chomp
  puts 'Input amount of pieces'
  pcs = gets.chomp.to_f

  # { "item" => { "price", "pieces" } }
  price_pcs = {}
  price_pcs[price] = pcs
  items_price_pcs[item] = price_pcs

  # Total price for each item
  item_total_price = price.to_i * pcs.to_f
  items_total_price[item] = item_total_price

  # Total cost
  total_cost += item_total_price
end

puts 'Item, price, pieces:', items_price_pcs
puts 'Total price for each item:', items_total_price
puts 'Total basket cost:', total_cost