// Squirrel
// Anti-Stuck

g_flLastUnstuckTime <- array(33, 0.0);

if (!Entities.FindByName(null, "__anti_stuck_think"))
{
	local hTimer = SpawnEntityFromTable("logic_script", {targetname = "__anti_stuck_think"});
	hTimer.ValidateScriptScope();
	hTimer.GetScriptScope()["AntiStuck_Think"] <- function(){
		local hPlayer, flRadius, vecOrigin, idx;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (!hPlayer.IsDying() && !hPlayer.IsDead() && !NetProps.GetPropInt(hPlayer, "m_isGhost"))
			{
				if (NetProps.GetPropInt(hPlayer, "m_StuckLast") != 0 && g_flLastUnstuckTime[hPlayer.GetEntityIndex()] + 1.0 < Time())
				{
					flRadius = 0.0;
					vecOrigin = null;

					while (!vecOrigin)
					{
						flRadius += 10.0;
						for (idx = 0; idx < 10; idx++)
						{
							if (vecOrigin = hPlayer.TryGetPathableLocationWithin(flRadius))
								break;
						}
					}

					printl("[Anti-Stuck] Player " + hPlayer.GetPlayerName() + " has been unstucked at " + hPlayer.GetOrigin().ToKVString());

					g_flLastUnstuckTime[hPlayer.GetEntityIndex()] = Time();
					hPlayer.SetOrigin(vecOrigin + Vector(0, 0, 5));
				}
			}
		}
		DoEntFire("!self", "CallScriptFunction", "AntiStuck_Think", 0.01, self, self);
	}
	DoEntFire("!self", "CallScriptFunction", "AntiStuck_Think", 0.01, hTimer, hTimer);
}

printl("[Anti-Stuck]\nAuthor: Sw1ft\nVersion: 1.1");