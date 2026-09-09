defmodule TicTacToeExWeb.GameBoardLive do
  use TicTacToeExWeb, :live_view

  alias TicTacToeEx.{Games, GameSupervisor}
  alias TicTacToeExWeb.{GameLive.Components.GameCell, GameSetup}

  on_mount {GameSetup, :fetch_game}
  on_mount {GameSetup, :validate_user}
  on_mount {GameSetup, :setup_user}

  @impl true
  def mount(_params, _session, socket) do
    game = socket.assigns.game
    Phoenix.PubSub.broadcast(TicTacToeEx.PubSub, "game:#{game.id}", :reload_game)
    Phoenix.PubSub.subscribe(TicTacToeEx.PubSub, "game:#{game.id}")

    {:ok, assign(socket, :game_over, nil)}
  end

  @impl true
  def handle_event("place_piece", %{"cell" => cell_id} = _params, socket) do
    game = socket.assigns.game
    piece = socket.assigns.player_piece
    cell_id = String.to_integer(cell_id)

    with {:player_turn, true} <- {:player_turn, game.current_turn == piece},
         {:game_over, false} <- {:game_over, not is_nil(socket.assigns.game_over)},
         {:ok, _} <- Games.place_piece(game, cell_id, piece) do
      Phoenix.PubSub.broadcast_from(
        TicTacToeEx.PubSub,
        self(),
        "game:" <> game.id,
        :reload_game
      )

      GameSupervisor.check_for_winner(game.id, cell_id)
      {:noreply, update(socket, :game, &Games.reload_game_cells/1)}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_over, piece}, socket) do
    Phoenix.PubSub.unsubscribe(TicTacToeEx.PuSub, "game:" <> socket.assigns.game.id)
    {:noreply, assign(socket, :game_over, piece)}
  end

  @impl true
  def handle_info(:reload_game, socket) do
    {:noreply, update(socket, :game, &Games.reload_game_cells/1)}
  end

  @impl true
  def terminate(_reason, socket) do
    game = socket.assigns.game
    Phoenix.PubSub.unsubscribe(TicTacToeEx.PubSub, "game:" <> game.id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.modal :if={not @game.is_full} id="modal-pending-game" closeable={false} active={true}>
        <h3 class="title is-3 is-spaced">
          You've created a {@game.visibility} game!
        </h3>
        <h5 :if={@game.visibility == :public} class="subtitle is-5">
          Matchmaking in progress, waiting on another player to join...
        </h5>
        <div class="content">
          Share the invite code <strong>{@game.invite_code}</strong>
          <span :if={@game.visibility == :public}> if you can't wait!</span>
        </div>
      </.modal>
      <.modal :if={not is_nil(@game_over)} id="modal-game-over" active={true}>
        <h3 class="title is-3">
          <%= if @game_over == @player_piece do %>
            Game Over, You Won!
          <% else %>
            Game Over, You Lost!
          <% end %>
        </h3>
      </.modal>
      <div class="notification is-centered">
        <h3 class="title is-3">
          <%= if @game.current_turn == @player_piece do %>
            Your turn!
          <% else %>
            Their turn...
          <% end %>
        </h3>
      </div>
      <div class="game-board">
        <GameCell.render
          :for={cell <- @game.game_cells}
          piece={cell.piece}
          id={cell.cell_id}
        />
      </div>
    </Layouts.app>
    """
  end
end
