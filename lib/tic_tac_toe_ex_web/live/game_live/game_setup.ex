defmodule TicTacToeExWeb.GameSetup do
  use TicTacToeExWeb, :verified_routes

  import Phoenix.LiveView
  import Phoenix.Component

  alias TicTacToeEx.Games

  def on_mount(:fetch_game, %{"game_id" => game_id} = _params, _session, socket) do
    case Games.get_game_state(game_id) do
      {:error, _} ->
        {:halt, redirect(socket, to: ~p"/not_found", status: 404)}

      {:ok, game} ->
        {:cont, assign(socket, :game, game)}
    end
  end

  def on_mount(:setup_user, _pararms, %{"user_id" => user_id} = _session, socket) do
    game = socket.assigns.game
    player_piece = Enum.find(game.players, &(&1.user_id == user_id)).piece

    socket =
      socket
      |> assign(:player_piece, player_piece)
      |> assign(:user_id, user_id)

    {:cont, socket}
  end

  def on_mount(:validate_user, _params, %{"user_id" => user_id} = _session, socket) do
    game = socket.assigns.game

    cond do
      not game.is_full ->
        {:cont, assign(socket, :user_id, user_id)}

      Enum.member?(Games.get_players(game.id), user_id) ->
        {:cont, assign(socket, :user_id, user_id)}

      true ->
        {:halt, redirect(socket, to: ~p"/not_playing")}
    end
  end
end
