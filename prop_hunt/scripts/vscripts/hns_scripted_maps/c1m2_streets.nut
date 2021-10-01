// Squirrel
// Prop Hunt
// c1m2 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_fortifications/barricade001_128_reference.mdl");
	hEntity.PrecacheModel("models/props_urban/fence001_256.mdl");
}

local rValue = RandomInt(1, 2);
if (rValue == 1)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(2292.761, 5060.023, 448.031)
		Vector(2413.046, 5060.023, 448.031)
		Vector(2292.761, 5160.023, 448.031)
		Vector(2413.046, 5160.023, 448.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-1156.930, 4337.544, 144.128)
		Vector(1310.450, 4405.641, 463.765)
		Vector(-872.805, 3406.126, 320.031)
		Vector(1401.702, 2748.348, 572.031)
	]
	g_HnS.PropList[1] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[2] <- {name = "traffic_barrel", model = "models/props_fairgrounds/traffic_barrel.mdl", hitbox = 0.85, nocollision = false}
	g_HnS.PropList[3] <- {name = "traffic_barrier001", model = "models/props_fortifications/traffic_barrier001.mdl", hitbox = 0.75, nocollision = false}
	g_HnS.PropList[4] <- {name = "tire001", model = "models/props_urban/tire001.mdl", hitbox = 0.5, nocollision = true, pos = Vector(0, 0, 5), ang = Vector(90, 0, 0)}
	g_HnS.PropList[5] <- {name = "hotel_chair001", model = "models/props_urban/hotel_chair001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 48), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[6] <- {name = "water_cooler", model = "models/props_interiors/water_cooler.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 64), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[7] <- {name = "vending_machine", model = "models/props/cs_office/vending_machine.mdl", hitbox = 1.1, nocollision = true, ang = Vector(0, 90, 0), skin = 1, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[8] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[9] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[10] <- {name = "waterbottle", model = "models/props_interiors/waterbottle.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[11] <- {name = "trashcluster01b", model = "models/props_junk/trashcluster01b.mdl", hitbox = 0.9, nocollision = true}
	g_HnS.PropList[12] <- {name = "iv_pole", model = "models/props_unique/hospital/iv_pole.mdl", hitbox = 1.0, nocollision = true}
	g_HnS.PropList[13] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[14] <- {name = "sign_street_04", model = "models/props_signs/sign_street_04.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(4, 4, 128), mins = Vector(-4, -4, 0)}
	g_HnS.PropList[15] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	g_HnS.PropList[16] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[17] <- {name = "firehydrant", model = "models/props_street/firehydrant.mdl", hitbox = 0.7, nocollision = true, pos = Vector(0, 0, -3), physicsblocker = true, maxs = Vector(12, 12, 40), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[18] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[19] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
	g_HnS.PropList[20] <- {name = "police_barrier001_128_reference", model = "models/props_fortifications/police_barrier001_128_reference.mdl", hitbox = 0.9, nocollision = true}
	g_HnS.PropList[21] <- {name = "concrete_barrier001_128_reference", model = "models/props_fortifications/concrete_barrier001_128_reference.mdl", hitbox = 0.8, nocollision = true}
}
else
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-5484.573, 1149.510, 384.031)
		Vector(-5117.281, 924.940, 464.031)
		Vector(-5498.110, 898.767, 384.031)
		Vector(-5266.049, 961.918, 392.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-5826.073, -2782.117, 584.031)
		Vector(-6876.749, -2497.456, 392.031)
		Vector(-5801.325, -1393.439, 448.031)
		Vector(-4867.774, -1838.956, 456.031)
	]
	g_HnS.PropList[1] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[2] <- {name = "traffic_barrel", model = "models/props_fairgrounds/traffic_barrel.mdl", hitbox = 0.85, nocollision = false}
	g_HnS.PropList[3] <- {name = "water_cooler", model = "models/props_interiors/water_cooler.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 64), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[4] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[5] <- {name = "waterbottle", model = "models/props_interiors/waterbottle.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[6] <- {name = "garbage_can001", model = "models/props_urban/garbage_can001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(14, 14, 54), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[7] <- {name = "sign_street_04", model = "models/props_signs/sign_street_04.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(4, 4, 128), mins = Vector(-4, -4, 0)}
	g_HnS.PropList[8] <- {name = "shopping_cart001", model = "models/props_urban/shopping_cart001.mdl", hitbox = 0.8, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(22, 18, 48), mins = Vector(-22, -18, 0)}
	g_HnS.PropList[9] <- {name = "static_crate_40", model = "models/props_crates/static_crate_40.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(22, 22, 44), mins = Vector(-22, -22, 0)}
	g_HnS.PropList[10] <- {name = "cash_register", model = "models/props_mall/cash_register.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 20), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[11] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
	g_HnS.PropList[12] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[13] <- {name = "concretebags2", model = "models/props/de_prodigy/concretebags2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(28, 38, 64), mins = Vector(-28, -38, 0)}
	g_HnS.PropList[14] <- {name = "bbq_grill", model = "models/props_interiors/bbq_grill.mdl", hitbox = 0.9, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(22, 28, 48), mins = Vector(-22, -28, 0)}
	g_HnS.PropList[15] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[16] <- {name = "atm01", model = "models/props_unique/atm01.mdl", hitbox = 1.1, nocollision = false, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[17] <- {name = "coffeemachine01", model = "models/props_unique/coffeemachine01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 8, 24), mins = Vector(-12, -8, 0)}
	g_HnS.PropList[18] <- {name = "fountain_drinks", model = "models/props_equipment/fountain_drinks.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(20, 22, 66), mins = Vector(-20, -22, 0)}
	g_HnS.PropList[19] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
	g_HnS.PropList[20] <- {name = "concrete_post001_48", model = "models/props_fortifications/concrete_post001_48.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 48), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[21] <- {name = "concrete_block001_128_reference", model = "models/props_fortifications/concrete_block001_128_reference.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[22] <- {name = "petfoodbag01", model = "models/props_junk/petfoodbag01.mdl", hitbox = 0.6, nocollision = false}
	SpawnEntityFromTable("prop_dynamic", {origin = Vector(-5502.922, 823.966, 384.031), model = "models/props_fortifications/barricade001_128_reference.mdl", angles = Vector(0, 90, 0)});
	SpawnEntityFromTable("prop_dynamic", {origin = Vector(-5584.532, 823.874, 616.031), model = "models/props_urban/fence001_256.mdl", angles = Vector(0, 90, 0)})
	EntFire("env_microphone", "Kill");
	EntFire("func_breakable", "Kill");
	EntFire("gunshop_door_lock", "Kill");
	EntFire("store_door01_dynamic", "Kill");
	EntFire("store_door02_dynamic", "Kill");
}

CreateInvisibleWall("physics_blocker_1", Vector(-384.105, 3199.562, 640.031), Vector(1200, 20, 192), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(-2503.576, 1199.158, 61.827), Vector(16, 2048, 256), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(1590.736, 2492.360, 690.294), Vector(300, 368, 256), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(-5567.904, 815.119, 384.031), Vector(368, 14, 512), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(2241.698, 3248.901, 704.031), Vector(1024, 548, 256), Vector(0, 0, -64));
CreateInvisibleWall("physics_blocker_6", Vector(-0.636, 2294.273, 675.419), Vector(2048, 8, 256), Vector(0, 0, -128));
CreateInvisibleWall("physics_blocker_7", Vector(1048.207, 2430.214, 728.243), Vector(236, 112, 128), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(-2475.962, 120.306, 15.031), Vector(16, 64, 192), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(-5560.867, -1104.763, 814.819), Vector(768, 2112, 16), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(-1053.203, 2284.482, 457.122), Vector(42.000, 913.159, 394.656), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(-1006.149, 2280.905, 539.242), Vector(494.800, 21.423, 163.864), Vector());