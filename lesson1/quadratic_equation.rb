puts "Решение квадратного уравнения вида ax^2 + bx + c = 0"
print "Задайте a = "
a = gets.chomp.to_f
print "Задайте b = "
b = gets.chomp.to_f
print "Задайте c = "
c = gets.chomp.to_f
d = b ** 2 - 4 * a * c
if d < 0
  puts "Данное квадратное уравнение не имеет корней, так как дискриминант < 0 (D = #{d})"
elsif d == 0
  puts "Данное квадратное уравнение имеет 1 корень, так как дискриминант = 0 (D = #{d}) X = #{-1*b/(2*a)}"
elsif d > 0
  puts "Данное квадратное уравнение имеет 2 корня, так как дискриминант > 0 (D = #{d}) X1 = #{(-1*b+Math.sqrt(d))/(2*a)} X2 = #{(-1*b-Math.sqrt(d))/(2*a)}"
end