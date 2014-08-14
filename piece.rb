require './position'
require './board'

require 'colorize'

class Piece
  attr_reader :color, :position

  def initialize(color, position, board)
    @color = color
    @position = position
    @board = board

    @promoted = false
  end

  def perform_slide position
    unless valid_slides.include? position
      raise InvalidMoveError.new(@position, position)
    end

    move(position)
  end

  def perform_jump position
    unless valid_jumps.include? position
      raise InvalidMoveError.new(@position, position)
    end

    jumped = middle_position(@position, position)

    @board[jumped] = nil

    move(position)
  end

  def valid_slides
    offsets.map do |offset|
      apply_offset(offset)
    end.select do |pos|
      Board.in_bounds?(pos) && @board[pos].nil?
    end
  end

  def valid_jumps
    slides = valid_slides
    
    offsets.reject do |offset|
      slides.include? apply_offset(offset)
    end.map do |offset|
      apply_offset([offset.rank * 2, offset.file * 2])
    end.select do |pos|
      Board.in_bounds?(pos) && @board[pos].nil?
    end
  end

  def to_s
    sigil = (@promoted) ? "K" : "P"
    (@color == :red) ? sigil.red : sigil.black
  end

  private

  def move position
    @board[position] = self
    @board[@position] = nil
    @position = position

    @promoted = true if promote?
  end

  def promote?
    return false if @promoted

    if @color == :red
      @position.rank == 7
    else
      @position.rank == 0
    end
  end

  def offsets
    forward = [[1, 1], [1, -1]]
    backward = [[-1, 1], [-1, -1]]
    
    if @promoted
      forward + backward
    elsif @color == :red
      forward
    else
      backward
    end
  end

  def apply_offset offset
    direction = (@color == :red) ? 1 : -1
    [@position.rank + (offset.rank * direction), @position.file + offset.file]
  end

  def middle_position(pos0, pos1)
    [
      average(pos0.rank, pos1.rank),
      average(pos0.file, pos1.file)
    ]
  end
  
  def average *nums
    (nums.inject(:+) / nums.size).to_i
  end
end
○
