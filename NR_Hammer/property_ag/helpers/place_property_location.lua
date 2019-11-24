function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
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