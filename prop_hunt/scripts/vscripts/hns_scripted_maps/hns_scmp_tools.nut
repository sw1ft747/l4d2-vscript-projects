// Squirrel
// Prop Hunt Scripted Maps Tools

/*===============================*\
 *          Variables            *
\*===============================*/

sModel <- ""
vecAng <- Vector(0, 0, 0)
fSize <- 1.0
vecMaxs <- Vector(0, 0, 0)
vecMins <- Vector(-0, -0, 0)

g_bRevokeWall <- false;
g_bWallDebugger <- false;

/*===============================*\
 *           Tables              *
\*===============================*/

Debugger <- {};

/*===============================*\
 *           Arrays              *
\*===============================*/

g_aWallPoints <- [null, null];

if (Convars.GetFloat("developer") != -1) Convars.SetValue("developer", -1);
if (Convars.GetFloat("nb_blind") != 1) Convars.SetValue("nb_blind", 1);
SendToConsole("bind mouse4 \"script_execute 3\"");
SendToConsole("bind mouse5 \"script CreateBlocker()\"");
EntFire("env_physics_blocker", "Kill");

function CreateEntity()
{
	local hTarget = null;
	local hPlayer = null;
	while ((hTarget = Entities.FindByClassname(hTarget, "player")) != null)
	{
		if (NetProps.GetPropInt(hTarget, "m_iTeamNum") == 3)
		{
			if (hTarget.GetZombieType() == 3)
			{
				hPlayer = hTarget;
				break;
			}
		}
	}
	if (hPlayer == null)
	{
		Say(null, "Zombie hunter is not found!", false);
		return;
	}
	hPlayer.SetForwardVector(QAngle(0, 0, 0).Forward());
	if (NetProps.GetPropInt(hPlayer, "m_fEffects") != 60) NetProps.SetPropInt(hPlayer, "m_fEffects", 60);
	if (NetProps.GetPropInt(hPlayer, "m_nRenderMode") != 6) NetProps.SetPropInt(hPlayer, "m_nRenderMode", 6);
	NetProps.SetPropFloat(hPlayer, "m_flModelScale", fSize);
	local hTable =
	{
		targetname = "hns_entity_" + hPlayer.GetEntityIndex()
		origin = hPlayer.GetOrigin()
		angles = vecAng
		model = sModel
		solid = 1
		disableshadows = 1
	}
	function CreateEntityFromTable()
	{
		SpawnEntityFromTable("prop_dynamic", hTable);
	}
	EntFire(hTable.targetname, "Kill");
	EntFire("worldspawn", "RunScriptCode", "CreateEntityFromTable()", 0.1);
}

function PlayerBlocker()
{
	local hTarget = null;
	local hPlayer = null;
	while ((hTarget = Entities.FindByClassname(hTarget, "player")) != null)
	{
		if (NetProps.GetPropInt(hTarget, "m_iTeamNum") == 3)
		{
			if (hTarget.GetZombieType() == 3)
			{
				hPlayer = hTarget;
				break;
			}
		}
	}
	if (hPlayer == null) return;
	EntFire("pl_blocker_" + hPlayer.GetEntityIndex(), "Kill");
	function Blocker()
	{
		CreateInvisibleWall(hPlayer.GetEntityIndex(), hPlayer.GetOrigin(), vecMaxs, vecMins, PHYS_BLOCKER_SURVIVORS);
	}
	EntFire("worldspawn", "RunScriptCode", "SendToServerConsole(\"ent_bbox env_physics_blocker\")", 0.11);
	EntFire("worldspawn", "RunScriptCode", "Blocker()", 0.1);
}

/** Set wall vector point
 * Signature: void Debugger.SetWallPoint()
*/

function Debugger::SetWallPoint()
{
	if (!g_bWallDebugger) return;
	if (g_aWallPoints[0] == null)
	{
		Say(null, "[Debugger.SetWallPoint] First point set", false);
		EmitSoundOnClient("Buttons.snd37", Ent("!player"));
		return g_aWallPoints[0] = Ent("!player").GetOrigin();
	}
	else if (g_aWallPoints[1] == null)
	{
		Say(null, "[Debugger.SetWallPoint] Second point set", false);
		EmitSoundOnClient("Buttons.snd37", Ent("!player"));
		return g_aWallPoints[1] = Ent("!player").GetOrigin();
	}
	Say(null, "[Debugger.SetWallPoint] Reset of current points", false);
	foreach(idx, val in g_aWallPoints) g_aWallPoints[idx] = null
	Debugger.SetWallPoint();
}

/** Create a wall through the vector points
 * Signature: string Debugger.CreateWall()
*/

