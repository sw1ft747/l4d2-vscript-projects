// Squirrel
// Prop Hunt
// c5m1 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_fortifications/barricade001_128_reference.mdl");
	hEntity.PrecacheModel("models/props_crates/static_crate_40.mdl");
}

local rValue = RandomInt(1, 2);
if (rValue == 1)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(761.593, 744.140, -481.969)
		Vector(762.901, 621.741, -481.969)
		Vector(841.457, 622.580, -481.969)
		Vector(840.549, 745.395, -481.969)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-1603.677, -1890.308, -375.969)
		Vector(-990.694, -1310.241, -376.543)
		Vector(-892.641, -423.297, -376.012)
		Vector(119.384, -1.897, -375.969)
	]
	g_HnS.PropList[1] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[2] <- {name = "urban_pot_clay01", model = "models/props_foliage/urban_pot_clay01.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[3] <- {name = "urban_pot_bigplant01", model = "models/props_foliage/urban_pot_bigplant01.mdl", hitbox = 0.65, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 32), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[4] <- {name = "garbage_can001", model = "models/props_urban/garbage_can001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(14, 14, 54), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[5] <- {name = "fire_hydrant001", model = "models/props_urban/fire_hydrant001.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 44), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[6] <- {name = "street_lamp01", model = "models/props_downtown/street_lamp01.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 164), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[7] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[8] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true}
	g_HnS.PropList[9] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[10] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[11] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[12] <- {name = "sofa_chair01", model = "models/props_interiors/sofa_chair01.mdl" hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(24, 24, 38), mins = Vector(-24, -24, 0)}
	g_HnS.PropList[13] <- {name = "lamp_table02", model = "models/props_interiors/lamp_table02.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[14] <- {name = "lamp_floor", model = "models/props_interiors/lamp_floor.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 84), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[15] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[16] <- {name = "sign_street_03", model = "models/props_signs/sign_street_03.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 128), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[17] <- {name = "mail_dropbox", model = "models/props_street/mail_dropbox.mdl", hitbox = 0.85, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 52), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[18] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	g_HnS.PropList[19] <- {name = "table_motel", model = "models/props_interiors/table_motel.mdl" hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[20] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[21] <- {name = "coffeemachine01", model = "models/props_unique/coffeemachine01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 8, 24), mins = Vector(-12, -8, 0)}
	g_HnS.PropList[22] <- {name = "cafe_barstool1", model = "models/props_furniture/cafe_barstool1.mdl", hitbox = 0.6, nocollision = true, ang = Vector(0, 45, 0), physicsblocker = true, maxs = Vector(10, 10, 36), mins = Vector(-10, -10, 0)}
	CreateInvisibleWall("physics_blocker_1", Vector(831.605, -111.484, -464.783), Vector(63, 608, 768), Vector());
	CreateInvisibleWall("physics_blocker_2", Vector(915.919, 500.758, -452.540), Vector(26, 384, 768), Vector());
	CreateInvisibleWall("physics_blocker_3", Vector(679.723, 59.429, -472.328), Vector(44, 440, 768), Vector());
	CreateInvisibleWall("physics_blocker_4", Vector(682.145, -296.453, -356.742), Vector(149, 197, 768), Vector());
	CreateInvisibleWall("physics_blocker_5", Vector(284.960, -289.037, -272.446), Vector(263, 138, 256), Vector());
	CreateInvisibleWall("physics_blocker_6", Vector(-235.263, 225.311, -187.414), Vector(920, 1357, 768), Vector());
	CreateInvisibleWall("physics_blocker_7", Vector(-597.929, -317.362, -169.004), Vector(530, 787, 768), Vector());
	CreateInvisibleWall("physics_blocker_8", Vector(166.845, -827.535, -229.595), Vector(673, 544, 768), Vector());
	CreateInvisibleWall("physics_blocker_9", Vector(-78.450, -835.044, -251.240), Vector(271, 11, 768), Vector());
	CreateInvisibleWall("physics_blocker_10", Vector(280.908, 947.537, -233.056), Vector(13, 460, 128), Vector());
	CreateInvisibleWall("physics_blocker_11", Vector(-3102.073, -2354.474, -55.969), Vector(2517, 2822, 256), Vector());
	CreateInvisibleWall("physics_blocker_12", Vector(-1183.101, -415.162, -205.834), Vector(102, 168, 768), Vector());
	CreateInvisibleWall("physics_blocker_13", Vector(-1713.667, -70.204, -148.800), Vector(642, 514, 768), Vector());
	CreateInvisibleWall("physics_blocker_14", Vector(-1702.650, -256.330, -229.315), Vector(12, 257, 768), Vector());
	CreateInvisibleWall("physics_blocker_15", Vector(-773.653, -326.958, -189.053), Vector(101, 398, 256), Vector());
	CreateInvisibleWall("physics_blocker_16", Vector(-739.367, -2052.300, -196.117), Vector(71, 774, 256), Vector());
	CreateInvisibleWall("physics_blocker_17", Vector(-1575.395, -2149.445, -186.672), Vector(490, 490, 256), Vector());
	CreateInvisibleWall("physics_blocker_18", Vector(-1771.296, -1288.365, -249.659), Vector(74, 23, 256), Vector());
	CreateInvisibleWall("physics_blocker_19", Vector(-1176.858, 328.335, -224.757), Vector(544, 150, 512), Vector());
	CreateInvisibleWall("physics_blocker_20", Vector(-740.628, -2377.197, -220.813), Vector(136, 330, 512), Vector());
	CreateInvisibleWall("physics_blocker_21", Vector(-1789.899, -2406.300, -217.455), Vector(593, 25, 368), Vector());
	CreateInvisibleWall("physics_blocker_22", Vector(678.975, 517.259, -239.446), Vector(253, 309, 256), Vector());
}
else
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-4553.088, -1265.536, -343.969)
		Vector(-4551.570, -1391.453, -343.969)
		Vector(-4562.284, -1169.741, -343.969)
		Vector(-4637.082, -1172.167, -343.969)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-2651.735, -2222.959, -378.534)
		Vector(-2103.945, -1169.088, -376.541)
		Vector(-2237.262, -435.872, -367.969)
		Vector(-3493.567, -607.507, -379.969)
	]
	g_HnS.PropList[1] <- {name = "garbage_can001", model = "models/props_urban/garbage_can001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(14, 14, 54), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[2] <- {name = "newspaperstack01", model = "models/props/cs_militia/newspaperstack01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 24), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[3] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[4] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[5] <- {name = "street_lamp01", model = "models/props_downtown/street_lamp01.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 164), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[6] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[7] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[8] <- {name = "trashcluster01b", model = "models/props_junk/trashcluster01b.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[9] <- {name = "paper_tray", model = "models/props_interiors/paper_tray.mdl", hitbox = 0.4, nocollision = true}
	g_HnS.PropList[10] <- {name = "refrigerator03_damaged_04", model = "models/props_interiors/refrigerator03_damaged_04.mdl", hitbox = 0.4, nocollision = true, pos = Vector(0, 0, 7)}
	g_HnS.PropList[11] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[12] <- {name = "urban_streettree01", model = "models/props_foliage/urban_streettree01.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 64), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[13] <- {name = "urban_pot_bigplant01", model = "models/props_foliage/urban_pot_bigplant01.mdl", hitbox = 0.65, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 32), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[14] <- {name = "table_motel", model = "models/props_interiors/table_motel.mdl" hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[15] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[16] <- {name = "coffeemachine01", model = "models/props_unique/coffeemachine01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 8, 24), mins = Vector(-12, -8, 0)}
	g_HnS.PropList[17] <- {name = "fountain_drinks", model = "models/props_equipment/fountain_drinks.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(20, 22, 66), mins = Vector(-20, -22, 0)}
	g_HnS.PropList[18] <- {name = "stove04_industrial", model = "models/props_interiors/stove04_industrial.mdl" hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 88), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[19] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[20] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true}
	g_HnS.PropList[21] <- {name = "round_table001", model = "models/props_urban/round_table001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(38, 38, 44), mins = Vector(-38, -38, 0)}
	g_HnS.PropList[22] <- {name = "mail_dropbox", model = "models/props_street/mail_dropbox.mdl", hitbox = 0.85, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 52), mins = Vector(-12, -12, 0)}
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_crates/static_crate_40.mdl", origin = Vector(-2602.903, -1749.197, -350.144), solid = 6});
	CreateInvisibleWall("physics_blocker_1", Vector(-3815.019, -1314.494, -150.002), Vector(794, 1864, 512), Vector());
	CreateInvisibleWall("physics_blocker_2", Vector(-3918.791, -1152.614, -243.473), Vector(19, 64, 256), Vector());
	CreateInvisibleWall("physics_blocker_3", Vector(-3724.032, -1371.710, -191.420), Vector(527, 149, 256), Vector());
	CreateInvisibleWall("physics_blocker_4", Vector(-2754.540, -2046.864, -150.676), Vector(1058, 2551, 256), Vector());
	CreateInvisibleWall("physics_blocker_5", Vector(-2145.765, -2433.781, -227.662), Vector(625, 56, 368), Vector());
	CreateInvisibleWall("physics_blocker_6", Vector(-3106.367, -2371.578, -185.716), Vector(1528, 334, 256), Vector());
	CreateInvisibleWall("physics_blocker_7", Vector(-1768.182, -1289.095, -225.969), Vector(61, 16, 128), Vector());
	CreateInvisibleWall("physics_blocker_8", Vector(-2792.757, -1530.812, -207.013), Vector(39, 60, 256), Vector());
	CreateInvisibleWall("physics_blocker_9", Vector(-2206.538, -2465.025, -197.434), Vector(63, 8, 256), Vector());
	CreateInvisibleWall("physics_blocker_10", Vector(-2139.939, -502.038, -195.518), Vector(111, 24, 128), Vector());
}

EntFire("func_areaportal", "Open");
EntFire("route_1_blocker", "Kill");
EntFire("route_2_blocker", "Kill");
EntFire("prop_car_alarm", "Kill");
SpawnEntityFromTable("prop_dynamic", {model = "models/props_downtown/door_interior_112_01.mdl", origin = Vector(-1692.000, -2016.000, -376.210), solid = 6, minhealthdmg = 1e6});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_fortifications/barricade001_128_reference.mdl", origin = Vector(-1579.065, -2305.160, -375.969), solid = 6});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_fortifications/barricade001_128_reference.mdl", origin = Vector(-1579.065, -2205.160, -376.969), solid = 6});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_fortifications/barricade001_128_reference.mdl", origin = Vector(-1579.065, -2105.160, -375.969), solid = 6});
CreateInvisibleWall("physics_blocker_wall", Vector(-1601.228, -2380.996, -230.224), Vector(24, 325, 512), Vector());