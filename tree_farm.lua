os.loadAPI("navigation.lua")
local interface = peripheral.wrap("back")
local chest = peripheral.wrap("bottom")

local coal_energy_value = 80

local interface_slots = {
    fuel = 1,
    sapling = 2,
    bone_meal = 3
}

local turtle_slots = {
    fuel = 14,
    sapling = 15,
    bone_meal = 16
}

local sapling_info = nil
local log_info = nil

function refuel()
    local fuel_deficit = turtle.getFuelLimit() - turtle.getFuelLevel()
    local coal_needed = math.floor(fuel_deficit / coal_energy_value)
    coal_needed = math.min(coal_needed, 64)
    if coal_needed == 0 then
        return
    end

    interface.pushItems(peripheral.getName(chest), interface_slots.fuel, coal_needed)
    turtle.select(turtle_slots.fuel)
    turtle.suckDown(coal_needed)
    turtle.refuel(coal_needed)
end

function get_bone_meal()
    local item_deficit = turtle.getItemSpace(turtle_slots.bone_meal)
    if item_deficit == 0 then
        return
    end

    interface.pushItems(peripheral.getName(chest), interface_slots.bone_meal, item_deficit)
    turtle.select(turtle_slots.bone_meal)
    turtle.suckDown(item_deficit)
end

function get_sapling()
    if turtle.getItemCount(turtle_slots.sapling) > 0 then
        return
    end

    interface.pushItems(peripheral.getName(chest), interface_slots.sapling, 1)
    turtle.select(turtle_slots.sapling)
    turtle.suckDown(1)

    if sapling_info == nil then
        sapling_info = turtle.getItemDetail(turtle_slots.sapling)
    end
end

function plant_tree()
    navigation.turn_to('pos_x')
    navigation.go_forward(2)
    turtle.select(turtle_slots.sapling)
    turtle.place()
    local grown = false

    turtle.select(turtle_slots.bone_meal)
    while not grown do
        turtle.place()
        local _, info = turtle.inspect()
        grown = (sapling_info.name ~= info.name)
    end
end

function cut_tree()
    if log_info == nil then
        _, log_info = turtle.inspect()
    end

    turtle.select(1)
    turtle.dig()
    navigation.go_forward(1)

    local done = false
    while not done do
        turtle.digUp()
        navigation.go_up(1)
        local _, info = turtle.inspectUp()
        done = (log_info.name ~= info.name)
    end

    turtle.dropDown()
end

function return_logs()
    navigation.go_to(vector.new(0, 0, 3))
    navigation.turn_to('neg_x')
    for i = 1, 16 do
        local detail = turtle.getItemDetail(i)
        if detail ~= nil and (detail.name == log_info.name) then
            turtle.select(i)
            turtle.drop(detail.count)
        end
    end
end

function main()
    interface = peripheral.wrap("back")
    chest = peripheral.wrap("bottom")
    refuel()
    get_bone_meal()
    get_sapling()
    plant_tree()
    cut_tree()
    -- return_logs()
    navigation.go_to(vector.new(0, 0, 0))
    navigation.turn_to('pos_x')
end

while true do
    main()
end
