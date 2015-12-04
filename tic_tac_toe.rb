# This module wraps a Tic Tac Toe game in its own namespace
module TicTacToe
  require "./computer_ai"

  # This class operates a Tic Tac Toe game
  class Game
    include ComputerAI

    def self.create(type_1, type_2)
      Game.new(Player.new("Player 1", "X", type_1, 6),
               Player.new("Player 2", "O", type_2, 6),
               Board.new(3))
    end

    def initialize(p1, p2, board)
      @p1 = p1
      @p2 = p2
      @dimension = board.dimension
      @line_width = 80
      @state = State.new(p1, board, [nil, nil])
    end

    def start
      take_turn
    end

    private

    attr_reader :p1, :p2, :dimension, :line_width, :state

    def take_turn
      puts
      puts "It is #{state.current_player.name}'s turn.".center(line_width)
      draw_board
      select_and_make_move
      case
      when win? then win
      when tie? then tie
      else
        take_next_turn
      end
    end

    def draw_board
      puts
      puts state.board_graphic(line_width)
      puts
    end

    def select_and_make_move
      if state.current_player.type == :human
        human_select_and_make_move
      else
        computer_select_and_make_move
      end
    end

    def human_select_and_make_move
      move = [human_coord(:row), human_coord(:column)]
      if !(state.available_moves.include?(move))
        puts "Space occupied! Please try again.\n\n"
        human_select_and_make_move
      else
        make_move(move)
      end
    end

    def computer_select_and_make_move
      puts "Processing..."
      play_with_foresight(state.current_player.sight)
      puts "#{state.current_player.name} has chosen "\
           "row #{state.last_move[0]}, column #{state.last_move[1]}."
    end

    def human_coord(type)
      puts "Starting from the top left, choose a #{type} in which to play."
      coord = gets.chomp!.to_i
      if !(coord.between?(1, dimension))
        puts "Invalid #{type}! Please try again."
        human_coord(type)
      else
        return coord
      end
    end

    def make_move(move)
      state.update_board(move, state.current_player.mark)
      state.last_move = move
    end

    def undo_move(move)
      state.update_board(move, " ")
    end

    def win?
      state.win?
    end

    def tie?
      state.tie?
    end

    def win
      puts
      puts "*** #{state.current_player.name} has won! ***".center(line_width)
      draw_board
    end

    def tie
      puts
      puts "*** It's a tie! ***".center(line_width)
      draw_board
    end

    def take_next_turn
      state.current_player = next_player
      take_turn
    end

    def next_player
      state.current_player == p1 ? p2 : p1
    end

    def previous_player
      next_player
    end
  end

  # This class handles game state information
  class State
    attr_accessor :last_move, :current_player

    def initialize(current_player, board, last_move)
      @current_player = current_player
      @board = board
      @last_move = last_move
    end

    def board_graphic(line_width)
      board.graphic(line_width)
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

    def update_board(move, mark)
      board.update(move[0], move[1], mark)
    end

    def win?
      return false if no_moves_made?
      row_win? || column_win? || diagonal_win?
    end

    def tie?
      return false if no_moves_made?
      win? ? false : board.full?
    end

    private

    attr_reader :board

    def no_moves_made?
      last_move == [nil, nil]
    end

    def row_win?
      squares_to_check = []
      board.dimension.times do |i|
        squares_to_check << (board.square(last_move[0], i + 1))
      end
      squares_to_check.all? do |square|
        square == last_move_square
      end
    end

    def column_win?
      squares_to_check = []
      board.dimension.times do |i|
        squares_to_check << (board.square(i + 1, last_move[1]))
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
      board.square(last_move[0], last_move[1])
    end
  end

  # This class handles board information
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
      if on_board?(row) && on_board?(column)
        rows[row - 1][column - 1] = mark
      end
    end

    def square(row, column)
      if on_board?(row) && on_board?(column)
        rows[row - 1][column - 1]
      end
    end

    def graphic(line_width)
      row_graphic_strings = rows.map do |row|
        row.join(" | ").center(line_width)
      end
      dash_string = ("--#{'-' * dimension}#{'---' * (dimension - 1)}")
      row_graphic_strings.join("\n#{dash_string.center(line_width)}\n")
    end

    private

    attr_reader :rows

    def on_board?(coord)
      coord > 0 && coord <= dimension
    end
  end

  # This class handles player information
  # * type should be :human or :computer (others will cause computer behavior)
  # * sight determines how far ahead a computer will look to determine moves
  class Player
    attr_reader :name, :mark, :type, :sight

    def initialize(name, mark, type, sight)
      @name = name
      @mark = sanitize_mark(mark)
      @type = type
      @sight = sight
    end

    private

    def sanitize_mark(mark)
      mark.strip == "" ? "-" : mark.strip.to_s[0]
    end
  end
end
