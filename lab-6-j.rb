## Шаблон для выполнения заданий Лабораторной работы №6 
## ВСЕ КОММЕНТАРИИ ПРИВЕДЕННЫЕ В ДАННОМ ФАЙЛЕ ДОЛЖНЫ ОСТАТЬСЯ НА СВОИХ МЕСТАХ
## НЕЛЬЗЯ ПЕРЕСТАВЛЯТЬ МЕСТАМИ КАКИЕ-ЛИБО БЛОКИ ДАННОГО ФАЙЛА
## решения заданий должны быть вписаны в отведенные для этого позиции 

################################################################################
# Задание 1 
# add b
################################################################################

class Array
  def add b
    res = []
    self.each_index{ |i| res.push(self[i] + b[i]) }
    res
  end

  def swap!(a) #вспомогательная функция для задания 17
    self.each_index do |i| 
      z = self[i]
      self[i] = a[i]
      a[i] = z
    end
  end
end

# конец описания задания 1
################################################################################

################################################################################
# Задания 2-6 
# Класс Field
################################################################################

class Field
  #attr_reader :field #debug 
  FieldSize = 10 #задание 2
  
  private #для проверок на строгое неравенство
  FieldSize_1 = FieldSize - 1
  
  public
  #задание 2
  def initialize
    @field = Array.new(FieldSize) do 
      Array.new(FieldSize) {nil}
    end
  end

  # Задание 3 size (метод класса)
  def self.size
    FieldSize
  end

  # Задание 4 set!(n, x, y, hor, ship)
  def set!(n, x, y, hor, ship)
    n -= 1
    xs = gen_xs(n, x, y, hor)
    ys = gen_ys(n, x, y, hor)
    xs.each do |i|
      ys.each { |j| @field[i][j] = ship }
    end
  end

  # Задание 5 to_s
  def to_s
    bar = '+'
    FieldSize.times {bar += '-'}
    bar += '+'
    body = 
      @field.inject(bar + "\n") do |body, xs|
        body += '|' +
          xs.inject('') do |memo, field|
            memo + (field ? field.to_s : ' ')
          end
        body + "|\n"
      end
    body += bar
  end

  # Задание 6 print_field
  def print_field
    print to_s + "\n"
  end
  
  private
  def infield a #вспомогательная функция для задания 7
    a.between?(0, FieldSize_1)
  end
  
  # Задание 7 free_space?(n, x, y, hor, ship)
  public
  def free_space?(n, x, y, hor, ship)
    n -= 1
    xs = gen_xs(n, x, y, hor)
    ys = gen_ys(n, x, y, hor)
    #i и j будет содержать координаты клеток
    xs.all? do |i|
      longcond = #длинное условие
        ys.all? do |j| 
          f = []
          i_1 = i - 1
          j_1 = j - 1
          #создать массив содержимого соседних клеток 3x3
          3.times do |m|
            3.times do |n|
              i_ = i_1 + m
              j_ = j_1 + n
              (infield(i_) && infield(j_)) ? (f.push @field[i_][j_]) : nil
            end
          end
          infield(j) && (f.all? {|x| [nil, ship].include? x})
        end
      infield(i) && longcond
    end
  end

  #вспомогательные функции для 4-го и 7-го задания
  private
  def gen_xs(n, x, y, hor) #требует n на один меньше реального
    hor ? (x..x + n).to_a : [x]
  end
  
  def gen_ys(n, x, y, hor) #требует n на один меньше реального
    hor ? [y] : (y..(y + n)).to_a
  end
end

# конец описания класса Field
################################################################################


################################################################################
# Задания 8-17 
# Класс Ship
################################################################################

