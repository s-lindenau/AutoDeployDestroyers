-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.vehicle");

local vehicle_trunk_inventory = 2; -- defines.inventory.player_vehicle (7) doesn't work?

-- return the total amount of the given item in the players inventories
function getInventoryCount(player, item)
    local quickbar_count = getCount(player, defines.inventory.player_quickbar, item);
    local inventory_count = getCount(player, defines.inventory.player_main, item);
    local vehicle_count = 0;
    if (isInSupportedVehicle(player)) then
        vehicle_count = getCount(player.vehicle, vehicle_trunk_inventory, item);
    end
    return quickbar_count + inventory_count + vehicle_count;
end

-- consume the given item from the players available inventories
-- priority:
-- 1. Vehicle trunk
-- 2. Main Inventory
-- 3. Quickbar
-- This method does no validations, it expects the calling method to check availability (including min_remaining!)
function consumeFromInventory(player, consume_item, consume_count, min_remaining)
    local consume_remaining = consume_count;

    if (isInSupportedVehicle(player)) then
        local consumed = consume(player.vehicle, consume_item, consume_remaining, vehicle_trunk_inventory);
        consume_remaining = consume_remaining - consumed;
    end

    if (consume_remaining > 0) then
        local consumed = consume(player, consume_item, consume_remaining, defines.inventory.player_main);
        consume_remaining = consume_remaining - consumed;
    end

    if (consume_remaining > 0) then
        local consumed = consume(player, consume_item, consume_remaining, defines.inventory.player_quickbar);
        consume_remaining = consume_remaining - consumed;
    end

    -- WARN player when lower limit reached
    local remaining_count = getInventoryCount(player, consume_item);
    if (remaining_count <= min_remaining) then
        player.print("Warning: " .. consume_item .. " count is running low. Only " .. remaining_count .. " left! Please restock for auto-deploy.")
    end
end

-- consume (item * amount) from the given inventory
-- return the actual amount consumed
function consume(entity, consume_item, consume_amount, inventory_index)
    local inventory_count = getCount(entity, inventory_index, consume_item);
    local to_consume_count = math.min(inventory_count, consume_amount);
    if (to_consume_count > 0) then
        return consumeStack(entity, inventory_index, consume_item, to_consume_count)
    else
        return 0;
    end
end

-- api call: LuaInventory.html#remove
function consumeStack(entity, inventory_index, consume_item, consume_amount)
    local inventory = entity.get_inventory(inventory_index);
    local stackToRemove = {
        name = consume_item,
        count = consume_amount
    };
    return inventory.remove(stackToRemove);
end

-- return the amount of the given item in the specific inventory
function getCount(entity, inventory_index, item)
    local entity_inventory = entity.get_inventory(inventory_index);
    if (entity_inventory ~= nil) then
        return entity_inventory.get_item_count(item);
    else
        return 0;
    end;
end