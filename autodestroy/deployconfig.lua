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
-- min_capsules_remaining: how many capsules should always remain in the player's inventory. Autodeploy stops if this amount (or lower) is reached
-- max_capsules_per_pass: how many capsules 1 launcher may throw per pass. Stacks with multiple launchers in power armor
-- aggression_factor:   configure the deploy aggression based on the player's playstyle. Default = 1.0, oriented at bot-only warfare.
--                      Lower this value if bots are used as secondary warfare; as support to for example the flamethrower.
--                      Can be any decimal between [0.0, 1.0]. Numbers higher than 1 can be used, however this is not advised as it will waste capsules.
function getDeployConfig()
    return {
        entity_to_deploy = "destroyer",
        item_to_consume = "destroyer-capsule",
        entity_deploy_per_capsule = 5,
        max_accepted_wastage = 1,
        min_capsules_remaining = 20,
        max_capsules_per_pass = 100,
        aggression_factor = 1.0,
    }
end