-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

-- entity_to_deploy: the actual entity that gets created
-- item_to_consume: the item that gets removed from the inventory
-- entity_deploy_per_capsule: how many entities are spawned from 1 capsule
-- max_accepted_wastage: example:   if the target is 6 entities, and 1 capsule spawns 5, that would be a wastage of 4 entities
--                                  the second capsule is only deployed if the wastage is not above the max accepted wastage
-- min_capsules_remaining: how many capsules should always remain in the player's inventory. Autodeploy stops if this amount (or lower) is reached
-- max_capsules_per_pass: how many capsules 1 launcher may throw per pass. Stacks with multiple launchers in power armor. The default of 100 is oriented at 'unlimited', lower this for a more realistic experience.
-- aggression_factor:   configure the deploy aggression based on the player's playstyle. Default = 1.0, oriented at bot-only warfare.
--                      Lower this value if bots are used as secondary warfare; as support to for example the flamethrower.
--                      Can be any decimal between [0.0, 1.0]. Numbers higher than 1 can be used, however this is not advised as it will waste capsules.
-- debug_print: prints ingame debug information for the player
-- debug_log: writes enemy information to a log file
-- enemy_visibility_range: at what distance do enemies get triggered by the player and attack. This directly affects the scan distance and thus performance!

require("autodestroy.settingkeys");

data:extend({
    {
        type = "string-setting",
        name = getEntityToDeployKey(),
        setting_type = "startup",
        default_value = "destroyer",
        order = "aa"
    },
    {
        type = "string-setting",
        name = getItemToConsumeKey(),
        setting_type = "startup",
        default_value = "destroyer-capsule",
        order = "ab"
    },
    {
        type = "int-setting",
        name = getEntityToDeployPerCapsuleKey(),
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 1,
        order = "ac"
    },
    {
        type = "int-setting",
        name = getMaxAcceptedWastageKey(),
        setting_type = "runtime-per-user",
        default_value = 1,
        minimum_value = 0,
        order = "ad"
    },
    {
        type = "int-setting",
        name = getMinCapsulesRemainingKey(),
        setting_type = "runtime-per-user",
        default_value = 20,
        minimum_value = 0,
        order = "ae"
    },
    {
        type = "int-setting",
        name = getMaxCapsulesPerPassKey(),
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 1,
        order = "af"
    },
    {
        type = "double-setting",
        name = getAggressionFactorKey(),
        setting_type = "runtime-per-user",
        default_value = 1.0,
        minimum_value = 0.0,
        order = "ag"
    },
    {
        type = "bool-setting",
        name = getDebugPrintKey(),
        setting_type = "runtime-per-user",
        default_value = false,
        order = "ah"
    },
    {
        type = "bool-setting",
        name = getDebugLogKey(),
        setting_type = "startup",
        default_value = false,
        order = "ai"
    },
    {
        type = "int-setting",
        name = getEnemyVisibilityRangeKey(),
        setting_type = "startup",
        default_value = 30,
        minimum_value = 1,
        maximum_value = 100,
        order = "aj"
    },
    {
        type = "double-setting",
        name = getMaxDispatchVehicleSpeedKey(),
        setting_type = "runtime-per-user",
        default_value = 0.9,
        minimum_value = 0.0,
        order = "ag"
    },
});