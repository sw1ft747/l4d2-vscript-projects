// Bridge Destruction

class CPluginBridgeDestruction extends VSLU.IScriptPlugin
{
	function Load()
	{
		VSLU.RegisterOnTickFunction("g_BridgeDestruction.BridgeDestruction_Think");
		
		g_BridgeDestruction.Precache();
		g_BridgeDestruction.ParseConfigFile();

		VSLU.RegisterChatCommand("!bd_mode", g_BridgeDestruction.SwitchMode);
		VSLU.RegisterChatCommand("!bd_clear", g_BridgeDestruction.Clear);
		VSLU.RegisterChatCommand("!bridge", g_BridgeDestruction.Forward);
		VSLU.RegisterChatCommand("!bbridge", g_BridgeDestruction.Behind);
		VSLU.RegisterChatCommand("!lbridge", g_BridgeDestruction.Left);
		VSLU.RegisterChatCommand("!rbridge", g_BridgeDestruction.Right);

		printl("[Bridge Destruction]\nAuthor: Sw1ft\nVersion: 1.2.5");
	}

	function Unload()
	{
		VSLU.RemoveOnTickFunction("g_BridgeDestruction.BridgeDestruction_Think");

		VSLU.RemoveChatCommand("!bd_mode");
		VSLU.RemoveChatCommand("!bd_clear");
		VSLU.RemoveChatCommand("!bridge");
		VSLU.RemoveChatCommand("!bbridge");
		VSLU.RemoveChatCommand("!lbridge");
		VSLU.RemoveChatCommand("!rbridge");
	}

	function OnRoundStartPost()
	{
		local hEntity, chance;

		if ((chance = g_BridgeDestruction.Settings.Chance) > 0)
		{
			foreach (map, tbl in g_BridgeDestruction.tBridgeDestParams)
			{
				if (VSLU.sMapName == map)
				{
					if (RandomInt(1, 100) <= chance)
					{
						if (VSLU.sMapName == "c9m1_alleys" || VSLU.sMapName == "c13m2_southpinestream")
						{
							if (!RandomInt(0, 1))
								continue;
						}

						local idx = ++g_BridgeDestruction.iUniquePendingBridges; idx = idx.tostring();

						if (g_BridgeDestruction.iUniquePendingBridges == 99999) g_BridgeDestruction.iUniquePendingBridges = 0;
						while (idx.len() != 5) idx = "0" + idx;

						local sName = "bridge_dest" + "_" + idx + "_" + VSLU.sMapName;

						g_BridgeDestruction.SpawnTrigger(sName, tbl["trigger_origin"], tbl["trigger_maxs"], tbl["trigger_mins"]);
						g_BridgeDestruction.tPendingBridges[sName] <- CBridgeDestruction(g_BridgeDestruction.tBridgeDestParams[VSLU.sMapName]["origin"],
																						g_BridgeDestruction.tBridgeDestParams[VSLU.sMapName]["angles"],
																						g_BridgeDestruction.Settings.AllowDamage);

						printf("> [Bridge Destruction] A trigger has been spawned for the current map at %.03f %.03f %.03f", tbl["trigger_origin"].x, tbl["trigger_origin"].y, tbl["trigger_origin"].z);
					}
				}
			}

			if (VSLU.sMapName == "c3m1_plankcountry")
			{
				if (RandomInt(0, 1) && RandomInt(1, 100) <= chance)
				{
					VSLU.CreateTimer(5.0, function(){
						local hEntity;
						if (hEntity = Entities.FindByName(null, "ferry_button"))
						{
							local idx = ++g_BridgeDestruction.iUniquePendingBridges; idx = idx.tostring();

							if (g_BridgeDestruction.iUniquePendingBridges == 99999) g_BridgeDestruction.iUniquePendingBridges = 0;
							while (idx.len() != 5) idx = "0" + idx;

							local sName = "bridge_dest" + "_" + idx + "_" + VSLU.sMapName;
							getroottable()["BD_OnFerryButtonPress"] <- function() foreach (key, val in g_BridgeDestruction.tPendingBridges) EntFire(key, "Enable");

							g_BridgeDestruction.SpawnTrigger(sName, Vector(-6958.838, 4708.850, -24.768), Vector(2601.610, 3271.359, 1301.132), Vector(), "g_BridgeDestruction.OnTriggerTouch", TR_OFF | TR_CLIENTS);
							g_BridgeDestruction.tPendingBridges[sName] <- CBridgeDestruction(Vector(-4816.808, 6674.193, -9.375), QAngle(), g_BridgeDestruction.Settings.AllowDamage);

							hEntity.ConnectOutput("OnPressed", "BD_OnFerryButtonPress");
						}
					});
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
	static m_sClassName = "CPluginBridgeDestruction";
	static m_sScriptPluginName = "Bridge Destruction";
}

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
			m_aBridge.push(SpawnEntityFromTable("prop_dynamic", {
				origin = vecOrigin
				angles = eAngles
				disableshadows = 1
				targetname = "__bridge_dest__"
				model = g_BridgeDestruction.sBridgeDestModel[i]
			}));
		}

		for (local j = 19; j < 23; j++)
		{
			m_aBridgeSupport.push(SpawnEntityFromTable("prop_dynamic", {
				origin = vecOrigin
				angles = eAngles
				disableshadows = 1
				targetname = "__bridge_dest__"
				model = g_BridgeDestruction.sBridgeDestModel[j]
			}));
		}

		m_hBridgeDestBusA = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_BridgeDestruction.sBridgeDestModel[23]
		});

