-- ia_placeable_buckets/register.lua
assert(minetest.get_modpath('bucket'))

-- Helper to safely get base liquid properties from MTG
--local function get_base_liquid_def(flowing)
local function get_base_liquid_def(base_name)
    assert(base_name ~= nil)
    --local base_name = flowing and "default:water_flowing" or "default:water_source"
    ----local base_name = flowing and "default:lava_flowing" or "default:lava_source" -- NOTE testing
    local base_def  = minetest.registered_nodes[base_name]
    assert(base_def ~= nil)
    return base_def
end

function placeable_buckets.register_liquid_source(name, description, image, flowing_name, groups, alpha, base_name)
    --minetest.log('placeable_buckets.register_liquid_source(name='..name..', flowing_name='..flowing_name..')')
    assert(name ~= nil)
    assert(description ~= nil)
    assert(image ~= nil)
    assert(flowing_name ~= nil)
    assert(groups ~= nil)
    --assert(alpha ~= nil)
    assert(base_name ~= nil)
    assert(minetest.registered_nodes       ~= nil)
    assert(minetest.registered_nodes[name] == nil, name)
    --local def                      = table.copy(get_base_liquid_def(false))
    local def                      = table.copy(get_base_liquid_def(base_name))
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

function placeable_buckets.register_liquid_flowing(name, description, image, source_name, groups, alpha, base_name)
    --minetest.log('placeable_buckets.register_liquid_flowing(name='..name..', source_name='..source_name..')')
    assert(name ~= nil)
    assert(description ~= nil)
    assert(image ~= nil)
    assert(source_name ~= nil)
    assert(groups ~= nil)
    assert(minetest.registered_nodes       ~= nil)
    assert(minetest.registered_nodes[name] == nil, name)
    --assert(alpha ~= nil)
    assert(base_name ~= nil)
    --local def                      = table.copy(get_base_liquid_def(true))
    local def                      = table.copy(get_base_liquid_def(base_name))
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

local function get_images(inventory_image, color, alpha, bucket_image_suffix)
    assert(inventory_image ~= nil)
    assert(color ~= nil)
    --assert(alpha ~= nil)
    assert(bucket_image_suffix ~= nil)
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
    if bucket_image_suffix and bucket_image_suffix ~= '' then
    bucket_image        = bucket_image .. '^('..bucket_image_suffix..')'
    --bucket_image        = bucket_image .. '^'..bucket_image_suffix
    end
    return {
--	['color_suffix']  = color_suffix,
	['source_image']  = source_image,
	['flowing_image'] = flowing_image,
	['bucket_image']  = bucket_image,
    }
end

function placeable_buckets.register_liquid0(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups, bucket_image_suffix, base_name_source, base_name_flowing)
    --minetest.log('placeable_buckets.register_liquid0(source_name='..source_name..', flowing_name='..flowing_name..', bucket_name='..bucket_name..', name='..name..')')
    assert(source_name ~= nil)
    assert(flowing_name ~= nil)
    assert(bucket_name ~= nil)
    assert(color ~= nil)
    --assert(node_alpha ~= nil)
    --assert(alpha ~= nil)
    assert(inventory_image ~= nil)
    assert(name ~= nil)
    assert(groups ~= nil)
    assert(bucket_image_suffix ~= nil)
    assert(base_name_source ~= nil)
    assert(base_name_flowing ~= nil)
    alpha               = alpha      or node_alpha
    node_alpha          = node_alpha or alpha
    assert((alpha == nil and node_alpha == nil) or (alpha >= node_alpha), 'bucket liquid should be more opaque than source/flowing liquid')
    local images        = get_images(inventory_image, color, alpha, bucket_image_suffix)
    local source_image  = images.source_image
    local flowing_image = images.flowing_image
    local bucket_image  = images.bucket_image

    -- 1. Register Nodes
    placeable_buckets.register_liquid_source (source_name,  name .. " Source",  source_image,  flowing_name, groups, node_alpha, base_name_source)
    placeable_buckets.register_liquid_flowing(flowing_name, name .. " Flowing", flowing_image, source_name,  groups, node_alpha, base_name_flowing)

    placeable_buckets.register_liquid1(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups, bucket_image_suffix, '')
end

function placeable_buckets.register_liquid1(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups, bucket_image_suffix, name_prefix)
    --minetest.log('placeable_buckets.register_liquid0(source_name='..source_name..', flowing_name='..flowing_name..', bucket_name='..bucket_name..', name='..name..')')
    assert(source_name ~= nil)
    assert(flowing_name ~= nil)
    assert(bucket_name ~= nil)
    assert(color ~= nil)
    --assert(node_alpha ~= nil)
    --assert(alpha ~= nil)
    assert(inventory_image ~= nil)
    assert(name ~= nil)
    assert(groups ~= nil)
    assert(bucket_image_suffix ~= nil)
    assert(name_prefix ~= nil)
    alpha               = alpha      or node_alpha
    node_alpha          = node_alpha or alpha
    assert((alpha == nil and node_alpha == nil) or (alpha >= node_alpha), 'bucket liquid should be more opaque than source/flowing liquid')
    local images        = get_images(inventory_image, color, alpha, bucket_image_suffix)
    local source_image  = images.source_image
    local flowing_image = images.flowing_image
    local bucket_image  = images.bucket_image
    -- 3. Register via MTG Bucket API
    bucket.register_liquid(
        source_name,
        flowing_name,
        bucket_name,
        bucket_image,
        name_prefix .. 'Bucket of ' .. name, -- No hardcoded "Juice"
        groups or {vessel = 1}
    )

    -- 4. Automatic Node-ification
    placeable_buckets.register_bucket_node(bucket_name)
    placeable_buckets.override_bucket_item(bucket_name)
    
    -- Track it in the library's internal list
    table.insert(placeable_buckets.buckets, bucket_name)
