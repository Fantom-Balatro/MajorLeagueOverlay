if not MO then MO = {} end

MO = {
    serverUrls = { "http://localhost:8080", "http://localhost:8081" },
    pvpScore = 0,
    highScore = 0,
    rerolls = 0,
    spent = 0,
    earned = 0,
    numLucky = 0,
    numGlass = 0,
    numGold = 0,
    numSteel = 0,
    numRedSeal = 0,
    numPurpleSeal = 0,
    numBlueSeal = 0,
    numGoldSeal = 0,
    currScore = 0,
    discards = 0,
    hands = 0
}

MO.UTILS = {
    send_json = nil,
    send_json_event = nil,
    print_table_shallow = nil,
    get_vouchers = nil,
    deck_check = nil,
    check_card = nil,
    reset_temp = nil,
    check_deck_with_delay = nil,
    start_pvp = nil,
    deck_string = nil
}

MO.TEMP = {
    numLucky = 0,
    numGlass = 0,
    numGold = 0,
    numSteel = 0,
    numRedSeal = 0,
    numPurpleSeal = 0,
    numBlueSeal = 0,
    numGoldSeal = 0
}

-- Sends a Lua table as JSON to one or more URLs
function MO.UTILS.send_json(urls, data_table)
    local json = require("json")
    local json_data = json.encode(data_table)

    -- Normalize input: allow string or table
    if type(urls) == "string" then
        urls = { urls }
    end

    local threadCode = [[
        local url, json_data = ...
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        local response_body = {}

        http.request{
            url = url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#json_data)
            },
            source = ltn12.source.string(json_data),
            sink = ltn12.sink.table(response_body)
        }
    ]]

    for _, url in ipairs(urls) do
        local thread = love.thread.newThread(threadCode)
        thread:start(url, json_data)
    end
end

function MO.UTILS.send_json_event(url, data_table)
    G.E_MANAGER:add_event(Event{
        func = function()
            MO.UTILS.send_json(url, data_table)
            return true
        end,
        blocking = false,
        trigger = "immediate"
    })
end

function MO.UTILS.print_table_shallow(tbl, name)
    name = name or "Table"
    sendDebugMessage(name .. " = {")
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            local sub_items = {}
            for sub_k, sub_v in pairs(v) do
                table.insert(sub_items, tostring(sub_k) .. " = " .. tostring(sub_v))
            end
            sendDebugMessage("  " .. tostring(k) .. " = {" .. table.concat(sub_items, ", ") .. "}")
        else
            sendDebugMessage("  " .. tostring(k) .. " = " .. tostring(v))
        end
    end
    sendDebugMessage("}")
end

function MO.UTILS.get_vouchers()
    local voucher_keys = ""
        if G.GAME.used_vouchers then
            local keys = {}
            for k, v in pairs(G.GAME.used_vouchers) do
                if v == true then
                    table.insert(keys, k)
                end
            end
            voucher_keys = table.concat(keys, "-")
        end
    return voucher_keys
end

function MO.UTILS.check_deck()
    MO.UTILS.reset_temp()
    for _, card in ipairs(G.playing_cards) do
		MO.UTILS.check_card(card)
	end

    local should_send_deck = false
    if MO.TEMP.numLucky ~= MO.numLucky then
        should_send_deck = true
        MO.numLucky = MO.TEMP.numLucky
    end
    if MO.TEMP.numGlass ~= MO.numGlass then
        should_send_deck = true
        MO.numGlass = MO.TEMP.numGlass
    end
    if MO.TEMP.numGold ~= MO.numGold then
        should_send_deck = true
        MO.numGold = MO.TEMP.numGold
    end
    if MO.TEMP.numSteel ~= MO.numSteel then
        should_send_deck = true
        MO.numSteel = MO.TEMP.numSteel
    end
    if MO.TEMP.numRedSeal ~= MO.numRedSeal then
        should_send_deck = true
        MO.numRedSeal = MO.TEMP.numRedSeal
    end
    if MO.TEMP.numPurpleSeal ~= MO.numPurpleSeal then
        should_send_deck = true
        MO.numPurpleSeal = MO.TEMP.numPurpleSeal
    end
    if MO.TEMP.numBlueSeal ~= MO.numBlueSeal then
        should_send_deck = true
        MO.numBlueSeal = MO.TEMP.numBlueSeal
    end
    if MO.TEMP.numGoldSeal ~= MO.numGoldSeal then
        should_send_deck = true
        MO.numGoldSeal = MO.TEMP.numGoldSeal
    end
    if should_send_deck then
        MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "deck_check", numLucky = MO.numLucky, numGlass = MO.numGlass, numGold = MO.numGold, numSteel = MO.numSteel, numRedSeal = MO.numRedSeal, numPurpleSeal = MO.numPurpleSeal, numBlueSeal = MO.numBlueSeal, numGoldSeal = MO.numGoldSeal})
    end
    return true
