// Squirrel
// Prop Hunt
// c2m4 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_urban/fence_cover001_128.mdl");
	hEntity.PrecacheModel("models/props_urban/outhouse_door001.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(-1996.929, 728.004, -183.969)
	Vector(-1998.446, 907.662, -183.969)
	Vector(3034.116, 3465.937, -187.969)
	Vector(3178.214, 3813.210, -187.969)
]
g_aPropSpawnOrigin <-
[
	Vector(1586.005, 1515.596, -147.969)
	Vector(2628.042, 1779.678, -191.969)
	Vector(445.726, 1569.523, -191.969)
	Vector(-468.016, 672.148, -191.969)
]

g_HnS.PropList[1] <- {name = "bench001", model = "models/props_urban/bench001.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, -90, 0)}
g_HnS.PropList[2] <- {name = "garbage_can002", model = "models/props_urban/garbage_can002.mdl", hitbox = 0.75, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(14, 14, 44), mins = Vector(-14, -14, 0)}
g_HnS.PropList[3] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
g_HnS.PropList[4] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
g_HnS.PropList[5] <- {name = "round_table001", model = "models/props_urban/round_table001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(38, 38, 44), mins = Vector(-38, -38, 0)}
g_HnS.PropList[6] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}
g_HnS.PropList[7] <- {name = "vending_machine01", model = "models/props_office/vending_machine01.mdl", hitbox = 1.1, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
g_HnS.PropList[8] <- {name = "concrete_post001_48", model = "models/props_fortifications/concrete_post001_48.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 48), mins = Vector(-8, -8, 0)}
g_HnS.PropList[9] <- {name = "bumpercar", model = "models/props_fairgrounds/bumpercar.mdl", hitbox = 0.85, nocollision = true, ang = Vector(0, 180, 0)}
g_HnS.PropList[10] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
g_HnS.PropList[11] <- {name = "trashbin01", model = "models/props_street/trashbin01.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 52), mins = Vector(-16, -16, 0)}
g_HnS.PropList[12] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}

SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence_cover001_128.mdl", origin = Vector(-2017.133, 267.131, -191.969), angles = Vector(0, 90, 0), solid = 6});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/outhouse_door001.mdl", origin = Vector(2587.610, 712.242, -186.325), angles = Vector(0, 84.5, 0), solid = 6, minhealthdmg = 1e6});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/outhouse_door001.mdl", origin = Vector(2513.000, 714.000, -186.325), angles = Vector(0, 90, 0), solid = 6, minhealthdmg = 1e6});

CreateInvisibleWall("physics_blocker_1", Vector(2477.796, 3888.134, -91.969), Vector(32, 64, 32), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(1968.616, 2447.095, -55.969), Vector(256, 96, 128), Vector());