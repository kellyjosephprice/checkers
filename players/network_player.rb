require 'json'

class NetworkPlayer < Player
  def initialize(socket, color, time_limit)
    super(color, time_limit)
    
    @socket = socket
  end
  
  def message type, body = ''
    puts "Sending type '#{type}'."
    serialized = { 'type' => type, 'body' => body }.to_json
    @socket.puts(serialized)
  end
  
  def say string
    message("line", string)
  end
  
  def update_board(board)
    message("board", board.to_s(@color))
  end
  
  def prompt(string)
    message("prompt", string)
  end
  
  def input
    @socket
  end
  
  def end_game
    message("game over")
  end
  
  def error string
    message("error", string)
  end
end
