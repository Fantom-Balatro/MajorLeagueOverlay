# MajorLeagueOverlay
A Balatro Mod to send info to an overlay for Major League Balatro

# Documentation
All json sent along with the username (pulled from the Multiplayer mod)
Set the serverUrl in Init.lua to the URL of the server (Only sends http not https)

# Actions
## game_start
### Info
Sent at the start of every Balatro run (including a Multiplayer match)
Also resets all internally stored variables (highest score, money earned, etc)
Nemesis property will only be present in multiplayer matches
Stake is numeric where "white stake" equals 1, adds +1 for each higher stake chosen
### Format
{ user = `<username>`, nemesis = `<username_opponent>`, stake = `<chosen_stake>`, deck = `<chosen_deck>`, action = "game_start", starting_lives = `<starting_lives>` }
### Example
{ user = "Fantom", nemesis = "oathkeep", stake = 1, deck = "Red Deck", action = "game_start", starting_lives = 4 }

## ante_reached
### Info
Sent whenever a new ante is reached (not sent ante 1)
### Format
{user = `<username>`, action = "ante_reached", amount = `<ante>`}
### Example
{user = "Fantom", action = "ante_reached", amount = 2}

## life_lost
### Info
Sent whenever a life is lost
### Format
{user = `<username>`, action = "life_lost"}
### Example
{user = "Fantom", action = "life_lost"}

## money_earned
### Info
Sent whenever money is earned (does not include starting $4 or $14 on yellow deck)
Total money earned is all money earned throughout the entire run/match (resets on game_start)
### Format
{user = `<username>`, action = "money_earned", amount = `<amount_earned>`, total = `<total_money_earned>`}
### Example
{user = "Fantom", action = "money_earned", amount = 4, total = 312}

## money_spent
### Info
Sent whenever money is lost (buying something from the shop, rerolls, rental jokers, etc.)
Total money spent is all money spent/lost throughout the entire run/match (resets on game_start)
### Format
{user = `<username>`, action = "money_spent", amount = `<amount_spent>`, total = `<total_money_spent>`}
### Example
{user = "Fantom", action = "money_earned", amount = 10, total = 291}

## reroll_shop
### Info
Sent whenever the reroll button is pressed
Total rerolls is the total amount of rerolls used throughout the entire run/match
### Format
{user = `<username>`, action = "reroll_shop", cost = `<reroll_cost>`, total_rerolls = `<total_rerolls>`}
### Example
{user = "Fantom", action = "reroll_shop", cost = 5, total_rerolls = 12}

## bought_voucher
### Info
Sent whenever a voucher is bought
New voucher is the voucher that was just bought
Vouchers is the list of all vouchers bought that run/match (excludes new_voucher)
Uses Balatro's internal center keys to refer to vouchers
### Format
{user = `<username>`, action = "bought_voucher", new_voucher = `<voucher_bought>` vouchers = `<all_vouchers_bought>`}
### Example
{user = "Fantom", action = "reroll_shop", action = "bought_voucher", new_voucher = "v_crystal_ball", vouchers = "v_wasteful-v_telescope-v_hone"}

## got_card
### Info
Sent whenever a joker/consumable/card is bought and whenever a consumable is used
Uses Balatro's internal center keys to refer to what is gotten
### Format
{user = `<username>`, action = "got_card", card = `<joker_or_consumable_or_card>`}
### Example
{user = "Fantom", action = "got_card", card = "j_hanging_chad"}

## high_score
### Info
Sent whenever the highest recorded score by a player in a single hand during that run/match is beaten
Does not use scientific notation. It simply sends the raw number
### Format
{user = `<username>`, action = "high_score", score = `<high_score>`}
### Example
{user = "Fantom", action = "high_score", score = 103420856}

## location_change
### Info
Sent when the player changes locations
Locations include: 
"loc_selecting" = blind select screen
"loc_shop" = in a shop
"loc_playing-bl_`<blind>`" = playing a blind/boss/nemesis (e.g. "loc_playing-bl_small")
"loc_ready" = ready for PvP
### Format
{user = `<username>`, action = "location_change", location = `<location>`}
### Example
{user = "Fantom", action = "location_change", location = "loc_selecting"}

## start_pvp
### Info
Sent when the player enters pvp
### Format
{user = `<username>`, action = "start_pvp"}
### Example
{user = "Fantom", action = "start_pvp"}

## pvp_discards
### Info
Sent at start of PvP and whenever a discard is used in PvP
### Format
{user = `<username>`, action = "pvp_discards", count = `<discards_left>`}
### Example
{user = "Fantom", action = "pvp_discards", count = 2}

## pvp_hands
### Info
Sent at start of PvP and whenever a hand is used in PvP
### Format
{user = `<username>`, action = "pvp_hands", count = `<hands_left>`, score = `<current_total_pvp_score>`}
### Example
{user = "Fantom", action = "pvp_hands", count = 3, score = 10156}

## deck_check
Sent when selecting a blind or using a relevant consumable
Sends info about deck composition
### Format
{user = `<username>`, action = "deck_check", numLucky = `<num_luckies_in_deck>`, numGlass = `<num_glass_in_deck>`, numGold = `<num_gold_cards_in_deck>`, numSteel = `<num_steel_cards_in_deck>`, numRedSeal = `<num_red_seals_in_deck>`, numPurpleSeal = `<num_purple_seals_in_deck>`, numBlueSeal = `<num_blue_seals_in_deck>`, numGoldSeal = `<num_gold_seals_in_deck>`}
### Example
{user = "Fantom", action = "deck_check", numLucky = 10, numGlass = 0, numGold = 1, numSteel = 3, numRedSeal = 10, numPurpleSeal = 2, numBlueSeal = 1, numGoldSeal = 0}

