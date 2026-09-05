defmodule TicTacToeEx.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias TicTacToeEx.Games.Game

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :user_id, Ecto.UUID
    field :piece, Ecto.Enum, values: [x_piece: "x", o_piece: "o"]
    belongs_to :game, Game

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:game_id, :user_id, :piece])
    |> validate_required([:game_id, :user_id, :piece])
  end
end
