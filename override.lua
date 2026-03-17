-- ia_placeable_buckets/override.lua

local function get_target_pos(pointed_thing)
    local node_under = minetest.get_node(pointed_thing.under)
    local def_under = minetest.registered_nodes[node_under.name]
    if def_under and def_under.buildable_to then
        return pointed_thing.under
    end
    return pointed_thing.above
end

function placeable_buckets.override_bucket_item(itemname)
	minetest.log('placeable_buckets.override_bucket_item(itemname='..itemname..')')
	assert(minetest.registered_items           ~= nil)
	local original_def = minetest.registered_items[itemname]
	assert(original_def                        ~= nil, itemname)
        assert(minetest.registered_nodes[itemname] ~= nil, itemname)
	--if not original_def then return end

	-- Copy the original on_place (the pouring logic)
	local original_on_place = original_def.on_place

	minetest.override_item(itemname, {
		on_place = function(itemstack, placer, pointed_thing)
core.log('on_place itemname: '..itemname)
--			if not pointed_thing or pointed_thing.type ~= "node" then -- noop
----core.log('on_place cutout')
--			--	return original_on_place(itemstack, placer, pointed_thing)
--			end
--
--			-- SHIFT+CLICK: Place the bucket as a node (if it has a node definition)
--			-- Note: Default buckets are often items, not nodes. 
--			-- We must ensure they have a node definition to be placeable.
			local name_before  = itemstack:get_name()
			local count_before = itemstack:get_count()
			local target_pos   = get_target_pos(pointed_thing)
			if placer and placer:get_player_control().sneak then
core.log('on_place sneak')
--				-- Check if this item is actually a node before placing
				assert(core.registered_nodes[itemname])
--				----if minetest.registered_nodes[itemname] then
				local result = minetest.item_place(itemstack, placer, pointed_thing) -- TODO need to check whether can place ?
--				--return result
--				--if (original_def.stack_max == 1) then return '' end -- NOTE testing
--				--if result then
				assert(result:get_count() == count_before)
				assert(result:get_name () == name_before)
				if minetest.get_node(target_pos).name == itemname then
				if result:get_count() == count_before and result:get_name() == name_before then -- decrement full & empty buckets
core.log('on_place sneak take item')
					--itemstack:take_item() -- NOTE testing
					result:take_item() -- NOTE testing
				end
				end
--				--return itemstack
				return result
--				----else
--				----	-- Fallback: if it's not a node, we can't place it as one.
--				----	-- You could alternatively register a 'dummy' node for it here.
--				----	return original_on_place(itemstack, placer, pointed_thing)
--				----end
			end
			assert(original_on_place)

--			if original_on_place then
core.log('on_place original')
				-- NORMAL CLICK: Use original pouring logic
				local result = original_on_place(itemstack, placer, pointed_thing) -- TODO need to check whether can place ?
				if not result then return result end
				--if result then
				assert(result:get_count() == count_before)
				--assert(result:get_name () == name_before) -- not true when placing bucket of liquid
				local node_at_target = minetest.get_node(target_pos)
				if result:get_name() ~= name_before or node_at_target.name == itemname then
				if result:get_count() == count_before and result:get_name() == name_before then -- decrement empty buckets only
core.log('on_place original take item')
					--itemstack:take_item() -- NOTE testing
					result:take_item() -- NOTE testing
				end
				end
				return result
--			end
--
--			assert(false) -- eliminate code path for debugging
--			-- 3. FALLBACK: If there's no on_place (like empty buckets), 
--            		-- let the engine try to place it as a node by default.
--			local result = minetest.item_place(itemstack, placer, pointed_thing)
--			--return result
--			--if (original_def.stack_max == 1) then return '' end -- NOTE testing
--			--if result then
--				itemstack:take_item() -- NOTE testing
--			--end
--			--return itemstack
--			return result
		end
	})
end

