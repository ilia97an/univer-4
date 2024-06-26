require_relative './lab-6-reference'

class AULOV_Player < Player
  def place_strategy ship_list
    tmp_field = Field.new #старый кусок
    dirs = [true, false]
    res = [] #старый кусок кончился
    #сначала расставить корабли на краю, а оставшихся разместить случайно
    suspend = false #остановить краевую расстановку, начать формирование листа
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
        puts tmp_field
        res.push(s[0], p[0], p[1], p[2])
      end
    end
    puts "!"
    res
    #ответом будет лист кораблей на краю и случайных
  end
  
  private
  #проходит по всем краевым клеткам с нужной ориентацией и если корабль можно 
  #разместить, то добавляет в выходной массив
  def sidesget(field, ship) #возвращает четыре массива свободных клеток
    print(ship)
    puts
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
end

###############################################################################
#тесты
###############################################################################

p1 = AULOV_Player.new("Ivan",false)
p2 = Player.new("Default",false)
i = 0
p1wins = 0
p2wins = 0
while i < 10
  g = Game.new(p1,p2)
  p1 == g.start ? p1wins += 1 : p2wins += 1
  i += 1
end
print(p1, " ", p1wins, "; ", p2, " ", p2wins, "\n\n");