end

function placeable_buckets.register_liquid(modname, color, node_alpha, alpha, item_id, name, groups, base_name_source, base_name_flowing)
    --minetest.log('placeable_buckets.register_liquid(modname='..modname..', item_id='..item_id..', name='..name..')')
    assert(modname ~= nil)
    assert(color ~= nil)
    --assert(node_alpha ~= nil)
    --assert(alpha ~= nil)
    assert(item_id ~= nil)
    assert(name ~= nil)
    assert(groups ~= nil)
    assert(base_name_source ~= nil)
    assert(base_name_flowing ~= nil)
    --assert(minetest.get_modpath('drinks')) -- NOTE do not declare in mod.conf
    
    -- standard naming conventions
    --local source_name     = modname .. ':flowspec_' .. item_id .. '_source'
    --local flowing_name    = modname .. ':flowspec_' .. item_id .. '_flowing'
    local source_name     = modname .. ':' .. item_id .. '_source'
    local flowing_name    = modname .. ':' .. item_id .. '_flowing'
    local bucket_name     = modname .. ':bucket_'   .. item_id
    local inventory_image = 'drinks_bucket_contents.png'
    placeable_buckets.register_liquid0(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups, '', base_name_source, base_name_flowing)

    if not ia_util.has_wooden_bucket_redo() then return end
    local bucket_name     = modname .. ':bucket_wood_'   .. item_id
    --inventory_image       = inventory_image .. '^wooden_bucket_overlay.png'
    placeable_buckets.register_liquid1(source_name, flowing_name, bucket_name, color, node_alpha, alpha, inventory_image, name, groups, 'wooden_bucket_overlay.png', 'Wooden ')
end








function placeable_buckets.get_on_use(satiates, quenches, return_item)
    assert(satiates    ~= nil)
    assert(quenches    ~= nil)
    assert(return_item ~= nil)
    local heals             = satiates
    if minetest.get_modpath('thirsty')   then
        return function(itemstack, user, pointed_thing)
	    assert(itemstack ~= nil)
	    assert(usuer ~= nil)
	    assert(pointed_thing ~= nil)
            thirsty.drink(user, quenches, 20)
            local  eat_func = minetest.item_eat(heals, return_item)
            return eat_func(itemstack, user, pointed_thing)
        end
    end
    if minetest.get_modpath('hunger_ng') then
        return function(itemstack, user, pointed_thing)
	    assert(itemstack ~= nil)
	    assert(user ~= nil)
	    assert(pointed_thing ~= nil)
            -- hunger_ng handles the actual restoration logic; 0 prevents vanilla healing
            local  eat_func = minetest.item_eat(0,     return_item)
            return eat_func(itemstack, user, pointed_thing)
        end
    end
    -- vanilla
    return function(itemstack, user, pointed_thing)
	    assert(itemstack ~= nil)
	    assert(usuer ~= nil)
	    assert(pointed_thing ~= nil)
        local      eat_func = minetest.item_eat(heals, return_item)
        return     eat_func(itemstack, user, pointed_thing)
    end
end

placeable_buckets.register_drink = function( name, template, def ) -- drinks/init.lua
   assert(name ~= nil)
   assert(template ~= nil)
   assert(def ~= nil)
   local template_def = minetest.registered_nodes[template]
   assert(template_def                    ~= nil)
   assert(minetest.registered_nodes[name] == nil)
   --if template_def then
   local drinks_def = table.copy(template_def)

   -- replace/add values
   for k,v in pairs(def) do
      if k == "groups" then
         -- special handling for groups: merge instead replace
         for g,n in pairs(v) do
            drinks_def[k][g] = n
         end
      else
         drinks_def[k]=v
      end
   end

   if def.inventory_image then
      drinks_def.wield_image = drinks_def.inventory_image
      drinks_def.tiles = { drinks_def.inventory_image }
   end

   minetest.register_node( name, drinks_def )
   --end
end

