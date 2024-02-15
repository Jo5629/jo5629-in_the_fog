--> Save the settings on a world-to-world basis.

function herobrine_settings.get_setting_def(name)
    return herobrine_settings.settings_defs[name]
end

function herobrine_settings.get_settings_list()
    return herobrine_settings.settings_list
end

function herobrine_settings.register_setting(name, def)
    local types = {["table"] = true, ["boolean"] = true, ["string"] = true, ["number"] = true}
    if def.type ~= type(def.value) or not types[def.type]  then
        minetest.log("error", string.format("[In the Fog] Was not able to register: %s", name))
        return false
    end
    if def.description == nil then def.description = "Not defined." end

    herobrine_settings.settings[name] = def.value
    herobrine_settings.settings_defs[name] = def
    table.insert(herobrine_settings.settings_list, name)
    minetest.log("action", string.format("[In the Fog] Registered setting: %s", name))
    return true
end

function herobrine_settings.get_setting(name)
    return herobrine_settings.settings[name]
end

function herobrine_settings.set_setting(name, val)
    local def = herobrine_settings.get_setting_def(name)
    local def_type = def.type
    local min, max = def.min or 0, def.max or 65536
    if not val then
        minetest.log("warning", string.format("[In the Fog] Was not able to overwrite setting: %s.", name))
        return false
    end
    if def_type == "number" and not tonumber(val) and not (tonumber(val) >= min and tonumber(val) <= max) then
        herobrine_settings.settings[name] = tonumber(val)
    elseif def_type == "table" then
        if minetest.deserialize(val) ~= nil then herobrine_settings.settings[name] = minetest.deserialize(val) end
    elseif def_type == "boolean" then
        local booleans = {["false"] = false, ["true"] = true}
        if booleans[val] ~= nil then herobrine_settings.settings[name] = booleans[val] end
    elseif def_type == "string" then
        herobrine_settings.settings[name] = val
    end

    minetest.log("action", string.format("[In the Fog] Was able to override setting: %s", name))
    return true
end

function herobrine_settings.save_settings()
    local file = Settings(minetest.get_worldpath() .. "/herobrine_settings.conf")
    for k, v in pairs(herobrine_settings.settings) do
        local setting_type = herobrine_settings.get_setting_def(k).type
        if setting_type == "table" then
            file:set(k, minetest.serialize(v))
        elseif setting_type == "string" or setting_type == "number" or setting_type == "boolean" then
            file:set(k, v)
        end
    end
    local success = file:write()
    return success
end

function herobrine_settings.load_settings()
    local settings = Settings(minetest.get_worldpath() .. "/herobrine_settings.conf")
    local settings_table = settings:to_table()
    for k, v in pairs(settings_table) do
        --> Write in the logs what settings were modified in the config file. Good for debugging.
        local old_val = herobrine_settings.get_setting(k)
        if type(old_val) == "table" then
            local new_table = minetest.serialize(old_val)
            old_val = new_table
        end

        if tostring(old_val) ~= v and old_val ~= nil then
            local log = string.format("[In the Fog] Setting %s has been modified from %s to %s.", k, tostring(old_val), v)
            minetest.log("action", log)
        end

        --> Actually write to the in-game settings table.
        herobrine_settings.set_setting(k, v)
    end
    return true
end

minetest.register_on_shutdown(function()
    herobrine_settings.save_settings()
end)