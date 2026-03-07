-- ia_bucket/override.lua

function ia_bucket.override_bucket_item(itemname)
	--minetest.log('ia_bucket.override_bucket_item(itemname='..itemname..')')
	assert(minetest.registered_items           ~= nil)
	local original_def = minetest.registered_items[itemname]
	assert(original_def                        ~= nil, itemname)
        assert(minetest.registered_nodes[itemname] ~= nil, itemname)
	--if not original_def then return end

	-- Copy the original on_place (the pouring logic)
	--local original_on_place = original_on_place or original_def.on_place -- FIXME 2026-03-07 12:58:28: WARNING[ServerStart]: Undeclared global variable "original_on_place" accessed at ...minetest/mods/ia_environment_meta/ia_bucket/override.lua:8
	local original_on_place = original_def.on_place

	minetest.override_item(itemname, {
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing or pointed_thing.type ~= "node" then
				return original_on_place(itemstack, placer, pointed_thing)
			end

			-- SHIFT+CLICK: Place the bucket as a node (if it has a node definition)
			-- Note: Default buckets are often items, not nodes. 
			-- We must ensure they have a node definition to be placeable.
			if placer and placer:get_player_control().sneak then
				-- Check if this item is actually a node before placing
				if minetest.registered_nodes[itemname] then
					return minetest.item_place(itemstack, placer, pointed_thing)
				else
					-- Fallback: if it's not a node, we can't place it as one.
					-- You could alternatively register a 'dummy' node for it here.
					return original_on_place(itemstack, placer, pointed_thing)
				end
			end

			-- NORMAL CLICK: Use original pouring logic
			return original_on_place(itemstack, placer, pointed_thing)
		end
	})
end

for _, name in ipairs(ia_bucket.buckets) do
	ia_bucket.override_bucket_item(name)
end
