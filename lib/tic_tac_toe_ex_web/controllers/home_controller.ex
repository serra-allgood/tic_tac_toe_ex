defmodule TicTacToeExWeb.HomeController do
  use TicTacToeExWeb, :controller

  def index(conn, _params) do
    button_config = [
      [visibility: "public", color: "is-primary"],
      [visibility: "private", color: "is-link"]
    ]

    render(conn, :index, button_config: button_config)
  end
end