class Ship
  attr_reader :len, :coord #задание 8

  #задание 8
  def initialize(field, len)
    @len = len
    @myfield = field
    @maxhealth = 100 * len
    @minhealth = 30 * len
    @health = @maxhealth
  end
  
  # Задание 9 to_s
  def to_s
    "X"
  end
  
  # Задание 10 clear
  def clear
    @myfield.set!(@len, @coord[0], @coord[1], @hor, nil)
  end
  
  # Задание 11 set!(x, y, hor)
  def set!(x, y, hor)
    b = @myfield.free_space?(@len, x, y, hor, self)
    if b
      @coord == nil ? nil : clear #если coord существует, то очистить
      @myfield.set!(@len, x, y, hor, self)
      @coord = [x, y, x, y]
      hor ? (@coord[2] += @len - 1) : (@coord[3] += @len - 1)
      @hor = hor
    end
    b
  end

  # Задание 12 kill
  def kill
    clear
    @coord = nil
  end

  # Задание 13 explode
  def explode
    @health -= 70
    if @health <= @minhealth
      kill
      @len
    end
  end
  
  # Задание 14 cure
  def cure
    (@health += 30) > @maxhealth ? @health = @maxhealth : nil
  end

  # Задание 15 health
  def health
    ((@health * 100).to_f / @maxhealth).round(2)
  end
  
  # Задание 16 move(forward)
  def move(forward)
    dif = forward ? 1 : -1 #определение вперед или назад поедет корабль
    x_ = @coord[0] #инициализация
    y_ = @coord[1] #инициализация
    @hor ? (x_ += dif) : (y_ += dif) #вертикально или горизонтально поедет
    b = @myfield.free_space?(@len, x_, y_, @hor, self)
    if b
      clear
      set!(x_, y_, @hor)
    end
    b
  end
  
  #вспомогательный метод к заданию 17
  def rotate_len(n, x, y, k)
    xc = x + n * (@hor ? 1 : 0)
    yc = y + n * (@hor ? 0 : 1)
    x_xc = x - xc
    y_yc = y - yc
    x_ = x_xc * kcos(k) - y_yc * ksin(k) + xc
    y_ = x_xc * ksin(k) + y_yc * kcos(k) + yc
    [x_, y_]
  end

  # Задание 17 rotate(n, k)
  def rotate(n, k)
    if k.between?(1,3) && n > 0
      p1 = [@coord[0], @coord[1]]
      p2 = [@coord[2], @coord[3]]
      p1_ = rotate_len(n - 1, p1[0], p1[1], k)
      p2_ = rotate_len(n - @len, p2[0], p2[1], k)
      hor_ = k == 2 ? @hor : (!@hor)
      (p2_[0] < p1_[0] || p2_[1] < p1_[1]) ? p1_.swap!(p2_) : nil
      set!(p1_[0], p1_[1], hor_)
    else
      false
    end
  end
  
  private
  def kcos(a) #вспомогательная функция для задания 17
    a == 2 ? -1 : 0
  end
  
  def ksin(a) #вспомогательная функция для задания 17
    if a == 1
      1
    else
      a == 2 ? 0 : -1
    end
  end
end

# конец описания класса Ship
################################################################################

################################################################################
# Задания 18-26
# Класс BattleField
################################################################################

class BattleField < Field
  Ships = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1] #задание 18
  
  #задание 18
  def newships
    @allships = []
    Ships.each_with_index {|x, i| @allships[i] = Ship.new(self, x)}
  end
  
  #задание 18
  def initialize
    super
    newships
  end
  
  # Задание 19 fleet
  def fleet
    ret = []
    @allships.each_with_index {|x, i| ret[i] = [i, x.len]}
    ret
  end
  
  # Задание 20 place_fleet pos_list
  def place_fleet pos_list
    if pos_list && pos_list.length == BattleField::Ships.length
      able = pos_list.all? {|f| @allships[f[0]].set!(f[1], f[2], f[3])}
    else
      able = false
    end
    able ? nil : @allships.each {|x| x.coord ? x.kill : nil}
    able
  end
  
  # Задание 21 remains
  def remains
    ret = []
    @allships.each_with_index {|x, i| ret[i] = [i, x.coord, x.len, x.health]}
    ret
  end
  
  # # Задание 22 refresh
  # def refresh
  #   res = []
  #   @allships.each {|x| x.coord ? res.push(x) : nil}
  #   @allships = nil
  #   @allships = res
  # end
  def refresh
    @allships.each {|x| x.coord ? nil : @allships.delete(x)}
  end

  # Задание 23 shoot c
  def shoot c
    if (ship = @field[c[0]][c[1]]) && (n = ship.explode)
      refresh
      "killed " + n.to_s
    else 
      ship ? "wounded" : "miss"
    end
  end
  
  # Задание 24 cure
  def cure
    @allships.each {|x| x.cure}
  end
  
  # Задание 25 game_over?
  def game_over?
    @allships == []
  end
  
  # Задание 26 move l_move
  def move l_move
    i = l_move[0]
    dir = l_move[2]
    move_t = l_move[1]
    if move_t.between?(1, 3)
      @allships[i].rotate(dir, move_t)
    else
      @allships[i].move(dir == 1 ? true : false)
    end
  end
