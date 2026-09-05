defmodule TicTacToeEx.GameSupervisor do
  use Supervisor

  require Logger, warn: false

  alias TicTacToeEx.Games.{GameServer, LineServer}

  def start_link(game_id) do
    Supervisor.start_link(__MODULE__, game_id, [])
  end

  @impl true
  def init(game_id) do
    children = define_child_specs(game_id)

    Supervisor.init(children, strategy: :one_for_all)
  end

  defp define_child_specs(game_id) do
    ["row", "col", "diag", GameServer]
    |> Enum.flat_map(&child_specs(game_id, &1))
  end

  defp child_specs(game_id, GameServer) do
    [{GameServer, game_id}]
  end

  defp child_specs(game_id, "diag") do
    [
      %{start: {LineServer, :start_link, [[game_id: game_id, id: "-diag-1"]]}, id: make_ref()},
      %{start: {LineServer, :start_link, [[game_id: game_id, id: "-diag-2"]]}, id: make_ref()}
    ]
  end

  defp child_specs(game_id, server_type) do
    for id <- 1..3 do
      %{
        start: {LineServer, :start_link, [[game_id: game_id, id: "-#{server_type}-#{id}"]]},
        id: make_ref()
      }
    end
  end
end
