os.loadAPI("navigation.lua")

coal_energy_value = 80

sapling_slot = 14
bone_meal_slot = 15
fuel_slot = 16

sapping_facing = 'pox_x'
bone_meal_facing = 'neg_x'
fuel_facing = 'neg_y'

function refuel()
    local fuel_deficit = turtle.getFuelLimit() - turtle.getFuelLevel()
    local coal_needed = math.floor(fuel_deficit / coal_energy_value)
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
    navigation.set_facing(sapping_facing)
    turtle.select(sapling_slot)
    turtle.suck(1)
end

function plant_tree()
    navigation.set_facing('pos_y')
    navigation.go_forward(1)
    turtle.select(sapling_slot)
    turtle.place()
    local _, sapling_info = turtle.inspect()
    local grown = false

    turtle.select(bone_meal_slot)
    while not grown do
        turtle.place()
        local _, info = turtle.inspect()
        grown = (sapling_info.name ~= info.name)
    end
end

function main()
    refuel()
    get_bone_meal()
    get_sapling()
    plant_tree()
end

main()
