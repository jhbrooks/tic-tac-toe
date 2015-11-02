require "./computer_ai"

# operates the Tic Tac Toe game
class Game
  include ComputerAI

  def initialize(p1, p2, board)
    @p1 = p1
    @p2 = p2
    @current_player = p1
    @board = board
    @last_move_row = nil
    @last_move_column = nil
    @line_width = 80
  end

  def start
    take_turn
    nil
  end

  private

  attr_reader :p1, :p2, :line_width, :board
  attr_accessor :last_move_row, :last_move_column, :current_player

  def take_turn
    puts
    puts "It is #{current_player.name}'s turn.".center(line_width)
    draw_board
    select_and_make_move
    if win?
      win
    elsif tie?
      tie
    else
      self.current_player = next_player
      take_turn
    end
  end

  def draw_board
    puts
    puts board.draw(line_width)
  end

  def select_and_make_move
    puts
    if current_player.type == "human"
      row = human_row
      column = human_column
      if !(available_moves.include?([row, column]))
        puts "Space occupied! Please try again."
        select_and_make_move
      else
        make_move([row, column])
      end
    else
      puts "Processing..."
      play_with_foresight(4)
      puts "#{current_player.name} has chosen row #{last_move_row}, column #{last_move_column}."
    end
  end

  def human_row
    puts "Starting from the top, choose the row where you'd like to play."
    row = gets.chomp!.to_i
    if !(row.between?(1, board.dimension))
      puts "Invalid row! Please try again."
      human_row
    else
      return row
    end
  end

  def human_column
    puts "Starting from the left, choose the column where you'd like to play."
    column = gets.chomp!.to_i
    if !(column.between?(1, board.dimension))
      puts "Invalid column! Please try again."
      human_column
    else
      return column
    end
  end

  def available_moves
    empties = []
    board.dimension.times do |i|
      board.dimension.times do |j|
        row = i + 1
        column = j + 1
        (empties << ([row, column])) if board.square(row, column) == " "
      end
    end
    empties
  end

  def make_move(move)
    board.update(move[0], move[1], current_player_mark)
    self.last_move_row = move[0]
    self.last_move_column = move[1]
    move
  end

  def undo_move(move)
    board.update(move[0], move[1], " ")
  end

  def win?
    row_win? || column_win? || diagonal_win?
  end

  def row_win?
    squares_to_check = []
    board.dimension.times do |i|
      squares_to_check << (board.square(last_move_row, i + 1))
    end
    squares_to_check.all? do |square|
      square == last_move_square
    end
  end

  def column_win?
    squares_to_check = []
    board.dimension.times do |i|
      squares_to_check << (board.square(i + 1, last_move_column))
    end
    squares_to_check.all? do |square|
      square == last_move_square
    end
  end

  def diagonal_win?
    down_diagonal_win? || up_diagonal_win?
  end

  def down_diagonal_win?
    squares_to_check = []
    1.upto(board.dimension) do |i|
      squares_to_check << (board.square(i, i))
    end
    squares_to_check.all? do |square|
      square == last_move_square
    end
  end

  def up_diagonal_win?
    squares_to_check = []
    board.dimension.downto(1) do |i|
      squares_to_check << (board.square(i, (board.dimension - i + 1)))
    end
    squares_to_check.all? do |square|
      square == last_move_square
    end
  end

  def tie?
    board.full?
  end

  def last_move_square
    board.square(last_move_row, last_move_column)
  end

  def win
    puts
    puts "*** #{current_player.name} has won! ***".center(line_width)
    draw_board
    puts
  end

  def tie
    puts
    puts "*** It's a tie! ***".center(line_width)
    draw_board
    puts
  end

  def next_player
    if current_player == p1
      return p2
    else
      return p1
    end
  end

  def previous_player
    next_player
  end

  def current_player_mark
    if current_player == p1
      "X"
    else
      "O"
    end
  end
end

# stores board information; handles modification, retrieval, and display
class Board
  attr_reader :dimension

  def initialize(dimension)
    @dimension = dimension
    @rows = []
    dimension.times do
      @rows << []
      dimension.times do
        @rows[-1] << " "
      end
    end
  end

  def full?
    rows.all? do |row|
      row.none? { |square| square == " " }
    end
  end

  def update(row, column, mark)
    rows[row - 1][column - 1] = mark
  end

  def square(row, column)
    rows[row - 1][column - 1]
  end

  def draw(line_width)
    row_graphic_strings = rows.map do |row|
      row.join(" | ").center(line_width)
    end
    dash_string = ("--#{'-' * dimension}#{'---' * (dimension - 1)}").center(line_width)
    row_graphic_strings.join("\n#{dash_string}\n")
  end

  private

  attr_reader :rows
end

# stores player information; handles retrieval
class Player
  attr_reader :name, :type

  def initialize(name, type)
    @name = name
    @type = type
  end
end

g = Game.new(Player.new("Player 1", "human"), Player.new("Player 2", "computer"), Board.new(4))
g.start
