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

    if length(state.pieces) == 3 and Enum.all?(state.pieces, &(&1 == hd(state.pieces))) do
      Phoenix.PubSub.broadcast(
        TicTacToeEx.PubSub,
        "game:" <> game_id,
        {:game_over, hd(state.pieces)}
      )

      {:stop, :shutdown, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def terminate(_reason, %{game_id: game_id}) do
    case Games.get_game(game_id) do
      {:ok, game} -> Games.delete_game(game)
      _ -> :ok
    end
  end
end
