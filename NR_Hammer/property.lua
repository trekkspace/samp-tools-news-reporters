local prop_location = require "NR_Hammer.list.property_locations"

local prop_type = require "NR_Hammer.list.property_type"
local prop_bizz_type = require "NR_Hammer.list.bizz_type"
local prop_house_type = require "NR_Hammer.list.house_sizes"

local property_exchange_type = require "NR_Hammer.list.property_exchange_type"
local property_id_limit = require "NR_Hammer.list.property_id_limit"

function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
-- print( interp("${name} is ${value}", {name = "foo", value = "bar"}) )

function place_property_id(exchange, type, id)
    if exchange ~= "buy" and id ~= -1  then
        if type == "bizz" then
            return interp("-ul cu ID-ul ${property_id}", {property_id = id})
        else
            return interp(" cu ID-ul ${property_id}", {property_id = id})
        end
    else
        return ""
    end
end

function place_property_interior(type, id, interior)

    if interior == "none" then
        return ""
    end

    function prev_space_or_comma()
        if id == -1 then
            return " "
        else
            return ", "
        end
    end

    if type == "bizz" then
        return interp("${space_or_comma}de tip ${interior}", {
            space_or_comma = prev_space_or_comma(),
            interior = interior
        })
    end

    if type == "house" then
        return interp("${space_or_comma}cu interior de tip ${interior}", {
            space_or_comma = prev_space_or_comma(),
            interior = prop_house_type[interior]
        })
    end
end

function place_property_location(type, id, interior, location)

    if location == "none" then
        return ""
    end

    function prev_space_or_comma()
        if id == -1 and interior == "none" then
            return " "
        else
            return ", "
        end
    end

    -- check if the zone exists
    if type == "bizz" then
        return interp("${space_or_comma}situat ${location}", {
            space_or_comma = prev_space_or_comma(),
            location = location
        })
    end

    if type == "house" then
        return interp("${space_or_comma}situata ${location}", {
            space_or_comma = prev_space_or_comma(),
            location = location
        })
    end
end

function place_property_price(exchange, id, interior, location, price)

    if exchange == "change" or exchange == "both" or price == "-1" then
        return ""
    end

    function place_property_exchange_text(exchange)
        if exchange == "buy" then
            return "avand un buget de"
        else
            return "la pretul de"
        end
    end

    return interp(", ${exchange} $${price}", {
        exchange = place_property_exchange_text(exchange),
        price = price
    })
end

-- _______________________________________________________________________
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- _______________________________________________________________________


local function trade_property(player_name, player_number, property_type, property_exchange, property_id, property_interior, property_location, property_price)
    
    local property = property_type

    local p_type = property_type
    local p_exchange = property_exchange
    local p_interior = property_interior
    local p_id = tonumber(property_id)
    local p_location = property_location
    local p_price = property_price
    local p_price_check = string.gsub(property_price, "%.", "")
    -- check for fraud :)))))
        -- verify property exchange type
    if property_exchange_type[p_exchange] == nil then
        return {
            error = true,
            message = "House exchange type is invalid. Must be [sell/buy/exchange/both]."
        }
    end

        -- verify property_type
    if prop_type[p_type] == nil then
        return {
            error = true,
            message = "Property type is invalid. Must be either 'house' or 'bizz'"
        }
    end
        -- verify property for id
    if p_id == nil then
        return {
            error = true,
            message = "Property ID is not valid."
        }
    else
            -- check house id if is in range
        if property == "house" and (p_id ~= -1 and (p_id < property_id_limit.house_min_id or p_id > property_id_limit.house_max_id)) then
            return {
                error = true,
                message = "House ID out of range."
            }
        end

            -- check bizz id if is in range
        if property == "bizz" and (p_id ~= -1 and (p_id < property_id_limit.bizz_min_id or p_id > property_id_limit.bizz_max_id)) then
            return {
                error = true,
                message = "Bizz ID out of range"
            }
        end
    end

        -- verify property_interior
    if property == "house" and prop_house_type[p_interior] == nil then
        return {
            error = true,
            message = "House interior type is invalid."
        }
    end


    function contains(list, x)
        for _, v in pairs(list) do
            if v == x then return true end
        end
        return false
    end
    if property == "bizz" and contains(prop_bizz_type, p_interior) == false then
        return {
            error = true,
            message = "Bizz interior type is invalid."
        }
    end
    
    -- if property == "bizz" and prop_bizz_type[p_interior] == nil then
    --     return "Bizz interior type is invalid."
    -- end

        -- verify property location
    local loc = ""
    for i in string.gmatch(p_location, "%S+") do
        loc = loc .. "_" .. i
    end
    p_location = loc:sub(2)
    if prop_location[p_location] == nil then
        return {
            error = true,
            message = "Propery location is invalid."
        }
    end

        -- verify property property price
        -- property price is a string due to the input from the game console
        -- ex 1500, in the game console would be printed as 1.500, with a dot
    if (p_price_check ~= "-1" and type(tonumber(p_price_check)) ~= "number") or tonumber(p_price_check) < -1 or p_price_check == "0" then
        return {
            error = true,
            message = "Invalid property price."
        }
    end

    -- ______ --
    -- ______ --
    -- ______ --


    local format_input = interp("${player} ${exchange} ${type}${id}${interior}${area}${price}, [/sms ${number}].", {
        player = player_name,
        number = player_number,
        exchange = property_exchange_type[p_exchange],
        type = prop_type[p_type],
        id = place_property_id(p_exchange, p_type, p_id),
        interior = place_property_interior(p_type, p_id, p_interior),
        area = place_property_location(p_type, p_id, p_interior, prop_location[p_location]),
        price = place_property_price(p_exchange, p_id, p_interior, p_location, p_price)
    })

    return {
        error = false,
        message = format_input
    }

