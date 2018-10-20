class Map
  def initialize(input)
    @grid = {}
    input.each.with_index do |line, row|
      line.strip.split('').each.with_index do |val, col|
        @grid[[row, col]] = val
      end
    end
  end

  def to_rows
    rows = []
    @grid.sort_by { |k, _| k }.each do |pair|
      if pair[0][1] > 0
        rows[pair[0][0]].push(pair[1])
      else
        rows[pair[0][0]] = [pair[1]]
      end
    end
    rows
  end

  def square?
    rows = to_rows
    height = rows.length
    rows.each { |row| return false if height != row.length }
    true
  end

  def empty?
    @grid.length.zero?
  end

  def get(x, y)
    val = @grid[[x, y]]
    if val.nil?
      update!(x, y, Node::CLEAN)
      Node::CLEAN
    else
      val
    end
  end

  def update!(x, y, val)
    @grid[[x, y]] = val
  end
end

class Node
  CLEAN = '.'.freeze
  INFECTED = '#'.freeze

  def initialize(node_val)
    @n = node_val
  end

  def infected?
    @n == INFECTED
  end
end

class Cleaner
  attr_reader :infections_caused, :pos

  CAN_FACE = %i[east west north south].freeze
  CAN_MOVE = %i[left right].freeze

  def initialize(map)
    raise 'we expect a square grid' unless map.square?
    raise 'we expect a non-empty grid' if map.empty?

    @map = map
    @position = [0, 0]
    @facing = :north
    @infections_caused = 0

    center!
  end

  def work!
    if current_node.infected?
      turn!(:right)
      clean_current!
    else
      turn!(:left)
      infect_current!
      @infections_caused += 1
    end
    move!
    self
  end

  private

  def current_node
    Node.new(@map.get(@position[0], @position[1]))
  end

  def infect_current!
    @map.update!(@position[0], @position[1], Node::INFECTED)
  end

  def clean_current!
    @map.update!(@position[0], @position[1], Node::CLEAN)
  end

  def center!
    rows = @map.to_rows
    raise 'we expect an odd grid size' if (rows.length % 2).zero?

    center = (rows.length / 2)
    @position = [center, center]
  end

  def move!
    case @facing
    when :north
      @position = [@position[0] - 1, @position[1]]
    when :south
      @position = [@position[0] + 1, @position[1]]
    when :east
      @position = [@position[0], @position[1] + 1]
    when :west
      @position = [@position[0], @position[1] - 1]
    end
  end

  def turn!(direction)
    raise 'cannot move in that direction' unless CAN_MOVE.include?(direction)
    case direction
    when :left
      case @facing
      when :north
        face! :west
      when :south
        face! :east
      when :east
        face! :north
      when :west
        face! :south
      end
    when :right
      case @facing
      when :north
        face! :east
      when :south
        face! :west
      when :east
        face! :south
      when :west
        face! :north
      end
    end
  end

  def face!(direction)
    raise 'unknown direction' unless CAN_FACE.include?(direction)

    @facing = direction
  end
end

map = Map.new(File.foreach('input.txt', "\n"))
cleaner = Cleaner.new(map)

10_000.times do
  cleaner.work!
end

puts cleaner.infections_caused unless cleaner.infections_caused != 5_261
