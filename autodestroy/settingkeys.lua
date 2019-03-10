-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

function getPrefix()
    return "autodestroy_";
end

function getEntityToDeployKey()
    return getPrefix() .. "entity_to_deploy";
end

function getItemToConsumeKey()
    return getPrefix() .. "item_to_consume";
end

function getEntityToDeployPerCapsuleKey()
    return getPrefix() .. "entity_deploy_per_capsule";
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

function getEnemyVisibilityRange()
    return getPrefix() .. "enemy_visibility_range";
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
