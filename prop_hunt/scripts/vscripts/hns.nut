// Squirrel
// Prop Hunt
// Powered by AP

/*===============================*\
 *        Library & Utils        *
\*===============================*/

IncludeScript("lib_utils");
IncludeScript("hns_lib/hns_library");
IncludeScript("hns_lib/hns_cmds");

/*===============================*\
 *        Global Variables       *
\*===============================*/

g_bRestartRound <- false;
g_bRestartActivate <- false;

/*===============================*\
 *           Arrays              *
\*===============================*/

g_aScriptedMaps <-
[
	"c1m1_hotel"
	"c1m2_streets"
	"c1m3_mall"
	"c2m1_highway"
	"c2m2_fairgrounds"
	"c2m4_barns"
	"c3m1_plankcountry"
	"c3m3_shantytown"
	"c3m4_plantation"
	"c4m1_milltown_a"
	"c5m1_waterfront"
	"c5m3_cemetery"
];

/*===============================*\
 *         Functions             *
\*===============================*/

function PrintSupportedMaps()
{
	local str;
	local sMsg = "Supported Maps\n"

	foreach (val in g_aScriptedMaps)
	{
		if (val.find("_") != null)
		{
			str = split(val, "_");
			sMsg += str[0] + " ";
		}
		else
		{
			sMsg += val + " ";
		}
	}

	SayMsg(sMsg);
	SayMsg("Use !callvote command to change a specific map\nFor example: !callvote c1m2");
}

function ExecuteScriptedMaps()
{
	if (g_aScriptedMaps.find(SessionState["MapName"]) != null)
	{
		IncludeScript("hns_scripted_maps/" + SessionState["MapName"], getroottable());
		SendToServerConsole(format("echo [Prop Hunt] Loaded %s scripted map", SessionState["MapName"]));
		g_HnS.OnGameplayStart();
	}
	else
	{
		SayMsg("[Prop Hunt] No scripted maps were found for the map");
		CreateTimer(3.0, PrintSupportedMaps);
	}
}

function OnGameplayStart()
{
	local hPlayer;
	local iCount = 0;

	IncludeScript("hns_lib/skipintro");

	printl("[Prop Hunt]\nAuthor: Sw1ft\nVersion: 2.0");

	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (!IsPlayerABot(hPlayer))
			iCount++;
	}

	if (g_HnS.Data.readyup)
	{
		g_bIsReadyUp = true;
	}

	if (iCount == 0)
	{
		g_bRestartActivate = true;
	}
	else
	{
		if (NetProps.GetPropInt(Ent("!player"), "m_fFlags") & FL_FROZEN) g_bRestartActivate = true;
		else ExecuteScriptedMaps();
	}
}

function OnPlayerSpawn(tParams)
{
	if (g_bRestartRound)
	{
		SayMsg("[Prop Hunt] Script Preparation");
		RestartGame(null, true);
		g_bRestartRound = false;
		g_bRestartActivate = false;
	}
}

function OnPlayerActivate(tParams)
{
	if (g_bRestartActivate)
		g_bRestartRound = true;
}

/*===============================*\
 *            Hooks              *
\*===============================*/

HookEvent("player_spawn", OnPlayerSpawn);
HookEvent("player_activate", OnPlayerActivate);