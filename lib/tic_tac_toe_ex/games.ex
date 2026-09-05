defmodule TicTacToeEx.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias TicTacToeEx.Repo

  alias TicTacToeEx.Games.{Game, GameCell, Player}

  def create_player(attrs) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  def find_public_game do
    from(g in Game,
      where: g.visibility == :public,
      where: g.is_full == false,
      order_by: [asc: g.inserted_at],
      limit: 1,
      lock: "FOR NO KEY UPDATE SKIP LOCKED"
    )
    |> Repo.one()
  end

  def generate_invite_code do
    slug = MnemonicSlugs.generate_slug(3)
    query = from(g in Game, where: g.invite_code == ^slug, limit: 1)

    if Repo.exists?(query) do
      generate_invite_code()
    else
      slug
    end
  end

  def get_by_invite_code(invite_code) do
    game = Repo.get_by(Game, invite_code: invite_code, is_full: false)

    case game do
      nil -> {:error, :not_found}
      _ -> {:ok, game}
    end
  end

  def get_game_state(game_id) do
    game =
      from(g in Game, where: g.id == ^game_id, preload: [:game_cells, :players])
      |> Repo.one()

    case game do
      nil -> {:error, :not_found}
      _ -> {:ok, game}
    end
  end

  def get_piece(game_id, user_id) do
    from(gc in GameCell,
      where: gc.game_id == ^game_id,
      where: gc.user_id == ^user_id,
      select: gc.piece,
      limit: 1
    )
    |> Repo.one()
  end

  def get_players(game_id) do
    from(p in Player,
      where: p.game_id == ^game_id,
      select: p.user_id,
      distinct: true
    )
    |> Repo.all()
  end

  def reload_game_cells(%Game{} = game) do
    Repo.reload(game)
    |> Repo.preload([:game_cells, :players])
  end

  def update_game_cell!(%GameCell{} = game_cell, attrs) do
    game_cell
    |> GameCell.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs) do
    Repo.transact(fn ->
      game = Repo.insert!(Game.changeset(%Game{}, attrs))

      for cell_id <- 1..9 do
        Repo.insert!(GameCell.changeset(%GameCell{}, %{game_id: game.id, cell_id: cell_id}))
      end

      Repo.insert!(Player.changeset(%Player{}, Map.merge(attrs, %{game_id: game.id})))

      {:ok, game}
    end)
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end
end
