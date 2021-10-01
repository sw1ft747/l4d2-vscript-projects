// Squirrel
// Prop Hunt
// c2m2 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_urban/fence001_256.mdl");
}

local rValue = RandomInt(1, 3);
if (rValue == 1)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(1626.387, 2693.716, 4.031)
		Vector(1600.434, 2801.160, 4.031)
		Vector(1707.647, 2967.397, 4.031)
		Vector(1624.511, 2919.037, 4.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(2944.675, 377.538, 0.093)
		Vector(1817.558, 1367.293, 0.031)
		Vector(3623.204, -644.480, -3.864)
		Vector(2986.277, -1664.770, 0.383)
	]
	g_HnS.PropList[1] <- {name = "round_table001", model = "models/props_urban/round_table001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(38, 38, 44), mins = Vector(-38, -38, 0)}
	g_HnS.PropList[2] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[3] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[4] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[5] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[6] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[7] <- {name = "police_barrier001_128_reference", model = "models/props_fortifications/police_barrier001_128_reference.mdl", hitbox = 0.9, nocollision = true, skin = 1}
	g_HnS.PropList[8] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.2, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[9] <- {name = "coffeemachine01", model = "models/props_unique/coffeemachine01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 8, 24), mins = Vector(-12, -8, 0)}
	g_HnS.PropList[10] <- {name = "fountain_drinks", model = "models/props_equipment/fountain_drinks.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(20, 22, 66), mins = Vector(-20, -22, 0)}
	g_HnS.PropList[11] <- {name = "concrete_post001_48", model = "models/props_fortifications/concrete_post001_48.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 48), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[12] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[13] <- {name = "Lil'Peanut_sign001", model = "models/props_fairgrounds/Lil'Peanut_sign001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 86), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[14] <- {name = "Lil'Peanut_cutout001", model = "models/props_fairgrounds/Lil'Peanut_cutout001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 86), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[15] <- {name = "cafe_barstool1", model = "models/props_furniture/cafe_barstool1.mdl", hitbox = 0.6, nocollision = true, ang = Vector(0, 45, 0), physicsblocker = true, maxs = Vector(10, 10, 36), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[16] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[17] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[18] <- {name = "concretebags2", model = "models/props/de_prodigy/concretebags2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(28, 38, 64), mins = Vector(-28, -38, 0)}
	g_HnS.PropList[19] <- {name = "vending_machine", model = "models/props/cs_office/vending_machine.mdl", hitbox = 1.1, nocollision = true, ang = Vector(0, 90, 0), skin = 1, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[20] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
	SpawnEntityFromTable("prop_dynamic", {origin = Vector(2751.861, -1528.650, 0.400), model = "models/props_urban/fence001_256.mdl", angles = Vector(0, 90, 0)});
}
else if (rValue == 2)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(856.796, -1409.676, 0.031)
		Vector(977.066, -1406.590, 0.031)
		Vector(971.672, -1231.848, 0.031)
		Vector(860.712, -1225.937, 0.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-2726.007, -1942.011, -127.969)
		Vector(-1478.768, -531.610, -127.969)
		Vector(-3024.599, 356.495, -127.969)
		Vector(679.717, -267.408, -2.059)
	]
	g_HnS.PropList[1] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[2] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[3] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[4] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[5] <- {name = "urban_small_palm01", model = "models/props_foliage/urban_small_palm01.mdl", hitbox = 1.1, nocollision = true}
	g_HnS.PropList[6] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	g_HnS.PropList[7] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[8] <- {name = "police_barrier001_128_reference", model = "models/props_fortifications/police_barrier001_128_reference.mdl", hitbox = 0.9, nocollision = true, skin = 1}
	g_HnS.PropList[9] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.2, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[10] <- {name = "concrete_post001_48", model = "models/props_fortifications/concrete_post001_48.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 48), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[11] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[12] <- {name = "Lil'Peanut_sign001", model = "models/props_fairgrounds/Lil'Peanut_sign001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 86), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[13] <- {name = "Lil'Peanut_cutout001", model = "models/props_fairgrounds/Lil'Peanut_cutout001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 86), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[14] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[15] <- {name = "concretebags2", model = "models/props/de_prodigy/concretebags2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(28, 38, 64), mins = Vector(-28, -38, 0)}
	g_HnS.PropList[16] <- {name = "vending_machine", model = "models/props/cs_office/vending_machine.mdl", hitbox = 1.1, nocollision = true, ang = Vector(0, 90, 0), skin = 1, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[17] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
	g_HnS.PropList[18] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
	SpawnEntityFromTable("prop_dynamic", {origin = Vector(-3690.848, -1147.721, -127.969), model = "models/props_urban/fence001_256.mdl", angles = Vector(0, 90, 0)});
	SpawnEntityFromTable("prop_dynamic", {origin = Vector(1030.362, -1232.231, 0.031), model = "models/props_urban/fence001_256.mdl"});
}
else
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-4610.598, -5568.736, -63.969)
		Vector(-4611.887, -5442.872, -63.969)
		Vector(-4957.389, -5441.954, -63.969)
		Vector(-4957.336, -5566.017, -63.969)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-3544.486, -4452.468, -127.969)
		Vector(-1700.582, -4585.867, -126.796)
		Vector(-1367.926, -5843.416, -123.361)
		Vector(-2866.593, -6060.515, -127.969)
	]
	g_HnS.PropList[1] <- {name = "cooler", model = "models/props_equipment/cooler.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(22, 22, 92), mins = Vector(-22, -22, 0)}
	g_HnS.PropList[2] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
	g_HnS.PropList[3] <- {name = "concrete_post001_48", model = "models/props_fortifications/concrete_post001_48.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 48), mins = Vector(-8, -8, 0)}
	g_HnS.PropList[4] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
	g_HnS.PropList[5] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[6] <- {name = "police_barrier001_128_reference", model = "models/props_fortifications/police_barrier001_128_reference.mdl", hitbox = 0.9, nocollision = true, skin = 1}
	g_HnS.PropList[7] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[8] <- {name = "round_table001", model = "models/props_urban/round_table001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(38, 38, 44), mins = Vector(-38, -38, 0)}
	g_HnS.PropList[9] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[10] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
	g_HnS.PropList[11] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
	g_HnS.PropList[12] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
}

hEntity = null;
EntFire("tol_clip_brush", "Kill");
EntFire("carousel_gate_door", "Kill");
EntFire("carousel_lever_model", "Kill");
EntFire("carousel_lever_base_model", "Kill");
EntFire("carousel_gate_button_model", "Kill");
if ((hEntity = Entities.FindByModel(null, "models/props_junk/gnome.mdl")) != null) hEntity.Kill();

CreateInvisibleWall("physics_blocker_1", Vector(2686.164, -1528.927, 0.953), Vector(128, 8, 192), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(1793.577, -0.752, 137.680), Vector(512, 1024, 512), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(-648.526, 601.136, -2.898), Vector(128, 300, 128), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(-1157.160, -1799.327, 16.347), Vector(248, 16, 192), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(-3803.314, -1150.805, -127.969), Vector(64, 8, 128), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(533.207, -135.579, 143.218), Vector(256, 128, 192), Vector());
CreateInvisibleWall("physics_blocker_7", Vector(937.167, -815.025, 109.355), Vector(64, 192, 192), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(1028.792, -1259.344, 0.031), Vector(8, 64, 128), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(-1184.786, -5380.908, 9.386), Vector(332, 388, 256), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(-4357.657, -4608.747, -10.712), Vector(16, 512, 256), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(-3026.966, -5465.143, -1.697), Vector(64, 256, 128), Vector());