defmodule TicTacToeEx.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, :uuid, null: false
      add :piece, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:players, :game_id)
    create constraint(:players, :check_piece, check: "piece IN ('x', 'o')")
    create unique_index(:players, [:game_id, :piece])
  end
end
