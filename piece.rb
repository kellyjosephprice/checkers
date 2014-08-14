# encoding: utf-8

require './position'
require './board'
require './errors'

require 'colorize'

class Piece
  attr_reader :color, :position
  attr_writer :board
  attr_accessor :promoted

  def initialize(color, position, promoted = false, board = nil)
    @color = color
    @position = position
    @promoted = promoted
    @board = board
  end

  def dup
    Piece.new(@color, @position.dup, @promoted)
  end

  def valid_move_seq? sequence
    begin
      test_board = @board.dup
      test_board[@position].perform_moves! sequence
    rescue InvalidMoveError => error
      @error = error.message
      false
    else
      true
    end
  end

  def perform_moves sequence
    unless valid_move_seq? sequence
      raise InvalidMoveError.new(@error)
    end

    perform_moves! sequence
  end

  def perform_moves! sequence
    sequence.each do |pos|
      if valid_slides.include?(pos) && any_jumps?
        raise ForcedMoveError
      elsif valid_slides.include? pos
        perform_slide(pos)
      elsif valid_jumps.include? pos
        perform_jump(pos)
      else
        raise InvalidMoveError.new("#{@position.pgn} cannot move to #{pos.pgn}")
      end
    end
  end

  def valid_moves
    valid_slides + valid_jumps
  end

  def valid_slides
    offsets.map do |offset|
      apply_offset(offset)
    end.select do |pos|
      Board.in_bounds?(pos) && @board[pos].nil?
    end
  end

  def valid_jumps
    offsets.reject do |offset|
      jumped = @board[apply_offset(offset)]
      jumped.nil? || jumped.color == @color
    end.map do |offset|
      apply_offset([offset.rank * 2, offset.file * 2])
    end.select do |pos|
      Board.in_bounds?(pos) && @board[pos].nil?
    end
  end

  def any_jumps?
    @board.pieces_by_color(@color).any? do |piece|
      piece.valid_jumps.any?
    end
  end

  def to_s
    sigil = (@promoted) ? "◉" : "◎"
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
    
    @promoted ? forward + backward : forward
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
    " "
  end
end
