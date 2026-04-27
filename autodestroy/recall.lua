-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.inventory");
require("autodestroy.tooltip");
require("autodestroy.powerarmor");
require("autodestroy.printf");

-- Perform a 'Total Recall' of active bots when the battle has ended
function checkAndRecallBots(player, deploy_config, enemy_weight, current_follower_count)
    local debug_print = deploy_config.debug_print;

    -- still enemies in range? wait with recall
    if (enemy_weight > 0) then
        return;
    end

    -- no more enemies, check if we have following bots to recall
    if (current_follower_count <= 0) then
        return;
    end

    -- player disabled recall functionality?
    local recall_enabled = deploy_config.recall_enabled;
    if not recall_enabled then
        if (debug_print) then
            player.print(" -- Recall: conditions met but disabled in settings")
        end
        return;
    end

    -- find bots in range to recall. Following bots will gather around the player when movement stops or remains constant
    local recall_range = deploy_config.recall_range;
    local position = player.position;
    local surface = player.surface;
    local target_force = player.force;

    local search_bots = {
        position = position,
        radius = recall_range,
        force = target_force,
        name = {
            deploy_config.entity_to_deploy_destroyer,
            deploy_config.entity_to_deploy_distractor,
            deploy_config.entity_to_deploy_defender
        }
    };

    local bots = surface.find_entities_filtered(search_bots);

    -- Gather the number of units per capsule for each bot type
    local units_per_capsule = {}
    units_per_capsule[deploy_config.entity_to_deploy_defender] = deploy_config.entity_deploy_per_capsule_defender;
    units_per_capsule[deploy_config.entity_to_deploy_distractor] = deploy_config.entity_deploy_per_capsule_distractor;
    units_per_capsule[deploy_config.entity_to_deploy_destroyer] = deploy_config.entity_deploy_per_capsule_destroyer;

    -- Precalculate the max lifetime per bot type
    local destroyer_prototype = prototypes.entity[deploy_config.entity_to_deploy_destroyer];
    local defender_prototype = prototypes.entity[deploy_config.entity_to_deploy_defender];
    local distractor_prototype = prototypes.entity[deploy_config.entity_to_deploy_distractor];

    local recall_context = {};
    recall_context[deploy_config.entity_to_deploy_destroyer] = getLifetimeThresholdForBotType(player, deploy_config, destroyer_prototype);
    recall_context[deploy_config.entity_to_deploy_defender] = getLifetimeThresholdForBotType(player, deploy_config, defender_prototype);
    recall_context[deploy_config.entity_to_deploy_distractor] = getLifetimeThresholdForBotType(player, deploy_config, distractor_prototype);

    -- group bots that can be recalled by type and count the number of capsules
    local bot_statistics = getCapsuleCountPerBotType(player, deploy_config, recall_context,bots, units_per_capsule);

    -- if we reach here, there are still follower bots on the player, but they may not be in range to recall
    local bots_in_range = bot_statistics.total_bots;
    if (bots_in_range < 1) then
        if (debug_print) then
            player.print(" -- Recall: active bots are outside recall range. Move closer to collect!")
        end
        return;
    end

    -- recall the bots, insert the capsules back in the inventory, and destroy the corresponding bot entities
    recallBots(player, deploy_config, bot_statistics, units_per_capsule);
end

function getLifetimeThresholdForBotType(player, deploy_config, bot_prototype)
    local base_life = bot_prototype.time_to_live;
    local modifier = player.force.following_robots_lifetime_modifier;
    local max_life = base_life * (1 + modifier);

    local lifetime_percentage = deploy_config.recall_lifetime;
    local lifetime_threshold_multiplier = lifetime_percentage / 100;
    local lifetime_threshold = max_life * lifetime_threshold_multiplier;

    return {
        base_life = base_life,
        modifier = modifier,
        max_life = max_life,
        lifetime_threshold = lifetime_threshold,
    }
end

