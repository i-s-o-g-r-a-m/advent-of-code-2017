class MatrixBoundsError < StandardError
  def initialize(msg = "Exceeded the matrix's bounds")
    super
  end
end

class MatrixInputError < StandardError
  def initialize(msg = 'The matrix input is malformed')
    super
  end
end

class RouteBadDirection < StandardError
  def initialize(msg = 'Unrecognized direction')
    super
  end
end

class RouteUnexpectedJunction < StandardError
  def initialize(msg = 'We do not know how to proceed')
    super
  end
end

class Cell
  CORNER_CHAR = '+'.freeze
  LETTER = /[A-Z]/

  attr_reader :value

  def initialize(cell_value, cell_coords)
    @value = cell_value
    @coords = cell_coords
    @value.freeze
    @coords.freeze
  end

  def empty?
    @value.nil? || @value.strip.empty?
  end

  def corner?
    @value == CORNER_CHAR
  end

  def letter?
    @value.match(LETTER)
  end
end

class Matrix
  def initialize(lines)
    raise MatrixInputError.new if lines.empty?

    lines.reduce(nil) do |accum, line|
      if !accum.nil? && accum != line.length
        raise MatrixInputError.new, 'All rows must be the same width'
      end

      line.length
    end

    @cells = lines.map { |line| line.split('') }
    @cur_x = 0
    @cur_y = 0
  end

  def current
    Cell.new(@cells[@cur_y][@cur_x], [@cur_x, @cur_y])
  end

  def right!
    raise MatrixBoundsError.new if @cur_x + 1 >= @cells[0].length

    @cur_x += 1
  end

  def left!
    raise MatrixBoundsError.new if @cur_x - 1 < 0

    @cur_x -= 1
  end

  def up!
    if @cur_y - 1 < 0 then raise MatrixBoundsError.new end

    @cur_y -= 1
  end

  def down!
    if @cur_y + 1 >= @cells.length then raise MatrixBoundsError.new end

    @cur_y += 1
  end

  def neighbors
    {
      up: Cell.new(@cells.dig(@cur_y - 1, @cur_x), [@cur_y - 1, @cur_x]),
      down: Cell.new(@cells.dig(@cur_y + 1, @cur_x), [@cur_y + 1, @cur_x]),
      left: Cell.new(@cells.dig(@cur_y, @cur_x - 1), [@cur_y, @cur_x - 1]),
      right: Cell.new(@cells.dig(@cur_y, @cur_x + 1), [@cur_y, @cur_x + 1]),
    }
  end
end

class Direction
  DIRECTIONS = %i[up down left right].freeze

  attr_reader :value

  def initialize(dir)
    raise RouteBadDirection.new unless DIRECTIONS.include?(dir)

    @value = dir
  end

  def opposite_dir
    {
      down: :up,
      up: :down,
      right: :left,
      left: :right,
    }[@value]
  end

  def turn?(new_dir)
    new_dir != @value && new_dir != opposite_dir
  end

end

class Route
  START_CHAR = '|'.freeze

  attr_reader :steps

  def initialize(matrix, initial_direction)
    @matrix = matrix
    @direction = Direction.new(initial_direction)
    @letters = []
    @steps = 0

    find_start
  end

  def travel!
    loop do
      @steps += 1

      case @direction.value
      when :down
        @matrix.down!
      when :up
        @matrix.up!
      when :left
        @matrix.left!
      when :right
        @matrix.right!
      else
        raise RouteBadDirection.new
      end

      break if @matrix.current.empty? # we've reached the end, or so we hope

      @letters.push(@matrix.current.value) if @matrix.current.letter?
      update_direction!
    end
  end

  def letters
    # there must be a nicer way to prevent accidental mutation
    @letters.map { |x| x }
  end

  private

  def update_direction!
    return if !@matrix.current.corner?

    new_dir = []
    @matrix.neighbors.each_pair do |key, value|
      new_dir.push(key) if @direction.turn?(key) && !value.empty?
    end

    if new_dir.length != 1
      raise RouteUnexpectedJunction.new, 'An unexpected fork in the road'
    end

    @direction = Direction.new(new_dir[0])
  end

  def find_start
    loop do
      break if @matrix.current.value == START_CHAR

      @matrix.right!
    end
  end
end

lines = File.foreach('input.txt', "\n").map { |line| line }
matrix = Matrix.new(lines)
route = Route.new(matrix, :down)
route.travel!

raise 'wrong set of letters' if route.letters.join('') != 'GEPYAWTMLK'
raise 'wrong number of steps' if route.steps != 17_628
