defmodule TicTacToeEx.DynamicGameSupervisor do
  use DynamicSupervisor

  def start_link(_), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_game(game_id) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {TicTacToeEx.DynamicGameSupervisors, self()}},
      {TicTacToeEx.GameSupervisor, game_id}
    )
  end
end
