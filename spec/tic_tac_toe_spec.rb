require "spec_helper"

describe TicTacToe do
  describe "::Game" do
    let(:game) do
      TicTacToe::Game.create(:human, :human)
    end

    describe "#human_select_and_make_move" do
      it "uses valid input to make a move" do
        allow(game).to receive(:human_coord).and_return(1)
        expect(game).to receive(:make_move).with([1, 1])

        game.send(:human_select_and_make_move)
      end
    end

    describe "#human_coord" do
      context "when the coord is invalid" do
        it "issues a warning and tries again" do
          #this causes an infite loop because the input is always invalid
          allow_any_instance_of(Kernel).to receive(:gets).and_return("0\n")
          expect(STDOUT)
                .to receive(:puts).with("Starting from the top left, "\
                                        "choose a row in which to play.")
          expect(STDOUT)
                .to receive(:puts).with("Invalid row! Please try again.")

          game.send(:human_coord, :row)
        end
      end

      context "when the coord is a row" do
        it "asks a player for a row to play in" do
          allow_any_instance_of(Kernel).to receive(:gets).and_return("1\n")
          expect(STDOUT)
                .to receive(:puts).with("Starting from the top left, "\
                                        "choose a row in which to play.")

          game.send(:human_coord, :row)
        end
      end

      context "when the coord is a column" do
        it "asks a player for a column to play in" do
          allow_any_instance_of(Kernel).to receive(:gets).and_return("1\n")
          expect(STDOUT)
                .to receive(:puts).with("Starting from the top left, "\
                                        "choose a column in which to play.")

          game.send(:human_coord, :column)
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
          state.send(:board).dimension.times do |row|
            state.send(:board).dimension.times do |col|
              state.update_board([(row + 1), (col + 1)], "X")
            end
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
        context "of all the same mark" do
          it "returns true" do
            state.update_board([1, 1], "X")
            state.update_board([1, 2], "X")
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([1, 1], "O")
            state.update_board([1, 2], "X")
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled column in the board" do
        context "of all the same mark" do
          it "returns true" do
            state.update_board([1, 1], "X")
            state.update_board([2, 1], "X")
            state.update_board([3, 1], "X")
            state.last_move = [3, 1]

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([1, 1], "O")
            state.update_board([2, 1], "X")
            state.update_board([3, 1], "X")
            state.last_move = [3, 1]

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled down diagonal in the board" do
        context "of all the same mark" do
          it "returns true" do
            state.update_board([1, 1], "X")
            state.update_board([2, 2], "X")
            state.update_board([3, 3], "X")
            state.last_move = [3, 3]

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([1, 1], "O")
            state.update_board([2, 2], "X")
            state.update_board([3, 3], "X")
            state.last_move = [3, 3]

            expect(state.win?).to be(false)
          end
        end
      end

      context "with a filled up diagonal in the board" do
        context "of all the same mark" do
          it "returns true" do
            state.update_board([3, 1], "X")
            state.update_board([2, 2], "X")
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

            expect(state.win?).to be(true)
          end
        end

        context "of different marks" do
          it "returns false" do
            state.update_board([3, 1], "O")
            state.update_board([2, 2], "X")
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

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
      context "when no squares are blank" do
        context "with a win present" do
          it "returns false" do
            state.send(:board).dimension.times do |row|
              state.send(:board).dimension.times do |col|
                state.update_board([(row + 1), (col + 1)], "X")
              end
            end
            state.last_move = [3, 3]

            expect(state.tie?).to be(false)
          end
        end

        context "with no win present" do
          it "returns true" do
            state.send(:board).dimension.times do |row|
              state.send(:board).dimension.times do |col|
                state.update_board([(row + 1), (col + 1)], (row + col))
              end
            end
            state.last_move = [3, 3]

            expect(state.tie?).to be(true)
          end
        end
      end

      context "when some squares are blank" do
        context "with a win present" do
          it "returns false" do
            state.update_board([3, 1], "X")
            state.update_board([2, 2], "X")
            state.update_board([1, 3], "X")
            state.last_move = [1, 3]

            expect(state.tie?).to be(false)
          end
        end

        context "with no win present" do
          it "returns false" do
            state.update_board([3, 1], "X")
            state.update_board([2, 2], "X")
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
      context "when no squares are blank" do
        it "returns true" do
          board.dimension.times do |row|
            board.dimension.times do |col|
              board.update((row + 1), (col + 1), "X")
            end
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
        it "updates rows correctly" do
          board.update(1, 1, "X")

          expect(board.send(:rows)).to eq([["X", " ", " "],
                                           [" ", " ", " "],
                                           [" ", " ", " "]])
        end
      end

      context "when aimed at the lower right corner square" do
        it "updates rows correctly" do
          board.update(3, 3, "X")

          expect(board.send(:rows)).to eq([[" ", " ", " "],
                                           [" ", " ", " "],
                                           [" ", " ", "X"]])
        end
      end

      context "when aimed at some other valid square" do
        it "updates rows correctly" do
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
      context "when aimed at the upper left corner" do
        it "returns the correct mark" do
          board.update(1, 1, "X")
          expect(board.square(1, 1)).to eq("X")
        end
      end

      context "when aimed at the lower right corner" do
        it "returns the correct mark" do
          board.update(3, 3, "X")
          expect(board.square(3, 3)).to eq("X")
        end
      end

      context "when aimed at some other valid square" do
        it "returns the correct mark" do
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
      context "when no squares are blank" do
        it "returns the correct string" do
          board.dimension.times do |row|
            board.dimension.times do |col|
              board.update((row + 1), (col + 1), "X")
            end
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