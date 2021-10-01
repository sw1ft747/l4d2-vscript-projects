// Squirrel
// Bridge Destruction

class CScriptPluginBridgeDestruction extends IScriptPlugin
{
	function Load()
	{
		::g_ConVar_AllowBridgeDest <- CreateConVar("bd_allow", 1, "integer", 0, 1);
		::g_ConVar_BridgeDestChance <- CreateConVar("bd_chance", 90, "integer", 0, 100);
		::g_ConVar_BridgeDestClearTime <- CreateConVar("bd_time", 0.0, "float", 0.0);
		::g_ConVar_BridgeDestDamage <- CreateConVar("bd_damage", 1, "integer", 0, 1);
		::g_ConVar_BridgeDestLimit <- CreateConVar("bd_limit", 10, "integer", 1);
		::g_ConVar_BridgeDestHordeTime <- CreateConVar("bd_horde", 10.5, "float", 0.0);

		RegisterOnTickFunction("g_tBridgeDestruction.BridgeDestruction_Think");

		g_ConVar_BridgeDestLimit.AddChangeHook(g_tBridgeDestruction.OnConVarChange);

		printl("[Bridge Destruction]\nAuthor: Sw1ft\nVersion: 1.2.1");
	}

	function Unload()
	{

	}

	function OnRoundStartPost()
	{
		local hEntity, chance;
		if ((chance = GetConVarInt(g_ConVar_BridgeDestChance)) > 0)
		{
			foreach (map, tbl in g_tBridgeDestParams)
			{
				if (g_sMapName == map)
				{
					if (RandomInt(1, 100) <= chance)
					{
						if (g_sMapName == "c9m1_alleys" || g_sMapName == "c13m2_southpinestream")
						{
							if (!RandomInt(0, 1))
								continue;
						}

						local idx = ++g_iUniquePendingBridges; idx = idx.tostring();

						if (g_iUniquePendingBridges == 99999) g_iUniquePendingBridges = 0;
						while (idx.len() != 5) idx = "0" + idx;

						local sName = "bridge_dest" + "_" + idx + "_" + g_sMapName;

						g_tBridgeDestruction.SpawnTrigger(sName, tbl["trigger_origin"], tbl["trigger_maxs"], tbl["trigger_mins"]);
						g_tPendingBridges[sName] <- CBridgeDestruction(g_tBridgeDestParams[g_sMapName]["origin"], g_tBridgeDestParams[g_sMapName]["angles"], GetConVarBool(g_ConVar_BridgeDestDamage));

						printf("> [Bridge Destruction] A trigger has been spawned for the current map at %.03f %.03f %.03f", tbl["trigger_origin"].x, tbl["trigger_origin"].y, tbl["trigger_origin"].z);
					}
				}
			}

			if (g_sMapName == "c3m1_plankcountry")
			{
				if (RandomInt(0, 1) && RandomInt(1, 100) <= chance)
				{
					CreateTimer(5.0, function(){
						local hEntity;
						if (hEntity = Entities.FindByName(null, "ferry_button"))
						{
							local idx = ++g_iUniquePendingBridges; idx = idx.tostring();

							if (g_iUniquePendingBridges == 99999) g_iUniquePendingBridges = 0;
							while (idx.len() != 5) idx = "0" + idx;

							local sName = "bridge_dest" + "_" + idx + "_" + g_sMapName;
							getroottable()["OnFerryButtonPress"] <- function() foreach (key, val in g_tPendingBridges) EntFire(key, "Enable");

							g_tBridgeDestruction.SpawnTrigger(sName, Vector(-6958.838, 4708.850, -24.768), Vector(2601.610, 3271.359, 1301.132), Vector(), "g_tBridgeDestruction.OnTriggerTouch", TR_OFF | TR_CLIENTS);
							g_tPendingBridges[sName] <- CBridgeDestruction(Vector(-4816.808, 6674.193, -9.375), QAngle(), GetConVarBool(g_ConVar_BridgeDestDamage));

							hEntity.ConnectOutput("OnPressed", "OnFerryButtonPress");
						}
					});
				}
			}
		}
	}

