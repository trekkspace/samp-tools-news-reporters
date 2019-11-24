function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function place_property_price(exchange, id, interior, location, price)

    if exchange == "change" or exchange == "both" then
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