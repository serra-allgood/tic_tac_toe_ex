defmodule TicTacToeEx.Games.LineServerTest do
  use TicTacToeEx.DataCase

  alias TicTacToeEx.Games
  alias TicTacToeEx.Games.LineServer

  import TicTacToeEx.GamesFixtures

  defp set_pieces(game, pieces) do
    {:ok, game} = Games.get_game_state(game.id)

    Enum.each(pieces, fn {cell_id, piece} ->
      cell = Enum.find(game.game_cells, &(&1.cell_id == cell_id))
      assert {:ok, _cell} = Games.update_game_cell(cell, %{piece: piece})
    end)
  end

  test "broadcasts game over when all cells in a line have the same piece" do
    game = game_fixture()
    set_pieces(game, [{1, :x_piece}, {2, :x_piece}, {3, :x_piece}])
    Phoenix.PubSub.subscribe(TicTacToeEx.PubSub, "game:#{game.id}")
    pid = start_supervised!({LineServer, game_id: game.id, line: "row-1"})

    LineServer.place_piece(pid, 1)

    assert_receive {:game_over, :x_piece}
  end

  test "does not broadcast game over for a mixed line" do
    game = game_fixture()
    set_pieces(game, [{1, :x_piece}, {2, :o_piece}, {3, :x_piece}])
    Phoenix.PubSub.subscribe(TicTacToeEx.PubSub, "game:#{game.id}")
    pid = start_supervised!({LineServer, game_id: game.id, line: "row-1"})

    LineServer.place_piece(pid, 1)
    _state = :sys.get_state(pid)

    refute_receive {:game_over, _piece}, 50
  end
end
