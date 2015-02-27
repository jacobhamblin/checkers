require 'colorize'
require_relative './piece.rb'

class Board
  attr_reader :rows

  def initialize
    @rows = Array.new(10) {Array.new(10)}
    populate_board
  end

  def display(highlight_from = nil, highlight_to = nil)
    puts "\ec"
    puts render(highlight_from, highlight_to)
  end

  def [](pos)
    # raise ArgumentError.new("Invalid Position") unless valid_pos?(pos)

    x, y = pos
    @rows[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y] = piece
  end

  def valid_pos?(pos)
    pos.all? {|coord| coord.between?(0,9) }
  end

  def occupied?(pos)
    !!whats_here?(pos)
  end

  def whats_here?(pos)
    self[pos]
  end

  def enemy_piece?(pos, color)
    !self[pos].nil? && self[pos].color != color
  end

  def gameover?
    @rows.flatten.compact.none? {|piece| piece.color != @rows.flatten.compact[0].color}
  end

  def winner
    @rows.flatten.compact[0].color
  end

  def populate_board
    @rows.each_with_index do |row, ri|
      row.each_with_index do |space, ci|
        if (ri + ci).odd?
          if ri < 4
            @rows[ri][ci] = Piece.new(:black, [ri, ci])
          elsif ri > 5
            @rows[ri][ci] = Piece.new(:white, [ri, ci])
          end
        end
      end
    end
  end

  def render(highlight_from = nil, highlight_to = nil)
    accumulator_string = ""
    @rows.each_with_index do |row, ri|
      row.each_with_index do |cell, ci|
        unless [ri, ci] == highlight_from || [ri, ci] == highlight_to
          if self[[ri,ci]].nil?
            accumulator_string += color_background("  ", ri, ci)
          else
            accumulator_string += color_background("#{self[[ri,ci]].symbol.to_s} ", ri, ci)
          end
        else
          if self[[ri,ci]].nil?
            accumulator_string += color_background("  ", ri, ci, true)
          else
            accumulator_string += color_background("#{self[[ri,ci]].symbol.to_s} ", ri, ci, true)
          end
        end
      end
      accumulator_string += "\n"
    end

    puts accumulator_string
  end

  def color_background(string, row, column, highlight = false)
    if highlight == true
      string.colorize(:color => :black, :background => :light_cyan)
    else
      case (row + column)%2
      when 0
        string.colorize(:color => :black, :background => :light_white)
      when 1
        string.colorize(:color => :black, :background => :white)
      end
    end
  end

end

def perform_test
  b = Board.new
  b.render
  sleep(2)
  b[[3,0]].perform_slide(b, [4,1])
  b.render
  sleep(2)
  b[[6,3]].perform_slide(b, [5,2])
  b.render
  sleep(2)
  b[[4,1]].perform_jump(b, [6,3])
  sleep(3)
  b.render
end
