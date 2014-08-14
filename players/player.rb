class Player
  attr_reader :color
    
  def initialize(color, time_limit = nil)
    @color = color
    @remaining_time = time_limit
  end
  
  def say(message)
    puts message
  end
  
  def error(message)
    say message
  end
  
  def update_board(board)
    puts board.to_s(@color)
    puts
  end
  
  def get_move
    @remaining_time.nil? ? prompt_move : prompt_timed_move
  end
  
  def end_game
  end

end 
