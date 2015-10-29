class Game
	def initialize(p1, p2, dimension = 3)
		@p1 = p1
		@p2 = p2
		@board = Board.new(dimension)
		@last_move = [nil, nil]
		@line_width = 80
	end

	def start
		take_turn(p1)
		return nil
	end

	private

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
		row_graphic_strings = board.squares.map do |row|
			row.join(" | ").center(line_width)
		end
		dash_string = ("--#{'-' * board.dimension}#{'---' * (board.dimension - 1)}").center(line_width)
		board_graphic_string = row_graphic_strings.join("\n#{dash_string}\n")
		puts board_graphic_string
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
		elsif board.squares[row - 1][column - 1] != " "
			puts "Space occupied! Please try again."
			move(player)
		else
			update_board(row, column, player)
			self.last_move = [(row - 1), (column - 1)]
		end
	end

	def win?
		row_win? || column_win? || diagonal_win?
	end

	def row_win?
		board.squares[last_move[0]].all? do |square|
			square == board.squares[last_move[0]][last_move[1]]
		end
	end

	def column_win?
		squares_to_check = []
		board.dimension.times do |i|
			squares_to_check << (board.squares[i - 1][last_move[1]])
		end
		squares_to_check.all? do |square|
			square == board.squares[last_move[0]][last_move[1]]
		end
	end

	def diagonal_win?
		down_diagonal_win? || up_diagonal_win?
	end

	def down_diagonal_win?
		squares_to_check = []
		1.upto(board.dimension) do |i|
			squares_to_check << (board.squares[i - 1][i - 1])
		end
		squares_to_check.all? do |square|
			square == board.squares[last_move[0]][last_move[1]]
		end
	end

	def up_diagonal_win?
		squares_to_check = []
		board.dimension.downto(1) do |i|
			squares_to_check << (board.squares[i - 1][board.dimension - i])
		end
		squares_to_check.all? do |square|
			square == board.squares[last_move[0]][last_move[1]]
		end
	end

	def win(player)
		puts
		puts "#{player.name} has won!".center(line_width)
		draw_board
		puts
	end

	def tie
		puts
		puts "It's a tie!".center(line_width)
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

	def update_board(row, column, player)
		board.squares[row - 1][column - 1] =
			if player == p1
				"X"
			else
				"O"
			end
	end

	def p1
		@p1
	end

	def p2
		@p2
	end

	def board
		@board
	end

	def last_move
		@last_move
	end

	def last_move=(row_column_pair)
		@last_move = row_column_pair
	end

	def line_width
		@line_width
	end
end

class Board
	def initialize(dimension)
		@dimension = dimension
		@squares = []
		dimension.times do
			@squares << []
			dimension.times do
				@squares[-1] << " "
			end
		end
	end

	def full?
		squares.all? do |row|
			row.none? { |square| square == " " }
		end
	end

	def dimension
		@dimension
	end

	def squares
		@squares
	end	
end

class Player
	def initialize(name)
		@name = name
	end

	def name
		@name
	end
end

g = Game.new(Player.new("Player 1"), Player.new("Player 2"))
g.start
