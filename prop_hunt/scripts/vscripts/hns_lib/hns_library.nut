// Squirrel
// Prop Hunt Library

/*===============================*\
 *   Enumerations & Constants    *
\*===============================*/

const PROP_LIGHT_NAME = "ent_hns_prop_light"
const PROP_LIGHT_COLOR = "55 255 55"
const FILE_DATA = "prop_hunt/data.txt"
const PREFIX_PROP_LIGHT = "prop_light"
const PREFIX_PHYS_BLOCKER = "blocker_"
const PREFIX_PHYS_PROP = "prop_"
const HINT_SND_DISTANCE_SQR = 25e4
const OBSERVER_FIRST_PERSON = 0
const OBSERVER_THIRD_PERSON = 1
const VOMIT_ATTACK_DELAY = 30
const FREEZE_TIME_DELAY = 1
const MAXHEALTH = 300
const AWARD_HP = 50
const MISS_DMG = 5
const EF_NODRAW = 60
const INFECTED_TEAM = 3
const SURVIVOR_TEAM = 2
const PREPARATION_TIME = 35
const PREPARATION_ROUND = 1
const GAME_ROUND_TIME = 300
const GAME_ROUND = 2

/*===============================*\
 *      Console Variables        *
\*===============================*/

cvar("sv_vote_issue_restart_game_allowed", 0);
cvar("sv_vote_issue_change_map_later_allowed", 0);
cvar("sv_vote_issue_change_map_now_allowed", 0);
cvar("sv_vote_issue_change_mission_allowed", 0);
cvar("versus_tank_chance_finale", 0);
cvar("versus_tank_chance_intro", 0);
cvar("versus_tank_chance", 0);
cvar("hud_targetid_name_height", 1e6);
cvar("sv_disable_glow_survivors", 1);
cvar("director_no_death_check", 1);
cvar("director_no_specials", 1);
cvar("director_no_bosses", 1);
cvar("hunter_pz_claw_dmg", 0);
cvar("cl_glow_blur_scale", 0);
cvar("mp_gamemode", "Versus");
cvar("z_hunter_health", 200);
cvar("z_discard_range", 1e6);
cvar("sb_all_bot_game", 1);
cvar("z_common_limit", 0);
cvar("sb_stop", 1);

/*===============================*\
 *        Custom ConVars         *
\*===============================*/

g_ConVar_PropLightColor <- CreateConVar("sv_hns_prop_light_color", PROP_LIGHT_COLOR);
g_ConVar_VomitAttackDelay <- CreateConVar("sv_hns_vomit_attack_delay", VOMIT_ATTACK_DELAY, "float", 1.0, 300.0);
g_ConVar_HunterMaxHealth <- CreateConVar("sv_hns_hunter_max_health", MAXHEALTH, "integer", 40, 500);
g_ConVar_AwardHealth <- CreateConVar("sv_hns_award_health", AWARD_HP, "integer", 0, 500);
g_ConVar_MissDamage <- CreateConVar("sv_hns_miss_damage", MISS_DMG, "integer", 0, 500);

/*===============================*\
 *        Global Variables       *
\*===============================*/

g_bTeamController <- false;
g_bRestart <- false;
g_bIsReadyUp <- false;
g_bVoteCalled <- false;
g_bOnceHint <- true;
g_bPlayersIsReady <- false;
g_iRoundType <- null;
g_iHunterTeamCount <- 0;
g_iPropTeamCount <- 0;
g_sMapToChange <- "";

/*===============================*\
 *           Arrays              *
\*===============================*/

g_flFreezeTime <- array(MAXCLIENTS + 1, 0.0);	
g_flYaw <- array(MAXCLIENTS + 1, null);			// wtf are these arrays -_-
g_bPlayerVote <- array(MAXCLIENTS + 1, null);
g_vecMaxs <- array(MAXCLIENTS + 1, null);
g_vecMins <- array(MAXCLIENTS + 1, null);
g_vecCorrectAngles <- array(MAXCLIENTS + 1, null);
g_vecCorrectOrigin <- array(MAXCLIENTS + 1, null);
g_vecFreezeOrigin <- array(MAXCLIENTS + 1, null);
g_bIsCausedDamage <- array(MAXCLIENTS + 1, false);
g_bIsFirstTimeUse <- array(MAXCLIENTS + 1, true);
g_bIsBeginPlayer <- array(MAXCLIENTS + 1, false);
g_bVomitAttack <- array(MAXCLIENTS + 1, false);
g_bIsPropUse <- array(MAXCLIENTS + 1, false);
g_bIsPropInUse <- array(MAXENTS + 1, false);
g_bIsFrozen <- array(MAXCLIENTS + 1, false);
g_bIsReady <- array(MAXCLIENTS + 1, false);
g_iPropTarget <- array(MAXCLIENTS + 1, 0);
g_iSwitchValue <- array(MAXCLIENTS + 1, 1);
g_iPropCollisionType <- array(MAXENTS + 1, -1);

g_aModelList <-
[
	"models/props_junk/gascan001a.mdl"
	"models/props_equipment/oxygentank01.mdl"
	"models/props_junk/propanecanister001a.mdl"
];

g_aWeaponList <-
[
	"shotgun_chrome"
	"pumpshotgun"
	"autoshotgun"
	"shotgun_spas"
];

g_aSoundList <-
[
	"ScavengeSB.MatchScoreFinal"
	"Bot.StuckSound"
	"Vote.Passed"
	"Vote.Failed"
	"Vote.Created"
	"Player.StopBody"
	"Player.StopVoice"
];

/*===============================*\
 *            Tables             *
\*===============================*/