end

return {
    trade_property = trade_property
}

-- print("Albert vinde casa, [/sms XXXX].")
-- trade_property("house", "sell", -1, 'none', "none", "-1")
-- print("--- Albert schimba casa cu ID-ul 108, [/sms XXXX].")
-- trade_property("house", "change", 108, 'none', "none", "-1")

-- print("Albert vinde casa cu ID-ul 108, cu interior de tip small, [/sms XXXX].")
-- trade_property("house", "sell", 108, 'small', "none", "-1")

-- print("Albert schimba casa cu ID-ul 108, cu interior de tip small, situata in orasul Las Venturas, [/sms XXXX].")
-- trade_property("house", "change", 108, 'small', "LV", "-1")

-- print("Albert vinde casa cu ID-ul 108, cu interior de tip small, situata in zona Rockshore a orasului Las Venturas, [/sms XXXX].")
-- trade_property("house", "sell", 108, 'small', "Rockshore", "-1")

-- print("Albert vinde casa cu ID-ul 812, cu interior de tip medium, situata in satul Palomino Creek, la pretul de $65.000.000, [/sms XXXX].")
-- trade_property("house", "sell", 812, 'medium', "Palomino_Creek", "65.000.000")
-- print("______________")
-- print("Victor vinde / schimba casa cu ID-ul 397, [/sms XXXX].")
-- trade_property("house", "both", 397, 'none', "none", "-1")

-- print("Victor vinde / schimba casa cu ID-ul 55, cu interior de tip big, situata in orasul Los Santos, [/sms XXXX].")
-- trade_property("house", "both", 55, 'big', "LS", "-1")

-- print("Moise cumpara casa, [/sms XXXX].")
-- trade_property("house", "buy", -1, 'none', "none", "-1")

-- print("Moise cumpara casa cu interior de tip big, [/sms XXXX].")
-- trade_property("house", "buy", -1, 'big', "none", "-1")

-- print("Moise cumpara casa cu interior de tip medium, situata in orasul Las Venturas, [/sms XXXX].")
-- trade_property("house", "buy", -1, 'medium', "LV", "-1")

-- print("Moise cumpara casa cu interior de tip big, situata in zona Vinewood a orasului Los Santos, [/sms XXXX].")
-- trade_property("house", "buy", -1, 'big', "Vinewood", "-1")

-- print("Moise cumpara casa cu interior de tip small, situata in satul Bayside, avand un buget de $35.000.000, [/sms XXXX].")
-- trade_property("house", "buy", 397, 'small', "Bayside", "35.000.000")

-- print("______________")

-- print("David vinde business, [/sms XXXX].")
-- trade_property("bizz", "sell", -1, 'none', "none", "-1")

-- print("David schimba business-ul cu ID-ul 117, [/sms XXXX].")
-- trade_property("bizz", "change", -1, 'none', "none", "-1")

-- print("David vinde business-ul cu ID-ul 121, de tip Bank, [/sms XXXX].")
-- trade_property("bizz", "sell", 121, 'bank', "none", "-1")

-- print("David schimba business-ul cu ID-ul 78, de tip 24/7 Store, situat in orasul San Fierro, [/sms XXXX].")
-- trade_property("bizz", "change", 78, 's247', "SF", "-1")

-- print("David vinde business-ul cu ID-ul 44, de tip Gas Station, situat in zona Emerald Isle a orasului Las Venturas, [/sms XXXX].")
-- trade_property("bizz", "sell", 44, 'gas', "Emerald_Isle", "-1")

-- print("David vinde business-ul cu ID-ul 60, de tip Cluckin' Bell, situat in satul Fort Carson, la pretul de $180.000.000, [/sms XXXX].")
-- trade_property("bizz", "sell", 60, 'bell', "Fort_Carson", "180.000.000")
-- print()
-- print("Victor vinde / schimba business-ul cu ID-ul 107, [/sms XXXX].")
-- trade_property("bizz", "both", 107, 'none', "none", "-1")

-- print("Victor vinde / schimba business-ul cu ID-ul 125, de tip Betting House, situat in orasul Los Santos, [/sms XXXX].")
-- trade_property("bizz", "both", 125, 'bet', "LS", "-1")

-- print()
-- print("Cezar cumpara business, [/sms XXXX].")
-- trade_property("bizz", "buy", -1, 'none', "none", "-1")

-- print("Cezar cumpara business de tip Gun Shop, [/sms XXXX].")
-- trade_property("bizz", "buy", -1, 'gun', "none", "-1")

-- print("Cezar cumpara business de tip Clothing Store, situat in orasul San Fierro, [/sms XXXX].")
-- trade_property("bizz", "buy", -1, 'cs', "SF", "-1")

-- print("Cezar cumpara business de tip Gas Station, situat in orasul Los Santos, avand un buget de $500.000.000, [/sms XXXX].")
-- trade_property("bizz", "buy", -1, 'gas', "LS", "500.000.000")

-- print("Cezar cumpara business de tip Pay N Spray, avand un buget de $900.000.000, [/sms XXXX].")
-- trade_property("bizz", "buy", -1, 'pns', "none", "900.000.000")

-- print("Cezar cumpara business situat in orasul Las Venturas, avand un buget de $270.000.000, [/sms XXXX].")
-- trade_property("bizz", "buy", "2", 'none', "LV", "270.000.000")
