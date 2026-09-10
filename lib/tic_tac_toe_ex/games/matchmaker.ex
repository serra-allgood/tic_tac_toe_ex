defmodule TicTacToeEx.Games.Matchmaker do
  alias TicTacToeEx.{Games, Games.Game, Repo}

  def match_player(user_id) do
    Repo.transact(fn ->
      game = Games.find_public_game()
      match_or_create_game(game, user_id)
    end)
  end

  def match_or_create_game(nil, user_id) do
    Games.create_game(%{visibility: :public, user_id: user_id, piece: :x_piece})
  end

  def match_or_create_game(%Game{} = game, user_id) do
    Repo.transact(fn ->
      with {:ok, _player} <-
             Games.create_player(%{game_id: game.id, user_id: user_id, piece: :o_piece}),
           {:ok, game} <- Games.update_game(game, %{is_full: true}) do
        {:ok, game}
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end
end
