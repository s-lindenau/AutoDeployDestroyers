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
require("autodestroy.controltiming");
require("autodestroy.recall");
require("autodestroy.tooltip");

-- validates if we can & should deploy more capsules
-- if so, deploy & consume the capsules
function checkAndDeployFor(player)
    local deploy_config = getDeployConfig(player);
    local debug_print = deploy_config.debug_print;
    local debug_print_noise_reduction = canDebugPrintNoisy();

    -- validate: are we in a vehicle going too fast?
    if (isDispatchAllowed(player, deploy_config) == false) then
        if (debug_print and debug_print_noise_reduction) then
            player.print("Auto Deploy disabled: vehicle speed too high");
        end;
        return;
    end;

    local max_follower_count = player.force.maximum_following_robot_count;
    local current_follower_count = getCurrentFollowerCount(player);
    local max_deploy_count = max_follower_count - current_follower_count;

    -- validate: enemies around player require deployment?
    local enemy_weight = getEnemyWeightAround(player, deploy_config);
    -- check if we can recall bots at this moment that are deployed but no longer needed
    checkAndRecallBots(player, deploy_config, enemy_weight, current_follower_count);
    if (enemy_weight <= 0) then
        if (debug_print and debug_print_noise_reduction) then
            player.print("Auto Deploy disabled: not enough enemies in range");
        end;
        return;
    end

    -- validate: player has enough capsules?
    local player_capsule_count_destroyer = getInventoryCount(player, deploy_config.item_to_consume_destroyer);
    local player_capsule_count_distractor = getInventoryCount(player, deploy_config.item_to_consume_distractor);
    local player_capsule_count_defender = getInventoryCount(player, deploy_config.item_to_consume_defender);
    local has_not_enough_destroyers = player_capsule_count_destroyer <= deploy_config.min_capsules_remaining;
    local has_not_enough_distractors = player_capsule_count_distractor <= deploy_config.min_capsules_remaining;
    local has_not_enough_defenders = player_capsule_count_defender <= deploy_config.min_capsules_remaining;
    if (has_not_enough_destroyers and has_not_enough_distractors and has_not_enough_defenders) then
        if (debug_print and debug_print_noise_reduction) then
            player.print("Auto Deploy disabled: not enough capsules in inventory");
        end;
        return
    end

    -- validate: can we deploy at least 1 capsule based on Max Follower Count vs Current Follower Count?
    local can_not_deploy_destroyers = max_deploy_count < math.max(1, deploy_config.entity_deploy_per_capsule_destroyer - deploy_config.max_accepted_wastage);
    local can_not_deploy_distractors = max_deploy_count < math.max(1,deploy_config.entity_deploy_per_capsule_distractor - deploy_config.max_accepted_wastage);
    local can_not_deploy_defenders = max_deploy_count < math.max(1, deploy_config.entity_deploy_per_capsule_defender - deploy_config.max_accepted_wastage);
    if (can_not_deploy_destroyers and can_not_deploy_distractors and can_not_deploy_defenders) then
        if (debug_print and debug_print_noise_reduction) then
            player.print("Auto Deploy disabled: max (acceptable) follower count reached");
        end;
        return;
    end

    local aggression_factor = math.max(0, deploy_config.aggression_factor);

    if debug_print then
        player.print("--- [Auto Deploy Debug] ---")
        player.print("Biter weight in area: " .. enemy_weight);
        player.print("Aggression Factor: " .. aggression_factor);
    end

    -- Destroyers first
    if debug_print then
       player.print(" - Destroyers - ");
    end
    local deploy_destroyers_context = {
        aggression_factor = aggression_factor,
        entity_deploy_per_capsule = deploy_config.entity_deploy_per_capsule_destroyer,
        entity_to_deploy = deploy_config.entity_to_deploy_destroyer,
        item_to_consume = deploy_config.item_to_consume_destroyer,
        max_follower_count = max_follower_count,
        current_follower_count = getCurrentFollowerCount(player), -- recalculate follower count, may have changed
        enemy_weight = enemy_weight,
        player_capsule_count = player_capsule_count_destroyer,
        getDeployCountForWeightFunction = getDeployCountForWeightDestroyer,
        getNumberOfLaunchersFunction = getNumberOfDestroyerLaunchers,
        tooltip_offset = 0,
    }
    checkAndDeployCapsules(player, deploy_config, deploy_destroyers_context)

    if debug_print then
       player.print(" - Defenders - ");
    end
    local deploy_defenders_context = {
        aggression_factor = aggression_factor,
        entity_deploy_per_capsule = deploy_config.entity_deploy_per_capsule_defender,
        entity_to_deploy = deploy_config.entity_to_deploy_defender,
        item_to_consume = deploy_config.item_to_consume_defender,
        max_follower_count = max_follower_count,
        current_follower_count = getCurrentFollowerCount(player), -- recalculate follower count, may have changed
        enemy_weight = enemy_weight,
        player_capsule_count = player_capsule_count_defender,
        getDeployCountForWeightFunction = getDeployCountForWeightDefender,
        getNumberOfLaunchersFunction = getNumberOfDefenderLaunchers,
        tooltip_offset = 1,
    }
    checkAndDeployCapsules(player, deploy_config, deploy_defenders_context)

    -- Distractors are not following bots, so only as last resort.
    -- Distractors do not get counted for the player following bots, so we can't really (easily) monitor how many are currently deployed.
    -- This would require another area filter with surface.find_entities_filtered, but those are quite expensive resource wise
    -- Distractors will be deployed at the current player position, and remain there until depleted.
    if debug_print then
       player.print(" - Distractors - ");
    end
    local deploy_distractors_context = {
        aggression_factor = aggression_factor,
        entity_deploy_per_capsule = deploy_config.entity_deploy_per_capsule_distractor,
        entity_to_deploy = deploy_config.entity_to_deploy_distractor,
        item_to_consume = deploy_config.item_to_consume_distractor,
        max_follower_count = max_follower_count,
        current_follower_count = getCurrentFollowerCount(player), -- recalculate follower count, may have changed
        enemy_weight = enemy_weight,
        player_capsule_count = player_capsule_count_distractor,
        getDeployCountForWeightFunction = getDeployCountForWeightDistractor,
        getNumberOfLaunchersFunction = getNumberOfDistractorLaunchers,
        tooltip_offset = 2,
    }
    checkAndDeployCapsules(player, deploy_config, deploy_distractors_context)
