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
        visibility: "some visibility"
      })
      |> TicTacToeEx.Games.create_game()

    game
  end
end
