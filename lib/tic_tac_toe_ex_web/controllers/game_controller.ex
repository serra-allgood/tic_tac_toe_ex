defmodule TicTacToeExWeb.GameController do
  use TicTacToeExWeb, :controller

  alias TicTacToeEx.{Games, Games.Matchmaker}

  def create(conn, %{"visibility" => visibility}) do
    visibility = String.to_existing_atom(visibility)

    with {:ok, game} <-
           then(visibility, fn
             :public -> Matchmaker.match_player()
             :private -> Games.create_game(%{visibility: visibility})
           end) do
      redirect(conn, to: ~p"/games/#{game.id}/live")
    end
  end

  def show(conn, %{"id" => invite_code}) do
    game = Games.get_by_invite_code!(invite_code)

    redirect(conn, to: ~p"/games/#{game.id}/live")
  end
end
