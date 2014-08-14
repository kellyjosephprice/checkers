# encoding: utf-8

require './position'
require './board'
require './errors'

require 'colorize'

class Piece
  attr_reader :color, :position
  attr_writer :board

  def initialize(color, position, board = nil)
    @color = color
    @position = position
    @board = board

    @promoted = false
  end

  def dup
    Piece.new(@color, @position.dup)
  end

  def valid_move_seq? sequence
    begin
      test_board = @board.dup
      test_board[@position].perform_move! sequence
    rescue
      false
    else
      true
    end
  end

  def perform_moves moves
    unless valid_move_seq? moves
      raise InvalidMoveError.new()
    end

    perform_moves! moves
  end

  def perform_moves! moves
    moves.each do |pos|
      if valid_slides.include? pos
        perform_slide(pos)
      elsif valid_jumps.include? pos
        perform_jump(pos)
      else
        raise InvalidMoveError.new
      end
    end
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
    sigil = (@promoted) ? "⛃" : "⛂"
    (@color == :red) ? sigil.red : sigil.white
  end

  private

  def perform_slide position
    move(position)
  end

  def perform_jump position
    jumped = middle_position(@position, position)

    @board[jumped] = nil

    move(position)
  end

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

class NilClass
  def to_s
    "⛀"
  end
end
