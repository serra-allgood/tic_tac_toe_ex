defmodule TicTacToeExWeb.GameLive do
  use TicTacToeExWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <header>
        <h1>game goes here</h1>
      </header>
    </Layouts.app>
    """
  end
end
