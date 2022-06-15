// Gas Station Explosion

class CPluginGasStationExplosion extends VSLU.IScriptPlugin
{
	function Load()
	{
		VSLU.RegisterOnTickFunction("g_GasStationExplosion.GSE_Think");
		VSLU.RegisterOnTickFunction("g_GasStationExplosion.InvalidEntitiesListener_Think");
		
		g_GasStationExplosion.Precache();
		g_GasStationExplosion.ParseConfigFile();

		VSLU.RegisterChatCommand("!gs_mode", g_GasStationExplosion.SwitchMode);
		VSLU.RegisterChatCommand("!gs_clear", g_GasStationExplosion.Clear);
		VSLU.RegisterChatCommand("!gas", g_GasStationExplosion.Forward);
		VSLU.RegisterChatCommand("!bgas", g_GasStationExplosion.Behind);
		VSLU.RegisterChatCommand("!lgas", g_GasStationExplosion.Left);
		VSLU.RegisterChatCommand("!rgas", g_GasStationExplosion.Right);

		printl("[Gas Station Explosion]\nAuthor: Sw1ft\nVersion: 1.0.6");
	}

	function Unload()
	{
		VSLU.RemoveOnTickFunction("g_GasStationExplosion.GSE_Think");
		VSLU.RemoveOnTickFunction("g_GasStationExplosion.InvalidEntitiesListener_Think");

		VSLU.RemoveChatCommand("!gs_mode");
		VSLU.RemoveChatCommand("!gs_clear");
		VSLU.RemoveChatCommand("!gas");
		VSLU.RemoveChatCommand("!bgas");
		VSLU.RemoveChatCommand("!lgas");
		VSLU.RemoveChatCommand("!rgas");
	}

	function OnRoundStartPost()
	{
		local hEntity, chance;

		if ((chance = g_GasStationExplosion.Settings.Chance) > 0)
		{
			foreach (map, tbl in g_GasStationExplosion.tGasStationExpParams)
			{
				if (VSLU.sMapName == map)
				{
					if (RandomInt(1, 100) <= chance)
					{
						g_GasStationExplosion.SpawnGasStation(g_GasStationExplosion.tGasStationExpParams[VSLU.sMapName]["origin"], g_GasStationExplosion.tGasStationExpParams[VSLU.sMapName]["angles"]);
						printl("> [Gas Station Explosion] Gas station has been spawned for the current map at " + kvstr(g_GasStationExplosion.tGasStationExpParams[VSLU.sMapName]["origin"]));
					}
				}
			}
		}
	}

