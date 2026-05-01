-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.controltiming");

--- @return boolean
function canDebugPrintNoisy()
    -- Some debug information doesn't need to be printed that often, add a delay factor of {n}
    local noisy_delay_factor = 10;
    local check_per_tick = getCheckPerTick();
    local tick_offset = getTickOffset();
    local check_per_tick_noisy = check_per_tick * noisy_delay_factor;
    return ((game.tick + tick_offset) % check_per_tick_noisy == 0);
end
