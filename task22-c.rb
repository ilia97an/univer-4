require_relative './lab-6-reference'

class AULOV_Player < Player

###############################################################################
#размещение
###############################################################################

  #само по себе это усовершенствование работает против применяющего игрока
  #но с доработанной стратегией движения должно улучшиться
  def place_strategy ship_list
    tmp_field = Field.new #старый кусок
    dirs = [true, false]
    res = [] #старый кусок кончился
    #сначала расставить корабли на краю, а оставшихся разместить случайно
    (ship_list.sort {|x,y| y[1] <=> x[1]}).each do |s|
      sides = sidesget(tmp_field, s) #клетки по бокам карты
      if sides.empty? #если не получилось найти места с краю - ставить случайно
        flag = false  #старый кусок
        while !flag
          p = random_point
          hor = dirs.sample
          if tmp_field.free_space?(s[1], p[0], p[1], hor, s[0])
            tmp_field.set!(s[1], p[0], p[1], hor, s[0])
            res.push [s[0], p[0], p[1], hor]
            flag = true
          end
        end  #старый кусок кончился
      else
        #puts "sides"
        p = sides.sample
        tmp_field.set!(s[1], p[0], p[1], p[2], s[0])
        #puts tmp_field
        res.push([s[0], p[0], p[1], p[2]])
      end
    end
    #puts "!"
    res
    #ответом будет лист кораблей на краю и случайных
  end
  
  private
  #проходит по всем краевым клеткам с нужной ориентацией и если корабль можно 
  #разместить, то добавляет в выходной массив
  def sidesget(field, ship) #возвращает четыре массива свободных клеток
    #print(ship)
    #puts
    res = []
    (0..(Field.size - 1)).to_a.each do |col|
      (0..(Field.size - 1)).to_a.each do |row|
        g = false
        r = false
        hor = false
        ver = false #пропустить эту клетку, если она не краевая
        #если мы в первой или последней колонке, то горизонтально
        (col == 0 || col == Field.size - 1) ? hor = true : nil
        (row == 0 || row == Field.size - 1) ? ver = true : nil
        #непонятно -- почему нужно инвертировать горизонтальность,но работает
        if hor && field.free_space?(ship[1], col, row, !hor, ship[0])
          res.push([col, row, !hor])
          g = true
          #print([col, row, true]) #горизонтально
          #puts
        end
        #непонятно -- почему нужно инвертировать горизонтальность,но работает
        if ver && field.free_space?(ship[1], col, row, ver, ship[0])
          res.push([col, row, ver]) #вертикаль наоборот дает горизонталь
          r = true
          #print([col, row, false]) #не горизонтально
          #puts
        end
#        if ver && hor
#          if g && r
#            print("1")
#          else
#            if r
#              print("2")
#            else
#              g ? print("3") : print("4")
#            end
#          end
#        else
#          if ver
#            r ? print("V") : print("v")
#          else
#            if hor
#              g ? print("H") : print("h")
#            else
#              print("-")
#            end
#          end
#        end
      end
#      print("\n")
    end
    res
  end
  
###############################################################################
#движение
###############################################################################
  private
  def hor?(s) #is hor?
    hor = (s[1][1] == s[1][3]) #если первая координата не меняется в начале
                               #и конце корабля, то он горизонтальный
  end
#  def shipset(s, field)
#    hor
#    field.set!(s[2], s[1][0], s[1][1], hor, s[0])
#  end

  
  def placefleet pos_list
    pos_list.inject(true) do |a, l|
      a && @allships[l[0]].set!(l[1], l[2], l[3])
    end
  end
  
  #изменяет лист remains, добавляя в него объект корабля размещенный на поле
  def createships(remains) #создает поле, наполненное указанными кораблями
    field = Field.new
    ships = []
    res = remains.map do |s|
      ship = Ship.new(field, s[2])
      ship.set!(s[1][0], s[1][1], hor?(s))
      #[s[0], s[1], s[2], s[3], ship]
      ships.push(ship)
    end
    ships
  end
  
  def setships(remains)
    field = Field.new
    remains.each {|s| field.set!(s[2], s[1][0], s[1][1], hor?(s), s[0])}
    field
  end
  
  def move(ship, l_move)
    if l_move[1].between?(1,3)
      ship.rotate(l_move[2], l_move[1])
    else
      ship.move(l_move[2] == 1)
    end
  end

  public
  def ship_move_strategy remains
    sorted = remains.sort {|a, b| a[3] <=> b[3]}
    stop = false
    res = [0, 0, 0]
    while !stop && !sorted.empty?
      weakest = sorted[0]
      #формирование массива всех возможных и невозможных передвижений
      premoves = []
      (1..3).to_a.each do |move_t| #добавить повороты
        (1..weakest[2]).to_a do |dir| #повороты вокруг клеток
          premoves.push([weakest[0], move_t, dir])
        end
      end
      premoves.push([weakest[0], 0, 0]) #добавить съезд назад
      premoves.push([weakest[0], 0, 1]) #добавить съезд вперед
      #оставить только возможные передвижения
      moves = []
      #при проверке каждый раз заново создавать карту
      premoves.each { |l_move| 
        #отметить временное поле всеми имеющимися кораблями
        field = setships(remains) 
        #создать объект самого слабого корабля специально для временного поля
        ship = Ship.new(field, weakest[2])
        #установить самый слабый корабль на поле
        ship.set!(weakest[1][0], weakest[1][1], hor?(weakest))
        #повернуть самый слабый корабль на поле
        move(ship, l_move) ? (moves.push(l_move)) : nil 
      }
      if moves.empty? #если возможных движений корабля нет, то двигать другой
        sorted.delete_at(0) #для этого удаляем из листа самый слабый корабль
      else
        stop = true #если есть возможные движения для самого слабого, то
        res = moves.sample #выбираем любое движение
      end
    end
    res #если никакой корабль не сдвинуть, то вернуть как [0, 0, 0]
  end
end

###############################################################################
#тесты
###############################################################################

p1 = AULOV_Player.new("Ivan",false)
p2 = Player.new("Default",false)
i = 0
p1wins = 0
p2wins = 0
while i < 100
  g = Game.new(p1,p2)
  p1 == g.start ? p1wins += 1 : p2wins += 1
  i += 1
end
print(p1, " ", p1wins, "; ", p2, " ", p2wins, "\n\n")
