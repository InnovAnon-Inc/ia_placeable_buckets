-- ia_placeable_buckets/nodes.lua

function placeable_buckets.register_bucket_node(itemname)
    --minetest.log('placeable_buckets.register_bucket_node(itemname='..itemname..')')
    assert(minetest.registered_nodes           ~= nil)
    assert(minetest.registered_nodes[itemname] == nil, itemname)
    local item_def = minetest.registered_items[itemname]
    assert(item_def                            ~= nil, itemname)

    -- 1. Create a deep copy of the entire item definition
    local node_def = table.copy(item_def)

    -- 2. Override only the fields necessary to make it a placeable node
    node_def.drawtype      = "plantlike"
    node_def.paramtype     = "light"
    node_def.walkable      = false
    node_def.is_ground_content = false
    
    -- Ensure it uses its own inventory image as the world texture
    node_def.tiles         = {item_def.inventory_image}
    
    node_def.selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
    }

    -- 3. Update Groups (Preserving existing, adding node-specific)
    node_def.groups = node_def.groups or {}
    node_def.groups.dig_immediate = 3 -- node_def.groups.dig_immediate or 3 ?
    node_def.groups.attached_node = 1 -- node_def.groups.attached_node or 1 ?
    --node_def.groups.not_in_creative_inventory = 1 -- NOTE testing

    -- 4. Set sounds (using default if available)
    if default and default.node_sound_defaults then
        node_def.sounds = default.node_sound_defaults()
    end

    -- 5. Logic: When dug, it drops the item version of itself
    --node_def.drop = itemname -- NOTE testing

    node_def.on_dig = function(pos, node, digger)
        if not digger then return end

        local inv = digger:get_inventory()
        local stack = ItemStack(itemname)

        -- Try to put it in the inventory
        if inv and inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
        else
            -- If inventory is full or restricted, drop it in the world
            minetest.add_item(pos, stack)
        end

        minetest.remove_node(pos)
    end

    -- 6. Register as a node using the ":" prefix to keep the name identical
    minetest.register_node(":" .. itemname, node_def)
    
    --log(3, "Converted " .. itemname .. " to a placeable node via table.copy")
end

--for _, name in ipairs(placeable_buckets.buckets) do
--	placeable_buckets.register_bucket_node(name)
--end
