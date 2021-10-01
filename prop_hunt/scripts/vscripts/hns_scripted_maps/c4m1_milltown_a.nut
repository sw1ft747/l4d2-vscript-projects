// Squirrel
// Prop Hunt
// c4m1 Scripted Map

local hEntity;
while ((hEntity = Entities.FindByClassname(hEntity, "predicted_viewmodel")) != null)
{
	hEntity.PrecacheModel("models/props_urban/fence001_64.mdl");
	hEntity.PrecacheModel("models/props_urban/fence001_256.mdl");
	hEntity.PrecacheModel("models/props_crates/static_crate_40.mdl");
	hEntity.PrecacheModel("models/props_foliage/urban_hedge_256_128_high.mdl");
	hEntity.PrecacheModel("models/props_fortifications/concrete_barrier001_128_reference.mdl");
	hEntity.PrecacheModel("models/props_urban/wood_fence002_256.mdl");
	hEntity.PrecacheModel("models/props_misc/standing_tarp_tall.mdl");
	hEntity.PrecacheModel("models/props_urban/wood_fence001_64.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break01.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break02.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break03.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break04.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break05.mdl");
	hEntity.PrecacheModel("models/props_interiors/stove02_break06.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_01.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_02.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_03.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_04.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_05.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_06.mdl");
	hEntity.PrecacheModel("models/props_interiors/refrigerator03_damaged_07.mdl");
}

