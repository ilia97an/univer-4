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
    self.zip(b).map {|l| l.reduce(:+)}
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
    @field = Array.new(FieldSize) {Array.new(FieldSize)}
  end

  # Задание 3 size (метод класса)
  def self.size
    FieldSize
  end

  # Задание 4 set!(n, x, y, hor, ship)
  def set! (n, x, y, hor, ship)
    n.times do
      @field[x][y] = ship
      if hor then x += 1 else y += 1 end
    end
  end

  # Задание 5 to_s
  def to_s
    line = "+" + "-" * Field.size + "+"
    res = line + "\n"
    @field.each do |row|
      res += "|"
      row.each {|x| res += (!x ? " " : x.to_s)}
      res += "|\n"
    end
    res += line
  end

  # Задание 6 print_field
  def print_field
    puts to_s
  end
  
  private
  def infield a #вспомогательная функция для задания 7
    a.between?(0, FieldSize_1)
  end
  
  # Задание 7 free_space?(n, x, y, hor, ship)
  public
  def free_space? (n, x, y, hor, ship)
    field_b = [x,y]
    dims = [0,n-1]
    if hor then dims.reverse! end
    field_e = field_b.add dims
    if (field_b + field_e).all? {|a| a.between?(0, FieldSize - 1)}
      dims = dims.add [1, 1]
      field_b.each_index do |i| 
        if field_b[i] > 0 
          field_b[i] -= 1
          dims[i] += 1
        end
      end
      field_e.each_index do |i| 
        if field_e[i] < FieldSize - 1 then dims[i] += 1 end
      end
      @field[field_b[0], dims[0]].all? do |row| 
        row[field_b[1], dims[1]].all? {|cell| !cell || cell == ship}
      end
    else
      false
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
  def set! (x, y, hor)
    if @myfield.free_space?(@len, x, y, hor, self)
      if @coord then clear end
      @myfield.set!(@len, x, y, hor, self)
      dim = [0, @len - 1]
      if hor then dim.reverse! end
      @coord = [x, y] + ([x, y].add dim) 
      @hor = hor
      true
    else
      false
    end
  end

  # Задание 12 kill
  def kill
    clear
    @coord = nil
  end

  # Задание 13 explode
  def explode
    @health -= 70
    if @health <= @minhealth then 
      kill 
      return @len
    end
    nil
  end
  
  # Задание 14 cure
  def cure
    @health += 30
    if @health > @maxhealth then @health = @maxhealth end
  end

  # Задание 15 health
  def health
    (100 * @health.to_f / @maxhealth).round(2)
  end
  
  # Задание 16 move(forward)
  def move forward 
    moves = [0, forward ? 1 : -1]
    if @hor then moves.reverse! end
    #p @coord
    #puts
    new_coord = @coord.add (moves + moves)
    set!(new_coord[0], new_coord[1], @hor)   
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
  def rotate (n, k)
    if n.between?(1, @len)
      new_hor = (k % 2 == 1) ? !@hor : @hor
      if k==1
        if @hor
          new_coord = [@coord[0] + n - 1, @coord[1] - n + 1]
        else
          new_coord = [@coord[2] + n - @len, @coord[3] + n - @len]
        end
        set!(new_coord[0], new_coord[1], new_hor)
      elsif k==2
        if @hor
          new_coord = [@coord[2] + 2 * n - 2* @len, @coord[3]]
        else
          new_coord = [@coord[2], @coord[3] + 2 * n - 2 * @len]
        end
        set!(new_coord[0], new_coord[1], new_hor)
      elsif k==3
        if @hor
          new_coord = [@coord[2] + n - @len, @coord[3] + n - @len]
        else
          new_coord = [@coord[0] - n + 1, @coord[1] + n - 1]
        end
        set!(new_coord[0], new_coord[1], new_hor)
      else
        false
      end
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
    @allships = Ships.map {|len| Ship.new(self, len)}
  end
  
  #задание 18
  def initialize
    super
    newships
  end
  
  # Задание 19 fleet
  def fleet
    @allships.each_with_index.map {|x, i| [i, x.len]}
  end
  
  # Задание 20 place_fleet pos_list
  def place_fleet pos_list
    res = pos_list.inject(true) do |a, l|
      a && @allships[l[0]].set!(l[1], l[2], l[3])
    end
    if res
      res = @allships.inject(true) {|a, ship| a && ship.coord}
    end
    if !res 
      #puts "@" #debug
      @allships.each {|ship| if ship.coord then ship.kill end}
    end
    res
  end
  
  # Задание 21 remains
  def remains
    @allships.each_with_index.map {|x, i| [i, x.coord, x.len, x.health]}
  end
  
  # # Задание 22 refresh
  # def refresh
  #   res = []
  #   @allships.each {|x| x.coord ? res.push(x) : nil}
  #   @allships = nil
  #   @allships = res
  # end
  def refresh
    @allships = @field.reduce(:|).find_all {|x| x}
  end

  # Задание 23 shoot c
  def shoot c
    if @field[c[0]][c[1]]
      if res = @field[c[0]][c[1]].explode
        refresh
        "killed #{res}"
      else
        "wounded"
      end
    else
      "miss"
    end
  end
  
  # Задание 24 cure
  def cure
    @allships.each {|ship| ship.cure}
  end
  
  # Задание 25 game_over?
  def game_over?
    @allships.empty?
  end
  
  # Задание 26 move l_move
  def move l_move
    if l_move[1].between?(1,3)
      @allships[l_move[0]].rotate(l_move[2], l_move[1])
    else