		m_hBridgeDestBusB = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_BridgeDestruction.sBridgeDestModel[23]
		});
		VSLU.AcceptEntityInput(m_hBridgeDestBusB, "SetAnimation", "hold_bus2");

		m_hBridgeDestBusC = SpawnEntityFromTable("prop_dynamic", {
			origin = vecOrigin
			angles = eAngles
			disableshadows = 1
			targetname = "__bridge_dest__"
			model = g_BridgeDestruction.sBridgeDestModel[23]
		});
		VSLU.AcceptEntityInput(m_hBridgeDestBusC, "SetAnimation", "hold_bus3");

		m_aBridgeDestSounds.push(SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin
			volume = 10
			spawnflags = 1 | 16 | 32
			radius = 10000
			pitchstart = 100
			pitch = 100
			targetname = "__bridge_dest__"
			message = "bridge.outro03"
		}));

		m_aBridgeDestSounds.push(SpawnEntityFromTable("ambient_generic", {
			origin = vecOrigin
			volume = 10
			spawnflags = 1 | 16 | 32
			radius = 60000
			pitchstart = 100
			pitch = 100
			targetname = "__bridge_dest__"
			message = "bridge.jetflyby03"
		}));

		m_aBridgeDestSounds.push(SpawnEntityFromTable("ambient_generic", {
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
			model = g_BridgeDestruction.sBridgeDestModel[25]
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
			model = g_BridgeDestruction.sBridgeDestModel[25]
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
			VSLU.AcceptEntityInput(m_hExplosionA, "Explode", "", 9.0);
			VSLU.AcceptEntityInput(m_hExplosionB, "Explode", "", 9.0);

			VSLU.AcceptEntityInput(m_aBridgeDestSounds[0], "PlaySound");
			VSLU.AcceptEntityInput(m_aBridgeDestSounds[1], "PlaySound", "", 9.75);
			VSLU.AcceptEntityInput(m_aBridgeDestSounds[2], "PlaySound", "", 10.75);
			
			VSLU.AcceptEntityInput(m_aBridgeDestSounds[0], "Kill", "", 20.0);
			VSLU.AcceptEntityInput(m_aBridgeDestSounds[1], "Kill", "", 20.0);
			VSLU.AcceptEntityInput(m_aBridgeDestSounds[2], "Kill", "", 20.0);

			VSLU.AcceptEntityInput(m_hBridgeDestShake, "StartShake", "", 9.5);
			VSLU.AcceptEntityInput(m_hBridgeDestShake, "Kill", "", 15.5);

			VSLU.AcceptEntityInput(m_hBridgeDestJetA, "Enable", "", 6.0);
			VSLU.AcceptEntityInput(m_hBridgeDestJetA, "SetAnimation", "bridge_outro1", 6.0);
			VSLU.AcceptEntityInput(m_hBridgeDestJetA, "Kill", "", 17.5);

			VSLU.AcceptEntityInput(m_hBridgeDestJetB, "Enable", "", 7.0);
			VSLU.AcceptEntityInput(m_hBridgeDestJetB, "SetAnimation", "bridge_outro1", 7.0);
			VSLU.AcceptEntityInput(m_hBridgeDestJetB, "Kill", "", 17.5);

			VSLU.AcceptEntityInput(m_hBridgeDestBusA, "SetAnimation", "bus", 9.0);
			VSLU.AcceptEntityInput(m_hBridgeDestBusB, "SetAnimation", "bus2", 9.0);
			VSLU.AcceptEntityInput(m_hBridgeDestBusC, "SetAnimation", "bus3", 9.0);

			foreach (ent in m_aBridge)
			{
				VSLU.AcceptEntityInput(ent, "SetAnimation", "hit", 9.0);
			}

			if (g_BridgeDestruction.Settings.HordeDelay > 0)
			{
				if (!Entities.FindByName(null, "director"))
				{
					SpawnEntityFromTable("info_director", {targetname = "director"});
				}

				m_PanicEventTimer = VSLU.CreateTimer(g_BridgeDestruction.Settings.HordeDelay, function(){
					EntFire("director", "ForcePanicEvent", "1");
					EntFire("@director", "ForcePanicEvent", "1");
				});
			}

			m_SurvivorsReactionTimer = VSLU.CreateTimer(14.0, function(){
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
							if ( hPlayer.IsSurvivor() && VSLU.IsEntityAlive(hPlayer) && !hPlayer.IsIncapacitated() )
							{
								aL4D1Survivors.push(hPlayer);
							}
						}
					}

					for (local j = 0; j < aL4D2SurvivorsNames.len(); j++)
					{
						if ( hPlayer = Entities.FindByName(null, "!" + aL4D2SurvivorsNames[j]) )
						{
							if ( hPlayer.IsSurvivor() && VSLU.IsEntityAlive(hPlayer) && !hPlayer.IsIncapacitated() )
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
							model = g_BridgeDestruction.sBridgeDestModel[24]
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
			});

			m_flDestructionTime = Time() + 20.0;

			return true;
		}

		return false;
	}

	function ClearDestruction()
	{
		if (m_hExplosionA) VSLU.AcceptEntityInput(m_hExplosionA, "Kill");
		if (m_hExplosionB) VSLU.AcceptEntityInput(m_hExplosionB, "Kill");

		foreach (ent in m_aEntities)
		{
			if (ent)
			{
				if (ent.IsValid())
				{
					if (m_aBridgeDestSounds.find(ent) != null)
					{
						VSLU.AcceptEntityInput(ent, "Volume", "0");
						VSLU.AcceptEntityInput(ent, "Kill", "", 0.01);
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
			foreach (idx, timer in VSLU.aTimers)
			{
				if (m_SurvivorsReactionTimer.GetIdentifier() == timer.GetIdentifier())
				{
					VSLU.aTimers.remove(idx);
					break;
				}
			}
		}
		
		if (m_PanicEventTimer)
		{
			foreach (idx, timer in VSLU.aTimers)
			{
				if (m_PanicEventTimer.GetIdentifier() == timer.GetIdentifier())
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

g_PluginBridgeDestruction <- CPluginBridgeDestruction();

__bd_fun_shit_mode__ <- true;
__fun_shit_last_survivors_reaction__ <- 0.0;

g_BridgeDestruction <-
{
	iUniquePendingBridges = 0

	aBridges = []

	tDestDir =
	{
		Forward = 0
		Behind = 1
		Left = 2
		Right = 3
	}

	sBridgeDestModel =
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
	]

	tPendingBridges = {}

	tBridgeDestParams =
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
	}

	Settings =
	{
		Allow = true
		Chance = 90
		ClearTime = 0.0
		AllowDamage = true
		Limit = 10
		HordeDelay = 10.5
	}
	
    ParseConfigFile = function()
    {
        this = ::g_BridgeDestruction;

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
			StringToFile("bridge_destruction/settings.nut", sData);
		}

		if (tData = FileToString("bridge_destruction/settings.nut"))
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

				error("[Bridge Destruction] " + exception + "\n");
				error("[Bridge Destruction] Failed to parse the config file\n");
			}
		}
		else
		{
			SerializeSettings();

			error("[Bridge Destruction] Missing the config file, created a new one\n");
		}
    }

	Precache = function()
	{
		this = ::g_BridgeDestruction;

		PrecacheEntityFromTable( { classname = "ambient_generic", message = "bridge.outro03" } );
		PrecacheEntityFromTable( { classname = "ambient_generic", message = "bridge.jetflyby03" } );
		PrecacheEntityFromTable( { classname = "env_explosion", fireballsprite = "sprites/zerogxplode.spr" } );

		for (local i = 0; i < g_BridgeDestruction.sBridgeDestModel.len(); ++i)
		{
			PrecacheEntityFromTable( { classname = "prop_dynamic", model = g_BridgeDestruction.sBridgeDestModel[i] } );
		}
	}

	SpawnTrigger = function(sName,
							vecOrigin,
							vecMaxs = Vector(64, 64, 128),
							vecMins = Vector(-64, -64, 0),
							sFunction = "g_BridgeDestruction.OnTriggerTouch",
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

		if (iType & TR_OFF) VSLU.AcceptEntityInput(hEntity, "Disable");
		return hEntity;
	}

	OnTriggerTouch = function()
	{
		if ( activator && activator.IsSurvivor() )
		{
			local sName = caller.GetName();
			if (sName.find("bridge_dest_") != null)
			{
				if (g_BridgeDestruction.Settings.Allow)
				{
					if (VSLU.sMapName == sName.slice(18))
					{
						if (sName in g_BridgeDestruction.tPendingBridges)
						{
							local bridge = g_BridgeDestruction.tPendingBridges[sName];

							if (!bridge.StartDestruction())
							{
								bridge.ClearDestruction();
							}
							else
							{
								if (g_BridgeDestruction.aBridges.len() > 0 && g_BridgeDestruction.aBridges.len() + 1 > g_BridgeDestruction.Settings.Limit)
								{
									g_BridgeDestruction.aBridges[0].ClearDestruction();
									g_BridgeDestruction.aBridges.remove(0);
								}
								g_BridgeDestruction.aBridges.push(bridge);
							}

							delete g_BridgeDestruction.tPendingBridges[sName];
							caller.Kill();
						}
					}
				}
			}
		}
	}

	BridgeDestruction_Think = function()
	{
		this = ::g_BridgeDestruction;

		if (aBridges.len() > 0 && g_BridgeDestruction.Settings.ClearTime > 0)
		{
			for (local i = 0; i < aBridges.len(); i++)
			{
				if (aBridges[i].m_flDestructionTime != null)
				{
					if (aBridges[i].m_flDestructionTime + g_BridgeDestruction.Settings.ClearTime < Time())
					{
						aBridges[i].ClearDestruction();
						aBridges.remove(i);
						i--;
					}
				}
			}
		}
	}

	Start = function(vecOrigin, eAngles)
	{
		this = ::g_BridgeDestruction;

		if (aBridges.len() > 0 && aBridges.len() + 1 > g_BridgeDestruction.Settings.Limit)
		{
			aBridges[0].ClearDestruction();
			aBridges.remove(0);
		}

		local bridge = CBridgeDestruction(vecOrigin, eAngles, g_BridgeDestruction.Settings.AllowDamage);

		if (!bridge.StartDestruction())
			bridge.ClearDestruction();
		else
			aBridges.push(bridge);
	}

	Initialize = function(hPlayer, iDestructionType)
	{
		if (VSLU.Player.IsHost(hPlayer) && g_BridgeDestruction.Settings.Allow)
		{
			local vecOrigin;
			local eAngles = hPlayer.EyeAngles();

			if (__bd_fun_shit_mode__)
			{
				vecOrigin = hPlayer.GetOrigin();
			}
			else
			{
				local tTraceResult = {};
				VSLU.Player.TraceLine(hPlayer, tTraceResult);

				vecOrigin = tTraceResult["pos"];
			}

			if (iDestructionType == g_BridgeDestruction.tDestDir.Behind)
				eAngles += QAngle(0, 180, 0);
			else if (iDestructionType == g_BridgeDestruction.tDestDir.Left)
				eAngles += QAngle(0, 90, 0);
			else if (iDestructionType == g_BridgeDestruction.tDestDir.Right)
				eAngles -= QAngle(0, 90, 0);

			g_BridgeDestruction.Start(vecOrigin, eAngles);
		}
	}

	Clear = function(hPlayer, sArgs)
	{
		this = ::g_BridgeDestruction;

		if ( VSLU.Player.IsHost(hPlayer) )
		{
			for (local i = 0; i < aBridges.len(); i++)
			{
				aBridges[i].ClearDestruction();
				aBridges.remove(i);
				i--;
			}
		}
	}

	SwitchMode = function(hPlayer, sArgs)
	{
		if ( VSLU.Player.IsHost(hPlayer) )
		{
			VSLU.SendMessage(hPlayer, "[Bridge Destruction] Destruction mode: %s", __bd_fun_shit_mode__ ? "camera direction" : "near the player");
			__bd_fun_shit_mode__ = !__bd_fun_shit_mode__;
		}
	}

	Forward = function(hPlayer, sArgs) { g_BridgeDestruction.Initialize(hPlayer, g_BridgeDestruction.tDestDir.Forward); }

	Behind = function(hPlayer, sArgs) { g_BridgeDestruction.Initialize(hPlayer, g_BridgeDestruction.tDestDir.Behind); }

	Left = function(hPlayer, sArgs) { g_BridgeDestruction.Initialize(hPlayer, g_BridgeDestruction.tDestDir.Left); }

	Right = function(hPlayer, sArgs) { g_BridgeDestruction.Initialize(hPlayer, g_BridgeDestruction.tDestDir.Right); }
};

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginBridgeDestruction);