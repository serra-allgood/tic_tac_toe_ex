# TicTacToe

## Description of Functionality

It is a Tic-Tac-Toe game server that supports public and private games between users, using a
LiveView interface. Users looking for any game can join the public queue. The server will check for
currently pending games first and join the user to the first available game. If there are no available
games, the server will create a pending game and push an update to the client if another player joins.
A user can also generate a private game, which will generate an invite code that can be copied and sent
to another player.

The database serves as the source of truth for game state. In addition to the two LiveView processes driving the two players' UI interactions, starting a game will spin up a supervisor tree with eight LineServer actors. Each actor corresponds to a three-in-a-row line on the game board, and when a piece is placed, relevant LineServer actors check to see if the win condition is present and broadcast via PubSub if so.

After a game concludes, the database is cleaned of the relevant records.

## AI/LLM Usage

GitHub Copilot is used in this project, only to write unit tests and find bugs. Despite my personal
feelings about LLMs, the professional industry is currently in love with them; it's been pushed on me
in my day job, and I can't avoid it any longer, so I need to practice with it. My compromise with this
is to limit usage of it to general research questions and the aformentioned unit tests and bug bashing.