local rValue = RandomInt(1, 2);
if (rValue == 1)
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-6986.270, 7491.930, 103.877)
		Vector(-7000.352, 7724.923, 104.273)
		Vector(-6994.992, 7867.715, 104.899)
		Vector(-6993.312, 7608.456, 98.385)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-3450.212, 7599.089, 231.605)
		Vector(-1618.088, 6206.566, 105.635)
		Vector(-4344.123, 7379.857, 103.737)
		Vector(-5824.938, 7306.243, 104.031)
	]
	g_HnS.PropList[1] <- {name = "traffic_barrel", model = "models/props_fairgrounds/traffic_barrel.mdl", hitbox = 0.85, nocollision = false}
	g_HnS.PropList[2] <- {name = "traffic_barrier001", model = "models/props_fortifications/traffic_barrier001.mdl", hitbox = 0.75, nocollision = false}
	g_HnS.PropList[3] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[4] <- {name = "phone_booth", model = "models/props_equipment/phone_booth.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 80), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[5] <- {name = "table_cafeteria", model = "models/props_interiors/table_cafeteria.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 38), mins = Vector(-28, -28, 0)}
	g_HnS.PropList[6] <- {name = "stove04_industrial", model = "models/props_interiors/stove04_industrial.mdl" hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 88), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[7] <- {name = "dumpster_2", model = "models/props_junk/dumpster_2.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(32, 38, 54), mins = Vector(-32, -38, 0)}
	g_HnS.PropList[8] <- {name = "washer_box", model = "models/props/cs_assault/washer_box.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(20, 20, 68), mins = Vector(-20, -20, 0)}
	g_HnS.PropList[9] <- {name = "gas_sign001", model = "models/props_urban/gas_sign001.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 66), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[10] <- {name = "fire_hydrant001", model = "models/props_urban/fire_hydrant001.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 44), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[11] <- {name = "round_table001", model = "models/props_urban/round_table001.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(38, 38, 44), mins = Vector(-38, -38, 0)}
	g_HnS.PropList[12] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 46), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[13] <- {name = "outhouse001", model = "models/props_urban/outhouse001.mdl", hitbox = 1.1, nocollision = true, physicsblocker = true, maxs = Vector(32, 32, 112), mins = Vector(-32, -32, 0)}
	g_HnS.PropList[14] <- {name = "big_wheel001", model = "models/props_urban/big_wheel001.mdl" hitbox = 0.6, nocollision = true}
	local vecPos = Vector(-4653.000, 8654.651, 96.031)
	for (local i = 0; i < 6; i++)
	{
		SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = vecPos, angles = Vector(0, 90, 0), solid = 6});
		vecPos += Vector(-250, 0, 0)
	}
	vecPos = Vector(-6737.775, 7340.368, 96.031)
	for (local i = 0; i < 2; i++)
	{
		SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = vecPos, angles = Vector(0, -90, 0), solid = 6});
		vecPos += Vector(-250, 0, 0)
	}
	vecPos = Vector(-6612.608, 7215.528, 96.031)
	for (local i = 0; i < 3; i++)
	{
		SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = vecPos, solid = 6});
		vecPos += Vector(0, -250, 0)
	}
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/outhouse_door001.mdl", origin = Vector(-5799.000, 6660.000, 100.941), angles = Vector(0, 90, 0), solid = 6, minhealthdmg = 1e6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_64.mdl", origin = Vector(-7148.666, 8064.105, 94.368), angles = Vector(0, -90, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = Vector(-6990.666, 8064.105, 94.368), angles = Vector(0, -90, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/fence001_256.mdl", origin = Vector(-6740.666, 8064.105, 94.368), angles = Vector(0, -90, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_fortifications/concrete_barrier001_128_reference.mdl", origin = Vector(-5620.299, 6676.447, 96.095), angles = Vector(0, -90, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_fortifications/concrete_barrier001_128_reference.mdl", origin = Vector(-5708.911, 6610.545, 96.031), angles = Vector(0, 0, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_foliage/urban_hedge_256_128_high.mdl", origin = Vector(-1205.697, 5705.407, 96.425), angles = Vector(0, 90, 0), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_crates/static_crate_40.mdl", origin = Vector(-3529.451, 7540.863, 96.411), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_crates/static_crate_40.mdl", origin = Vector(-3552.997, 7547.925, 137.216), solid = 6});
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_crates/static_crate_40.mdl", origin = Vector(-3576.558, 7550.631, 97.184), solid = 6});
	CreateInvisibleWall("physics_blocker_1", Vector(-7256.504, 8063.492, 83.851), Vector(1464, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_2", Vector(-5822.794, 8653.740, 76.160), Vector(1512, 8, 768), Vector());
	CreateInvisibleWall("physics_blocker_3", Vector(-7378.852, 6573.653, 96.031), Vector(768, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_4", Vector(-6748.852, 6573.653, 96.031), Vector(1024, 8, 768), Vector());
	CreateInvisibleWall("physics_blocker_5", Vector(-5703.297, 6588.406, 100.441), Vector(1616, 96, 768), Vector());
	CreateInvisibleWall("physics_blocker_6", Vector(-4594.973, 7754.167, 245.906), Vector(512, 1024, 768), Vector());
	CreateInvisibleWall("physics_blocker_7", Vector(-3344.774, 6516.587, 238.949), Vector(512, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_8", Vector(-3699.569, 7725.957, 316.772), Vector(999, 512, 768), Vector());
	CreateInvisibleWall("physics_blocker_9", Vector(-2132.444, 7134.047, 337.813), Vector(768, 368, 768), Vector());
	CreateInvisibleWall("physics_blocker_10", Vector(-1582.408, 7012.762, 304.247), Vector(128, 128, 192), Vector());
	CreateInvisibleWall("physics_blocker_11", Vector(-2102.425, 5451.750, 250.330), Vector(656, 444, 768), Vector());
	CreateInvisibleWall("physics_blocker_12", Vector(-1264.369, 5045.666, 99.611), Vector(128, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_13", Vector(-1191.425, 5813.538, 99.785), Vector(64, 3096, 768), Vector());
	local hTable = {origin = Vector(-7208.967, 7359.708, 77.264), damage = 500.0, damagetype = DMG_FALL, spawnflags = TR_CLIENTS}
	local hEntity = SpawnEntityFromTable("trigger_hurt", hTable);
	hEntity.__KeyValueFromVector("maxs", Vector(16, 1024, 16));
	hEntity.__KeyValueFromVector("mins", Vector(0, 0, -8));
	hEntity.__KeyValueFromInt("solid", 2);
}
else
{
	g_aHunterSpawnOrigin <-
	[
		Vector(-467.201, 6440.625, 104.031)
		Vector(-469.070, 6503.969, 104.031)
		Vector(-495.986, 6457.157, 104.031)
		Vector(-440.256, 6457.167, 104.031)
	]
	g_aPropSpawnOrigin <-
	[
		Vector(-944.652, 5769.611, 264.031)
		Vector(1876.468, 2667.995, 95.886)
		Vector(586.935, 7245.413, 96.031)
		Vector(599.300, 5722.273, 96.031)
	]
	g_HnS.PropList[1] <- {name = "plastic_chair001", model = "models/props_urban/plastic_chair001.mdl", hitbox = 0.75, nocollision = true}
	g_HnS.PropList[2] <- {name = "sofa_chair02", model = "models/props_interiors/sofa_chair02.mdl", hitbox = 0.7, nocollision = true, physicsblocker = true, maxs = Vector(22, 22, 40), mins = Vector(-22, -22, 0)}
	g_HnS.PropList[3] <- {name = "stove02", model = "models/props_interiors/stove02.mdl", hitbox = 0.75, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 32), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[4] <- {name = "table_bedside", model = "models/props_interiors/table_bedside.mdl", hitbox = 0.6, nocollision = true, ang = Vector(0, 90, 0), physicsblocker = true, maxs = Vector(12, 12, 34), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[5] <- {name = "trashcluster01a", model = "models/props_junk/trashcluster01a.mdl", hitbox = 0.8, nocollision = true}
	g_HnS.PropList[6] <- {name = "urban_pot_clay02", model = "models/props_foliage/urban_pot_clay02.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[7] <- {name = "traffic_barrier001", model = "models/props_fortifications/traffic_barrier001.mdl", hitbox = 0.75, nocollision = false}
	g_HnS.PropList[8] <- {name = "dining_table_round", model = "models/props_interiors/dining_table_round.mdl", hitbox = 0.8, nocollision = true, physicsblocker = true, maxs = Vector(28, 28, 32), mins = Vector(-28, -28, 0)}
	g_HnS.PropList[9] <- {name = "urban_pot_bigplant01", model = "models/props_foliage/urban_pot_bigplant01.mdl", hitbox = 0.65, nocollision = true, physicsblocker = true, maxs = Vector(12, 12, 32), mins = Vector(-12, -12, 0)}
	g_HnS.PropList[10] <- {name = "refrigerator03", model = "models/props_interiors/refrigerator03.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(16, 16, 70), mins = Vector(-16, -16, 0)}
	g_HnS.PropList[11] <- {name = "lamp_table02", model = "models/props_interiors/lamp_table02.mdl", hitbox = 0.5, nocollision = true}
	g_HnS.PropList[12] <- {name = "washer_box", model = "models/props/cs_assault/washer_box.mdl", hitbox = 1.0, nocollision = true, physicsblocker = true, maxs = Vector(20, 20, 68), mins = Vector(-20, -20, 0)}
	g_HnS.PropList[13] <- {name = "fire_hydrant001", model = "models/props_urban/fire_hydrant001.mdl", hitbox = 0.6, nocollision = true, physicsblocker = true, maxs = Vector(10, 10, 44), mins = Vector(-10, -10, 0)}
	g_HnS.PropList[14] <- {name = "microwave01", model = "models/props/cs_militia/microwave01.mdl", hitbox = 0.5, nocollision = true}
	local vecPos = Vector(789.720, 2966.861, 95.586)
	for (local i = 0; i < 6; i++)
	{
		SpawnEntityFromTable("prop_dynamic", {model = "models/props_urban/wood_fence001_256.mdl", origin = vecPos, solid = 6, angles = Vector(0, 90, 0), rendercolor = "138 189 153"})
		vecPos += Vector(255, 0, 0)
	}
	CreateInvisibleWall("physics_blocker_1", Vector(-1264.369, 5045.666, 99.611), Vector(8, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_2", Vector(-1255.422, 5684.875, 95.776), Vector(128, 3096, 768), Vector());
	CreateInvisibleWall("physics_blocker_3", Vector(82.351, 2911.636, 307.715), Vector(768, 768, 768), Vector());
	CreateInvisibleWall("physics_blocker_4", Vector(-400.871, 4010.758, 257.938), Vector(888, 1072, 768), Vector());
	CreateInvisibleWall("physics_blocker_5", Vector(992.647, 6862.054, 390.959), Vector(768, 512, 768), Vector());
	CreateInvisibleWall("physics_blocker_6", Vector(1003.155, 6040.676, 280.281), Vector(512, 666, 768), Vector());
	CreateInvisibleWall("physics_blocker_7", Vector(1068.421, 4014.266, 385.304), Vector(666, 666, 768), Vector());
	CreateInvisibleWall("physics_blocker_8", Vector(-917.595, 5549.448, 490.031), Vector(666, 512, 768), Vector());
	CreateInvisibleWall("physics_blocker_9", Vector(2059.409, 2955.789, 208.281), Vector(1024, 2048, 768), Vector());
	CreateInvisibleWall("physics_blocker_10", Vector(664.078, 2949.579, 207.617), Vector(1425, 16, 768), Vector());
	CreateInvisibleWall("physics_blocker_11", Vector(1696.386, 3049.616, 242.879), Vector(368, 256, 768), Vector());
}

local vecPos = Vector(-1160.413, 6556.871, 90.607)
for (local i = 0; i < 4; i++)
{
	SpawnEntityFromTable("prop_dynamic", {model = "models/props_foliage/urban_hedge_256_128_high.mdl", origin = vecPos, angles = Vector(0, 90, 0), solid = 6});
	vecPos += Vector(0, -250, 0)
}

EntFire("prop_car_alarm", "Kill");