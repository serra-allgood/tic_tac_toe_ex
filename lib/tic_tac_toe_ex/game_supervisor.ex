defmodule TicTacToeEx.GameSupervisor do
  use Supervisor, restart: :temporary

  require Logger, warn: false

  alias TicTacToeEx.Games.LineServer

  def start_link(game_id) do
    Supervisor.start_link(__MODULE__, game_id, name: via(game_id))
  end

  def via(game_id) do
    {:via, Registry, {TicTacToeEx.GameRegistry, game_id}}
  end

  # TODO: Collect errors and retry after making LineServer.place_piece idempotent
  def check_for_winner(game_id, cell_id) do
    {:ok, _} = ensure_started(game_id)

    Supervisor.which_children(via(game_id))
    |> Enum.each(fn
      {{LineServer, _server_id}, pid, :worker, [LineServer]} when is_pid(pid) ->
        LineServer.place_piece(pid, cell_id)

      _ ->
        nil
    end)
  end

  defp ensure_started(game_id) do
    case Registry.lookup(TicTacToeEx.GameRegistry, game_id) do
      [] -> TicTacToeEx.DynamicGameSupervisor.start_game(game_id)
      _ -> {:ok, :already_started}
    end
  end

  @impl true
  def init(game_id) do
    children = child_specs(game_id)

    Supervisor.init(children, strategy: :one_for_one, auto_shutdown: :any_significant)
  end

  defp child_specs(game_id) do
    ["row", "col", "diag"]
    |> Enum.flat_map(&build_child_specs(game_id, &1))
  end

  defp build_child_specs(game_id, "diag") do
    [
      %{
        start: {LineServer, :start_link, [[game_id: game_id, line: "diag-1"]]},
        id: {LineServer, game_id <> "-diag-1"},
        restart: :transient,
        significant: true
      },
      %{
        start: {LineServer, :start_link, [[game_id: game_id, line: "diag-2"]]},
        id: {LineServer, game_id <> "-diag-2"},
        restart: :transient,
        significant: true
      }
    ]
  end

  defp build_child_specs(game_id, server_type) do
    for id <- 1..3 do
      %{
        start: {LineServer, :start_link, [[game_id: game_id, line: "#{server_type}-#{id}"]]},
        id: {LineServer, "#{game_id}-#{server_type}-#{id}"},
        restart: :transient,
        significant: true
      }
    end
  end
end