g_HnS <-
{
	time = 0.0
	hud = false
	started = false

	PropList = {}
	Commands = {}

	Data =
	{
		readyup = false
		readyup_timer = 3.0
	}

	FreezeController =
	{
		enabled = false
		freeze_props = false
		freeze_hunters = false
		unfreeze_props = false
		unfreeze_hunters = false
	}

	MapList =
	{
		c1m1 = "c1m1_hotel", c2m1 = "c2m1_highway", c2m5 = "c2m5_concert", c3m4 = "c3m4_plantation", c4m4 = "c4m4_milltown_b", c5m3 = "c5m3_cemetery",
		c1m2 = "c1m2_streets", c2m2 = "c2m2_fairgrounds", c3m1 = "c3m1_plankcountry", c4m1 = "c4m1_milltown_a", c4m5 = "c4m5_milltown_escape", c5m4 = "c5m4_quarter",
		c1m3 = "c1m3_mall", c2m3 = "c2m3_coaster", c3m2 = "c3m2_swamp", c4m2 = "c4m2_sugarmill_a", c5m1 = "c5m1_waterfront", c5m5 = "c5m5_bridge", c13m1 = "c13m1_alpinecreek",
		c1m4 = "c1m4_atrium", c2m4 = "c2m4_barns", c3m3 = "c3m3_shantytown", c4m3 = "c4m3_sugarmill_b", c5m2 = "c5m2_park", c13m2 = "c13m2_southpinestream",
		c8m1 = "c8m1_apartment", c10m1 = "c10m1_caves", c11m1 = "c11m1_greenhouse", c12m1 = "c12m1_hilltop", c7m1 = "c7m1_docks", c13m3 = "c13m3_memorialbridge",
		c8m2 = "c8m2_subway", c10m2 = "c10m2_drainage", c11m2 = "c11m2_offices", c12m2 = "c12m2_traintunnel", c7m2 = "c7m2_barge", c13m4 = "c13m4_cutthroatcreek",
		c8m3 = "c8m3_sewers", c10m3 = "c10m3_ranchhouse", c11m3 = "c11m3_garage", c12m3 = "c12m3_bridge", c7m3 = "c7m3_port", c6m1 = "c6m1_riverbank",
		c8m4 = "c8m4_interior", c10m4 = "c10m4_mainstreet", c11m4 = "c11m4_terminal", c12m4 = "c12m4_barn", c9m1 = "c9m1_alleys", c6m2 = "c6m2_bedlam",
		c8m5 = "c8m5_rooftop", c10m5 = "c10m5_houseboat", c11m5 = "c11m5_runway", c12m5 = "c12m5_cornfield", c9m2 = "c9m2_lots", c6m3 = "c6m3_port"
	}

	OnGameEvent_weapon_fire = function(tParams)
	{
		local hPlayer = GetPlayerFromUserID(tParams["userid"]);

		if (hPlayer.IsSurvivor())
		{
			function GetValue(hPlayer)
			{
				if (!g_bIsCausedDamage[hPlayer.GetEntityIndex()])
				{
					hPlayer.TakeDamage(GetConVarInt(g_ConVar_MissDamage), DMG_BUCKSHOT, hPlayer);
				}
			}

			CreateTimer((tParams["weapon"] == "melee") ? 0.3 : 0.01, g_HnS.GetValue, hPlayer);
		}
	}

	OnGameEvent_player_hurt = function(tParams)
	{
		if ("userid" in tParams)
		{
			local hVictim = GetPlayerFromUserID(tParams["userid"]);

			if (IsHunter(hVictim))
			{
				local hAttacker = GetPlayerFromUserID(tParams["attacker"]);
				if (hAttacker != null)
				{
					g_bIsCausedDamage[hAttacker.GetEntityIndex()] = true;
					CreateTimer((tParams["weapon"] == "melee") ? 0.3 : 0.01, function(idx){g_bIsCausedDamage[idx] = false}, hAttacker.GetEntityIndex());
				}
			}
		}
	}

	OnGameEvent_player_death = function(tParams)
	{
		if ("userid" in tParams)
		{
			local hVictim = GetPlayerFromUserID(tParams["userid"]);
			local hAttacker = GetPlayerFromUserID(tParams["attacker"]);

			g_bIsReady[hVictim.GetEntityIndex()] = false;

			if (IsHunter(hVictim))
			{
				RestorePlayerData(hVictim.GetEntityIndex());
			}

			if (hAttacker != null)
			{
				if (IsHunter(hVictim) && hAttacker.IsSurvivor())
				{
					local iHealth = hAttacker.GetHealth();
					local iAwardHealth = GetConVarInt(g_ConVar_AwardHealth);
					local iMaxHealth = GetConVarInt(g_ConVar_HunterMaxHealth);

					if (iHealth + iAwardHealth > iMaxHealth) hAttacker.SetHealth(iMaxHealth);
					else hAttacker.SetHealth(iHealth + iAwardHealth);

					sayf("[Prop Hunt] %s was killed by %s", hVictim.GetPlayerName(), hAttacker.GetPlayerName());
				}
			}
		}
	}

	OnGameEvent_player_disconnect = function(tParams)
	{
		local hPlayer = GetPlayerFromUserID(tParams["userid"]);

		g_bIsReady[hPlayer.GetEntityIndex()] = false;
		if (IsHunter(hPlayer)) RestorePlayerData(hPlayer.GetEntityIndex());
	}
}

/*===============================*\
 *         Functions             *
\*===============================*/

function IsHunter(hPlayer)
{
	return hPlayer.GetZombieType() == ZOMBIE_HUNTER;
}

function UpdateDataTable(tData)
{
	local sData = "{";
	foreach (key, val in tData)
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
	sData = sData + "\n}\n";
	StringToFile(FILE_DATA, sData);
}

function GetDataTable()
{
	local value = FileToString(FILE_DATA);
	if (value != null)
	{
		value = compilestring("return " + value)();
		foreach (key, val in g_HnS.Data) if (key in value) g_HnS.Data.rawset(key, value.rawget(key));
	}
	else
	{
		printl("[Prop Hunt] The data table was created in the 'left4dead2/ems/prop_hunt' folder\n");
		return;
	}
	UpdateDataTable(g_HnS.Data);
}

function RestorePlayerData(idx)
{
	local hTarget;
	if (hTarget = Entities.FindByName(null, PREFIX_PHYS_PROP + idx))
	{
		local entidx = g_iPropTarget[idx];
		local hEntity = EntIndexToHScript(g_iPropTarget[idx]);

		if (hEntity != null)
		{
			AcceptEntityInput(hEntity, "EnableMotion");
			NetProps.SetPropInt(hEntity, "m_CollisionGroup", g_iPropCollisionType[entidx]);
			hEntity.ApplyAbsVelocityImpulse(Vector(0, 0, -0.001));
			g_iPropCollisionType[entidx] = -1;
		}

		g_flYaw[idx] = null;
		g_iPropTarget[idx] = 0;
		g_bIsPropUse[idx] = false;
		g_bIsPropInUse[entidx] = false;
		g_bIsFrozen[idx] = false;
		hTarget.Kill();
	}

	if (hTarget = Entities.FindByName(null, PREFIX_PHYS_BLOCKER + idx)) hTarget.Kill();
	g_vecCorrectOrigin[idx] = null;
	g_bIsFirstTimeUse[idx] = true;
	g_bVomitAttack[idx] = false;
	g_iSwitchValue[idx] = 1;
}

