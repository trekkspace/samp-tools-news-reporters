local imgui = require 'imgui'
local key = require 'vkeys'
local sampev = require 'samp.events'

local t_property = require("NR_Hammer.property")
local t_vehicle = require("NR_Hammer.vehicle")
local car_list = require("NR_Hammer.list.cars")
local bizz_list = require("NR_Hammer.list.bizz_type")
local location_list = require("NR_Hammer.list.locations")

local selected = {
    message = imgui.ImInt(-1),
    location = imgui.ImInt(-1),
    car = imgui.ImInt(-1),
    business = imgui.ImInt(-1),
    house = imgui.ImInt(-1)
}
local i_business = {
    location = imgui.ImBuffer(256),
    type = imgui.ImBuffer(256),
    id = imgui.ImBuffer(256),
    price = imgui.ImBuffer(256)
}

local i_car = {
    veh_vip = imgui.ImBool(false),
    model = imgui.ImBuffer(256),
    days = imgui.ImBuffer(256),
    km = imgui.ImBuffer(256),
    hidd = imgui.ImBuffer(256),
    price = imgui.ImBuffer(256),
}

local i_house = {
    location = imgui.ImBuffer(256),
    type = imgui.ImBuffer(256), -- 'none/small/medium/big'
    id = imgui.ImBuffer(256),
    price = imgui.ImBuffer(256)
}


local check_box = {

    x0 = imgui.ImBool(true),
    x1 = imgui.ImBool(false),
    x2 = imgui.ImBool(false),

    none = imgui.ImBool(true),
    small = imgui.ImBool(false),
    medium = imgui.ImBool(false),
    big = imgui.ImBool(false),
}

local trade_seleted = {
    trade = imgui.ImBuffer(256),

    sell = imgui.ImBool(true),
    buy = imgui.ImBool(false),
    change = imgui.ImBool(false),
    both = imgui.ImBool(false),
}

local property_selected = {
    property = imgui.ImBuffer(256),

    car = imgui.ImBool(true),
    house = imgui.ImBool(false),
    bizz = imgui.ImBool(false)
}

local search = {
  bizz = imgui.ImBuffer(256),
  car = imgui.ImBuffer(256),
  house = imgui.ImBuffer(256),
  location = imgui.ImBuffer(256)
}



-- alt
local ads_pool = {
    {name = "player_a", number = '0450', message = "vand freeway 2x"},
    {name = "player_b", number = '12312', message = "schimb casa in ls cu id 40"},
}

local ad_pool = {
    accept = imgui.ImBool(true)
}


local m_text = {}

local m_text_init = {
    name = imgui.ImBuffer(256),
    number = imgui.ImBuffer(256),
    message = "Ad not selected.",
    id = -1
}

m_text = m_text_init

local main_window_state = imgui.ImBool(false)
local second_windows_state = imgui.ImBool(true)

local translated_text = imgui.ImBuffer(256)

-- init defaul values
property_selected.property.v = 'car'
trade_seleted.trade.v = 'sell'
i_house.type.v = 'none'
i_car.hidd.v = 'x0'



function sampev.onServerMessage(color, text)
    if ad_pool.accept.v then
        local check_str = {}
        if text:sub(1, 8) == "SMS from" then
            for i in string.gmatch(text, "[^%s]+") do table.insert(check_str, i) end

            local player_number = check_str[4]:sub(2, -3)
            local s, j = string.find(text, player_number)
            table.insert(ads_pool, {
                name = check_str[3],
                number = player_number,
                message = text:sub(j + 4)
            })
        end
    end
end

function get_ads()
    local ads_list = {}
    for count = 1, #ads_pool do
        table.insert(ads_list, ads_pool[count].name .. " - " .. ads_pool[count].message)
    end

    return ads_list
end

function filtered_list(text, list)
    if text == "" then
        return list
    end

    local new_list = {}
    for count = 1, #list do
        local i = string.find(string.lower(list[count]), string.lower(text))
        if i then table.insert(new_list, list[count]) end
    end
    return new_list
end

