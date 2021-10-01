// Squirrel
// Auto Bunnyhop

g_sTableDataKey <- "V6tElp";

if (!("g_bAutoBunnyhopHostOnly" in this)) g_bAutoBunnyhopHostOnly <- false;
if (!("g_bHostAutoBunnyhop" in this)) g_bHostAutoBunnyhop <- false;
if (!("g_bAutoBunnyhop" in this)) g_bAutoBunnyhop <- array(33, true);

__tAutoBunnyhop <-
{
	ArrayToTable = function(arr)
	{
		if (typeof arr == "array")
		{
			local tbl = {};

			foreach (idx, val in arr)
				tbl.rawset(idx, val);

			return tbl;
		}
	}

	TableToArray = function(tbl)
	{
		if (typeof tbl == "table")
		{
			local arr = [];

			if (tbl.len() > 0)
			{
				for (local i = 0; i < tbl.len(); i++)
				{
					if (tbl.rawin(i.tostring()))
						arr.push(tbl[i.tostring()]);
				}
			}

			return arr;
		}
	}

	IsHost = function(hPlayer)
	{
		local hGameRules, hPlayerManager;
		if ((hGameRules = Entities.FindByClassname(null, "terror_gamerules")) && (hPlayerManager = Entities.FindByClassname(null, "terror_player_manager")))
		{
			return NetProps.GetPropIntArray(hPlayerManager, "m_listenServerHost", hPlayer.GetEntityIndex()) && !NetProps.GetPropInt(hGameRules, "m_bIsDedicatedServer");
		}
		return false;
	}

	GetHostPlayer = function()
	{
		local hPlayerManager;
		if (hPlayerManager = Entities.FindByClassname(null, "terror_player_manager"))
		{
			local idx = 1;
			while (idx < NetProps.GetPropArraySize(hPlayerManager, "m_listenServerHost"))
			{
				if (NetProps.GetPropIntArray(hPlayerManager, "m_listenServerHost", idx))
				{
					return PlayerInstanceFromIndex(idx);
				}
				idx++;
			}
		}
	}

	OnGameEvent_player_say = function(tParams)
	{
		local hPlayer;
		if (hPlayer = GetPlayerFromUserID(tParams["userid"]))
		{
			local idx = hPlayer.GetEntityIndex();
			local sText = tParams["text"].tolower();

			switch (sText)
			{
			case "!bhop":
			case "/bhop":
				if (g_bAutoBunnyhop[idx])
				{
					NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", NetProps.GetPropInt(hPlayer, "m_afButtonDisabled") & ~2);
					EmitSoundOnClient("Buttons.snd11", hPlayer);
				}
				else
				{
					EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
				}
				g_bAutoBunnyhop[idx] = !g_bAutoBunnyhop[idx];
				break;
			
			case "!bhop2":
			case "/bhop2":
				if (IsHost(hPlayer))
				{
					if (g_bHostAutoBunnyhop)
					{
						SendToServerConsole("-alt1");
						SendToServerConsole("bind SPACE +jump");
						EmitSoundOnClient("Buttons.snd11", hPlayer);
					}
					else
					{
						SendToServerConsole("alias +bhop2 \"+jump;+alt1\"");
						SendToServerConsole("alias -bhop2 \"-jump;-alt1\"");
						SendToServerConsole("bind SPACE +bhop2");
						EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
					}
					g_bHostAutoBunnyhop = !g_bHostAutoBunnyhop;
				}
				break;
			
			case "!bhop_usage":
			case "/bhop_usage":
				if (IsHost(hPlayer))
				{
					if (g_bAutoBunnyhopHostOnly)
					{
						ClientPrint(hPlayer, 3, "\x04[Auto Bunnyhop]\x03 Allowed\x04 to use by clients");
						EmitSoundOnClient("Buttons.snd11", hPlayer);
					}
					else
					{
						ClientPrint(hPlayer, 3, "\x04[Auto Bunnyhop]\x03 Forbidden\x04 to use by clients");
						EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
					}
					g_bAutoBunnyhopHostOnly = !g_bAutoBunnyhopHostOnly;
				}
				break;
			}
		}
	}

	OnGameEvent_round_start = function(tParams)
	{
		local arr = {};

		RestoreTable(g_sTableDataKey, arr);
		arr = TableToArray(arr);

		if (arr.len() == 33)
		{
			foreach (idx, val in arr)
			{
				if (val == 1) arr[idx] = true;
				else arr[idx] = false;
			}
			g_bAutoBunnyhop = arr;
		}
	}

	OnGameEvent_map_transition = function(tParams)
	{
		SaveTable(g_sTableDataKey, ArrayToTable(g_bAutoBunnyhop));
	}

	OnGameEvent_player_disconnect = function(tParams)
	{
		g_bAutoBunnyhop[GetPlayerFromUserID(tParams["userid"]).GetEntityIndex()] = true;
	}
};

if (!Entities.FindByName(null, "__auto_bunnyhop_think"))
{
	local hTimer = SpawnEntityFromTable("logic_script", {targetname = "__auto_bunnyhop_think"});

	hTimer.ValidateScriptScope();
	hTimer.GetScriptScope()["AutoBunnyhop_Think"] <- function(){
		local hPlayer, buttons;
		if (hPlayer = __tAutoBunnyhop.GetHostPlayer())
		{
			if (g_bHostAutoBunnyhop && NetProps.GetPropInt(hPlayer, "m_nButtons") & (1 << 14) && !hPlayer.IsIncapacitated() && !hPlayer.IsDead() && !hPlayer.IsDying())
			{
				if (!NetProps.GetPropEntity(hPlayer, "m_hGroundEntity") && NetProps.GetPropInt(hPlayer, "m_MoveType") != 9)
				{
					SendToServerConsole("-jump");
				}
				else
				{
					SendToServerConsole("+jump");
					EntFire("worldspawn", "RunScriptCode", "SendToServerConsole(\"-jump\")", 0.01);
				}
			}
			hPlayer = null;
		}

		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (!hPlayer.IsIncapacitated() && !hPlayer.IsDead() && !hPlayer.IsDying())
			{
				if (g_bAutoBunnyhop[hPlayer.GetEntityIndex()])
				{
					if (g_bAutoBunnyhopHostOnly && !__tAutoBunnyhop.IsHost(hPlayer))
					{
						continue;
					}

					buttons = NetProps.GetPropInt(hPlayer, "m_afButtonDisabled");

					if (!NetProps.GetPropEntity(hPlayer, "m_hGroundEntity") && NetProps.GetPropInt(hPlayer, "m_MoveType") != 9)
					{
						NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", buttons | 2);
						continue;
					}

					NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", buttons & ~2);
				}
			}
		}

		DoEntFire("!self", "CallScriptFunction", "AutoBunnyhop_Think", 0.01, self, self);
	}
	DoEntFire("!self", "CallScriptFunction", "AutoBunnyhop_Think", 0.01, hTimer, hTimer);
}

__CollectEventCallbacks(__tAutoBunnyhop, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

printl("[Auto Bunnyhop]\nAuthor: Sw1ft\nVersion: 2.1.1");