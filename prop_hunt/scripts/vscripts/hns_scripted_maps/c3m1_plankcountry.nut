// Squirrel
// Prop Hunt
// c3m1 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_urban/fence_cover001_128.mdl");
	hEntity.PrecacheModel("models/props_urban/wood_fence001_256.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(-7161.847, 6312.498, 32.031)
	Vector(-7164.319, 6355.199, 32.031)
	Vector(-7225.621, 6361.806, 31.851)
	Vector(-7223.748, 6310.876, 31.859)
]
g_aPropSpawnOrigin <-
[
	Vector(-7956.083, 7814.473, 11.445)
	Vector(-7213.940, 6978.376, 17.871)
	Vector(-5983.517, 6913.255, 12.172)
	Vector(-6326.937, 6403.611, 176.031)
]

g_HnS.PropList[1] <- {name = "tire001", model = "models/props_urban/tire001.mdl", hitbox = 0.5, nocollision = true, pos = Vector(0, 0, 5), ang = Vector(90, 0, 0)}
g_HnS.PropList[2] <- {name = "chairlobby01", model = "models/props_interiors/chairlobby01.mdl", hitbox = 0.8, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[3] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
g_HnS.PropList[4] <- {name = "printer", model = "models/props_interiors/printer.mdl" hitbox = 0.5, nocollision = true, ang = Vector(0, -90, 0)}
g_HnS.PropList[5] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, rendercolor = "69 118 102"}
g_HnS.PropList[6] <- {name = "table_motel", model = "models/props_interiors/table_motel.mdl" hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[7] <- {name = "sofa_chair01", model = "models/props_interiors/sofa_chair01.mdl" hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(24, 24, 38), mins = Vector(-24, -24, 0)}
g_HnS.PropList[8] <- {name = "copymachine01", model = "models/props_interiors/copymachine01.mdl" hitbox = 0.3, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(24, 24, 64), mins = Vector(-24, -24, 0)}
g_HnS.PropList[9] <- {name = "stove04_industrial", model = "models/props_interiors/stove04_industrial.mdl" hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 88), mins = Vector(-16, -16, 0)}
g_HnS.PropList[10] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
g_HnS.PropList[11] <- {name = "trashcluster01a_corner", model = "models/props_junk/trashcluster01a_corner.mdl", hitbox = 0.65, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[12] <- {name = "shopping_cart001", model = "models/props_urban/shopping_cart001.mdl", hitbox = 0.8, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(22, 18, 48), mins = Vector(-22, -18, 0)}
g_HnS.PropList[13] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
g_HnS.PropList[14] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[15] <- {name = "urban_pot_clay01", model = "models/props_foliage/urban_pot_clay01.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[16] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[17] <- {name = "plastic_icechest001", model = "models/props_urban/plastic_icechest001.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[18] <- {name = "plastic_bucket001", model = "models/props_urban/plastic_bucket001.mdl", hitbox = 0.4, nocollision = true}
g_HnS.PropList[19] <- {name = "oil_drum001", model = "models/props_urban/oil_drum001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 48), mins = Vector(-16, -16, 0)}
g_HnS.PropList[20] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
g_HnS.PropList[21] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
g_HnS.PropList[22] <- {name = "metal_pole001", model = "models/props_urban/metal_pole001.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 256), mins = Vector(-8, -8, 0)}

local vecPos = Vector(-7650.571, 8054.979, 38.323)
for (local i = 0; i < 8; i++)
{
	if (i > 0 && i < 4) vecPos += Vector(0, 0, -10)
	else if (i >= 4) vecPos += Vector(0, 0, 15)
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence_cover001_128.mdl", origin = vecPos, angles = Vector(0, 90, 0)});
	vecPos += Vector(-128, 0, 0)
}

vecPos = Vector(-8786.931, 7114.232, 85.349)
for (local i = 0; i < 3; i++)
{
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/wood_fence001_256.mdl", origin = vecPos});
	vecPos += Vector(0, -255, 0)
}

local hTable = {origin = Vector(-5316.292, 5744.031, -31.159), damage = 500.0, damagetype = DMG_FALL, spawnflags = TR_CLIENTS}
local hEntity = SpawnEntityFromTable("trigger_hurt", hTable);
hEntity.__KeyValueFromVector("maxs", Vector(32, 2048, 16));
hEntity.__KeyValueFromVector("mins", Vector(-16, 0, -32));
hEntity.__KeyValueFromInt("solid", 2);

CreateInvisibleWall("physics_blocker_1", Vector(-8793.784, 6588.359, 85.442), Vector(8, 692, 512), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(-8639.618, 8049.536, 20.353), Vector(1092, 8, 512), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(-5462.772, 7375.735, 111.340), Vector(256, 256, 512), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(-6875.994, 7455.025, 144.031), Vector(512, 256, 512), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(-7564.199, 7722.348, 32.031), Vector(256, 512, 512), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(-7720.268, 6278.578, 151.391), Vector(768, 16, 512), Vector());
CreateInvisibleWall("physics_blocker_7", Vector(-7153.670, 6294.378, 160.031), Vector(128, 292, 512), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(-6976.016, 6262.563, 192.319), Vector(208, 300, 512), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(-6770.315, 6226.067, 160.031), Vector(200, 8, 512), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(-6478.141, 6653.642, 169.517), Vector(296, 232, 512), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(-8590.607, 6915.058, 236.108), Vector(548, 596, 512), Vector());
CreateInvisibleWall("physics_blocker_12", Vector(-8630.134, 7416.718, 184.031), Vector(8, 768, 512), Vector());
CreateInvisibleWall("physics_blocker_13", Vector(-8630.134, 7416.718, 184.031), Vector(48, 8, 512), Vector());
CreateInvisibleWall("physics_blocker_14", Vector(-6432.445, 5661.903, 32.031), Vector(792, 8, 512), Vector());
CreateInvisibleWall("physics_blocker_15", Vector(-5641.588, 5670.233, 32.031), Vector(256, 64, 512), Vector());
CreateInvisibleWall("physics_blocker_16", Vector(-6394.760, 5697.196, 161.031), Vector(8, 512, 512), Vector());
CreateInvisibleWall("physics_blocker_17", Vector(-6383.166, 6432.562, 294.619), Vector(192, 192, 16), Vector());