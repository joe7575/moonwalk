--[[

	Moon Walk Mod
	=============

	Copyright (C) 2017 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	2017-11-25  v0.01  first version

]]--

local TIMEOUT = 120 -- 2 minutes
local RADIUS = 50

local function switch_off(pos, clicker, meta)
	if meta:get_string("user") == clicker:get_player_name() then
		meta:set_int("running", 0)
		meta:set_string("infotext", "Moon Walk free")
		clicker:set_attribute("moonwalk_active", nil)
		clicker:set_physics_override({
				gravity = 1
		})
		clicker:setpos({x=pos.x, y=pos.y+1.5, z=pos.z})	
		clicker:setvelocity({x=0, y=0, z=0})
	end
end

local function control_player(pos, pos1, pos2, player)
	local meta = minetest.get_meta(pos)
	if player and player:get_player_name() == meta:get_string("user") then
		local running = meta:get_int("running") or 0
		local timeout = meta:get_int("timeout") or 1
		if running == 1 and timeout > 0 then
			-- check if outside of the construction area
			local correction = false
			local pl_pos = player:getpos()
			if pl_pos then
				if pl_pos.x < pos1.x then pl_pos.x = pos1.x; correction = true end
				if pl_pos.x > pos2.x then pl_pos.x = pos2.x; correction = true end
				if pl_pos.z < pos1.z then pl_pos.z = pos1.z; correction = true end
				if pl_pos.z > pos2.z then pl_pos.z = pos2.z; correction = true end
				if correction == true then
					local last_pos = minetest.string_to_pos(meta:get_string("last_known_pos"))
					player:setpos(last_pos)	
				else  -- store last known correct position
					meta:set_string("last_known_pos", minetest.pos_to_string(pl_pos))
				end
				minetest.after(1, control_player, pos, pos1, pos2, player)
			end
		else
			switch_off(pos, player, meta)
		end
		meta:set_int("timeout", timeout - 1)
	else
		meta:set_int("running", 0)
		meta:set_string("user", nil)
		meta:set_string("infotext", "Moon Walk free")
	end
end	

local function switch_on(pos, clicker, meta)
	-- prevent handing over to the next crane
	if clicker:get_attribute("moonwalk_active") ~= nil then  
		return
	end
	meta:set_int("running", 1)
	clicker:set_attribute("moonwalk_active", "true")
	meta:set_string("infotext", "Moon Walk busy")
	meta:set_string("user", clicker:get_player_name())
	meta:set_int("timeout", TIMEOUT)
	clicker:set_physics_override({
			gravity = 0.16 -- set gravity to 16% of its original value
			               -- (0.16 * 9.81)
	})
	local pos1 = {x=pos.x-RADIUS, y=pos.y, z=pos.z-RADIUS}
	local pos2 = {x=pos.x+RADIUS, y=pos.y, z=pos.z+RADIUS}
	control_player(pos, pos1, pos2, clicker)
end

minetest.register_node("moonwalk:startblock", {
	description = "Moon Walk",
	drawtype = "node",
	tiles = {"moonwalk.png"},
	
	-- switch ON/OFF
	on_rightclick = function (pos, node, clicker)
		local meta = minetest.get_meta(pos)
		local running = meta:get_int("running")
		if running == 1 then
			switch_off(pos, clicker, meta)
		else
			switch_on(pos, clicker, meta)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("running", 0)
		meta:set_string("infotext", "Moon Walk free")
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, not_in_creative_inventory=1},
})

minetest.register_lbm({
	label = "[Moonwalk] Node update",
	name = "moonwalk:update",
	nodenames = {"moonwalk:startblock"},
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("running", 0)
		meta:set_string("infotext", "Moon Walk free")
	end
})

minetest.register_on_joinplayer(function(player)
	player:set_physics_override({gravity=1, speed=1})	
end)

dofile(minetest.get_modpath("moonwalk") .. "/skydive.lua")
