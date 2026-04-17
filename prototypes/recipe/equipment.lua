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
            { type = "item", name = "processing-unit", amount = 25 },
            { type = "item", name = "iron-gear-wheel", amount = 10 },
            { type = "item", name = "steel-plate", amount = 100 },
            { type = "item", name = "electric-engine-unit", amount = 20 }
        },
        results =
        {
            { type = "item", name = getPersonalDestroyerLauncherName(), amount = 1 }
        }
    },
    {
        type = "recipe",
        name = getPersonalDistractorLauncherName(),
        enabled = false,
        energy_required = 10,
        ingredients =
        {
            { type = "item", name = "advanced-circuit", amount = 25 },
            { type = "item", name = "iron-gear-wheel", amount = 10 },
            { type = "item", name = "steel-plate", amount = 100 },
            { type = "item", name = "engine-unit", amount = 15 }
        },
        results =
        {
            { type = "item", name = getPersonalDistractorLauncherName(), amount = 1 }
        }
    },
    {
        type = "recipe",
        name = getPersonalDefenderLauncherName(),
        enabled = false,
        energy_required = 10,
        ingredients =
        {
            { type = "item", name = "electronic-circuit", amount = 25 },
            { type = "item", name = "iron-gear-wheel", amount = 10 },
            { type = "item", name = "steel-plate", amount = 100 },
            { type = "item", name = "engine-unit", amount = 5 }
        },
        results =
        {
            { type = "item", name = getPersonalDefenderLauncherName(), amount = 1 }
        }
    }
});