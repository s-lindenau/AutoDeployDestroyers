-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("graphics.basedir");
require("prototypes.personaldestroyerlauncher");

data:extend({
    {
        type = "technology",
        name = getAutomatedDestroyerDeploymentName(),
        icon = getGraphicsDir() .. "/technology/" .. getAutomatedDestroyerDeploymentName() .. ".png",
        icon_size = 128,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = getPersonalDestroyerLauncherName()
            },
        },
        prerequisites = { "power-armor", "combat-robotics-3" },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"military-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 30
        },
        order = "c-k-d-zz",
    }
});