end

function checkAndDeployCapsules(player, deploy_config, deploy_capsule_context)
    local debug_print = deploy_config.debug_print;

    local aggression_factor = deploy_capsule_context.aggression_factor;
    local enemy_weight = deploy_capsule_context.enemy_weight;
    local entity_deploy_per_capsule = deploy_capsule_context.entity_deploy_per_capsule;
    local entity_to_deploy = deploy_capsule_context.entity_to_deploy;
    local item_to_consume = deploy_capsule_context.item_to_consume;
    local max_follower_count = deploy_capsule_context.max_follower_count;
    local player_capsule_count = deploy_capsule_context.player_capsule_count;
    local current_follower_count = deploy_capsule_context.current_follower_count;
    local tooltip_offset = deploy_capsule_context.tooltip_offset;

    -- check if we have launchers for the current bot type
    if deploy_capsule_context.getNumberOfLaunchersFunction(player) < 1 then
        if debug_print then
            player.print("No launchers for bot type in armor: " .. entity_to_deploy);
        end
        return;
    end;

    -- calculate the desired bot count - with no regards for limits
    local destroyers_for_weight = deploy_capsule_context.getDeployCountForWeightFunction(enemy_weight);
    destroyers_for_weight = math.ceil(destroyers_for_weight * aggression_factor);

    if debug_print then
        player.print("Bots [" .. entity_to_deploy .. "] for weight: " .. destroyers_for_weight .. " (not limited)")
    end

    -- limit the bot count to the player's max follower count
    local target_destroyer_count = math.min(destroyers_for_weight, max_follower_count)
    if debug_print then
        player.print("Target [" .. entity_to_deploy .. "] count: " .. target_destroyer_count .. " (max followers " .. max_follower_count .. ")")
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

    local capsules_to_reach_target = getCapsuleCount(deploy_to_reach_target, entity_deploy_per_capsule)
    if debug_print then
        player.print("Capsules to reach target: " .. capsules_to_reach_target)
    end

    -- capsules are multiples of entity_deploy_per_capsule (per bot type} (i.e. 5), and capsules_to_reach_target is rounded up.
    -- check if this would waste too many by exceeding the follower limit
    local final_follower_count = current_follower_count + capsules_to_reach_target * entity_deploy_per_capsule;
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

    local max_capsules_per_pass = getMaxCapsulesToThrow(player, deploy_config, deploy_capsule_context.getNumberOfLaunchersFunction)
    if (allowed_capsules_to_consume > max_capsules_per_pass) then
        allowed_capsules_to_consume = max_capsules_per_pass
        if debug_print then
            player.print("Max capsules per pass limit exceeded - limiting to " .. max_capsules_per_pass)
        end
    end
    local deploy_count_target = allowed_capsules_to_consume * entity_deploy_per_capsule;

    if debug_print then
        player.print("Deploy count target: " .. deploy_count_target .. " (" .. allowed_capsules_to_consume .. " capsules * " .. entity_deploy_per_capsule .. ")")
    end

    if allowed_capsules_to_consume <= 0 then
        if debug_print then
            player.print("*** Allowed capsules to reach target is zero - do nothing")
        end
        return;
    end

    -- all validations passed; start deploying
    local deploy_count = 0;
    local deploy_pattern = getNextDeployPattern();
    local player_position = player.position;

    if debug_print then
        player.print("Selected deploy pattern: " .. deploy_pattern.name);
    end

    local deploy_position_offset = deploy_pattern.startPositionOffset;
    local start_position = getNextDeployPosition(player_position, deploy_position_offset)

    deployEntity(player, entity_to_deploy, start_position);
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
                    deployEntity(player, entity_to_deploy, start_position);
                    deploy_count = deploy_count + 1;
                end
            until (repetitions >= repeat_count);
        end
    end

    local consumed_capsules = getCapsuleCount(deploy_count, entity_deploy_per_capsule);
    local total_consumed = consumeFromInventory(player, item_to_consume, consumed_capsules, deploy_config.min_capsules_remaining);

    if(total_consumed >= 1) then
        showTooltipConsumedSuccessful(player, deploy_config, item_to_consume, total_consumed, tooltip_offset);
        tooltip_offset = tooltip_offset + getTooltipOffsetStep();
    end

    if debug_print then
        player.print("*** Bots all deployed. Consumed capsules: " .. total_consumed)
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

function canDebugPrintNoisy()
    -- Some debug information doesn't need to be printed that often, add a delay factor of {n}
    local noisy_delay_factor = 10;
    local check_per_tick = getCheckPerTick();
    local tick_offset = getTickOffset();
    local check_per_tick_noisy = check_per_tick * noisy_delay_factor;
    return ((game.tick + tick_offset) % check_per_tick_noisy == 0);
end

function getCurrentFollowerCount(player)
    local following_robots = player.following_robots;
    local current_follower_count = #following_robots;
    return current_follower_count;
end