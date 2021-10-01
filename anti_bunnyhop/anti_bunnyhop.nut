// Squirrel
// Anti-Bunnyhop

g_flPlayerMaxGroundSpeed <- 220.0;
g_flPlayerMaxAdrenalineSpeed <- 260.0;
g_flPlayerMaxGroundSpeedSqr <- g_flPlayerMaxGroundSpeed * g_flPlayerMaxGroundSpeed;
g_flPlayerMaxAdrenalineSpeedSqr <- g_flPlayerMaxAdrenalineSpeed * g_flPlayerMaxAdrenalineSpeed;

g_bInAir <- array(33, false);
g_flAdrenalineDuration <- array(33, 0.0);

__tAntiBunnyhop <-
{
	OnGameEvent_adrenaline_used = function(tParams)
	{
		g_flAdrenalineDuration[GetPlayerFromUserID(tParams["userid"]).GetEntityIndex()] = Time() + Convars.GetFloat("adrenaline_duration").tofloat();
	}
}

function __IsAttackedBySI(hPlayer)
{
	if (hPlayer.IsSurvivor())
		if (NetProps.GetPropEntity(hPlayer, "m_pounceAttacker") ||
			NetProps.GetPropEntity(hPlayer, "m_jockeyAttacker") ||
			NetProps.GetPropEntity(hPlayer, "m_pummelAttacker") ||
			NetProps.GetPropEntity(hPlayer, "m_carryAttacker") ||
			NetProps.GetPropEntity(hPlayer, "m_tongueOwner"))
			return true;
	return false;
}

if (!Entities.FindByName(null, "__anti_bunnyhop_think"))
{
	local hTimer = SpawnEntityFromTable("logic_script", {targetname = "__anti_bunnyhop_think"});
	hTimer.ValidateScriptScope();
	hTimer.GetScriptScope()["AntiBunnyhop_Think"] <- function(){
		local hPlayer, vecHorizontalVel, idx;

		if (Convars.GetFloat("adrenaline_run_speed").tofloat() != g_flPlayerMaxAdrenalineSpeed)
		{
			g_flPlayerMaxAdrenalineSpeed = Convars.GetFloat("adrenaline_run_speed").tofloat();
			g_flPlayerMaxAdrenalineSpeedSqr = g_flPlayerMaxAdrenalineSpeed * g_flPlayerMaxAdrenalineSpeed;
		}

		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (!hPlayer.IsDead() && !hPlayer.IsDying() && !hPlayer.IsIncapacitated())
			{
				if (__IsAttackedBySI(hPlayer))
					continue;

				idx = hPlayer.GetEntityIndex();

				if (NetProps.GetPropEntity(hPlayer, "m_hGroundEntity"))
				{
					if (g_bInAir[idx])
					{
						vecHorizontalVel = hPlayer.GetVelocity(); vecHorizontalVel.z = 0.0;

						if (vecHorizontalVel.LengthSqr() > (g_flAdrenalineDuration[idx] > Time() ? g_flPlayerMaxAdrenalineSpeedSqr : g_flPlayerMaxGroundSpeedSqr))
							hPlayer.SetVelocity(vecHorizontalVel.Scale(1.0 / vecHorizontalVel.Length()) * (g_flAdrenalineDuration[idx] > Time() ? g_flPlayerMaxAdrenalineSpeed : g_flPlayerMaxGroundSpeed));

						g_bInAir[idx] = false;
					}
				}
				else if (!g_bInAir[idx])
				{
					g_bInAir[idx] = true;
				}
			}
		}
		
		DoEntFire("!self", "CallScriptFunction", "AntiBunnyhop_Think", 0.01, self, self);
	}
	DoEntFire("!self", "CallScriptFunction", "AntiBunnyhop_Think", 0.01, hTimer, hTimer);
}

__CollectEventCallbacks(__tAntiBunnyhop, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

printl("[Anti-Bunnyhop]\nAuthor: Sw1ft\nVersion: 1.1");