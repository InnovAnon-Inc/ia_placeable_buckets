---- ia_bucket/register.lua
--assert(minetest.get_modpath('bucket'))
--assert(minetest.get_modpath('drinks')) -- stealing resources only: do not use api; we require this to be loaded after us: do not declare in mod.conf
--
---- bucket.register_liquid(source, flowing, itemname, inventory_image, name, groups, force_renew)
--function ia_bucket.register_liquid(modname, color, alpha, source, flowing, itemname, inventory_image, name, groups, force_renew)
--    assert(modname)
--    assert(itemname)
--    local source_name         = modname .. ':flowspec_' .. itemname .. '_source'
--    local flowing_name        = modname .. ':flowspec_' .. itemname .. '_flowing'
--    local bucket_name         = modname .. ':bucket_'   .. itemname
--    local source_description  = name .. ' Source'
--    local flowing_description = name .. ' Flowing'
--    local bucket_description  = 'Bucket of ' .. name
--    local source_image        = "default_water_source_animated.png^[colorize:"     .. color .. ":120" -- TODO alpha
--    local flowing_image       = "default_water_flowing_animated.png^[colorize:"    .. color .. ":120" -- TODO alpha
--    --local bucket_image        = 'bucket.png^(drinks_bucket_contents.png^[colorize:'.. color .. ':200)'
--    local bucket_image        = 'bucket.png^(' .. '('..inventory_image..')' .. '^[colorize:'.. color .. ':200)' -- TODO alpha
--
--    assert(not minetest.registered_nodes[source_name])
--    assert(not minetest.registered_nodes[flowing_name])
--    assert(not minetest.registered_items[bucket_name])
--
--    -- TODO move to helper method ia_bucket.register_liquid_source
--    minetest.register_node(source_name, { -- TODO copy & override water source def ?
--        description                = source_description,
--	drawtype                   = 'liquid',
--	tiles                      = {
--		{
--			name      = source_image,
--            		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
--		},
--	},
--	special_tiles              = {
--		{
--			name             = source_image,
--            		animation        = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
--                        backface_culling = false,
--		},
--	},
--	alpha                      = 160,
--    	paramtype                  = "light",
--    	walkable                   = false,
--    	pointable                  = false,
--    	diggable                   = false,
--    	buildable_to               = true,
--    	drop                       = "",
--    	drowning                   = 1,
--    	liquidtype                 = "source",
--    	liquid_alternative_flowing = flowing_name,
--    	liquid_alternative_source  = source_name,
--    	liquid_viscosity           = 1,
--    	groups                     = {liquid = 3,}, -- TODO extend groups
--    })
--    
--    -- TODO move to helper method: ia_bucket.register_liquid_flowing
--    minetest.register_node(flowing_name, { -- TODO copy & override water flowing def ?
--    	drawtype                   = "flowingliquid",
--    	tiles                      = {
--		flowing_image,
--	},
--	special_tiles              = {
--		{
--			name             = flowing_image,
--            		animation        = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8},
--            		backface_culling = false,
--		},
--	},
--	alpha                      = 160,
--	paramtype                  = "light",
--	walkable                   = false,
--	pointable                  = false,
--	diggable                   = false,
--	buildable_to               = true,
--	drop                       = "",
--	drowning                   = 1,
--	liquidtype                 = "flowing",
--	liquid_alternative_flowing = flowing_name,
--	liquid_alternative_source  = source_name,
--	liquid_viscosity           = 1,
--	groups                     = {liquid = 3, not_in_creative_inventory = 1}, -- TODO extend groups
--    })
--
--    bucket.register_liquid(
--	source_name,        -- source
--	flowing_name,       -- flowing
--	bucket_name,        -- itemname
--	bucket_image,       -- inventory_image
--	bucket_description, -- name
--	groups,             -- groups
--    )
--
--end
--
--function ia_bucket.register_liquid2(modname, color, alpha, name, inventory_image, groups)
--	-- TODO
--	ia_bucket.register_liquid(modname, color, alpha, ...)
--end
assert(minetest.get_modpath('bucket'))

-- Helper to safely get base liquid properties from MTG
local function get_base_liquid_def(flowing)
    local base_name = flowing and "default:water_flowing" or "default:water_source"
    --local base_name = flowing and "default:lava_flowing" or "default:lava_source" -- NOTE testing
    local base_def  = minetest.registered_nodes[base_name]
    assert(base_def ~= nil)
    return base_def
end

function ia_bucket.register_liquid_source(name, description, image, flowing_name, groups, alpha)
    --minetest.log('ia_bucket.register_liquid_source(name='..name..', flowing_name='..flowing_name..')')
    assert(minetest.registered_nodes       ~= nil)
    assert(minetest.registered_nodes[name] == nil, name)
    local def                      = table.copy(get_base_liquid_def(false))
    def.description                = description
    def.tiles                      = {
        {
            name      = image,
            animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
        },
    }
    def.special_tiles              = {
        {
            name             = image,
            animation        = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0},
            backface_culling = false,
        },
    }
    def.liquid_alternative_source  = name
    def.liquid_alternative_flowing = flowing_name
    def.groups                     = def.groups or {
	    liquid = 3,
    }
    def.groups                     = ia_util.merge_groups(def.groups, groups)
    --def.alpha                      = alpha or def.alpha or 160
    def.use_texture_alpha          = alpha or def.alpha or 160
    
    minetest.register_node(name, def)