function RestartGame(iTeam = null, bForceRestart = false, fTime = 5.0)
{
	if (g_bRestart || bForceRestart)
	{
		if (g_HnS.hud && g_HnS.started)
		{
			g_HnS.hud = false;
		}

		if (iTeam != null)
		{
			if (iTeam == SURVIVOR_TEAM || iTeam == INFECTED_TEAM)
			{
				local hPlayer = null;
				local hud_flags = g_HnS.HUD.Fields.restart_bg.flags;

				if (iTeam == SURVIVOR_TEAM)
				{
					g_HnS.HUD.Fields.restart_bg.dataval = "Hunters Won!";
					g_HnS.HUD.Fields.live_props.dataval = 0;
				}
				else if (iTeam == INFECTED_TEAM)
				{
					g_HnS.HUD.Fields.restart_bg.dataval = "Props Survived!";
					g_HnS.FreezeController["enabled"] = true;
					g_HnS.FreezeController["freeze_hunters"] = true;
				}

				if (hud_flags & HUD_FLAG_NOTVISIBLE)
				{
					g_HnS.HUD.Fields.restart_bg.flags = hud_flags & ~HUD_FLAG_NOTVISIBLE;
					EmitSoundToAll("ScavengeSB.MatchScoreFinal");
					g_bTeamController = false;
				}
			}
			else if (iTeam < 2 || iTeam > 3 || typeof iTeam != "integer")
			{
				printl("[RestartGame] Wrong type of Team");
				return;
			}
		}
		else
		{
			SayMsg("[Prop Hunt] Restarting...");
		}

		if (g_iRoundType != null)
		{
			local timer_flags = g_HnS.HUD.Fields.timer.flags;
			if (timer_flags & HUD_FLAG_BEEP) g_HnS.HUD.Fields.timer.flags = timer_flags & ~HUD_FLAG_BEEP;
		}

		CreateTimer(fTime, cvar, "mp_restartgame", 1);
		return;
	}
	printl("[RestartGame] Wrong game situation");
}

function HUDLoad(iTime)
{
	if (!g_HnS.hud)
	{
		g_HnS.hud = true;
	}

	if (g_HnS.hud)
	{
		g_HnS.time = Time();
		g_HnS.HUD <- {Fields = {}};

		g_HnS.HUD.Fields.timer <- {slot = HUD_MID_TOP, dataval = iTime.tofloat(), flags = HUD_FLAG_AS_TIME | HUD_FLAG_NOBG};
		g_HnS.HUD.Fields.mode_bg <- {slot = HUD_FAR_RIGHT, dataval = "Prop Hunt", flags = HUD_FLAG_NOBG, name = "Powered by AP Gaming"};
		g_HnS.HUD.Fields.live_props <- {slot = HUD_RIGHT_TOP, staticstring = "Live Props: ", dataval = 0, flags = HUD_FLAG_NOBG | HUD_FLAG_TEAM_SURVIVORS | HUD_FLAG_NOTVISIBLE};

		g_HnS.HUD.Fields.restart_bg <- {slot = HUD_SCORE_1, dataval = "", flags = HUD_FLAG_NOBG | HUD_FLAG_BLINK | HUD_FLAG_NOTVISIBLE};
		g_HnS.HUD.Fields.round_bg <- {slot = HUD_FAR_LEFT, dataval = "", flags = HUD_FLAG_NOBG};
		g_HnS.HUD.Fields.timer_bg <- {slot = HUD_MID_BOT, dataval = ""};

		if (iTime == PREPARATION_TIME)
		{
			g_HnS.HUD.Fields.round_bg.dataval = "Preparation Time";
			HUDPlace(HUD_FAR_LEFT, 0.57, -0.024, 0.2, 0.1);
		}
		else if (iTime == GAME_ROUND_TIME)
		{
			g_HnS.HUD.Fields.round_bg.dataval = "Time Left";
			HUDPlace(HUD_FAR_LEFT, 0.57, -0.024, 0.2, 0.1); // 0.357
		}

		HUDPlace(HUD_FAR_RIGHT, 0.18, -0.024, 0.25, 0.1); // 0.395
		HUDPlace(HUD_RIGHT_TOP, 0.549, -0.024, 0.2, 0.1); // 0.553
		HUDPlace(HUD_MID_BOT, 0.45, 0.012, 0.1, 0.03);
		HUDPlace(HUD_MID_TOP, 0.45, 0.01, 0.1, 0.035);

		HUDSetLayout(g_HnS.HUD);
	}
}

function HUDUpdate(iTime, bCheck = true)
{
	if (!g_HnS.hud)
	{
		g_HnS.started = false;
		return;
	}

	if (g_HnS.hud && !g_HnS.started)
	{
		g_HnS.started = true;
	}

	if (typeof iTime != "integer")
		return;

	if (g_HnS.Data.readyup && g_iRoundType == PREPARATION_ROUND && g_bIsReadyUp)
	{
		if (!g_bPlayersIsReady)
		{
			RemoveOnTickFunction("HUDUpdate", PREPARATION_TIME);
			return;
		}
	}

	if (g_HnS.started)
	{
		local flTime = iTime.tofloat() - (Time() - g_HnS.time);

		if (iTime == PREPARATION_TIME)
		{
			g_iRoundType = PREPARATION_ROUND;
		}

		if (iTime == GAME_ROUND_TIME)
		{
			g_iRoundType = GAME_ROUND;

			if (flTime <= 30.0)
			{
				local timer_flags = g_HnS.HUD.Fields.timer.flags;
				if (!(timer_flags & (HUD_FLAG_BLINK | HUD_FLAG_BEEP)))
				{
					g_HnS.HUD.Fields.timer.flags = timer_flags | HUD_FLAG_BLINK | HUD_FLAG_BEEP;
				}
				if (g_bOnceHint)
				{
					GiveHint();
					g_bOnceHint = false;
				}
			}

			local prop_counter_flags = g_HnS.HUD.Fields.live_props.flags;
			if (prop_counter_flags & HUD_FLAG_NOTVISIBLE) g_HnS.HUD.Fields.live_props.flags = prop_counter_flags & ~HUD_FLAG_NOTVISIBLE;
		}

		if (flTime <= 0.01)
		{
			RemoveOnTickFunction("HUDUpdate", iTime);
			if (bCheck)
			{
				if (iTime == GAME_ROUND_TIME)
				{
					RestartGame(INFECTED_TEAM, true);
					local hud_flags = g_HnS.HUD.Fields.timer.flags;
					if (hud_flags & HUD_FLAG_BEEP) g_HnS.HUD.Fields.timer.flags = hud_flags & ~HUD_FLAG_BEEP;
				}
				else if (iTime == PREPARATION_TIME)
				{
					StartRound();
					HUDLoad(GAME_ROUND_TIME);
					HUDUpdate(GAME_ROUND_TIME);
					CreateTimer(1.0, function(){
						if (g_iRoundType == PREPARATION_ROUND)
						{
							SayMsg("[Prop Hunt] Game aborted, wrong timer situation detected");
							RestartGame(null, true);
						}
					});
				}
			}
			return;
		}

		g_HnS.HUD.Fields.timer.dataval = flTime;
		HUDSetLayout(g_HnS.HUD);

        if (!IsOnTickFunctionRegistered("HUDUpdate", iTime))
			RegisterOnTickFunction("HUDUpdate", iTime);
	}
}