	function OnRoundEnd()
	{

	}

	function AdditionalClassMethodsInjected()
	{
		RegisterChatCommand("!bd_mode", g_tBridgeDestruction.SwitchMode, true);
		RegisterChatCommand("!bd_clear", g_tBridgeDestruction.Clear, true);
		RegisterChatCommand("!bridge", g_tBridgeDestruction.Forward, true);
		RegisterChatCommand("!bbridge", g_tBridgeDestruction.Behind, true);
		RegisterChatCommand("!lbridge", g_tBridgeDestruction.Left, true);
		RegisterChatCommand("!rbridge", g_tBridgeDestruction.Right, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	function _set(key, val) { throw null; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CScriptPluginBridgeDestruction";
	static m_sScriptPluginName = "Bridge Destruction";
}

enum eDestructionType
{
	Forward,
	Behind,
	Left,
	Right
}

g_BridgeDestruction <- CScriptPluginBridgeDestruction();

g_bMode <- true;
g_iUniquePendingBridges <- 0;
g_flLastSurvivorsReaction <- 0.0;

g_aBridges <- [];

g_sBridgeDestModel <-
[
	"models/c5_bridge_destruction/bridge_centdwn_1.mdl"
	"models/c5_bridge_destruction/bridge_centdwn_1b.mdl"
	"models/c5_bridge_destruction/bridge_centdwn_2.mdl"
	"models/c5_bridge_destruction/bridge_centup_1.mdl"
	"models/c5_bridge_destruction/bridge_centup_1b.mdl"
	"models/c5_bridge_destruction/bridge_centup_2.mdl"
	"models/c5_bridge_destruction/bridge_centup_2b.mdl"
	"models/c5_bridge_destruction/bridge_left_tower.mdl"
	"models/c5_bridge_destruction/bridge_right_tower.mdl"
	"models/c5_bridge_destruction/bridge_lfttower_rip_botfloors.mdl"
	"models/c5_bridge_destruction/bridge_lfttower_rip_topfloors.mdl"
	"models/c5_bridge_destruction/bridge_lfttower_stat_floors.mdl"
	"models/c5_bridge_destruction/bridge_rgttower_floors.mdl"
	"models/c5_bridge_destruction/bridge_rgttower_topfloors.mdl"
	"models/c5_bridge_destruction/bridge_vertical_rails.mdl"
	"models/c5_bridge_destruction/bridge_pierbase.mdl"
	"models/c5_bridge_destruction/bridge_semiflatnose.mdl"
	"models/c5_bridge_destruction/bridge_fueltruck.mdl"
	"models/c5_bridge_destruction/bridge_hummers.mdl"
	"models/c5_bridge_destruction/bridge_dynamic_center1.mdl"
	"models/c5_bridge_destruction/bridge_dynamic_center2.mdl"
	"models/c5_bridge_destruction/bridge_dynamic_end1.mdl"
	"models/c5_bridge_destruction/bridge_dynamic_end2.mdl"
	"models/c5_bridge_destruction/bridge_busses.mdl"
	"models/props_interiors/airportdeparturerampcontrol01.mdl"
	"models/f18/f18_placeholder.mdl"
];

g_tPendingBridges <- {};

g_tBridgeDestParams <-
{
	c6m3_port =
	{
		trigger_origin = Vector(-2062.633, -685.943, -191.969)
		trigger_maxs = Vector(108.640, 12.566, 410.655)
		trigger_mins = Vector()
		origin = Vector(-3141.602, -2143.331, -110.209)
		angles = QAngle(0, 180, 0)
	}

	c9m1_alleys =
	{
		trigger_origin = Vector(-949.667, -7970.812, -223.675)
		trigger_maxs = Vector(22.216, 3177.197, 1364.365)
		trigger_mins = Vector()
		origin = Vector(2080.064, -4009.666, 228.966)
		angles = QAngle(0, 0, 0)
	}

	c9m2_lots =
	{
		trigger_origin = Vector(3032.958, 2666.969, -101.435)
		trigger_maxs = Vector(807.156, 148.021, 1314.826)
		trigger_mins = Vector()
		origin = Vector(1275.789, 4534.177, 387.299)
		angles = QAngle(0, 180, 0)
	}

	c10m3_ranchhouse =
	{
		trigger_origin = Vector(-9937.490, -7684.239, -64.212)
		trigger_maxs = Vector(81.160, 2330.433, 1253.644)
		trigger_mins = Vector()
		origin = Vector(-11367.77, -8278.106, -63.968)
		angles = QAngle(0, -90, 0)
	}

	c12m4_barn =
	{
		trigger_origin = Vector(10822.685, -4212.229, 116.031)
		trigger_maxs = Vector(17.283, 180.896, 127.043)
		trigger_mins = Vector()
		origin = Vector(8984.604, -2053.905, 238.65)
		angles = QAngle(0, 180, 0)
	}

	c13m2_southpinestream =
	{
		trigger_origin = Vector(-1047.866, 5766.257, 272.152)
		trigger_maxs = Vector(2673.266, 13.561, 2565.334)
		trigger_mins = Vector()
		origin = Vector(30.444, 6942.437, 275.739)
		angles = QAngle(0, 90, 0)
	}

	c13m3_memorialbridge =
	{
		trigger_origin = Vector(-3722.606, -6447.695, 444.042)
		trigger_maxs = Vector(10.111, 1822.004, 1662.693)
		trigger_mins = Vector()
		origin = Vector(-1914.662, -7212.97, 157.138)
		angles = QAngle(0, -100, 0)
	}

	c14m1_junkyard =
	{
		trigger_origin = Vector(-4432.354, -6572.248, -315.754)
		trigger_maxs = Vector(1713.458, 14.379, 1649.094)
		trigger_mins = Vector()
		origin = Vector(-6870.083, -5472.271, -380.567)
		angles = QAngle(0, 180, 0)
	}
};

class CBridgeDestruction
{
	constructor(vecOrigin, eAngles, bDamage)
	{
		eAngles.x = 0.0;
		eAngles.z = 0.0;
		vecOrigin -= eAngles.Forward() * 500;

		local vecLeft = eAngles.Left();
		local vecCenter = Vector(vecOrigin.x, vecOrigin.y, vecOrigin.z + 750);

		eAngles.y -= 90.0;
		eAngles = kvstr(eAngles);

		m_aBridgeDestSounds = [];
		m_aBridgeSupport = [];
		m_aBridge = [];

		if (bDamage)
		{
			m_hExplosionA = SpawnEntityFromTable("env_explosion", {
				origin = vecCenter + vecLeft * 650
				iRadiusOverride = 1200
				iMagnitude = 10
				ignoredClass = 0
				spawnflags = 4 | 64 | 256 | 512 | 8192
				targetname = "__bridge_dest__"
				fireballsprite = "sprites/zerogxplode.spr"
			});

			m_hExplosionB = SpawnEntityFromTable("env_explosion", {
				origin = vecCenter + vecLeft * -1000
				iRadiusOverride = 1200
				iMagnitude = 10
				ignoredClass = 0
				spawnflags = 4 | 64 | 256 | 512 | 8192
				targetname = "__bridge_dest__"
				fireballsprite = "sprites/zerogxplode.spr"
			});
		}

		for (local i = 0; i < 19; i++)
		{
			m_aBridge.append(SpawnEntityFromTable("prop_dynamic", {
				origin = vecOrigin
				angles = eAngles
				disableshadows = 1
				targetname = "__bridge_dest__"
				model = g_sBridgeDestModel[i]
			}));
		}

		for (local j = 19; j < 23; j++)
		{
			m_aBridgeSupport.append(SpawnEntityFromTable("prop_dynamic", {
				origin = vecOrigin
				angles = eAngles
				disableshadows = 1
				targetname = "__bridge_dest__"
				model = g_sBridgeDestModel[j]
			}));
		}

		m_hBridgeDestBusA = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_sBridgeDestModel[23]
		});

		m_hBridgeDestBusB = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_sBridgeDestModel[23]
		});
		AcceptEntityInput(m_hBridgeDestBusB, "SetAnimation", "hold_bus2");

