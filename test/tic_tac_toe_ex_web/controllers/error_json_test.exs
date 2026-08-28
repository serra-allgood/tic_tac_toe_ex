defmodule TicTacToeExWeb.ErrorJSONTest do
  use TicTacToeExWeb.ConnCase, async: true

  test "renders 404" do
    assert TicTacToeExWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert TicTacToeExWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
