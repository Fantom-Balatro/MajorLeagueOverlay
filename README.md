# MajorLeagueOverlay
A Balatro Mod to send info to an overlay for Major League Balatro

# Documentation
All json sent along with the username (pulled from the Multiplayer mod)

## game_start
### Info
Sent at the start of every Balatro run (including a Multiplayer match)
### Format
{ user = <username>, action = "game_start", starting_lives = <starting_lives> }
### Example
{ user = "Fantom", action = "game_start", starting_lives = 4 }

## ante_reached
### Info
Sent whenever a new ante is reached (not sent ante 1)
### Format
{user = <username>, action = "ante_reached", amount = <ante>}
### Example
{user = "Fantom", action = "ante_reached", amount = 2}
