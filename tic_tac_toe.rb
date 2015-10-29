# operates the Tic Tac Toe game
class Game
  def initialize(p1, p2, board)
    @p1 = p1
    @p2 = p2
    @board = board
    @last_move_row = nil
    @last_move_column = nil
    @line_width = 80
  end

  def start
    take_turn(p1)
    nil
  end

  private

  attr_reader :p1, :p2, :board, :line_width
  attr_accessor :last_move_row, :last_move_column

  def take_turn(player)
    puts
    puts "It is #{player.name}'s turn.".center(line_width)
    draw_board
    move(player)
    if win?
      win(player)
    elsif board.full?
      tie
    else
      take_turn(other_player(player))
    end
  end

  def draw_board
    puts
    puts board.draw(line_width)
  end

  def move(player)
    puts
    puts "Starting from the top, choose the row where you'd like to play."
    row = gets.chomp!.to_i
    puts "Starting from the left, choose the column where you'd like to play."
    column = gets.chomp!.to_i
    if !(row.between?(1, board.dimension)) || !(column.between?(1, board.dimension))
      puts "Invalid move! Please try again."
      move(player)
    elsif board.square(row, column) != " "
      puts "Space occupied! Please try again."
      move(player)
    else
      board.update(row, column, player_mark(player))
      self.last_move_row = row
      self.last_move_column = column
    end
  end

  def win?
    row_win? || column_win? || diagonal_win?
  end

  def row_win?
    squares_to_check = []
    board.dimension.times do |i|
      squares_to_check << (board.square(last_move_row, i))
    end
    squares_to_check.all? do |square|
      square == last_move_square
    end
  end

  def column_win?
    squares_to_check = []
    board.dimension.times do |i|
      squares_to_check << (board.square(i, last_move_column))
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

  def last_move_square
    board.square(last_move_row, last_move_column)
  end

  def win(player)
    puts
    puts "*** #{player.name} has won! ***".center(line_width)
    draw_board
    puts
  end

  def tie
    puts
    puts "*** It's a tie! ***".center(line_width)
    draw_board
    puts
  end

  def other_player(player)
    if player == p1
      return p2
    else
      return p1
    end
  end

  def player_mark(player)
    if player == p1
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
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

g = Game.new(Player.new("Player 1"), Player.new("Player 2"), Board.new(3))
g.start
