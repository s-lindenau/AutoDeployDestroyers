-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.player");
require("autodestroy.deploycapsule");

local check_per_tick = 90;
local tick_offset = 15;

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
    local deploy_config = getDeployConfig(game.players[1]);
    local entity_to_deploy = game.entity_prototypes[deploy_config.entity_to_deploy];
    local item_to_consume = game.item_prototypes[deploy_config.item_to_consume];
    assert(entity_to_deploy, "Configured entity to deploy is not a valid game entity: " .. deploy_config.entity_to_deploy);
    assert(item_to_consume, "Configured item to consume is not a valid game item: " .. deploy_config.item_to_consume)
end

script.on_event(defines.events.on_tick, autoDeployDestroyers)
script.on_configuration_changed(checkConfiguration);