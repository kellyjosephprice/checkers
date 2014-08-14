class InvalidMoveError < StandardError
  def initialize(source, dest)
    @source = source
    @dest = dest

    super(move_message)
  end

  def move_message
    "The piece #{source} cannot move to #{dest}!"
  end
end

class InvalidMoveSequenceError < InvalidMoveSequenceError
  def initialize(source, sequence)
    @source = source
    @sequence = sequence

    super(move_message)
  end

  def move_message
    "The sequence of moves #{sequence} contains invalid moves!"
  end
end
