os.loadAPI("navigation.lua")

coal_energy_value = 80

sapling_slot = 14
bone_meal_slot = 15
fuel_slot = 16

sapling_facing = 'pos_x'
bone_meal_facing = 'neg_x'
fuel_facing = 'neg_y'

sapling_info = nil
log_info = nil

function refuel()
    local fuel_deficit = turtle.getFuelLimit() - turtle.getFuelLevel()
    local coal_needed = math.floor(fuel_deficit / coal_energy_value)
    coal_needed = math.min(coal_needed, 64)
    print(string.format('Fuel Deficit: %d, Coal: %d', fuel_deficit, coal_needed))
    if coal_needed == 0 then
        return
    end

    print('Getting fuel')
    navigation.set_facing(fuel_facing)
    turtle.select(fuel_slot)
    turtle.suck(coal_needed)
    turtle.refuel(coal_needed)
    turtle.drop()
end

function get_bone_meal()
    local item_deficit = turtle.getItemSpace(bone_meal_slot)
    print(string.format('Bone Meal Deficit: %d', item_deficit))
    if item_deficit == 0 then
        return
    end

    print('Getting bone meal')
    navigation.set_facing(bone_meal_facing)
    turtle.select(bone_meal_slot)
    turtle.suck(item_deficit)
end

function get_sapling()
    if turtle.getItemCount(sapling_slot) > 0 then
        return
    end

    print('Getting sapling')
    navigation.set_facing(sapling_facing)
    turtle.select(sapling_slot)
    turtle.suck(1)
    if sapling_info == nil then
        sapling_info = turtle.getItemDetail(sapling_slot)
    end
end

function plant_tree()
    navigation.set_facing('pos_y')
    navigation.go_forward(1)
    turtle.select(sapling_slot)
    turtle.place()
    local grown = false

    turtle.select(bone_meal_slot)
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
end

function return_logs()
    navigation.go_to(vector.new(0, 0, 3))
    navigation.set_facing('neg_y')
    for i = 1, 16 do
        local detail = turtle.getItemDetail(i)
        if detail == nil or (detail.name == log_info.name) then
            turtle.select(i)
            turtle.drop(detail.count)
        end
    end
end

function main()
    refuel()
    get_bone_meal()
    get_sapling()
    plant_tree()
    cut_tree()
    return_logs()
    navigation.go_to(vector.new(0, 0, 0))
end

while true do
    main()
end
