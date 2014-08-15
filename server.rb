require './game'

require 'socket'

class Server
  def initialize(options = {})
    default = {
      port: 2500,
      ip: '127.0.0.1'
    }
    options = default.merge(options)
    @port = options[:port]
    @ip = options[:ip]
    
    @clients = []
  end
  
  def loop_forever
    @server = TCPServer.new @ip, @port
    
    loop do
      @clients << @server.accept
      
      if @clients.size >= 2
        start_game
      end
    end
  end
  
  def start_game
    players = [:red, :white].map do |color|
      NetworkPlayer.new(@clients.shift, color, nil)
    end
  
    Thread.start(Game.new(players)) do |game|
      puts "Game started!"
      game.play
      puts "Game over!"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  server = Server.new
  server.loop_forever
end
