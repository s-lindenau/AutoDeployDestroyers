-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.deploypattern");
require("autodestroy.deployconfig");
require("autodestroy.deployweight");
require("autodestroy.enemyweight");
require("autodestroy.powerarmor");
require("autodestroy.inventory");

local debug_print = false;
local deploy_config = getDeployConfig();

-- validates if we can & should deploy more capsules
-- if so, deploy & consume the capsules
function checkAndDeployFor(player)

    -- validate: player has enough capsules?
    local player_capsule_count = getInventoryCount(player, deploy_config.item_to_consume);
    if (player_capsule_count <= deploy_config.min_capsules_remaining) then
        return
    end

    local max_follower_count = player.force.maximum_following_robot_count;
    local current_follower_count = player.force.get_entity_count(deploy_config.entity_to_deploy); -- TODO: this works FORCE wide (so for all players of same force in MP).
    local max_deploy_count = max_follower_count - current_follower_count;

    -- validate: can we deploy at least 1 capsule?
    if (max_deploy_count < (deploy_config.entity_deploy_per_capsule - deploy_config.max_accepted_wastage)) then
        return;
    end

    -- validate: enemies around player require deployment?
    local enemy_weight = getEnemyWeightAround(player);
    if (enemy_weight <= 0) then
        return;
    end

    local deploy_for_weight = getDeployCountForWeight(enemy_weight, max_follower_count);
    local deploy_to_reach_target = math.max(0, deploy_for_weight - current_follower_count);

    local capsules_to_consume = getCapsuleCount(deploy_to_reach_target, deploy_config.entity_deploy_per_capsule);
    local allowed_capsules_to_consume = math.min(player_capsule_count - deploy_config.min_capsules_remaining, capsules_to_consume)
    local max_capsules_to_throw = getMaxCapsulesToThrow(player, deploy_config);
    local max_allowed_capsules_to_consume = math.min(allowed_capsules_to_consume, max_capsules_to_throw);
    local deploy_count_target = max_allowed_capsules_to_consume * deploy_config.entity_deploy_per_capsule;

    -- validate: after calculating actual deploy count, do we still need to deploy bots?
    deploy_count_target = getWastageCorrectedDeployCount(deploy_to_reach_target, deploy_count_target, deploy_config.max_accepted_wastage, deploy_config.entity_deploy_per_capsule)
    if (deploy_count_target <= 0) then
        return;
    end

    -- all validations passed; start deploying
    local deploy_count = 0;
    local deploy_pattern = getNextDeployPattern();
    local player_position = player.position;

    local deploy_position_offset = deploy_pattern.startPositionOffset;
    local start_position = getNextDeployPosition(player_position, deploy_position_offset)

    deployEntity(player, deploy_config.entity_to_deploy, start_position);
    deploy_count = deploy_count + 1;

    local deploy_translations = deploy_pattern.translations;
    while (deploy_count < deploy_count_target) do
        for _, translation in pairs(deploy_translations) do
            local repetitions = 0;
            local repeat_count = translation.repeatAmount;
            local translation_offset = translation.translationOffset;

            repeat
                repetitions = repetitions + 1;

                start_position = getNextDeployPosition(start_position, translation_offset)
                if (deploy_count < deploy_count_target) then
                    deployEntity(player, deploy_config.entity_to_deploy, start_position);
                    deploy_count = deploy_count + 1;
                end
            until (repetitions >= repeat_count);
        end
    end

    local consumed_capsules = getCapsuleCount(deploy_count, deploy_config.entity_deploy_per_capsule);
    consumeFromInventory(player, deploy_config.item_to_consume, consumed_capsules, deploy_config.min_capsules_remaining);
    printDebugInfo(player, enemy_weight, deploy_for_weight, deploy_to_reach_target, deploy_config.max_accepted_wastage, deploy_count, player_capsule_count, consumed_capsules)
end

function printDebugInfo(player, enemy_weight, deploy_for_weight, deploy_to_reach_target, max_accepted_wastage, deploy_count, player_capsule_count, consumed_capsules)
    if (debug_print == true) then
        player.print("-- Auto Deploy Debug --")
        player.print("Biter weight in area: " .. enemy_weight);
        player.print("Deploy for weight: " .. deploy_for_weight);
        player.print("Deploy to reach: " .. deploy_to_reach_target);
        player.print("Accepted wastage: " .. max_accepted_wastage)
        player.print("Deployed: " .. deploy_count);
        player.print("Available capsules: " .. player_capsule_count);
        player.print("Capsules consumed: " .. consumed_capsules);
    end
end

function getNextDeployPosition(start_position, translation)
    return {
        x = start_position.x + translation.x,
        y = start_position.y + translation.y
    };
end

function deployEntity(player, item_name, item_position)
    player.surface.create_entity {
        name = item_name,
        position = item_position,
        force = player.force,
        target = player.character
    }
end

function getCapsuleCount(deployed, deploy_per_capsule)
    return math.ceil(deployed / deploy_per_capsule);
end

function getWastageCorrectedDeployCount(deploy_to_reach_target, deploy_count_target, max_accepted_wastage, entity_deploy_per_capsule)
    local wastage = math.max(0, deploy_count_target - deploy_to_reach_target)
    local capsules_wasted = getCapsuleCount(wastage, entity_deploy_per_capsule);
    if (wastage > max_accepted_wastage) then
        return deploy_count_target - (capsules_wasted * entity_deploy_per_capsule);
    end
    return deploy_count_target;
end

function getMaxCapsulesToThrow(player, deploy_config)
    local number_of_launchers = getNumberOfDestroyerLaunchers(player);
    local capsules_cap = deploy_config.max_capsules_per_pass;
    return number_of_launchers * capsules_cap;
end