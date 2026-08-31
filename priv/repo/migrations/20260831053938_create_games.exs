defmodule TicTacToeEx.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visibility, :text, null: false
      add :invite_code, :text, null: false
      add :is_full, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:games, :invite_code)
    create constraint(:games, :check_visibility, check: "visibility IN ('public', 'private')")
  end
end
