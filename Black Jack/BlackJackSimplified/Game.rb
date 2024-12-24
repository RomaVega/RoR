#!/usr/bin/env ruby
# frozen_string_literal: true

# -------------------------------------------------------
# Подготовка колоды и вспомогательных функций
# -------------------------------------------------------

VALUES = {
  '2'  => 2,  '3'  => 3,  '4'  => 4,  '5'  => 5,
  '6'  => 6,  '7'  => 7,  '8'  => 8,  '9'  => 9,
  '10' => 10, 'J'  => 10, 'Q'  => 10, 'K'  => 10, 'A' => 1
}.freeze

SUITS = ['+', '<3', '^', '<>'].freeze

def create_deck
  deck = []
  VALUES.each do |val_str, val_points|
    SUITS.each do |suit|
      deck << ["#{val_str}#{suit}", val_points]
    end
  end
  deck.shuffle
end

def calculate_score(cards)
  sum = cards.sum { |c| c[1] }
  ace_count = cards.count { |c| c[0].include?('A') }

  ace_count.times do
    sum += 10 if sum + 10 <= 21
  end
  sum
end

def show_cards(cards)
  cards.map { |c| c[0] }.join('  ')
end

def show_dealer_cards(cards, hidden: true)
  return cards.map.with_index { |c, i| hidden && i < 2 ? '**' : c[0] }.join('  ')
end

# -------------------------------------------------------
# Основной цикл
# -------------------------------------------------------

puts "\nДобро пожаловать в Блэкджек!"
print "Введите ваше имя: "
player_name = gets.chomp

player_bank = 100
dealer_bank = 100

loop do
  if player_bank < 10 || dealer_bank < 10
    puts "\nУ кого-то из игроков недостаточно средств!"
    break
  end

  pot = 20
  player_bank -= 10
  dealer_bank -= 10

  deck = create_deck

  player_cards = [deck.pop, deck.pop]
  dealer_cards = [deck.pop, deck.pop]

  player_score = calculate_score(player_cards)
  dealer_score = calculate_score(dealer_cards)

  puts "\n--- Новая раздача ---"
  puts "\n#{player_name}, ваши карты: #{show_cards(player_cards)}"
  puts "Сумма очков: #{player_score}"

  puts "\nКарты дилера: #{show_dealer_cards(dealer_cards, hidden: true)}"

  player_can_hit = true
  game_over = false

  def check_auto_open(p_cards, d_cards)
    p_cards.size == 3 && d_cards.size == 3
  end

  until game_over
    # --- Ход игрока ---
    unless check_auto_open(player_cards, dealer_cards)
      puts "\nВаш ход (1 - Пропустить, 2 - Добавить карту, 3 - Открыть): "
      choice = gets.chomp

      if choice == '1'
        # Пропустить => переход хода дилеру
      elsif choice == '2'
        # Добавить карту, но только если у игрока ровно 2 карты и не брал ещё
        if player_can_hit && player_cards.size == 2
          player_cards << deck.pop
          player_score = calculate_score(player_cards)
          puts "\nВы взяли карту: #{player_cards.last[0]}"
          puts "Теперь у вас очков: #{player_score}"
          player_can_hit = false
          game_over = true if player_score > 21
        else
          puts "\nВы уже не можете взять карту!"
        end
      elsif choice == '3'
        # Открыть
        game_over = true
      else
        puts "\nНеверный ввод, пропускаем ход."
      end
    else
      # У обоих по 3 карты => вскрываемся
      game_over = true
    end

    break if game_over

    # --- Ход дилера ---
    dealer_score = calculate_score(dealer_cards)
    if dealer_score < 17 && dealer_cards.size < 3
      dealer_cards << deck.pop
      dealer_score = calculate_score(dealer_cards)
      puts "\nДилер взял карту."
    else
      puts "\nДилер пропустил ход."
    end

    # Проверка перебора
    game_over = true if dealer_score > 21
    # Если у дилера 3 карты и у игрока 3 или тоже 2 -> вскрытие
    game_over = true if check_auto_open(player_cards, dealer_cards)
  end

  # Вскрытие, подсчёт результатов
  player_score = calculate_score(player_cards)
  dealer_score = calculate_score(dealer_cards)

  puts "\n--- Итоги раунда ---"
  puts "Карты дилера: #{show_dealer_cards(dealer_cards, hidden: false)}"
  puts "Очки дилера: #{dealer_score}"
  puts "#{player_name}, ваши карты: #{show_cards(player_cards)}"
  puts "Ваши очки: #{player_score}"

  if player_score > 21
    puts "\nУ вас перебор. Вы проиграли!"
    dealer_bank += pot
  elsif dealer_score > 21
    puts "\nДилер перебрал! Вы выиграли!"
    player_bank += pot
  elsif player_score > dealer_score
    puts "\nВы выиграли!"
    player_bank += pot
  elsif dealer_score > player_score
    puts "\nВы проиграли!"
    dealer_bank += pot
  else
    puts "\nНичья! Возвращаем ставки."
    player_bank += 10
    dealer_bank += 10
  end

  puts "\nБанк игрока: $#{player_bank}"
  puts "Банк дилера: $#{dealer_bank}"

  if player_bank < 10
    puts "\nУ вас недостаточно средств!"
    break
  end
  if dealer_bank < 10
    puts "\nУ дилера недостаточно средств!"
    break
  end

  print "\nСыграть ещё раз? (y/n): "
  ans = gets.chomp.downcase
  break unless ans == 'y'
end

puts "\nСпасибо за игру, #{player_name}!"