function CheckBothTeams()
{
	if (g_bRestart)
	{
		RemoveLoopFunction("CheckBothTeams");
		SayMsg("[Prop Hunt] Both teams have enough players");
		RestartGame();
		return;
	}

	local hPlayer;
	g_iHunterTeamCount = 0;
	g_iPropTeamCount = 0;

	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (!IsPlayerABot(hPlayer))
		{
			switch (NetProps.GetPropInt(hPlayer, "m_iTeamNum"))
			{
			case SURVIVOR_TEAM:
				g_iHunterTeamCount++;
				break;

			case INFECTED_TEAM:
				g_iPropTeamCount++;
				break;
			}
		}
	}

	if (g_iHunterTeamCount > 0 && g_iPropTeamCount > 0)
		g_bRestart = true;
}

function GetHunterTeamCount()
{
	local hPlayer;
	g_iHunterTeamCount = 0;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (NetProps.GetPropInt(hPlayer, "m_iTeamNum") == SURVIVOR_TEAM && !IsPlayerABot(hPlayer))
			g_iHunterTeamCount++;
	}
}

function GetPropTeamCount()
{
	local hPlayer;
	g_iPropTeamCount = 0;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (NetProps.GetPropInt(hPlayer, "m_iTeamNum") == INFECTED_TEAM && !IsPlayerABot(hPlayer))
			g_iPropTeamCount++;
	}
}

function IsHunterTeamValid()
{
	if (g_iHunterTeamCount > 0) return true;
	SayMsg("[Prop Hunt] Not enough players in Hunter Team!");
	return false;
}

function IsPropTeamValid()
{
	if (g_iPropTeamCount > 0) return true;
	SayMsg("[Prop Hunt] Not enough players in Prop Team!");
	return false;
}

function HelpList()
{
	SayMsg("[Prop Hunt]");
	SayMsg("!callvote - call vote to change map (e.g. !callvote c1m1) [Both]");
	SayMsg("!list - list of ready players (Ready Up System) [Both]");
	SayMsg("!jh - join Hunter Team [Prop Only]");
	SayMsg("!jp - join Prop Team [Hunter Only]");
	SayMsg("!hint - give a hint to the hunters [Prop]");
	SayMsg("!tp - toggle third-person mode [Prop]");
	// SayMsg("!freeze - freeze own movement [Prop]");
	SayMsg("!switch - select each prop in order [Prop]");
	SayMsg("!random - choose a random prop model [Prop]");
	SayMsg("!choose - choose a prop via the value (e.g. !choose 7) [Prop]");
	SayMsg("Press [E] to take a physic prop and get his model (Prep)");
	SayMsg("Press [ZOOM Button] to release a prop (Prep. round)");
	SayMsg("Press [ZOOM Button] to use a vomit attack (Game round)");
	SayMsg("> Don't move to freeze your prop rotation");
}

function PrecacheModels()
{
	local hPlayer;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		for (local i = 1; i <= g_HnS.PropList.len(); i++)
			hPlayer.PrecacheModel(g_HnS.PropList[i].model);
	}
	printl("[PrecacheModels] Successfully precached for all players");
}

function PrecacheSounds()
{
	local hPlayer;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		for (local i = 0; i < g_aSoundList.len(); i++)
			hPlayer.PrecacheScriptSound(g_aSoundList[i]);
	}
	printl("[PrecacheSounds] Successfully precached for all players");
}

function KillEntity(hPlayer)
{
	if (NetProps.GetPropInt(hPlayer, "m_iTeamNum") != 1)
	{
		NetProps.SetPropInt(hPlayer, "m_nRenderMode", 6);
		hPlayer.KillPlayer();
	}
}

function RemoveItemSpawn()
{
	local hEntity;
	while (hEntity = Entities.Next(hEntity))
	{
		if (hEntity.GetEntityIndex() != 0)
		{
			local sClass = hEntity.GetClassname();
			if (sClass.find("weapon_") != null && sClass.find("_spawn") != null)
			{
				hEntity.Kill();
			}
			else if (sClass.find("upgrade_") != null)
			{
				hEntity.Kill();
			}
			else if (sClass == "prop_fuel_barrel")
			{
				Entity.Kill();
			}
			else if (sClass == "prop_physics")
			{
				local sModelName = NetProps.GetPropString(hEntity, "m_ModelName");
				if (g_aModelList.find(sModelName) != null) hEntity.Kill();
			}
		}
	}
}

function CheckVoteStatus()
{
	local votes_yes = 0;
	local votes_no = 0;

	for (local i = 1; i <= MAXCLIENTS; i++)
	{
		if (g_bPlayerVote[i] != null)
		{
			if (g_bPlayerVote[i]) votes_yes++;
			else votes_no++;
		}
	}

	if (votes_yes > votes_no)
	{
		SayMsg("[Prop Hunt] Voting for map change accepted!");
		sayf("[Prop Hunt] Changing map to %s in 5 sec", g_sMapToChange);
		CreateTimer(5.0, ServerCommand, format("changelevel %s", g_sMapToChange));
		EmitSoundToAll("Vote.Passed");
	}
	else
	{
		SayMsg("[Prop Hunt] Voting has been failed, not enough votes 'Yes'");
		SayMsg("[Prop Hunt] Voting call will be available in 30 seconds");
		CreateTimer(30.0, function(){g_bVoteCalled = false});
		EmitSoundToAll("Vote.Failed");
	}

	for (local i = 1; i <= MAXCLIENTS; i++)
		g_bPlayerVote[i] = null;

	g_sMapToChange = "";
}

function GetReadyPlayers()
{
	local hPlayer;
	local iPlayersCount = 0;
	local iReadyPlayersCount = 0

	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (!IsPlayerABot(hPlayer) && hPlayer.IsAlive())
			iPlayersCount++;
	}

	for (local i = 1; i <= MAXCLIENTS; i++)
	{
		if (g_bIsReady[i]) iReadyPlayersCount++;
	}

	if (iReadyPlayersCount == iPlayersCount)
	{
		local timer = g_HnS.Data.readyup_timer;

		RemoveLoopFunction("GetReadyPlayers");
		foreach (idx, val in g_bIsReady) g_bIsReady[idx] = false;

		SayMsg("[Prop Hunt] All players are ready, the game begins");

		CreateTimer(timer / 3.0, SayMsg, "Live in 3");
		CreateTimer(timer / 3.0 * 2.0, SayMsg, "Live in 2");
		CreateTimer(timer, SayMsg, "Live in 1");

		CreateTimer(timer * 1.25, function(){
			SayMsg("The game has begun");
			g_HnS.FreezeController["freeze_props"] = false;
			g_HnS.FreezeController["unfreeze_props"] = true;
			g_bPlayersIsReady = true;
			g_bIsReadyUp = false;
			g_HnS.time = Time();
			g_HnS.FreezeController["unfreeze_props"] = false;
			RegisterOnTickFunction("HUDUpdate", PREPARATION_TIME);
		});
	}
}

