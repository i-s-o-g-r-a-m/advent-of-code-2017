h = 0

b = 79 * 100 + 100000
c = 79 * 100 + 100000 + 17000

while true
  prime = true

  (2..(b-1)).each do |i|
    if b % i == 0
      prime = false
      break
    end
  end

  h = h + 1 unless prime
  break if b == c
  b = b + 17
end

puts h if h == 907
