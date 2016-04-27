-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

local supported_vehicles = { "car", "tank" } -- vehicles that have trunk inventory (inclusive)
local unsupported_vehicles = { "cargo", "locomotive" } -- vehicles that don't have trunk inventory (exclusive)

-- is the player in a vehicle with a trunk (based on name.substring matches for vehicles from other mods)
function isInSupportedVehicle(player)
    local vehicle = player.vehicle;
    if (vehicle ~= nil) then
        local name = vehicle.name;
        if (isInInclusiveList(name)) then
            if (isNotInExclusiveList(name)) then
                return true;
            end
        end
    end
    return false;
end

function isInInclusiveList(name)
    for _, vehicleName in pairs(supported_vehicles) do
        if (string.find(name, vehicleName)) then
            return true;
        end
    end
    return false;
end

function isNotInExclusiveList(name)
    for _, vehicleName in pairs(unsupported_vehicles) do
        if (string.find(name, vehicleName)) then
            return false;
        end
    end
    return true;
end