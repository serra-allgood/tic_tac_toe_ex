defmodule TicTacToeEx.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias TicTacToeEx.Games

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :visibility, Ecto.Enum, values: [:public, :private]
    field :invite_code, :string, autogenerate: {Games, :generate_invite_code, []}
    field :is_full, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:visibility, :invite_code, :is_full])
    |> validate_required([:visibility])
  end
end
