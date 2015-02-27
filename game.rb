require_relative 'board.rb'

class Game
  def initialize(white = HumanPlayer.new(:white), black = HumanPlayer.new(:black))
    @board = Board.new
    @white = white
    @black = black
    @round = 0
  end

  def player_turn
    ( @round % 2 == 0 ) ? @white : @black
  end

  def play_turn
    current_player = player_turn
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

  def get_move(board)



  end

end
