class InvalidMoveError < StandardError
end

class NoMoveError < InvalidMoveError
  def message
    "You must make a move when you are able to!"
  end
end

class ForcedMoveError < InvalidMoveError
  def message
    "You must take a piece when you are able to!"
  end
end

class NoPieceError < InvalidMoveError
  def initialize pos, *args
    @pos = pos
    super args
  end

  def message 
    "There is no piece at #{ @pos.pgn } to move!"
  end
end

class WrongColorError < InvalidMoveError
  def initialize pos, color, *args
    @pos = pos
    @color = color
  end

  def message
    "The piece at #{ @pos.pgn } does not belong to #{ @color }!"
  end
end

class OutOfTimeError < StandardError
end
