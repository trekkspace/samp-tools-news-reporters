function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
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
            interior = prop_bizz_type[interior]
        })
    end

    if type == "house" then
        return interp("${space_or_comma}cu interior de tip ${interior}", {
            space_or_comma = prev_space_or_comma(),
            interior = prop_house_type[interior]
        })
    end
end