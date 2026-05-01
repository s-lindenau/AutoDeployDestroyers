-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("prototypes.personaldestroyerlauncher");

function hasAutoLauncher(player)
    local number_of_destroyer_launchers = getNumberOfDestroyerLaunchers(player, true);
    local number_of_distractor_launchers = getNumberOfDistractorLaunchers(player, true);
    local number_of_defender_launchers = getNumberOfDefenderLaunchers(player, true);
    local total_number_of_launchers = number_of_destroyer_launchers + number_of_distractor_launchers + number_of_defender_launchers;
    return total_number_of_launchers > 0;
end

function getGridArmor(player)
    local armor_inventory = player.get_inventory(defines.inventory.character_armor);
    if (armor_inventory.is_empty() == false) then
        local armor = armor_inventory[1];
        if (armor.grid ~= nil) then
            return armor;
        end
    end
    return nil;
end

function getNumberOfDestroyerLaunchers(player, is_strict_launcher)
    local grid_armor = getGridArmor(player);
    local number_of_destroyer_launchers = getNumberOfArmorItemsMatchingName(grid_armor, isDestroyerLauncher);
    if not is_strict_launcher then
        -- nothing here, as there currently are no bot types 'above' destroyers, but the function signature requires it
    end
    return number_of_destroyer_launchers;
end

function getNumberOfDistractorLaunchers(player, is_strict_launcher)
    local grid_armor = getGridArmor(player);
    local number_of_distractor_launchers = getNumberOfArmorItemsMatchingName(grid_armor, isDistractorLauncher);
    if not is_strict_launcher then
        local number_of_destroyer_launchers = getNumberOfDestroyerLaunchers(player, true);
        local number_of_defender_launchers = getNumberOfDefenderLaunchers(player, true);
        number_of_distractor_launchers = number_of_distractor_launchers + number_of_destroyer_launchers + number_of_defender_launchers;
    end
    return number_of_distractor_launchers;
end

function getNumberOfDefenderLaunchers(player, is_strict_launcher)
    local grid_armor = getGridArmor(player);
    local number_of_defender_launchers = getNumberOfArmorItemsMatchingName(grid_armor, isDefenderLauncher);
    if not is_strict_launcher then
        local number_of_destroyer_launchers = getNumberOfDestroyerLaunchers(player, true);
        number_of_defender_launchers = number_of_defender_launchers + number_of_destroyer_launchers;
    end
    return number_of_defender_launchers;
end

function getNumberOfArmorItemsMatchingName(grid_armor, isTargetArmorEquipmentFunction)
    local number_of_launchers = 0;
    if (grid_armor ~= nil) then
        local all_equipment = grid_armor.grid.equipment;
        for _, equipment in pairs(all_equipment) do
            if isTargetArmorEquipmentFunction(equipment) then
                number_of_launchers = number_of_launchers + 1;
            end
        end
    end
    return number_of_launchers;
end

function isDestroyerLauncher(equipment)
    return getPersonalDestroyerLauncherName() == equipment.name;
end

function isDistractorLauncher(equipment)
    return getPersonalDistractorLauncherName() == equipment.name;
end

function isDefenderLauncher(equipment)
    return getPersonalDefenderLauncherName() == equipment.name;
end

function getMaxCapsulesToProcess(player, deploy_config, getNumberOfLaunchersFunction)
    local is_strict_launcher = deploy_config.strict_launcher;
    local number_of_launchers = getNumberOfLaunchersFunction(player, is_strict_launcher);
    local capsules_cap = deploy_config.max_capsules_per_pass;
    return number_of_launchers * capsules_cap;
end