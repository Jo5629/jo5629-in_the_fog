local storage = minetest.get_mod_storage()

local function num_mese(pos)
    local pos1 = {x = pos.x + 1, y = pos.y - 1, z = pos.z + 1}
    local pos2 = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
    local nodes = minetest.find_nodes_in_area(pos1, pos2, "default:mese")
    return #nodes
end

minetest.register_node("herobrine:shrine_node", {
    description = "Node used for the Herobrine shrine",
    tiles = {"default_coal_block.png"},
    is_ground_content = false,
    groups = {cracky = 3},
    sounds = default.node_sound_stone_defaults(),
    on_ignite = function(pos, igniter)
        local interval = herobrine_settings.get_setting("shrine_interval")
        local old_time = storage:get_int("herobrine:shrine_gametime")

        local name = igniter:get_player_name()
        local time_left = (old_time - minetest.get_gametime()) * -1
        if not (old_time == 0 or time_left > interval) then
            minetest.chat_send_player(name, string.format("[In the Fog] %d seconds left.", interval - time_left))
            return
        end

        local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        local node_name = minetest.get_node(flame_pos).name
        if num_mese(pos) == 9 and node_name == "air" then
            local timeofday = minetest.get_timeofday() * 24
            if timeofday < 20 then
                minetest.set_timeofday(20/24)
            end

            old_time = minetest.get_gametime()
            storage:set_int("herobrine:shrine_gametime", old_time)

            minetest.after(2, function()
                herobrine.lightning_strike(flame_pos)
                if node_name == "fire:basic_flame" or node_name == "lightning:dying_flame" or node_name == "air" then
                    minetest.set_node(flame_pos, {name = "fire:permanent_flame"})
                end
                minetest.chat_send_all(minetest.colorize("#FF0000", "WARNING. UNKNOWN SPECIMEN FOUND."))
                local pos = {x = flame_pos.x, y = flame_pos.y + 1, z = flame_pos.z}

                herobrine.spawnHerobrine("herobrine:herobrine", pos)
            end)
        end
    end
})

minetest.register_craft({
    type = "shapeless",
    output = "herobrine:shrine_node 2",
    recipe = {
        "default:coalblock",
        "default:diamond"
    },
})