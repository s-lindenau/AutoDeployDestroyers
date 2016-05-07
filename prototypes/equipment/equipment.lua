-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("graphics.basedir");
require("prototypes.personaldestroyerlauncher");

data:extend({
    {
        type = "movement-bonus-equipment", --not really, but ok.
        name = getPersonalDestroyerLauncherName(),
        sprite =
        {
            filename = getGraphicsDir() .. "/equipment/" .. getPersonalDestroyerLauncherName() .. ".png",
            width = 64,
            height = 64,
            priority = "medium"
        },
        shape =
        {
            width = 2,
            height = 2,
            type = "full"
        },
        energy_source =
        {
            type = "electric",
            usage_priority = "secondary-input"
        },
        energy_consumption = "50kW",
        movement_bonus = 0
    }
});