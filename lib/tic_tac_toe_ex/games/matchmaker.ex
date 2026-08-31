defmodule TicTacToeEx.Games.Matchmaker do
  alias TicTacToeEx.{Games, Games.Game, Repo}

  def match_player do
    Repo.transact(fn ->
      game = Games.find_public_game()
      match_or_create_game(game)
    end)
  end

  defp match_or_create_game(nil) do
    Games.create_game(%{visibility: :public})
  end

  defp match_or_create_game(%Game{} = game) do
    Games.update_game(game, %{is_full: true})
  end
end