function getCapsuleCountPerBotType(player, deploy_config, recall_context, bots, units_per_capsule)
    local bot_statistics = {}
    bot_statistics.total_bots = #bots;
    bot_statistics.total_capsules = 0; -- initial value, updated in this function

    local bot_counts = {}
    local bots_per_type = {}
    bots_per_type[deploy_config.entity_to_deploy_defender] = {};
    bots_per_type[deploy_config.entity_to_deploy_distractor] = {};
    bots_per_type[deploy_config.entity_to_deploy_destroyer] = {};

    -- Count bots by type that can be recalled
    for _, bot in pairs(bots) do
        if canRecallBot(player, deploy_config, recall_context,bot) then
            local bot_name = bot.name;
            bot_counts[bot_name] = (bot_counts[bot_name] or 0) + 1;
            table.insert(bots_per_type[bot_name], bot);
        end
    end

    -- Calculate the number of capsules for each bot type
    local capsules_per_type = {}
    for bot_name, count in pairs(bot_counts) do
        local per_capsule = units_per_capsule[bot_name]
        -- need to fill up one capsule before it may be recalled (floor)
        local capsule_count = math.floor(count / per_capsule);
        capsules_per_type[bot_name] = capsule_count;
        bot_statistics.total_capsules = bot_statistics.total_capsules + capsule_count;
    end

    bot_statistics.bot_counts = bot_counts;
    bot_statistics.capsule_counts = capsules_per_type;
    bot_statistics.bots_per_type = bots_per_type;
    return bot_statistics
end

function canRecallBot(player, deploy_config, recall_context, bot)
    local bot_recall_context = recall_context[bot.name];

    local base_life = bot_recall_context.base_life;
    local modifier = bot_recall_context.modifier;
    local max_life = bot_recall_context.max_life;
    local lifetime_threshold = bot_recall_context.lifetime_threshold;

    -- check if bot has spent over x% of its max (modified) lifetime
    local current_life = bot.time_to_live;

    -- Factorio filters and only shows unique messages per x seconds, so this won't spam too much
    if (deploy_config.debug_print) then
        local message = " -- Recall: %s base_life=%s modifier=%s max_life=%s current_life=%s threshold=%s test";
        printf(player, message, bot.name, base_life, modifier, max_life, current_life, lifetime_threshold);
    end

    if current_life < lifetime_threshold then
        return false;
    end
    return true;
end

function recallBots(player, deploy_config, bot_statistics, units_per_capsule)
    local debug_print = deploy_config.debug_print;
    local capsule_counts = bot_statistics.capsule_counts;

    local capsules_per_type = {}
    capsules_per_type[deploy_config.entity_to_deploy_defender] = deploy_config.item_to_consume_defender;
    capsules_per_type[deploy_config.entity_to_deploy_distractor] = deploy_config.item_to_consume_distractor;
    capsules_per_type[deploy_config.entity_to_deploy_destroyer] = deploy_config.item_to_consume_destroyer;

    local number_of_launchers_function_per_type = {}
    number_of_launchers_function_per_type[deploy_config.entity_to_deploy_defender] = getNumberOfDefenderLaunchers;
    number_of_launchers_function_per_type[deploy_config.entity_to_deploy_distractor] = getNumberOfDistractorLaunchers;
    number_of_launchers_function_per_type[deploy_config.entity_to_deploy_destroyer] = getNumberOfDestroyerLaunchers;

    local tooltip_offset = 0;
    for bot_type, capsule_count in pairs(capsule_counts) do
        local capsule_type = capsules_per_type[bot_type]

        local max_capsules_per_pass = getMaxCapsulesToThrow(player, deploy_config, number_of_launchers_function_per_type[bot_type]);
        if (capsule_count > max_capsules_per_pass) then
            capsule_count = max_capsules_per_pass;
            if debug_print then
                player.print("Max capsules per pass limit exceeded - limiting to " .. max_capsules_per_pass)
            end
        end

        local inserted_count = insertIntoInventory(player, capsule_type, capsule_count);

        if (inserted_count >= 1) then
            showTooltipInsertedSuccessful(player, deploy_config, capsule_type, inserted_count, tooltip_offset);
            tooltip_offset = tooltip_offset + getTooltipOffsetStep();
            -- remove the entities from the game world after successful recall into inventory
            destroyRecalledBots(bot_statistics, bot_type, inserted_count, units_per_capsule);
        end

        if debug_print then
            player.print(" -- Recall: bot type = " .. bot_type .. ", total number of " .. capsule_type .. ": " .. capsule_count .. ", recalled: " .. inserted_count)
        end
    end
end

function destroyRecalledBots(bot_statistics, bot_type, inserted_capsules_count, units_per_capsule)
    local bots_list = bot_statistics.bots_per_type[bot_type];
    local bots_to_destroy_count = inserted_capsules_count * units_per_capsule[bot_type];

    local destroyed = 0;
    for _, bot in pairs(bots_list) do
        destroyed = destroyed + 1
        if destroyed > bots_to_destroy_count then
            break
        end

        destroyEntity(bot);
    end
end

-- api call: LuaEntity.html#destroy
function destroyEntity(entity)
    entity.destroy();
end
