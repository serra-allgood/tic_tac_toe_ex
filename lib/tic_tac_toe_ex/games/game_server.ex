defmodule TicTacToeEx.Games.GameServer do
  use GenServer

  require Logger, warn: false

  alias TicTacToeEx.{Games, Games.LineServer}

  @game_cell_placement %{
    1 => ["-row-1", "-col-1", "-diag-1"],
    2 => ["-row-1", "-col-2"],
    3 => ["-row-1", "-col-3", "-diag-2"],
    4 => ["-row-2", "-col-1"],
    5 => [
      "-row-2",
      "-col-2",
      "-diag-1",
      "-diag-2"
    ],
    6 => ["-row-2", "-col-3"],
    7 => ["-row-3", "-col-1", "-diag-2"],
    8 => ["-row-3", "-col-2"],
    9 => ["-row-3", "-col-3", "-diag-1"]
  }

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via(game_id))
  end

  def via(game_id) do
    {:via, Registry, {TicTacToeEx.GameRegistry, game_id}}
  end

  def place_piece(game_id, cell_id, piece) do
    Logger.debug("Getting here")
    {:ok, _} = ensure_started(game_id)
    Logger.debug("How about here")
    GenServer.cast(via(game_id), {:place_piece, cell_id, piece})
  end

  defp ensure_started(game_id) do
    case Registry.lookup(TicTacToeEx.GameRegistry, game_id) do
      [] -> TicTacToeEx.DynamicGameSupervisor.start_game(game_id)
      _ -> {:ok, :already_started}
    end
  end

  @impl true
  def init(game_id) do
    Games.get_game_state(game_id)
  end

  @impl true
  def handle_cast({:place_piece, cell_id, piece}, game) do
    game.game_cells
    |> Enum.each(fn
      %{cell_id: ^cell_id} = game_cell ->
        Logger.debug("--------------------------Yeppers--------------------")
        Games.update_game_cell!(game_cell, %{piece: piece})

      _ ->
        Logger.debug("----------------------Nopers----------------------")
        nil
    end)

    @game_cell_placement[cell_id]
    |> Enum.each(fn server_id ->
      LineServer.place_piece(game.id, server_id, piece)
    end)

    Phoenix.PubSub.broadcast(TicTacToeEx.PubSub, "game:#{game.id}", :piece_placed)

    Logger.debug("--------------------------Yeppers-------------------------------")

    {:noreply, Games.reload_game_cells(game)}
  end
end
