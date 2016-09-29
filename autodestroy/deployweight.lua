-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

function getDeployCountForWeight(weight)
    if (weight == nil) then
        return 0;
    end

    local deployCount = math.ceil(weight/300.0)

    return deployCount
end
