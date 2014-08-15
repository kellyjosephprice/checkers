require 'readline'

class Player
  attr_reader :color
    
  def initialize(color, time_limit = nil)
    @color = color
    @remaining_time = time_limit
  end
  
  def say message
    puts message
  end
  
  def error(message)
    say "\n"
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

  private 
  
  def format_time(time)
    Time.at( time ).utc.strftime("%M:%S:%2N")
  end
  
  def prompt_timed_move
    timer = Time.now
    
    # seconds since the epoch
    say "Remaining time: #{ format_time(@remaining_time) }."
    
    move = prompt_move
    
    time_taken = Time.now - timer    
    @remaining_time -= time_taken
    
    raise OutOfTimeError if @remaining_time <= 0
    
    move
  end
  
  def prompt message
    print message
  end
  
  def input 
    Readline.readline(": ", true)
  end
  
  def prompt_move
    result = {}
    
    begin
      prompt "Enter your move"
      moves = input.split(' ').map do |coord|
        parse_coordinate(coord)
      end
    rescue ArgumentError
      retry
    end

    result[:piece] = moves.shift
    result[:sequence] = moves
    
    result
  end
  
  
  def parse_coordinate(coord)
    Position.from_pgn(coord)
  end 
end 