function OnZoomPress(hPlayer)
{
	if (IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		local idx = hPlayer.GetEntityIndex();
		if (g_bVomitAttack[idx])
		{
			local hVictim;
			while (hVictim = Entities.FindInSphere(hVictim, hPlayer.DoTraceLine(eTrace.Type_Pos, 180.0), 60.0))
			{
				if (hVictim.IsPlayer() && hVictim.IsSurvivor() && hVictim.IsAlive())
				{
					hVictim.HitWithVomit();
				}
			}

			Say(hPlayer, format("[Prop Hunt] You used the vomit attack, recharge after %d sec", GetConVarFloat(g_ConVar_VomitAttackDelay).tointeger()), true);
			CreateTimer(GetConVarFloat(g_ConVar_VomitAttackDelay), function(idx){g_bVomitAttack[idx] = true}, idx);

			g_bVomitAttack[idx] = false;
		}
	}
}

function OnUsePress(hPlayer)
{
	if (IsHunter(hPlayer) && hPlayer.IsAlive())
		if (g_iRoundType == PREPARATION_ROUND)
			GetProp(hPlayer);
}

function GiveHint()
{
	local hPlayer;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (IsHunter(hPlayer))
		{
			local hTarget;
			while (hTarget = Entities.FindByClassname(hTarget, "player"))
			{
				if (hTarget.IsSurvivor())
				{
					if ((hTarget.GetOrigin() - hPlayer.GetOrigin()).LengthSqr() >= HINT_SND_DISTANCE_SQR)
					{
						g_HnS.Commands.Hint(hPlayer);
						break;
					}
				}
			}
		}
	}
}

function BalanceTeams()
{
	if (g_iRoundType != PREPARATION_ROUND && g_iRoundType != GAME_ROUND)
	{
		local hPlayer, iCount;
		local iHunterTeamCount = 0;
		local iPropTeamCount = 0;

		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (!IsPlayerABot(hPlayer))
			{
				if (!IsPlayerABot(hPlayer))
				{
					switch (NetProps.GetPropInt(hPlayer, "m_iTeamNum"))
					{
					case SURVIVOR_TEAM:
						iHunterTeamCount++;
						break;

					case INFECTED_TEAM:
						iPropTeamCount++;
						break;
					}
				}
			}
		}

		if (iHunterTeamCount >= 2 && iPropTeamCount == 0)
		{
			iCount = iHunterTeamCount / 2;
			for (local i = 1; i <= MAXCLIENTS; i++)
			{
				hPlayer = PlayerInstanceFromIndex(i);
				if (hPlayer != null)
				{
					if (iPropTeamCount < iCount)
					{
						NetProps.SetPropInt(hPlayer, "m_iTeamNum", INFECTED_TEAM);
						if (hPlayer.IsAlive()) KillEntity(hPlayer);
						iPropTeamCount++;
					}
					else
					{
						RemoveLoopFunction("BalanceTeams");
						break;
					}
				}
			}
		}
		else if (iHunterTeamCount == 0 && iPropTeamCount >= 2)
		{
			iCount = iPropTeamCount / 2;
			for (local i = 1; i <= MAXCLIENTS; i++)
			{
				hPlayer = PlayerInstanceFromIndex(i);
				if (hPlayer != null)
				{
					if (iHunterTeamCount < iCount)
					{
						NetProps.SetPropInt(hPlayer, "m_iTeamNum", SURVIVOR_TEAM);
						if (hPlayer.IsAlive()) KillEntity(hPlayer);
						iHunterTeamCount++;
					}
					else
					{
						RemoveLoopFunction("BalanceTeams");
						break;
					}
				}
			}			
		}
	}
}

function CreateProp(hPlayer, nIndex)
{
	if (IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		local hTarget;
		local bPhysBlocker = false;
		local idx = hPlayer.GetEntityIndex();
		local tKeyValues = {fHitBox = null, iCollisionType = null}

		tKeyValues.hProp <-
		{
			model = ""
			origin = hPlayer.GetOrigin()
			targetname = PREFIX_PHYS_PROP + idx
			disableshadows = 1
		}

		g_vecCorrectAngles[idx] = null;
		g_vecCorrectOrigin[idx] = null;

		foreach (key, val in g_HnS.PropList[nIndex])
		{
			switch (key)
			{
			case "model":
				tKeyValues.hProp.model = val;
				break;

			case "hitbox":
				tKeyValues.fHitBox = val;
				break;

			case "nocollision":
				tKeyValues.iCollisionType = (val ? 2 : 5);
				break;

			case "pos":
				g_vecCorrectOrigin[idx] = val;
				tKeyValues.hProp.origin += val;
				break;

			case "ang":
				g_vecCorrectAngles[idx] = val;
				tKeyValues.hProp.angles <- val;
				break;

			case "skin":
				tKeyValues.hProp.skin <- val;
				break;

			case "rendercolor":
				tKeyValues.hProp.rendercolor <- val;
				break;

			case "physicsblocker":
				bPhysBlocker = true;
				break;

			case "maxs":
				g_vecMaxs[idx] = val;
				break;

			case "mins":
				g_vecMins[idx] = val;
				break;
			}
		}

		if (g_bIsFirstTimeUse[idx])
		{
			NetProps.SetPropInt(hPlayer, "m_iObserverMode", OBSERVER_THIRD_PERSON);
			g_bIsFirstTimeUse[idx] = false;
		}

		if (hTarget = Entities.FindByName(null, PREFIX_PHYS_PROP + idx)) hTarget.Kill();
		if (hTarget = Entities.FindByName(null, PREFIX_PHYS_BLOCKER + idx)) hTarget.Kill();
		if (bPhysBlocker) CreateInvisibleWall(PREFIX_PHYS_BLOCKER + idx, hPlayer.GetOrigin(), g_vecMaxs[idx], g_vecMins[idx], PHYS_BLOCKER_SURVIVORS);

		NetProps.SetPropFloat(hPlayer, "m_flModelScale", tKeyValues.fHitBox);
		NetProps.SetPropInt(hPlayer, "m_CollisionGroup", tKeyValues.iCollisionType);
		NetProps.SetPropInt(hPlayer, "m_fEffects", EF_NODRAW);
		NetProps.SetPropInt(hPlayer, "m_nRenderMode", 6);

		SpawnEntityFromTable("prop_dynamic", tKeyValues.hProp);
	}
}