end

# конец описания класса BattleField
################################################################################


################################################################################
# Задания 27-33
# Класс Player
################################################################################
class Player
  attr_accessor :manual #задание 27
  
  #задание 27
  def reset
    @allshots = []
    @lastshots = []
  end
  
  #задание 27
  def initialize(name, manual = true)
    @name = name
    @manual = manual
    @lastsample = [1, 0]
    reset
  end
  
  # Задание 28 to_s
  def to_s
    @name
  end
  
  # Задание 29 random_point
  def random_point
    [rand(0..Field::FieldSize_1), rand(0..Field::FieldSize_1)]
  end
  
  # Задание 30 place_strategy ship_list
  def place_strategy ship_list
    field = Field.new
    ship_list.map do |s|
      ship = Ship.new(field, s[1])
      [s[0]] + putship(ship) #putship это цикл размещающий один корабль
    end
  end
  
  # Задание 31 hit message
  def hit message
    @lastshots.push [@shot, message]
  end
  
  # Задание 31 miss
  def miss #задание 31
    @lastshots.push [@shot, "miss"]
    @allshots.push @lastshots
    @lastshots = []
  end
  
  # Задание 32 shot_strategy
  def shot_strategy
    if @manual
      @lastshots.each {|x| print(x, "\n")}
      puts "Make a shot. To switch off the manual mode enter -1 for any coordinate"
      while true
        print "x = "; x = gets.to_i; print x
        print " y = "; y = gets.to_i; puts y
        shot = [x,y]
        if shot.all? {|a| a.between?(-1, Field.size - 1)}
          break
        else
          puts "Incorrect input"
        end
      end
      if shot.any? {|a| a == -1}
        @manual = false
        shot_strategy
      else
        @shot = shot
      end
    else
      # Здесь необходимо разместить решение задания 32
      #выстрелы уже были?
      if (!@lastshots.empty?) && (!@lastshots[-1][1] == "killed")
        #сейчас не первый выстрел -- стрелять по соседним клеткам
        #проверить -- сейчас второй выстрел?
        #если сейчас только второй выстрел, выбрать случайную соседнюю клетку
        #если больше двух попаданий -- стрелять только дволь выбранной оси
        if @lastshots.length == 1 || @lastshots[-2][1] == "killed"
          @lastsample[0] = rand(3) - 1
          @lastsample[1] = dx != 0 ? 0 : rand(3) - 1
        end
        #по итогу обязательно выбрана какая-то ось и нужно стрелять по ней
        shot = @lastshots[-1][0].add @lastsample
        if !shot[0].between?(0..FieldSize) || !shot[1].between?(0..FieldSize)
          @lastsample = [@lastsample[0] * (-1), @lastsample[1] * (-1)]
          shot = @lastshots[-1][0].add @lastsample
          (@lastshots.any? {|x| x[0] == shot}) ? shot_strategy : nil
        end
        @shot = shot
      else
        #сейчас первый выстрел -- стрелять наугад
        @shot = random_point
      end
      # конец решения задания 32
    end
  end

  # Задание 33 ship_move_strategy remains
  def ship_move_strategy remains
    if @manual
      puts "Ship health"
      tmp_field = Field.new
      names = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a
      ship_hash = {}
      remains.each do |ship|
        name = names[ship[0]]
        x = ship[1][0]; y = ship[1][1]
        hor = (ship[1][1] == ship[1][3])
        ship_hash[name] = [ship[0], ship[2]]
        tmp_field.set!(ship[2], x, y, hor, name)
        print(name, " - ", ship[3], "%\n") 
      end
      puts "Your ships"
      tmp_field.print_field
      puts "Make a move. To switch off the manual mode enter an incorrect ship name"
      while true
        print "Choose ship: "; 
        name = gets.strip; puts name
        if !ship_hash[name] then break end
        move = 0
        begin
          print "Enter 0 to move, 1-3 to rotate: " 
          move = gets.to_i; puts move
        end until move.between?(0,3)
        if move == 0
          print "1 - forward/any - backward): "; dir = gets.to_i
          puts dir
        else
          dir = 0
          begin
            print "Choose a center point: (1..#{ship_hash[name][1]}): "
            dir = gets.to_i; puts dir
          end until dir.between?(1,ship_hash[name][1])
        end
        break
      end
      if !ship_hash[name]
        @manual = false
        ship_move_strategy remains
      else
        [ship_hash[name][0], move, dir]
      end
    else
      # Здесь необходимо разместить решение задания 33
      ship = (remains.sort {|a, b| a[3] <=> b[3]})[0] #выбрать самый поврежденный
      move_t = rand(4)
      dir = rand(1..ship[2])
      i = nil
      remains.each_with_index {|e, j| (i == nil && e == ship) ? i = j : nil}
      [i, move_t, dir]
      # конец решения задания 33
    end
  end 

  private
  def putship(ship) #вспомогательная функция для задания 30
    p = []
    hor = false
    resume = true
    while resume
      hor = rand(2) == 1 ? true : false
      p = random_point
      resume = ship.set!(p[0], p[1], hor) ? false : true
    end
    p + [hor]
  end
