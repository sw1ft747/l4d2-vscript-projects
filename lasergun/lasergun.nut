// Laser Gun

class CPluginLaserGun extends VSLU.IScriptPlugin
{
	function Load()
	{
		g_LaserGun.Precache();
		g_LaserGun.ParseConfigFile();
		g_LaserGun.RandomizeBeamColors();

		VSLU.RegisterOnTickFunction("g_LaserGun.LaserGun_Think");

		VSLU.HookEvent("player_connect", g_LaserGun.OnPlayerConnect, g_LaserGun);

		VSLU.RegisterChatCommand("!laser_color", g_LaserGun.ChangeLaserBeamColor);

		printl("[Laser Gun]\nAuthor: Sw1ft\nVersion: 2.1.6");
	}

	function Unload()
	{
		VSLU.RemoveOnTickFunction("g_LaserGun.LaserGun_Think");

		VSLU.UnhookEvent("player_connect", g_LaserGun.OnPlayerConnect, g_LaserGun);

		VSLU.RemoveChatCommand("!laser_color");
	}

	function OnRoundStartPost()
	{
	}

	function OnRoundEnd()
	{
	}

	function GetClassName() { return "CPluginLaserGun"; }

	function GetScriptPluginName() { return "Laser Gun"; }

	function GetInterfaceVersion() { return 1; }
}

class CLaserGunBeam
{
	constructor(hEntity, vecEndPos, flLifeTime)
	{
		m_hEntity = hEntity;
		m_vecEndPos = vecEndPos;

		if (flLifeTime != null)
			m_flLifeTime = Time() + flLifeTime;
		else
			m_bDestroy = false;
	}

	function IsBeamEntityValid() { return m_hEntity.IsValid(); }

	function RemoveBeam() { if (m_hEntity.IsValid()) m_hEntity.Kill(); }

	function SetEndPosition() { NetProps.SetPropVector(m_hEntity, "m_vecEndPos", m_vecEndPos); }

	m_hEntity = null;
	m_vecEndPos = null;
	m_bDestroy = true;
	m_flLifeTime = 0.0;
}

g_PluginLaserGun <- CPluginLaserGun();

if (!("g_sLGLaserBeamColor" in this)) g_sLGLaserBeamColor <- array(MAXCLIENTS + 1, "0 127 255");

