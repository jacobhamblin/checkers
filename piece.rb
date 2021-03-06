class Piece
  DOWN = [[1,1],[1,-1]]
  UP = [[-1,-1],[-1,1]]
  UP_DOWN = UP + DOWN

  attr_reader :color
  attr_accessor :pos, :king, :symbol

  def initialize(color, pos)
    @color = color
    @pos = pos
    @symbol = (color == :white) ? :○ : :●
    @king = false
  end

  def perform_slide(board, pos)
    raise ArgumentError.new("Invalid move") unless valid_slide?(board, pos)
    old_pos = self.pos
    self.pos = pos
    board[pos] = self
    board[old_pos] = nil
    maybe_promote
  end


  def perform_jump(board, pos)
    raise ArgumentError.new("Invalid move") unless valid_jump?(board, pos)
    old_pos = self.pos
    self.pos = pos
    board[pos] = self
    board[[(old_pos[0] + ((self.pos[0] - old_pos[0]) / 2)), (old_pos[1] + ((self.pos[1] - old_pos[1]) / 2))]] = nil
    board[old_pos] = nil
    maybe_promote
  end

  def moves(board)
    slide_moves(board) + jump_moves(board)
  end

  def slide_moves(board)
    arr = []
    board.rows.each_with_index do |row, ri|
      row.each_with_index do |space, ci|
        arr << [ri, ci] if self.valid_slide?(board, [ri, ci])
      end
    end
    arr
  end

  def jump_moves(board)
    arr = []
    board.rows.each_with_index do |row, ri|
      row.each_with_index do |space, ci|
        arr << [ri, ci] if self.valid_jump?(board, [ri, ci])
      end
    end
    arr
  end

  def valid_jump?(board, pos)
    options = []
    move_diffs.each do |x_shift, y_shift|
      x, y = self.pos
      jump_coords = [x + (x_shift * 2), y + (y_shift * 2)]
      obstacle_coords = [x + x_shift, y + y_shift]
      if board.valid_pos?(jump_coords) && !board.occupied?(jump_coords) && board.enemy_piece?(obstacle_coords, self.color)
        options << jump_coords
      end
    end
    options.include?(pos)
  end

  def valid_slide?(board, pos)
    options = move_diffs.map { |dir| [dir[0] + self.pos[0], dir[1] + self.pos[1]]  }
    options = options.select {|pos| !board.occupied?(pos) && board.valid_pos?(pos)}
    options.include?(pos)
  end

  def move_diffs
    @king ? UP_DOWN : (@color == :white ? UP : DOWN)
  end

  def maybe_promote
    if pos[0] == 9 && color == :black || pos[0] == 0 && color == :white
      @king = true
      color == :white ? (@symbol = :♔ ) : (@symbol = :♚)
    end
  end

end
