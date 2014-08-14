class Position < Array
  def self.from_pgn(pgn)
    raise ArgumentError if pgn.nil? || pgn.length != 2
    
    rank = Integer(pgn[1]) - 1
    file = ('a'..'h').to_a.index(pgn[0])
    
    if file.nil?
      raise ArgumentError.new('File out of bounds.')
    end
    
    position = [rank, file]
    
    unless Board.in_bounds?(position)
     raise ArgumentError.new('Position out of bounds.')
    end
    
    position
  end
end

class Array
  def rank
    self.first
  end
  
  def file
    self.last
  end
  
  def rank= rank
    self[0] = rank
  end
  
  def file= file
    self[1] = file
  end
  
  def pgn 
    "#{ ('a'..'h').to_a[file] }#{ rank + 1 }"
  end
end