function Debugger::CreateWall()
{
	if (g_aWallPoints[0] == null || g_aWallPoints[1] == null || !g_bWallDebugger) return Say(null, "[Debugger.CreateWall] Not enough vector points", false);
	local vecPos = g_aWallPoints[0];
	local fPitch = g_aWallPoints[1].x - g_aWallPoints[0].x;
	local fYaw = g_aWallPoints[1].y - g_aWallPoints[0].y;
	local fRoll = g_aWallPoints[1].z - g_aWallPoints[0].z;
	if (fPitch < 0 && fYaw < 0)
	{
		fPitch *= -1;
		fYaw *= -1;
		vecPos -= Vector(fPitch, fYaw, 0);
	}
	else if (fPitch > 0 && fYaw < 0)
	{
		fYaw *= -1;
		vecPos -= Vector(0, fYaw, 0);
	}
	else if (fPitch < 0 && fYaw > 0)
	{
		fPitch *= -1;
		vecPos -= Vector(fPitch, 0, 0);
	}
	if (fRoll > 0)
	{
		sayf("Result:\nCreateInvisibleWall(\"physics_blocker\", Vector(%.03f, %.03f, %.03f), Vector(%.03f, %.03f, %.03f), Vector());", vecPos.x, vecPos.y, vecPos.z, fPitch, fYaw, fRoll);
		if (!g_bRevokeWall) CreateInvisibleWall("physics_blocker", vecPos, Vector(fPitch, fYaw, fRoll), Vector());
	}
	else
	{
		sayf("Result:\nCreateInvisibleWall(\"physics_blocker\", Vector(%.03f, %.03f, %.03f), Vector(%.03f, %.03f, 0.000), Vector(0.000, 0.000, %.03f));", vecPos.x, vecPos.y, vecPos.z, fPitch, fYaw, fRoll);
		if (!g_bRevokeWall) CreateInvisibleWall("physics_blocker", vecPos, Vector(fPitch, fYaw, 0), Vector(0, 0, fRoll));
	}
	ServerCommand("ent_bbox env_physics_blocker");
	EmitSoundOnClient("Buttons.snd4", Ent("!player"));
	foreach (idx, val in g_aWallPoints) g_aWallPoints[idx] = null;
}

/** Display a wall through the vector points
 * Signature: void Debugger.DisplayWall()
*/

function Debugger::DisplayWall()
{
	if (!g_bWallDebugger) return;
	if (g_aWallPoints[0] != null)
	{
		local vecPos = g_aWallPoints[0];
		local _vecPos = g_aWallPoints[1] != null ? g_aWallPoints[1] : Ent("!player").GetOrigin();
		local fPitch = _vecPos.x - g_aWallPoints[0].x;
		local fYaw = _vecPos.y - g_aWallPoints[0].y;
		local fRoll = _vecPos.z - g_aWallPoints[0].z;
		if (fPitch < 0 && fYaw < 0)
		{
			fPitch *= -1;
			fYaw *= -1;
			vecPos -= Vector(fPitch, fYaw, 0);
		}
		else if (fPitch > 0 && fYaw < 0)
		{
			fYaw *= -1;
			vecPos -= Vector(0, fYaw, 0);
		}
		else if (fPitch < 0 && fYaw > 0)
		{
			fPitch *= -1;
			vecPos -= Vector(fPitch, 0, 0);
		}
		DebugDrawClear();
		DebugDrawBox(vecPos, Vector(fPitch, fYaw, fRoll), Vector(), 232, 0, 232, 100, 1e6);
	}
	else DebugDrawClear();
}

/** Switch wall editor debugger
 * Signature: void Debugger.WallEditor(CBasePlayer player, string value)
*/

function Debugger::WallEditor(hPlayer, sValue)
{
	if (sValue == "wall")
	{
		if (CPlayer(hPlayer).IsHost())
		{
			if (g_bWallDebugger)
			{
				DebugDrawClear();
				Convars.SetValue("developer", 0);
				RemoveOnTickFunction("Debugger.DisplayWall");
				EmitSoundOnClient("Buttons.snd11", hPlayer);
			}
			else
			{
				Convars.SetValue("developer", -1);
				EntFire("env_physics_blocker", "Kill");
				RegisterOnTickFunction("Debugger.DisplayWall");
				ServerCommand("ent_bbox env_physics_blocker");
				ServerCommand("bind g \"script Debugger.SetWallPoint()\"");
				ServerCommand("bind h \"script Debugger.CreateWall()\"");
				sayf("[Debugger.WallEditor] Added bind to create vector points for the wall (G)");
				sayf("[Debugger.WallEditor] Added bind to create an invisible wall (H)");
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
			g_bWallDebugger = !g_bWallDebugger;
		}
	}
}

RegisterChatCommand("!debug", Debugger.WallEditor, true, true);

PlayerBlocker();
CreateEntity();