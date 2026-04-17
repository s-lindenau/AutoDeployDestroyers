-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("graphics.basedir");
require("prototypes.personaldestroyerlauncher");

data:extend({
    {
        type = "item",
        name = getPersonalDestroyerLauncherName(),
        icon = getGraphicsDir() .. "/icons/" .. getPersonalDestroyerLauncherName() .. ".png",
        icon_size = 32,
        place_as_equipment_result = getPersonalDestroyerLauncherName(),
        subgroup = "equipment",
        order = "f[" .. getPersonalDestroyerLauncherName() .. "]-a[" .. getPersonalDestroyerLauncherName() .. "]",
        stack_size = 5
    },
    {
        type = "item",
        name = getPersonalDistractorLauncherName(),
        icon = getGraphicsDir() .. "/icons/" .. getPersonalDistractorLauncherName() .. ".png",
        icon_size = 32,
        place_as_equipment_result = getPersonalDistractorLauncherName(),
        subgroup = "equipment",
        order = "f[" .. getPersonalDistractorLauncherName() .. "]-a[" .. getPersonalDistractorLauncherName() .. "]",
        stack_size = 5
    },
    {
        type = "item",
        name = getPersonalDefenderLauncherName(),
        icon = getGraphicsDir() .. "/icons/" .. getPersonalDefenderLauncherName() .. ".png",
        icon_size = 32,
        place_as_equipment_result = getPersonalDefenderLauncherName(),
        subgroup = "equipment",
        order = "f[" .. getPersonalDefenderLauncherName() .. "]-a[" .. getPersonalDefenderLauncherName() .. "]",
        stack_size = 5
    }
});