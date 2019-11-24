local cars = require "NR_Hammer.list.cars"
local hidden = require "NR_Hammer.list.hidden"
local property_exchange_type = require "NR_Hammer.list.property_exchange_type"

local vv_days = require "NR_Hammer.list.veh_days"
local vv_km = require "NR_Hammer.list.veh_km"

function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function vehicle_days(v_days)
    if v_days == "0" then
        return ""
    else
        if v_days == "1" then
            return " cu 1 zi"
        else
            return interp(" cu ${days} zile", {
                days = v_days
            })
        end
    end
end

function vehicle_km(v_days, v_km, v_hidd)
    if v_km == "0" then
      return ""
    end

    if v_km == "" then
      return ""
    end

    if v_days == 0 then
      return interp(" cu ${km} kilometri", {km = v_km})
    end

    if v_days > 0 and v_hidd ~= "x0" then
      return interp(", ${km} kilometri", {km = v_km})
    end

    if v_days > 0 then
      return interp(" si ${km} kilometri", {km = v_km})
    end
end

function vehicle_hidden(v_days, v_km, v_hidd)
    if v_hidd == "none" then
        return ""
    end

    if v_days == 0 and v_km == 0 then
        return interp(" cu ${hidd}", {hidd = v_hidd})
    end

    if v_days > 0 or v_km > 0 then
        return interp(" si ${hidd}", {hidd = v_hidd})
    end
end

function vehicle_price(v_exhange, v_price)

    if v_exhange == "change" or v_exhange == "both" or v_price == "0" then
        return ""
    end

    function veh_exchange_text(exchange)
        if v_exhange == "buy" then
            return ", avand un buget de"
        else
            return " la pretul de"
        end
    end

    return interp("${exchange} $${price}", {
        exchange = veh_exchange_text(exchange),
        price = v_price
    })
end

local function trade_vehicle(player_name, player_number, veh_exchange, veh_name, veh_days, veh_km, veh_hidd, veh_price)

    local v_days_check = string.gsub(veh_days, "%.", "")
    local v_km_check = string.gsub(veh_km, "%.", "")
    local v_days = tonumber(v_days_check)
    local v_km = tonumber(v_km_check)
    -- verify for fraud
    if property_exchange_type[veh_exchange] == nil then
        return  "Car exchange type is invalid. Must be [sell/buy/exchange/both]."
    end

    if veh_days == "up" or veh_days == "down" then
        veh_days = vv_days[veh_days]
        v_days = 1
    else
        if type(v_days) ~= "number" or v_days < 0 then
            return  "Invalid vehicle days."
        end
    end

    if veh_km == "up" or veh_km == "down" then
        veh_km = vv_km[veh_km]
        v_km = 1
    else

        if type(v_km) ~= "number" or v_km < 0 then
            return  "Invalid vehicle kilometers."
        end
    end

    function inTable(tbl, item)
        for key, value in pairs(tbl) do
            if value == item then return key end
        end
        return false
    end

    printStringNow(veh_name)
    if inTable(cars, veh_name) == false then
        return  "Invalid vehicle name."
    end

    if hidden[veh_hidd]== nil then
        return  "Invalid hidden. Place 'x0' for a default value."
    end

    local format_input = interp("${player} ${exchange} ${vehicle}${days}${km}${hidd}${money}, [/sms ${number}].", {
        player = player_name,
        exchange = property_exchange_type[veh_exchange],
        vehicle = veh_name,
        days = vehicle_days(veh_days),
        km = vehicle_km(v_days, veh_km, veh_hidd),
        hidd = vehicle_hidden(v_days, v_km, hidden[veh_hidd]),
        money = vehicle_price(veh_exchange, veh_price),
        number = player_number
    })

    return format_input
end

return {
    trade_vehicle = trade_vehicle
}

--  )
-- print(interp("${prop}", {prop = "Victor vinde Hotknife, [/sms XXXX]."}))
-- trade_vehicle('sell', 'hotknife', '0', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor schimba Jester VIP, [/sms XXXX]."}))
-- trade_vehicle('change', 'jestervip', '0', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor vinde FCR-900 cu 2.100 zile, [/sms XXXX]."}))
-- trade_vehicle('sell', 'fcr', '2.100', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor schimba Sunrise cu 1.291 zile si 4.259 kilometri, [/sms XXXX]."}))
-- trade_vehicle('change', 'sunrise', '1.291', '4.259', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor vinde Mountain Bike cu 1 zi, 13 kilometri si hidden, [/sms XXXX]."}))
-- trade_vehicle('sell', 'mtb', '1', '13', 'x1', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor vinde Infernus VIP cu 494 zile, 1.550 kilometri si dublu hidden la pretul de $220.000.000, [/sms XXXX]."}))
-- trade_vehicle('sell', 'infvip', '494', '1.550', 'x2', '220.000.000')



-- print()
-- print(interp("${prop}", {prop = "Victor vinde BMX cu 1 zi şi 420 kilometri, [/sms XXXX]."}))
-- trade_vehicle('sell', 'bmx', '1', '420', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor schimba Club cu 1 zi si dublu hidden, [/sms XXXX]."}))
-- trade_vehicle('change', 'club', '1', '0', 'x2', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor vinde / schimba Jetmax VIP, [/sms XXXX]."}))
-- trade_vehicle('both', 'jetmaxvip', '0', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Victor vinde / schimba Elegy cu 50 kilometri si hidden, [/sms XXXX]."}))
-- trade_vehicle('both', 'elegy', '0', '50', 'x1', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Bike, [/sms XXXX]."}))
-- trade_vehicle('buy', 'bike', '0', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara vehicul VIP, [/sms XXXX]."}))
-- trade_vehicle('buy', 'vehvip', '0', '0', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Perennial cu 1.000 zile si 25.000 kilometri, [/sms XXXX]."}))
-- trade_vehicle('buy', 'perennial', '1.000', '25.000', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Broadway cu 100 zile, 20.000 kilometri si hidden, [/sms XXXX]."}))
-- trade_vehicle('buy', 'broadway', '100', '20.000', 'x1', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Freeway cu 500 zile, 10.000 kilometri si dublu hidden, avand un buget de $325.000.000, [/sms XXXX]."}))
-- trade_vehicle('buy', 'freeway', '500', '10.000', 'x2', '325.000.000')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Patriot cu putine zile si putini kilometri, [/sms XXXX]."}))
-- trade_vehicle('buy', 'patriot', 'up', '1000', 'x0', '0')
-- print()
-- print(interp("${prop}", {prop = "Tudor cumpara Romero cu multe zile si multi kilometri, [/sms XXXX]."}))
-- trade_vehicle('buy', 'romero', 'down', 'up', 'x0', '0')

-- trade_vehicle('buy', 'romero', 'up', 'down', 'x2', '1.000.000')