function get_input()
    if m_text.name.v == "" or m_text.number.v == "" then
        translated_text.v = 'Invalid player name / number.'
        return
    end
    if property_selected["property"].v == 'bizz' then
        if i_business.id.v == "" then i_business.id.v = '-1' end
        if i_business.price.v == "" then i_business.price.v = '-1' end

        translated_text.v = t_property.trade_property(
            m_text.name.v,
            m_text.number.v,
            "bizz",
            trade_seleted["trade"].v,
            i_business.id.v,
            i_business.type.v,
            i_business.location.v,
            i_business.price.v
        )
    end

    if property_selected["property"].v == 'car' then
        if i_car.days.v == "" then i_car.days.v = "0" end
        if i_car.km.v == "" then i_car.km.v = "0" end
        if i_car.price.v == "" then i_car.price.v = "0" end
        if i_car.hidd.v == "" then i_car.hidd.v = "x0" end

        translated_text.v = t_vehicle.trade_vehicle(
            m_text.name.v,
            m_text.number.v,
            trade_seleted["trade"].v,
            i_car.model.v,
            i_car.days.v or "0",
            i_car.km.v or "0",
            i_car.hidd.v,
            i_car.price.v or "0")
    end

    if property_selected["property"].v == 'house' then

        if i_house.id.v == "" then i_house.id.v = '-1' end
        if i_house.price.v == "" then i_house.price.v = '-1' end

        translated_text.v = t_property.trade_property(
            m_text.name.v,
            m_text.number.v,
            "house",
            trade_seleted["trade"].v,
            i_house.id.v,
            i_house.type.v,
            i_house.location.v,
            i_house.price.v
        )

    end
end

-- frame
-- frame
-- frame

