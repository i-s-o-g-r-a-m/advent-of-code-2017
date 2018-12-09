#!/usr/bin/env ruby

class Map
  def initialize(input, default_value)
    @default_value = default_value
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
      update!(x, y, @default_value)
      @default_value
    else
      val
    end
  end

  def update!(x, y, val)
    @grid[[x, y]] = val
  end
end

class Node
  attr_reader :status

  STATUSES = {
    clean: '.',
    infected: '#',
    flagged: 'F',
    weakened: 'W'
  }.freeze

  VAL_TO_STATUS = STATUSES.invert.freeze

  def initialize(node_val)
    raise 'unknown node value' unless VAL_TO_STATUS.key?(node_val)
    @status = VAL_TO_STATUS[node_val]
  end

  def val
    STATUSES[@status]
  end
end

class Cleaner
  attr_reader :infections_caused, :pos

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
    case current_node.status
    when :clean
      update_current!(:weakened)
      turn!(:left)
    when :weakened
      update_current!(:infected)
      @infections_caused += 1
    when :infected
      update_current!(:flagged)
      turn!(:right)
    when :flagged
      update_current!(:clean)
      turn!(:left)
      turn!(:left)
    end
    move!
    self
  end

  private

  def current_node
    Node.new(@map.get(@position[0], @position[1]))
  end

  def update_current!(new_status)
    @map.update!(@position[0], @position[1], Node::STATUSES[new_status])
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
        @facing = :west
      when :south
        @facing = :east
      when :east
        @facing = :north
      when :west
        @facing = :south
      end
    when :right
      case @facing
      when :north
        @facing = :east
      when :south
        @facing = :west
      when :east
        @facing = :south
      when :west
        @facing = :north
      end
    end
  end
end

# -----------------------------------------------------------------------------

map = Map.new(File.foreach('input.txt', "\n"), Node::STATUSES[:clean])
cleaner = Cleaner.new(map)

10_000_000.times do
  cleaner.work!
end

puts cleaner.infections_caused unless cleaner.infections_caused != 2_511_927
