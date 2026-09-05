defmodule TicTacToeExWeb.GameLive.Components.GameCell do
  use TicTacToeExWeb, :html

  attr :id, :integer, required: true
  attr :player_piece, :atom, required: true
  attr :piece, :atom

  def render(assigns) do
    ~H"""
    <%= if not is_nil(@piece) do %>
      <div class="game-cell">
        {translate_piece(@piece)}
      </div>
    <% else %>
      <div
        class="game-cell"
        phx-click="place_piece"
        phx-value-cell={@id}
        phx-value-piece={@player_piece}
      />
    <% end %>
    """
  end

  defp translate_piece(:x_piece), do: "X"
  defp translate_piece(:o_piece), do: "O"
end