function GetProp(hPlayer)
{
	if (!g_bIsPropUse[hPlayer.GetEntityIndex()])
	{
		if (IsHunter(hPlayer) && hPlayer.IsAlive())
		{
			local hEntity;
			if (hEntity = hPlayer.DoTraceLine(eTrace.Type_Hit, 1000.0))
			{
				if (hEntity.GetClassname() == "prop_physics")
				{
					local sModelName = NetProps.GetPropString(hEntity, "m_ModelName");
					local aModelName = split(sModelName, "/.");
					local sName = aModelName[aModelName.len() - 2];

					for (local i = 1; i <= g_HnS.PropList.len(); i++)
					{
						if (g_HnS.PropList[i]["name"] == sName)
						{
							if (!g_bIsPropInUse[hEntity.GetEntityIndex()])
							{
								local idx = hPlayer.GetEntityIndex();
								local entidx = hEntity.GetEntityIndex();

								if (g_bIsFirstTimeUse[idx])
								{
									NetProps.SetPropInt(hPlayer, "m_iObserverMode", OBSERVER_THIRD_PERSON);
									g_bIsFirstTimeUse[idx] = false;
								}

								if (KeyInScriptScope(hEntity, PREFIX_PROP_LIGHT))
								{
									AcceptEntityInput(GetScriptScopeVar(hEntity, PREFIX_PROP_LIGHT), "Kill");
									RemoveScriptScopeKey(hEntity, PREFIX_PROP_LIGHT);
								}

								g_bIsPropUse[idx] = true;
								g_bIsPropInUse[entidx] = true;
								g_iPropTarget[idx] = entidx;
								g_flYaw[idx] = hPlayer.GetAngles().Yaw();
								g_iPropCollisionType[entidx] = NetProps.GetPropInt(hEntity, "m_CollisionGroup");

								NetProps.SetPropInt(hEntity, "m_CollisionGroup", 1);
								CreateProp(hPlayer, i);
								break;
							}
						}
					}
				}
			}
		}
	}
}

function PreparatoryRound()
{
	local hPlayer, rValue;

	RemoveItemSpawn();
	PrecacheModels();
	PrecacheSounds();

	if (IsHunterTeamValid())
	{
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (hPlayer.IsSurvivor() && hPlayer.IsAlive())
			{
				local tInv = {};
				GetInvTable(hPlayer, tInv);
				foreach (weapon in tInv) weapon.Kill();

				rValue = RandomInt(0, g_aHunterSpawnOrigin.len() - 1);
				if (SessionState["MapName"].find("m1_") != null)
				{
					CreateTimer(0.11, function(hPlayer, vecOrigin){
						if (hPlayer != null && hPlayer.IsValid())
						{
							TP(hPlayer, vecOrigin, QAngle(90.0, RandomFloat(0.0, 360.0), 0.0), null);
						}
					}, hPlayer, g_aHunterSpawnOrigin[rValue]);
				}
				else
				{
					TP(hPlayer, g_aHunterSpawnOrigin[rValue], QAngle(90.0, RandomFloat(0.0, 360.0), 0.0), null);
				}

				NetProps.SetPropFloat(hPlayer, "m_flModelScale", 1.0);
				NetProps.SetPropFloat(hPlayer, "m_flNextShoveTime", Time() + 1e6);
				NetProps.SetPropInt(hPlayer, "m_afButtonForced", IN_DUCK);

				AcceptEntityInput(hPlayer, "DisableLedgeHang");
				AcceptEntityInput(hPlayer, "SetGlowEnabled", "0");

				if (g_aHunterSpawnOrigin.len() > 1)
				{
					g_aHunterSpawnOrigin.remove(rValue);
				}

				if (!IsPlayerABot(hPlayer))
				{
					g_bIsBeginPlayer[hPlayer.GetEntityIndex()] = true;
					CreateTimer(0.05, function(hPlayer){hPlayer.GiveItem("pistol")}, hPlayer);
				}
			}
		}
		g_HnS.FreezeController["freeze_hunters"] = true;
	}

	if (IsPropTeamValid())
	{
		hPlayer = null;

		for (local i = 1; i <= g_iPropTeamCount; i++)
		{
			rValue = RandomInt(0, g_aPropSpawnOrigin.len() - 1);
			ZSpawn({type = ZOMBIE_HUNTER, pos = g_aPropSpawnOrigin[rValue]});
			if (g_aPropSpawnOrigin.len() > 1) g_aPropSpawnOrigin.remove(rValue);
		}

		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (IsHunter(hPlayer) && hPlayer.IsAlive())
			{
				local tInv = {};
				GetInvTable(hPlayer, tInv);
				foreach (weapon in tInv) weapon.Kill();

				NetProps.SetPropFloat(hPlayer, "m_flModelScale", 1.0);
				NetProps.SetPropEntity(hPlayer, "m_customAbility", null);

				TP(hPlayer, null, QAngle(0.0, RandomFloat(0.0, 360.0), 0.0), null);
			}
		}
	}

	if (g_HnS.Data.readyup)
	{
		g_HnS.FreezeController["freeze_props"] = true;
		RegisterLoopFunction("GetReadyPlayers", 0.1);
		SayMsg("[Prop Hunt] The game uses the Ready Up System\nType !ready or !unready in the chat to confirm your status");
	}

	for (local i = 1; i <= g_HnS.PropList.len(); i++)
	{
		local hEntity;
		while (hEntity = Entities.FindByModel(hEntity, g_HnS.PropList[i].model))
		{
			local tKeyValues = {
				origin = hEntity.GetOrigin() + Vector(0, 0, 10)
				targetname = PROP_LIGHT_NAME
				_light = GetConVarString(g_ConVar_PropLightColor)
				brightness = 3
				distance = 50
			};

			local hLight = SpawnEntityFromTable("light_dynamic", tKeyValues);
			SetScriptScopeVar(hEntity, PREFIX_PROP_LIGHT, hLight);
		}
	}
}

function StartRound()
{
	local hPlayer;

	if (IsHunterTeamValid())
	{
		local rValue;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (hPlayer.IsSurvivor() && hPlayer.IsAlive())
			{
				if (!IsPlayerABot(hPlayer))
				{
					rValue = RandomInt(0, g_aWeaponList.len() - 1);
					hPlayer.GiveItem(g_aWeaponList[rValue]);
					NetProps.SetPropInt(hPlayer, "m_afButtonForced", IN_WALK);

					if (g_aWeaponList[rValue] == "autoshotgun") g_aWeaponList.remove(rValue);
					if (g_aWeaponList[rValue] == "shotgun_spas") g_aWeaponList.remove(rValue);

					if (KeyInScriptScope(hPlayer, PREFIX_PROP_LIGHT)) RemoveScriptScopeKey(hPlayer, PREFIX_PROP_LIGHT);
				}
			}
		}
	}

	if (IsPropTeamValid())
	{
		local idx;
		hPlayer = null;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (IsHunter(hPlayer) && hPlayer.IsAlive())
			{
				if (!IsPlayerABot(hPlayer))
				{
					idx = hPlayer.GetEntityIndex();
					g_bVomitAttack[idx] = true;

					if (g_bIsFirstTimeUse[idx])
					{
						g_HnS.Commands.Random(hPlayer);
						Say(hPlayer, "[Prop Hunt] You didn't choose prop, you got random", true);
					}

					if (KeyInScriptScope(hPlayer, PREFIX_PROP_LIGHT)) RemoveScriptScopeKey(hPlayer, PREFIX_PROP_LIGHT);
				}
			}
		}
	}

	EntFire(PROP_LIGHT_NAME, "brightness", "0");
	EntFire(PROP_LIGHT_NAME, "Kill");
	
	g_HnS.FreezeController["freeze_hunters"] = false;
	g_HnS.FreezeController["unfreeze_hunters"] = true;

	CreateTimer(0.1, function(){
		g_HnS.FreezeController["unfreeze_hunters"] = false;
		g_HnS.FreezeController["enabled"] = false;
	});
}

