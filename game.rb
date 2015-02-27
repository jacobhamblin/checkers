require_relative './board.rb'
require 'yaml'
# require 'byebug'

class Game
  attr_reader :board, :white, :black, :round

  def initialize(white = HumanPlayer.new(:white), black = HumanPlayer.new(:black))
    @board = Board.new
    @white = white
    @black = black
    @round = 0
  end

  def player_turn
    ( @round % 2 == 0 ) ? @white : @black
  end

  def play
    puts "\ec\nWhite plays first"
    sleep(2)
    puts "\ec"
    loop do
      if @board.gameover?
        puts "Congratulations #{@board.winner}, you've won!\n\n"

        @board.render
        break
      end
      player_turn.play_turn(@board, self)
      @round += 1
    end
  end

  def save(name = "default")
    puts "Saving game '#{name}'..", ' '
    File.write(save_path(name), @board.to_yaml)
  end

  def load(name = "default")
    path = save_path(name)
    if File.exist?(path)
      puts "Loading game '#{name}'..", ' '
      contents = File.read(path)
      @board = YAML::load(contents)
      @board.display
    else
      puts "Cannot find load file '#{name}'"
    end
  end

  private

    def save_path(name)
      "./#{name}.yml"
    end
end



class Player
  attr_reader :name

  def initialize(color)
    @color = color
  end

  def get_move(board)
    raise NotImplementedError.new
  end

  def pieces(board)
    board.rows.flatten.compact.select {|piece| piece.color == self.color}
  end

  def name
    @color.to_s
  end

end



class HumanPlayer < Player

  def initialize(color)
    @color = color
    @selection = [0,0]
  end

  def play_turn(board, game)
    from_coordinates, to_coordinates = [nil,nil]
    coords = [@selection, from_coordinates]

    loop do
      board.display(*coords)
      stroke = get_char
      case stroke
      when /[wasd]/
        move_selection(board, stroke)
        coords = [@selection, from_coordinates]
      when "\r", " "
        from_coordinates == nil ? (from_coordinates = @selection) : (to_coordinates = @selection)
        coords = [@selection, from_coordinates]
        unless to_coordinates.nil?
          if board[from_coordinates.reverse].valid_slide?(board, to_coordinates.reverse)
            my_piece?(board, from_coordinates.reverse)
            board[from_coordinates.reverse].perform_slide(board, to_coordinates.reverse)
            return
          elsif board[from_coordinates.reverse].valid_jump?(board, to_coordinates.reverse)
            my_piece?(board, from_coordinates.reverse)
            board[from_coordinates.reverse].perform_jump(board, to_coordinates.reverse)
            break if board[to_coordinates.reverse].jump_moves > 0
            return
          end
        end
      when "\u0013" # ctrl+s
        game.save
      when "\u000C" # ctrl+l
        game.load
      when "\u0003" #ctrl+c
        exit
      else
        #nothing
      end
    end
  rescue ArgumentError => e
    retry
  end

  def get_char
    state = `stty -g`
    `stty raw -echo -icanon isig`

    STDIN.getc.chr
  ensure
    `stty #{state}`
  end

  def move_selection(board, stroke)
    offsets = {
      w: [0,-1],
      a: [-1,0],
      s: [0, 1],
      d: [1,0]
    }
    stroke = stroke.to_sym
    x, y = @selection
    x_shift, y_shift = offsets[stroke]
    pos = [x + x_shift, y + y_shift]
    @selection = pos if board.valid_pos?(pos)
  end


  def my_piece?(board, coordinates)
    unless board.occupied?(coordinates) && board.whats_here?(coordinates).color == @color
      raise ArgumentError.new("This space does not have one of your pieces!")
    else
      true
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
