-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

-- Pattern to deploy entities in.
-- Assume a starting position, most likely the player.position
--
-- 1. 'startPositionOffset' is the first translation done from the starting position. One entity is deployed here.
-- 2. for each 'translation' in 'translations':
-- 2.1 repeat 'repeatAmount' times
-- 2.2 apply 'translationOffset' to the previous deployed position
-- 2.3 deploy 1 entity
--
-- This will result in a deploy pattern with the given name.
--
-- Note for repeating patterns;
-- after the last translation, the first translation should bring the position back to the original starting position
local deployPatterns = {
    {
        name = "Square",
        startPositionOffset = { x = -3, y = 5 },
        translations = {
            {
                repeatAmount = 6,
                translationOffset = { x = 1, y = 0 }
            },
            {
                repeatAmount = 6,
                translationOffset = { x = 0, y = -1 }
            },
            {
                repeatAmount = 6,
                translationOffset = { x = -1, y = 0 }
            },
            {
                repeatAmount = 6,
                translationOffset = { x = 0, y = 1 }
            }
        }
    },

    {
        name = "Rhombus",
        startPositionOffset = { x = 0, y = 5 },
        translations = {
            {
                repeatAmount = 5,
                translationOffset = { x = 1, y = -1 }
            },
            {
                repeatAmount = 5,
                translationOffset = { x = -1, y = -1 }
            },
            {
                repeatAmount = 5,
                translationOffset = { x = -1, y = 1 }
            },
            {
                repeatAmount = 5,
                translationOffset = { x = 1, y = 1 }
            }
        }
    },

    {
        name = "Triangle",
        startPositionOffset = { x = 0, y = 3 },
        translations = {
            {
                repeatAmount = 5,
                translationOffset = { x = 1, y = -1 }
            },
            {
                repeatAmount = 10,
                translationOffset = { x = -1, y = 0 }
            },
            {
                repeatAmount = 5,
                translationOffset = { x = 1, y = 1 }
            }
        }
    },

    {
        name = "Circle",
        startPositionOffset = { x = 2, y = 4 },
        translations = {
            {
                repeatAmount = 2,
                translationOffset = { x = 1, y = -1 }
            },
            {
                repeatAmount = 3,
                translationOffset = { x = 0, y = -1 }
            },
            {
                repeatAmount = 2,
                translationOffset = { x = -1, y = -1 }
            },
            {
                repeatAmount = 3,
                translationOffset = { x = -1, y = 0 }
            },
            {
                repeatAmount = 2,
                translationOffset = { x = -1, y = 1 }
            },
            {
                repeatAmount = 3,
                translationOffset = { x = 0, y = 1 }
            },
            {
                repeatAmount = 2,
                translationOffset = { x = 1, y = 1 }
            },
            {
                repeatAmount = 3,
                translationOffset = { x = 1, y = 0 }
            }
        }
    }
}

-- Return one of the deploy patterns based on the current game time.
-- Pseudo-random to not break multiplayer.
function getNextDeployPattern()
    local numberOfDeployPatterns = #deployPatterns;
    local patternIndex = (game.tick / 60) % numberOfDeployPatterns;
    return deployPatterns[math.floor(patternIndex) + 1];
end