#      print "coord"
#      p @allships[l_move[0]].coord
#      puts
      @allships[l_move[0]].move(l_move[2] == 1)
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
    [rand(Field.size), rand(Field.size)]
  end
  
  # Задание 30 place_strategy ship_list
  def place_strategy ship_list
    tmp_field = Field.new
    dirs = [true, false]
    res = []
    (ship_list.sort {|x,y| y[1] <=> x[1]}).each do |s|
      flag = false
      while !flag
        p = random_point
        hor = dirs.sample
        if tmp_field.free_space?(s[1], p[0], p[1], hor, s[0])
          tmp_field.set!(s[1], p[0], p[1], hor, s[0])
          res.push [s[0], p[0], p[1], hor]
          flag = true
        end
      end
    end
    res
  end
  
  # Задание 31 hit message
  def hit message
    @lastshots.push [@shot, message] #uncomment debug
  end
  
  # Задание 31 miss
  def miss
    @allshots.push( hit("miss") )
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
      if @lastshots.length == 0 || @lastshots[-1][1][0,6] == "killed"
        @shot = random_point
      else 
        if @lastshots.length == 1 || @lastshots[-2][1][0,6] == "killed"
          @lastsample = [[0,1],[0,-1],[1,0],[-1,0]].sample
          @shot = @lastshots[-1][0]
        end
        @shot = @shot.add @lastsample
        if ! @shot.all? {|x| x.between?(0, Field.size-1)}
          @lastsample = @lastsample.map {|x| -x}
          @shot = (@lastshots[-1][0]).add @lastsample
        end
      end
      if @lastshots.any? {|x| x[0] == @shot}
        shot_strategy
      else
        @shot
      end
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
      weakest = (remains.sort {|a, b| a[3] <=> b[3]})[0]
      [weakest[0], rand(4), rand(1..weakest[2])]
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
    #print(p[0], " game setup\n") #uncomment debug
    p[0].reset
    player_ships = p[1].fleet
    if !p[1].place_fleet(p[0].place_strategy player_ships)
      raise "Illegal ship placement"
    else
      #puts
      #puts
      #puts p[0]
      #puts p[1]
      #puts "Ships placed" #uncomment debug
    end
  end
  
  # Задание 35 start
  def start 
    lastshots = []
    win = false #delete debug
    winner = nil #delete debug
    while ! @game_over
      p1 = @players[0]
      p2 = @players[1]
      p1[2] += 1 
      #print("Step #{p1[2]} of player ",p1[0], "\n") #uncomment debug
      p1[1].cure
      l_move = p1[0].ship_move_strategy p1[1].remains
      b = p1[1].move l_move
      if p1[0].to_s == "Ivan"# && !b
        #puts "impossible"
        print b
        puts
        puts p1[1]
        print l_move
        puts
      end
      shot = p1[0].shot_strategy
      if lastshots.include? shot
        #puts "Illegal shot" #uncomment debug
        res = "miss"
      else 
        lastshots.push shot
        res = p2[1].shoot shot
      end
      #print(shot, " ", res, "\n") #uncomment debug
      if res == "miss"
        p1[0].miss
        @players.reverse!
        lastshots = []
      else
        p1[0].hit res
        @game_over = p2[1].game_over?
        if @game_over #delete debug
          #puts "Player #{p1[0]} wins!" #uncomment debug
          win = true #delete debug
          winner = p1[0] #delete debug
          break
        end #delete debug
      end
    end
    win ? winner : nil #delete debug
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
#p1 = Player.new("Ivan",false)
#p2 = Player.new("Feodor",false)
#g = Game.new(p1,p2)
#g.start

