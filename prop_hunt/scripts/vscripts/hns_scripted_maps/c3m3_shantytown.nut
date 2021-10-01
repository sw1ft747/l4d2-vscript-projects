// Squirrel
// Prop Hunt
// c3m3 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_doors/doormain_rural01.mdl");
	hEntity.PrecacheModel("models/props_urban/fence001_256.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break01.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break02.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break03.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break04.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break05.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break06.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(-5915.079, 2124.250, 136.031)
	Vector(-5915.682, 2244.050, 146.044)
	Vector(-5956.030, 2243.837, 146.044)
	Vector(-5973.754, 2133.205, 136.031)
]
g_aPropSpawnOrigin <-
[
	Vector(-5087.240, 998.303, 130.883)
	Vector(-5786.767, 781.775, 161.031)
	Vector(-4763.692, 803.082, 148.031)
	Vector(-5748.236, 1364.309, 128.031)
]

g_HnS.PropList[1] <- {name = "stove01", model = "models/props/cs_militia/stove01.mdl", hitbox = 0.75, nocollision = true, pos = Vector(0, 0, 16), physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[2] <- {name = "stove02", model = "models/props_interiors/stove02.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[3] <- {name = "dining_table_round", model = "models/props_interiors/dining_table_round.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 32), mins = Vector(-28, -28, 0)}
g_HnS.PropList[4] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}
g_HnS.PropList[5] <- {name = "side_table_square", model = "models/props_interiors/side_table_square.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 32), mins = Vector(-12, -12, 0)}
g_HnS.PropList[6] <- {name = "sofa_chair01", model = "models/props_interiors/sofa_chair01.mdl" hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(24, 24, 38), mins = Vector(-24, -24, 0)}
g_HnS.PropList[7] <- {name = "metalbucket02a", model = "models/props_junk/metalbucket02a.mdl" hitbox = 0.5, nocollision = true, pos = Vector(0, 0, 8)}
g_HnS.PropList[8] <- {name = "sawhorse", model = "models/props_interiors/sawhorse.mdl" hitbox = 0.7, nocollision = true}
g_HnS.PropList[9] <- {name = "fridge_mini", model = "models/props_interiors/fridge_mini.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 34), mins = Vector(-12, -12, 0)}
g_HnS.PropList[10] <- {name = "trashcluster01a_corner", model = "models/props_junk/trashcluster01a_corner.mdl", hitbox = 0.65, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[11] <- {name = "hay_bail_stack", model = "models/props/de_inferno/hay_bail_stack.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(44, 44, 68), mins = Vector(-44, -44, 0)}
g_HnS.PropList[12] <- {name = "oil_drum001", model = "models/props_urban/oil_drum001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 48), mins = Vector(-16, -16, 0)}
g_HnS.PropList[13] <- {name = "washer", model = "models/props_interiors/washer.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 48), mins = Vector(-16, -16, 0)}
g_HnS.PropList[14] <- {name = "cinderblock_stack", model = "models/props/de_nuke/cinderblock_stack.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(18, 18, 32), mins = Vector(-18, -18, 0)}
g_HnS.PropList[15] <- {name = "makeshift_stove_battery", model = "models/props_interiors/makeshift_stove_battery.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(18, 18, 24), mins = Vector(-18, -18, 0)}
g_HnS.PropList[16] <- {name = "urban_pot_clay01", model = "models/props_foliage/urban_pot_clay01.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[17] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
g_HnS.PropList[18] <- {name = "atm01", model = "models/props_unique/atm01.mdl", hitbox = 1.1, nocollision = false, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
g_HnS.PropList[19] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
g_HnS.PropList[20] <- {name = "table_cafeteria", model = "models/props_interiors/table_cafeteria.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 38), mins = Vector(-28, -28, 0)}
g_HnS.PropList[21] <- {name = "trashcankitchen01", model = "models/props_interiors/trashcankitchen01.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 36), mins = Vector(-12, -12, 0)}
g_HnS.PropList[22] <- {name = "petfoodbag01", model = "models/props_junk/petfoodbag01.mdl", hitbox = 0.6, nocollision = false}

SpawnEntityFromTable("prop_dynamic", {model = "models/props_doors/doormain_rural01.mdl", origin = Vector(-4703.000, 831.000, 198.998), angles = Vector(0.000, 180.000, 0.000), solid = 6, minhealthdmg = 1e6, skin = 1});

CreateInvisibleWall("physics_blocker_1", Vector(-6035.700, 1850.024, 260.802), Vector(512, 512, 128), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(-5054.054, 1089.411, 268.586), Vector(512, 512, 128), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(-5162.426, 405.982, 292.018), Vector(512, 512, 128), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(-4931.886, 874.167, 130.199), Vector(192, 192, 256), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(-5540.035, -12.319, 270.653), Vector(512, 512, 256), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(-5883.020, 572.179, 268.709), Vector(396, 358, 256), Vector());
CreateInvisibleWall("physics_blocker_7", Vector(-5836.257, 930.031, 259.378), Vector(192, 272, 256), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(-4670.157, 147.310, 258.737), Vector(32, 512, 128), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(-5141.683, 122.918, 258.737), Vector(512, 32, 128), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(-5237.650, 1868.038, 253.962), Vector(192, 128, 128), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(-5778.593, 415.363, 253.962), Vector(128, 144, 128), Vector());
CreateInvisibleWall("physics_blocker_12", Vector(-5077.736, 181.042, 253.962), Vector(128, 144, 128), Vector());