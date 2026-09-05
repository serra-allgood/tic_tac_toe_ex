defmodule TicTacToeEx.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias TicTacToeEx.{Games, Games.GameCell, Games.Player}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :visibility, Ecto.Enum, values: [:public, :private]
    field :invite_code, :string, autogenerate: {Games, :generate_invite_code, []}
    field :is_full, :boolean, default: false
    has_many :game_cells, GameCell, preload_order: [:cell_id]
		has_many :players, Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:visibility, :invite_code, :is_full])
		|> cast_assoc(:players, with: &Player.changeset/2)
    |> validate_required([:visibility])
  end
end