end

local reversed_centers = nil

function MO.UTILS.check_card(card)
    if not card or not card.base or not card.base.suit or not card.base.value then return "" end

	if not reversed_centers then reversed_centers = MP.UTILS.reverse_key_value_pairs(G.P_CENTERS) end

    local suit = string.sub(card.base.suit, 1, 1)

	local rank_value_map = {
		["10"] = "T",
		Jack = "J",
		Queen = "Q",
		King = "K",
		Ace = "A",
	}
	local rank = rank_value_map[card.base.value] or card.base.value

	local enhancement = reversed_centers[card.config.center] or "none"
	local edition = card.edition and MP.UTILS.reverse_key_value_pairs(card.edition, true)["true"] or "none"
	local seal = card.seal or "none"

	local card_str = suit .. "-" .. rank .. "-" .. enhancement .. "-" .. edition .. "-" .. seal
    if enhancement == "m_gold" then
        MO.TEMP.numGold = MO.TEMP.numGold + 1
    elseif enhancement == "m_lucky" then
        MO.TEMP.numLucky = MO.TEMP.numLucky + 1
    elseif enhancement == "m_glass" then
        MO.TEMP.numGlass = MO.TEMP.numGlass + 1
    elseif enhancement == "m_steel" then
        MO.TEMP.numSteel = MO.TEMP.numSteel + 1
    end
    if seal == "Red" then
        MO.TEMP.numRedSeal = MO.TEMP.numRedSeal + 1
    elseif seal == "Purple" then
        MO.TEMP.numPurpleSeal = MO.TEMP.numPurpleSeal + 1
    elseif seal == "Blue" then
        MO.TEMP.numBlueSeal = MO.TEMP.numBlueSeal + 1
    elseif seal == "Gold" then
        MO.TEMP.numGoldSeal = MO.TEMP.numGoldSeal + 1
    end
    return true
end

function MO.UTILS.check_deck_with_delay()
    G.E_MANAGER:add_event(Event{
		func = function()
            MO.UTILS.check_deck()
        	return true
		end,
		blocking = false,
		trigger = 'after',
		delay = 0.4
		})
end

function MO.UTILS.start_pvp()
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "start_pvp"})
    MO.discards = G.GAME.current_round.discards_left or 0
    MO.hands = G.GAME.current_round.hands_left or 0
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "pvp_discards", count = MO.discards})
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "pvp_hands", score = 0, count = MO.hands})
    MO.UTILS.send_json_event(MO.serverUrls, {user = MP.UTILS.get_username(), action = "full_deck", deck = MO.UTILS.deck_string()})
end

function MO.UTILS.deck_string()
    local deck_str = ""
    for _, card in ipairs(G.playing_cards) do
		deck_str = deck_str .. ";" .. MP.UTILS.card_to_string(card)
	end
    return deck_str
end

function MO.UTILS.current_deck_string()
    local deck_str = ""
    for _, card in ipairs(G.deck.cards) do
        deck_str = deck_str .. ";" .. MP.UTILS.card_to_string(card)
    end
    return deck_str
end

function MO.UTILS.reset_temp()
    MO.TEMP.numLucky = 0
    MO.TEMP.numGlass = 0
    MO.TEMP.numGold = 0
    MO.TEMP.numSteel = 0
    MO.TEMP.numRedSeal = 0
    MO.TEMP.numPurpleSeal = 0
    MO.TEMP.numBlueSeal = 0
    MO.TEMP.numGoldSeal = 0
end
