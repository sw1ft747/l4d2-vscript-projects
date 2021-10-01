// Squirrel
// Plane Crash

class CScriptPluginPlaneCrash extends IScriptPlugin
{
	function Load()
	{
		::g_ConVar_AllowPlaneCrash <- CreateConVar("pc_allow", 1, "integer", 0, 1);
		::g_ConVar_PlaneCrashChance <- CreateConVar("pc_chance", 90, "integer", 0, 100);
		::g_ConVar_PlaneCrashClearTime <- CreateConVar("pc_time", 0.0, "float", 0.0);
		::g_ConVar_PlaneCrashDamage <- CreateConVar("pc_damage", 20, "float", 0);
		::g_ConVar_PlaneCrashLimit <- CreateConVar("pc_limit", 5, "integer", 1);
		::g_ConVar_PlaneCrashHordeTime <- CreateConVar("pc_horde", 24.0, "float", 0.0);

		RegisterOnTickFunction("g_tPlaneCrash.PlaneCrash_Think");

		HookEvent("finale_escape_start", g_tPlaneCrash.OnFinaleEscapeStarted, g_tPlaneCrash);

		g_ConVar_PlaneCrashLimit.AddChangeHook(g_tPlaneCrash.OnConVarChange);

		printl("[Plane Crash]\nAuthor: Sw1ft\nVersion: 2.1.2");
	}

	function Unload()
	{

	}

	function OnRoundStartPost()
	{
		local hEntity, chance;
		if ((chance = GetConVarInt(g_ConVar_PlaneCrashChance)) > 0)
		{
			foreach (map, tbl in g_tPlaneCrashParams)
			{
				if (g_sMapName == map)
				{
					if (RandomInt(1, 100) <= chance)
					{
						hEntity = SpawnEntityFromTable("trigger_multiple", {
							targetname = "plane_crash_" + g_sMapName
							origin = tbl["trigger_origin"]
							spawnflags = TR_CLIENTS
						});
						hEntity.__KeyValueFromInt("solid", 2);
						hEntity.__KeyValueFromVector("maxs", tbl["trigger_maxs"]);
						hEntity.__KeyValueFromVector("mins", tbl["trigger_mins"]);
						hEntity.__KeyValueFromString("OnStartTouch", "!caller,RunScriptCode,g_tPlaneCrash.OnTriggerTouch()");
						hEntity.ValidateScriptScope();
						printf("> [Plane Crash] A trigger has been spawned for the current map at %.03f %.03f %.03f", tbl["trigger_origin"].x, tbl["trigger_origin"].y, tbl["trigger_origin"].z);
					}
				}
			}
		}
	}

	function OnRoundEnd()
	{

	}

