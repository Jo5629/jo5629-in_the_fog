local signs_lib_enabled = minetest.get_modpath("signs_lib")
if signs_lib_enabled then
    minetest.log("info", "[In the Fog] signs_lib is enabled, using that for random_signs.lua")
end

herobrine.signs = {}

local words_table = {
    ["en"] = {
        "I am watching you...",
        "On your six!",
    },
}
words_table["default"] = words_table["en"]

function herobrine.signs.register_text(lang_table, text_table)
    for _, lang in pairs(lang_table) do
        for _, text in pairs(text_table) do
            table.insert(words_table[lang], text)
        end
    end
end

function herobrine.signs.get_full_lang_table()
    return words_table
end

function herobrine.signs.get_lang_table(lang)
    if not lang then lang = "default" end
    return words_table[lang]
end

function herobrine.signs.generate_random_text(lang)
    if not words_table[lang] or not lang then
        lang = "default"
    end
    return words_table[lang][math.random(1, #words_table[lang])], true
end

--> Took and updated the function from herobrine.find_position_near()
function herobrine.signs.find_position_near(pos, radius)
    if not radius or radius > 70 then --> As long as the radius is <= 79 we will be okay. Lower the bar a little more to be safe.
        radius = math.random(40, 60)
    end
    local pos1 = {x = pos.x - radius, y = pos.y - radius, z = pos.z - radius}
    local pos2 = {x = pos.x + radius, y = pos.y + radius, z = pos.z + radius}
    local nodes = minetest.find_nodes_in_area_under_air(pos1, pos2, herobrine_settings.get_setting("signs_spawnable_on"))
    table.shuffle(nodes)
    local found = false
    local newpos = pos
    for _, node_pos in pairs(nodes) do
        local temp_pos = {x = node_pos.x, y = node_pos.y + 2, z = node_pos.z}
        if minetest.get_node(temp_pos).name == "air"  then
            newpos = node_pos
            found = true
            break
        end
    end
    if found then
        newpos.y = newpos.y + 1
        return newpos, found
    else
        return pos, found
    end
end

local sign_node = "default:sign_wall_wood" --> Use this so that signs_lib is not usually needed.
function herobrine.signs.place_sign(pos, text)
    minetest.set_node(pos, {name = sign_node, param2 = 1})
    if signs_lib_enabled then
        signs_lib.update_sign(pos, {text = text})
        return true
    else
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", text)
        meta:set_string("text", text) --> Hope to still be viewed after sign_lib is enabled.
        return true
    end
end

local function place_random_sign(pname, target, range, waypoint)
    local playerobj = minetest.get_player_by_name(pname)
    local targetobj = minetest.get_player_by_name(target)
    if not targetobj then
        return false, string.format("Could not find player %s.", target)
    end
    if type(range) ~= "number" then
        return false, "Range is not an actual number."
    end
    local pos, found = herobrine.signs.find_position_near(targetobj:get_pos(), range)
    if not found then
        return "Was not able to find an eligible node."
    end
    herobrine.signs.place_sign(pos, herobrine.signs.generate_random_text())
    if waypoint == "true" then
        local id = playerobj:hud_add({
            hud_elem_type = "waypoint",
            name = "Position of Sign",
            text = "m",
            number = 0x85FF00,
            world_pos = pos,
        })
        minetest.after(7, function()
            playerobj:hud_remove(id)
        end)
    end
    return true, string.format("Placed a sign at %s.", minetest.pos_to_string(pos, 1))
end

herobrine.register_subcommand("place_random_sign :target :num :waypoint", {
    privs = herobrine.commands.default_privs,
    description = "Places a random sign with text around the player",
    func = function(name, target, num, waypoint)
        return place_random_sign(name, target, tonumber(num), waypoint)
    end
})