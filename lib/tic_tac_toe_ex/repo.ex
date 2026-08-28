defmodule TicTacToeEx.Repo do
  use Ecto.Repo,
    otp_app: :tic_tac_toe_ex,
    adapter: Ecto.Adapters.Postgres
end
