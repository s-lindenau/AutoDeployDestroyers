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
        placed_as_equipment_result = getPersonalDestroyerLauncherName(),
        flags = { "goes-to-main-inventory" },
        subgroup = "equipment",
        order = "f[" .. getPersonalDestroyerLauncherName() .. "]-a[" .. getPersonalDestroyerLauncherName() .. "]",
        stack_size = 5
    }
});