if not MO then MO = {} end

MO = {
    serverUrl = "https://localhost:8080",
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
    numGoldSeal = 0
}

MO.UTILS = {
    send_json = nil,
    send_json_event = nil,
    print_table_shallow = nil,
    get_vouchers = nil,
    deck_check = nil,
    check_card = nil,
    reset_temp = nil
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

-- Sends a Lua table as JSON to the given URL
function MO.UTILS.send_json(url, data_table)
    local json = require("json")
    local json_data = json.encode(data_table)
    local threadCode = [[
    local url, json_data = ...
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        local response_body = {}

        local res, status_code, response_headers = http.request{
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
    
    local thread = love.thread.newThread(threadCode)
    thread:start(url, json_data)
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
    MO.UTILS.send_json_event(MO.serverUrl, {user = MP.UTILS.get_username(), action = "deck_check", deck = deck_str}) 
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
    printDebugMessage("Card checked: " .. card_str)
    return true
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