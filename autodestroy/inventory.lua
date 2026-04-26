-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.vehicle");

-- return the total amount of the given item in the players inventories
function getInventoryCount(player, item)
    local inventory_count = getCount(player, defines.inventory.character_main, item);
    local vehicle_count = 0;
    if (isInSupportedVehicle(player)) then
        vehicle_count = getCount(player.vehicle, defines.inventory.car_trunk, item);
    end
    return inventory_count + vehicle_count;
end

-- consume the given item from the players available inventories
-- This method does no validations, it expects the calling method to check availability (including min_remaining!)
-- This method returns the successful removed amount so calling logic can postprocess
function consumeFromInventory(player, consume_item, consume_count, min_remaining)
    remaining_to_consume = processPlayerInventories(player, consume_item, consume_count, consume);

    -- WARN player when lower limit reached
    local remaining_count = getInventoryCount(player, consume_item);
    if (remaining_count <= min_remaining) then
        player.print("Warning: " .. consume_item .. " count is running low. Only " .. remaining_count .. " left! Please restock for auto-deploy.")
    end

    local consumed_count = consume_count - remaining_to_consume;
    return consumed_count;
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
    local consumed_amount = inventory.remove(stackToRemove);
    return consumed_amount;
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

-- insert the given item into the players available inventories
-- This method only validates available inventory space, it expects the calling method to check if insert is functionally allowed
-- This method also does not remove any other game entities, it returns the successful insertion amount so calling logic can postprocess
function insertIntoInventory(player, insert_item, insert_count)
    local remaining_count = processPlayerInventories(player, insert_item, insert_count, insert);
    local inserted_count = insert_count - remaining_count;
    return inserted_count;
end

-- api call: LuaInventory.html#can_insert
-- api call: LuaInventory.html#insert
-- return the actual amount inserted
function insert(entity, insert_item, insert_amount, inventory_index)
    local inventory = entity.get_inventory(inventory_index);
    local insert_stack = {
        name = insert_item,
        count = insert_amount
    }
    local can_insert = inventory.can_insert(insert_stack);
    if not can_insert then
        return 0;
    end;

    local inserted_amount = inventory.insert(insert_stack);
    return inserted_amount;
end

-- Consume or Insert from/to player inventory. Priority:
-- 1. Vehicle trunk
-- 2. Main Inventory
-- returns the remaining amount (when not all amounts requested could be processed)
function processPlayerInventories(player, item, amount, inventoryFunction)
    local remaining = amount;
    -- first: process car trunk if available
    if (isInSupportedVehicle(player)) then
        local amount_processed = inventoryFunction(player.vehicle, item, remaining, defines.inventory.car_trunk);
        remaining = remaining - amount_processed;
    end

    -- second: process player main inventory if still needed
    if (remaining > 0) then
        local amount_processed = inventoryFunction(player, item, remaining, defines.inventory.character_main);
        remaining = remaining - amount_processed;
    end
    return remaining;
end