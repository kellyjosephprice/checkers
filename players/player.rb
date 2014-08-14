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
  
  def get_promotion
    parse = {
      "Q" => Queen,
      "k" => Knight,
      "R" => Rook,
      "B" => Bishop
    }
    
    begin
      print "Promote pawn (#{ parse.keys.sort.join(', ') }): "
      choice = gets.chomp
      
      unless (parse.keys.include? choice)
        raise ArgumentError.new("Invalid promotion.")
      end
      
      parse[choice]
    rescue ArgumentError
      retry
    end
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
    
    # TODO
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

class OutOfTimeError < StandardError
end