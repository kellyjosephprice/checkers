require "../player"

class LocalPlayer < Player
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
    STDIN
  end
  
  def prompt_move
    result = {}
    
    begin
      prompt "Enter your move: "
      moves = input.gets.split(' ')
    
      start = parse_coordinate(moves[0])
      dest = parse_coordinate(moves[1])
    rescue ArgumentError
      retry
    end
    
    result[:start] = start
    result[:dest] = dest
    
    result
  end
  
  
  def parse_coordinate(coord)
    Position.from_pgn(coord)
  end 
end
