-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("prototypes.personaldestroyerlauncher");

data:extend({
    {
        type = "recipe",
        name = getPersonalDestroyerLauncherName(),
        enabled = false,
        energy_required = 10,
        ingredients =
        {
            { "processing-unit", 25 },
            { "iron-gear-wheel", 10 },
            { "steel-plate", 100 },
            { "electric-engine-unit", 20 },
        },
        result = getPersonalDestroyerLauncherName()
    }
});