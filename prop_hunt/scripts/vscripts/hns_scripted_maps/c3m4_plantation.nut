// Squirrel
// Prop Hunt
// c3m4 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props/de_inferno/wood_fence.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break01.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break02.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break03.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break04.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break05.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break06.mdl");
	hEntity.PrecacheModel("models/props_downtown/door_interior_128_01.mdl");
}

local rValue = RandomInt(1, 2);
if (rValue == 1)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-796.691, -1075.977, 40.031)
		Vector(-787.280, -707.099, 40.031)
		Vector(-830.382, -1594.792, 40.031)
		Vector(-825.279, -1226.695, 40.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-1960.458, -805.503, 16.031)
		Vector(-1133.246, -3282.094, 2.031)
		Vector(1654.305, -3233.253, 66.031)
		Vector(1689.631, -893.995, 176.932)
	]
	g_HnS.PropList[1] <- {name = "fridge002", model = "models/props_urban/fridge002.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(18, 18, 78), mins = Vector(-18, -18, 0)}
	g_HnS.PropList[2] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
	g_HnS.PropList[3] <- {name = "plastic_bucket001", model = "models/props_urban/plastic_bucket001.mdl", hitbox = 0.4, nocollision = true}
	g_HnS.PropList[4] <- {name = "plastic_icechest001", model = "models/props_urban/plastic_icechest001.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[5] <- {name = "plastic_water_jug001", model = "models/props_urban/plastic_water_jug001.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[6] <- {name = "sleeping_bag3", model = "models/props_equipment/sleeping_bag3.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 16), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[7] <- {name = "sofa_chair01", model = "models/props_interiors/sofa_chair01.mdl" hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(24, 24, 38), mins = Vector(-24, -24, 0)}
	g_HnS.PropList[8] <- {name = "stove02", model = "models/props_interiors/stove02.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[9] <- {name = "waterheater", model = "models/props_interiors/waterheater.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 96), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[10] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	g_HnS.PropList[11] <- {name = "urban_bigplant01", model = "models/props_foliage/urban_bigplant01.mdl", hitbox = 1.1, nocollision = true}
	g_HnS.PropList[12] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_furniture/it_mkt_table2.mdl", origin = Vector(-2502.617, -1020.767, 65.031), angles = Vector(10, 0, -80), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props/de_inferno/wood_fence.mdl", origin = Vector(-2362.428, -1296.994, 43.502), angles = Vector(0, 75, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props/de_inferno/wood_fence.mdl", origin = Vector(-2362.428, -1296.994, 0.502), angles = Vector(0, 75, 0), solid = 6});
}
else
{
	g_aHunterSpawnOrigin <-
	[
		Vector(2077.776, 4.211, 224.031)
		Vector(2117.326, 7.587, 224.031)
		Vector(2034.427, 1.865, 260.116)
		Vector(2163.955, 7.652, 243.574)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(2529.588, -457.986, 416.031)
		Vector(1695.770, -127.747, 224.031)
		Vector(1674.149, 130.113, 416.031)
		Vector(1671.468, 808.193, 128.852)
	]
	g_HnS.PropList[1] <- {name = "big_wheel001", model = "models/props_urban/big_wheel001.mdl" hitbox = 0.6, nocollision = true}
	g_HnS.PropList[2] <- {name = "plastic_bucket001", model = "models/props_urban/plastic_bucket001.mdl", hitbox = 0.4, nocollision = true}
	g_HnS.PropList[3] <- {name = "plastic_icechest001", model = "models/props_urban/plastic_icechest001.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[4] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[5] <- {name = "plastic_water_jug001", model = "models/props_urban/plastic_water_jug001.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[6] <- {name = "lamp_floor", model = "models/props_interiors/lamp_floor.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 84), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[7] <- {name = "sleeping_bag3", model = "models/props_equipment/sleeping_bag3.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 16), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[8] <- {name = "makeshift_stove_battery", model = "models/props_interiors/makeshift_stove_battery.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(18, 18, 24), mins = Vector(-18, -18, 0)}
	g_HnS.PropList[9] <- {name = "torchoven_01", model = "models/props_junk/torchoven_01.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[10] <- {name = "wheelchair01", model = "models/props_unique/wheelchair01.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(17, 17, 38), mins = Vector(-17, -17, 0)}
	g_HnS.PropList[11] <- {name = "static_crate_40", model = "models/props_crates/static_crate_40.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(22, 22, 44), mins = Vector(-22, -22, 0)}
	g_HnS.PropList[12] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	RunScriptCode("SpawnEntityFromTable(\"prop_door_rotating\", {model = \"models/props_downtown/door_interior_128_01.mdl\", origin = Vector(2048.000, -45.000, 224.010), angles = Vector(0.000, -90.000, 0.000), speed = 200, returndelay = -1})", 0.1);
	EntFire("trigger_once", "Kill");
	EntFire("prop_minigun", "Kill");
	local vecPos = Vector(2943.870, 917.574, 127.440)
	for (local i = 0; i < 12; i++)
	{
		SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = vecPos, angles = Vector(0, 90, 0), solid = 6});
		vecPos += Vector(-250, 0, 0)
	}
}

CreateInvisibleWall("physics_blocker_1", Vector(-2367.748, -2883.974, -0.569), Vector(4, 1850, 512), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(-980.440, -2288.154, 178.760), Vector(354, 1666, 512), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(-1279.657, -3677.400, 291.902), Vector(411, 2, 512), Vector(0, 0, -112));
CreateInvisibleWall("physics_blocker_4", Vector(-384.366, -3767.606, 129.305), Vector(512, 2, 512), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(-515.844, -3162.053, 208.031), Vector(4, 128, 128), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(-2160.324, -2537.208, 177.251), Vector(386, 1112, 512), Vector());
CreateInvisibleWall("physics_blocker_7", Vector(735.259, -1223.631, 182.968), Vector(400, 768, 512), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(254.879, 916.126, 130.355), Vector(2840, 8, 512), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(2391.723, 62.498, 410.031), Vector(386, 144, 512), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(1988.298, -471.072, 411.171), Vector(144, 128, 2), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(1418.804, -273.072, 593.088), Vector(768, 768, 2), Vector());