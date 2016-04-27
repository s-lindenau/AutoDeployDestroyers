-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

-- Describes what to deploy and the relevant quantities
--
-- entity_to_deploy: the actual entity that gets created
-- item_to_consume: the item that gets removed from the inventory
-- entity_deploy_per_capsule: how many entities are spawned from 1 capsule
-- max_accepted_wastage: example:   if the target is 6 entities, and 1 capsule spawns 5, that would be a wastage of 4 entities
--                                  the second capsule is only deployed if the wastage is not above the max accepted wastage
-- min_capsules_remaining: how many capsules should always remain in the players inventory. Autodeploy stops if this amount (or lower) is reached
function getDeployConfig()
    return {
        entity_to_deploy = "destroyer",
        item_to_consume = "destroyer-capsule",
        entity_deploy_per_capsule = 5,
        max_accepted_wastage = 5,
        min_capsules_remaining = 20
    }
end