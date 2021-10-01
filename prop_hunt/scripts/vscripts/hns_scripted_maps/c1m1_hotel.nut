// Squirrel
// Prop Hunt
// c1m1 Scripted Map

// Players Spawn Position
g_aHunterSpawnOrigin <-
[
	Vector(655.614, 5764.078, 2847.674)
	Vector(537.830, 5762.009, 2848.031)
	Vector(724.926, 6120.946, 2848.333)
	Vector(435.167, 6070.375, 2848.480)
]
g_aPropSpawnOrigin <-
[
	Vector(573.854, 5959.235, 2656.031)
	Vector(2164.995, 6307.685, 2656.031)
	Vector(1997.789, 5619.109, 2656.031)
	Vector(1030.888, 5347.084, 2656.031)
]

// Prop List
g_HnS.PropList[1] <- {name = "hotel_chair", model = "models/props_furniture/hotel_chair.mdl", hitbox = 0.75, nocollision = true}
g_HnS.PropList[2] <- {name = "hotel_lamp001", model = "models/props_urban/hotel_lamp001.mdl", hitbox = 0.65, nocollision = true}
g_HnS.PropList[3] <- {name = "ashtray_stand001", model = "models/props_urban/ashtray_stand001.mdl", hitbox = 0.6, nocollision = true}
g_HnS.PropList[4] <- {name = "plastic_bucket001", model = "models/props_urban/plastic_bucket001.mdl", hitbox = 0.4, nocollision = true}
g_HnS.PropList[5] <- {name = "mini_fridge", model = "models/props_downtown/mini_fridge.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 24), mins = Vector(-12, -12, 0)}
g_HnS.PropList[6] <- {name = "urban_pot_clay02", model = "models/props_foliage/urban_pot_clay02.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 16), mins = Vector(-8, -8, 0)}
g_HnS.PropList[7] <- {name = "urban_pot_clay03", model = "models/props_foliage/urban_pot_clay03.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 16), mins = Vector(-8, -8, 0)}
g_HnS.PropList[8] <- {name = "hotel_chair001", model = "models/props_urban/hotel_chair001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 48), mins = Vector(-26, -26, 0)}
g_HnS.PropList[9] <- {name = "vending_machine", model = "models/props/cs_office/vending_machine.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 90, 0), skin = 1, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
g_HnS.PropList[10] <- {name = "snack_machine2", model = "models/props_equipment/snack_machine2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 86), mins = Vector(-26, -26, 0)}
g_HnS.PropList[11] <- {name = "fridge_mini", model = "models/props_interiors/fridge_mini.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 34), mins = Vector(-12, -12, 0)}
g_HnS.PropList[12] <- {name = "cafe_barstool1", model = "models/props_furniture/cafe_barstool1.mdl", hitbox = 0.6, nocollision = true, ang = Vector(0, 45, 0), physicsblocker = true, maxs = Vector(10, 10, 36), mins = Vector(-10, -10, 0)}
g_HnS.PropList[13] <- {name = "microwave01", model = "models/props/cs_militia/microwave01.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(17, 17, 24), mins = Vector(-17, -17, 0)}
g_HnS.PropList[14] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}

// Entities Manipulation
local hEntity;
if ((hEntity = Entities.FindInSphere(null, Vector(1810.791, 7227.514, 2464.031), 20.0)) != null) hEntity.Kill();
if ((hEntity = Entities.FindInSphere(null, Vector(1810.966, 6592.707, 2464.031), 20.0)) != null) hEntity.Kill();
while ((hEntity = Entities.FindByModel(hEntity, "models/props_windows/hotel_window_glass001.mdl")) != null) hEntity.Kill();
while ((hEntity = Entities.FindByModel(hEntity, "models/props_windows/hotel_window_glass002.mdl")) != null) hEntity.Kill();
EntFire("func_breakable", "Kill");
EntFire("elevator_panel", "Kill");

// Player Blocker
CreateInvisibleWall("physics_blocker_1", Vector(2516.067, 6170.938, 2655.977), Vector(8, 368, 256), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_2", Vector(2350.756, 6487.687, 2655.289), Vector(192, 8, 256), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_3", Vector(2350.756, 6517.687, 2655.289), Vector(8, 1256, 256), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_4", Vector(2286.329, 7690.032, 2654.553), Vector(64, 8, 192), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_5", Vector(2448.290, 6165.466, 2655.771), Vector(64, 8, 192), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_6", Vector(2347.767, 5593.427, 2672.031), Vector(8, 64, 92), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_7", Vector(1639.740, 6394.977, 2600.435), Vector(8, 1256, 192), Vector(0, 0, -192));
CreateInvisibleWall("physics_blocker_8", Vector(383.375, 4970.280, 2691.281), Vector(2048, 8, 192), Vector(0, 0, -256));
CreateInvisibleWall("physics_blocker_9", Vector(2302.031, 6382.031, 2770.031), Vector(192, 192, 16), Vector());
CreateInvisibleWall("physics_blocker_10", Vector(382.555, 6270.823, 2691.281), Vector(1256, 8, 192), Vector());
CreateInvisibleWall("physics_blocker_11", Vector(1314.779, 5526.333, 2464.031), Vector(8, 192, 128), Vector());
CreateInvisibleWall("physics_blocker_12", Vector(1660.529, 6531.017, 2656.031), Vector(256, 128, 128), Vector());
CreateInvisibleWall("physics_blocker_13", Vector(1825.475, 7162.615, 2464.031), Vector(112, 128, 128), Vector());
CreateInvisibleWall("physics_blocker_14", Vector(1831.379, 6525.675, 2464.031), Vector(112, 128, 128), Vector());