	function AdditionalClassMethodsInjected()
	{
		RegisterChatCommand("!pc_mode", g_tPlaneCrash.SwitchMode, true);
		RegisterChatCommand("!pc_clear", g_tPlaneCrash.Clear, true);
		RegisterChatCommand("!plane", g_tPlaneCrash.Forward, true);
		RegisterChatCommand("!bplane", g_tPlaneCrash.Behind, true);
		RegisterChatCommand("!lplane", g_tPlaneCrash.Left, true);
		RegisterChatCommand("!rplane", g_tPlaneCrash.Right, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	function _set(key, val) { throw null; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CScriptPluginPlaneCrash";
	static m_sScriptPluginName = "Plane Crash";
}

enum eCrashType
{
	Forward,
	Behind,
	Left,
	Right
}

g_PlaneCrash <- CScriptPluginPlaneCrash();

g_bMode <- true;
g_flLastSurvivorsReaction <- 0.0;

g_aPlanes <- [];

g_sPlaneModel <-
[
	"models/props_interiors/airportdeparturerampcontrol01.mdl"
	"models/hybridphysx/precrash_airliner.mdl"
	"models/hybridphysx/airliner_fuselage_secondary_1.mdl"
	"models/hybridphysx/airliner_fuselage_secondary_2.mdl"
	"models/hybridphysx/airliner_fuselage_secondary_3.mdl"
	"models/hybridphysx/airliner_fuselage_secondary_4.mdl"
	"models/hybridphysx/airliner_left_wing_secondary.mdl"
	"models/hybridphysx/airliner_right_wing_secondary_1.mdl"
	"models/hybridphysx/airliner_right_wing_secondary_2.mdl"
	"models/hybridphysx/airliner_tail_secondary.mdl"
	"models/hybridphysx/airliner_primary_debris_4.mdl"
	"models/hybridphysx/airliner_primary_debris_1.mdl"
	"models/hybridphysx/airliner_primary_debris_2.mdl"
	"models/hybridphysx/airliner_primary_debris_3.mdl"
	"models/hybridphysx/airliner_fire_emit1.mdl"
	"models/hybridphysx/airliner_fire_emit2.mdl"
	"models/hybridphysx/airliner_sparks_emit.mdl"
	"models/hybridphysx/airliner_endstate_vcollide_dummy.mdl"
];

g_tPlaneCrashParams <-
{
	c1m2_streets =
	{
		trigger_origin = Vector(-7301.124, -1146.229, 382.507)
		trigger_maxs = Vector(13.366, 1002.849, 1080.520)
		trigger_mins = Vector()
		origin = Vector(-9011.491, -576.481, 384.031)
		angles = QAngle(0, 180, 0)
	}

	c2m1_highway =
	{
		trigger_origin = Vector(1844.480, 6705.288, -1118.534)
		trigger_maxs = Vector(2136.581, 16.381, 971.237)
		trigger_mins = Vector()
		origin = Vector(3773.583, 5229.438, -1004.816)
		angles = QAngle(0, -93.231, 0)
	}

	c3m4_plantation =
	{
		trigger_origin = Vector(-2374.878, -3565.377, 3.613)
		trigger_maxs = Vector(2003.132, 2206.400, 1191.983)
		trigger_mins = Vector()
		origin = Vector(-2785.709, -3676.346, 52.115)
		angles = QAngle(0, -121.851, 0)
	}

	c5m4_quarter =
	{
		trigger_origin = Vector(-1380.347, -1791.956, 64.681)
		trigger_maxs = Vector(30.247, 132.206, 1115.703)
		trigger_mins = Vector()
		origin = Vector(229.832, -913.114, 65.031)
		angles = QAngle(0, 90.728, 0)
	}
	
	c6m2_bedlam =
	{
		trigger_origin = Vector(639.570, 1281.739, -63.969)
		trigger_maxs = Vector(1707.050, 142.284, 841.336)
		trigger_mins = Vector()
		origin = Vector(-757.382, 1156.305, -88.737)
		angles = QAngle(0, 89.240, 0)
	}

	c7m3_port =
	{
		trigger_origin = Vector(-300.677, -1882.187, -0.630)
		trigger_maxs = Vector(632.311, 578.951, 995.576)
		trigger_mins = Vector()
		origin = Vector(813.220, -32.343, -5.372)
		angles = QAngle(0, 180, 0)
	}

	c8m1_apartment =
	{
		trigger_origin = Vector(749.650, 1796.665, 16.031)
		trigger_maxs = Vector(1938.032, 55.383, 4562.303)
		trigger_mins = Vector()
		origin = Vector(1149.504, 1818.803, 8.031)
		angles = QAngle(0, -90.174, 0)
	}

	c9m1_alleys =
	{
		trigger_origin = Vector(-4577.353, -10280.589, 5.106)
		trigger_maxs = Vector(27.726, 2081.276, 933.604)
		trigger_mins = Vector()
		origin = Vector(-3199.007, -11608.114, 64.031)
		angles = QAngle(0, -179.499, 0)
	}

	c10m4_mainstreet =
	{
		trigger_origin = Vector(-3146.643, -140.137, 375.231)
		trigger_maxs = Vector(156.765, 17.999, 138.520)
		trigger_mins = Vector()
		origin = Vector(-4272.170, -1079.558, -63.968)
		angles = QAngle(0, 176.842, 0)
	}

	c12m1_hilltop =
	{
		trigger_origin = Vector(-11067.224, -13421.997, 585.149)
		trigger_maxs = Vector(896.173, 8.708, 1619.477)
		trigger_mins = Vector()
		origin = Vector(-12169.009, -12943.565, -86.600)
		angles = QAngle(0, 111.220, 0)
	}

	c13m3_memorialbridge =
	{
		trigger_origin = Vector(757.256, -4666.164, 822.675)
		trigger_maxs = Vector(1131.471, 134.771, 1519.715)
		trigger_mins = Vector()
		origin = Vector(353.373, -3296.894, 105.241)
		angles = QAngle(0, 152.687, 0)
	}

	c14m2_lighthouse =
	{
		trigger_origin = Vector(-7334.104, 4356.157, -263.416)
		trigger_maxs = Vector(6793.194, 41.668, 2639.376)
		trigger_mins = Vector()
		origin = Vector(-4913.594, 5219.752, -136.201)
		angles = QAngle(0, 178.7, 0)
	}
};

class CPlaneCrash
{
	constructor(vecOrigin, eAngles, bDamage)
	{
		eAngles.x = 0.0;
		eAngles.z = 0.0;
		eAngles.y += 30.0;

		local hEntity;
		local vecDirection = eAngles.Forward();

		vecOrigin += vecDirection * -750;
		vecOrigin += Vector(vecDirection.y, -vecDirection.x, 0.0) * 1270;
		vecOrigin.z -= 50.0;

		m_aHurtTriggers = [];
		m_aPlaneCrashEmitters = [];
		m_aPlaneCrash = [];

		hEntity = SpawnEntityFromTable("ambient_generic", {
			volume = 2
			spawnflags = 49
			radius = 3250
			pitchstart = 100
			pitch = 100
			message = "airport.planecrash"
		});
		TP(hEntity, vecOrigin, null, null);
		m_hPlaneCrashSound = hEntity;

		hEntity = SpawnEntityFromTable("env_shake", {
			spawnflags = 1
			duration = 4
			amplitude = 4
			frequency = 180
			radius = 3117
		});
		TP(hEntity, vecOrigin, null, null);
		m_hPlaneCrashShake = hEntity;

		hEntity = SpawnEntityFromTable("prop_dynamic", {
			spawnflags = 0
			StartDisabled = 1
			disableshadows = 1
			model = g_sPlaneModel[1]
		});
		TP(hEntity, vecOrigin, eAngles, null);
		m_hPlanePreCrash = hEntity;

		hEntity = SpawnEntityFromTable("prop_dynamic", {
			spawnflags = 0
			solid = 0
			StartDisabled = 1
			disableshadows = 1
			model = g_sPlaneModel[11]
		});
		TP(hEntity, vecOrigin, eAngles, null);
		m_hPlaneCrashTail = hEntity;

		hEntity = SpawnEntityFromTable("prop_dynamic", {
			spawnflags = 0
			solid = 0
			StartDisabled = 1
			model = g_sPlaneModel[12]
		});
		TP(hEntity, vecOrigin, eAngles, null);
		m_hPlaneCrashEngine = hEntity;

		hEntity = SpawnEntityFromTable("prop_dynamic", {
			spawnflags = 0
			solid = 0
			StartDisabled = 1
			disableshadows = 1
			model = g_sPlaneModel[13]
		});
		TP(hEntity, vecOrigin, eAngles, null);
		m_hPlaneCrashWing = hEntity;

		hEntity = SpawnEntityFromTable("prop_dynamic", {
			spawnflags = 0
			solid = 6
			StartDisabled = 1
			RandomAnimation = 0
			model = g_sPlaneModel[17]
		});
		TP(hEntity, vecOrigin + Vector(0, 0, 9999.9), eAngles, null);
		m_hPlaneCrashCollision = hEntity;

		for (local i = 0; i < 9; i++)
		{
			hEntity = SpawnEntityFromTable("prop_dynamic", {
				spawnflags = 0
				solid = 0
				StartDisabled = 1
				disableshadows = 1
				model = g_sPlaneModel[2 + i]
			});
			TP(hEntity, vecOrigin, eAngles, null);
			m_aPlaneCrash.append(hEntity);
		}

		for (local j = 0; j < 3; j++)
		{
			hEntity = SpawnEntityFromTable("prop_dynamic", {
				spawnflags = 0
				solid = 0
				StartDisabled = 1
				model = g_sPlaneModel[14 + j]
			});
			TP(hEntity, vecOrigin, eAngles, null);
			m_aPlaneCrashEmitters.append(hEntity);
		}

		if (bDamage)
		{
			hEntity = SpawnEntityFromTable("trigger_hurt", {
				spawnflags = 3
				damagetype = 1
				damage = GetConVarFloat(g_ConVar_PlaneCrashDamage)
			});
			AcceptEntityInput(hEntity, "Disable");
			AttachEntity(m_hPlaneCrashTail, hEntity, "HullDebris1");
			hEntity.__KeyValueFromVector("maxs", Vector(300, 300, 300));
			hEntity.__KeyValueFromVector("mins", Vector(-300, -300, -300));
			hEntity.__KeyValueFromInt("solid", 2);
			TP(hEntity, vecOrigin, eAngles, null);
			m_aHurtTriggers.append(hEntity);

			hEntity = SpawnEntityFromTable("trigger_hurt", {
				spawnflags = 3
				damagetype = 1
				damage = GetConVarFloat(g_ConVar_PlaneCrashDamage)
			});
			AcceptEntityInput(hEntity, "Disable");
			AttachEntity(m_hPlaneCrashEngine, hEntity, "particleEmitter2");
			hEntity.__KeyValueFromVector("maxs", Vector(300, 300, 300));
			hEntity.__KeyValueFromVector("mins", Vector(-300, -300, -300));
			hEntity.__KeyValueFromInt("solid", 2);
			TP(hEntity, vecOrigin, eAngles, null);
			m_aHurtTriggers.append(hEntity);

			hEntity = SpawnEntityFromTable("trigger_hurt", {
				spawnflags = 3
				damagetype = 1
				damage = GetConVarFloat(g_ConVar_PlaneCrashDamage)
			});
			AcceptEntityInput(hEntity, "Disable");
			AttachEntity(m_hPlaneCrashWing, hEntity, "new_spark_joint_1");
			hEntity.__KeyValueFromVector("maxs", Vector(300, 300, 300));
			hEntity.__KeyValueFromVector("mins", Vector(-300, -300, -300));
			hEntity.__KeyValueFromInt("solid", 2);
			TP(hEntity, vecOrigin, eAngles, null);
			m_aHurtTriggers.append(hEntity);
		}

		m_aEntities = [m_hPlaneCrashSound, m_hPlaneCrashShake, m_hPlaneCrashCollision, m_hPlanePreCrash, m_hPlaneCrashTail, m_hPlaneCrashWing, m_hPlaneCrashEngine];
		m_aEntities.extend(m_aHurtTriggers);
		m_aEntities.extend(m_aPlaneCrashEmitters);
		m_aEntities.extend(m_aPlaneCrash);
	}

	function StartCrash()
	{
		if (IsAllEntitiesValid())
		{
			AcceptEntityInput(m_hPlaneCrashSound, "PlaySound");

			AcceptEntityInput(m_hPlaneCrashShake, "StartShake", "", 20.5);
			AcceptEntityInput(m_hPlaneCrashShake, "StartShake", "", 23.0);
			AcceptEntityInput(m_hPlaneCrashShake, "StartShake", "", 24.0);
			AcceptEntityInput(m_hPlaneCrashShake, "StartShake", "", 26.0);
			AcceptEntityInput(m_hPlaneCrashShake, "Kill", "", 30.0);

			AcceptEntityInput(m_hPlanePreCrash, "SetAnimation", "approach");
			AcceptEntityInput(m_hPlanePreCrash, "TurnOn");
			AcceptEntityInput(m_hPlanePreCrash, "Kill", "", 15.0);

			AcceptEntityInput(m_hPlaneCrashTail, "SetAnimation", "idleOuttaMap");
			AcceptEntityInput(m_hPlaneCrashTail, "TurnOn", "", 14.0);
			AcceptEntityInput(m_hPlaneCrashTail, "SetAnimation", "boom", 14.95);

			AcceptEntityInput(m_hPlaneCrashEngine, "SetAnimation", "idleOuttaMap");
			AcceptEntityInput(m_hPlaneCrashEngine, "TurnOn", "", 14.0);
			AcceptEntityInput(m_hPlaneCrashEngine, "SetAnimation", "boom", 14.95);

			AcceptEntityInput(m_hPlaneCrashWing, "SetAnimation", "idleOuttaMap");
			AcceptEntityInput(m_hPlaneCrashWing, "TurnOn", "", 14.0);
			AcceptEntityInput(m_hPlaneCrashWing, "SetAnimation", "boom", 14.95);

			if (GetConVarFloat(g_ConVar_PlaneCrashHordeTime) > 0)
			{
				if (!Entities.FindByName(null, "director"))
				{
					SpawnEntityFromTable("info_director", {targetname = "director"});
				}

				m_PanicEventTimer = CreateTimer(GetConVarFloat(g_ConVar_PlaneCrashHordeTime), function(){
					EntFire("director", "ForcePanicEvent", "1");
					EntFire("@director", "ForcePanicEvent", "1");
				});
			}

			foreach (ent in m_aHurtTriggers)
			{
				AcceptEntityInput(ent, "Enable", "", 15.0);
				AcceptEntityInput(ent, "Kill", "", 27.0);
			}

			foreach (ent in m_aPlaneCrash)
			{
				AcceptEntityInput(ent, "SetAnimation", "idleOuttaMap");
				AcceptEntityInput(ent, "TurnOn", "", 14.0);
				AcceptEntityInput(ent, "SetAnimation", "boom", 14.95);
			}

			foreach (ent in m_aPlaneCrashEmitters)
			{
				AcceptEntityInput(ent, "SetAnimation", "boom", 14.95);
			}

			CreateTimer(27.0, function(hPlaneCrashCollision){
				if (hPlaneCrashCollision.IsValid())
				{
					TP(hPlaneCrashCollision, hPlaneCrashCollision.GetOrigin() - Vector(0, 0, 9999.9), null, null);
				}
			}, m_hPlaneCrashCollision);

			m_SurvivorsReactionTimer = CreateTimer(30.0, function(){
				if (g_flLastSurvivorsReaction + 10.0 < Time())
				{
					local hPlayer;
					local aL4D1Survivors = [];
					local aL4D2Survivors = [];
					local aL4D1SurvivorsNames = ["louis", "zoey", "bill", "francis"];
					local aL4D2SurvivorsNames = ["coach", "nick", "ellis", "rochelle"];
					
					for (local i = 0; i < aL4D1SurvivorsNames.len(); i++)
					{
						hPlayer = Entities.FindByName(null, "!" + aL4D1SurvivorsNames[i]);
						if (hPlayer)
						{
							if (hPlayer.IsSurvivor() && hPlayer.IsAlive() && !hPlayer.IsIncapacitated())
							{
								aL4D1Survivors.append(hPlayer);
							}
						}
					}

					for (local j = 0; j < aL4D2SurvivorsNames.len(); j++)
					{
						hPlayer = Entities.FindByName(null, "!" + aL4D2SurvivorsNames[j]);
						if (hPlayer)
						{
							if (hPlayer.IsSurvivor() && hPlayer.IsAlive() && !hPlayer.IsIncapacitated())
							{
								if (GetCharacterDisplayName(hPlayer).tolower() == aL4D2SurvivorsNames[j])
								{
									aL4D2Survivors.append(hPlayer);
								}
							}
						}
					}

					if (aL4D1Survivors.len() > 0)
					{
						local hEntity = SpawnEntityFromTable("func_orator", {
							model = g_sPlaneModel[0]
							disableshadows = 1
							spawnflags = 1
						});
						NetProps.SetPropInt(hEntity, "m_fEffects", (1 << 5));
						AcceptEntityInput(hEntity, "SpeakResponseConcept", "PlaneCrash");
						AcceptEntityInput(hEntity, "Kill", "", 0.01);
					}

					if (aL4D2Survivors.len() > 0)
					{
						local idx;
						local arr = [];
						local flTime = 1.0;

						while (aL4D2Survivors.len() > 0) // shuffle the array
						{
							idx = RandomInt(0, aL4D2Survivors.len() - 1);
							arr.append(aL4D2Survivors[idx]);
							aL4D2Survivors.remove(idx);
						}

						for (local k = 0; k < arr.len(); k++)
						{
							AcceptEntityInput(arr[k], "SpeakResponseConcept", "C2M1Falling", flTime);
							flTime += 0.25;
						}
					}
					g_flLastSurvivorsReaction = Time();
				}
			});

			m_flCrashTime = Time() + 32.0;

			return true;
		}
		return false;
	}

	function ClearCrash()
	{
		foreach (ent in m_aEntities)
		{
			if (ent)
			{
				if (ent.IsValid())
				{
					if (ent == m_hPlaneCrashSound)
					{
						AcceptEntityInput(m_hPlaneCrashSound, "Volume", "0");
						AcceptEntityInput(m_hPlaneCrashSound, "Kill", "", 0.01);
					}
					else ent.Kill();
				}
			}
		}

		if (m_SurvivorsReactionTimer)
		{
			foreach (idx, timer in g_aTimers)
			{
				if (m_SurvivorsReactionTimer.GetIdentifier() == timer.GetIdentifier())
				{
					g_aTimers.remove(idx);
					break;
				}
			}
		}

		if (m_PanicEventTimer)
		{
			foreach (idx, timer in g_aTimers)
			{
				if (m_PanicEventTimer.GetIdentifier() == timer.GetIdentifier())
				{
					g_aTimers.remove(idx);
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

	function _set(key, val) { throw null; }

	m_flCrashTime = null;
	m_hPlanePreCrash = null;
	m_hPlaneCrashTail = null;
	m_hPlaneCrashWing = null;
	m_hPlaneCrashEngine = null;
	m_hPlaneCrashSound = null;
	m_hPlaneCrashShake = null;
	m_hPlaneCrashCollision = null;
	m_aPlaneCrashEmitters = null;
	m_aPlaneCrash = null;
	m_aHurtTriggers = null;
	m_aEntities = null;
	m_SurvivorsReactionTimer = null;
	m_PanicEventTimer = null;
}

g_tPlaneCrash <-
{
	OnConVarChange = function(ConVar, LastValue, NewValue)
	{
		while (g_aPlanes.len() > NewValue)
		{
			g_aPlanes[0].ClearCrash();
			g_aPlanes.remove(0);
		}
	}

	OnFinaleEscapeStarted = function(tParams)
	{
		if (g_sMapName == "c4m5_milltown_escape")
		{
			local chance = GetConVarInt(g_ConVar_PlaneCrashChance);
			if (chance > 0)
			{
				if (RandomInt(1, 100) <= chance)
				{
					g_tPlaneCrash.Start(Vector(-6803.697, 7144.039, 94.930), QAngle(0, -100.016, 0));
				}
			}
		}
	}

	OnTriggerTouch = function()
	{
		if (!activator) return;
		if (activator.IsSurvivor())
		{
			if (caller.GetName().find("plane_crash_") != null)
			{
				if (GetConVarBool(g_ConVar_AllowPlaneCrash))
				{
					if (g_sMapName == caller.GetName().slice(12))
					{
						if (g_aPlanes.len() > 0 && g_aPlanes.len() + 1 > GetConVarInt(g_ConVar_PlaneCrashLimit))
						{
							g_aPlanes[0].ClearCrash();
							g_aPlanes.remove(0);
						}
						g_tPlaneCrash.Start(g_tPlaneCrashParams[g_sMapName]["origin"], g_tPlaneCrashParams[g_sMapName]["angles"]);
						caller.Kill();
					}
				}
			}
		}
	}

	PlaneCrash_Think = function()
	{
		if (g_aPlanes.len() > 0 && GetConVarFloat(g_ConVar_PlaneCrashClearTime) > 0)
		{
			for (local i = 0; i < g_aPlanes.len(); i++)
			{
				if (g_aPlanes[i].m_flCrashTime != null)
				{
					if (g_aPlanes[i].m_flCrashTime + GetConVarFloat(g_ConVar_PlaneCrashClearTime) < Time())
					{
						g_aPlanes[i].ClearCrash();
						g_aPlanes.remove(i);
						i--;
					}
				}
			}
		}
	}

	Start = function(vecOrigin, eAngles)
	{
		if (g_aPlanes.len() > 0 && g_aPlanes.len() + 1 > GetConVarInt(g_ConVar_PlaneCrashLimit))
		{
			g_aPlanes[0].ClearCrash();
			g_aPlanes.remove(0);
		}
		local plane = CPlaneCrash(vecOrigin, eAngles, GetConVarBool(g_ConVar_PlaneCrashDamage));
		if (!plane.StartCrash()) plane.ClearCrash();
		else g_aPlanes.append(plane);
	}

	Initialize = function(hPlayer, iCrashType)
	{
		if (hPlayer.IsHost() && GetConVarBool(g_ConVar_AllowPlaneCrash))
		{
			local vecOrigin;
			local eAngles = hPlayer.EyeAngles();
			if (g_bMode) vecOrigin = GetPositionToGround(hPlayer);
			else vecOrigin = hPlayer.DoTraceLine(eTrace.Type_Pos, eTrace.Distance, eTrace.Mask_Shot);
			if (iCrashType == eCrashType.Behind) eAngles += QAngle(0, 180, 0);
			else if (iCrashType == eCrashType.Left) eAngles += QAngle(0, 90, 0);
			else if (iCrashType == eCrashType.Right) eAngles -= QAngle(0, 90, 0);
			g_tPlaneCrash.Start(vecOrigin, eAngles);
		}
	}

	Clear = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			for (local i = 0; i < g_aPlanes.len(); i++)
			{
				g_aPlanes[i].ClearCrash();
				g_aPlanes.remove(i);
				i--;
			}
		}
	}

	SwitchMode = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			sayf("[Plane Crash] Crash mode: %s", g_bMode ? "camera direction" : "near the player");
			g_bMode = !g_bMode;
		}
	}

	Forward = function(hPlayer) { g_tPlaneCrash.Initialize(hPlayer, eCrashType.Forward); }

	Behind = function(hPlayer) { g_tPlaneCrash.Initialize(hPlayer, eCrashType.Behind); }

	Left = function(hPlayer) { g_tPlaneCrash.Initialize(hPlayer, eCrashType.Left); }

	Right = function(hPlayer) { g_tPlaneCrash.Initialize(hPlayer, eCrashType.Right); }
};

PrecacheEntityFromTable({classname = "ambient_generic", message = "airport.planecrash"});

for (local i = 0; i < g_sPlaneModel.len(); i++)
{
	PrecacheEntityFromTable({classname = "prop_dynamic", model = g_sPlaneModel[i]});
}

g_ScriptPluginsHelper.AddScriptPlugin(g_PlaneCrash);