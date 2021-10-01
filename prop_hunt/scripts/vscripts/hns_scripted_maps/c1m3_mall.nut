// Squirrel
// Prop Hunt
// c1m3 Scripted Map

local hEntity ;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_fortifications/barricade001_128_reference.mdl");
}

g_aHunterSpawnOrigin <-
[
	Vector(6574.818, -1350.691, 24.031)
	Vector(6678.173, -1487.707, 24.031)
	Vector(6965.894, -1421.455, 24.031)
	Vector(6791.094, -1443.219, 24.031)
]
g_aPropSpawnOrigin <-
[
	Vector(3615.587, -2608.706, -63.969)
	Vector(4214.948, -2297.929, 280.031)
	Vector(6953.380, -2533.411, 280.031)
	Vector(5873.389, -2131.596, 24.031)
]

g_HnS.PropList[1] <- {name = "mall_grass_bush01", model = "models/props_foliage/mall_grass_bush01.mdl", hitbox = 0.8, nocollision = true}
g_HnS.PropList[2] <- {name = "cash_register", model = "models/props_mall/cash_register.mdl", hitbox = 0.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 20), mins = Vector(-16, -16, 0)}
g_HnS.PropList[3] <- {name = "ashtray_stand001", model = "models/props_urban/ashtray_stand001.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(8, 8, 32), mins = Vector(-8, -8, 0)}
g_HnS.PropList[4] <- {name = "trashcan01", model = "models/props_interiors/trashcan01.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 56), mins = Vector(-12, -12, 0)}
g_HnS.PropList[5] <- {name = "table_cafeteria", model = "models/props_interiors/table_cafeteria.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 38), mins = Vector(-28, -28, 0)}
g_HnS.PropList[6] <- {name = "phone_booth_airport", model = "models/props_unique/airport/phone_booth_airport.mdl", hitbox = 1.5, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 106), mins = Vector(-16, -16, 0)}
g_HnS.PropList[7] <- {name = "mall_pot_large02", model = "models/props_foliage/mall_pot_large02.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(30, 30, 40), mins = Vector(-30, -30, 0)}
g_HnS.PropList[8] <- {name = "mall_display_06", model = "models/props_mall/mall_display_06.mdl", hitbox = 1.1, nocollision = false, physicsblocker = true, maxs = Vector(16, 16, 72), mins = Vector(-16, -16, 0)}
g_HnS.PropList[9] <- {name = "hotel_chair001", model = "models/props_urban/hotel_chair001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(26, 26, 48), mins = Vector(-26, -26, 0)}
g_HnS.PropList[10] <- {name = "atm01", model = "models/props_unique/atm01.mdl", hitbox = 1.1, nocollision = false, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
g_HnS.PropList[11] <- {name = "boxes_garage_lower", model = "models/props/cs_militia/boxes_garage_lower.mdl", hitbox = 1.0, nocollision = true, ang = Vector(0, 45, 0)}

local vecPos = Vector(1705.998, -1518.294, 0.031)
for (local i = 1; i <= 10; i++)
{
	vecPos += Vector(100, 0, 0);
	SpawnEntityFromTable("prop_dynamic", {origin = vecPos, model = "models/props_fortifications/barricade001_128_reference.mdl", angles = Vector(0, -90, 0)});
}

vecPos = Vector(5380.035, -2923.261, 0.031)
for (local i = 1; i <= 21; i++)
{
	if (i == 4 || i == 5) vecPos += Vector(0, 0, 12);
	vecPos += Vector(100, 0, 0);
	SpawnEntityFromTable("prop_dynamic", {origin = vecPos, model = "models/props_fortifications/barricade001_128_reference.mdl", angles = Vector(0, 90, 0)});
}

CreateInvisibleWall("physics_blocker_1", Vector(1743.726, -1522.392, 0.031), Vector(1024, 8, 256), Vector());
CreateInvisibleWall("physics_blocker_2", Vector(5313.237, -2931.534, 0.031), Vector(2292, 8, 256), Vector());
CreateInvisibleWall("physics_blocker_3", Vector(2748.998, -2005.882, 165.060), Vector(64, 368, 64), Vector());
CreateInvisibleWall("physics_blocker_4", Vector(7178.626, -2545.811, 410.060), Vector(268, 232, 64), Vector());
CreateInvisibleWall("physics_blocker_5", Vector(5229.775, -2751.019, 75.096), Vector(64, 232, 128), Vector());

sayf("[HnS] There are no props which you can pick up =/");