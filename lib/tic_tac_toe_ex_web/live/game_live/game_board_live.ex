defmodule TicTacToeExWeb.GameBoardLive do
  use TicTacToeExWeb, :live_view

  alias TicTacToeEx.{Games, Games.GameServer}
  alias TicTacToeExWeb.{GameLive.Components.GameCell, GameSetup}

  on_mount {GameSetup, :fetch_game}
  on_mount {GameSetup, :validate_user}
  on_mount {GameSetup, :setup_user}

  @impl true
  def mount(_params, _session, socket) do
    game = socket.assigns.game
    Phoenix.PubSub.broadcast(TicTacToeEx.PubSub, "game:#{game.id}", :player_joined)
    Phoenix.PubSub.subscribe(TicTacToeEx.PubSub, "game:#{game.id}")

    {:ok, socket}
  end

  @impl true
  def handle_event("place_piece", %{"cell" => cell_id, "piece" => piece} = _params, socket) do
    %{game: game} = socket.assigns
    piece = String.to_existing_atom(piece)
    if game.current_turn == piece do
      GameServer.place_piece(
      game.id,
      String.to_integer(cell_id),
      piece
    )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, update(socket, :game, &Games.reload_game_cells(&1))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.modal id="modal-pending-game" :if={not @game.is_full} closeable={false} active={true}>
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
          player_piece={@player_piece}
          id={cell.cell_id}
        />
      </div>
    </Layouts.app>
    """
  end
end
