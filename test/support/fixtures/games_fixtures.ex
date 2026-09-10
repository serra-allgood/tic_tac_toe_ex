defmodule TicTacToeEx.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TicTacToeEx.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        invite_code: "some invite_code",
        visibility: :public,
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        piece: :x_piece
      })
      |> TicTacToeEx.Games.create_game()

    game
  end
end