function PropHunt_Think() // the main think function
{
	local hPlayer, hEntity;
	local iAliveHunters = 0;
	local iAliveProps = 0;
	local iHunterTeamCount = 0;
	local iPropTeamCount = 0;
	
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (IsPlayerABot(hPlayer) || (hPlayer.GetZombieType() != ZOMBIE_SURVIVOR && hPlayer.GetZombieType() != ZOMBIE_HUNTER)) // remove the player if he's a bot or zombie but not a hunter
		{
			hPlayer.Kill();
			continue;
		}

		local idx = hPlayer.GetEntityIndex();
		local bSurvivor = hPlayer.IsSurvivor();
		local bAlive = hPlayer.IsAlive();

		if (g_HnS.FreezeController["enabled"])
		{
			if (g_HnS.FreezeController["freeze_hunters"] && bSurvivor) NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") | FL_FROZEN);
			if (g_HnS.FreezeController["freeze_props"] && !bSurvivor) NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") | FL_FROZEN);
			if (g_HnS.FreezeController["unfreeze_hunters"] && bSurvivor) NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") & ~FL_FROZEN);
			if (g_HnS.FreezeController["unfreeze_props"] && !bSurvivor) NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") & ~FL_FROZEN);
		}

		if (g_bTeamController)
		{
			if (g_iRoundType == GAME_ROUND) // count the amount of players
			{
				switch (NetProps.GetPropInt(hPlayer, "m_iTeamNum"))
				{
				case SURVIVOR_TEAM:
					iHunterTeamCount++;
					break;

				case INFECTED_TEAM:
					iPropTeamCount++;
					break;
				}
			}
		}

		if (bSurvivor && bAlive && !IsPlayerABot(hPlayer) && !g_bIsBeginPlayer[hPlayer.GetEntityIndex()]) // kill the real player if he've spawned when the game started
		{
			KillEntity(hPlayer);
			continue;
		}

		if (g_bIsPropUse[idx]) // if the player took an object
		{
			local entidx = g_iPropTarget[idx];
			hEntity = EntIndexToHScript(g_iPropTarget[idx]);

			if (hEntity == null || !g_bIsPropInUse[g_iPropTarget[idx]] || !bAlive) // restore the data if the object invalid or the player is dead
			{
				if (hEntity != null)
				{
					AcceptEntityInput(hEntity, "EnableMotion");
					NetProps.SetPropInt(hEntity, "m_CollisionGroup", g_iPropCollisionType[entidx]);
					hEntity.ApplyAbsVelocityImpulse(Vector(0, 0, 1e-6));
					g_iPropCollisionType[entidx] = -1;
				}

				g_flYaw[idx] = null;
				g_iPropTarget[idx] = 0;
				g_bIsPropUse[idx] = false;
				g_bIsPropInUse[entidx] = false;
			}
			else if (g_bIsPropInUse[g_iPropTarget[idx]]) // otherwise
			{
				if (hPlayer.GetButtonMask() & IN_ZOOM || g_iRoundType == GAME_ROUND) // restore the data if a player wants to release the object or the main part of the game started
				{
					g_flYaw[idx] = null;
					g_iPropTarget[idx] = 0;
					g_bIsPropUse[idx] = false;
					g_bIsPropInUse[entidx] = false;

					AcceptEntityInput(hEntity, "EnableMotion");
					NetProps.SetPropInt(hEntity, "m_CollisionGroup", g_iPropCollisionType[entidx]);

					hEntity.SetOrigin(NetProps.GetPropVector(hEntity, "m_vecAbsOrigin"));
					hEntity.ApplyAbsVelocityImpulse(hPlayer.GetVelocity() * 2 + Vector(0, 0, -1e-3)); // if the player velocity equals zero then we need to add an impulse for the object to release it

					g_iPropCollisionType[entidx] = -1;
				}
				else
				{
					if (g_flYaw[idx] != hPlayer.GetAngles().Yaw()) // adjust angles of the object relative to the player
					{
						local eAngles = hEntity.GetAngles();
						eAngles.y += hPlayer.GetAngles().Yaw() - g_flYaw[idx];
						hEntity.SetAngles(eAngles);
					}

					g_flYaw[idx] = hPlayer.GetAngles().Yaw();
					hEntity.__KeyValueFromVector("origin", hPlayer.DoTraceLine(eTrace.Type_Pos, 100.0, eTrace.Mask_Player_Solid)); // use the interpolated type of teleport to move the object
				}
			}
		}

		if (bAlive)
		{
			EmitSoundOn("Player.StopBody", hPlayer); // disable the player sounds
			EmitSoundOn("Player.StopVoice", hPlayer);

			if (bSurvivor)
			{
				if (g_bTeamController)
				{
					iAliveHunters++;
				}
				if (hPlayer.GetHealth() == 1 || hPlayer.IsIncapacitated()) // kill the player and remove remaining weapons
				{
					local tInv = {};
					GetInvTable(hPlayer, tInv);
					foreach (weapon in tInv) weapon.Kill();
					KillEntity(hPlayer);
				}
			}
			else if (IsHunter(hPlayer))
			{
				if (g_bTeamController || g_iRoundType == GAME_ROUND) 
				{
					iAliveProps++; // count alive props
				}

				if (hEntity = Entities.FindByName(null, PREFIX_PHYS_PROP + idx)) // find the prop
				{
					local vecVel = hPlayer.GetVelocity();
					
					if (vecVel.x == 0 && vecVel.y == 0 && vecVel.z == 0 && NetProps.GetPropEntity(hPlayer, "m_hGroundEntity") != null) // the player is not moving and staying on the ground
					{
						if (!g_bIsFrozen[idx])
						{
							if (g_flFreezeTime[idx] <= Time())
							{
								g_bIsFrozen[idx] = true;
								g_vecFreezeOrigin[idx] = hPlayer.GetOrigin();
							}
							else
							{
								g_flFreezeTime[idx] = Time() + FREEZE_TIME_DELAY;
							}
						}
					}
					else if (g_bIsFrozen[idx])
					{
						g_bIsFrozen[idx] = false;
					}

					if (NetProps.GetPropInt(hEntity, "m_CollisionGroup") != 10)
					{
						NetProps.SetPropInt(hEntity, "m_CollisionGroup", 10);
					}

					if (g_bIsFrozen[idx]) // if the prop player frozen
					{
						if (hPlayer.GetOrigin() != g_vecFreezeOrigin[idx])
							hPlayer.SetOrigin(g_vecFreezeOrigin[idx]); // if the prop player not found in the saved position then teleport him back
					}
					else // adjust the prop position and angles
					{
						local hTarget;
						local vecPos = hPlayer.GetOrigin();
						local eAngles = hPlayer.GetAngles();

						if (hTarget = Entities.FindByName(null, PREFIX_PHYS_BLOCKER + idx)) hTarget.__KeyValueFromVector("origin", vecPos);
						if (g_vecCorrectOrigin[idx] != null) vecPos += g_vecCorrectOrigin[idx];
						if (g_vecCorrectAngles[idx] != null) eAngles += g_vecCorrectAngles[idx];

						// hEntity.__KeyValueFromVector("origin", vecPos);
						hEntity.SetOrigin(vecPos);
						hEntity.__KeyValueFromVector("angles", Vector(eAngles.x, eAngles.y, eAngles.z));
					}
				}
			}
		}

		if (NetProps.GetPropInt(hPlayer, "m_MoveType") == MOVETYPE_OBSERVER)
		{
			NetProps.SetPropInt(hPlayer, "m_fFlags", FL_CLIENT | FL_FROZEN); // freeze a spectator
		}
	}

	hEntity = null;
	while (hEntity = Entities.FindByClassname(hEntity, "witch")) hEntity.Kill();

	hEntity = null;
	while (hEntity = Entities.FindByClassname(hEntity, "infected")) hEntity.Kill();

	hEntity = null;
	while (hEntity = Entities.FindByClassname(hEntity, "survivor_death_model")) hEntity.Kill();

	if (g_iRoundType == GAME_ROUND && g_HnS.HUD.Fields.live_props.dataval != iAliveProps)
	{
		g_HnS.HUD.Fields.live_props.dataval = iAliveProps; // set the count of alive props
	}

	if (g_bTeamController)
	{
		if (g_iRoundType == GAME_ROUND && (iHunterTeamCount < 1 || iPropTeamCount < 1))
		{
			SayMsg("[Prop Hunt] Not enough players");
			g_bTeamController = false;
			RestartGame(null, true);
			return;
		}

		if (iAliveHunters < 1)
		{
			g_bTeamController = false;
			if (g_iRoundType == PREPARATION_ROUND)
			{
				SayMsg("[Prop Hunt] Game aborted, no live hunters");
				RestartGame(null, true);
			}
			else
			{
				RestartGame(INFECTED_TEAM, true);
			}
		}
		else if (iAliveProps < 1)
		{
			g_bTeamController = false;
			if (g_iRoundType == PREPARATION_ROUND)
			{
				SayMsg("[Prop Hunt] Game aborted, no live props");
				RestartGame(null, true);
			}
			else
			{
				RestartGame(SURVIVOR_TEAM, true);
			}
		}
	}
}

