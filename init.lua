-- ia_placeable_buckets/init.lua
-- TODO recipes
-- TODO restore climate_api
-- TODO restore entity_...
-- TODO restore waterworks
-- TODO restore 3d meshes

	-- TODO is there a way to register with pipeworks so it's pumpable through tubes ?
	-- pipeworks.liquids.<name>.source      = core.registered_nodes['mapgen_<name>_source'].name,
	-- pipeworks.liquids.<name>.river_water = core.registered_nodes['mapgen_<name>_source'].liquid_alternative_flowing,
	-- pipeworks.flowables.register[...] = ...
	-- pipeworks/pressure_logic/flowable_noode_registry_install.lua:
	-- -- registration functions
        --local checkexists = function(nodename)
	--local insertbase = function(nodename)
	--local regwarning = function(kind, nodename)
	--register.simple = function(nodename)
	-- -- has a helper function which determines which nodes to consider valid neighbours.
	--register.directional = function(nodename, neighbourfn, directionfn)
	--register.directional_vertical_fixed = function(nodename, topside)
	--	local neighbourfn = function(node) return { side } end
	--	local directionfn = function(node, direction)
	--register.directional_horizonal_rotate = function(nodename, doubleended)
	--	local getends = function(node)
	--	local neighbourfn = function(node)
	--	local directionfn = function(node, direction)
	--local checkbase = function(nodename)
	--local duplicateerr = function(kind, nodename) error(kind.." duplicate registration for "..nodename) end
	--register.intake = function(nodename, maxpressure, intakefn)
	--register.intake_simple = function(nodename, maxpressure)
	--register.output = function(nodename, upper, lower, outputfn, cleanupfn)
	--register.output_simple = function(nodename, upper, lower, neighbours)
	--local insert_transition_base = function(nodename)
	--local simpleseterror = function(msg)
	--register.transition_simple_set = function(nodeset, extras)
	--	local smallest_first = function(a, b)
	
assert(minetest.get_modpath('ia_util'))
assert(ia_util ~= nil)
local modname                    = minetest.get_current_modname() or "ia_placeable_buckets"
local storage                    = minetest.get_mod_storage()
placeable_buckets                        = {}
placeable_buckets.buckets                = {
	"bucket:bucket_water",
	"bucket:bucket_river_water",
	"bucket:bucket_lava",
	"bucket:bucket_empty"
}
if ia_util.has_wooden_bucket_redo() then
--	for fluid, def in pairs(bucket.liquids) do
--		--if not fluid:find('flowing') and not fluid:find('lava') and not fluid:find('corium')
--		--	and not fluid:find('molten') and not fluid:find('weightless')
--		--then
--		if wooden_bucket.is_allowed_fluid(fluid) then
--			local item_name = def.itemname:gsub('[^:]+:bucket', 'wooden_bucket:bucket_wood')
--			local original = core.registered_items[def.itemname]
--			assert(item_name)
--			assert(original)
--			--assert(item_name == def.itemname, 'item_name='..item_name..', def.itemname='..def.itemname)
--			if item_name == def.itemname then
--			--if original and item_name and item_name ~= def.itemname then
--				--local new_name = original.description:gsub('Bucket', 'Wooden Bucket')
--				--local new_image = original.inventory_image
--				--wooden_bucket.register_liquid_wood(fluid, item_name, new_image, new_name, original.groups)
--				table.insert(placeable_buckets.buckets, item_name)
--			end
--		end
--	end
	for _,item_name in ipairs(wooden_bucket.buckets) do
		table.insert(placeable_buckets.buckets, item_name)
	end
	table.insert(placeable_buckets.buckets, 'wooden_bucket:bucket_wood_empty')
elseif minetest.get_modpath('bucket_wooden') then
    table.insert(placeable_buckets.buckets, 'bucket_wooden:bucket_empty')
    table.insert(placeable_buckets.buckets, 'bucket_wooden:bucket_water')
    table.insert(placeable_buckets.buckets, 'bucket_wooden:bucket_river_water')
end
placeable_buckets.mod = 'ia'
placeable_buckets.hunger_ng_upstreams     = {
    [modname]                = true,
    ["claycrafter"]          = true,
    ["default"]              = true,
    ["farming"]              = true,
    --["ketchup"]              = true,
    ["milker"]               = true,
    ["peeer"]                = true,
    ["pooper"]               = true,
}
placeable_buckets.drinking_glasses        = {}
placeable_buckets.glass_bottles           = {}
placeable_buckets.heavy_steel_bottles     = {}
--local modpath, S                 = ia_util.loadmod(modname) -- FIXME
local modpath = minetest.get_modpath(modname)
dofile(modpath .. '/nodes.lua')
dofile(modpath .. '/override.lua')
--dofile(modpath .. '/nodes_overrides.lua')
dofile(modpath .. '/register.lua')
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

