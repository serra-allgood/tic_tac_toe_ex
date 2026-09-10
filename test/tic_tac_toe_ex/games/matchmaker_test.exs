defmodule TicTacToeEx.Games.MatchmakerTest do
  use TicTacToeEx.DataCase

  alias TicTacToeEx.{Games, Repo}
  alias TicTacToeEx.Games.{Game, Matchmaker, Player}

  import Ecto.Query
  import TicTacToeEx.GamesFixtures

  defp get_player_piece(game_id, user_id) do
    Repo.one(
      from p in Player,
        where: p.game_id == ^game_id and p.user_id == ^user_id,
        select: p.piece
    )
  end

  describe "match_player/1" do
    test "creates a new public game with player X when no open public game exists" do
      user_id = Ecto.UUID.generate()

      assert {:ok, %Game{} = game} = Matchmaker.match_player(user_id)
      assert game.visibility == :public
      assert game.is_full == false

      players = Games.get_players(game.id)
      assert user_id in players

      piece = get_player_piece(game.id, user_id)
      assert piece == :x_piece
    end

    test "joins an existing open public game as player O and sets is_full to true" do
      user1_id = Ecto.UUID.generate()
      user2_id = Ecto.UUID.generate()

      assert {:ok, %Game{} = game1} = Matchmaker.match_player(user1_id)
      assert game1.is_full == false

      assert {:ok, %Game{} = game2} = Matchmaker.match_player(user2_id)
      assert game2.id == game1.id
      assert game2.is_full == true

      players = Games.get_players(game2.id)
      assert Enum.sort(players) == Enum.sort([user1_id, user2_id])

      assert get_player_piece(game2.id, user1_id) == :x_piece
      assert get_player_piece(game2.id, user2_id) == :o_piece
    end

    test "matches the oldest available public game" do
      user1_id = Ecto.UUID.generate()
      user2_id = Ecto.UUID.generate()
      user3_id = Ecto.UUID.generate()

      game1 =
        game_fixture(%{
          visibility: :public,
          user_id: user1_id,
          piece: :x_piece,
          invite_code: "code1"
        })

      _game2 =
        game_fixture(%{
          visibility: :public,
          user_id: user2_id,
          piece: :x_piece,
          invite_code: "code2"
        })

      assert {:ok, matched_game} = Matchmaker.match_player(user3_id)
      assert matched_game.id == game1.id
      assert matched_game.is_full == true
    end

    test "ignores private games and full public games" do
      user1_id = Ecto.UUID.generate()
      user2_id = Ecto.UUID.generate()
      user3_id = Ecto.UUID.generate()

      _private_game =
        game_fixture(%{
          visibility: :private,
          user_id: user1_id,
          piece: :x_piece,
          invite_code: "code-priv"
        })

      full_game =
        game_fixture(%{
          visibility: :public,
          user_id: user2_id,
          piece: :x_piece,
          invite_code: "code-full"
        })

      Games.update_game(full_game, %{is_full: true})

      assert {:ok, new_game} = Matchmaker.match_player(user3_id)
      assert new_game.id != full_game.id
      assert new_game.visibility == :public
      assert new_game.is_full == false
    end
  end

  describe "match_or_create_game/2" do
    test "creates a new game when passed nil" do
      user_id = Ecto.UUID.generate()

      assert {:ok, %Game{} = game} = Matchmaker.match_or_create_game(nil, user_id)
      assert game.visibility == :public
      assert game.is_full == false
      assert get_player_piece(game.id, user_id) == :x_piece
    end

    test "adds second player and marks game full when passed a game" do
      user1_id = Ecto.UUID.generate()
      user2_id = Ecto.UUID.generate()

      game = game_fixture(%{visibility: :public, user_id: user1_id, piece: :x_piece})

      assert {:ok, updated_game} = Matchmaker.match_or_create_game(game, user2_id)
      assert updated_game.id == game.id
      assert updated_game.is_full == true
      assert get_player_piece(game.id, user2_id) == :o_piece
    end

    test "rolls back transaction if player creation fails" do
      user_id = Ecto.UUID.generate()
      game = game_fixture(%{visibility: :public, user_id: user_id, piece: :x_piece})

      # Attempting to add player with an invalid user_id (nil) fails changeset validation
      assert {:error, %Ecto.Changeset{}} = Matchmaker.match_or_create_game(game, nil)

      # Game remains unchanged and not full
      db_game = Games.get_game!(game.id)
      assert db_game.is_full == false
    end
  end
end