function imgui.OnDrawFrame()
    if main_window_state.v then
        imgui.Begin('Ad Pool', second_windows_state)

        imgui.BeginGroup()

        imgui.Checkbox('Receive Ads in Pool', ad_pool.accept)

        imgui.SameLine()

        if imgui.Button('Clear Pool') then
            ads_pool = {}
        end

        imgui.SameLine()
        if imgui.Button('Remove') then

            selected.message.v = -1
            table.remove(ads_pool, m_text.id)
            m_text = m_text_init
            m_text.name.v = ""
            m_text.number.v = ""
            get_input()
        end

        imgui.PushItemWidth(80)
        if imgui.InputText('Player', m_text.name) then get_input() end

        imgui.PushItemWidth(80)
        if imgui.InputText('Number', m_text.number) then get_input() end

        imgui.Text("Ad: " .. m_text.message)
        imgui.EndGroup()

        imgui.PushItemWidth(-1)
        if imgui.ListBox('Ads', selected.message, get_ads(), 6) then
            m_text.name.v = ads_pool[selected.message.v + 1].name
            m_text.number.v = ads_pool[selected.message.v + 1].number
            m_text.message = ads_pool[selected.message.v + 1].message
            m_text.id = selected.message.v + 1
            get_input()
            printStringNow('Selected', 1000)
        end
        imgui.End()


        imgui.Begin('News Reporters', main_window_state)

        imgui.TextWrapped('Ad: ' .. m_text.message)
        imgui.Separator()
        imgui.TextWrapped("News: " .. translated_text.v)
        imgui.Separator()
        imgui.BeginGroup()
        if imgui.Button('/cw') then
          sampSendChat('/cw ' .. translated_text.v)
        end
        imgui.SameLine()
        if imgui.Button('/news ') then
          sampSendChat("/news ".. translated_text.v)
        end
        imgui.SameLine()
        if imgui.Button("Chat") then
          sampSendChat(translated_text.v)
        end

        imgui.EndGroup()

        imgui.Separator()

        imgui.Columns(2)
        -- // Property Selection
        -- //
        -- //
        imgui.BeginGroup()
        if imgui.RadioButton('Car', property_selected["car"].v) then
            property_selected["property"].v = "car"

            printStringNow("You selected Car.", 1000)
            get_input()
            property_selected["car"].v = true
            property_selected["house"].v = false
            property_selected["bizz"].v = false
        end
        imgui.SameLine()
        if imgui.RadioButton('House', property_selected["house"].v) then
            property_selected["property"].v = "house"

            printStringNow("You selected House.", 1000)
            get_input()

            property_selected["car"].v = false
            property_selected["house"].v = true
            property_selected["bizz"].v = false
        end

        if imgui.RadioButton('Business', property_selected["bizz"].v) then
            property_selected["property"].v = "bizz"

            printStringNow("You selected Business.", 1000)
            get_input()

            property_selected["car"].v = false
            property_selected["house"].v = false
            property_selected["bizz"].v = true
        end
        imgui.EndGroup()

        imgui.NextColumn()

        imgui.BeginGroup()

        -- // Trade Selection
        -- //
        -- //

        if imgui.RadioButton('Sell', trade_seleted["sell"].v) then
            trade_seleted["trade"].v = "sell"
            get_input()
            trade_seleted["sell"].v = true
            trade_seleted["buy"].v = false
            trade_seleted["both"].v = false
            trade_seleted["change"].v = false
        end

        imgui.SameLine()

        if imgui.RadioButton('Both', trade_seleted["both"].v) then
            trade_seleted["trade"].v = "both"
            get_input()
            trade_seleted["sell"].v = false
            trade_seleted["buy"].v = false
            trade_seleted["both"].v = true
            trade_seleted["change"].v = false
        end
        if imgui.RadioButton('Buy', trade_seleted["buy"].v) then
            trade_seleted["trade"].v = "buy"
            get_input()
            trade_seleted["sell"].v = false
            trade_seleted["buy"].v = true
            trade_seleted["both"].v = false
            trade_seleted["change"].v = false
        end

        imgui.SameLine()
        if imgui.RadioButton('Change', trade_seleted["change"].v) then
            trade_seleted["trade"].v = "change"
            get_input()
            trade_seleted["sell"].v = false
            trade_seleted["buy"].v = false
            trade_seleted["both"].v = false
            trade_seleted["change"].v = true
        end



        imgui.EndGroup()

        if property_selected['car'].v then

            imgui.Columns(1);
            imgui.Separator()
            imgui.Text("Vehicle Information")
            imgui.Separator()

            imgui.Columns(2);
            if imgui.Checkbox('VIP', i_car.veh_vip) then
              get_input()
            end

            -- car model
            if imgui.InputText('Model', search.car) then
                -- local search_car = filtered_list(search.car.v, car_list)
                local f_list = filtered_list(search.car.v, car_list)
                if f_list[2] == nil and f_list[1] then
                    i_car.model.v = f_list[1]
                end
                get_input()
            end

            if imgui.ListBox('Cars', selected.car, filtered_list(search.car.v, car_list), 6) then
                i_car.model.v = filtered_list(search.car.v, car_list)[selected.car.v + 1]
                get_input()
            end

            imgui.NextColumn()
            imgui.BeginGroup()


            if imgui.RadioButton('X0', check_box["x0"].v) then
                i_car.hidd.v = 'x0'
                get_input()

                check_box["x0"].v = true
                check_box["x1"].v = false
                check_box["x2"].v = false
            end

            imgui.SameLine()

            if imgui.RadioButton('X1', check_box["x1"].v) then
                i_car.hidd.v = 'x1'
                get_input()
                check_box["x0"].v = false
                check_box["x1"].v = true
                check_box["x2"].v = false
            end
            imgui.SameLine()

            if imgui.RadioButton('X2', check_box["x2"].v) then
                i_car.hidd.v = 'x2'
                get_input()
                check_box["x0"].v = false
                check_box["x1"].v = false
                check_box["x2"].v = true

            end

            imgui.EndGroup()

            imgui.BeginGroup()

            imgui.Text("Vehicle kilometers: ")

            imgui.PushItemWidth(10)
            if imgui.Button('K -') then
                i_car.km.v = "down"
                get_input()
            end
            imgui.SameLine()

            imgui.PushItemWidth(30)
            if imgui.Button('No KM') then
                i_car.km.v = "0"
                get_input()
            end
            imgui.SameLine()

            imgui.PushItemWidth(10)
            if imgui.Button('K +') then
                i_car.km.v = "up"
                get_input()
            end
            -- imgui.SameLine()
            imgui.PushItemWidth(115)
            if imgui.InputText('KM', i_car.km) then
                get_input()
            end

            imgui.EndGroup()

            imgui.BeginGroup()

            imgui.Text('Vehicle Days: ')

            if imgui.Button('D -') then
                i_car.days.v = "down"
                get_input()
                printStringNow(i_car.days.v, 1000)

            end
            imgui.SameLine()
            if imgui.Button('No DY') then
                i_car.days.v = "0"
                printStringNow(i_car.days.v, 1000)

                get_input()
            end
            imgui.SameLine()
            if imgui.Button('D +') then
                i_car.days.v = "up"
                get_input()
            end

            imgui.PushItemWidth(115);
            if imgui.InputText('Days', i_car.days) then
                get_input()
            end
            imgui.EndGroup()

            if trade_seleted["trade"].v == "sell" or trade_seleted["trade"].v == "buy" then
                imgui.BeginGroup()

                imgui.Text('Vehicle Price: ')

                if imgui.Button('No Price') then
                    i_car.price.v = "0"
                    get_input()
                end

                imgui.PushItemWidth(115)
                if imgui.InputText('Price', i_car.price) then
                    get_input()
                end
                imgui.EndGroup()
            end
        end

        if property_selected.house.v then
            imgui.Columns(1);
            imgui.Separator()
            imgui.Text("House Information")
            imgui.Separator()

            imgui.Columns(2);

            if imgui.InputText('Location', search.location) then
                local f_location = filtered_list(search.location.v, location_list)

                if f_location[2] == nil and f_location[1] then
                    i_house.location.v = f_location[1]
                end
                get_input()
            end

            if imgui.ListBox('Locations', selected.location, filtered_list(search.location.v, location_list), 6) then
                i_house.location.v = filtered_list(search.location.v, location_list)[selected.location.v + 1]
                get_input()
            end
            imgui.NextColumn()


            imgui.BeginGroup()

            if imgui.RadioButton('NO', check_box["none"].v) then
                i_house.type.v = "none"
                get_input()

                check_box["none"].v = true
                check_box["small"].v = false
                check_box["medium"].v = false
                check_box["big"].v = false
            end

            imgui.SameLine()

            if imgui.RadioButton('Small', check_box["small"].v) then
                i_house.type.v = "small"
                get_input()
                check_box["none"].v = false
                check_box["small"].v = true
                check_box["medium"].v = false
                check_box["big"].v = false
            end

            if imgui.RadioButton('Medium', check_box["medium"].v) then
                i_house.type.v = "medium"
                get_input()
                check_box["none"].v = false
                check_box["small"].v = false
                check_box["medium"].v = true
                check_box["big"].v = false

            end

            imgui.SameLine()
            if imgui.RadioButton('Big', check_box["big"].v) then
                i_house.type.v = "big"
                get_input()
                check_box["none"].v = false
                check_box["small"].v = false
                check_box["medium"].v = false
                check_box["big"].v = true

            end

            imgui.EndGroup()

            imgui.BeginGroup()

              if trade_seleted["trade"].v == "sell" or trade_seleted["trade"].v == "buy" then
              if imgui.Button('No H Price') then
                  i_house.price = "-1"
              end
              if imgui.InputText('H Price', i_house.price) then
                  get_input()
              end

            end
            if imgui.Button('No H ID') then
                i_house.id = "-1"
            end
            if imgui.InputText('H ID', i_house.id) then
                get_input()
            end
            imgui.EndGroup()

        end

        -- bizz
        if property_selected['bizz'].v then
            imgui.Columns(1);
            imgui.Separator()
            imgui.Text("Business Information")
            imgui.Separator()

            imgui.Columns(2);

            if imgui.InputText('Bizz', search.bizz) then

                local f_business = filtered_list(search.bizz.v, bizz_list)

                if f_business[2] == nil and f_business[1] then
                    i_business.type.v = f_business[1]
                end
                get_input()
            end

            if imgui.ListBox('Businesses', selected.business, filtered_list(search.bizz.v, bizz_list), 6) then
                i_business.type.v = filtered_list(search.bizz.v, bizz_list)[selected.business.v + 1]
                get_input()
            end

            if imgui.Button('No B Price') then
                get_input()
                i_business.price.v = "-1"
            end

            if trade_seleted["trade"].v == "sell" or trade_seleted["trade"].v == "buy" then
                if imgui.InputText('B Price', i_business.price) then
                    get_input()
                end
            end
            imgui.NextColumn()

            if imgui.InputText('Location', search.location) then
                local f_location = filtered_list(search.location.v, location_list)

                if f_location[2] == nil and f_location[1] then
                    i_business.location.v = f_location[1]
                end
                get_input()
            end

            if imgui.ListBox('Locations', selected.location, filtered_list(search.location.v, location_list), 6) then
                i_business.location.v = filtered_list(search.location.v, location_list)[selected.location.v + 1]
                get_input()
                printStringNow(i_business.location.v, 1000)
            end

            if imgui.Button('No B ID') then
                i_business.id.v = "-1"
                get_input()
            end
            if imgui.InputText('B ID', i_business.id) then
                get_input()
            end
        end
        imgui.End()
    end
end

function main()
    while true do
        wait(0)
        if wasKeyPressed(key.VK_X) then
          main_window_state.v = not main_window_state.v
        end

        imgui.Process = main_window_state.v
    end
end