end

function ia_bucket.register_liquid_flowing(name, description, image, source_name, groups, alpha)
    --minetest.log('ia_bucket.register_liquid_flowing(name='..name..', source_name='..source_name..')')
    assert(minetest.registered_nodes       ~= nil)
    assert(minetest.registered_nodes[name] == nil, name)
    local def                      = table.copy(get_base_liquid_def(true))
    def.description                = description
    def.tiles                      = { image }
    def.special_tiles              = {
        {
            name             = image,
            animation        = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.8},
            backface_culling = false,
        },
    }
    def.liquid_alternative_source  = source_name
    def.liquid_alternative_flowing = name
    def.groups                     = def.groups or {
	    liquid                    = 3,
	    not_in_creative_inventory = 1,
    }
    def.groups                     = ia_util.merge_groups(def.groups, groups)
    --def.alpha                      = alpha or def.alpha or 160
    def.use_texture_alpha          = alpha or def.alpha or 160
    
    minetest.register_node(name, def)
end

local function get_images(inventory_image, color, alpha)
    alpha               = alpha or 200
    local color_suffix  = "^[colorize:" .. color .. ":" .. alpha
    -- FIXME too much blue tint
    --local source_image  = "default_water_source_animated.png" .. color_suffix
    --local flowing_image = "default_water_flowing_animated.png" .. color_suffix
    --local source_image  = "(default_water_source_animated.png^[greyscale)" .. color_suffix
    --local flowing_image = "(default_water_flowing_animated.png^[greyscale)" .. color_suffix
    --local bright_template = "^[greyscale^[contrast:50^[brightness:50"
    --local source_image  = "(default_water_source_animated.png" .. bright_template .. ")" .. color_suffix
    --local flowing_image = "(default_water_flowing_animated.png" .. bright_template .. ")" .. color_suffix
    local bleach_modifier = "^[greyscale^[contrast:10^[brightness:70"
    --local bleach_modifier = "^[greyscale^[contrast:70^[brightness:10"
    local source_image  = "(default_water_source_animated.png" .. bleach_modifier .. ")" .. color_suffix
    local flowing_image = "(default_water_flowing_animated.png" .. bleach_modifier .. ")" .. color_suffix
    --local bucket_image = 'bucket.png^(' .. '('..inventory_image..')' .. '^[colorize:'.. color .. ':'..alpha..')'
    local bucket_image  = 'bucket.png^(' .. '('..inventory_image..')' .. color_suffix..')'
    return {
--	['color_suffix']  = color_suffix,
	['source_image']  = source_image,
	['flowing_image'] = flowing_image,
	['bucket_image']  = bucket_image,
    }
end

function ia_bucket.register_liquid0(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups)
    --minetest.log('ia_bucket.register_liquid0(source_name='..source_name..', flowing_name='..flowing_name..', bucket_name='..bucket_name..', name='..name..')')
    alpha               = alpha      or node_alpha
    node_alpha          = node_alpha or alpha
    assert((alpha == nil and node_alpha == nil) or (alpha >= node_alpha), 'bucket liquid should be more opaque than source/flowing liquid')
    local images        = get_images(inventory_image, color, alpha)
    local source_image  = images.source_image
    local flowing_image = images.flowing_image
    local bucket_image  = images.bucket_image

    -- 1. Register Nodes
    ia_bucket.register_liquid_source (source_name,  name .. " Source",  source_image,  flowing_name, groups, node_alpha)
    ia_bucket.register_liquid_flowing(flowing_name, name .. " Flowing", flowing_image, source_name,  groups, node_alpha)

    -- 3. Register via MTG Bucket API
    bucket.register_liquid(
        source_name,
        flowing_name,
        bucket_name,
        bucket_image,
        'Bucket of ' .. name, -- No hardcoded "Juice"
        groups or {vessel = 1}
    )

    -- 4. Automatic Node-ification
    ia_bucket.register_bucket_node(bucket_name)
    ia_bucket.override_bucket_item(bucket_name)
    
    -- Track it in the library's internal list
    table.insert(ia_bucket.buckets, bucket_name)
end

function ia_bucket.register_liquid(modname, color, node_alpha, alpha, item_id, name, groups)
    --minetest.log('ia_bucket.register_liquid(modname='..modname..', item_id='..item_id..', name='..name..')')
    assert(modname and item_id)
    assert(minetest.get_modpath('drinks')) -- NOTE do not declare in mod.conf
    
    -- standard naming conventions
    local source_name     = modname .. ':flowspec_' .. item_id .. '_source'
    local flowing_name    = modname .. ':flowspec_' .. item_id .. '_flowing'
    local bucket_name     = modname .. ':bucket_'   .. item_id
    local inventory_image = 'drinks_bucket_contents.png'
    ia_bucket.register_liquid0(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups)
end
