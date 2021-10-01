// Squirrel
// Prop Hunt
// c2m1 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_fortifications/barricade001_128_reference.mdl");
	hEntity.PrecacheModel("models/props_urban/fence_cover001_256.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(2272.393, 4336.929, -1047.969)
	Vector(2269.410, 4228.819, -1047.969)
	Vector(2219.432, 4230.079, -1047.969)
	Vector(2222.643, 4353.336, -1047.969)
]
g_aPropSpawnOrigin <-
[
	Vector(1515.651, 4501.751, -974.754)
	Vector(1656.284, 3640.377, -807.969)
	Vector(1280.728, 5552.873, -807.969)
	Vector(2548.014, 5578.460, -767.969)
]

g_HnS.PropList[1] <- {name = "plastic_flamingo001", model = "models/props_urban/plastic_flamingo001.mdl", hitbox = 0.9, nocollision = true, pos = Vector(0, 0, -12), ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(12, 12, 56), mins = Vector(-12, -12, 0)}
g_HnS.PropList[2] <- {name = "urban_pot_fancy01", model = "models/props_foliage/urban_pot_fancy01.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[3] <- {name = "urban_pot_large01", model = "models/props_foliage/urban_pot_large01.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 38), mins = Vector(-28, -28, 0)}
g_HnS.PropList[4] <- {name = "refrigerator03", model = "models/props_interiors/refrigerator03.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 70), mins = Vector(-16, -16, 0)}
g_HnS.PropList[5] <- {name = "table_cafeteria", model = "models/props_interiors/table_cafeteria.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 38), mins = Vector(-28, -28, 0)}
g_HnS.PropList[6] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
g_HnS.PropList[7] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true}
g_HnS.PropList[8] <- {name = "urban_grass_bush01", model = "models/props_foliage/urban_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[9] <- {name = "urban_fern01", model = "models/props_foliage/urban_fern01.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[10] <- {name = "chimney001", model = "models/props_urban/chimney001.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[11] <- {name = "chimney002", model = "models/props_urban/chimney002.mdl", hitbox = 0.6, nocollision = true}
g_HnS.PropList[12] <- {name = "cafe_barstool1", model = "models/props_furniture/cafe_barstool1.mdl", hitbox = 0.6, nocollision = true, ang = Vector(0, 45, 0), physicsblocker = true, maxs = Vector(10, 10, 36), mins = Vector(-10, -10, 0)}
g_HnS.PropList[13] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
g_HnS.PropList[14] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
g_HnS.PropList[15] <- {name = "monitor01a", model = "models/props_lab/monitor01a.mdl", hitbox = 0.5, nocollision = true, pos = Vector(0, 0, 11)}
g_HnS.PropList[16] <- {name = "traffic_barrel", model = "models/props_fairgrounds/traffic_barrel.mdl", hitbox = 0.85, nocollision = false}
g_HnS.PropList[17] <- {name = "hotel_lamp001", model = "models/props_urban/hotel_lamp001.mdl", hitbox = 0.65, nocollision = true}
g_HnS.PropList[18] <- {name = "urban_pot_clay01", model = "models/props_foliage/urban_pot_clay01.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[19] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[20] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
g_HnS.PropList[21] <- {name = "ice_machine001", model = "models/props_urban/ice_machine001.mdl", hitbox = 1.2, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(38, 42, 82), mins = Vector(-38, -42, 0)}
g_HnS.PropList[22] <- {name = "vending_machine", model = "models/props/cs_office/vending_machine.mdl", hitbox = 1.1, nocollision = true, ang = Vector(0, 90, 0), skin = 1, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
g_HnS.PropList[23] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}

local vecPos = Vector(3070.305, 5173.956, -975.969)
for (local i = 1; i <= 4; i++)
{
	vecPos += Vector(0, 100, 0);
	SpawnEntityFromTable("prop_dynamic", {origin = vecPos, model = "models/props_fortifications/barricade001_128_reference.mdl", angles = Vector(0, 180, 0)});
}

vecPos = Vector(783.039, 3222.433, -968.046)
for (local i = 1; i <= 4; i++)
{
	vecPos += Vector(0, 100, 0);
	SpawnEntityFromTable("prop_dynamic", {origin = vecPos, model = "models/props_fortifications/barricade001_128_reference.mdl"});
}

SpawnEntityFromTable("prop_dynamic", {origin = Vector(2108.833, 3216.651, -807.969), model = "models/props_urban/fence_cover001_256.mdl"});

CreateInvisibleWall("physics_blocker_1", Vector(3062.490, 3828.863, -967.969), Vector(16, 2448, 1024), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(2045.774, 3835.525, -843.923), Vector(1024, 16, 1024), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(2055.614, 3584.058, -831.719), Vector(64, 256, 256), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(1920.938, 6270.857, -845.791), Vector(1132, 16, 1024), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(774.983, 3234.747, -968.690), Vector(8, 512, 512), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(2109.018, 3169.986, -807.969), Vector(8, 72, 128), Vector());

EntFire("carkillsurvival-caralarm_car1", "Kill");
EntFire("carkillsurvival2-caralarm_car1", "Kill");

RunScriptCode("RemoveItemSpawn()", 6.5);