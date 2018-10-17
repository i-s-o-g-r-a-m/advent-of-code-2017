class SquareMatrix
  attr_reader :m, :size

  def initialize(data)
    @m = {}
    @data = data
    @size = @data.length
    raise 'oh no' if @size != @data[0].length
    @data.each.with_index do |line, row_idx|
      line.split('').each.with_index { |char, idx| @m[[row_idx, idx]] = char }
    end
  end

  def flip_horiz!
    half = @size / 2
    (0..half - 1).each do |row_idx|
      mirror_idx = @size - row_idx - 1
      (0..@size - 1).each do |col_idx|
        cur_val = @m[[row_idx, col_idx]]
        mirror_val = @m[[mirror_idx, col_idx]]
        @m[[mirror_idx, col_idx]] = cur_val
        @m[[row_idx, col_idx]] = mirror_val
      end
    end
    self
  end

  def flip_vert!
    half = @size / 2
    (0..half - 1).each do |col_idx|
      mirror_idx = @size - col_idx - 1
      (0..@size - 1).each do |row_idx|
        cur_val = @m[[row_idx, col_idx]]
        mirror_val = @m[[row_idx, mirror_idx]]
        @m[[row_idx, col_idx]] = mirror_val
        @m[[row_idx, mirror_idx]] = cur_val
      end
    end
    self
  end

  def rotate_90!
    layers = (@size - 1) / 2
    (0..layers).each do |layer|
      (layer..@size - layer - 2).each do |col|
        a = [layer, col]
        b = [col, @size - layer - 1]
        c = [@size - layer - 1, @size - col - 1]
        d = [@size - col - 1, layer]
        a_val = @m[a]
        b_val = @m[b]
        c_val = @m[c]
        d_val = @m[d]
        @m[a] = d_val
        @m[b] = a_val
        @m[c] = b_val
        @m[d] = c_val
      end
    end
    self
  end

  def permutations
    Enumerator.new do |y|
      m = SquareMatrix.new(@data)
      3.times do
        m.rotate_90!
        y.yield m.to_s
      end

      horiz = SquareMatrix.new(@data)
      horiz.flip_horiz!
      y.yield horiz.to_s

      3.times do
        horiz.rotate_90!
        y.yield horiz.to_s
      end

      vert = SquareMatrix.new(@data)
      vert.flip_vert!
      y.yield vert.to_s

      3.times do
        vert.rotate_90!
        y.yield vert.to_s
      end
    end
  end

  def to_s
    rows = []
    (0..@size - 1).each do |r|
      row = []
      (0..@size - 1).map { |c| row.push(@m[[r, c]]) }
      rows.push(row.join(''))
    end
    rows.join('/')
  end
end

class Image
  def initialize(data, rules)
    @data = data
    @rules = rules
  end

  def enhance!
    new_squares = []
    squares.each do |sq_r|
      row = []
      sq_r.each do |sq|
        sq_str = sq.join('/')
        sq_new = transform(sq_str)
        row.push(sq_new.split('/'))
      end
      new_squares.push(row)
    end
    @data = collapse_squares(new_squares)
  end

  def collapse_squares(square_rows)
    accum = []

    square_rows.each do |sq_row|
      merged = Array.new(sq_row[0].length) { '' }
      sq_row.each do |sq|
        sq.each.with_index do |item, index|
          merged[index] += item
        end
      end
      accum.push(merged.join('/'))
    end

    accum.join('/')
  end

  def transform(sq_str)
    found = @rules[sq_str]
    if !found.nil?
      found
    else
      matrix = SquareMatrix.new(sq_str.split('/'))
      matrix.permutations.each do |p|
        return @rules[p] unless @rules[p].nil?
      end
      raise "could not find match for #{sq_str}"
    end
  end

  def rows
    @data.split('/')
  end

  def squares
    accum = []
    rowz = rows
    square_size = (rowz[0].length % 2).zero? ? 2 : 3

    (0..rowz.length - 1).step(square_size).each do |row_offset|
      row = []
      (0..rowz[row_offset].length - 1).step(square_size).each do |col|
        square = []
        (0..square_size - 1).each do |i|
          square.push(rowz[row_offset + i][col, square_size])
        end
        row.push(square)
      end
      accum.push(row)
    end

    accum
  end

  def size
    rows[0].length
  end

  def matrix
    SquareMatrix.new(rows)
  end
end

rules = {}
File.foreach('input.txt', "\n").map do |line|
  in_pattern, out_pattern = line.split(' => ')
  rules[in_pattern.strip] = out_pattern.strip
end

# part 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

image = Image.new('.#./..#/###', rules)

5.times do
  image.enhance!
end

on_count = image.matrix.to_s.count('#')
puts on_count
raise 'wrong answer' unless on_count == 110

# part 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

image = Image.new('.#./..#/###', rules)

18.times do
  image.enhance!
end

on_count = image.matrix.to_s.count('#')
puts on_count
raise 'wrong answer' unless on_count == 1_277_716
