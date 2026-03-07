-- ia_bucket/init.lua

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
local modname                    = minetest.get_current_modname() or "ia_bucket"
local storage                    = minetest.get_mod_storage()
ia_bucket                        = {}
ia_bucket.buckets                = {
	"bucket:bucket_water",
	"bucket:bucket_river_water",
	"bucket:bucket_lava",
	"bucket:bucket_empty"
}
--local modpath, S                 = ia_util.loadmod(modname)
local modpath = minetest.get_modpath(modname)
dofile(modpath .. '/nodes.lua')
dofile(modpath .. '/override.lua')
dofile(modpath .. '/register.lua')
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

