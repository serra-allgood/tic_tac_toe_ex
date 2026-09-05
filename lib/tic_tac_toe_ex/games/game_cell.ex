defmodule TicTacToeEx.Games.GameCell do
  use Ecto.Schema
  import Ecto.Changeset

  alias TicTacToeEx.Games.Game

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_cells" do
    field :cell_id, :integer
    field :user_id, Ecto.UUID
    field :piece, Ecto.Enum, values: [x_piece: "x", o_piece: "o"]
    belongs_to :game, Game

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game_cell, attrs) do
    game_cell
    |> cast(attrs, [:game_id, :cell_id, :user_id, :piece])
    |> validate_required([:game_id, :cell_id])
  end
end