g_LaserGun <-
{
	aLaserBeams = []
	aEntsAABB = array(MAXENTS + 1, false)

	Settings =
	{
		BeamExtent = 10.0
		MaxReflects = 8
		DamageToInfected = 200.0
		DamageToSurvivors = 25.0
		GlowImpacts = true
		Debug = false
		DebugDrawDuration = 10
	}

	aInteractClasses =
	[
		"player"
		"infected"
		"witch"
		"weapon_gascan"
		"prop_physics"
		"prop_fuel_barrel"
		"prop_door_rotating"
		"func_breakable"	
	]

	aInteractModelList =
	[
		"models/props_junk/gascan001a.mdl"
		"models/props_equipment/oxygentank01.mdl"
		"models/props_junk/propanecanister001a.mdl"
		"models/props_junk/wood_pallet001a.mdl"
	]

	aPassThroughClasses =
	[
		"player"
		"infected"
		"witch"
		"prop_fuel_barrel"
		"prop_door_rotating"
		"func_breakable"
	]

    ParseConfigFile = function()
    {
        this = ::g_LaserGun;

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
			StringToFile("lasergun/settings.nut", sData);
		}

		if (tData = FileToString("lasergun/settings.nut"))
		{
			try
            {
				tData = compilestring("return " + tData)();

				foreach (key, val in Settings)
				{
					if (tData.rawin(key))
					{
						Settings[key] = tData[key];
					}
				}
			}
			catch (error)
            {
				SerializeSettings();
			}
		}
		else
		{
			SerializeSettings();
		}

		if (Settings["BeamExtent"] < 1.0)
			Settings["BeamExtent"] = 1.0;
    }

	LaserGunAttack = function(hAttacker, vecStart, vecAngles)
	{
		this = ::g_LaserGun;

		local aHitEnts = null;

		if ( Settings.MaxReflects <= 0 )
			return;

		if ( Settings.Debug )
		{
			DebugDrawClear();
			aHitEnts = array(MAXENTS + 1, 0);
		}

		local hEntity, hPrevEntity;

		local iReflects = 0;
		local aPotentialTargets = [];
		local aTracedEntities = [];

		// Collect entities
		while ( hEntity = Entities.Next(hEntity) )
		{
			local sClassname = hEntity.GetClassname();

			if ( aInteractClasses.find(sClassname) != null )
			{
				if ( sClassname == "player" )
				{
					if ( VSLU.IsEntityAlive(hEntity) && NetProps.GetPropInt(hEntity, "m_iObserverMode") == 0 && !NetProps.GetPropInt(hEntity, "m_isGhost") )
					{
						aEntsAABB[hEntity.GetEntityIndex()] = true;
						aPotentialTargets.push(hEntity);
					}
				}
				else
				{
					if ( sClassname == "infected" || sClassname == "witch" )
					{
						if ( !VSLU.IsEntityAlive(hEntity) )
							continue;

						aEntsAABB[hEntity.GetEntityIndex()] = true;
					}
					else
					{
						aEntsAABB[hEntity.GetEntityIndex()] = false;
					}

					aPotentialTargets.push(hEntity);
				}
			}
		}

		while ( iReflects < Settings.MaxReflects )
		{
			aTracedEntities.clear();

			local tTraceResult = {};
			local vecDir = vecAngles.Forward();

			VSLU.TraceLine(tTraceResult, vecStart, VSLU.Trace_MakeEndPoint(vecStart, vecDir), TRACE_MASK_SHOT_IGNORE_WINDOW, hAttacker, true, vecAngles);

			local vecHitPoint = tTraceResult["pos"];

			// Didn't hit the world
			if ( hEntity = tTraceResult["enthit"] )
			{
				// Check if beam can pass through that entity
				if ( aPassThroughClasses.find(hEntity.GetClassname()) != null || aInteractModelList.find(NetProps.GetPropString(hEntity, "m_ModelName")) != null )
				{
					aTracedEntities.push(hEntity);

					// Start tracing until we hit the world or entity that can be ignored
					while (hEntity)
					{
						hPrevEntity = hEntity;
						VSLU.TraceLine(tTraceResult, vecHitPoint, VSLU.Trace_MakeEndPoint(vecHitPoint, vecDir), TRACE_MASK_SHOT_IGNORE_WINDOW, hEntity, true, vecAngles);

						vecHitPoint = tTraceResult["pos"];

						// Traced against previous the entity or trace stopped in solid, break the cycle to prevent infinite recursion
						if ( hEntity == tTraceResult["enthit"] || tTraceResult["startsolid"] )
							break;
						
						hEntity = tTraceResult["enthit"];

						if (hEntity)
						{
							// Entity that can be ignored, can stop tracing for now
							if ( aPassThroughClasses.find(hEntity.GetClassname()) == null && aInteractModelList.find(NetProps.GetPropString(hEntity, "m_ModelName")) == null )
								break;

							// Continue to trace through entities
							aTracedEntities.push(hEntity);
						}
						else // Did hit the world
						{
							break;
						}
					}
				}
				else if ( tTraceResult["enthit"] ) // Entity that can be ignored
				{
					aTracedEntities.push( tTraceResult["enthit"] );
				}
			}

			// Reflect direction of beam off the surface
			local vecReflectedRay = VSLU.Math.VectorReflect(vecDir, tTraceResult["planenormal"]);

			// Impact effect
			local hParticle = SpawnEntityFromTable("info_particle_system", {
				origin = vecHitPoint
				start_active = 1
				effect_name = "sparks_generic_random_core"
			}); hParticle.SetAngles( VSLU.Math.VectorToQAngle(tTraceResult["planenormal"]) );

			VSLU.CreateTimer(1.0, function(hParticle){
				if ( hParticle && hParticle.IsValid() )
					hParticle.Kill();
			}, hParticle);

			// Create the beam
			aLaserBeams.push(CLaserGunBeam(SpawnEntityFromTable("env_laser", {
				origin = vecStart
				rendercolor = g_sLGLaserBeamColor[hAttacker.GetEntityIndex()]
				texture = "sprites/laserbeam.spr"
				renderamt = "255"
				TextureScroll = 100
				damage = 0
				width = 2
			}), vecHitPoint, 0.15));

			// Prepare OBB beam
			local flBeamExtent = Settings.BeamExtent;
			local flBeamLength = (vecHitPoint - vecStart).Length();

			local vecBeamMins = Vector(0, -flBeamExtent / 2, -flBeamExtent / 2);
			local vecBeamMaxs = Vector(flBeamLength, flBeamExtent / 2, flBeamExtent / 2);

			// Draw beam direction, its reflected direction, surface normal and OBB beam
			if ( Settings.Debug )
			{
				VSLU.Debug.Mark(vecStart, Settings.DebugDrawDuration, Vector(-1, -1, -1), Vector(1, 1, 1), 232, 232, 232);

				VSLU.Debug.Line(vecHitPoint, vecHitPoint + vecReflectedRay * 32, Settings.DebugDrawDuration, 232, 0, 0);
				VSLU.Debug.Line(vecHitPoint, vecHitPoint + vecDir * -32, Settings.DebugDrawDuration, 0, 232, 0);
				
				VSLU.Debug.Line(vecHitPoint, vecHitPoint + tTraceResult["planenormal"] * 24, Settings.DebugDrawDuration, 232, 232, 232);

				DrawOBB(vecStart, vecAngles, vecBeamMins, vecBeamMaxs, 232, 232, 0);
			}

			// Iterate through entities to deal the damage
			local idx = 0;
			while ( idx < aPotentialTargets.len() )
			{
				hEntity = aPotentialTargets[idx++];

				if ( hEntity == hAttacker && iReflects == 0 )
					continue;

				if ( aTracedEntities.find(hEntity) != null )
				{
					if ( Settings.Debug )
						aHitEnts[hEntity.GetEntityIndex()] = 2;

					hEntity.TakeDamage(hEntity.IsPlayer() ? (hEntity.IsSurvivor() ? Settings.DamageToSurvivors : Settings.DamageToInfected) : Settings.DamageToInfected, DMG_BURN, hAttacker);
					hEntity.ApplyAbsVelocityImpulse(vecDir * 50);

					continue;
				}

				local vecMins = NetProps.GetPropVector(hEntity, "m_Collision.m_vecMins");
				local vecMaxs = NetProps.GetPropVector(hEntity, "m_Collision.m_vecMaxs");

				if ( hEntity.IsPlayer() && hEntity.IsSurvivor() && hEntity.IsIncapacitated() && !hEntity.IsHangingFromLedge() )
					vecMaxs.z = 36.0;

				local vecOrigin = hEntity.GetOrigin();
				local vecMidOrigin = vecOrigin + (vecMins + vecMaxs) * 0.5;

				// Is entity's origin between two plates of cylinder
				if ( (vecHitPoint - vecStart).Dot(vecMidOrigin - vecStart) > 0 && (vecStart - (vecHitPoint + vecDir * 200)).Dot(vecMidOrigin - (vecHitPoint + vecDir * 200)) > 0 )
				{
					// Is entity's origin within the radius of cylinder
					if ( (vecMidOrigin - vecStart).Cross(vecDir).LengthSqr() < 62500 ) // sqrt(62500) = 250
					{
						// Check OBB-OBB / OBB-AABB intersection
						if ( aEntsAABB[hEntity.GetEntityIndex()] )
						{
							if ( !Settings.Debug )
							{
								if ( !VSLU.Collision.IsOBBIntersectingAABB(vecStart, vecAngles, vecBeamMins, vecBeamMaxs, vecOrigin, vecMins, vecMaxs) )
									continue;
							}
							else
							{
								if ( !VSLU.Collision.IsOBBIntersectingAABB(vecStart, vecAngles, vecBeamMins, vecBeamMaxs, vecOrigin, vecMins, vecMaxs) )
								{
									if (aHitEnts[hEntity.GetEntityIndex()] != 2)
										aHitEnts[hEntity.GetEntityIndex()] = 1;

									continue;
								}
								else
								{
									aHitEnts[hEntity.GetEntityIndex()] = 2;
								}
							}
						}
						else
						{
							if ( !Settings.Debug )
							{
								if ( !VSLU.Collision.IsOBBIntersectingOBB(vecStart, vecAngles, vecBeamMins, vecBeamMaxs, vecOrigin, hEntity.GetAngles(), vecMins, vecMaxs) )
									continue;
							}
							else
							{
								if ( !VSLU.Collision.IsOBBIntersectingOBB(vecStart, vecAngles, vecBeamMins, vecBeamMaxs, vecOrigin, hEntity.GetAngles(), vecMins, vecMaxs) )
								{
									if (aHitEnts[hEntity.GetEntityIndex()] != 2)
										aHitEnts[hEntity.GetEntityIndex()] = 1;

									continue;
								}
								else
								{
									aHitEnts[hEntity.GetEntityIndex()] = 2;
								}
							}
						}
						
						hEntity.TakeDamage(hEntity.IsPlayer() ? (hEntity.IsSurvivor() ? Settings.DamageToSurvivors : Settings.DamageToInfected) : Settings.DamageToInfected, DMG_BURN, hAttacker);
					}
				}
			}

			// Stop if distance to the destination point is too far and the beam was reflected at least once
			if ( iReflects > 0 && (vecHitPoint - vecStart).LengthSqr() > 1440000 )
				break;

			// Too many dyn. lights can crash the game
			if ( Settings.GlowImpacts && iReflects <= 10 )
			{
				local hLight;

				if ( iReflects + 1 == Settings.MaxReflects )
				{
					hLight = SpawnEntityFromTable("light_dynamic", {
						origin = vecHitPoint
						_light = g_sLGLaserBeamColor[hAttacker.GetEntityIndex()]
						spotlight_radius = 128
						distance = 150.0
						brightness = 1
					});

					VSLU.CreateTimer(0.15, function(hLight){
						if ( hLight && hLight.IsValid() )
							hLight.Kill();
					}, hLight);
				}

				hLight = SpawnEntityFromTable("light_dynamic", {
					origin = vecStart
					_light = g_sLGLaserBeamColor[hAttacker.GetEntityIndex()]
					spotlight_radius = 128
					distance = 150.0
					brightness = 1
				});

				VSLU.CreateTimer(0.15, function(hLight){
					if (hLight && hLight.IsValid())
						hLight.Kill();
				}, hLight);
			}

			// Convert direction to euler angles
			vecAngles = VSLU.Math.VectorToQAngle(vecReflectedRay);
			vecStart = vecHitPoint;

			++iReflects;
		}

		if ( Settings.Debug )
		{
			DrawHitEnts(aHitEnts, aEntsAABB);
		}
	}

	LaserGun_Think = function()
	{
		this = ::g_LaserGun;

		local hProjectile;
		while (hProjectile = Entities.FindByClassname(hProjectile, "grenade_launcher_projectile"))
		{
			local hPlayer;
			
			if (hPlayer = NetProps.GetPropEntity(hProjectile, "m_hThrower"))
			{
				try
				{
					local vecPush = hPlayer.EyeAngles().Forward();
					
					vecPush.z = 0.0;
					vecPush *= -100;

					LaserGunAttack(hPlayer, hProjectile.GetOrigin(), hPlayer.EyeAngles());
					NetProps.SetPropVector(hPlayer, "m_vecBaseVelocity", vecPush);
				}
				catch (e)
				{
					errorl("[Laser Gun] Unexpected error: " + e);
				}

				hProjectile.Kill();
			}
		}

		// Process beams
		for (local i = 0; i < aLaserBeams.len(); ++i)
		{
			local beam = aLaserBeams[i];

			if ( beam.IsBeamEntityValid() && !(beam.m_bDestroy && Time() > beam.m_flLifeTime) )
			{
				beam.SetEndPosition();
			}
			else
			{
				beam.RemoveBeam();

				aLaserBeams.remove(i);
				--i;
			}
		}
	}

	function DrawAABB(vecOrigin, vecMins, vecMaxs, r, g, b)
	{
		local aa = [1, 3, 0, 2];
		local aVertices = VSLU.Math.PointsFromBox(vecMins, vecMaxs);

		for (local i = 0; i < 8; ++i)
		{
			aVertices[i] += vecOrigin;
		}

		for (local i = 0; i < 4; ++i)
		{
			VSLU.Debug.Line(aVertices[i], aVertices[aa[i]], Settings.DebugDrawDuration, r, g, b);
			VSLU.Debug.Line(aVertices[i + 4], aVertices[aa[i] + 4], Settings.DebugDrawDuration, r, g, b);
			VSLU.Debug.Line(aVertices[i], aVertices[i + 4], Settings.DebugDrawDuration, r, g, b);
		}
	}

	function DrawOBB(vecOrigin, vecAngles, vecMins, vecMaxs, r, g, b)
	{
		local aa = [1, 3, 0, 2];
		local aVertices = VSLU.Math.PointsFromBox(vecMins, vecMaxs);

		local boxToWorld = matrix3x4(vecOrigin, vecAngles);

		for (local i = 0; i < 8; ++i)
		{
			aVertices[i] = boxToWorld.VectorTransform( aVertices[i] );
		}

		for (local i = 0; i < 4; ++i)
		{
			VSLU.Debug.Line(aVertices[i], aVertices[aa[i]], Settings.DebugDrawDuration, r, g, b);
			VSLU.Debug.Line(aVertices[i + 4], aVertices[aa[i] + 4], Settings.DebugDrawDuration, r, g, b);
			VSLU.Debug.Line(aVertices[i], aVertices[i + 4], Settings.DebugDrawDuration, r, g, b);
		}
	}

	function DrawHitEnts(aHitEnts, aEntsAABB)
	{
		this = ::g_LaserGun;

		local idx = 0;
		while ( idx < aHitEnts.len() )
		{
			if ( aHitEnts[idx] > 0 )
			{
				local hEntity = Ent(idx);

				if ( aHitEnts[idx] == 1 )
				{
					if ( aEntsAABB[idx] )
					{
						DrawAABB(hEntity.GetOrigin(), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMins"), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMaxs"), 232, 0, 0);
					}
					else
					{
						DrawOBB(hEntity.GetOrigin(), hEntity.GetAngles(), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMins"), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMaxs"), 232, 0, 0);
					}
				}
				else
				{
					if ( aEntsAABB[idx] )
					{
						DrawAABB(hEntity.GetOrigin(), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMins"), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMaxs"), 0, 232, 0);
					}
					else
					{
						DrawOBB(hEntity.GetOrigin(), hEntity.GetAngles(), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMins"), NetProps.GetPropVector(hEntity, "m_Collision.m_vecMaxs"), 0, 232, 0);
					}
				}
			}

			++idx;
		}
	}

	ChangeLaserBeamColor = function(hPlayer, sArgs)
	{
		local sColor = sArgs;

		if (sColor == null)
		{
			VSLU.SendMessage(hPlayer, "Example: !laser_color <color_name> OR !laser_color <r> <g> <b>");
		}
		else if (sColor.len() == 1)
		{
			switch (sColor[0])
			{
			case "white":		sColor = "255 255 255";		break;
			case "red":			sColor = "255 0 0";			break;
			case "orange":		sColor = "255 155 0";		break;
			case "yellow":		sColor = "255 255 0";		break;
			case "green":		sColor = "0 255 0";			break;
			case "aquamarine":	sColor = "0 255 255";		break;
			case "azure":		sColor = "0 127 255";		break;
			case "blue":		sColor = "0 0 255";			break;
			case "purple":		sColor = "255 0 255";		break;
			default:			return;
			}

			if (sColor != g_sLGLaserBeamColor[hPlayer.GetEntityIndex()])
			{
				g_sLGLaserBeamColor[hPlayer.GetEntityIndex()] = sColor;
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
		}
		else if (sColor.len() >= 3)
		{
			local r = str_to_int( sColor[0] );
			local g = str_to_int( sColor[1] );
			local b = str_to_int( sColor[2] );

			if (r + g + b < 40)
			{
				VSLU.SendMessage(hPlayer, "[Laser Gun] The color is too dull, try another");
			}
			else
			{
				g_sLGLaserBeamColor[hPlayer.GetEntityIndex()] = format("%d %d %d", r, g, b);
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
		}
	}

	Precache = function()
	{
		PrecacheEntityFromTable( { classname = "env_laser", texture = "sprites/laserbeam.spr" } );
		PrecacheEntityFromTable( { classname = "info_particle_system", effect_name = "sparks_generic_random_core" } );
	}

	RandomizeBeamColors = function()
	{
		if ( !("__vslu_lasergun_first_load" in getroottable()) )
		{
			local aColors =
			[
				"255 255 255",
				"255 0 0",
				"255 155 0",
				"255 255 0",
				"0 255 0",
				"0 255 255",
				"0 127 255",
				"0 0 255",
				"255 0 255"
			];

			for (local i = 1; i <= MAXCLIENTS; ++i)
			{
				g_sLGLaserBeamColor[i] = aColors[ RandomInt(0, aColors.len() - 1) ];
			}

			::__vslu_lasergun_first_load <- true;
		}
	}

	OnPlayerConnect = function(tParams)
	{
		local aColors =
		[
			"255 255 255",
			"255 0 0",
			"255 155 0",
			"255 255 0",
			"0 255 0",
			"0 255 255",
			"0 127 255",
			"0 0 255",
			"255 0 255"
		];

		g_sLGLaserBeamColor[tParams["index"] + 1] = aColors[ RandomInt(0, aColors.len() - 1) ];
	}
};

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginLaserGun);