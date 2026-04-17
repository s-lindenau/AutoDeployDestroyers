-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.settingkeys");

data:extend({
    {
        type = "string-setting",
        name = getEntityToDeployDestroyerKey(),
        setting_type = "startup",
        default_value = "destroyer",
        order = "aaa"
    },
    {
        type = "string-setting",
        name = getItemToConsumeDestroyerKey(),
        setting_type = "startup",
        default_value = "destroyer-capsule",
        order = "aab"
    },
    {
        type = "string-setting",
        name = getEntityToDeployDistractorKey(),
        setting_type = "startup",
        default_value = "distractor",
        order = "aba"
    },
    {
        type = "string-setting",
        name = getItemToConsumeDistractorKey(),
        setting_type = "startup",
        default_value = "distractor-capsule",
        order = "abb"
    },
    {
        type = "string-setting",
        name = getEntityToDeployDefenderKey(),
        setting_type = "startup",
        default_value = "defender",
        order = "aca"
    },
    {
        type = "string-setting",
        name = getItemToConsumeDefenderKey(),
        setting_type = "startup",
        default_value = "defender-capsule",
        order = "acb"
    },
    {
        type = "int-setting",
        name = getEntityToDeployPerCapsuleDestroyerKey(),
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 1,
        order = "aca"
    },
    {
        type = "int-setting",
        name = getEntityToDeployPerCapsuleDistractorKey(),
        setting_type = "runtime-global",
        default_value = 3,
        minimum_value = 1,
        order = "acb"
    },
    {
        type = "int-setting",
        name = getEntityToDeployPerCapsuleDefenderKey(),
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        order = "acc"
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
        order = "ak"
    },
    {
        type = "bool-setting",
        name = getStrictLauncherKey(),
        setting_type = "runtime-per-user",
        default_value = true,
        order = "al"
    },
});