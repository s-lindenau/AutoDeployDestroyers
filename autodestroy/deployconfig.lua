-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.settingkeys");

-- Describes what to deploy and the relevant quantities
function getDeployConfig(player)
    local deploy_config_startup = getStartupConfig();
    local deploy_config_player = {
        entity_deploy_per_capsule_destroyer = settings.global[getEntityToDeployPerCapsuleDestroyerKey()].value,
        entity_deploy_per_capsule_distractor = settings.global[getEntityToDeployPerCapsuleDistractorKey()].value,
        entity_deploy_per_capsule_defender = settings.global[getEntityToDeployPerCapsuleDefenderKey()].value,
        max_accepted_wastage = settings.get_player_settings(player)[getMaxAcceptedWastageKey()].value,
        min_capsules_remaining = settings.get_player_settings(player)[getMinCapsulesRemainingKey()].value,
        max_capsules_per_pass = settings.global[getMaxCapsulesPerPassKey()].value,
        aggression_factor = settings.get_player_settings(player)[getAggressionFactorKey()].value,
        debug_print = settings.get_player_settings(player)[getDebugPrintKey()].value,
        debug_log = settings.startup[getDebugLogKey()].value,
        enemy_visibility_range = settings.startup[getEnemyVisibilityRangeKey()].value,
        max_dispatch_vehicle_speed = settings.get_player_settings(player)[getMaxDispatchVehicleSpeedKey()].value,
        strict_launcher = settings.get_player_settings(player)[getStrictLauncherKey()].value,
    }
    return getMergedTables(deploy_config_startup, deploy_config_player);
end

function getStartupConfig()
    return {
        entity_to_deploy_destroyer = settings.startup[getEntityToDeployDestroyerKey()].value,
        item_to_consume_destroyer = settings.startup[getItemToConsumeDestroyerKey()].value,
        entity_to_deploy_distractor = settings.startup[getEntityToDeployDistractorKey()].value,
        item_to_consume_distractor = settings.startup[getItemToConsumeDistractorKey()].value,
        entity_to_deploy_defender = settings.startup[getEntityToDeployDefenderKey()].value,
        item_to_consume_defender = settings.startup[getItemToConsumeDefenderKey()].value,
    }
end

function getMergedTables(deploy_config_startup, deploy_config_player)
    local merged_table = {}
    for key, value in pairs(deploy_config_startup) do
        merged_table[key] = value
    end
    for key, value in pairs(deploy_config_player) do
        merged_table[key] = value
    end
    return merged_table
end