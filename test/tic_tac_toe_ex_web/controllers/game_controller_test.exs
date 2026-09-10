defmodule TicTacToeExWeb.GameControllerTest do
  use TicTacToeExWeb.ConnCase

  test "redirects for an unsupported game visibility", %{conn: conn} do
    conn = post(conn, ~p"/games?visibility=unknown")

    assert response(conn, 302)
    assert redirected_to(conn) == "/"
  end
end
