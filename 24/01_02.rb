ports = [
  [ 25, 13 ],
  [ 4, 43 ],
  [ 42, 42 ],
  [ 39, 40 ],
  [ 17, 18 ],
  [ 30, 7 ],
  [ 12, 12 ],
  [ 32, 28 ],
  [ 9, 28 ],
  [ 1, 1 ],
  [ 16, 7 ],
  [ 47, 43 ],
  [ 34, 16 ],
  [ 39, 36 ],
  [ 6, 4 ],
  [ 3, 2 ],
  [ 10, 49 ],
  [ 46, 50 ],
  [ 18, 25 ],
  [ 2, 23 ],
  [ 3, 21 ],
  [ 5, 24 ],
  [ 46, 26 ],
  [ 50, 19 ],
  [ 26, 41 ],
  [ 1, 50 ],
  [ 47, 41 ],
  [ 39, 50 ],
  [ 12, 14 ],
  [ 11, 19 ],
  [ 28, 2 ],
  [ 38, 47 ],
  [ 5, 5 ],
  [ 38, 34 ],
  [ 39, 39 ],
  [ 17, 34 ],
  [ 42, 16 ],
  [ 32, 23 ],
  [ 13, 21 ],
  [ 28, 6 ],
  [ 6, 20 ],
  [ 1, 30 ],
  [ 44, 21 ],
  [ 11, 28 ],
  [ 14, 17 ],
  [ 33, 33 ],
  [ 17, 43 ],
  [ 31, 13 ],
  [ 11, 21 ],
  [ 31, 39 ],
  [ 0, 9 ],
  [ 13, 50 ],
  [ 10, 14 ],
  [ 16, 10 ],
  [ 3, 24 ],
  [ 7, 0 ],
  [ 50, 50 ],
].map { |p| [p, p.object_id] }

bridges = [
  [[[0, 0], 0]],
]

max_bridge_strength = bridges[0].map { |p| p[0].sum }.reduce(0) { |accum, p| accum + p }

def extend_bridge(bridge, ports)
  fits_with = bridge.last[0][1]
  obj_ids = bridge.map { |p| p[1] }
  matches = ports
    .select { |p| !obj_ids.include?(p[1]) && p[0].include?(fits_with) }
    .map { |p| p[0][0] == fits_with ? p : [p[0].reverse, p[1]] }
  matches.map { |m| bridge + [m] }
end

while true
  max_bridge_len = bridges.last.length
  bridges.select { |b| b.length == max_bridge_len }.each do |b|
    extend_bridge(b, ports).each do |new_bridge|
      bridges << new_bridge
      new_strength = new_bridge.map { |p| p[0].sum }.reduce(0) { |accum, p| accum + p }
      max_bridge_strength = new_strength if new_strength > max_bridge_strength
    end
  end
  break if bridges.last.length == max_bridge_len
end

# part 1
if max_bridge_strength == 1868
  puts max_bridge_strength
else
  puts "wrong: #{max_bridge_strength}"
end

# part 2
longest_bridge_strength = bridges
  .select { |b| b.length == max_bridge_len }
  .map { |b| b.map { |p| p[0].sum }.reduce(0) { |accum, s| accum + s } }
  .max
if longest_bridge_strength == 1841
  puts longest_bridge_strength
else
  puts "wrong: #{longest_bridge_strength}"
end
