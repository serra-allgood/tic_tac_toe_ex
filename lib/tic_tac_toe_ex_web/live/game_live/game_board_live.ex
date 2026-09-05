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
    GameServer.place_piece(
      socket.assigns.game.id,
      String.to_integer(cell_id),
      String.to_existing_atom(piece)
    )

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
      <h1 :if={not @game.is_full} class="title">Pending...</h1>
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
