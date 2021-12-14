// Laser Gun

class CLaserGun extends IScriptPlugin
{
	function Load()
	{
		::g_ConVar_LaserGunMaxReflects <- CreateConVar("laser_max_reflects", 10);

		RegisterOnTickFunction("g_LaserGun.LaserGun_Think");
		RegisterOnTickFunction("g_LaserGun.LaserBeam_Think");

		HookEvent("player_disconnect", g_LaserGun.OnPlayerDisconnect, g_LaserGun);

		g_ConVar_LaserGunMaxReflects.AddChangeHook(g_LaserGun.OnConVarChange);

		printl("[Laser Gun]\nAuthor: Sw1ft\nVersion: 2.1.5");
	}

	function Unload()
	{
		RemoveConVar(g_ConVar_LaserGunMaxReflects);

		RemoveOnTickFunction("g_LaserGun.LaserGun_Think");
		RemoveOnTickFunction("g_LaserGun.LaserBeam_Think");

		UnhookEvent("player_disconnect", g_LaserGun.OnPlayerDisconnect, g_LaserGun);

		RemoveChatCommand("!laser_color");
	}

	function OnRoundStartPost()
	{
	}

	function OnRoundEnd()
	{
	}

	function OnExtendClassMethods()
	{
		RegisterChatCommand("!laser_color", g_LaserGun.ChangeLaserBeamColor, true, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CLaserGun";
	static m_sScriptPluginName = "Laser Gun";
}

class CLaserBeam
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

	function IsLifeTimeOut() { return m_bDestroy && Time() > m_flLifeTime; }

	function DestroyBeam() { if (m_hEntity.IsValid()) m_hEntity.Kill(); }

	function SetEndPosition() { NetProps.SetPropVector(m_hEntity, "m_vecEndPos", m_vecEndPos); }

	m_hEntity = null;
	m_vecEndPos = null;
	m_bDestroy = true;
	m_flLifeTime = 0.0;
}

g_PluginLaserGun <- CLaserGun();

if (!("g_sLGLaserBeamColor" in this)) g_sLGLaserBeamColor <- array(MAXCLIENTS + 1, "0 127 255");

::trace_util_BeamTraceMask <- eTrace.Mask_Shot & ~0x02; // CONTENTS_WINDOW

g_LaserGun <-
{
	aLaserBeams = []

	sExclusionClasses =
	[
		"player"
		"infected"
		"witch"
		"prop_fuel_barrel"
		"prop_door_rotating"
		"func_breakable"
	]

	aExclusionModelList =
	[
		"models/props_junk/gascan001a.mdl"
		"models/props_equipment/oxygentank01.mdl"
		"models/props_junk/propanecanister001a.mdl"
		"models/props_junk/wood_pallet001a.mdl"
	]

	LaserGun = function(hPlayer, eAngles, vecStart)
	{
		local hEntity, length;
		local iReflects = 0;
		local aEntities = [];

		while (hEntity = Entities.Next(hEntity))
		{
			switch (hEntity.GetClassname())
			{
			case "witch":
			case "infected":
			case "prop_door_rotating":
			case "prop_fuel_barrel":
			case "func_breakable":
				aEntities.push(hEntity);
				break;

			case "player":
				if (hEntity.IsAlive() && NetProps.GetPropInt(hEntity, "m_iObserverMode") == 0 && !NetProps.GetPropInt(hEntity, "m_isGhost")) aEntities.push(hEntity);
				break;
				
			case "prop_physics":
				if (g_LaserGun.aExclusionModelList.find(NetProps.GetPropString(hEntity, "m_ModelName")) != null) aEntities.push(hEntity);
				break;
			}
		}

		length = aEntities.len();

		while (iReflects < GetConVarInt(g_ConVar_LaserGunMaxReflects))
		{
			local aHitEntities = [];
			local hEntityNew, vecStartNew;
			local vecRayDir = eAngles.Forward();
			local vecDropPoint = DoTraceLine(vecStart, vecRayDir, eTrace.Type_Pos, eTrace.Distance, trace_util_BeamTraceMask, hPlayer);

			if (hEntity = DoTraceLine(vecStart, vecRayDir, eTrace.Type_Hit, eTrace.Distance, trace_util_BeamTraceMask, hPlayer))
			{
				// did we hit entity that the beam must pass through?
				if (g_LaserGun.sExclusionClasses.find(hEntity.GetClassname()) != null || g_LaserGun.aExclusionModelList.find(NetProps.GetPropString(hEntity, "m_ModelName")) != null)
				{
					aHitEntities.push(hEntity);
					while (hEntity)
					{
						hEntityNew = hEntity;
						vecStartNew = vecDropPoint;
						vecDropPoint = DoTraceLine(vecDropPoint, vecRayDir, eTrace.Type_Pos, eTrace.Distance, trace_util_BeamTraceMask, hEntity);
						hEntity = DoTraceLine(vecDropPoint, vecRayDir, eTrace.Type_Hit, eTrace.Distance, trace_util_BeamTraceMask, hEntity);
						if (hEntity)
						{
							if (g_LaserGun.sExclusionClasses.find(hEntity.GetClassname()) == null && g_LaserGun.aExclusionModelList.find(NetProps.GetPropString(hEntity, "m_ModelName")) == null)
							{
								break;
							}
							aHitEntities.push(hEntity);
						}
					}
				}
			}

			// trace additional points for triangle
			local vecPointA = DoTraceLine(vecStartNew != null ? vecStartNew : vecStart, (eAngles - QAngle(0, 0.01, 0)).Forward(),
										eTrace.Type_Pos, eTrace.Distance, trace_util_BeamTraceMask,  hEntityNew != null ? hEntityNew : hPlayer);

			local vecPointB = DoTraceLine(vecStartNew != null ? vecStartNew : vecStart, (eAngles - QAngle(0.01, 0, 0)).Forward(),
										eTrace.Type_Pos, eTrace.Distance,  trace_util_BeamTraceMask, hEntityNew != null ? hEntityNew : hPlayer);

			local vecNormal = ((vecPointA - vecDropPoint).Cross(vecPointB - vecDropPoint)).Normalize(); // get normal of wall (or something else) using cross product
			local vecDir = VMath.Reflect(vecRayDir, vecNormal); // get new direction of the reflected ray

			// ricochet/hit effect
			local hParticle = SpawnEntityFromTable("info_particle_system", {
				origin = vecDropPoint
				start_active = 1
				effect_name = "sparks_generic_random_core"
			});
			hParticle.SetAngles(VectorToQAngle(vecNormal));

			CreateTimer(1.0, function(hParticle){
				if (hParticle.IsValid()) hParticle.Kill();
			}, hParticle);
			
			// beam effect
			g_LaserGun.aLaserBeams.push(CLaserBeam(SpawnEntityFromTable("env_laser", {
				origin = vecStart
				rendercolor = g_sLGLaserBeamColor[hPlayer.GetEntityIndex()]
				texture = "sprites/laserbeam.spr"
				renderamt = "255"
				TextureScroll = 100
				damage = 0
				width = 2
			}), vecDropPoint, 0.15));

			local idx = 0;
			while (idx < length)
			{
				hEntity = aEntities[idx++];

				if (aHitEntities.find(hEntity) != null)
				{
					hEntity.TakeDamage(hEntity.IsPlayer() ? (hEntity.IsSurvivor() ? 90 : 500) : 500, DMG_BURN, hPlayer);
					continue;
				}

				local sClass = hEntity.GetClassname();
				local vecOrigin = hEntity.GetOrigin();

				if (sClass == "player")
				{
					vecOrigin = hEntity.GetBodyPosition();
				}
				else if (sClass == "infected" || sClass == "witch")
				{
					vecOrigin += Vector(0, 0, 47);
				}

				// is entity between two points of the beam?
				if ((vecDropPoint - vecStart).Dot(vecOrigin - vecStart) > 0 && (vecStart - vecDropPoint).Dot(vecOrigin - vecDropPoint) > 0)
				{
					// take damage if entity too close to the beam
					if ((vecOrigin - vecStart).Cross(vecRayDir).LengthSqr() < 1225)
					{
						hEntity.TakeDamage(hEntity.IsPlayer() ? (hEntity.IsSurvivor() ? 50 : 500) : 500, DMG_BURN, hPlayer);
					}
				}
			}

			// stop if distance to the destination point is too far and beam was reflected at least once
			if (iReflects > 0 && (vecDropPoint - vecStart).LengthSqr() > 1440000)
				break;

			// don't let engine explode
			if (iReflects <= 10)
			{
				local hLight = SpawnEntityFromTable("light_dynamic", {
					origin = vecStart
					_light = g_sLGLaserBeamColor[hPlayer.GetEntityIndex()]
					spotlight_radius = 128
					distance = 150.0
					brightness = 1
				});

				CreateTimer(0.15, function(hLight){
					if (hLight && hLight.IsValid())
						hLight.Kill();
				}, hLight);
			}

			eAngles = VectorToQAngle(vecDir);
			vecStart = vecDropPoint;
			iReflects++;
		}
	}

	ChangeLaserBeamColor = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local sColor = split(sValue, " ");

			if (sColor.len() == 1)
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

				if (sColor == g_sLGLaserBeamColor[hPlayer.GetEntityIndex()]) return;
				else g_sLGLaserBeamColor[hPlayer.GetEntityIndex()] = sColor;
			}
			else if (sColor.len() == 3)
			{
				local r = sColor[0];
				local g = sColor[1];
				local b = sColor[2];

				try {r = r.tointeger()}
				catch (error) {r = 0};
				try {g = g.tointeger()}
				catch (error) {g = 0};
				try {b = b.tointeger()}
				catch (error) {b = 0};

				if (r + g + b < 40) return SayMsg("[Laser Gun] The color is too dull, try another");
				else g_sLGLaserBeamColor[hPlayer.GetEntityIndex()] = format("%d %d %d", r, g, b);
			}
			else return;

			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}
	}

	LaserGun_Think = function()
	{
		local hProjectile;

		while (hProjectile = Entities.FindByClassname(hProjectile, "grenade_launcher_projectile"))
		{
			local hPlayer;
			
			if (hPlayer = NetProps.GetPropEntity(hProjectile, "m_hThrower"))
			{
				local vecPush = hPlayer.EyeAngles().Forward(); vecPush.z = 0.0; vecPush *= -200;

				g_LaserGun.LaserGun(hPlayer, hPlayer.EyeAngles(), hProjectile.GetOrigin());
				NetProps.SetPropVector(hPlayer, "m_vecBaseVelocity", vecPush);

				hProjectile.Kill();
			}
		}
	}

	LaserBeam_Think = function()
	{
		this = ::g_LaserGun;

		for (local i = 0; i < aLaserBeams.len(); i++)
		{
			if (aLaserBeams[i].IsBeamEntityValid() && !aLaserBeams[i].IsLifeTimeOut())
			{
				aLaserBeams[i].SetEndPosition();
			}
			else
			{
				aLaserBeams[i].DestroyBeam();
				aLaserBeams.remove(i);
				i--;
			}
		}
	}

	OnConVarChange = function(ConVar, sLastValue, sNewValue)
	{
		try
		{
			sNewValue = sNewValue.tointeger();
			if (sNewValue < 1)
			{
				sNewValue = 1;
				ConVar.SetValue(1);
			}
		}
		catch (error)
		{
			ConVar.SetValue(sLastValue);
		}
	}

	OnPlayerDisconnect = function(tParams)
	{
		g_sLGLaserBeamColor[tParams["_player"].GetEntityIndex()] = "0 127 255";
	}
};

PrecacheEntityFromTable({classname = "env_laser", texture = "sprites/laserbeam.spr"});
PrecacheEntityFromTable({classname = "info_particle_system", effect_name = "sparks_generic_random_core"});

g_ScriptPluginsHelper.AddScriptPlugin(g_PluginLaserGun);