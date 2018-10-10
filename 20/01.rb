class Particle
  attr_reader :position, :velocity, :acceleration, :id

  def initialize(id, position, velocity, acceleration)
    @id = id
    @position = position
    @velocity = velocity
    @acceleration = acceleration
  end

  def dist
    [@position.x.abs, @position.y.abs, @position.z.abs].sum
  end

  def move!
    @velocity.x += @acceleration.x
    @velocity.y += @acceleration.y
    @velocity.z += @acceleration.z
    @position.x += @velocity.x
    @position.y += @velocity.y
    @position.z += @velocity.z
  end
end

class Coord
  attr_accessor :x, :y, :z
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end
end

particles = File.foreach('input.txt', "\n").map.with_index do |line, i|
  coords = line.scan(/[a-z]=<(.*?)>/).map do |xyz|
    Coord.new(*xyz[0].split(',').map(&:to_i))
  end
  Particle.new(i, *coords)
end

1000.times do
  particles.each(&:move!)
end

closest = particles.reduce(nil) do |accum, obj|
  accum = obj if accum.nil?
  obj.dist < accum.dist ? obj : accum
end

puts(closest.id)
raise 'wrong answer' if closest.id != 161
