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

-- validates if we can & should deploy more capsules
-- if so, deploy & consume the capsules
function checkAndDeployFor(player)
    local deploy_config = getDeployConfig(player);
    local debug_print = deploy_config.debug_print;

    -- validate: are we in a vehicle going too fast?
    if (isDispatchAllowed(player, deploy_config) == false) then
        if (debug_print) then
            player.print("Auto Deploy disabled: vehicle speed too high");
        end;
        return;
    end;

    -- validate: player has enough capsules?
    local player_capsule_count = getInventoryCount(player, deploy_config.item_to_consume);
    if (player_capsule_count <= deploy_config.min_capsules_remaining) then
        return
    end

    local max_follower_count = player.force.maximum_following_robot_count;
    local following_robots = player.following_robots;
    local current_follower_count = #following_robots;
    local max_deploy_count = max_follower_count - current_follower_count;

    -- validate: can we deploy at least 1 capsule?
    if (max_deploy_count < (deploy_config.entity_deploy_per_capsule - deploy_config.max_accepted_wastage)) then
        return;
    end

    -- validate: enemies around player require deployment?
    local enemy_weight = getEnemyWeightAround(player, deploy_config);
    if (enemy_weight <= 0) then
        return;
    end

    -- calculate the desired destroyer count - with no regards for limits
    local aggression_factor = math.max(0, deploy_config.aggression_factor);
    local destroyers_for_weight = getDeployCountForWeight(enemy_weight);
    destroyers_for_weight = math.ceil(destroyers_for_weight * aggression_factor);

    if debug_print then
        player.print("-- Auto Deploy Debug --")
        player.print("Biter weight in area: " .. enemy_weight .. " health")
        player.print("Aggression Factor: " .. aggression_factor);
        player.print("Destroyers for weight: " .. destroyers_for_weight .. " (not limited)")
    end

    -- limit the destroyer count to the player's max follower count
    local target_destroyer_count = math.min(destroyers_for_weight, max_follower_count)
    if debug_print then
        player.print("Target destroyer count: " .. target_destroyer_count .. " (max followers " .. max_follower_count .. ")")
    end

    local deploy_to_reach_target = math.max(0, target_destroyer_count - current_follower_count)

    if debug_print then
        player.print("Current follower count: " .. current_follower_count .. ", deploy to reach target: " .. deploy_to_reach_target)
    end

    -- validate: if nothing needs to be deployed, stop early
    if (deploy_to_reach_target <= 0) then
        if debug_print then
            player.print("*** Deploy to reach target is zero - do nothing")
        end
        return
    end

    local capsules_to_reach_target = getCapsuleCount(deploy_to_reach_target, deploy_config.entity_deploy_per_capsule)
    if debug_print then
        player.print("Capsules to reach target: " .. capsules_to_reach_target)
    end

    -- capsules are multiples of deploy_config.entity_deploy_per_capsule (i.e. 5), and capsules_to_reach_target is rounded up.
    -- check if this would waste too many by exceeding the follower limit
    local final_follower_count = current_follower_count + capsules_to_reach_target * deploy_config.entity_deploy_per_capsule
    if (final_follower_count > max_follower_count + deploy_config.max_accepted_wastage) then
        capsules_to_reach_target = capsules_to_reach_target - 1
        if debug_print then
            player.print("Final follower count would be " .. final_follower_count .. ", exceeding max followers " .. max_follower_count .. " + wastage " .. deploy_config.max_accepted_wastage)
            player.print("- Reducing capsules to reach target to " .. capsules_to_reach_target)
        end
    else
        if debug_print then
            player.print("Final follower count will be " .. final_follower_count .. " (including wastage " .. deploy_config.max_accepted_wastage .. ")")
        end
    end

    if (capsules_to_reach_target <= 0) then
        if debug_print then
            player.print("*** Capsules to reach target is zero - do nothing")
        end
        return
    end

    local allowed_capsules_to_consume = math.min(player_capsule_count - deploy_config.min_capsules_remaining, capsules_to_reach_target)
    if debug_print then
        player.print("Allowed capsules to consume: " .. allowed_capsules_to_consume .. " (inventory capsule count: " .. player_capsule_count .. ", min remaining " .. deploy_config.min_capsules_remaining .. ")")
    end

    local max_capsules_per_pass = getMaxCapsulesToThrow(player, deploy_config)
    if (allowed_capsules_to_consume > max_capsules_per_pass) then
        allowed_capsules_to_consume = max_capsules_per_pass
        if debug_print then
            player.print("Max capsules per pass limit exceeded - limiting to " .. max_capsules_per_pass)
        end
    end
    local deploy_count_target = allowed_capsules_to_consume * deploy_config.entity_deploy_per_capsule

    if debug_print then
        player.print("Deploy count target: " .. deploy_count_target .. " (" .. allowed_capsules_to_consume .. " capsules * " .. deploy_config.entity_deploy_per_capsule .. ")")
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

    if debug_print then
        player.print("*** Destroyers all deployed. Consumed capsules: " .. consumed_capsules)
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

function getMaxCapsulesToThrow(player, deploy_config)
    local number_of_launchers = getNumberOfDestroyerLaunchers(player);
    local capsules_cap = deploy_config.max_capsules_per_pass;
    return number_of_launchers * capsules_cap;
end

function isDispatchAllowed(player, deploy_config)
    if (player.vehicle ~= nil) then
        local vehicle_speed = player.vehicle.speed;
        if (vehicle_speed == nil) then
            vehicle_speed = 0;
        end
        local max_dispatch_vehicle_speed = deploy_config.max_dispatch_vehicle_speed;
        return math.abs(vehicle_speed) < max_dispatch_vehicle_speed;
    end;
    return true;
end