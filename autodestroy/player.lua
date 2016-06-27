-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("prototypes.personaldestroyerlauncher");

-- only deploy for players that have an active character in the game world
function autoDeployActiveFor(player)
    if (isConnected(player)) then
        if (isCharacter(player)) then
            if (hasDestroyerLauncher(player)) then
                return true;
            end
        end
    end
    return false;
end

function isConnected(player)
    return player.connected;
end

function isCharacter(player)
    return player.controller_type == defines.controllers.character;
end

function hasDestroyerLauncher(player)
    local armor_inventory = player.get_inventory(defines.inventory.player_armor);
    local power_armor = getPowerArmor(armor_inventory);

    if (hasDestroyerLauncherEquipment(power_armor)) then
        return true;
    else
        return false;
    end
end

function getPowerArmor(armor_inventory)
    if (armor_inventory.is_empty() == false) then
        local armor = armor_inventory[1];
        if (armor.has_grid == true) then
            return armor;
        end
    end
    return nil;
end

function hasDestroyerLauncherEquipment(power_armor)
    if (power_armor ~= nil) then
        local all_equipment = power_armor.grid.equipment;
        for _, equipment in pairs(all_equipment) do
            if isDestroyerLauncher(equipment) then
                return true;
            end
        end
    end
    return false;
end

function isDestroyerLauncher(equipment)
    return getPersonalDestroyerLauncherName() == equipment.name;
end
