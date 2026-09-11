defmodule TicTacToeEx.GamesTest do
  use TicTacToeEx.DataCase

  alias TicTacToeEx.Games

  describe "games" do
    alias TicTacToeEx.Games.Game
    import TicTacToeEx.GamesFixtures

    @invalid_attrs %{visibility: nil, invite_code: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{
        visibility: :public,
        invite_code: "some invite_code",
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        piece: :x_piece
      }

      assert {:ok, %Game{} = game} = Games.create_game(valid_attrs)
      assert game.visibility == :public
      assert game.invite_code == "some invite_code"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()

      update_attrs = %{
        visibility: :private,
        invite_code: "some updated invite_code"
      }

      assert {:ok, %Game{} = game} = Games.update_game(game, update_attrs)
      assert game.visibility == :private
      assert game.invite_code == "some updated invite_code"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end

    test "get_by_invite_code/1 returns an open game" do
      game = game_fixture(%{visibility: :private, invite_code: "join-me"})

      assert {:ok, found_game} = Games.get_by_invite_code("join-me")
      assert found_game.id == game.id
    end

    test "get_by_invite_code/1 rejects missing and full games" do
      game = game_fixture(%{visibility: :private, invite_code: "already-full"})
      assert {:ok, _game} = Games.update_game(game, %{is_full: true})

      assert {:error, :not_found} = Games.get_by_invite_code("missing")
      assert {:error, :not_found} = Games.get_by_invite_code("already-full")
    end

    test "place_piece/3 places a piece and advances the turn" do
      game = game_fixture()
      {:ok, game} = Games.get_game_state(game.id)

      assert {:ok, [updated_game, updated_cell]} =
               Games.place_piece(game, 1, :x_piece)

      assert updated_game.current_turn == :o_piece
      assert updated_cell.cell_id == 1
      assert updated_cell.piece == :x_piece

      assert {:ok, reloaded_game} = Games.get_game_state(game.id)
      assert Enum.find(reloaded_game.game_cells, &(&1.cell_id == 1)).piece == :x_piece
    end

    test "place_piece/3 rolls back when the cell does not exist" do
      game = game_fixture()
      {:ok, game} = Games.get_game_state(game.id)

      assert {:error, "cell_id not found"} = Games.place_piece(game, 10, :x_piece)
      assert Games.get_game!(game.id).current_turn == :x_piece
      assert Games.get_cell_pieces(game.id, [10]) == []
    end

    test "place_piece/3 rolls back when the cell is already occupied" do
      game = game_fixture()
      {:ok, game} = Games.get_game_state(game.id)

      assert {:ok, _} = Games.place_piece(game, 1, :x_piece)
      {:ok, game} = Games.get_game_state(game.id)

      assert {:error, "cell already occupied"} = Games.place_piece(game, 1, :o_piece)
      assert Games.get_game!(game.id).current_turn == :o_piece
      assert Games.get_cell_pieces(game.id, [1]) == [:x_piece]
    end
  end
end
