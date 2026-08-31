defmodule TicTacToeExWeb.HomeController do
  use TicTacToeExWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
