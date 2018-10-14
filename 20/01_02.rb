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

  def ==(obj)
    @x == obj.x && @y == obj.y && @z == obj.z
  end

  def eql?(obj)
    @x == obj.x && @y == obj.y && @z == obj.z
  end

  def hash
    bytes = []
    [@x.to_s, @y.to_s, @z.to_s].join.each_byte { |b| bytes.push(b) }
    bytes.map { |b| b.to_s }.join.to_i
  end
end

particles = File.foreach('input.txt', "\n").map.with_index do |line, i|
  coords = line.scan(/[a-z]=<(.*?)>/).map do |xyz|
    Coord.new(*xyz[0].split(',').map(&:to_i))
  end
  Particle.new(i, *coords)
end

particles2 = Marshal.load(Marshal.dump(particles))

1000.times do
  particles.each(&:move!)
end

closest = particles.reduce(nil) do |accum, obj|
  accum = obj if accum.nil?
  obj.dist < accum.dist ? obj : accum
end

puts(closest.id)
raise 'wrong answer' if closest.id != 161

1000.times do
  particles2.each(&:move!)
  particles2.each do |p|
    count = particles2.count { |e| e.position == p.position }
    particles2.delete_if { |e| e.position == p.position } if count > 1
  end
end

puts(particles2.length)
raise 'wrong answer' if particles2.length != 438
