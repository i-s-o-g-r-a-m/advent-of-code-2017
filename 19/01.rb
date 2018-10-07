# TODO extract 'direction' value class
# TODO extract 'value' value class

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

class Matrix
  def initialize(lines)
    if lines.empty? then raise MatrixInputError.new end

    lines.reduce(nil) do |accum, line|
      if !accum.nil? && accum != line.length then raise MatrixInputError.new end
      line.length
    end

    @cells = lines.map { |line| line.split('') }
    @cur_x = 0
    @cur_y = 0
  end

  def cur_value
    @cells[@cur_y][@cur_x]
  end

  def cur_coords
    [@cur_x, @cur_y]
  end

  def right!
    if @cur_x + 1 >= @cells[0].length then raise MatrixBoundsError.new end

    @cur_x += 1
  end

  def left!
    if @cur_x - 1 < 0 then raise MatrixBoundsError.new end

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
      up: @cells.dig(@cur_y - 1, @cur_x),
      down: @cells.dig(@cur_y + 1, @cur_x),
      left: @cells.dig(@cur_y, @cur_x - 1),
      right: @cells.dig(@cur_y, @cur_x + 1),
    }
  end
end

class Route
  DIRECTIONS = %i[up down left right].freeze
  CORNER_CHAR = '+'

  def initialize(matrix, initial_direction)
    if !DIRECTIONS.include?(initial_direction) then
      raise RouteBadDirection.new
    end

    @matrix = matrix
    @direction = initial_direction
    @letters = []

    find_start
  end

  def travel!
    loop do
      case @direction
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

      if @matrix.cur_value.nil? || @matrix.cur_value == " " then
        break
      end

      if /[A-Z]/.match(@matrix.cur_value) then
        @letters.push(@matrix.cur_value)
      end

      update_direction!
    end
  end

  def letters
    return @letters
  end

  private

  def update_direction!
    if @matrix.cur_value != CORNER_CHAR then return end

    new_dir = []
    @matrix.neighbors.each_pair do |key, value|
      val_is_valid = ![nil, ' '].include?(value)
      if key != @direction && key != opposite_dir && val_is_valid then
        new_dir.push(key)
      end
    end
    if new_dir.length != 1 then
      raise RouteUnexpectedJunction.new
    end
    @direction = new_dir[0]
  end

  def opposite_dir
    case @direction
    when :down
      :up
    when :up
      :down
    when :left
      :right
    when :right
      :left
    end
  end

  def find_start
    loop do
      if @matrix.cur_value == '|' then break end

      @matrix.right!
    end
  end
end

lines = File.foreach('input.txt', "\n").map { |line| line }
matrix = Matrix.new(lines)
route = Route.new(matrix, :down)
route.travel!

if route.letters.join('') != 'GEPYAWTMLK'
  raise 'wrong answer!'
end