	function OnRoundEnd()
	{
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CPluginGasStationExplosion";
	static m_sScriptPluginName = "Gas Station Explosion";
}

class CGasStationExplosion
{
	constructor(vecOrigin, eAngles, bDamage)
	{
		eAngles.x = 0.0;
		eAngles.z = 0.0;
		eAngles.y += 90.0;
		vecOrigin.z += 0.95;

		local sAngles = kvstr(eAngles);
		local vecForward = eAngles.Forward();
		local vecLeft = eAngles.Left() * -1;
		local vecGasPumpLeft = vecOrigin + Vector(0, 0, 8) + vecForward * 178 + vecLeft * -9;
		local vecGasPumpRight = vecOrigin + Vector(0, 0, 8) + vecForward * -215 + vecLeft * -9;

		m_aSoundEntities = [];
		m_aGasStation = [];
		m_aTimers = [];

		if (bDamage)
		{
			m_aTrianglePoints =
			[
				vecOrigin + vecLeft * 115 + vecForward * -155
				vecOrigin + vecLeft * -115 + vecForward * -155
				vecOrigin + vecLeft * 115 + vecForward * 330
			];

			m_hGasPumpLeftExplosion = SpawnEntityFromTable("env_explosion", {
				origin = vecGasPumpLeft + Vector(0, 0, 64)
				iMagnitude = 1000
				iRadiusOverride = 400
				spawnflags = 1852
				rendermode = 5
				ignoredClass = 4
				targetname = "__gas_station_exp__"
				fireballsprite = "sprites/zerogxplode.vmt"
			});

			m_hGasPumpRightExplosion = SpawnEntityFromTable("env_explosion", {
				origin = vecGasPumpRight + Vector(0, 0, 64)
				iMagnitude = 1000
				iRadiusOverride = 400
				spawnflags = 1852
				rendermode = 5
				ignoredClass = 4
				targetname = "__gas_station_exp__"
				fireballsprite = "sprites/zerogxplode.vmt"
			});

			getroottable()[m_sHurtFunction = "_gas_station_hurt" + UniqueString()] <- function(aTrianglePoints)
			{
				local hEntity, vecPos;
				local function HurtEntity(hEntity, vecPos)
				{
					if ( VSLU.Math.VectorBetween(vecOrigin - Vector(500, 500, 500), vecOrigin + Vector(500, 500, 500), vecPos) )
					{
						if ( vecPos.z + 200 > vecOrigin.z && vecPos.z - 200 < vecOrigin.z )
						{
							if ( (aTrianglePoints[1] - aTrianglePoints[0]).Dot(vecPos - aTrianglePoints[0]) > 0 && (aTrianglePoints[0] - aTrianglePoints[1]).Dot(vecPos - aTrianglePoints[1]) > 0 )
							{
								if ( (aTrianglePoints[2] - aTrianglePoints[0]).Dot(vecPos - aTrianglePoints[0]) > 0 && (aTrianglePoints[0] - aTrianglePoints[2]).Dot(vecPos - aTrianglePoints[2]) > 0 )
								{
									hEntity.TakeDamage(10.0, DMG_BURN, null);
								}
							}
						}
					}
				}

				while (hEntity = Entities.FindByClassname(hEntity, "player"))
				{
					if ( VSLU.IsEntityAlive(hEntity) && NetProps.GetPropInt(hEntity, "m_iObserverMode") == 0 && !NetProps.GetPropInt(hEntity, "m_isGhost") )
					{
						HurtEntity(hEntity, VSLU.Player.GetBodyPosition(hEntity))
					}
				}

				hEntity = null;
				while (hEntity = Entities.FindByClassname(hEntity, "infected"))
				{
					if ( VSLU.IsEntityAlive(hEntity) )
					{
						HurtEntity(hEntity, hEntity.GetOrigin())
					}
				}

				hEntity = null;
				while (hEntity = Entities.FindByClassname(hEntity, "witch"))
				{
					if ( VSLU.IsEntityAlive(hEntity) )
					{
						HurtEntity(hEntity, hEntity.GetOrigin())
					}
				}
				
				foreach (model in ["models/props_junk/gascan001a.mdl", "models/props_equipment/oxygentank01.mdl", "models/props_junk/propanecanister001a.mdl", "models/props_industrial/barrel_fuel.mdl"])
				{
					hEntity = null;
					while (hEntity = Entities.FindByModel(hEntity, model))
					{
						HurtEntity(hEntity, hEntity.GetOrigin())
					}
				}
			}
		}

		getroottable()[m_sPushFunction = "__gas_station_push" + UniqueString()] <- function()
		{
			local hPlayer, vecDirection;
			while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
			{
				if (VSLU.IsEntityAlive(hPlayer) && NetProps.GetPropInt(hPlayer, "m_iObserverMode") == 0 && !NetProps.GetPropInt(hPlayer, "m_isGhost"))
				{
					if ((hPlayer.GetOrigin() - vecOrigin).LengthSqr() <= 25e4)
					{
						if (NetProps.GetPropInt(hPlayer, "m_fFlags") & FL_ONGROUND)
						{
							vecDirection = hPlayer.GetOrigin() - vecOrigin; vecDirection.z = 0.0;
							NetProps.SetPropVector(hPlayer, "m_vecBaseVelocity", vecDirection.Normalize() * 500);
						}
					}
				}
			}
		}

		for (local i = 0; i < 9; i++)
		{
			m_aGasStation.push(SpawnEntityFromTable("prop_dynamic", {
				origin = vecOrigin
				angles = sAngles
				disableshadows = 1
				targetname = "__gas_station_exp__"
				model = g_GasStationExplosion.sGasStationExpModel[i]
			}));
		}

		m_hGasPumpExplosionShake = SpawnEntityFromTable("env_shake", {
			origin = vecOrigin
			amplitude = 16
			radius = 4096
			duration = 0.7
			frequency = 20
			targetname = "__gas_station_exp__"
		});

		m_hGasStationExplosionShake = SpawnEntityFromTable("env_shake", {
			origin = vecOrigin
			amplitude = 12
			radius = 4096
			duration = 3
			frequency = 9
			targetname = "__gas_station_exp__"
		});

		m_aSoundEntities.push(m_hBurningPipeLeft = SpawnEntityFromTable("ambient_generic", {
			origin = vecGasPumpLeft + Vector(0, 0, 32)
			disableshadows = 1
			health = 10
			radius = 2048
			spawnflags = 16
			targetname = "__gas_station_exp__"
			message = "fire_large"
		}));

		m_aSoundEntities.push(m_hBurningPipeRight = SpawnEntityFromTable("ambient_generic", {
			origin = vecGasPumpRight + Vector(0, 0, 32)
			disableshadows = 1
			health = 10
			radius = 2048
			spawnflags = 16
			targetname = "__gas_station_exp__"
			message = "fire_large"
		}));

		m_aSoundEntities.push(m_hGasExplosionSound = SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin + Vector(0, 0, 92)
			disableshadows = 1
			health = 10
			radius = 2642
			spawnflags = 1 | 16 | 32
			targetname = "__gas_station_exp__"
			message = "Objects.gas_station_explosion"
		}));

