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
    MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "reroll_shop", cost = e.cost})
    return reroll_shop_ref(e)
end

local buy_from_shop_ref = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
	local c1 = e.config.ref_table
	if c1 and c1:is(Card) then
		MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "bought_card", card = c1.config.center_key})
    end
    return buy_from_shop_ref(e)
end

local use_card_ref = G.FUNCS.use_card
function G.FUNCS.use_card(e, mute, nosave)
	if e.config and e.config.ref_table and e.config.ref_table.shop_voucher and e.config.ref_table.config and e.config.ref_table.config.center_key then
		MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "bought_voucher",  new_voucher = e.config.ref_table.config.center_key, vouchers = MO.UTILS.get_vouchers()})
	end
	if e.config and e.config.ref_table and not e.config.ref_table.shop_voucher and e.config.ref_table.config and e.config.ref_table.config.center.atlas ~= "Booster" and e.config.ref_table.config.center_key then
		MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "bought_card",  card = e.config.ref_table.config.center_key})
	end
	return use_card_ref(e, mute, nosave)
end

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "money_moved", amount = mod})
	return ease_dollars_ref(mod, instant)
end

local ease_ante_ref = ease_ante
function ease_ante(mod, instant)
    MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "ante_reached", amount = G.GAME.round_resets.ante + mod})
    return ease_ante_ref(mod, instant)
end

local ease_lives_ref = ease_lives
function ease_lives(mod, instant)
	MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "life_lost"})
	return ease_lives_ref(mod, instant)
end

local start_run_ref = Game.start_run
function Game:start_run(args)
	if MP and MP.LOBBY then
		MO.pvpScore = 0
		MO.highScore = 0
		MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "game_start", starting_lives = MP.LOBBY.config.starting_lives})
	end
	return start_run_ref(self, args)
end

local play_hand_ref = MP.ACTIONS.play_hand
function MP.ACTIONS.play_hand(score, hands_left)
	if score > 0 then
		if (score - MO.pvpScore) > MO.highScore then
			MO.highScore = (score - MO.pvpScore)
			MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "high_score", score = MO.highScore})
		end
	end
	MO.pvpScore = score
	return play_hand_ref(score, hands_left)
end