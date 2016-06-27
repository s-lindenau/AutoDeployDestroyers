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

script.on_event(defines.events.on_tick, autoDeployDestroyers)