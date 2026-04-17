-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

function getDeployCountForWeightDestroyer(weight)
    if (weight == nil) then
        return 0;
    end
    -- lower number = more bots per weight, higher number = less bots
    local deployCount = math.ceil(weight/300.0) -- ceil: round up to the first whole number, so we never reach 0
    return deployCount
end

function getDeployCountForWeightDistractor(weight)
    if (weight == nil) then
        return 0;
    end
    -- lower number = more bots per weight, higher number = less bots
    local deployCount = math.floor(weight/2000.0) -- floor: round down, so 0 can be reached to save distractors
    return deployCount
end

function getDeployCountForWeightDefender(weight)
    -- same as destroyers for now
    return getDeployCountForWeightDestroyer(weight);
end