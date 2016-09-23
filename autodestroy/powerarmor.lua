-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

function hasDestroyerLauncher(player)
    local number_of_launchers = getNumberOfDestroyerLaunchers(player);
    return number_of_launchers > 0;
end

function getPowerArmor(player)
    local armor_inventory = player.get_inventory(defines.inventory.player_armor);
    if (armor_inventory.is_empty() == false) then
        local armor = armor_inventory[1];
        if (armor.grid ~= nil) then
            return armor;
        end
    end
    return nil;
end

function getNumberOfDestroyerLaunchers(player)
    local power_armor = getPowerArmor(player);
    local number_of_launchers = 0;
    if (power_armor ~= nil) then
        local all_equipment = power_armor.grid.equipment;
        for _, equipment in pairs(all_equipment) do
            if isDestroyerLauncher(equipment) then
                number_of_launchers = number_of_launchers + 1;
            end
        end
    end
    return number_of_launchers;
end

function isDestroyerLauncher(equipment)
    return getPersonalDestroyerLauncherName() == equipment.name;
end