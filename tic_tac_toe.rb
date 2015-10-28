class Game
	def initialize(p1, p2, dimension = 3)
		@p1 = p1
		@p2 = p2
		@board = Board.new(dimension)
		@win_condition = dimension
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
end

class Player
	def initialize(name)
		@name = name
	end
end