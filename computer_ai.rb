# This module handles computer AI for a game (currently tested for Tic Tac Toe)
# * For Tic Tac Toe, for boards with dimension > 3, only usable with low sight
# * Only works for two players (negation toggle differentiates wins and losses)
# * Game must implement:
#   * make_move(move), undo_move(move)
#   * win?, tie?
#   * previous_player, next_player
# * Game.state must implement:
#   * available_moves
#   * current_player=
module ComputerAI
  def random_move(moves)
    moves[rand(moves.length)]
  end

  def best_moves(scored_moves)
    best_scored_moves = scored_moves.select do |_move, score|
      score == best_score(scored_moves.values)
    end
    best_scored_moves.keys
  end

  def best_score(scores)
    scores.max
  end

  def play_with_foresight(sight)
    scored_moves = {}
    state.available_moves.each do |move|
      make_move(move)
      scored_moves[move] = score_and_revert(move, sight)
    end
    make_move(random_move(best_moves(scored_moves)))
  end

  def score_and_revert(move, sight)
    case
    when win? || (sight == 0) then result = 1 * sight
    when tie? then result = 0
    else
      result = look_ahead(sight - 1)
    end
    undo_move(move)
    result
  end

  def look_ahead(sight)
    state.current_player = next_player
    result = -(score_and_revert(play_with_foresight(sight), sight))
    state.current_player = previous_player
    result
  end
end