function AllowTakeDamage(tDamageInfo)
{
	if (tDamageInfo["Attacker"] && tDamageInfo["Victim"].IsPlayer() && tDamageInfo["Attacker"].GetClassname() == "prop_physics" && tDamageInfo["Victim"].IsSurvivor())
	{
		return false;
	}
	return true;
}

function g_HnS::OnGameplayStart()
{
	GetPropTeamCount();
	GetHunterTeamCount();

	if (IsHunterTeamValid() && IsPropTeamValid()) // both teams are ready for the game
	{
		PreparatoryRound();

		HUDLoad(PREPARATION_TIME);
		HUDUpdate(PREPARATION_TIME);

		g_HnS.FreezeController["enabled"] = true;

		RegisterOnTickFunction("PropHunt_Think");

		RegisterChatCommand("!list", g_HnS.Commands.List);
		RegisterChatCommand("!hint", g_HnS.Commands.Hint);
		// RegisterChatCommand("!freeze", g_HnS.Commands.Freeze, true);
		RegisterChatCommand("!tp", g_HnS.Commands.ThirdPerson, true);
		RegisterChatCommand("!switch", g_HnS.Commands.Switch, true);
		RegisterChatCommand("!random", g_HnS.Commands.Random, true);
		RegisterChatCommand("!ready", g_HnS.Commands.Ready, true);
		RegisterChatCommand("!unready", g_HnS.Commands.Unready, true);
		RegisterChatCommand("!choose", g_HnS.Commands.Choose, true, true);

		RegisterUserCommand("hns_choose", g_HnS.Commands.Choose, true);
		RegisterUserCommand("hns_list", g_HnS.Commands.List, false, false);
		RegisterUserCommand("hns_hint", g_HnS.Commands.Hint, false);
		RegisterUserCommand("hns_random", g_HnS.Commands.Random, false);
		RegisterUserCommand("hns_switch", g_HnS.Commands.Switch, false);
		// RegisterUserCommand("hns_freeze", g_HnS.Commands.Freeze, false);
		RegisterUserCommand("hns_tp", g_HnS.Commands.ThirdPerson, false);
		RegisterUserCommand("hns_unready", g_HnS.Commands.Unready, false);
		RegisterUserCommand("hns_ready", g_HnS.Commands.Ready, false);

		RegisterButtonListener(IN_ZOOM, "OnZoomPress", eButtonType.Pressed, eTeam.Infected);
		RegisterButtonListener(IN_USE, "OnUsePress", eButtonType.Pressed, eTeam.Infected);

		CreateTimer(0.15, function(){g_bTeamController = true});
		CreateTimer(5.0, HelpList);

		EntFire("func_button", "Kill");
		EntFire("trigger_once", "Kill");
		EntFire("trigger_multiple", "Kill");
		EntFire("info_remarkable", "Kill");
		EntFire("info_changelevel", "Kill");
		EntFire("func_simpleladder", "Kill");
		EntFire("prop_door_rotating", "Kill");
		EntFire("prop_door_rotating_checkpoint", "Kill");
		EntFire("prop_dynamic", "AddOutput", "disableshadows 1");
		EntFire("prop_physics", "AddOutput", "disableshadows 1");

		printl("[Prop Hunt] Successfully start");
		__CollectEventCallbacks(g_HnS, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
	}
	else
	{
		SayMsg("[Prop Hunt] Waiting for players...");
		SayMsg("Type !jh to choose Hunter Team");
		SayMsg("Type !jp to choose Prop Team");
		RegisterLoopFunction("CheckBothTeams", 0.15);
		CreateTimer(3.0, RegisterLoopFunction, "BalanceTeams", 1.0);
	}
}

// Prepare the data table
GetDataTable();