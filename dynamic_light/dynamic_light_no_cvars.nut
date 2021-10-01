// Squirrel
// Dynamic Light

class CScriptPluginDynamicLight extends IScriptPlugin
{
	function Load()
	{
		g_tDynamicLight.ParseConfigFile();

		HookEvent("molotov_thrown", g_tDynamicLight.OnMolotovThrown, g_tDynamicLight);
		HookEvent("weapon_fire", g_tDynamicLight.OnWeaponFire, g_tDynamicLight);
		HookEvent("ability_use", g_tDynamicLight.OnAbilityUse, g_tDynamicLight);
		HookEvent("break_prop", g_tDynamicLight.OnBreakProp, g_tDynamicLight);

		printl("[Dynamic Light]\nAuthor: Sw1ft\nVersion: 2.0.1c");
	}

	function Unload()
	{

	}

	function OnRoundStartPost()
	{
		
	}

	function OnRoundEnd()
	{

	}

	function AdditionalClassMethodsInjected()
	{
		RegisterLoopFunction("DynamicLight_Think", 0.0334);
		RegisterOnTickFunction("g_tDynamicLight.DynamicLight_Think2");

		RegisterChatCommand("!dl_reset", g_tDynamicLight.ResetDynamicLightSettings_Cmd, true);
		RegisterChatCommand("!dl_reload", g_tDynamicLight.ReloadDynamicLightSettings_Cmd, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	function _set(key, val) { throw null; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CScriptPluginDynamicLight";
	static m_sScriptPluginName = "Dynamic Light [No CVars Edition]";
}

g_DynamicLight <- CScriptPluginDynamicLight();

g_hMuzzleFlashParticle <- null;

g_aParticlesList <- [];
g_flMuzzleFlashTime <- array(MAXCLIENTS + 1, 0.0);

g_tDynamicLightSettings <-
{
	dl_allow = 1
	dl_mode = DL_HELD_ITEM | DL_PROJECTILE | DL_INFLUENCE_EFFECT | DL_INFECTED_GLOW | DL_MUZZLE_FLASH
	dl_limit = 32
	dl_blink_interval = 0.25
	dl_flame_radius = 200.0
	dl_pipe_radius = 160.0
	dl_spit_radius = 200.0
	dl_fireworks_color = "255 100 0"
	dl_molotov_color = "255 50 0"
	dl_spit_color = "0 192 0"
}

g_tDynamicLightSettingsSrc <- clone g_tDynamicLightSettings;

g_tDynamicLight <-
{
	ParseConfigFile = function(bReset = false)
	{
		local tData;

		local function SerializeSettings()
		{
			local sData = "{";

			foreach (key, val in ::g_tDynamicLightSettings)
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
			StringToFile("dynamic_light/settings.nut", sData);
		}

		if (bReset)
		{
			g_tDynamicLightSettings = clone g_tDynamicLightSettingsSrc;
			SerializeSettings();
			return;
		}

		if (tData = FileToString("dynamic_light/settings.nut"))
		{
			try {
				tData = compilestring("return " + tData)();
				foreach (key, val in g_tDynamicLightSettings)
				{
					if (tData.rawin(key))
					{
						switch (key)
						{
						case "dl_allow":
							g_tDynamicLightSettings[key] = Math.Clamp(tData[key], 0, 1);
							break;
						
						case "dl_mode":
							g_tDynamicLightSettings[key] = Math.Clamp(tData[key], 0, 31);
							break;
						
						case "dl_limit":
							g_tDynamicLightSettings[key] = (tData[key] < 0 ? 0 : tData[key]);
							break;
						
						case "dl_blink_interval":
							g_tDynamicLightSettings[key] = (tData[key] < 0.01 ? 0.01 : tData[key]);
							break;
						
						case "dl_flame_radius":
						case "dl_pipe_radius":
						case "dl_spit_radius":
							g_tDynamicLightSettings[key] = Math.Clamp(tData[key], 0, 1000.0);
							break;
						
						default:
							g_tDynamicLightSettings[key] = tData[key];
							break;
						}
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

	RemoveParticles = function(tParams)
	{
		if (tParams["particle"] && tParams["particle"].IsValid())
			tParams["particle"].Kill();

		if (tParams["particle2"] && tParams["particle2"].IsValid())
			tParams["particle2"].Kill();
	}

	GetParticleAttachment = function(sModel)
	{
		if (sModel.len() > 29)
		{
			switch (sModel[29])
			{
			case 98: // nick
			case 104: // ellis
			case 100: // rochelle
			case 118: // bill
				return "weapon_bone";

			case 99: // coach
			case 101: // francis
			case 97: // louis
			case 110: // zoey
				return "survivor_light";
			}
		}
	}

	Blink = function(hLight, flRadius, flDelay, bMode)
	{
		if (hLight && hLight.IsValid())
		{
			CreateTimer(flDelay, function(hLight, flRadius, flDelay, bMode){
				NetProps.SetPropFloat(hLight, "m_Radius", bMode ? 0.0 : flRadius);
				g_tDynamicLight.Blink(hLight, flRadius, flDelay, !bMode);
			}, hLight, flRadius, flDelay, bMode);
		}
	}

	PutOutMuzzleFlash = function(hLight, idx)
	{
		if (g_flMuzzleFlashTime[idx] <= Time())
		{
			NetProps.SetPropFloat(hLight, "m_Radius", 0.0);
			AcceptEntityInput(hLight, "TurnOff");
		}
	}

	OnProjectileSpawn = function(hProjectile, iType)
	{
		if (g_tDynamicLightSettings["dl_allow"] && g_tDynamicLightSettings["dl_mode"] & DL_PROJECTILE)
		{
			if (iType == 0) // pipe bomb
			{
				if (g_aParticlesList.len() + 1 < g_tDynamicLightSettings["dl_limit"])
				{
					local flRadius = g_tDynamicLightSettings["dl_pipe_radius"] * 1.25;
					
					local hLight = SpawnEntityFromTable("light_dynamic", {
						_light = "200 0 0"
						spotlight_radius = 128
						distance = flRadius
						brightness = 0
					});

					local hLight2 = SpawnEntityFromTable("light_dynamic", {
						_light = "255 55 0"
						spotlight_radius = 8
						distance = 16
						brightness = 1
						style = 6
					});

					g_tDynamicLight.Blink(hLight, flRadius, g_tDynamicLightSettings["dl_blink_interval"], true);

					AttachEntity(hProjectile, hLight, "pipebomb_light");
					AttachEntity(hProjectile, hLight2, "fuse");

					g_aParticlesList.push(hLight);
					g_aParticlesList.push(hLight2);
				}
				return;
			}
			if (g_aParticlesList.len() < g_tDynamicLightSettings["dl_limit"])
			{
				if (iType == 1) // molotov
				{
					local hLight = SpawnEntityFromTable("light_dynamic", {
						_light = g_tDynamicLightSettings["dl_molotov_color"]
						spotlight_radius = 128
						distance = g_tDynamicLightSettings["dl_flame_radius"]
						brightness = 1
						style = 6
					});

					AttachEntity(hProjectile, hLight, "wick");
					g_aParticlesList.push(hLight);

					return;
				}

				// spit
				local hLight = SpawnEntityFromTable("light_dynamic", {
					origin = hProjectile.GetOrigin()
					_light = g_tDynamicLightSettings["dl_spit_color"]
					spotlight_radius = 128
					distance = g_tDynamicLightSettings["dl_flame_radius"] * 0.75
					brightness = 1
					style = 6
				});

				AttachEntity(hProjectile, hLight);
				g_aParticlesList.push(hLight);
			}
		}
	}

	OnInfluenceEffectSpawn = function(hEntity, iType)
	{
		if (g_tDynamicLightSettings["dl_allow"] && g_tDynamicLightSettings["dl_mode"] & DL_INFLUENCE_EFFECT && g_aParticlesList.len() < g_tDynamicLightSettings["dl_limit"])
		{
			local flInfluenceEffectLifeTime, flRadius, sColor;

			switch (iType)
			{
			// inferno or fireworks
			case 0:
			case 1:
				flRadius = g_tDynamicLightSettings["dl_flame_radius"] * 1.25;
				flInfluenceEffectLifeTime = cvar("inferno_flame_lifetime", null, false);
				if (iType == 0)
				{
					sColor = g_tDynamicLightSettings["dl_molotov_color"];
				}
				else
				{
					flInfluenceEffectLifeTime -= 1.5;
					sColor = g_tDynamicLightSettings["dl_fireworks_color"];
				}
				break;
			
			// spit
			default:
				flRadius = g_tDynamicLightSettings["dl_spit_radius"] * 1.25;
				flInfluenceEffectLifeTime = 7.25;
				sColor = g_tDynamicLightSettings["dl_spit_color"];
				break;
			}

			if (flInfluenceEffectLifeTime > 3.4 || iType == 2)
			{
				local iTicks = 50;
				local flTime = 0.0;
				local flRadiusDelta = flRadius / iTicks;

				local hLight = SpawnEntityFromTable("light_dynamic", {
					origin = hEntity.GetOrigin() + Vector(0, 0, 4)
					_light = sColor
					spotlight_radius = 256
					brightness = (iType == 2 ? 2 : 3)
					distance = 0
					style = 6
				});

				if (flRadius > 10)
				{
					flRadius = 0.0;
					for (local i = 0; i < iTicks; i++)
					{
						flTime += 0.0333333;
						flRadius += flRadiusDelta;
						CreateTimer(flTime, function(hLight, flRadius){
							if (hLight.IsValid()) NetProps.SetPropFloat(hLight, "m_Radius", flRadius);
						}, hLight, flRadius);
					}
					for (local j = 0; j < iTicks; j++)
					{
						flTime -= 0.0333333;
						flRadius -= flRadiusDelta;
						CreateTimer(flInfluenceEffectLifeTime - flTime, function(hLight, flRadius){
							if (hLight.IsValid()) NetProps.SetPropFloat(hLight, "m_Radius", flRadius);
						}, hLight, flRadius);
					}
				}

				AttachEntity(hEntity, hLight);
				g_aParticlesList.push(hLight);
			}
		}
	}

	DynamicLight_ThinkThread = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "inferno"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnInfluenceEffectSpawn(hEntity, 0);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}

		hEntity = null;
		while (hEntity = Entities.FindByClassname(hEntity, "pipe_bomb_projectile"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnProjectileSpawn(hEntity, 0);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}

		hEntity = null;
		while (hEntity = Entities.FindByClassname(hEntity, "insect_swarm"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnInfluenceEffectSpawn(hEntity, 2);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}
	}

	DynamicLight_Think2 = function()
	{
		local idx = 0;
		local length = g_aParticlesList.len();

		while (idx < length)
		{
			if (!g_aParticlesList[idx].IsValid())
			{
				g_aParticlesList.remove(idx);
				length--;
				continue;
			}
			idx++;
		}

		if (g_hMuzzleFlashParticle && g_hMuzzleFlashParticle.IsValid())
		{
			local hPlayer = GetScriptScopeVar(g_hMuzzleFlashParticle, "owner");
			if (hPlayer.IsValid())
			{
				local vecDirection = hPlayer.EyeAngles().Forward();
				local vecEyePosition = hPlayer.EyePosition();
				local vecPos = hPlayer.DoTraceLine(eTrace.Type_Pos, 30.0);
				g_hMuzzleFlashParticle.SetOrigin(((vecEyePosition - vecPos).LengthSqr() <= 625.0) ? (vecPos - vecDirection) : (vecEyePosition + vecDirection * 25.0));
			}
		}
	}

	FindFireCrackerBlast = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "fire_cracker_blast"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnInfluenceEffectSpawn(hEntity, 1);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}
	}

	FindSpitterProjectile = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "spitter_projectile"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnProjectileSpawn(hEntity, 2);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}
	}

	OnMolotovThrown = function(tParams)
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "molotov_projectile"))
		{
			if (!KeyInScriptScope(hEntity, "spawned"))
			{
				g_tDynamicLight.OnProjectileSpawn(hEntity, 1);
				SetScriptScopeVar(hEntity, "spawned", true);
			}
		}
	}

	OnWeaponFire = function(tParams)
	{
		if (g_tDynamicLightSettings["dl_allow"] && g_tDynamicLightSettings["dl_mode"] & DL_MUZZLE_FLASH)
		{
			local bAutomaticWeapon = true;

			switch (tParams["weaponid"])
			{
			case 1: // pistol
			case 3: // pumpshotgun
			case 4: // autoshotgun
			case 6: // hunting_rifle
			case 8: // shotgun_chrome
			case 10: // sniper_military
			case 11: // shotgun_spas
			case 32: // pistol_magnum
			case 35: // sniper_awp
			case 36: // sniper_scout
				bAutomaticWeapon = false;

			case 2: // smg
			case 5: // rifle
			case 7: // smg_silenced
			case 9: // rifle_desert
			case 26: // rifle_ak47
			case 33: // smg_mp5
			case 34: // rifle_sg552
			case 37: // rifle_m60
			case 54: // prop_minigun, prop_minigun_l4d1
				local hPlayer = tParams["_player"];
				local hLight = GetScriptScopeVar(hPlayer, "dynamic_light")["muzzle_flash"];

				if (hLight && hLight.IsValid() && hPlayer.IsAlive() && NetProps.GetPropInt(hPlayer, "m_nWaterLevel") < 3)
				{
					AcceptEntityInput(hLight, "TurnOn");
					NetProps.SetPropFloat(hLight, "m_Radius", bAutomaticWeapon ? (RandomInt(0, 1) ? 65.0 : RandomFloat(155.0, 255.0)) : RandomFloat(100.0, 255.0));
					
					g_flMuzzleFlashTime[hPlayer.GetEntityIndex()] = Time() + 0.0334;
					CreateTimer(0.0334, g_tDynamicLight.PutOutMuzzleFlash, hLight, hPlayer.GetEntityIndex());
				}
				
				break;
			}
		}
	}

	OnAbilityUse = function(tParams)
	{
		if (tParams["ability"] == "ability_spit")
			CreateTimer(0.24, g_tDynamicLight.FindSpitterProjectile);
	}

	OnBreakProp = function(tParams)
	{
		CreateTimer(0.01, g_tDynamicLight.FindFireCrackerBlast);
	}

	ResetDynamicLightSettings_Cmd = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			g_tDynamicLight.ParseConfigFile(true);
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}
	}

	ReloadDynamicLightSettings_Cmd = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			g_tDynamicLight.ParseConfigFile();
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}
	}
};

