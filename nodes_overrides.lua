-- ia_placeable_buckets/nodes_overrides.lua

function placeable_buckets.register_and_override_bucket(itemname)
    minetest.log('placeable_buckets: Processing '..itemname)
    
    local original_def = minetest.registered_items[itemname]
    assert(original_def ~= nil, "Item " .. itemname .. " does not exist!")

    -- 1. Capture the original liquid-pouring logic BEFORE we register the node
    local original_on_place = original_def.on_place
    local original_on_use = original_def.on_use

    -- 2. Register the NODE version of the bucket
    -- Using table.copy on the original item definition
    local node_def = table.copy(original_def)

    node_def.drawtype = "plantlike"
    node_def.paramtype = "light"
    node_def.walkable = false
    node_def.is_ground_content = false
    node_def.tiles = {original_def.inventory_image}
    node_def.selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
    }

    -- CRITICAL: Clear these so the NODE doesn't try to "pour" itself 
    -- when minetest.item_place is called.
    node_def.on_place = nil
    node_def.on_use = nil
    
    node_def.groups = table.copy(original_def.groups or {})
    node_def.groups.dig_immediate = 3
    node_def.groups.attached_node = 1
    node_def.drop = itemname

    if default and default.node_sound_defaults then
        node_def.sounds = default.node_sound_defaults()
    end

    -- Register the node (this replaces the item definition in the registry)
    minetest.register_node(":" .. itemname, node_def)

    -- 3. Now OVERRIDE the new definition to add the Shift-Click logic
    -- We use the captured original_on_place from step 1
    minetest.override_item(itemname, {
        on_place = function(itemstack, placer, pointed_thing)
            if not pointed_thing or pointed_thing.type ~= "node" then
                if original_on_place then
                    return original_on_place(itemstack, placer, pointed_thing)
                end
                return itemstack
            end

            -- SHIFT+CLICK: Standard node placement
            if placer and placer:get_player_control().sneak then
                -- This will now use the node_def we registered above (which has no on_place)
                return minetest.item_place(itemstack, placer, pointed_thing)
            end

            -- NORMAL CLICK: Liquid logic
            if original_on_place then
                return original_on_place(itemstack, placer, pointed_thing)
            end
            
            -- Fallback if for some reason original_on_place was nil
            return minetest.item_place(itemstack, placer, pointed_thing)
        end
    })
end

-- Initialization loop
--for _, name in ipairs(placeable_buckets.buckets) do
--    placeable_buckets.register_and_override_bucket(name)
--end
