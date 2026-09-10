defmodule TicTacToeExWeb.GameLive.Components.GameOverModal do
  use TicTacToeExWeb, :html

  attr :game_over, :atom, required: true
  attr :player_piece, :atom, required: true

  def render(assigns) do
    ~H"""
    <.modal id="modal-game-over" active={true}>
      <h3 class="title is-3">
        {game_over_message(assigns)}
      </h3>
    </.modal>
    """
  end

  defp game_over_message(%{game_over: game_over}) when is_nil(game_over), do: ""

  defp game_over_message(%{game_over: :none}) do
    "Game Over! It's a tie!"
  end

  defp game_over_message(%{game_over: game_over, player_piece: piece}) when game_over == piece do
    "Game Over! You Won!"
  end

  defp game_over_message(_assigns), do: "Game Over! You Lost..."
end
