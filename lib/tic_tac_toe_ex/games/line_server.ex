defmodule TicTacToeEx.Games.LineServer do
  use GenServer

  require Logger, warn: false

  alias TicTacToeEx.Games

  @cell_ids_by_line %{
    "row-1" => [1, 2, 3],
    "row-2" => [4, 5, 6],
    "row-3" => [7, 8, 9],
    "col-1" => [1, 4, 7],
    "col-2" => [2, 5, 8],
    "col-3" => [3, 6, 9],
    "diag-1" => [1, 5, 9],
    "diag-2" => [3, 5, 7]
  }

  def start_link(game_id: game_id, line: line) do
    GenServer.start_link(__MODULE__, %{game_id: game_id, line: line, pieces: []}, [])
  end

  def place_piece(pid, cell_id) do
    GenServer.cast(pid, {:place_piece, cell_id})
  end

  @impl true
  def init(state) do
    state = %{state | pieces: Games.get_cell_pieces(state.game_id, @cell_ids_by_line[state.line])}
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:place_piece, cell_id},
        %{game_id: game_id, line: line} = state
      ) do
    state =
      if cell_id in @cell_ids_by_line[line] do
        %{state | pieces: Games.get_cell_pieces(game_id, @cell_ids_by_line[line])}
      else
        state
      end

    case game_over_state(state) do
      false ->
        {:noreply, state}

      game_state ->
        Phoenix.PubSub.broadcast(
          TicTacToeEx.PubSub,
          "game:" <> game_id,
          {:game_over, game_state}
        )

        {:stop, :shutdown, state}
    end
  end

  @impl true
  def terminate(_reason, %{game_id: game_id}) do
    case Games.get_game(game_id) do
      {:ok, game} -> Games.delete_game(game)
      _ -> :ok
    end
  end

  defp game_over_state(%{pieces: pieces}) when length(pieces) != 3, do: false

  defp game_over_state(%{pieces: pieces, game_id: game_id}) do
    winner(pieces) || tie(game_id)
  end

  defp winner(pieces) do
    Enum.all?(pieces, &(&1 == hd(pieces))) && hd(pieces)
  end

  defp tie(game_id) do
    length(Games.get_cell_pieces(game_id, 1..9)) == 9 && :none
  end
end