for _, name in ipairs(placeable_buckets.buckets) do
	placeable_buckets.register_bucket_node(name)
end
for _, name in ipairs(placeable_buckets.buckets) do
	placeable_buckets.override_bucket_item(name)
end
--for _, name in ipairs(placeable_buckets.buckets) do
--    placeable_buckets.register_and_override_bucket(name)
--end

local water_color       = '#3f5daec8'
local river_water_color = '#439ad9b4'
local lava_color        = '#ffae15'
assert(water_color       ~= nil)
assert(river_water_color ~= nil)
assert(lava_color        ~= nil)
placeable_buckets.register_drink_vessels(modname, water_color,       'water',       'Water',        1, 0,
    'default:water_source',       'default:water_flowing',       'bucket:bucket_water',       'wooden_bucket:bucket_wood_water') -- TODO handle farming redo
local jcu_water_def         = minetest.registered_items[modname..':jcu_water']
jcu_water_def.groups        = ia_util.merge_groups(jcu_water_def.groups, { h2o= 3 })
jcu_water_def.groups        = ia_util.merge_groups(jcu_water_def.groups, { h2o= 3 })
local jbo_water_def         = minetest.registered_items[modname..':jbo_water']
jbo_water_def.groups        = ia_util.merge_groups(jbo_water_def.groups, { h2o= 6 })
jbo_water_def.groups        = ia_util.merge_groups(jbo_water_def.groups, { h2o= 6 })
local jsb_water_def         = minetest.registered_items[modname..':jsb_water']
jsb_water_def.groups        = ia_util.merge_groups(jsb_water_def.groups, { h2o= 6 })
jsb_water_def.groups        = ia_util.merge_groups(jsb_water_def.groups, { h2o= 6 })
local jbu_water_def         = minetest.registered_items['bucket:bucket_water']
jbu_water_def.groups        = ia_util.merge_groups(jbu_water_def.groups, { h2o=12 })
jbu_water_def.groups        = ia_util.merge_groups(jbu_water_def.groups, { h2o=12 })
if ia_util.has_wooden_bucket_redo() then
    local jbw_water_def     = minetest.registered_items['wooden_bucket:bucket_wood_water']
    jbw_water_def.groups    = ia_util.merge_groups(jbw_water_def.groups, { h2o=12 })
    jbw_water_def.groups    = ia_util.merge_groups(jbw_water_def.groups, { h2o=12 })
end
placeable_buckets.register_drink_vessels(modname, river_water_color, 'river_water', 'River Water',  1, 0,
    'default:river_water_source', 'default:river_water_flowing', 'bucket:bucket_river_water', 'wooden_bucket:bucket_wood_river_water')
local jcu_river_water_def         = minetest.registered_items[modname..':jcu_river_water']
jcu_river_water_def.groups        = ia_util.merge_groups(jcu_river_water_def.groups, { h2o= 3 })
jcu_river_water_def.groups        = ia_util.merge_groups(jcu_river_water_def.groups, { h2o= 3 })
local jbo_river_water_def         = minetest.registered_items[modname..':jbo_river_water']
jbo_river_water_def.groups        = ia_util.merge_groups(jbo_river_water_def.groups, { h2o= 6 })
jbo_river_water_def.groups        = ia_util.merge_groups(jbo_river_water_def.groups, { h2o= 6 })
local jsb_river_water_def         = minetest.registered_items[modname..':jsb_river_water']
jsb_river_water_def.groups        = ia_util.merge_groups(jsb_river_water_def.groups, { h2o= 6 })
jsb_river_water_def.groups        = ia_util.merge_groups(jsb_river_water_def.groups, { h2o= 6 })
local jbu_river_water_def         = minetest.registered_items['bucket:bucket_river_water']
jbu_river_water_def.groups        = ia_util.merge_groups(jbu_river_water_def.groups, { h2o=12 })
jbu_river_water_def.groups        = ia_util.merge_groups(jbu_river_water_def.groups, { h2o=12 })
if ia_util.has_wooden_bucket_redo() then
    local jbw_river_water_def     = minetest.registered_items['wooden_bucket:bucket_wood_river_water']
    jbw_river_water_def.groups    = ia_util.merge_groups(jbw_river_water_def.groups, { h2o=12 })
    jbw_river_water_def.groups    = ia_util.merge_groups(jbw_river_water_def.groups, { h2o=12 })
end
placeable_buckets.register_drink_vessels(modname, lava_color,        'lava',        'Lava',        0, -3,
    'default:lava_source',        'default:lava_flowing',        'default:bucket_lava',       nil) -- TODO maybe only steel bottle
