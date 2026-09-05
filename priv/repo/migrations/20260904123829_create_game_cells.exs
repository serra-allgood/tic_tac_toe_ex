defmodule TicTacToeEx.Repo.Migrations.CreateGameCells do
  use Ecto.Migration

  def change do
    create table(:game_cells, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :game_id, references(:games, on_delete: :delete_all, type: :binary_id), null: false

      add :cell_id, :integer, null: false
      add :user_id, :uuid
      add :piece, :text

      timestamps(type: :utc_datetime)
    end

    create index(:game_cells, :game_id)
    create index(:game_cells, [:game_id, :user_id])
    create constraint(:game_cells, :check_piece, check: "piece IN ('x', 'o')")
    create constraint(:game_cells, :check_cell_id, check: "cell_id >= 1 and cell_id <= 9")
    create unique_index(:game_cells, [:game_id, :cell_id])
  end
end
