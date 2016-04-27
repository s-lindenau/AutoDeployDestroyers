-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

-- Provides the target count to deploy if the weight is between {previous} and {current}.
-- Deploy amount is always capped to the 'max_follower_count'
--
-- So for example:
-- The lowest entry in the config describes the deploy amount for weights between 0 and {weight}
-- The second entry in the config is valid for weights between {previous weight} and {weight}
-- Anything above the biggest entry will deploy the 'max_follower_count' (134 in vanilla)
local deployWeightConfig = {
    { weight = 100, deployCount = 5 },
    { weight = 1000, deployCount = 25 },
    { weight = 5000, deployCount = 50 },
    { weight = 10000, deployCount = 100 },
    { weight = 12500, deployCount = 125 }
}

function getDeployCountForWeight(weight, max_follower_count)
    if (weight == nil) then
        return max_follower_count;
    end

    table.sort(deployWeightConfig, deployWeightConfigComparator);
    for _, deployConfig in pairs(deployWeightConfig) do
        local deployWeight = deployConfig.weight;
        local deployCount = deployConfig.deployCount;

        if (weight < deployWeight) then
            return math.min(deployCount, max_follower_count);
        end
    end

    return max_follower_count;
end

function deployWeightConfigComparator(first, second)
    return first.weight < second.weight;
end