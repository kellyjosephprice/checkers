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
    board = player == :red ? @board.reverse : @board
    
    board.each_with_index.map do |row, rank|
      tiles = row.each_with_index.map do |tile, file|
        string = tile.to_s + ' '

        
        if white_tile? [rank, file]
          string = string.white if tile.nil?
          string = string.on_white
        else
          string = string.green if tile.nil?
          string = string.on_green
        end
      end.join("")
    end.join("\n")
  end
  
  def move(color, start_pos, end_pos)
    
    if self[start_pos].color != color
      raise InvalidMoveError.new(
        "Piece at #{ start.pgn } does not belong to #{ @color }.")
    end
    
    piece = self[start_pos]
    
    if piece.nil?
      raise InvalidMoveError.new(
        "There is no piece at #{ start_pos.pgn } to move.")
    elsif !piece.legal_moves.include?(end_pos)
      raise InvalidMoveError.new(
        "Piece at #{ start_pos.pgn } can't move to #{ end_pos.pgn }.")
    end
    
    piece.move(end_pos)
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
      self[pos] = Piece.new(:red, pos, self)
    end

    positions.map! do |rank, file|
      file = (file % 2 == 0) ? file + 1 : file - 1
      [7 - rank, file]
    end

    positions.each do |pos|
      self[pos] = Piece.new(:white, pos, self)
    end
  end  
  
  def white_tile? pos
    pos.rank % 2 == pos.file % 2 
  end  

end
