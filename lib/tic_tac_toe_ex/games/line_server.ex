defmodule TicTacToeEx.Games.LineServer do
  use GenServer

  def start_link(game_id: game_id, id: id) do
    GenServer.start_link(__MODULE__, [], name: via(game_id, id))
  end

  def via(game_id, server_id) do
    {:via, Registry, {TicTacToeEx.GameRegistry, game_id <> server_id}}
  end

  def place_piece(game_id, server_id, piece) do
    GenServer.cast(via(game_id, server_id), {:place_piece, piece})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:place_piece, piece}, state) when length(state) < 3 do
    state = [piece | state]
    {:noreply, state}
  end

  @impl true
  def handle_cast({:place_piece, _piece}, state) do
    {:noreply, state}
  end
end
