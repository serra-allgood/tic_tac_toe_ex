defmodule TicTacToeEx.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visibility, :text, null: false
      add :invite_code, :text, null: false
      add :is_full, :boolean, default: false
      add :current_turn, :text, default: "x"

      timestamps(type: :utc_datetime)
    end

    # When matchmaking, we're going to prioritize players who have been waiting the longest
    # to start a game.
    create index(:games, [asc: :inserted_at], where: "visibility = 'public' and is_full IS false")

    create unique_index(:games, :invite_code, where: "is_full IS FALSE")
    create constraint(:games, :check_visibility, check: "visibility IN ('public', 'private')")
    create constraint(:games, :check_current_turn, check: "current_turn IN ('x', 'o')")
  end
end
