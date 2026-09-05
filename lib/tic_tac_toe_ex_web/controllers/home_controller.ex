defmodule TicTacToeExWeb.HomeController do
  use TicTacToeExWeb, :controller

  def index(conn, _params) do
    button_config = [
      [visibility: "public", color: "is-primary"],
      [visibility: "private", color: "is-link"]
    ]

    user_id = get_user_id(conn)

    conn
    |> put_session(:user_id, user_id)
    |> render(:index, button_config: button_config, user_id: user_id)
  end
end
