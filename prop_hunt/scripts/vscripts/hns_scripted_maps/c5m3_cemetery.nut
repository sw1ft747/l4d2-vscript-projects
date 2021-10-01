// Squirrel
// Prop Hunt
// c5m3 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_urban/wood_railing001_128.mdl");
	hEntity.PrecacheModel("models/props_urban/fence003_64.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(6497.328, 8628.269, 0.031)
	Vector(6492.481, 8497.235, 0.031)
	Vector(6488.419, 8387.457, 0.031)
	Vector(6484.210, 8273.683, 0.031)
]
g_aPropSpawnOrigin <-
[
	Vector(3701.380, 5391.822, 164.031)
	Vector(3513.832, 6014.806, -0.969)
	Vector(5711.039, 7557.542, 20.338)
	Vector(4838.047, 6743.384, 7.409)
]

g_HnS.PropList[1] <- {name = "orange_cone001_reference", model = "models/props_fortifications/orange_cone001_reference.mdl", hitbox = 0.5, nocollision = true}
g_HnS.PropList[2] <- {name = "tire001", model = "models/props_urban/tire001.mdl", hitbox = 0.5, nocollision = true, pos = Vector(0, 0, 5), ang = Vector(90, 0, 0)}
g_HnS.PropList[3] <- {name = "oil_drum001", model = "models/props_urban/oil_drum001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 48), mins = Vector(-16, -16, 0)}
g_HnS.PropList[4] <- {name = "sleeping_bag3", model = "models/props_equipment/sleeping_bag3.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 16), mins = Vector(-16, -16, 0)}
g_HnS.PropList[5] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[6] <- {name = "refrigerator03", model = "models/props_interiors/refrigerator03.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 70), mins = Vector(-16, -16, 0)}
g_HnS.PropList[7] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
g_HnS.PropList[8] <- {name = "trashcluster01a_corner", model = "models/props_junk/trashcluster01a_corner.mdl", hitbox = 0.65, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
g_HnS.PropList[9] <- {name = "bbq_grill", model = "models/props_interiors/bbq_grill.mdl", hitbox = 0.9, nocollision = true, ang = Vector(0, -90, 0), physicsblocker = true, maxs = Vector(22, 28, 48), mins = Vector(-22, -28, 0)}
g_HnS.PropList[10] <- {name = "garbage_can001", model = "models/props_urban/garbage_can001.mdl", hitbox = 0.9, nocollision = true, physicsblocker = true, maxs = Vector(14, 14, 54), mins = Vector(-14, -14, 0)}
g_HnS.PropList[11] <- {name = "fire_hydrant001", model = "models/props_urban/fire_hydrant001.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 44), mins = Vector(-10, -10, 0)}
g_HnS.PropList[12] <- {name = "mail_dropbox", model = "models/props_street/mail_dropbox.mdl", hitbox = 0.85, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 52), mins = Vector(-12, -12, 0)}
g_HnS.PropList[13] <- {name = "sign_street_03", model = "models/props_signs/sign_street_03.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 128), mins = Vector(-8, -8, 0)}
g_HnS.PropList[14] <- {name = "sign_street_04", model = "models/props_signs/sign_street_04.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(4, 4, 128), mins = Vector(-4, -4, 0)}
g_HnS.PropList[15] <- {name = "traffic_barrier001", model = "models/props_fortifications/traffic_barrier001.mdl", hitbox = 0.75, nocollision = false}
g_HnS.PropList[16] <- {name = "cashregister01", model = "models/props_interiors/cashregister01.mdl", hitbox = 0.3, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 12), mins = Vector(-8, -8, 0)}
g_HnS.PropList[17] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}
g_HnS.PropList[18] <- {name = "sofa_chair02", model = "models/props_interiors/sofa_chair02.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(22, 22, 40), mins = Vector(-22, -22, 0)}

SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/wood_railing001_128.mdl", origin = Vector(3999.500, 5347.226, 164.031), solid = 6, disableshadows = 1});
SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence003_64.mdl", origin = Vector(3996.000, 5249.029, 148.031), angles = Vector(0, 180, 0), solid = 6, disableshadows = 1});

CreateInvisibleWall("physics_blocker_1", Vector(5407.075, 5694.944, 204.443), Vector(800, 2760, 512), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(5381.352, 8429.553, 194.815), Vector(826, 116, 512), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(2880.374, 6239.373, 151.281), Vector(1476, 1077, 512), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(4358.068, 7167.601, 224.830), Vector(1054, 10, 512), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(4379.853, 5498.843, 142.425), Vector(486, 360, 512), Vector());
CreateInvisibleWall("physics_blocker_6", Vector(4868.283, 5729.990, 243.051), Vector(561, 57, 512), Vector());
CreateInvisibleWall("physics_blocker_7", Vector(3997.321, 5022.310, 164.031), Vector(5, 387, 512), Vector());
CreateInvisibleWall("physics_blocker_8", Vector(4004.113, 5145.151, 140.744), Vector(473, 314, 512), Vector());
CreateInvisibleWall("physics_blocker_9", Vector(4462.711, 5458.139, 209.304), Vector(6, 44, 512), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(3483.353, 4980.826, 318.291), Vector(522, 816, 512), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(3394.145, 5647.641, 336.072), Vector(88, 72, 512), Vector());
CreateInvisibleWall("physics_blocker_12", Vector(3131.330, 5413.099, 242.454), Vector(274, 299, 512), Vector());
CreateInvisibleWall("physics_blocker_13", Vector(2927.222, 5453.521, 204.401), Vector(124, 299, 512), Vector());
CreateInvisibleWall("physics_blocker_14", Vector(2899.437, 5702.539, 140.120), Vector(71, 535, 512), Vector());