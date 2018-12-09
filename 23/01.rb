instructions = File.foreach('input.txt', "\n").to_a

# part 1

pos = 0
state = Hash.new(0)
seen = Hash.new(0)

while true
  break if instructions[pos].nil?

  op, reg, val = instructions[pos].split(' ')
  val = /[a-z]/.match?(val) ? state[val] : val.to_i
  jump = pos + 1
  seen[op] += 1

  raise 'unknown instruction' unless ['set', 'sub', 'mul', 'jnz'].include?(op)

  case op
  when 'set'
    state[reg] = val
  when 'sub'
    state[reg] = state[reg] - val
  when 'mul'
    state[reg] = state[reg] * val
  when 'jnz'
    reg_val = /[a-z]/.match?(reg) ? state[reg] : reg.to_i
    jump = pos + val if !reg_val.zero?
  end

  pos = jump
end

puts seen['mul'] if seen['mul'] == 5929
