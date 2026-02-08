if SMODS and SMODS.current_mod then
	SMODS.Atlas({
		key = "modicon",
		path = "icon.jpg",
		px = 32,
		py = 32,
	})
end


local reroll_shop_ref = G.FUNCS.reroll_shop
function G.FUNCS.reroll_shop(e)
	MO.rerolls = MO.rerolls + 1
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "reroll_shop", cost = e.cost, total_rerolls = MO.rerolls})
    return reroll_shop_ref(e)
end

local buy_from_shop_ref = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
	local c1 = e.config.ref_table
	if c1 and c1:is(Card) then
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "got_card", card = c1.config.center_key})
    end
    return buy_from_shop_ref(e)
end

local use_card_ref = G.FUNCS.use_card
function G.FUNCS.use_card(e, mute, nosave)
	if e.config and e.config.ref_table and e.config.ref_table.shop_voucher and e.config.ref_table.config and e.config.ref_table.config.center_key then
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "bought_voucher", new_voucher = e.config.ref_table.config.center_key, vouchers = MO.UTILS.get_vouchers()})
	end
	if e.config and e.config.ref_table and not e.config.ref_table.shop_voucher and e.config.ref_table.config and e.config.ref_table.config.center.atlas ~= "Booster" and e.config.ref_table.config.center_key then
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "got_card", card = e.config.ref_table.config.center_key})
	end
	return use_card_ref(e, mute, nosave)
end

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
	if mod > 0 then
		MO.earned = MO.earned + mod
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "money_earned", amount = mod, total = MO.earned})
	end
    if mod < 0 then
		MO.spent = MO.spent - mod
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "money_spent", amount = mod * -1, total = MO.spent})
	end
	return ease_dollars_ref(mod, instant)
end

local ease_ante_ref = ease_ante
function ease_ante(mod, instant)
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "ante_reached", amount = G.GAME.round_resets.ante + mod})
    return ease_ante_ref(mod, instant)
end

local ease_lives_ref = ease_lives
function ease_lives(mod, instant)
	MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "life_lost"})
	return ease_lives_ref(mod, instant)
end

local start_run_ref = Game.start_run
function Game:start_run(args)
	if MP and MP.LOBBY then
		MO.pvpScore = 0
		MO.highScore = 0
		MO.rerolls = 0
		MO.earned = 0
		MO.spent = 0
		MO.numLucky = 0
		MO.numGlass = 0
		MO.numGold = 0
		MO.numSteel = 0
		MO.numRedSeal = 0
		MO.numPurpleSeal = 0
		MO.numBlueSeal = 0
		MO.numGoldSeal = 0
		MO.currScore = 0
		MO.discards = 0
		MO.hands = 0
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), nemesis = MP.LOBBY.is_host and MP.LOBBY.guest.username or MP.LOBBY.host.username, stake = MP.LOBBY.deck.stake or MP.LOBBY.config.stake, deck = MP.LOBBY.deck.back or MP.LOBBY.config.back, action = "game_start", starting_lives = MP.LOBBY.config.starting_lives})
	end
	return start_run_ref(self, args)
end

local update_hand_played_ref = Game.update_hand_played
function Game:update_hand_played(dt)
	if not G.STATE_COMPLETE then
		G.E_MANAGER:add_event(Event{
			func = function()
				if G.GAME.chips and G.GAME.chips > MO.currScore then
				local diff = G.GAME.chips - MO.currScore
				MO.currScore = G.GAME.chips
				if diff > MO.highScore then
					MO.highScore = diff
					MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "high_score", score = MO.highScore})
				end
			end
        	return true
		end,
		blocking = false,
		trigger = 'after',
		delay = 0.5
		})
	end
	return update_hand_played_ref(self, dt)
end


local play_hand_ref = MP.ACTIONS.play_hand
function MP.ACTIONS.play_hand(score, hands_left)
	MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "pvp_hands", score = score, count = hands_left})
	MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "current_deck", deck = MO.UTILS.current_deck_string()})
	MO.UTILS.current_hand_string_with_delay(3)
	if score > 0 then
		if (score - MO.pvpScore) > MO.highScore then
			MO.highScore = (score - MO.pvpScore)
			MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "high_score", score = MO.highScore})
		end
	end
	MO.pvpScore = score
	return play_hand_ref(score, hands_left)
end

local blind_select_ref = Game.update_blind_select
function Game:update_blind_select(dt)
	if not G.STATE_COMPLETE then
		MO.currScore = 0
		MO.UTILS.check_deck()
	end
	return blind_select_ref(self, dt)
end

local update_play_tarot_ref = Game.update_play_tarot
function Game:update_play_tarot(dt)
	if self.buttons then
		MO.UTILS.check_deck_with_delay()
	end
	return update_play_tarot_ref(self, dt)
end

local set_location_ref = MP.ACTIONS.set_location
function MP.ACTIONS.set_location(location)
	if MP.GAME.location ~= location then
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "location_change", location = location})
		if location == "loc_playing-bl_mp_nemesis" then
			MO.UTILS.start_pvp()
		end
	end
	return set_location_ref(location)
end

local discard_cards_from_highlighted_ref = G.FUNCS.discard_cards_from_highlighted
function G.FUNCS.discard_cards_from_highlighted(e, hook)
	if MP.is_pvp_boss() then
		MO.discards = G.GAME.current_round.discards_left or 0
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "pvp_discards", count = MO.discards})
		MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "current_deck", deck = MO.UTILS.current_deck_string()})
		MO.UTILS.current_hand_string_with_delay(3)
	end
	return discard_cards_from_highlighted_ref(e, hook)
end