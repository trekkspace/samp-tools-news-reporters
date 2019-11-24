function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function place_property_id(exchange, type, id)
    if exchange == "sell" and id ~= -1  then
        if type == "bizz" then
            return interp("-ul cu ID-ul ${property_id}", {property_id = id})
        else
            return interp(" cu ID-ul ${property_id}", {property_id = id})
        end
    else
        return ""
    end
end