// Squirrel
// L4D Style Ragdolls Repulsion

__tL4DStyleRagdollsRepulsion <-
{
	GetBoneID = function(iType, nRagdollBone)
	{
		switch (iType)
		{
		case 1: // smoker
			switch (nRagdollBone)
			{
			case 0:		return 0;
			case 2:		return 12;
			case 5:		return 16;
			case 6:		return 17;
			case 7:		return 18;
			case 8:		return 20;
			case 9:		return 21;
			case 10:	return 22;
			case 11:	return 6;
			case 12:	return 7;
			case 13:	return 8;
			case 14:	return 2;
			case 15:	return 3;
			case 16:	return 4;
			case 17:	bHeadshotted = true; return 14;
			}
			break;

		case 3: // hunter
			switch (nRagdollBone)
			{
			case 2:		return 12;
			case 0:		return 0;
			case 1:		return 10;
			case 5:		return 16;
			case 6:		return 17;
			case 7:		return 18;
			case 8:		return 35;
			case 9:		return 36;
			case 10:	return 37;
			case 11:	return 6;
			case 12:	return 7;
			case 13:	return 8;
			case 14:	return 2;
			case 15:	return 3;
			case 16:	return 4;
			case 17:	bHeadshotted = true; return 14;
			}
			break;

		case 5: // jockey
			switch (nRagdollBone)
			{
			case 0:		return 0;
			case 1:		return 50;
			case 2:		return 51;
			case 3:		return 46;
			case 4:		return 47;
			case 5:		return 2;
			case 6:		return 3;
			case 7:		return 5;
			case 8:		return 9;
			case 8:		return 9;
			case 9:		return 10;
			case 10:	return 11;
			case 11:	return 28;
			case 12:	return 29;
			case 13:	return 30;
			case 14:	bHeadshotted = true; return 7;
			}
			break;

		case 6: // charger
			switch (nRagdollBone)
			{
			case 0:		return 0;
			case 1:		return 12;
			case 2:		return 13;
			case 3:		return 9;
			case 4:		return 10;
			case 5:		return 11;
			case 6:		return 2;
			case 7:		return 4;
			case 8:		return 6;
			case 9:		return 18;
			case 10:	return 19;
			case 12:	return 7;
			case 13:	return 8;
			case 15:	return 14;
			case 14:	bHeadshotted = true; return 15;
			}
			break;
		}
		return -1;
	}

	ParseConfigFile = function()
	{
		local tData;

		local function Clamp(n, min, max)
		{
			return n < min ? min : (n > max ? max : n);
		}

		local function SerializeSettings()
		{
			local sData = "{";
			foreach (key, val in ::__tL4DStyleRagdollsRepulsion.Settings)
			{
				switch (typeof val)
				{
				case "string":
					sData = format("%s\n\t%s = \"%s\"", sData, key, val);
					break;
				
				case "float":
					sData = format("%s\n\t%s = %.2f", sData, key, val);
					break;
				
				case "integer":
				case "bool":
					sData = sData + "\n\t" + key + " = " + val;
					break;
				}
			}
			sData = sData + "\n}";
			StringToFile("ragdolls_repulsion/settings.cfg", sData);
		}

		if (tData = FileToString("ragdolls_repulsion/settings.cfg"))
		{
			try {
				tData = compilestring("return " + tData)();
				foreach (key, val in Settings)
				{
					if (tData.rawin(key))
					{
						Settings[key] = ((key == "Force") ? Clamp(tData[key], 0.0, 40000.0) : tData[key]);
					}
				}
			}
			catch (error) {
				SerializeSettings();
			}
		}
		else
		{
			SerializeSettings();
		}
	}

	NormalizeVector = function(vec)
	{
		return vec.Scale(1.0 / vec.Length());
	}

	OnGameEvent_player_death = function(tParams)
	{
		if ("userid" in tParams && "attacker" in tParams)
		{
			local hPlayer;
			if (hPlayer = GetPlayerFromUserID(tParams["userid"]))
			{
				local hAttacker = GetPlayerFromUserID(tParams["attacker"]);
				local iType = hPlayer.GetZombieType();

				if (!hAttacker || !hAttacker.IsSurvivor() || hPlayer.IsSurvivor() || iType == 4 || iType == 8) // spitter or tank
					return;

				switch (tParams["weapon"])
				{
				case "pipe_bomb":
				case "inferno":
				case "entityflame":
				case "prop_fuel_barrel":
				case "grenade_launcher_projectile":
					return;
				}
				
				local hRagdoll;
				if (hRagdoll = NetProps.GetPropEntity(hPlayer, "m_hRagdoll"))
				{
					bHeadshotted = false;

					local flForce = Settings.Force;
					local nBoneID = GetBoneID(iType, NetProps.GetPropInt(hRagdoll, "m_nForceBone"));

					if (Settings.HeadshotOnly && !bHeadshotted)
						return;

					local vecHullOrigin = hPlayer.GetOrigin();
					local vecBoneOrigin = hPlayer.GetBoneOrigin(nBoneID);
					local vecPos = (nBoneID != -1 && (vecBoneOrigin - vecHullOrigin).LengthSqr() < 4e4) ? vecBoneOrigin : (vecHullOrigin + (hPlayer.EyePosition() - vecHullOrigin) * 0.5);

					NetProps.SetPropEntity(hRagdoll, "m_hPlayer", null);

					if (iType == 6) // charger
					{
						flForce *= 0.5;
						hRagdoll.SetOrigin(hRagdoll.GetOrigin() + Vector(0, 0, 10));
					}
					
					NetProps.SetPropVector(hRagdoll, "m_vecForce", NormalizeVector(vecPos - hAttacker.EyePosition()) * flForce);
				}
			}
		}
	}

	Settings =
	{
		HeadshotOnly = false
		Force = 20000.0
	}

	bHeadshotted = false
}

__tL4DStyleRagdollsRepulsion.ParseConfigFile();

__CollectEventCallbacks(__tL4DStyleRagdollsRepulsion, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

printl("[L4D Style Ragdolls Repulsion]\nAuthor: Sw1ft\nVersion: 1.0.2");