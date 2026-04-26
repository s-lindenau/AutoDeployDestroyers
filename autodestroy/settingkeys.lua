-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

function getPrefix()
    return "autodestroy_";
end

function getEntityToDeployDestroyerKey()
    return getPrefix() .. "entity_to_deploy"; -- don't add `destroyer` for backwards compatibility
end

function getItemToConsumeDestroyerKey()
    return getPrefix() .. "item_to_consume"; -- don't add `destroyer` for backwards compatibility
end

function getEntityToDeployDistractorKey()
    return getPrefix() .. "entity_to_deploy_distractor";
end

function getItemToConsumeDistractorKey()
    return getPrefix() .. "item_to_consume_distractor";
end

function getEntityToDeployDefenderKey()
    return getPrefix() .. "entity_to_deploy_defender";
end

function getItemToConsumeDefenderKey()
    return getPrefix() .. "item_to_consume_defender";
end

function getEntityToDeployPerCapsuleDestroyerKey()
    return getPrefix() .. "entity_deploy_per_capsule"; -- don't add `destroyer` for backwards compatibility
end

function getEntityToDeployPerCapsuleDistractorKey()
    return getPrefix() .. "entity_deploy_per_capsule_distractor";
end

function getEntityToDeployPerCapsuleDefenderKey()
    return getPrefix() .. "entity_deploy_per_capsule_defender";
end

function getMaxAcceptedWastageKey()
    return getPrefix() .. "max_accepted_wastage";
end

function getMinCapsulesRemainingKey()
    return getPrefix() .. "min_capsules_remaining";
end

function getMaxCapsulesPerPassKey()
    return getPrefix() .. "max_capsules_per_pass";
end

function getAggressionFactorKey()
    return getPrefix() .. "aggression_factor";
end

function getDebugPrintKey()
    return getPrefix() .. "debug_print";
end

function getDebugLogKey()
    return getPrefix() .. "debug_log";
end

function getEnemyVisibilityRangeKey()
    return getPrefix() .. "enemy_visibility_range";
end

function getMaxDispatchVehicleSpeedKey()
    return getPrefix() .. "max_dispatch_vehicle_speed";
end

function getStrictLauncherKey()
    return getPrefix() .. "strict_launcher";
end

function getBotRecallEnabledKey()
    return getPrefix() .. "bot_recall_enabled";
end

function getBotRecallRangeKey()
    return getPrefix() .. "bot_recall_range";
end

function getBotRecallMaxLifetimeKey()
    return getPrefix() .. "bot_recall_max_lifetime";
end

function getTooltipMessagesEnabledKey()
    return getPrefix() .. "tooltip_messages_enabled";
end