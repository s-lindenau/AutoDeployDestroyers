-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.settingkeys");

-- Describes what to deploy and the relevant quantities
function getDeployConfig(player)
    return {
        entity_to_deploy = settings.startup[getEntityToDeployKey()].value,
        item_to_consume = settings.startup[getItemToConsumeKey()].value,
        entity_deploy_per_capsule = settings.global[getEntityToDeployPerCapsuleKey()].value,
        max_accepted_wastage = settings.get_player_settings(player)[getMaxAcceptedWastageKey()].value,
        min_capsules_remaining = settings.get_player_settings(player)[getMinCapsulesRemainingKey()].value,
        max_capsules_per_pass = settings.global[getMaxCapsulesPerPassKey()].value,
        aggression_factor = settings.get_player_settings(player)[getAggressionFactorKey()].value,
        debug_print = settings.get_player_settings(player)[getDebugPrintKey()].value,
        debug_log = settings.startup[getDebugLogKey()].value,
        enemy_visibility_range = settings.startup[getEnemyVisibilityRangeKey()].value,
    }
end