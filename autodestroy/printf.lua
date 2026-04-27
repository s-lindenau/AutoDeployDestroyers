-- Print a formatted string to the player console
---@param player LuaPlayer
---@param message_template string
---@vararg any # Message parameters to replace in the message_template
function printf(player, message_template, ...)
    local message = string.format(message_template, ...);
    player.print(message);
end