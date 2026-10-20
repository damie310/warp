-- Warp for Luanti / Mineclonia
-- Players can use/list warps; only users with the "server" privilege can create/delete them.
local modname = minetest.get_current_modname()
local storage = minetest.get_mod_storage()

local function get_warps()
    local raw = storage:get_string("warps")
    if raw == "" then return {} end
    local ok, decoded = pcall(minetest.deserialize, raw)
    if ok and type(decoded) == "table" then return decoded end
    return {}
end

local function save_warps(warps)
    storage:set_string("warps", minetest.serialize(warps))
end

local function valid_name(name)
    return type(name) == "string" and #name >= 1 and #name <= 32
        and name:match("^[%w_%-]+$") ~= nil
end

local function is_admin(name)
    return minetest.check_player_privs(name, {server = true})
end

minetest.register_chatcommand("warp", {
    params = "[name]",
    description = "List available warps or teleport to one",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found." end
        local warp_name = (param or ""):match("^%s*(.-)%s*$")
        local warps = get_warps()
        if warp_name == "" then
            local names = {}
            for key in pairs(warps) do names[#names + 1] = key end
            table.sort(names)
            if #names == 0 then return true, "No warps have been created yet." end
            return true, "Available warps: " .. table.concat(names, ", ")
                .. ". Use /warp <name> to teleport."
        end
        local pos = warps[warp_name]
        if type(pos) ~= "table" or type(pos.x) ~= "number"
            or type(pos.y) ~= "number" or type(pos.z) ~= "number" then
            return false, "Warp not found. Use /warp to list available warps."
        end
        player:set_pos({x = pos.x, y = pos.y, z = pos.z})
        return true, "Teleported to warp '" .. warp_name .. "'."
    end,
})

minetest.register_chatcommand("setwarp", {
    params = "<name>",
    description = "Create or update a warp here (admin only)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found." end
        local warp_name = (param or ""):match("^%s*(.-)%s*$")
        if not valid_name(warp_name) then
            return false, "Use 1–32 letters, numbers, underscores, or hyphens for the warp name."
        end
        if not is_admin(name) then
            return false, "You need the server privilege to create warps."
        end
        local pos = player:get_pos()
        local warps = get_warps()
        local existed = warps[warp_name] ~= nil
        warps[warp_name] = {x = pos.x, y = pos.y, z = pos.z}
        save_warps(warps)
        return true, (existed and "Updated warp '" or "Created warp '") .. warp_name .. "'."
    end,
})

minetest.register_chatcommand("delwarp", {
    params = "<name>",
    description = "Delete a warp (admin only)",
    privs = {server = true},
    func = function(name, param)
        local warp_name = (param or ""):match("^%s*(.-)%s*$")
        if not valid_name(warp_name) then return false, "Provide a valid warp name." end
        if not is_admin(name) then return false, "You need the server privilege to delete warps." end
        local warps = get_warps()
        if not warps[warp_name] then return false, "Warp not found." end
        warps[warp_name] = nil
        save_warps(warps)
        return true, "Deleted warp '" .. warp_name .. "'."
    end,
})

minetest.register_chatcommand("warplist", {
    description = "List all available warps",
    func = function()
        local warps = get_warps()
        local names = {}
        for key in pairs(warps) do names[#names + 1] = key end
        table.sort(names)
        if #names == 0 then return true, "No warps have been created yet." end
        return true, "Available warps: " .. table.concat(names, ", ")
    end,
})
