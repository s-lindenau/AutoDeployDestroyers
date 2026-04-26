-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.player");
require("autodestroy.deploycapsule");
require("autodestroy.controltiming");

local check_per_tick = getCheckPerTick();
local tick_offset = getTickOffset();

function autoDeployDestroyers()
    if ((game.tick + tick_offset) % check_per_tick == 0) then
        for _, player in pairs(game.players) do
            if (autoDeployActiveFor(player)) then
                checkAndDeployFor(player);
            end
        end
    end
end

function checkConfiguration()
    local deploy_config = getStartupConfig();
    checkDeployConfiguration(deploy_config.entity_to_deploy_destroyer, deploy_config.item_to_consume_destroyer);
    checkDeployConfiguration(deploy_config.entity_to_deploy_distractor, deploy_config.item_to_consume_distractor);
    checkDeployConfiguration(deploy_config.entity_to_deploy_defender, deploy_config.item_to_consume_defender);
end

function checkDeployConfiguration(entity_to_deploy_name, item_to_consume_name)
    local entity_to_deploy = prototypes.entity[entity_to_deploy_name];
    local item_to_consume = prototypes.item[item_to_consume_name];
    assert(entity_to_deploy, "Configured entity to deploy is not a valid game entity: " .. entity_to_deploy_name);
    assert(item_to_consume, "Configured item to consume is not a valid game item: " .. item_to_consume_name);
end

script.on_event(defines.events.on_tick, autoDeployDestroyers)
script.on_configuration_changed(checkConfiguration);