end

# конец описания класса Player
################################################################################

################################################################################
# Задания 34-35 
# Класс Game
################################################################################

class Game
  # Задание 34
  def initialize(player_1, player_2)
    @game_over = false
    @players = [[player_1, BattleField.new, 0], [player_2, BattleField.new, 0]]
    @players.each {|p| reset p}
    @players.shuffle!
  end
  
  # Задание 34
  def reset p
    puts((player = p[0]).to_s + " game setup")
    player.reset
    fleet = (bfield = p[1]).fleet
    place = player.place_strategy fleet
    if bfield.place_fleet place
      puts "Ships placed"
    else
      raise "Illegal ship placement"
    end
  end
  
  # Задание 35 start
  def start
    lastshots = []
    while !@game_over
      n = (@players[0][2] += 1) #увеличить счетчик выстрелов игрока
      player = @players[0][0]
      puts("Step " + n.to_s + " of player " + player.to_s)
      (bfield = @players[0][1]).cure
      remains = bfield.remains
      l_move = player.ship_move_strategy remains
      bfield.move l_move
      shot = player.shot_strategy
      if lastshots.any? shot 
        puts "Illegal shot"
        res = "miss"
      else
        lastshots.push shot
        res = @players[1][1].shoot shot
      end
      print("[ " + shot[0].to_s + " , " + shot[1].to_s + " ] " + res + "\n")
      if res == "miss"
        player.miss
        @players.reverse!
        lastshots = []
      else
        player.hit res
        if (@game_over = @players[1][1].game_over?)
          print("Player " + player.to_s + " wins!\n")
        end
      end
    end
  end
end

# конец описания класса Game
################################################################################

################################################################################
# Переустановка датчика случайных чисел
################################################################################
srand
################################################################################

# Пример запуска
p1 = Player.new("Ivan",true)
p2 = Player.new("Feodor")
g = Game.new(p1,p2)
#g.start