function placeable_buckets.register_drink_vessel0(modname, item_id, name, desc, inventory_image, return_item, multiplier, heals)
    --assert(minetest.get_modpath('drinks'))
    minetest.log('register_drink_vessel0(modname='..modname..', item_id='..item_id..', name='..name..', desc='..desc..', inventory_image='..inventory_image..', return_item='..return_item..', multiplier='..tostring(multiplier)..', heals='..tostring(heals)..')')
    assert(modname ~= nil)
    assert(item_id         ~= nil)
    assert(name            ~= nil)
    assert(desc            ~= nil)
    assert(inventory_image ~= nil)
    assert(return_item     ~= nil)
    assert(multiplier      ~= nil)
    assert(multiplier == tonumber(multiplier))
    assert(heals ~= nil)
    assert(heals == tonumber(heals))
    heals = (heals or 0)
    local satiates = 2 * multiplier
    local quenches = 3 * multiplier
    local on_use   = placeable_buckets.get_on_use(satiates, quenches, return_item)

    item_id = modname..':'..item_id
    --if minetest.get_modpath("drinks") then
        --drinks.register_item(item_id, return_item, {
        placeable_buckets.register_drink(item_id, return_item, {
            description     = desc,
            groups          = {drink = 1}, -- h2o=3 for claycrafter
            --juice_type = name,
            inventory_image = inventory_image,
            on_use          = on_use,
        })
    --end

    if not minetest.get_modpath("hunger_ng") then return end
    assert(minetest.get_modpath("hunger_ng"))
    if placeable_buckets.hunger_ng_upstreams[modname] then return end
    assert(not placeable_buckets.hunger_ng_upstreams[modname])
    minetest.log('modname: '..modname)
    --if minetest.get_modpath("hunger_ng") then
        hunger_ng.add_hunger_data(item_id, {
            satiates = satiates,
            heals    = heals,
            quenches = quenches, -- TODO check for hunger_ng redo
            returns  = return_item,
        })
    --end
end

function placeable_buckets.register_drink_vessels(modname, color, item_id, name, multiplier, heals, source, flowing, bucket, wooden_bucket)
    minetest.log('register_drink_vessels(modname='..modname..', color='..color..', item_id='..item_id..', name='..name..', multiplier='..tostring(multiplier)..', heals='..tostring(heals)..', source='..source..', flowing='..flowing..', bucket='..bucket..', wooden_bucket='..tostring(wooden_bucket)..')')
    --assert(minetest.get_modpath('drinks'))
    assert(modname    ~= nil)
    assert(color      ~= nil)
    assert(item_id    ~= nil)
    assert(name       ~= nil)
    assert(multiplier ~= nil)
    assert(multiplier == tonumber(multiplier))
    assert(heals      ~= nil)
    assert(heals == tonumber(heals))
    assert(source     ~= nil)
    assert(flowing    ~= nil)
    assert(bucket     ~= nil)
    --assert(wooden_bucket ~= nil)
    --local jcu_name        = modname..':jcu_'..item_id
    --local jbo_name        = modname..':jbo_'..item_id
    --local jsb_name        = modname..':jsb_'..item_id
    local jcu_name        = 'jcu_'..item_id
    local jbo_name        = 'jbo_'..item_id
    local jsb_name        = 'jsb_'..item_id
    local jcu_desc        = 'Cup of '              .. name
    local jbo_desc        = 'Bottle of '           .. name
    local jsb_desc        = 'Heavy Steel Bottle (' .. name .. ')' -- ' Juice)'
    local jcu_image       = 'drinks_glass_contents.png^[colorize:'  .. color .. ':200^drinks_drinking_glass.png'
    local jbo_image       = 'drinks_bottle_contents.png^[colorize:' .. color .. ':200^drinks_glass_bottle.png'
    local jsb_image       = 'vessels_steel_bottle.png'
    multiplier            = (multiplier or 0)
    placeable_buckets.register_drink_vessel0(modname, jcu_name, name, jcu_desc, jcu_image, 'vessels:drinking_glass', multiplier * 1, heals)
    assert(not placeable_buckets.drinking_glasses[modname..':'..jcu_name])
    placeable_buckets.drinking_glasses[modname..':'..jcu_name] = {
	    bucket        = bucket,
	    flowing       = flowing,
	    source        = source,
	    wooden_bucket = wooden_bucket,
    }
    assert(placeable_buckets.drinking_glasses[modname..':'..jcu_name])

    placeable_buckets.register_drink_vessel0(modname, jbo_name, name, jbo_desc, jbo_image, 'vessels:glass_bottle',   multiplier * 2, heals)
    assert(not placeable_buckets.glass_bottles[modname..':'..jbo_name])
    placeable_buckets.glass_bottles[modname..':'..jbo_name] = {
	    bucket        = bucket,
	    flowing       = flowing,
	    source        = source,
	    wooden_bucket = wooden_bucket,
    }
    assert(placeable_buckets.glass_bottles[modname..':'..jbo_name])

    placeable_buckets.register_drink_vessel0(modname, jsb_name, name, jsb_desc, jsb_image, 'vessels:steel_bottle',   multiplier * 2, heals)
    assert(not placeable_buckets.heavy_steel_bottles[modname..':'..jsb_name])
    placeable_buckets.heavy_steel_bottles[modname..':'..jsb_name] = {
	    bucket        = bucket,
	    flowing       = flowing,
	    source        = source,
	    wooden_bucket = wooden_bucket,
    }
    assert(placeable_buckets.heavy_steel_bottles[modname..':'..jsb_name])
end
