local version = "v3.0.1"
local srcpath = minetest.get_modpath(minetest.get_current_modname()) .. "/src"

herobrine = {}

if not minetest.get_modpath("herobrine_awards") then
    herobrine_awards = {
        unlock = function() end
    }
end

minetest.register_privilege("herobrine_admin", {
    description = "Allows the player to use advanced commands with the In the Fog mod.",
    give_to_singleplayer = false,
    give_to_admin = true,
})

--> Callbacks.
dofile(srcpath .. "/callbacks.lua")

--> Commands.
dofile(srcpath .. "/commands.lua")

--> Functions.
dofile(srcpath .. "/functions/spawning.lua")
dofile(srcpath .. "/functions/daycount.lua")
dofile(srcpath .. "/functions/stalking.lua")
dofile(srcpath .. "/functions/lightning.lua")
dofile(srcpath .. "/functions/shrine.lua")
dofile(srcpath .. "/functions/doors.lua")
dofile(srcpath .. "/functions/jumpscare.lua")
dofile(srcpath .. "/functions/random_signs.lua")
dofile(srcpath .. "/functions/torch.lua")
--dofile(srcpath .. "/functions/crashing.lua") Might remove this feature in the future.
--dofile(srcpath .. "/functions/trees.lua") Disabled till further notice. Works but needs more technical fixing.

--> Mobs.
dofile(srcpath .. "/mobs/stalker.lua")
dofile(srcpath .. "/mobs/herobrine.lua")
dofile(srcpath .. "/mobs/footsteps.lua")

--dofile(srcpath .. "/tests.lua")

minetest.log("action", "[In the Fog] Mod initialized. VERSION: " .. version)