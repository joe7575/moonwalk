--[[

	Moon Walk Mod
	=============

	Copyright (C) 2017 Joachim Stolberg
	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	2017-11-25  v0.01  first version

]]--


local function control_player(player)
	if player then
		local pos = player:getpos()
		local node = minetest.get_node_or_nil({x=pos.x, y=pos.y-2, z=pos.z})
		print(dump(pos))
		if node.name == "air" then
			local v = player:get_player_velocity()
			if v.y < -0.5 then
				player:set_physics_override({gravity = 0, speed=2})
			end
			minetest.after(1, control_player, player)
		else
			player:set_physics_override({gravity = 1, speed=1})		
		end
	end
end	

local function switch_on(clicker)
	clicker:set_physics_override({gravity = 0.05, speed=2})
	minetest.after(2, control_player, clicker)
end

minetest.register_node("moonwalk:skydive", {
	description = "Sky Dive",
	drawtype = "node",
	tiles = {"moonwalk_skydive.png"},
	on_rightclick = function (pos, node, clicker)
		switch_on(clicker)
	end,

	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=2, crumbly=2, not_in_creative_inventory=1},
})
