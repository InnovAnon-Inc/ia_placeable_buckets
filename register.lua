-- ia_placeable_buckets/register.lua
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
    --local bleach_modifier = "^[greyscale^[contrast:10^[brightness:70"
    ----local bleach_modifier = "^[greyscale^[contrast:70^[brightness:10"
    --local source_image  = "(default_water_source_animated.png" .. bleach_modifier .. ")" .. color_suffix
    --local flowing_image = "(default_water_flowing_animated.png" .. bleach_modifier .. ")" .. color_suffix
    local kill_blue = "^[brighten^[multiply:#ffffff"
    local source_image  = "(default_water_source_animated.png" .. kill_blue .. ")" .. color_suffix
    local flowing_image = "(default_water_flowing_animated.png" .. kill_blue .. ")" .. color_suffix
    --local mask_logic = "^[greyscale^[contrast:20^[brightness:50"
    --local source_image  = "(default_water_source_animated.png" .. mask_logic .. ")" .. color_suffix
    --local flowing_image = "(default_water_flowing_animated.png" .. mask_logic .. ")" .. color_suffix
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
    --local source_name     = modname .. ':flowspec_' .. item_id .. '_source'
    --local flowing_name    = modname .. ':flowspec_' .. item_id .. '_flowing'
    local source_name     = modname .. ':' .. item_id .. '_source'
    local flowing_name    = modname .. ':' .. item_id .. '_flowing'
    local bucket_name     = modname .. ':bucket_'   .. item_id
    local inventory_image = 'drinks_bucket_contents.png'
    ia_bucket.register_liquid0(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups)
end








function ia_bucket.get_on_use(satiates, quenches, return_item)
    assert(satiates    ~= nil)
    assert(quenches    ~= nil)
    assert(return_item ~= nil)
    local heals             = satiates
    if minetest.get_modpath('thirsty')   then
        return function(itemstack, user, pointed_thing)
            thirsty.drink(user, quenches, 20)
            local  eat_func = minetest.item_eat(heals, return_item)
            return eat_func(itemstack, user, pointed_thing)
        end
    end
    if minetest.get_modpath('hunger_ng') then
        return function(itemstack, user, pointed_thing)
            -- hunger_ng handles the actual restoration logic; 0 prevents vanilla healing
            local  eat_func = minetest.item_eat(0,     return_item)
            return eat_func(itemstack, user, pointed_thing)
        end
    end
    -- vanilla
    return function(itemstack, user, pointed_thing)
        local      eat_func = minetest.item_eat(heals, return_item)
        return     eat_func(itemstack, user, pointed_thing)
    end
end

function ia_bucket.register_drink_vessel0(item_id, name, desc, inventory_image, return_item, multiplier)
    assert(minetest.get_modpath('drinks'))
    assert(item_id         ~= nil)
    assert(name            ~= nil)
    assert(desc            ~= nil)
    assert(inventory_image ~= nil)
    assert(return_item     ~= nil)
    assert(multiplier      ~= nil)
    local satiates = 2 * multiplier
    local quenches = 3 * multiplier
    local on_use   = ia_bucket.get_on_use(satiates, quenches, return_item)

    drinks.register_item(item_id, return_item, {
        description     = desc,
        groups          = {drink = 1},
        --juice_type = name,
        inventory_image = inventory_image,
        on_use          = on_use,
    })

    if minetest.get_modpath("hunger_ng") then
        hunger_ng.add_hunger_data(item_id, {
            satiates = satiates,
            heals    = 0,
            quenches = quenches,
            returns  = return_item,
        })
    end
end

function ia_bucket.register_drink_vessels(modname, color, item_id, name)
    assert(minetest.get_modpath('drinks'))
    assert(modname ~= nil)
    assert(color   ~= nil)
    assert(item_id ~= nil)
    assert(name    ~= nil)
    local jcu_name        = modname..':jcu_'..item_id
    local jbo_name        = modname..':jbo_'..item_id
    local jsb_name        = modname..':jsb_'..item_id
    local jcu_desc        = 'Cup of '              .. name .. ' Juice'
    local jbo_desc        = 'Bottle of '           .. name .. ' Juice'
    local jsb_desc        = 'Heavy Steel Bottle (' .. name .. ' Juice)'
    local jcu_image       = 'drinks_glass_contents.png^[colorize:'  .. color .. ':200^drinks_drinking_glass.png'
    local jbo_image       = 'drinks_bottle_contents.png^[colorize:' .. color .. ':200^drinks_glass_bottle.png'
    local jsb_image       = 'vessels_steel_bottle.png'
    ia_bucket.register_drink_vessel0(jcu_name, name, jcu_desc, jcu_image, 'vessels:drinking_glass', 1)
    ia_bucket.register_drink_vessel0(jbo_name, name, jbo_desc, jbo_image, 'vessels:glass_bottle',   2)
    ia_bucket.register_drink_vessel0(jsb_name, name, jsb_desc, jsb_image, 'vessels:steel_bottle',   2)
end
