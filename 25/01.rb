require 'set'

class Tape
  def initialize
    @on_positions = Set.new([])
    @cursor = 0
  end

  def off
    !(@on_positions === @cursor)
  end

  def on
    @on_positions === @cursor
  end

  def turn_on
    @on_positions << @cursor
  end

  def turn_off
    @on_positions.delete?(@cursor)
  end

  def move_right
    @cursor += 1
  end

  def move_left
    @cursor -= 1
  end

  def check_sum
    @on_positions.length
  end
end

class StateMachine
  def initialize(tape)
    @tape = tape
    @state = :A
  end

  def process
    case @state
    when :A
      if @tape.off
        @tape.turn_on
        @tape.move_right
        @state = :B
      else
        @tape.turn_off
        @tape.move_left
        @state = :C
      end
    when :B
      if @tape.off
        @tape.turn_on
        @tape.move_left
        @state = :A
      else
        @tape.turn_on
        @tape.move_right
        @state = :C
      end
    when :C
      if @tape.off
        @tape.turn_on
        @tape.move_right
        @state = :A
      else
        @tape.turn_off
        @tape.move_left
        @state = :D
      end
    when :D
      if @tape.off
        @tape.turn_on
        @tape.move_left
        @state = :E
      else
        @tape.turn_on
        @tape.move_left
        @state = :C
      end
    when :E
      if @tape.off
        @tape.turn_on
        @tape.move_right
        @state = :F
      else
        @tape.turn_on
        @tape.move_right
        @state = :A
      end
    when :F
      if @tape.off
        @tape.turn_on
        @tape.move_right
        @state = :A
      else
        @tape.turn_on
        @tape.move_right
        @state = :E
      end
    end
  end
end

# part 1

tape = Tape.new
sm = StateMachine.new(tape)

12_261_543.times do
  sm.process
end

unless tape.check_sum == 5744
  puts 'wrong answer!'
end
