# Copilot instructions for this repository

This repo is a Phoenix 1.8 / Elixir 1.17 app named `TicTacToe`. Treat the root `AGENTS.md` as the broader project rulebook; keep this file focused on the commands and project-specific patterns that are easy to miss when working in this codebase.

## Commands

Run these from the repository root:

```sh
mix setup                         # install deps, set up DB, and build assets
mix phx.server                    # start Phoenix at http://localhost:4000
iex -S mix phx.server             # start the app with an IEx shell
mix test                          # create/migrate the test DB, then run ExUnit
mix test test/tic_tac_toe_web/controllers/page_controller_test.exs
mix test test/tic_tac_toe_web/controllers/page_controller_test.exs:4
mix format                        # format Elixir and HEEx files
mix format --check-formatted      # verify formatting without modifying files
mix precommit                     # compile with warnings-as-errors, prune unused deps, format, and test
mix assets.build                  # compile app assets via esbuild
mix assets.deploy                 # minify assets and generate phoenix digest
```

`mix test` already runs `ecto.create` and `ecto.migrate` before test execution. Use `mix ecto.setup` for explicit database setup/seeds and `mix ecto.reset` to drop and rebuild it.

## Project architecture

- The application follows the standard Phoenix layout created by `mix phx.new`: `lib/tic_tac_toe/` holds domain/application code, while `lib/tic_tac_toe_web/` holds the web layer.
- `TicTacToe.Application` is the OTP supervision root. It starts `TicTacToe.Repo`, Oban, `Phoenix.PubSub`, and `TicTacToeWeb.Endpoint` under a `:one_for_one` supervisor.
- `TicTacToeWeb` centralizes the web imports and route helpers (`:router`, `:controller`, `:html`, `:live_view`). Avoid scattering web concerns outside the `TicTacToeWeb` namespace.
- `TicTacToe.Repo` is the shared Ecto repository for Postgres-backed data. Keep persistence logic in `TicTacToe.*` context modules rather than in controllers or LiveViews.
- The current app is intentionally minimal but the project README describes the intended design: a Tic-Tac-Toe server with public queue matching, private invite games, per-game GenServer state, PubSub-driven LiveView updates, and database-backed rehydration when a game server restarts.
- The browser-facing flow is standard Phoenix: router -> controller/LiveView -> templates/components -> PubSub/server updates. Keep the UI layer thin and move game rules/state transitions into domain logic.
- Assets are bundled through `assets/js/app.js` and `assets/css/app.css` via esbuild.

## Repo-specific conventions and guardrails

- Treat `AGENTS.md` as the canonical broader rule set for Elixir/Phoenix work. This file should stay concise and project-specific, not duplicate the entire AGENTS guidance.
- Prefer adding new code under the existing Phoenix structure rather than creating ad hoc app roots. Follow the established split between `lib/tic_tac_toe` and `lib/tic_tac_toe_web`.
- Use `Req` for HTTP work; do not add `:httpoison`, `:tesla`, or `:httpc`.
- In LiveView work, follow the project conventions already captured in `AGENTS.md`: start templates with `<Layouts.app flash={@flash} ...>`, use `to_form/2`, use `<.input>`, give key elements stable DOM ids, and use LiveView streams for collections.
- Keep generated Phoenix patterns in place: use `~p` for routes, `Phoenix.Component` helpers, and `CoreComponents` instead of custom ad hoc HTML helpers.
- Keep Ecto fields typed as `:string` whenever they are textual, and generate migrations with `mix ecto.gen.migration migration_name_using_underscores`.
- For tests, use `start_supervised!/1` for processes, keep the SQL sandbox via `TicTacToe.DataCase` / `TicTacToeWeb.ConnCase`, and avoid `Process.sleep/1` in favor of monitoring or `:sys.get_state/1`.
- The project’s `mix precommit` alias is the final verification step. If it reports issues, fix them before considering the change ready.

## Useful repository context

- `README.md` describes the game as a real-time Tic-Tac-Toe experience with public/private matching and temporary database-backed game state. Keep that behavior in mind when deciding whether a change belongs in a domain context or the LiveView layer.
- The app is deliberately small and Phoenix-standard; prefer targeted edits over broad refactors. Most changes should fit naturally inside the existing app skeleton instead of creating new architecture layers.
- The current generated test suite includes simple controller coverage (`test/tic_tac_toe_web/controllers/page_controller_test.exs`); use that as the baseline pattern for asserting page behavior with `ConnCase` and path-based checks.
