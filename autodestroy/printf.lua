-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

--- Print a formatted string to the player console
---@param player LuaPlayer
---@param message_template string
---@param ... any # Message parameters to replace in the message_template
---@diagnostic disable-next-line: unused
function printf(player, message_template, ...)
    local message = string.format(message_template, ...);
    player.print(message);
end
