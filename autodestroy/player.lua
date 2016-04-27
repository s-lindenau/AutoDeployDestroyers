-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("defines");

-- only deploy for players that have an active character in the game world
function autoDeployActiveFor(player)
    if (isConnected(player)) then
        if (isCharacter(player)) then
            return true;
        end
    end
    return false;
end

function isConnected(player)
    return player.connected;
end

function isCharacter(player)
    return player.controller_type == defines.controllers.character;
end

