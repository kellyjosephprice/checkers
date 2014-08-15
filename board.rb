# encoding: utf-8

require './piece'
require './position'
require 'colorize'

class Board
  attr_reader :board
  
  def initialize(new_game = true)
    @board = Array.new(8) { Array.new(8) }
    
    set_pieces if new_game
  end
  
  def self.in_bounds?(pos)
    pos.all? { |vector| vector.between?(0, 7) }
  end
  
  def [] pos
    @board[pos.rank][pos.file]
  end
  
  def []= pos, piece
    @board[pos.rank][pos.file] = piece
  end 
  
  def to_s(player = :red)
    reversed = player == :red

    oriented_board = reversed ? @board.reverse : @board
    
    rows = oriented_board.each_with_index.map do |row, rank|
      oriented_row = reversed ? row : row.reverse 

      rank_label = reversed ? "#{8 - rank} " : "#{rank + 1} "
      rank_label = rank_label.on_light_black
        
      tiles = oriented_row.each_with_index.map do |tile, file|
        string = ' ' + tile.to_s + ' '

        if white_tile? [rank, file]
          string = string.white if tile.nil?
          string = string.on_white
        else
          string = string.green if tile.nil?
          string = string.on_green
        end
      end.join("")

      rank_label + tiles
    end

    # NOTE: throwing in weirdly sized draught character for alignment
    labels = ("a".."h").map do |c| 
      '⛃'.light_black + "#{c} " 
    end
    labels.reverse! unless reversed
    file_label = labels.join.on_light_black
      
    (rows << "  #{file_label}").join("\n")
  end # I'm sorry
  
  def move(pos, sequence)
    piece = self[pos]

    raise NoMoveError if sequence.nil? || sequence.empty?
    raise NoPieceError.new(pos) if piece.nil?
    
    piece.perform_moves(sequence)
  end
  
  def dup
    duped = Board.new(false)
    
    @board.each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        old_piece = self[[rank, file]]
        
        next if old_piece.nil?
        
        new_piece = old_piece.dup
        
        duped[[rank, file]] = new_piece     
        new_piece.board = duped
      end
    end
    
    duped
  end
  
  def pieces_by_color(color)
    pieces.select { |p| p.color == color }
  end
  
  def pieces
    @board.flatten.compact
  end
  
  def opponents_for_color(color)
    pieces_by_color(opposing_color(color))
  end
  
  def opposing_color(color)
    color == :red ? :white : :red
  end
  
  private
  
  def set_pieces
    files = [0, 2, 4, 6]

    positions = files.map { |file| [0, file] }
    positions.concat(files.map { |file| [1, file + 1] })
    positions.concat(files.map { |file| [2, file] })

    positions.each do |pos|
      self[pos] = Piece.new(:red, pos, false, self)
    end

    positions.map! do |rank, file|
      file = (file % 2 == 0) ? file + 1 : file - 1
      [7 - rank, file]
    end

    positions.each do |pos|
      self[pos] = Piece.new(:white, pos, false, self)
    end
  end  
  
  def white_tile? pos
    pos.rank % 2 == pos.file % 2 
  end  

end
