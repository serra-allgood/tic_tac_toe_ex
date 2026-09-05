defmodule TicTacToeExWeb.GameController do
  use TicTacToeExWeb, :controller

  alias TicTacToeEx.{Games, Games.Matchmaker}

  def create(conn, %{"visibility" => visibility}) do
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
    end
  end

  def show(conn, %{"id" => invite_code}) do
    with {:ok, game} <- Games.get_by_invite_code(invite_code) do
      redirect(conn, to: ~p"/games/#{game.id}/live?#{[game_id: game.id]}")
    end
  end
end