		m_hBridgeDestBusC = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_sBridgeDestModel[23]
		});
		AcceptEntityInput(m_hBridgeDestBusC, "SetAnimation", "hold_bus3");

		m_aBridgeDestSounds.append(SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin
			volume = 10
			spawnflags = 1 | 16 | 32
			radius = 10000
			pitchstart = 100
			pitch = 100
			targetname = "__bridge_dest__"
			message = "bridge.outro03"
		}));

		m_aBridgeDestSounds.append(SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin
			volume = 10
			spawnflags = 1 | 16 | 32
			radius = 60000
			pitchstart = 100
			pitch = 100
			targetname = "__bridge_dest__"
			message = "bridge.jetflyby03"
		}));

		m_aBridgeDestSounds.append(SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin
			volume = 10
			spawnflags = 1 | 16 | 32
			radius = 60000
			pitchstart = 100
			pitch = 100
			targetname = "__bridge_dest__"
			message = "bridge.jetflyby03"
		}));

		m_hBridgeDestShake = SpawnEntityFromTable("env_shake", {
			origin = vecOrigin
			spawnflags = 1
			duration = 6
			amplitude = 10
			frequency = 250
			radius = 3000
			targetname = "__bridge_dest__"
		});

		vecOrigin.z -= 4500;
		m_hBridgeDestJetA = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			disablereceiveshadows = 1
			solid = 0
			StartDisabled = 1
			DefaultAnim = "home"
			targetname = "__bridge_dest__"
			model = g_sBridgeDestModel[25]
		});
		NetProps.SetPropFloat(m_hBridgeDestJetA, "m_flModelScale", 20);

		m_hBridgeDestJetB = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			disablereceiveshadows = 1
			solid = 0
			StartDisabled = 1
			DefaultAnim = "home"
			targetname = "__bridge_dest__"
			model = g_sBridgeDestModel[25]
		});
		NetProps.SetPropFloat(m_hBridgeDestJetB, "m_flModelScale", 20);

		m_aEntities = [m_hBridgeDestShake, m_hBridgeDestBusA, m_hBridgeDestBusB, m_hBridgeDestBusC, m_hBridgeDestJetA, m_hBridgeDestJetB];
		m_aEntities.extend(m_aBridge);
		m_aEntities.extend(m_aBridgeSupport);
		m_aEntities.extend(m_aBridgeDestSounds);
	}

	function StartDestruction()
	{
		if (IsAllEntitiesValid())
		{
			AcceptEntityInput(m_hExplosionA, "Explode", "", 9.0);
			AcceptEntityInput(m_hExplosionB, "Explode", "", 9.0);

			AcceptEntityInput(m_aBridgeDestSounds[0], "PlaySound");
			AcceptEntityInput(m_aBridgeDestSounds[1], "PlaySound", "", 9.75);
			AcceptEntityInput(m_aBridgeDestSounds[2], "PlaySound", "", 10.75);
			
			AcceptEntityInput(m_aBridgeDestSounds[0], "Kill", "", 20.0);
			AcceptEntityInput(m_aBridgeDestSounds[1], "Kill", "", 20.0);
			AcceptEntityInput(m_aBridgeDestSounds[2], "Kill", "", 20.0);

			AcceptEntityInput(m_hBridgeDestShake, "StartShake", "", 9.5);
			AcceptEntityInput(m_hBridgeDestShake, "Kill", "", 15.5);

			AcceptEntityInput(m_hBridgeDestJetA, "Enable", "", 6.0);
			AcceptEntityInput(m_hBridgeDestJetA, "SetAnimation", "bridge_outro1", 6.0);
			AcceptEntityInput(m_hBridgeDestJetA, "Kill", "", 17.5);

			AcceptEntityInput(m_hBridgeDestJetB, "Enable", "", 7.0);
			AcceptEntityInput(m_hBridgeDestJetB, "SetAnimation", "bridge_outro1", 7.0);
			AcceptEntityInput(m_hBridgeDestJetB, "Kill", "", 17.5);

			AcceptEntityInput(m_hBridgeDestBusA, "SetAnimation", "bus", 9.0);
			AcceptEntityInput(m_hBridgeDestBusB, "SetAnimation", "bus2", 9.0);
			AcceptEntityInput(m_hBridgeDestBusC, "SetAnimation", "bus3", 9.0);

			foreach (ent in m_aBridge)
			{
				AcceptEntityInput(ent, "SetAnimation", "hit", 9.0);
			}

			if (GetConVarFloat(g_ConVar_BridgeDestHordeTime) > 0)
			{
				if (!Entities.FindByName(null, "director"))
				{
					SpawnEntityFromTable("info_director", {targetname = "director"});
				}

				m_PanicEventTimer = CreateTimer(GetConVarFloat(g_ConVar_BridgeDestHordeTime), function(){
					EntFire("director", "ForcePanicEvent", "1");
					EntFire("@director", "ForcePanicEvent", "1");
				});
			}

			m_SurvivorsReactionTimer = CreateTimer(14.0, function(){
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
							disableshadows = 1
							spawnflags = 1
							model = g_sBridgeDestModel[24]
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

						while (aL4D2Survivors.len() > 0)
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

			m_flDestructionTime = Time() + 20.0;

			return true;
		}
		return false;
	}

	function ClearDestruction()
	{
		if (m_hExplosionA) AcceptEntityInput(m_hExplosionA, "Kill");
		if (m_hExplosionB) AcceptEntityInput(m_hExplosionB, "Kill");

		foreach (ent in m_aEntities)
		{
			if (ent)
			{
				if (ent.IsValid())
				{
					if (m_aBridgeDestSounds.find(ent) != null)
					{
						AcceptEntityInput(ent, "Volume", "0");
						AcceptEntityInput(ent, "Kill", "", 0.01);
					}
					else
					{
						ent.Kill();
					}
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

	m_flDestructionTime = null;
	m_hExplosionA = null;
	m_hExplosionB = null;
	m_hBridgeDestJetA = null;
	m_hBridgeDestJetB = null;
	m_hBridgeDestBusA = null;
	m_hBridgeDestBusB = null;
	m_hBridgeDestBusC = null;
	m_hBridgeDestShake = null;
	m_aBridge = null;
	m_aBridgeDestSounds = null;
	m_aBridgeSupport = null;
	m_aEntities = null;
	m_SurvivorsReactionTimer = null;
	m_PanicEventTimer = null;
}

g_tBridgeDestruction <-
{
	SpawnTrigger = function(sName,
							vecOrigin,
							vecMaxs = Vector(64, 64, 128),
							vecMins = Vector(-64, -64, 0),
							sFunction = "g_tBridgeDestruction.OnTriggerTouch",
							iType = TR_CLIENTS,
							sOutput = "OnStartTouch",
							sClass = "trigger_multiple")
	{
		local hEntity = SpawnEntityFromTable(sClass, {
			origin = vecOrigin
			spawnflags = iType
			targetname = sName
		});

		hEntity.__KeyValueFromVector("maxs", vecMaxs);
		hEntity.__KeyValueFromVector("mins", vecMins);
		hEntity.__KeyValueFromInt("solid", 2);
		hEntity.__KeyValueFromString(sOutput, format("!caller,RunScriptCode,%s()", sFunction));
		hEntity.ValidateScriptScope();

		if (iType & TR_OFF) AcceptEntityInput(hEntity, "Disable");
		return hEntity;
	}

	OnConVarChange = function(ConVar, LastValue, NewValue)
	{
		while (g_aBridges.len() > NewValue)
		{
			g_aBridges[0].ClearDestruction();
			g_aBridges.remove(0);
		}
	}

	OnTriggerTouch = function()
	{
		if (!activator) return;
		if (activator.IsSurvivor())
		{
			local sName = caller.GetName();
			if (sName.find("bridge_dest_") != null)
			{
				if (GetConVarBool(g_ConVar_AllowBridgeDest))
				{
					if (g_sMapName == sName.slice(18))
					{
						if (sName in g_tPendingBridges)
						{
							local bridge = g_tPendingBridges[sName];
							if (!bridge.StartDestruction())
							{
								bridge.ClearDestruction();
							}
							else
							{
								if (g_aBridges.len() > 0 && g_aBridges.len() + 1 > GetConVarInt(g_ConVar_BridgeDestLimit))
								{
									g_aBridges[0].ClearDestruction();
									g_aBridges.remove(0);
								}
								g_aBridges.append(bridge);
							}
							delete g_tPendingBridges[sName];
							caller.Kill();
						}
					}
				}
			}
		}
	}

	BridgeDestruction_Think = function()
	{
		if (g_aBridges.len() > 0 && GetConVarFloat(g_ConVar_BridgeDestClearTime) > 0)
		{
			for (local i = 0; i < g_aBridges.len(); i++)
			{
				if (g_aBridges[i].m_flDestructionTime != null)
				{
					if (g_aBridges[i].m_flDestructionTime + GetConVarFloat(g_ConVar_BridgeDestClearTime) < Time())
					{
						g_aBridges[i].ClearDestruction();
						g_aBridges.remove(i);
						i--;
					}
				}
			}
		}
	}

	Start = function(vecOrigin, eAngles)
	{
		if (g_aBridges.len() > 0 && g_aBridges.len() + 1 > GetConVarInt(g_ConVar_BridgeDestLimit))
		{
			g_aBridges[0].ClearDestruction();
			g_aBridges.remove(0);
		}
		local bridge = CBridgeDestruction(vecOrigin, eAngles, GetConVarBool(g_ConVar_BridgeDestDamage));
		if (!bridge.StartDestruction()) bridge.ClearDestruction();
		else g_aBridges.append(bridge);
	}

	Initialize = function(hPlayer, iDestructionType)
	{
		if (hPlayer.IsHost() && GetConVarBool(g_ConVar_AllowBridgeDest))
		{
			local vecOrigin;
			local eAngles = hPlayer.EyeAngles();
			if (g_bMode) vecOrigin = hPlayer.GetOrigin();
			else vecOrigin = hPlayer.DoTraceLine(eTrace.Type_Pos, eTrace.Distance, eTrace.Mask_Shot);
			if (iDestructionType == eDestructionType.Behind) eAngles += QAngle(0, 180, 0);
			else if (iDestructionType == eDestructionType.Left) eAngles += QAngle(0, 90, 0);
			else if (iDestructionType == eDestructionType.Right) eAngles -= QAngle(0, 90, 0);
			g_tBridgeDestruction.Start(vecOrigin, eAngles);
		}
	}

	Clear = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			for (local i = 0; i < g_aBridges.len(); i++)
			{
				g_aBridges[i].ClearDestruction();
				g_aBridges.remove(i);
				i--;
			}
		}
	}

	SwitchMode = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			sayf("[Bridge Destruction] Destruction mode: %s", g_bMode ? "camera direction" : "near the player");
			g_bMode = !g_bMode;
		}
	}

	Forward = function(hPlayer) { g_tBridgeDestruction.Initialize(hPlayer, eDestructionType.Forward); }

	Behind = function(hPlayer) { g_tBridgeDestruction.Initialize(hPlayer, eDestructionType.Behind); }

	Left = function(hPlayer) { g_tBridgeDestruction.Initialize(hPlayer, eDestructionType.Left); }

	Right = function(hPlayer) { g_tBridgeDestruction.Initialize(hPlayer, eDestructionType.Right); }
};

PrecacheEntityFromTable({classname = "ambient_generic", message = "bridge.outro03"});
PrecacheEntityFromTable({classname = "ambient_generic", message = "bridge.jetflyby03"});
PrecacheEntityFromTable({classname = "env_explosion", fireballsprite = "sprites/zerogxplode.spr"});

for (local i = 0; i < g_sBridgeDestModel.len(); i++)
{
	PrecacheEntityFromTable({classname = "prop_dynamic", model = g_sBridgeDestModel[i]});
}

g_ScriptPluginsHelper.AddScriptPlugin(g_BridgeDestruction);