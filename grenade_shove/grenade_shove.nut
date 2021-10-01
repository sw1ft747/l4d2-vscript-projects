// Squirrel
// Grenade Shove

const VOMITJAR_MAX_USES = 5
const EXTINGUISH_TIME = 5.0

enum ePipeBomb
{
	flDuration = 6.0
	flBeepMinInterval = 0.1
	flInitialBeepInterval = 0.5
	flIntervalDelta = 0.025
}

g_flExtinguishTime <- array(33, 0.0);

__tGrenadeShove <-
{
	ParseConfigFile = function()
	{
		local tData;

		local function SerializeSettings()
		{
			local sData = "{";

			foreach (key, val in ::__tGrenadeShove.Settings)
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
			StringToFile("grenade_shove/settings.cfg", sData);
		}

		if (tData = FileToString("grenade_shove/settings.cfg"))
		{
			try {
				tData = compilestring("return " + tData)();
				foreach (key, val in Settings)
				{
					if (tData.rawin(key))
					{
						Settings[key] = tData[key];
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

	OnGameEvent_round_start = function(tParams)
	{
		::__tGrenadeShove.ParseConfigFile();
	}

	OnGameEvent_entity_shoved = function(tParams)
	{
		local hEntity;

		if (hEntity = EntIndexToHScript(tParams["entityid"]))
		{
			local sClass = hEntity.GetClassname();

			if (sClass == "infected" || sClass == "witch")
			{
				local hAttacker = GetPlayerFromUserID(tParams["attacker"]);
				local hWeapon = hAttacker.GetActiveWeapon();

				if (hWeapon)
				{
					local sWeaponClass = hWeapon.GetClassname();

					if (sWeaponClass == "weapon_pipe_bomb")
					{
						if (!__tGrenadeShove.Settings.AllowPipeBomb)
							return;

						hEntity.ValidateScriptScope();
						local tParams = hEntity.GetScriptScope();

						if (!("grenade_shove" in tParams))
						{
							tParams["grenade_shove"] <- {
								slot1 = {
									used = false
									owner = null
									pipe_bomb = null
									bang_time = 0.0
									interval = 0.0
								}
							}
						}

						tParams = tParams["grenade_shove"]["slot1"];

						if (!tParams["used"])
						{
							local aPipeBomb = CreatePipeBomb();
							local hPipeBomb = aPipeBomb[0];

							DoEntFire("!self", "SetParent", "!activator", 0.0, hEntity, hPipeBomb);
							DoEntFire("!self", "SetParentAttachment", GetParticleAttachmentByClass(hEntity.GetClassname(), NetProps.GetPropInt(hEntity, "m_zombieClass")), 0.0, hEntity, hPipeBomb);

							EntFire("!activator", "RunScriptCode", "self.SetForwardVector(Vector(0, 0, -1))", 0.0, hPipeBomb);

							FillPipeBombParameters(tParams, hAttacker, aPipeBomb);
							ActivatePipeBomb(hEntity, 1);

							hWeapon.Kill();
						}
					}
					else if (sWeaponClass == "weapon_molotov")
					{
						if (!__tGrenadeShove.Settings.AllowMolotov)
							return;

						if (sClass == "witch")
							hEntity.TakeDamage(0.0, 8, hAttacker);
						else
							DoEntFire("!self", "Ignite", "", 0.0, null, hEntity);
					}
				}
			}
		}
	}

	OnGameEvent_player_shoved = function(tParams)
	{
		local hPlayer;

		if (hPlayer = GetPlayerFromUserID(tParams["userid"]))
		{
			if (!hPlayer.IsSurvivor())
			{
				local hAttacker = GetPlayerFromUserID(tParams["attacker"]);
				local hWeapon = hAttacker.GetActiveWeapon();

				if (hWeapon)
				{
					local sWeaponClass = hWeapon.GetClassname();

					if (sWeaponClass == "weapon_pipe_bomb")
					{
						if (!__tGrenadeShove.Settings.AllowPipeBomb)
							return;

						local tParams = hPlayer.GetScriptScope();

						if (!("grenade_shove" in tParams))
						{
							tParams["grenade_shove"] <- {
								slot1 = {
									used = false
									owner = null
									pipe_bomb = null
									bang_time = 0.0
									interval = 0.0
								}

								slot2 = {
									used = false
									owner = null
									pipe_bomb = null
									bang_time = 0.0
									interval = 0.0
								}
							}
						}

						local iSlot = 1;
						local bSlot1 = tParams["grenade_shove"]["slot1"]["used"];
						local bSlot2 = tParams["grenade_shove"]["slot2"]["used"];
						local iType = NetProps.GetPropInt(hPlayer, "m_zombieClass");
						local sAttachment = GetParticleAttachmentByClass(null, iType);

						if (sAttachment == "hand")
						{
							if (bSlot1 && bSlot2)
								return;
							
							if (bSlot1 && !bSlot2)
							{
								sAttachment = "lhand";
								iSlot = 2;
							}
							else
							{
								sAttachment = "rhand";
							}
						}
						else if (bSlot1)
						{
							return;
						}

						local aPipeBomb = CreatePipeBomb();
						local hPipeBomb = aPipeBomb[0];
						local flPitch = -90;

						if (iType == 3)
						{
							if (sAttachment == "rhand")
								flPitch = 180;
							else
								flPitch = 0;
						}

						if (iType == 5 || iType == 6)
						{
							flPitch = 180;
						}

						DoEntFire("!self", "SetParent", "!activator", 0.0, hPlayer, hPipeBomb);
						DoEntFire("!self", "SetParentAttachment", sAttachment, 0.0, hPlayer, hPipeBomb);

						EntFire("!activator", "RunScriptCode", (flPitch == -90 ? "self.SetForwardVector(Vector(0, 0, -1))" : format("self.SetAngles(QAngle(%d, 0, 0))", flPitch)), 0.0, hPipeBomb);

						FillPipeBombParameters(iSlot == 1 ? tParams["grenade_shove"]["slot1"] : tParams["grenade_shove"]["slot2"], hAttacker, aPipeBomb);
						ActivatePipeBomb(hPlayer, iSlot);

						hWeapon.Kill();

						return;
					}
					else if (sWeaponClass == "weapon_molotov")
					{
						if (!__tGrenadeShove.Settings.AllowMolotov)
							return;

						hPlayer.ValidateScriptScope();
						local tParams = hPlayer.GetScriptScope();

						if (!("on_fire" in tParams))
							tParams["on_fire"] <- false;
						
						hPlayer.TakeDamage(0.0, 8, hAttacker);
						g_flExtinguishTime[hPlayer.GetEntityIndex()] = Time() + EXTINGUISH_TIME;

						tParams["on_fire"] = true;

						return;
					}
					else if (sWeaponClass == "weapon_vomitjar")
					{
						if (!__tGrenadeShove.Settings.AllowVomitjar)
							return;

						hWeapon.ValidateScriptScope();
						local tParams = hWeapon.GetScriptScope();

						if (!("uses" in tParams))
							tParams["uses"] <- 0;

						tParams["uses"]++;
						hPlayer.HitWithVomit();

						if (tParams["uses"] >= VOMITJAR_MAX_USES)
							hWeapon.Kill();
					}
				}
			}
		}
	}

	OnGameEvent_player_hurt = function(tParams)
	{
		local hPlayer;

		if (hPlayer = GetPlayerFromUserID(tParams["userid"]))
		{
			if (!hPlayer.IsSurvivor())
			{
				if (tParams["weapon"] == "inferno" || tParams["weapon"] == "" && tParams["type"] == 268435464)
				{
					hPlayer.ValidateScriptScope();
					hPlayer.GetScriptScope()["prohibit_extinguish"] <- true;
				}
			}
		}
	}

	Settings =
	{
		AllowPipeBomb = true
		AllowMolotov = true
		AllowVomitjar = true
	}
}

function ExplodePipeBomb(tSlot)
{
	local hAttacker = tSlot["owner"];
	local hPipeBomb = tSlot["pipe_bomb"][0];

	local hExplosive = SpawnEntityFromTable("prop_physics", {
		model = "models/props_junk/propanecanister001a.mdl"
		minhealthdmg = (1 << 30)
		spawnflags = (1 << 9)
		disableshadows = 1
		rendermode = 6
	});

	NetProps.SetPropInt(hExplosive, "m_fEffects", 32);
	NetProps.SetPropInt(hExplosive, "m_CollisionGroup", 1);

	hExplosive.ValidateScriptScope();
	hPipeBomb.ValidateScriptScope();

	if (!hAttacker.IsValid()) hAttacker = hExplosive;
	else hAttacker.ValidateScriptScope();

	hExplosive.SetOrigin(hPipeBomb.GetOrigin());

	DoEntFire("!self", "RunScriptCode", "activator.SetOrigin(caller.GetOrigin())", 0.0, hExplosive, hPipeBomb);
	DoEntFire("!self", "RunScriptCode", "activator.TakeDamage((1 << 30), 0, caller)", 0.01, hExplosive, hAttacker);

	ClearPipeBombParameters(tSlot);
}

function ActivatePipeBomb(hEntity, iSlot)
{
	if (hEntity.IsValid())
	{
		local tSlot = (iSlot == 1 ? hEntity.GetScriptScope()["grenade_shove"]["slot1"] : hEntity.GetScriptScope()["grenade_shove"]["slot2"]);

		if (tSlot["pipe_bomb"][0].IsValid())
		{
			if (hEntity.GetHealth() <= 0 || NetProps.GetPropInt(hEntity, "movetype") == 0)
			{
				ClearPipeBombParameters(tSlot);
				return;
			}

			if (tSlot["bang_time"] <= Time())
			{
				ExplodePipeBomb(tSlot);
				return;
			}

			local flInterval = tSlot["interval"];

			if (flInterval > ePipeBomb.flBeepMinInterval)
				tSlot["interval"] -= ePipeBomb.flIntervalDelta;

			EntFire("!activator", "RunScriptCode", format("ActivatePipeBomb(self, %d)", iSlot), flInterval, hEntity);
			EntFire("!activator", "RunScriptCode", "EmitSoundOn(\"PipeBomb.TimerBeep\", self)", 0.0, tSlot["pipe_bomb"][0]);
		}
	}
}

function CreatePipeBomb()
{
	local hPipeBomb = SpawnEntityFromTable("pipe_bomb_projectile", {solid = 1});

	local hParticleLight = SpawnEntityFromTable("info_particle_system", {
		effect_name = "weapon_pipebomb_blinking_light"
		start_active = 1
	});

	local hParticleFuse = SpawnEntityFromTable("info_particle_system", {
		effect_name = "weapon_pipebomb_fuse"
		start_active = 1
	});

	DoEntFire("!self", "SetParent", "!activator", 0.0, hPipeBomb, hParticleFuse);
	DoEntFire("!self", "SetParentAttachment", "fuse", 0.0, hPipeBomb, hParticleFuse);

	DoEntFire("!self", "SetParent", "!activator", 0.0, hPipeBomb, hParticleLight);
	DoEntFire("!self", "SetParentAttachment", "pipebomb_light", 0.0, hPipeBomb, hParticleLight);

	NetProps.SetPropInt(hPipeBomb, "m_CollisionGroup", 1);

	return [hPipeBomb, hParticleLight, hParticleFuse];
}

function GetParticleAttachmentByClass(sClass, iType)
{
	switch (iType)
	{
		case -1: // infected or witch
			if (sClass == "infected")
				return "mouth";
			return "leye";
		case 5: // jockey and charger
		case 6:
			return "rhand";
		case 1: // smoker
			return "smoker_mouth";
		case 3: // hunter
			return "hand";
		default: // other SI and tank
			return "mouth";
	}
}

function FillPipeBombParameters(tParams, hOwner, aPipeBomb)
{
	tParams["used"] = true;
	tParams["owner"] = hOwner;
	tParams["pipe_bomb"] = aPipeBomb;
	tParams["bang_time"] = Time() + ePipeBomb.flDuration;
	tParams["interval"] = ePipeBomb.flInitialBeepInterval;
}

function ClearPipeBombParameters(tParams)
{
	if (typeof tParams["pipe_bomb"] == "array")
	{
		foreach (ent in tParams["pipe_bomb"])
		{
			if (ent.IsValid())
				ent.Kill();
		}
	}

	tParams["used"] = false;
	tParams["owner"] = null;
	tParams["pipe_bomb"] = null;
	tParams["bang_time"] = 0.0;
	tParams["interval"] = 0.0;
}

if (!Entities.FindByName(null, "__grenade_shove_think"))
{
	local hTimer = SpawnEntityFromTable("logic_script", {targetname = "__grenade_shove_think"});
	hTimer.ValidateScriptScope();
	hTimer.GetScriptScope()["GrenadeShove_Think"] <- function(){
		local hPlayer, tParams;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (!hPlayer.IsSurvivor())
			{
				hPlayer.ValidateScriptScope();
				tParams = hPlayer.GetScriptScope()

				if ("prohibit_extinguish" in tParams)
				{
					if (hPlayer.IsOnFire())
					{
						if (tParams["prohibit_extinguish"])
							continue;
					}
					else
					{
						tParams["prohibit_extinguish"] = false;
					}
				}

				if ("on_fire" in tParams)
				{
					if (tParams["on_fire"] && g_flExtinguishTime[hPlayer.GetEntityIndex()] <= Time())
					{
						if (hPlayer.IsOnFire()) hPlayer.Extinguish();
						tParams["on_fire"] = false;
					}
				}
			}
		}
		DoEntFire("!self", "CallScriptFunction", "GrenadeShove_Think", 0.01, self, self);
	}
	DoEntFire("!self", "CallScriptFunction", "GrenadeShove_Think", 0.01, hTimer, hTimer);

}

__CollectEventCallbacks(__tGrenadeShove, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

printl("[Grenade Shove]\nAuthor: Sw1ft\nVersion: 2.1");