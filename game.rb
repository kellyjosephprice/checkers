require './errors'
require './players'
require './board'
require './position'

require 'yaml'
require 'readline'

class Game
  attr_reader :board
  
  def initialize(players)
    @board = Board.new
    @red_player, @white_player = players

    @current_player = @red_player
  end

  def play 
    until over?
      render_board
      make_move
      cycle_player
    end

    display_results
  end
  
  def over?
    !winner.nil? || draw?
  end

  def draw?
    @board.pieces_by_color(@current_player.color).none? do |piece|
      piece.valid_moves.any?
    end
  end

  def winner
    return @red_player   if @board.pieces_by_color(:red).empty?
    return @white_player if @board.pieces_by_color(:white).empty?
  end
  
  def next_player
    @current_player == @red_player ? @white_player : @red_player
  end
  
  def self.load(path)
    YAML::load_file(path)
  end
  
  def save(path)
    print "Saving..."
    
    File.open(path, 'w') do |file|
      file << self.to_yaml
    end
    
    puts "done!"
  end
  
  def prompt_save    
    begin
      print "Save the game (y/n)? "
      answer = Readline.readline.strip.downcase
    end until ['y', 'n'].include? answer
    
    game.save("games/" + Time.now.strftime('%F-%T.game')) if answer == 'y'
  end
  
  def players
    [@red_player, @white_player]
  end
  
  private
  
  def make_move
    color = @current_player.color
    
    once_for_local { |p| p.say("#{ @current_player.color.capitalize } to play.")}
    
    begin
      move = @current_player.get_move
      raise WrongColorError.new(move[:piece], color) if @board[move[:piece]].color != color

      @board.move(move[:piece], move[:sequence])
    rescue InvalidMoveError => error
      puts "Caught exception!"
      @current_player.error(error.message)
      retry
    end
  end
    
  def display_results
    render_board
    
    winner = next_player
    loser = @current_player
    
    winner.say("Congratulations, #{ winner.color }!")
    loser.say("Too bad, #{ loser.color }!")
  
    once_for_local { |p| p.end_game }
  end
  
  def cycle_player
    @current_player = next_player
  end
  
  def render_board
    once_for_local { |p| p.update_board(@board) }
  end
  
  def once_for_local
    if players.all? { |p| p.is_a? NetworkPlayer }
      players.each { |p| yield(p) }
    else
      yield(@current_player)
    end
  end
end

if __FILE__ == $PROGRAM_NAME  
  path = ARGV.shift
  players = [LocalPlayer.new(:red, 600), LocalPlayer.new(:white, 600)]
  
  game = path.nil? ? Game.new(players) : Game.load(path)
  
  trap('SIGINT') do
    puts
    puts
    
    game.prompt_save
    
    puts "Goodbye!"
    exit
  end
 
  begin 
    game.play
  rescue StandardError => error
    puts error
   
    Dir.mkdir("games") unless Dir.exists?("games")
    game.save("games/" + Time.now.strftime('%F-%T.yaml'))
  end
end