function DynamicLight_Think()
{
	local hPlayer;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if (!KeyInScriptScope(hPlayer, "dynamic_light"))
		{
			SetScriptScopeVar(hPlayer, "dynamic_light", {
				name = null
				burning = false
				particle = null
				particle2 = null
				muzzle_flash = null
			});
		}

		local sActiveWeapon;
		local tParams = GetScriptScopeVar(hPlayer, "dynamic_light");

		if (g_tDynamicLightSettings["dl_allow"])
		{
			if (hPlayer.IsAlive())
			{
				local length = g_aParticlesList.len();
				local mode = g_tDynamicLightSettings["dl_mode"];
				
				if (hPlayer.IsSurvivor() && NetProps.GetPropInt(hPlayer, "m_nWaterLevel") < 3)
				{
					if (tParams["muzzle_flash"])
					{
						if (!tParams["muzzle_flash"].IsValid())
							tParams["muzzle_flash"] = null;
					}
					else if (mode & DL_MUZZLE_FLASH)
					{
						local hLight = tParams["muzzle_flash"] = SpawnEntityFromTable("light_dynamic", {
							_light = "250 150 30"
							spotlight_radius = 32
							brightness = 1
							distance = 0
						});

						if (hPlayer.IsHost())
						{
							g_hMuzzleFlashParticle = hLight;
							SetScriptScopeVar(hLight, "owner", hPlayer);
						}
						else
						{
							AttachEntity(hPlayer, hLight, "survivor_light");
						}

						AcceptEntityInput(hLight, "TurnOff");
					}

					if (mode & DL_HELD_ITEM && !hPlayer.IsIncapacitated() && NetProps.GetPropInt(hPlayer, "m_MoveType") != MOVETYPE_LADDER)
					{
						local hWeapon;
						local tInv = {};
						GetInvTable(hPlayer, tInv);

						if ((hWeapon = hPlayer.GetActiveWeapon()) && !NetProps.GetPropInt(hWeapon, "m_bRedraw"))
							sActiveWeapon = hWeapon.GetClassname();

						if ("slot2" in tInv)
						{
							local sClass = tInv["slot2"].GetClassname();
							if (sClass != tParams["name"] && sClass == sActiveWeapon)
							{
								if (sClass == "weapon_molotov" && length < g_tDynamicLightSettings["dl_limit"])
								{
									local hLight = SpawnEntityFromTable("light_dynamic", {
										_light = g_tDynamicLightSettings["dl_molotov_color"]
										spotlight_radius = 128
										distance = g_tDynamicLightSettings["dl_flame_radius"]
										brightness = 1
										style = 6
									});

									AttachEntity(hPlayer, hLight, g_tDynamicLight.GetParticleAttachment(NetProps.GetPropString(hPlayer, "m_ModelName")));

									g_aParticlesList.push(hLight);

									g_tDynamicLight.RemoveParticles(tParams);
									tParams["particle"] = hLight;
									tParams["name"] = sClass;

									continue;
								}
								else if (sClass == "weapon_pipe_bomb" && length + 1 < g_tDynamicLightSettings["dl_limit"])
								{
									local flRadius = g_tDynamicLightSettings["dl_pipe_radius"];

									local hLight = SpawnEntityFromTable("light_dynamic", {
										_light = "255 0 0"
										spotlight_radius = 128
										distance = flRadius
										brightness = 1
									});

									local hLight2 = SpawnEntityFromTable("light_dynamic", {
										origin = hPlayer.EyePosition() + hPlayer.EyeAngles().Left() * 8
										_light = "128 28 0"
										spotlight_radius = 32
										distance = 32
										brightness = 2
										style = 6
									});

									g_tDynamicLight.Blink(hLight, flRadius, g_tDynamicLightSettings["dl_blink_interval"], true);

									AttachEntity(hPlayer, hLight, g_tDynamicLight.GetParticleAttachment(NetProps.GetPropString(hPlayer, "m_ModelName")));
									AttachEntity(hPlayer, hLight2, "armR_T");

									g_aParticlesList.push(hLight);
									g_aParticlesList.push(hLight2);

									g_tDynamicLight.RemoveParticles(tParams);
									tParams["particle"] = hLight;
									tParams["particle2"] = hLight2;
									tParams["name"] = sClass;

									continue;
								}
							}
						}
					}
				}
				else if (mode & DL_INFECTED_GLOW)
				{
					if (hPlayer.IsOnFire() && NetProps.GetPropInt(hPlayer, "m_nWaterLevel") < 1)
					{
						if (!tParams["burning"] && length < g_tDynamicLightSettings["dl_limit"])
						{
							local hLight = SpawnEntityFromTable("light_dynamic", {
								origin = hPlayer.GetBodyPosition(0.35)
								_light = g_tDynamicLightSettings["dl_molotov_color"]
								spotlight_radius = 128
								distance = g_tDynamicLightSettings["dl_flame_radius"] * 0.75
								brightness = 2
								style = 6
							});

							AttachEntity(hPlayer, hLight);

							g_aParticlesList.push(hLight);

							g_tDynamicLight.RemoveParticles(tParams);
							tParams["particle"] = hLight;
						}
						tParams["burning"] = true;
					}
					else
					{
						if (tParams["burning"]) g_tDynamicLight.RemoveParticles(tParams);
						tParams["burning"] = false;
					}
				}
			}
		}

		if (tParams["name"] != sActiveWeapon)
		{
			g_tDynamicLight.RemoveParticles(tParams);
			tParams["name"] = null;
			tParams["particle"] = null;
			tParams["particle2"] = null;
		}
	}

	newthread(g_tDynamicLight.DynamicLight_ThinkThread).call();
}

g_ScriptPluginsHelper.AddScriptPlugin(g_DynamicLight);