		m_aSoundEntities.push(m_hGasExplosionImpactSound = SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin + Vector(0, 0, 92)
			disableshadows = 1
			health = 10
			radius = 2642
			spawnflags = 1 | 16 | 32
			targetname = "__gas_station_exp__"
			message = "SmashCave.WoodRockCollapse"
		}));

		m_aSoundEntities.push(m_hGasPumpExplosionSound = SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin + Vector(0, 0, 92)
			disableshadows = 1
			health = 10
			radius = 2642
			spawnflags = 1 | 16 | 32
			targetname = "__gas_station_exp__"
			message = "explode_3"
		}));

		VSLU.AcceptEntityInput(m_hGasStationBrush = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin - Vector(0, 0, 144.031)
			angles = sAngles
			solid = 6
			effects = 16
			spawnflags = 256
			disableshadows = 1
			StartDisabled = 1
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[9]
		}), "DisableCollision");

		VSLU.AttachEntity(m_hDebrisDoor = SpawnEntityFromTable("func_door", {
			origin = vecOrigin - Vector(0, 0, 216.031)
			angles = kvstr(eAngles - QAngle(0, 90, 0))
			disableshadows = 1
			speed = 200
			lip = -128
			wait = -1
			spawnpos = 1
			movedir = "90 0 0"
			targetname = "__gas_station_exp__"
		}), m_hGasStationBrush);

		m_hGasStationPit = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = sAngles
			disableshadows = 1
			StartDisabled = 1
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[11]
		});

		m_hGasPumpLeft = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = sAngles
			disableshadows = 1
			StartDisabled = 1
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[10]
		});

		m_hGasPumpRight = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin + vecForward * -393
			angles = sAngles
			disableshadows = 1
			StartDisabled = 1
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[10]
		});

		m_hGasPumpLeftParticle = SpawnEntityFromTable("info_particle_system", {
			origin = vecGasPumpLeft
			angles = sAngles
			targetname = "__gas_station_exp__"
			effect_name = "gas_explosion_pump"
		});

		m_hGasPumpRightParticle = SpawnEntityFromTable("info_particle_system", {
			origin = vecGasPumpRight
			angles = sAngles
			targetname = "__gas_station_exp__"
			effect_name = "gas_explosion_pump"
		});

		m_hGasStationExplosionParticle = SpawnEntityFromTable("info_particle_system", {
			origin = vecGasPumpLeft - Vector(0, 0, 36.03125)
			angles = sAngles
			targetname = "__gas_station_exp__"
			effect_name = "gas_explosion_main"
		});

		m_hGasPumpLeftBreakable = SpawnEntityFromTable("prop_physics", {
			origin = vecGasPumpLeft
			angles = kvstr(eAngles - QAngle(0, 90, 0))
			spawnflags = 8 | 8192
			disableshadows = 1
			pressuredelay = 4
			physdamagescale = 1
			ExplodeDamage = 90
			PerformanceMode = 1
			Damagetype = DMG_CLUB
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[12]
		});

		m_hGasPumpRightBreakable = SpawnEntityFromTable("prop_physics", {
			origin = vecGasPumpRight
			angles = kvstr(eAngles - QAngle(0, 90, 0))
			spawnflags = 8 | 8192
			disableshadows = 1
			pressuredelay = 4
			physdamagescale = 1
			ExplodeDamage = 90
			PerformanceMode = 1
			Damagetype = DMG_CLUB
			targetname = "__gas_station_exp__"
			model = g_GasStationExplosion.sGasStationExpModel[12]
		});

		g_GasStationExplosion.aInvalidEntitiesListener.push({
			ent = m_hGasPumpLeftBreakable
			func = g_GasStationExplosion.OnGasPumpKill
			params = {
				pump = "left"
				__instance = this
			}
		});

		g_GasStationExplosion.aInvalidEntitiesListener.push({
			ent = m_hGasPumpRightBreakable
			func = g_GasStationExplosion.OnGasPumpKill
			params = {
				pump = "right"
				__instance = this
			}
		});

		m_aEntities =
		[
			m_hGasStationBrush
			m_hDebrisDoor
			m_hGasStationPit
			m_hGasPumpLeft
			m_hGasPumpRight
			m_hGasPumpLeftParticle
			m_hGasPumpRightParticle
			m_hGasPumpExplosionShake
			m_hGasPumpExplosionSound
			m_hGasStationExplosionParticle
			m_hGasStationExplosionShake
			m_hGasExplosionImpactSound
		];
		m_aEntities.extend(m_aGasStation);
		m_aEntities.extend(m_aSoundEntities);
	}

	function StartPreExplosion()
	{
		if (!m_bExplosionStarted)
		{
			VSLU.AcceptEntityInput(m_hGasExplosionSound, "PlaySound");
			m_aTimers.push(VSLU.CreateTimer(2.0, function(__instance){
				if (!__instance.StartExplosion())
					__instance.ClearExplosion();
			}, this));
			m_bExplosionStarted = true;
		}
	}

	function StartExplosion()
	{
		if (IsAllEntitiesValid())
		{
			VSLU.AcceptEntityInput(m_hGasExplosionSound, "PlaySound");
			VSLU.AcceptEntityInput(m_hBurningPipeLeft, "PlaySound", "", 1.0);
			VSLU.AcceptEntityInput(m_hBurningPipeRight, "PlaySound", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasExplosionImpactSound, "PlaySound", "", 3.1);

			VSLU.AcceptEntityInput(m_hGasStationExplosionShake, "StartShake");
			VSLU.AcceptEntityInput(m_hGasStationExplosionParticle, "Start", "", 0.5);

			VSLU.AcceptEntityInput(m_hDebrisDoor, "Close", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasStationBrush, "Enable", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasStationBrush, "EnableCollision", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasStationPit, "Enable", "", 1.0);

			VSLU.AcceptEntityInput(m_hGasPumpLeftParticle, "Kill", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpRightParticle, "Kill", "", 1.0);

			VSLU.AcceptEntityInput(m_hGasPumpLeft, "Kill", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpRight, "Kill", "", 1.0);

			VSLU.AcceptEntityInput(m_hGasPumpLeftBreakable, "Break");
			VSLU.AcceptEntityInput(m_hGasPumpRightBreakable, "Break");

			VSLU.AcceptEntityInput(m_hGasExplosionSound, "Kill", "", 12.0);
			VSLU.AcceptEntityInput(m_hGasExplosionImpactSound, "Kill", "", 12.0);
			VSLU.AcceptEntityInput(m_hGasStationExplosionShake, "Kill", "", 12.0);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionShake, "Kill", "", 6.0);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionSound, "Kill", "", 6.0);

			if (!m_bGasPumpLeftExploded)
			{
				if (m_hGasPumpLeftExplosion) VSLU.AcceptEntityInput(m_hGasPumpLeftExplosion, "Explode");
				VSLU.AcceptEntityInput(m_hGasPumpLeftParticle, "Start");
				VSLU.AcceptEntityInput(m_hGasPumpExplosionSound, "PlaySound");
			}
			else if (!m_bGasPumpRightExploded)
			{
				if (m_hGasPumpRightExplosion) VSLU.AcceptEntityInput(m_hGasPumpRightExplosion, "Explode");
				VSLU.AcceptEntityInput(m_hGasPumpRightParticle, "Start");
				VSLU.AcceptEntityInput(m_hGasPumpExplosionSound, "PlaySound");
			}

			foreach (ent in m_aGasStation)
			{
				VSLU.AcceptEntityInput(ent, "SetAnimation", "boom");
			}

			if (g_GasStationExplosion.Settings.HordeDelay > 0)
			{
				if (!Entities.FindByName(null, "director"))
				{
					SpawnEntityFromTable("info_director", {targetname = "director"});
				}

				m_aTimers.push(VSLU.CreateTimer(g_GasStationExplosion.Settings.HordeDelay, function(){
					EntFire("director", "ForcePanicEvent", "1");
					EntFire("@director", "ForcePanicEvent", "1");
				}));
			}

			if (m_sHurtFunction)
			{
				m_aTimers.push(VSLU.CreateTimer(0.4, VSLU.RegisterLoopFunction, m_sHurtFunction, 0.5, m_aTrianglePoints));
				m_aTimers.push(VSLU.CreateTimer(64.6, function(sHurtFunction, aTrianglePoints){
					if (VSLU.IsLoopFunctionRegistered(sHurtFunction, aTrianglePoints))
						VSLU.RemoveLoopFunction(sHurtFunction, aTrianglePoints);
				}, m_sHurtFunction, m_aTrianglePoints));
			}

			m_aTimers.push(VSLU.CreateTimer(0.4, VSLU.RegisterOnTickFunction, m_sPushFunction));
			m_aTimers.push(VSLU.CreateTimer(0.9, function(sPushFunction){
				if (VSLU.IsOnTickFunctionRegistered(sPushFunction))
					VSLU.RemoveOnTickFunction(sPushFunction);
			}, m_sPushFunction));

			m_aTimers.push(VSLU.CreateTimer(6.0, function(){
				if (__fun_shit_last_survivors_reaction__ + 10.0 < Time())
				{
					local hPlayer;
					local aL4D1Survivors = [];
					local aL4D2Survivors = [];
					local aL4D1SurvivorsNames = ["louis", "zoey", "bill", "francis"];
					local aL4D2SurvivorsNames = ["coach", "nick", "ellis", "rochelle"];

					for (local i = 0; i < aL4D1SurvivorsNames.len(); i++)
					{
						if ( hPlayer = Entities.FindByName(null, "!" + aL4D1SurvivorsNames[i]) )
						{
							if (hPlayer.IsSurvivor() && VSLU.IsEntityAlive(hPlayer) && !hPlayer.IsIncapacitated())
							{
								aL4D1Survivors.push(hPlayer);
							}
						}
					}

					for (local j = 0; j < aL4D2SurvivorsNames.len(); j++)
					{
						if ( hPlayer = Entities.FindByName(null, "!" + aL4D2SurvivorsNames[j]) )
						{
							if (hPlayer.IsSurvivor() && VSLU.IsEntityAlive(hPlayer) && !hPlayer.IsIncapacitated())
							{
								if (GetCharacterDisplayName(hPlayer).tolower() == aL4D2SurvivorsNames[j])
								{
									aL4D2Survivors.push(hPlayer);
								}
							}
						}
					}

					if (aL4D1Survivors.len() > 0)
					{
						local hEntity = SpawnEntityFromTable("func_orator", {
							disableshadows = 1
							spawnflags = 1
							model = g_GasStationExplosion.sGasStationExpModel[13]
						});
						NetProps.SetPropInt(hEntity, "m_fEffects", (1 << 5));
						VSLU.AcceptEntityInput(hEntity, "SpeakResponseConcept", "PlaneCrash");
						VSLU.AcceptEntityInput(hEntity, "Kill", "", 0.01);
					}

					if (aL4D2Survivors.len() > 0)
					{
						local idx;
						local arr = [];
						local flTime = 1.0;

						while (aL4D2Survivors.len() > 0)
						{
							idx = RandomInt(0, aL4D2Survivors.len() - 1);
							arr.push(aL4D2Survivors[idx]);
							aL4D2Survivors.remove(idx);
						}
						
						for (local k = 0; k < arr.len(); k++)
						{
							VSLU.AcceptEntityInput(arr[k], "SpeakResponseConcept", "C2M1Falling", flTime);
							flTime += 0.25;
						}
					}

					__fun_shit_last_survivors_reaction__ = Time();
				}
			}));

			m_bGasPumpLeftExploded = true;
			m_bGasPumpRightExploded = true;
			m_flExplosionTime = Time() + 9.0;

			return true;
		}
		return false;
	}

	function ExplodeGasPumpLeft()
	{
		if (!m_bGasPumpLeftExploded)
		{
			if (m_hGasPumpLeftExplosion) VSLU.AcceptEntityInput(m_hGasPumpLeftExplosion, "Explode", "", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpLeft, "Enable", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpLeft, "SetAnimation", "leftDetonator", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionShake, "StartShake", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpLeftParticle, "Start", "", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionSound, "PlaySound", "", 1.10);
			m_bGasPumpLeftExploded = true;
			StartPreExplosion();
		}
	}

	function ExplodeGasPumpRight()
	{
		if (!m_bGasPumpRightExploded)
		{
			if (m_hGasPumpRightExplosion) VSLU.AcceptEntityInput(m_hGasPumpRightExplosion, "Explode", "", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpRight, "Enable", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpRight, "SetAnimation", "rightDetonator", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionShake, "StartShake", "", 1.0);
			VSLU.AcceptEntityInput(m_hGasPumpRightParticle, "Start", "", 1.10);
			VSLU.AcceptEntityInput(m_hGasPumpExplosionSound, "PlaySound", "", 1.10);
			m_bGasPumpRightExploded = true;
			StartPreExplosion();
		}
	}

	function ClearExplosion()
	{
		m_bGasPumpLeftExploded = true;
		m_bGasPumpRightExploded = true;

		if (m_sPushFunction)
		{
			if (VSLU.IsOnTickFunctionRegistered(m_sPushFunction)) VSLU.RemoveOnTickFunction(m_sPushFunction);
			delete getroottable()[m_sPushFunction];
		}

		if (m_sHurtFunction)
		{
			if (VSLU.IsLoopFunctionRegistered(m_sHurtFunction, m_aTrianglePoints)) VSLU.RemoveLoopFunction(m_sHurtFunction, m_aTrianglePoints);
			delete getroottable()[m_sHurtFunction];
		}

		if (m_hGasPumpLeftBreakable && m_hGasPumpLeftBreakable.IsValid()) m_hGasPumpLeftBreakable.Kill();
		if (m_hGasPumpRightBreakable && m_hGasPumpRightBreakable.IsValid()) m_hGasPumpRightBreakable.Kill();

		foreach (ent in m_aSoundEntities)
		{
			if (ent && ent.IsValid())
			{
				VSLU.AcceptEntityInput(ent, "Volume", "0");
				VSLU.AcceptEntityInput(ent, "Kill", "", 0.01);
			}
		}

		foreach (ent in m_aEntities)
		{
			if (ent && ent.IsValid())
			{
				ent.Kill();
			}
		}

		for (local i = 0; i < m_aTimers.len(); i++)
		{
			foreach (idx, timer in VSLU.aTimers)
			{
				if (m_aTimers[i].GetIdentifier() == timer.GetIdentifier())
				{
					VSLU.aTimers.remove(idx);
					break;
				}
			}
		}
	}

	function IsAllEntitiesValid()
	{
		foreach (ent in m_aEntities)
		{
			if (!ent || !ent.IsValid())
				return false;
		}
		return true;
	}

	m_flExplosionTime = null;
	m_sPushFunction = null;
	m_sHurtFunction = null;
	m_bExplosionStarted = null;
	m_hGasStationExplosionParticle = null;
	m_hGasStationExplosionShake = null;
	m_hGasPumpExplosionShake = null;
	m_bGasPumpLeftExploded = null;
	m_bGasPumpRightExploded = null;
	m_hGasPumpLeftBreakable = null;
	m_hGasPumpRightBreakable = null;
	m_hGasPumpLeftParticle = null;
	m_hGasPumpRightParticle = null;
	m_hGasPumpLeftExplosion = null;
	m_hGasPumpRightExplosion = null;
	m_hGasPumpLeft = null;
	m_hGasPumpRight = null;
	m_hBurningPipeLeft = null;
	m_hBurningPipeRight = null;
	m_hGasPumpExplosionSound = null;
	m_hGasExplosionImpactSound = null;
	m_hGasExplosionSound = null;
	m_hGasStationBrush = null;
	m_hGasStationPit = null;
	m_aTrianglePoints = null;
	m_aGasStation = null;
	m_hDebrisDoor = null;
	m_aTimers = null;
	m_aEntities = null;
	m_aSoundEntities = null;
}

