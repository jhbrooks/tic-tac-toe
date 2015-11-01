# handles computer AI for a game (currently tested for Tic Tac Toe)
# for Tic Tac Toe, takes too long to be usable for boards with dimension > 3
# currently only works for two players
# currently does not score an immediate win higher than a guaranteed win later
# game must implement: #make_move, #win?, #tie?, #previous_player, #next_player, #undo_move, #available_moves
module ComputerAI
  def random_move(moves)
    moves[rand(moves.length)]
  end

  def best_moves(scored_moves)
    best_scored_moves = scored_moves.select do |move, score|
      score == best_score(scored_moves.values)
    end
    best_scored_moves.keys
  end

  def best_score(scores)
    scores.max
  end

  def play_optimally
    scored_moves = {}
    available_moves.each do |move|
      make_move(move)
      scored_moves[move] = check_game_state_and_revert(move)
    end
    make_move(random_move(best_moves(scored_moves)))
  end

  def check_game_state_and_revert(move)
    if win?
      result = 1
    elsif tie?
      result = 0
    else
      self.current_player = next_player
      result = -(check_game_state_and_revert(play_optimally))
      self.current_player = previous_player
    end
    undo_move(move)
    return result
  end
end