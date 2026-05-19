--[[

	Moon Walk Mod
	=============

	Copyright (C) 2017-2026 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	2017-11-25  v0.01  first version
	2026-05-17  v0.02  updated to new API, added player physics locking pattern
	2026-05-19  v0.03  simplified to gravity-only and require player_monoids

]]--

local TIMEOUT = 120 -- timeout in seconds (2 minutes)
local RADIUS = 50   -- effect radius around the moonwalk block
local MOON_GRAVITY = 0.12
local GRAVITY_CHANGE_ID = "moonwalk:gravity"

local function set_player_gravity(player, gravity)
	player_monoids.gravity:add_change(player, gravity, GRAVITY_CHANGE_ID)
end

local function clear_player_gravity(player)
	player_monoids.gravity:del_change(player, GRAVITY_CHANGE_ID)
end

local function restore_player_physics(player)
	local meta = player:get_meta()
	
	if meta:get_int("moonwalk_is_active") == 1 then
		meta:set_int("moonwalk_is_active", 0)
		clear_player_gravity(player)
	end
end

local function switch_off(pos, clicker, meta)
	if meta:get_string("user") == clicker:get_player_name() then
		meta:set_int("running", 0)
		meta:set_string("user", "")
		meta:set_string("infotext", "Moon Walk free")
		restore_player_physics(clicker)
		clicker:set_pos({x=pos.x, y=pos.y+1.5, z=pos.z})	
	end
end

local function control_player(pos, pos1, pos2, player_name)
	local player = core.get_player_by_name(player_name)
	local meta = core.get_meta(pos)
	if player and player_name == meta:get_string("user") then
		local running = meta:get_int("running") or 0
		local timeout = meta:get_int("timeout") or 1
		if running == 1 and timeout > 0 then
			set_player_gravity(player, MOON_GRAVITY)
			-- check if player is outside of the moonwalk radius
			local correction = false
			local pl_pos = player:get_pos()
			if pl_pos then
				if pl_pos.x < pos1.x then pl_pos.x = pos1.x; correction = true end
				if pl_pos.x > pos2.x then pl_pos.x = pos2.x; correction = true end
				if pl_pos.z < pos1.z then pl_pos.z = pos1.z; correction = true end
				if pl_pos.z > pos2.z then pl_pos.z = pos2.z; correction = true end
				if correction == true then
					local last_pos = core.string_to_pos(meta:get_string("last_known_pos"))
					player:set_pos(last_pos)	
				else  -- store last known correct position
					meta:set_string("last_known_pos", core.pos_to_string(pl_pos))
				end
				core.after(1, control_player, pos, pos1, pos2, player_name)
			end
		else
			switch_off(pos, player, meta)
		end
		meta:set_int("timeout", timeout - 1)
	else
		meta:set_int("running", 0)
		meta:set_string("user", "")
		meta:set_string("infotext", "Moon Walk free")
	end
end	

local function switch_on(pos, clicker, meta)
	local player_meta = clicker:get_meta()

	-- activate moon gravity
	set_player_gravity(clicker, MOON_GRAVITY)
	player_meta:set_int("moonwalk_is_active", 1)

	meta:set_int("running", 1)
	meta:set_string("infotext", "Moon Walk busy")
	meta:set_string("user", clicker:get_player_name())
	meta:set_int("timeout", TIMEOUT)

	local pos1 = {x=pos.x-RADIUS, y=pos.y, z=pos.z-RADIUS}
	local pos2 = {x=pos.x+RADIUS, y=pos.y, z=pos.z+RADIUS}
	control_player(pos, pos1, pos2, clicker:get_player_name())
end

core.register_node("moonwalk:startblock", {
	description = "Moon Walk",
	drawtype = "node",
	tiles = {"moonwalk_top.png", "moonwalk_top.png", "moonwalk.png"},
	
	-- switch ON/OFF
	on_rightclick = function (pos, node, clicker)
		local meta = core.get_meta(pos)
		local running = meta:get_int("running")
		if running == 1 then
			switch_off(pos, clicker, meta)
		else
			switch_on(pos, clicker, meta)
		end
	end,

	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_int("running", 0)
		meta:set_string("infotext", "Moon Walk free")
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 10,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
})

core.register_lbm({
	label = "[Moonwalk] Node update",
	name = "moonwalk:update",
	nodenames = {"moonwalk:startblock"},
	run_at_every_load = true,
	action = function(pos, node)
		local meta = core.get_meta(pos)
		meta:set_int("running", 0)
		meta:set_string("infotext", "Moon Walk free")
	end
})

core.register_on_joinplayer(function(player)
	restore_player_physics(player)
end)

core.register_on_respawnplayer(function(player)
	restore_player_physics(player)
end)

core.register_on_leaveplayer(function(player)
	restore_player_physics(player)
end)

core.register_on_dieplayer(function(player)
	restore_player_physics(player)
end)

core.register_craft({
	output = "moonwalk:startblock",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:copper_ingot", "default:mese", "default:copper_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"}
	}
})