g_PluginGasStationExplosion <- CPluginGasStationExplosion();

__gse_fun_shit_mode__ <- true;
__fun_shit_last_survivors_reaction__ <- 0.0;

g_GasStationExplosion <-
{
	aGasStations = []
	aInvalidEntitiesListener = []

	tExpDir =
	{
		Forward = 0
		Behind = 1
		Left = 2
		Right = 3
	}

	sGasStationExpModel =
	[
		"models/hybridphysx/gasstationpart_1.mdl"
		"models/hybridphysx/gasstationpart_2.mdl"
		"models/hybridphysx/gasstationpart_3.mdl"
		"models/hybridphysx/gasstationpart_4.mdl"
		"models/hybridphysx/gasstationpart_5.mdl"
		"models/hybridphysx/gasstationpart_6.mdl"
		"models/hybridphysx/gasstationpart_7.mdl"
		"models/hybridphysx/gasstationpart_8.mdl"
		"models/hybridphysx/gasstationpart_9.mdl"
		"models/hybridphysx/gasstation_endstate_2.mdl"
		"models/hybridphysx/gaspumpdestruction.mdl"
		"models/hybridphysx/gasstationpit.mdl"
		"models/props_equipment/gas_pump_nodebris.mdl"
		"models/props_interiors/airportdeparturerampcontrol01.mdl"
	]

	tGasStationExpParams =
	{
		c1m2_streets =
		{
			origin = Vector(-6438.181, -3003.592, 390.657)
			angles = QAngle(0, -90, 0)
		}

		c6m3_port =
		{
			origin = Vector(638.044, 1093.173, 158.031)
			angles = QAngle(0, 90, 0)
		}

		c7m1_docks =
		{
			origin = Vector(10494.208, 2892.211, 128.031)
			angles = QAngle(0, 180, 0)
		}

		c7m3_port =
		{
			origin = Vector(638.044, 1093.173, 158.031)
			angles = QAngle(0, 90, 0)
		}
	}

	Settings =
	{
		Allow = true
		Chance = 90
		ClearTime = 0.0
		AllowDamage = true
		Limit = 10
		HordeDelay = 2.0
	}

    ParseConfigFile = function()
    {
        this = ::g_GasStationExplosion;

		local tData;

		local function SerializeSettings()
		{
			local sData = "{";

			foreach (key, val in Settings)
			{
				switch (typeof val)
				{
				case "string":
					sData = format("%s\n\t%s = \"%s\"", sData, key, val);
					break;
				
				case "float":
					sData = format("%s\n\t%s = %f", sData, key, val);
					break;
				
				case "integer":
				case "bool":
					sData = sData + "\n\t" + key + " = " + val;
					break;
				}
			}

			sData = sData + "\n}";
			StringToFile("gas_station_explosion/settings.nut", sData);
		}

		if (tData = FileToString("gas_station_explosion/settings.nut"))
		{
			try
            {
				tData = compilestring("return " + tData)();

				foreach (key, val in Settings)
				{
					if (tData.rawin(key))
					{
						if (key == "Chance")
							Settings[key] = VSLU.Math.Clamp(tData[key], 0, 100);
						else if (key == "Limit" && tData[key] < 1)
							Settings[key] = 1;
						else
							Settings[key] = tData[key];
					}
				}
			}
			catch (exception)
            {
				SerializeSettings();

				error("[Gas Station Explosion] " + exception + "\n");
				error("[Gas Station Explosion] Failed to parse the config file\n");
			}
		}
		else
		{
			SerializeSettings();

			error("[Gas Station Explosion] Missing the config file, created a new one\n");
		}
    }

	Precache = function()
	{
		this = ::g_GasStationExplosion;

		PrecacheEntityFromTable( { classname = "ambient_generic", message = "Objects.gas_station_explosion" } );
		PrecacheEntityFromTable( { classname = "ambient_generic", message = "SmashCave.WoodRockCollapse" } );
		PrecacheEntityFromTable( { classname = "ambient_generic", message = "explode_3" } );
		PrecacheEntityFromTable( { classname = "ambient_generic", message = "fire_large" } );
		PrecacheEntityFromTable( { classname = "env_explosion", fireballsprite = "sprites/zerogxplode.spr" } );

		for (local i = 0; i < g_GasStationExplosion.sGasStationExpModel.len(); ++i)
		{
			PrecacheEntityFromTable( { classname = "prop_dynamic", model = g_GasStationExplosion.sGasStationExpModel[i] } );
		}
	}

	OnGasPumpKill = function(tParams)
	{
		if (tParams["pump"] == "left")
			tParams["__instance"].ExplodeGasPumpLeft();
		else
			tParams["__instance"].ExplodeGasPumpRight();
	}

	Initialize = function(hPlayer, iExplosionType)
	{
		if (VSLU.Player.IsHost(hPlayer) && g_GasStationExplosion.Settings.Allow)
		{
			local vecOrigin;
			local eAngles = hPlayer.EyeAngles();

			if (__gse_fun_shit_mode__)
			{
				vecOrigin = hPlayer.GetOrigin();
			}
			else
			{
				local tTraceResult = {};
				VSLU.Player.TraceLine(hPlayer, tTraceResult);

				vecOrigin = tTraceResult["pos"];
			}

			if (iExplosionType == g_GasStationExplosion.tExpDir.Behind)
				eAngles += QAngle(0, 180, 0);
			else if (iExplosionType == g_GasStationExplosion.tExpDir.Left)
				eAngles += QAngle(0, 90, 0);
			else if (iExplosionType == g_GasStationExplosion.tExpDir.Right)
				eAngles -= QAngle(0, 90, 0);

			g_GasStationExplosion.SpawnGasStation(vecOrigin, eAngles);
		}
	}

	GSE_Think = function()
	{
		this = ::g_GasStationExplosion;

		if (aGasStations.len() > 0 && g_GasStationExplosion.Settings.ClearTime > 0)
		{
			for (local i = 0; i < aGasStations.len(); ++i)
			{
				if (aGasStations[i].m_flExplosionTime != null)
				{
					if (aGasStations[i].m_flExplosionTime + g_GasStationExplosion.Settings.ClearTime < Time())
					{
						aGasStations[i].ClearExplosion();
						aGasStations.remove(i);
						i--;
					}
				}
			}
		}
	}

	InvalidEntitiesListener_Think = function()
	{
		local tbl;

		for (local i = 0; i < g_GasStationExplosion.aInvalidEntitiesListener.len(); ++i)
		{
			tbl = g_GasStationExplosion.aInvalidEntitiesListener[i];

			if (!tbl.ent.IsValid())
			{
				tbl.func(tbl.params);
				g_GasStationExplosion.aInvalidEntitiesListener.remove(i);
				i--;
			}
		}
	}

	SpawnGasStation = function(vecOrigin, eAngles)
	{
		this = ::g_GasStationExplosion;

		if (aGasStations.len() > 0 && aGasStations.len() + 1 > g_GasStationExplosion.Settings.Limit)
		{
			aGasStations[0].ClearExplosion();
			aGasStations.remove(0);
		}
		aGasStations.push(CGasStationExplosion(vecOrigin, eAngles, g_GasStationExplosion.Settings.AllowDamage));
	}

	Clear = function(hPlayer, sArgs)
	{
		this = ::g_GasStationExplosion;

		if (VSLU.Player.IsHost(hPlayer))
		{
			for (local i = 0; i < aGasStations.len(); i++)
			{
				aGasStations[i].ClearExplosion();
				aGasStations.remove(i);
				i--;
			}
		}
	}

	SwitchMode = function(hPlayer, sArgs)
	{
		if (VSLU.Player.IsHost(hPlayer))
		{
			VSLU.SendMessage(hPlayer, "[Gas Station Explosion] Explosion mode: " + (__gse_fun_shit_mode__ ? "camera direction" : "near the player"));
			__gse_fun_shit_mode__ = !__gse_fun_shit_mode__;
		}
	}

	Forward = function(hPlayer, sArgs) { g_GasStationExplosion.Initialize(hPlayer, g_GasStationExplosion.tExpDir.Forward); }

	Behind = function(hPlayer, sArgs) { g_GasStationExplosion.Initialize(hPlayer, g_GasStationExplosion.tExpDir.Behind); }

	Left = function(hPlayer, sArgs) { g_GasStationExplosion.Initialize(hPlayer, g_GasStationExplosion.tExpDir.Left); }

	Right = function(hPlayer, sArgs) { g_GasStationExplosion.Initialize(hPlayer, g_GasStationExplosion.tExpDir.Right); }
};

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginGasStationExplosion);