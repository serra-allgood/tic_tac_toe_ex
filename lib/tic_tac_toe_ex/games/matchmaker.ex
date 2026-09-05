defmodule TicTacToeEx.Games.Matchmaker do
  alias TicTacToeEx.{Games, Games.Game, Repo}

  def match_player(user_id) do
    Repo.transact(fn ->
      game = Games.find_public_game()
      match_or_create_game(game, user_id)
    end)
  end

  defp match_or_create_game(nil, user_id) do
    Games.create_game(%{visibility: :public, user_id: user_id, piece: :x_piece})
  end

  defp match_or_create_game(%Game{} = game, user_id) do
    Repo.transact(fn ->
      Games.create_player(%{game_id: game.id, user_id: user_id, piece: :o_piece})
      Games.update_game(game, %{is_full: true})
    end)
  end
end
