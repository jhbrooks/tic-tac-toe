class Game
	def initialize(p1, p2, dimension = 3)
		@p1 = p1
		@p2 = p2
		@board = Board.new(dimension)
		@last_move = [nil, nil]
	end

	def start
		take_turn(p1)
	end

	private

	def take_turn(player)
		puts "It is #{player.name}'s turn."
		draw_board
		move(player)
		if win?
			win(player)
			return nil
		elsif board.full?
			tie
			return nil
		else
			take_turn(other_player(player))
		end
	end

	def draw_board
		board.squares.each do |row|
			p row
		end
	end

	def move(player)
		puts "Starting from the top, choose the row where you'd like to play."
		row = gets.chomp!.to_i
		puts "Starting from the left, choose the column where you'd like to play."
		column = gets.chomp!.to_i
		if !(row.between?(1, board.dimension)) || !(column.between?(1, board.dimension))
			puts "Invalid move! Please try again."
			move(player)
		elsif !(board.squares[row - 1][column - 1].nil?)
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
		puts "#{player.name} has won!"
		draw_board
	end

	def tie
		puts "It's a tie!"
		draw_board
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
end

class Board
	def initialize(dimension)
		@dimension = dimension
		@squares = []
		dimension.times do
			@squares << []
			dimension.times do
				@squares[-1] << nil
			end
		end
	end

	def full?
		squares.all? do |row|
			row.none? { |square| square.nil? }
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
