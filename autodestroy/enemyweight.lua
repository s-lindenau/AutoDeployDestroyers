-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

local enemy_visibility_range = 30; -- is stored on the entity prototype, but not public on the LuaEntity(Prototype)
local debug_log = false; -- writes enemy information to a log file

-- returns the weight of all enemies in range
function getEnemyWeightAround(player)
    local surface = player.surface;
    local position = player.position;
    local force = player.force;

    local search_nearest = {
        position = position,
        max_distance = enemy_visibility_range,
        force = force
    };

    local enemy_in_visibility_range = surface.find_nearest_enemy(search_nearest);

    if (enemy_in_visibility_range == nil) then
        return 0;
    end

    local search_area = {
        { position.x - enemy_visibility_range, position.y - enemy_visibility_range },
        { position.x + enemy_visibility_range, position.y + enemy_visibility_range }
    }

    local search_enemies = {
        area = search_area,
        force = game.forces.enemy
    };

    local enemies = surface.find_entities_filtered(search_enemies);
    local debug_contents = "============ Enemy Weight ============\r\n";

    local total_enemy_weight = 0;
    for _, enemy in pairs(enemies) do
        local enemy_weight = getEnemyWeight(enemy);
        total_enemy_weight = total_enemy_weight + enemy_weight;
        if (debug_log == true) then
            debug_contents = debug_contents .. enemy.name .. "=" .. enemy_weight .. "\r\n";
        end
    end

    if (debug_log == true) then
        debug_contents = debug_contents .. "============ Total: " .. total_enemy_weight .. " ============\r\n";
        game.write_file("AutoDeployDestroyers.log", debug_contents);
    end

    return total_enemy_weight;
end

-- simple weight function based on remaining hitpoints of the enemy
function getEnemyWeight(enemy_entity)
    return enemy_entity.health;
end