require "spec_helper"

describe TicTacToe do
  describe "::Game" do
    let(:game) do
      TicTacToe::Game.create(:human, :computer)
    end

    describe "#take_turn" do
      before(:each) do
        allow(STDOUT).to receive(:puts)
        allow(game).to receive(:draw_board)
        allow(game).to receive(:select_and_make_move)
        allow(game).to receive(:take_next_turn)
      end

      context "when creating a full board" do
        let(:all_moves) do
          all_moves = []

          game.send(:dimension).times do |row|
            game.send(:dimension).times do |col|
              all_moves << [(row + 1), (col + 1)]
            end
          end

          all_moves
        end

        context "with a win present" do
          before(:each) do
            all_moves.each do |move|
              game.send(:make_move, move)
            end
          end

          it "declares a win" do
            expect(game).to receive(:win)

            game.send(:take_turn)
          end

          it "does not declare a tie" do
            expect(game).to_not receive(:tie)

            game.send(:take_turn)
          end

          it "does not start the next turn" do
            expect(game).to_not receive(:take_next_turn)

            game.send(:take_turn)
          end
        end

        context "with no win present" do
          before(:each) do
            game.send(:make_move, [1, 1])
            game.send(:make_move, [3, 3])
            game.send(:make_move, [3, 2])
            game.send(:make_move, [1, 3])
            game.send(:make_move, [2, 1])
            game.send(:state).current_player = game.send(:next_player)
            game.send(:make_move, [2, 2])
            game.send(:make_move, [1, 2])
            game.send(:make_move, [3, 1])
            game.send(:make_move, [2, 3])
          end

          it "does not declare a win" do
            expect(game).to_not receive(:win)

            game.send(:take_turn)
          end

          it "declares a tie" do
            expect(game).to receive(:tie)

            game.send(:take_turn)
          end

          it "does not start the next turn" do
            expect(game).to_not receive(:take_next_turn)

            game.send(:take_turn)
          end
        end
      end

      context "when creating an un-full board" do
        context "with a win present" do
          before(:each) do
            game.send(:make_move, [1, 1])
            game.send(:make_move, [1, 2])
            game.send(:make_move, [1, 3])
          end

          it "declares a win" do
            expect(game).to receive(:win)

            game.send(:take_turn)
          end

          it "does not declare a tie" do
            expect(game).to_not receive(:tie)

            game.send(:take_turn)
          end

          it "does not start the next turn" do
            expect(game).to_not receive(:take_next_turn)

            game.send(:take_turn)
          end
        end

        context "with no win present" do
          before(:each) do
            game.send(:make_move, [1, 1])
            game.send(:make_move, [1, 2])
          end

          it "does not declare a win" do
            expect(game).to_not receive(:win)

            game.send(:take_turn)
          end

          it "does not declare a tie" do
            expect(game).to_not receive(:tie)

            game.send(:take_turn)
          end

          it "starts the next turn" do
            expect(game).to receive(:take_next_turn)

            game.send(:take_turn)
          end
        end
      end
    end

    describe "#select_and_make_move" do
      context "when the current player is human" do
        it "asks the human to select and make a move" do
          expect(game).to receive(:human_select_and_make_move)

          game.send(:select_and_make_move)
        end
      end

      context "when the current player is a computer" do
        it "asks the computer to select and make a move" do
          game.send(:state).current_player = game.send(:next_player)

          expect(game).to receive(:computer_select_and_make_move)

          game.send(:select_and_make_move)
        end
      end
    end

    describe "#human_select_and_make_move" do
      before(:each) do
        allow(game).to receive(:human_coord).and_return(1)
      end

      context "when the input move is an occupied square" do
        before(:each) do
          game.send(:make_move, [1, 1])
        end

        it "issues a warning" do
            allow(game).to receive(:try_again)

            expect(STDOUT)
                  .to receive(:puts)
                             .with("Space occupied! Please try again.\n\n")

            game.send(:human_select_and_make_move)
          end

          it "tries again" do
            allow(STDOUT).to receive(:puts)

            expect(game).to receive(:try_again)
                                   .with(:human_select_and_make_move)

            game.send(:human_select_and_make_move)
          end
      end

      context "when the input move is not an occupied square" do
        it "uses the input to make a move" do
          expect(game).to receive(:make_move).with([1, 1])

          game.send(:human_select_and_make_move)
        end
      end
    end

    describe "#computer_select_and_make_move" do
      before(:each) do
        allow_any_instance_of(Kernel).to receive(:rand).and_return(0)
        allow(game).to receive(:puts)
      end

      context "with a win offered" do
        it "moves to win" do
          game.send(:make_move, [1, 1])
          game.send(:make_move, [1, 2])
          game.send(:computer_select_and_make_move)

          expect(game.send(:state).last_move).to eq([1, 3])
        end
      end

      context "with a trap offered" do
        it "moves to set the trap" do
          game.send(:make_move, [2, 2])
          game.send(:state).current_player = game.send(:next_player)
          game.send(:make_move, [1, 1])
          game.send(:make_move, [3, 3])
          game.send(:computer_select_and_make_move)

          expect(game.send(:state).last_move).to eq([1, 3])
        end
      end

      context "with a loss threatened" do
        context "with no win present" do
          it "moves to block the loss" do
            game.send(:make_move, [1, 1])
            game.send(:make_move, [1, 2])
            game.send(:state).current_player = game.send(:next_player)
            game.send(:computer_select_and_make_move)

            expect(game.send(:state).last_move).to eq([1, 3])
          end
        end

        context "with a win present" do
          it "moves to win" do
            game.send(:make_move, [1, 1])
            game.send(:make_move, [1, 2])
            game.send(:state).current_player = game.send(:next_player)
            game.send(:make_move, [2, 1])
            game.send(:make_move, [2, 2])
            game.send(:computer_select_and_make_move)

            expect(game.send(:state).last_move).to eq([2, 3])
          end
        end
      end

      context "with a trap threatened" do
        it "moves to block the trap" do
          game.send(:make_move, [2, 2])
          game.send(:state).current_player = game.send(:next_player)
          game.send(:make_move, [1, 1])
          game.send(:make_move, [3, 3])
          game.send(:state).current_player = game.send(:next_player)
          game.send(:computer_select_and_make_move)

          expect(game.send(:state).last_move).to eq([1, 2])
        end
      end
    end

    describe "#try_again" do
      it "runs the method given to it as its first argument" do
        allow(game).to receive(:dummy_method)

        expect(game).to receive(:dummy_method)

        game.send(:try_again, :dummy_method)
      end
      it "passes any additional arguments along to that method" do
        allow(game).to receive(:dummy_method).with(1, 2)

        expect(game).to receive(:dummy_method).with(1, 2)

        game.send(:try_again, :dummy_method, 1, 2)
      end
    end

    describe "#human_coord" do
      context "when the coord is a row" do
        it "asks for a row to play in" do
          allow_any_instance_of(Kernel).to receive(:gets).and_return("1\n")

          expect(STDOUT)
                .to receive(:puts).with("Starting from the top left, "\
                                        "choose a row in which to play.")

          game.send(:human_coord, :row)
        end
      end

      context "when the coord is a column" do
        it "asks for a column to play in" do
          allow_any_instance_of(Kernel).to receive(:gets).and_return("1\n")

          expect(STDOUT)
                .to receive(:puts).with("Starting from the top left, "\
                                        "choose a column in which to play.")

          game.send(:human_coord, :column)
        end
      end

      context "when the coord is invalid" do
        context "when the coord is not a number" do
          before(:each) do
            allow_any_instance_of(Kernel).to receive(:gets).and_return("a\n")
          end

          it "issues a warning" do
            allow(game).to receive(:try_again)

            expect(STDOUT).to receive(:puts)
            expect(STDOUT)
                  .to receive(:puts).with("Invalid row! Please try again.")

            game.send(:human_coord, :row)
          end

          it "tries again" do
            allow(STDOUT).to receive(:puts)

            expect(game).to receive(:try_again).with(:human_coord, :row)

            game.send(:human_coord, :row)
          end
        end

        context "when the coord is off the board" do
          before(:each) do
            allow_any_instance_of(Kernel).to receive(:gets).and_return("0\n")
          end

          it "issues a warning" do
            allow(game).to receive(:try_again)

            expect(STDOUT).to receive(:puts)
            expect(STDOUT)
                  .to receive(:puts).with("Invalid row! Please try again.")

            game.send(:human_coord, :row)
          end

          it "tries again" do
            allow(STDOUT).to receive(:puts)

            expect(game).to receive(:try_again).with(:human_coord, :row)

            game.send(:human_coord, :row)
          end
        end
      end

      context "when the coord is valid" do
        it "returns the coord" do
          allow_any_instance_of(Kernel).to receive(:gets).and_return("1\n")
          allow(STDOUT).to receive(:puts)

          expect(game.send(:human_coord, :row)).to eq(1)
        end
      end
    end

    describe "#next_player" do
      context "when p1 is the current player" do
        it "returns p2" do
          expect(game.send(:next_player)).to eq(game.send(:p2))
        end
      end

      context "when p2 is the current player" do
        it "returns p1" do
          game.send(:state).current_player = game.send(:p2)

          expect(game.send(:next_player)).to eq(game.send(:p1))
        end
      end
    end
  end

  describe "::State" do
    let(:state) do
      TicTacToe::State.new(TicTacToe::Player.new("na", "X", :na, 0),
                           TicTacToe::Board.new(3),
                           [nil, nil])
    end

    describe "#available_moves" do
      let(:all_moves) do
        all_moves = []

        state.send(:board).dimension.times do |row|
          state.send(:board).dimension.times do |col|
            all_moves << [(row + 1), (col + 1)]
          end
        end

        all_moves
      end

      context "when no squares are blank" do
        it "returns an empty array" do
          all_moves.each do |move|
            state.update_board(move, "X")
          end

          expect(state.available_moves).to eq([])
        end
      end

      context "when all squares are blank" do
        it "returns an array of moves covering every square on the board" do
          expect(state.available_moves).to eq(all_moves)
        end
      end

      context "when only some squares are blank" do
        it "returns an array of moves covering only the blank squares" do
          state.update_board([1, 1], "X")
          state.update_board([2, 2], "X")

          blank_square_moves = all_moves - [[1, 1], [2, 2]]

          expect(state.available_moves).to eq(blank_square_moves)
        end
      end
    end

    describe "#win?" do
      context "with a filled row in the board" do
        before(:each) do
          state.update_board([1, 1], "X")
          state.update_board([1, 2], "X")

          state.last_move = [1, 3]
        end

        context "of all the same mark" do
          it "returns true" do
            state.update_board([1, 3], "X")

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([1, 3], "O")

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled column in the board" do
        before(:each) do
          state.update_board([1, 1], "X")
          state.update_board([2, 1], "X")

          state.last_move = [3, 1]
        end

        context "of all the same mark" do
          it "returns true" do
            state.update_board([3, 1], "X")

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([3, 1], "O")

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled down diagonal in the board" do
        before(:each) do
          state.update_board([1, 1], "X")
          state.update_board([2, 2], "X")

          state.last_move = [3, 3]
        end

        context "of all the same mark" do
          it "returns true" do
            state.update_board([3, 3], "X")

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([3, 3], "O")

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled up diagonal in the board" do
        context "of all the same mark" do
          before(:each) do
            state.update_board([3, 1], "X")
            state.update_board([2, 2], "X")

            state.last_move = [1, 3]
          end

          it "returns true" do
            state.update_board([1, 3], "X")

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([1, 3], "O")

            expect(state.win?).to be(false)
          end
        end
      end

      context "with no row column or diagonal filled" do
        it "returns false" do
          state.update_board([3, 1], "X")
          state.update_board([2, 2], "X")
          state.update_board([1, 2], "X")
          state.last_move = [1, 2]

          expect(state.win?).to be(false)
        end
      end

      context "with no moves made" do
        it "returns false" do
          expect(state.win?).to be(false)
        end
      end
    end

    describe "#tie?" do
      let(:all_moves) do
        all_moves = []

        state.send(:board).dimension.times do |row|
          state.send(:board).dimension.times do |col|
            all_moves << [(row + 1), (col + 1)]
          end
        end

        all_moves
      end

      context "when no squares are blank" do
        before(:each) do
          state.last_move = [3, 3]
        end

        context "with a win present" do
          it "returns false" do
            all_moves.each do |move|
              state.update_board(move, "X")
            end

            expect(state.tie?).to be(false)
          end
        end

        context "with no win present" do
          it "returns true" do
            all_moves.each do |move|
              state.update_board(move, "#{move[0]}#{move[1]}")
            end

            expect(state.tie?).to be(true)
          end
        end
      end

      context "when only some squares are blank" do
        before(:each) do
          state.update_board([3, 1], "X")
          state.update_board([2, 2], "X")
        end

        context "with a win present" do
          it "returns false" do
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

            expect(state.tie?).to be(false)
          end
        end

        context "with no win present" do
          it "returns false" do
            state.update_board([1, 2], "X")
            state.last_move = [1, 2]

            expect(state.tie?).to be(false)
          end
        end
      end

      context "with no moves made" do
        it "returns false" do
          expect(state.tie?).to be(false)
        end
      end
    end
  end

  describe "::Board" do
    let(:board) { TicTacToe::Board.new(3) }

    describe "#full?" do
      let(:all_moves) do
        all_moves = []

        board.dimension.times do |row|
          board.dimension.times do |col|
            all_moves << [(row + 1), (col + 1)]
          end
        end

        all_moves
      end

      context "when no squares are blank" do
        it "returns true" do
          all_moves.each do |move|
            board.update(*move, "X")
          end

          expect(board.full?).to be(true)
        end
      end

      context "when all squares are blank" do
        it "returns false" do
          expect(board.full?).to be(false)
        end
      end

      context "when only some squares are blank" do
        it "returns false" do
          board.update(1, 1, "X")
          board.update(2, 2, "X")

          expect(board.full?).to be(false)
        end
      end
    end

    describe "#update" do
      context "when aimed at the upper left corner square" do
        it "marks that square in rows" do
          board.update(1, 1, "X")

          expect(board.send(:rows)).to eq([["X", " ", " "],
                                           [" ", " ", " "],
                                           [" ", " ", " "]])
        end
      end

      context "when aimed at the lower right corner square" do
        it "marks that square in rows" do
          board.update(3, 3, "X")

          expect(board.send(:rows)).to eq([[" ", " ", " "],
                                           [" ", " ", " "],
                                           [" ", " ", "X"]])
        end
      end

      context "when aimed at some other valid square" do
        it "marks that square in rows" do
          board.update(2, 1, "X")

          expect(board.send(:rows)).to eq([[" ", " ", " "],
                                           ["X", " ", " "],
                                           [" ", " ", " "]])
        end
      end

      context "when aimed outside the board" do
        it "does nothing" do
          board.update(0, 0, "X")
          board.update(4, 4, "X")
          board.update(1, 0, "X")
          board.update(0, 1, "X")

          expect(board.send(:rows)).to eq([[" ", " ", " "],
                                           [" ", " ", " "],
                                           [" ", " ", " "]])
        end
      end
    end

    describe "#square" do
      context "when aimed at the upper left corner square" do
        it "returns the mark for that square" do
          board.update(1, 1, "X")
          expect(board.square(1, 1)).to eq("X")
        end
      end

      context "when aimed at the lower right corner square" do
        it "returns the mark for that square" do
          board.update(3, 3, "X")
          expect(board.square(3, 3)).to eq("X")
        end
      end

      context "when aimed at some other valid square" do
        it "returns the mark for that square" do
          board.update(2, 1, "X")
          expect(board.square(2, 1)).to eq("X")
        end
      end

      context "when aimed outside the board" do
        it "returns nil" do
          results = []

          results << (board.square(0, 0))
          results << (board.square(4, 4))
          results << (board.square(1, 0))
          results << (board.square(0, 1))

          expect(results).to eq([nil, nil, nil, nil])
        end
      end
    end

    describe "#graphic" do
      let(:all_moves) do
        all_moves = []

        board.dimension.times do |row|
          board.dimension.times do |col|
            all_moves << [(row + 1), (col + 1)]
          end
        end

        all_moves
      end

      context "when no squares are blank" do
        it "returns the correct string" do
          all_moves.each do |move|
            board.update(*move, "X")
          end

          expect(board.graphic(0)).to eq( "X | X | X\n"\
                                         "-----------\n"\
                                          "X | X | X\n"\
                                         "-----------\n"\
                                          "X | X | X")
        end
      end

      context "when all squares are blank" do
        it "returns the correct string" do
          expect(board.graphic(0)).to eq( "  |   |  \n"\
                                         "-----------\n"\
                                          "  |   |  \n"\
                                         "-----------\n"\
                                          "  |   |  ")
        end
      end

      context "when only some squares are blank" do
        it "returns the correct string" do
          board.update(1, 1, "X")
          board.update(2, 2, "X")

          expect(board.graphic(0)).to eq( "X |   |  \n"\
                                         "-----------\n"\
                                          "  | X |  \n"\
                                         "-----------\n"\
                                          "  |   |  ")
        end
      end

      context "when passed a line_width greater than 0" do
        it "returns the correct string" do
          board.update(1, 1, "X")
          board.update(2, 2, "X")

          expect(board.graphic(15)).to eq("   X |   |     \n"\
                                          "  -----------  \n"\
                                          "     | X |     \n"\
                                          "  -----------  \n"\
                                          "     |   |     ")
        end
      end
    end
  end

  describe "::Player" do
    describe "#new" do
      context "when passed an empty string as a mark" do
        it "changes it to a dash" do
          expect(TicTacToe::Player.new("I", "", :human, 0).mark).to eq("-")
        end
      end

      context "when passed a blank string as a mark" do
        context "with length of 1" do
          it "changes it to a dash" do
            expect(TicTacToe::Player.new("na", " ", :na, 0).mark).to eq("-")
          end
        end

        context "with length greater than 1" do
          it "changes it to a dash" do
            expect(TicTacToe::Player.new("na", "  ", :na, 0).mark).to eq("-")
          end
        end
      end

      context "when passed a non-blank string as a mark" do
        context "with length 1" do
          it "makes that string the mark" do
            expect(TicTacToe::Player.new("na", "X", :na, 0).mark).to eq("X")
          end
        end

        context "with length greater than 1" do
          it "selects the first non-whitespace character as the mark" do
            expect(TicTacToe::Player.new("na", " XY", :na, 0).mark).to eq("X")
          end
        end
      end
    end
  end
end