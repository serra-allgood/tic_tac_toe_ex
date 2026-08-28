# TicTacToe

## Purpose of this Project

This project is to showcase my knowledge of Elixir OTP practices, as well as to practice with LiveView.

## Description of Functionality

It is a Tic-Tac-Toe game server that supports public and private games between users, using a
LiveView interface. Users looking for any game can join the public queue. The server will check for
currently pending games first and join the user to the first available game. If there are no available
games, the server will create a pending game and push an update to the client if another player joins.
A user can also generate a private game, which will generate an invite like that can be copied and sent
to another player. When the invited player joins, the server once again pushes an update to the client.

Game state is handled by individual GenServers, and the LiveView interface is updated by Phoenix.PubSub.
Game state is also temporarily stored in a postgres database, and if a GenServer crashes and restarts, it
rehydrates from the database. After a game conludes, the history is erased from the database.

## AI/LLM Usage

GitHub Copilot is used in this project, only to write unit tests and find bugs. Despite my personal
feelings about LLMs, the professional industry is currently in love with them; it's been pushed on me
in my day job, and I can't avoid it any longer, so I need to practice with it. My compromise with this
is to limit usage of it to general research questions and the aformentioned unit tests and bug bashing.
