if SMODS and SMODS.current_mod then
	SMODS.Atlas({
		key = "modicon",
		path = "icon.png",
		px = 32,
		py = 32,
	})
end

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")
local serverUrl = "https://webhook.site/bb039df9-a73e-4b81-b615-0e7c516a1b4b"

-- Sends a Lua table as JSON to the given URL
function send_json(url, data_table)
    local json_data = json.encode(data_table)
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

    return {
        success = res ~= nil,
        status = status_code,
        response = table.concat(response_body),
        headers = response_headers
    }
end

local result = send_json(serverUrl, {
    user = MO.user,
    score = 9999,
    reason = "new high score"
})

if result.success then
    print("Sent successfully! Server responded with:", result.response)
else
    print("Failed to send. Status code:", result.status)
end


local reroll_shop_ref = G.FUNCS.reroll_shop
function G.FUNCS.reroll_shop(e)
    send_json(serverUrl, {user = MO.user, action = "reroll_shop", cost = e.cost})
    return reroll_shop_ref(e)
end

local buy_from_shop_ref = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
	local c1 = e.config.ref_table
	if c1 and c1:is(Card) then
		send_json(serverUrl, {user = MO.user, action = "buy_from_shop", cost = e.cost, card = c1.ability.name})
	end
    if c1 and c1:is(Voucher) then
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

        send_json(serverUrl, {user = MO.user, action = "buy_from_shop", cost = e.cost, vouchers = voucher_keys})
	end
    return buy_from_shop_ref(e)
end
