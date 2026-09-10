defmodule TicTacToeExWeb.GameController do
  use TicTacToeExWeb, :controller

  alias TicTacToeEx.{Games, Games.Matchmaker}

  def create(conn, %{"invite_form" => invite_code}) do
    user_id = get_user_id(conn)

    with {:ok, game} <- Games.get_by_invite_code(invite_code),
         {:ok, _} <- Matchmaker.match_or_create_game(game, user_id) do
      redirect(conn, to: ~p"/games/#{game.id}/live?#{[game_id: game.id]}")
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "That invite code is invalid!")
        |> redirect(to: ~p"/")

      _ ->
        conn
        |> put_flash(:error, "Something went wrong while joining the game! Please try again.")
        |> redirect(to: ~p"/")
    end
  end

  def create(conn, %{"visibility" => visibility}) when visibility in ["public", "private"] do
    visibility = String.to_existing_atom(visibility)
    user_id = get_user_id(conn)

    with {:ok, game} <-
           then(visibility, fn
             :public ->
               Matchmaker.match_player(user_id)

             :private ->
               Games.create_game(%{
                 visibility: :private,
                 user_id: user_id,
                 piece: :x_piece
               })
           end) do
      redirect(conn, to: ~p"/games/#{game.id}/live?#{[game_id: game.id]}")
    else
      _ ->
        conn
        |> put_flash(:error, "Something went wrong while creating the game! Please try again.")
        |> redirect(to: ~p"/")
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "That game visibility is invalid!")
    |> redirect(to: ~p"/")
  end

  def show(conn, %{"id" => invite_code}) do
    with {:ok, game} <- Games.get_by_invite_code(invite_code) do
      redirect(conn, to: ~p"/games/#{game.id}/live?#{[game_id: game.id]}")
    else
      _ ->
        conn
        |> put_flash(:error, "That invite code is invalid!")
        |> redirect(to: ~p"/")
    end
  end
end
