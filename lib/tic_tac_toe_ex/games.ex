defmodule TicTacToeEx.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias TicTacToeEx.Repo

  alias TicTacToeEx.Games.Game

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
    Repo.get_by(Game, invite_code: invite_code, is_full: false)
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
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
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
