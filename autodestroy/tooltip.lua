-- Author: slindenau
-- https://github.com/s-lindenau
-- https://forums.factorio.com/memberlist.php?mode=viewprofile&u=16823
-- Licence: GPLv3

require("autodestroy.controltiming");

-- Show consuming items from inventory
function showTooltipConsumedSuccessful(player, deploy_config, capsule_type, consumed_count, offset)
    local template = "mod-messages-autodestroy.autodestroy_inventory-item-consumed-popup";
    showTooltipMessage(player, deploy_config, capsule_type, consumed_count, offset, template);
end

-- Show recalling items into inventory
function showTooltipInsertedSuccessful(player, deploy_config, capsule_type, inserted_count, offset)
    local template = "mod-messages-autodestroy.autodestroy_inventory-item-inserted-popup";
    showTooltipMessage(player, deploy_config, capsule_type, inserted_count, offset, template);
end

function showTooltipMessage(player, deploy_config, item_type, item_count, offset, text_template)
    local tooltip_enabled = deploy_config.tooltip_enabled;
    if not tooltip_enabled then
        return;
    end

    local tooltip_text = {text_template, item_count, item_type }
    local time_to_live = math.max(90, getCheckPerTick()); -- Duration in ticks
    local movement_speed = 0.5 -- Upward movement speed
    local zoomed_offset = offset / player.zoom;
    local text_position = { player.position.x, player.position.y - zoomed_offset };

    player.create_local_flying_text {
        text = tooltip_text,
        position = text_position,
        time_to_live = time_to_live,
        speed = movement_speed
    }
end

-- The height difference between tooltips messages
function getTooltipOffsetStep()
    return 0.90;
end