## full_deck
Sent at start of PvP and whenever a hand/discard is used in PvP
Syntax for a card is as follows:
suit-rank-enhancement-edition-seal
suit can be S,C,H,D
rank can be A,2,3,4,5,6,7,8,9,T,J,Q,K
enhancement is m_`<enhancement>` (c_base is no enhancement)
edition is e_`<edition>`
seal can be Red, Gold, Blue, Purple
### Format
{user = `<username>`, action = "full_deck", deck = `<deck_string>`}
### Example
{user = "Fantom", action = "full_deck", deck = ";S-A-c_base-none-none;S-K-c_base-none-none;S-Q-c_base-none-none;S-J-c_base-none-none;S-T-c_base-none-none;S-9-c_base-none-none;S-8-c_base-none-none;S-7-c_base-none-none;S-6-c_base-none-none;S-5-c_base-none-none;S-4-c_base-none-none;S-3-c_base-none-none;S-2-c_base-none-none;H-A-c_base-none-none;H-K-c_base-none-none;H-Q-c_base-none-none;H-J-c_base-none-none;H-T-c_base-none-none;H-9-c_base-none-none;H-8-c_base-none-none;H-7-c_base-none-none;H-6-c_base-none-none;H-5-c_base-none-none;H-4-c_base-none-none;H-3-c_base-none-none;H-2-c_base-none-none;C-A-c_base-none-none;C-K-c_base-none-none;C-Q-c_base-none-none;C-J-c_base-none-none;C-T-c_base-none-none;C-9-c_base-none-none;C-8-c_base-none-none;C-7-c_base-none-none;C-6-c_base-none-none;C-5-c_base-none-none;C-4-c_base-none-none;C-3-c_base-none-none;C-2-c_base-none-none;D-A-c_base-none-none;D-K-c_base-none-none;D-Q-c_base-none-none;D-J-c_base-none-none;D-T-c_base-none-none;D-9-c_base-none-none;D-8-c_base-none-none;D-7-c_base-none-none;D-6-c_base-none-none;D-5-c_base-none-none;D-4-c_base-none-none;D-3-c_base-none-none;D-2-c_base-none-none;D-4-c_base-none-Gold;S-8-m_gold-none-none"}

## current_deck
Sent whenever a hand/discard is used in PvP (includes cards still in hand and in deck)
Syntax for a card is as follows:
suit-rank-enhancement-edition-seal
suit can be S,C,H,D
rank can be A,2,3,4,5,6,7,8,9,T,J,Q,K
enhancement is m_`<enhancement>` (c_base is no enhancement)
edition is e_`<edition>`
seal can be Red, Gold, Blue, Purple
### Format
{user = `<username>`, action = "current_deck", deck = `<deck_string>`}
### Example
{user = "Fantom", action = "current_deck", deck = ";S-A-c_base-none-none;S-K-c_base-none-none;S-Q-c_base-none-none;S-J-c_base-none-none;S-T-c_base-none-none;S-9-c_base-none-none;S-8-c_base-none-none;S-7-c_base-none-none;S-6-c_base-none-none;S-5-c_base-none-none;S-4-c_base-none-none;S-3-c_base-none-none;S-2-c_base-none-none;H-A-c_base-none-none;H-K-c_base-none-none;H-Q-c_base-none-none;H-J-c_base-none-none;H-T-c_base-none-none;H-9-c_base-none-none;H-8-c_base-none-none;H-7-c_base-none-none;H-6-c_base-none-none;H-5-c_base-none-none;H-4-c_base-none-none;H-3-c_base-none-none;H-2-c_base-none-none;C-A-c_base-none-none;C-K-c_base-none-none;C-Q-c_base-none-none;C-J-c_base-none-none;C-T-c_base-none-none;C-9-c_base-none-none;C-8-c_base-none-none;C-7-c_base-none-none;C-6-c_base-none-none;C-5-c_base-none-none;C-4-c_base-none-none;C-3-c_base-none-none;C-2-c_base-none-none;D-A-c_base-none-none;D-K-c_base-none-none;D-Q-c_base-none-none;D-J-c_base-none-none;D-T-c_base-none-none;D-9-c_base-none-none;D-8-c_base-none-none;D-7-c_base-none-none;D-6-c_base-none-none;D-5-c_base-none-none;D-4-c_base-none-none;D-3-c_base-none-none;D-2-c_base-none-none;D-4-c_base-none-Gold;S-8-m_gold-none-none"}

## current_hand
Sent at start of PvP and whenever a hand/discard is used in PvP
Syntax for a card is as follows:
suit-rank-enhancement-edition-seal
suit can be S,C,H,D
rank can be A,2,3,4,5,6,7,8,9,T,J,Q,K
enhancement is m_`<enhancement>` (c_base is no enhancement)
edition is e_`<edition>`
seal can be Red, Gold, Blue, Purple
### Format
{user = `<username>`, action = "current_hand", hand = `<hand_string>`}
### Example
{user = "Fantom", action = "current_hand", hand = ";H-Q-c_base-none-none;C-Q-c_base-none-none;D-9-c_base-none-none;H-8-c_base-none-none;C-8-c_base-none-none;H-5-c_base-none-none;C-3-c_base-none-none;D-2-c_base-none-none"}