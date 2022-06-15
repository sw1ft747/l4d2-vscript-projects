// Dynamic Light

class CPluginDynamicLight extends VSLU.IScriptPlugin
{
	function Load()
	{
		g_DynamicLight.ParseConfigFile();

		VSLU.HookEvent("molotov_thrown", g_DynamicLight.OnMolotovThrown, g_DynamicLight);
		VSLU.HookEvent("weapon_fire", g_DynamicLight.OnWeaponFire, g_DynamicLight);
		VSLU.HookEvent("ability_use", g_DynamicLight.OnAbilityUse, g_DynamicLight);
		VSLU.HookEvent("break_prop", g_DynamicLight.OnBreakProp, g_DynamicLight);

		VSLU.RegisterLoopFunction("DynamicLight_Think", 0.0334);
		VSLU.RegisterOnTickFunction("g_DynamicLight.DynamicLight_Think2");

		VSLU.RegisterChatCommand("!dl_reset", g_DynamicLight.ResetDynamicLightSettings_Cmd);
		VSLU.RegisterChatCommand("!dl_reload", g_DynamicLight.ReloadDynamicLightSettings_Cmd);

		printl("[Dynamic Light]\nAuthor: Sw1ft\nVersion: 2.0.6");
	}

	function Unload()
	{
		VSLU.UnhookEvent("molotov_thrown", g_DynamicLight.OnMolotovThrown, g_DynamicLight);
		VSLU.UnhookEvent("weapon_fire", g_DynamicLight.OnWeaponFire, g_DynamicLight);
		VSLU.UnhookEvent("ability_use", g_DynamicLight.OnAbilityUse, g_DynamicLight);
		VSLU.UnhookEvent("break_prop", g_DynamicLight.OnBreakProp, g_DynamicLight);

		VSLU.RemoveLoopFunction("DynamicLight_Think", 0.0334);
		VSLU.RemoveOnTickFunction("g_DynamicLight.DynamicLight_Think2");

		VSLU.RemoveChatCommand("!dl_reset");
		VSLU.RemoveChatCommand("!dl_reload");
	}

	function OnRoundStartPost()
	{	
	}

	function OnRoundEnd()
	{
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CPluginDynamicLight";
	static m_sScriptPluginName = "Dynamic Light";
}

g_PluginDynamicLight <- CPluginDynamicLight();

::g_DynamicLightSettings <-
{
	Allow = true
	Limit = 16

	GlowPipe = true
	GlowPipeProjectile = true
	PipeBlinkInterval = 0.25
	PipeRadius = 160.0
	PipeFuseRadius = 32.0
	PipeProjectileRadius = 200.0
	PipeProjectileFuseRadius = 16.0
	PipeBlinkColor = "255 0 0"
	PipeFuseColor = "128 28 0"
	PipeProjectileBlinkColor = "200 0 0"
	PipeProjectileFuseColor = "255 55 0"

	GlowMolotov = true
	GlowMolotovProjectile = true
	MolotovRadius = 200.0
	MolotovProjectileRadius = 200.0

	GlowInferno = true
	InfernoRadius = 250.0
	FlameColor = "255 50 0"

	GlowSpit = true
	GlowSpitProjectile = true
	SpitRadius = 250.0
	SpitProjectileRadius = 150.0
	SpitColor = "0 192 0"

	GlowFirecrackerBlast = true
	FirecrackerBlastRadius = 250.0
	FirecrackerBlastColor = "255 100 0"

	GlowBurningInfected = true
	BurningInfectedRadius = 150.0

	GlowMuzzleFlash = true
	MuzzleFlashColor = "250 150 30"
}

::g_DynamicLightSettingsSrc <- clone g_DynamicLightSettings;

g_DynamicLight <-
{
	hMuzzleFlashParticle = null

	aParticlesList = []
	flMuzzleFlashTime = array(MAXCLIENTS + 1, 0.0)

	ParseConfigFile = function(bReset = false)
	{
		local tData;

		local function SerializeSettings()
		{
			local sData = "{";

			// Manually save everything, I don't want it to be messed up
			sData += "\n\tAllow = " + g_DynamicLightSettings.Allow;
			sData += "\n\tLimit = " + g_DynamicLightSettings.Limit;

			sData += "\n\n\tGlowPipe = " + g_DynamicLightSettings.GlowPipe;
			sData += "\n\tGlowPipeProjectile = " + g_DynamicLightSettings.GlowPipeProjectile;
			sData += format("\n\tPipeBlinkInterval = %f", g_DynamicLightSettings.PipeBlinkInterval);
			sData += format("\n\tPipeRadius = %f", g_DynamicLightSettings.PipeRadius);
			sData += format("\n\tPipeFuseRadius = %f", g_DynamicLightSettings.PipeFuseRadius);
			sData += format("\n\tPipeProjectileRadius = %f", g_DynamicLightSettings.PipeProjectileRadius);
			sData += format("\n\tPipeProjectileFuseRadius = %f", g_DynamicLightSettings.PipeProjectileFuseRadius);
			sData += format("\n\tPipeBlinkColor = \"%s\"", g_DynamicLightSettings.PipeBlinkColor);
			sData += format("\n\tPipeFuseColor = \"%s\"", g_DynamicLightSettings.PipeFuseColor);
			sData += format("\n\tPipeProjectileBlinkColor = \"%s\"", g_DynamicLightSettings.PipeProjectileBlinkColor);
			sData += format("\n\tPipeProjectileFuseColor = \"%s\"", g_DynamicLightSettings.PipeProjectileFuseColor);

			sData += "\n\n\tGlowMolotov = " + g_DynamicLightSettings.GlowMolotov;
			sData += "\n\tGlowMolotovProjectile = " + g_DynamicLightSettings.GlowMolotovProjectile;
			sData += format("\n\tMolotovRadius = %f", g_DynamicLightSettings.MolotovRadius);
			sData += format("\n\tMolotovProjectileRadius = %f", g_DynamicLightSettings.MolotovProjectileRadius);

			sData += "\n\n\tGlowInferno = " + g_DynamicLightSettings.GlowInferno;
			sData += format("\n\tInfernoRadius = %f", g_DynamicLightSettings.InfernoRadius);
			sData += format("\n\tFlameColor = \"%s\"", g_DynamicLightSettings.FlameColor);

			sData += "\n\n\tGlowSpit = " + g_DynamicLightSettings.GlowSpit;
			sData += "\n\tGlowSpitProjectile = " + g_DynamicLightSettings.GlowSpitProjectile;
			sData += format("\n\tSpitRadius = %f", g_DynamicLightSettings.SpitRadius);
			sData += format("\n\tSpitProjectileRadius = %f", g_DynamicLightSettings.SpitProjectileRadius);
			sData += format("\n\tSpitColor = \"%s\"", g_DynamicLightSettings.SpitColor);

			sData += "\n\n\tGlowFirecrackerBlast = " + g_DynamicLightSettings.GlowFirecrackerBlast;
			sData += format("\n\tFirecrackerBlastRadius = %f", g_DynamicLightSettings.FirecrackerBlastRadius);
			sData += format("\n\tFirecrackerBlastColor = \"%s\"", g_DynamicLightSettings.FirecrackerBlastColor);

			sData += "\n\n\tGlowBurningInfected = " + g_DynamicLightSettings.GlowBurningInfected;
			sData += format("\n\tBurningInfectedRadius = %f", g_DynamicLightSettings.BurningInfectedRadius);

			sData += "\n\n\tGlowMuzzleFlash = " + g_DynamicLightSettings.GlowMuzzleFlash;
			sData += format("\n\tMuzzleFlashColor = \"%s\"", g_DynamicLightSettings.MuzzleFlashColor);

			sData += "\n}";
			StringToFile("dynamic_light/settings.txt", sData);
		}

		if (bReset)
		{
			g_DynamicLightSettings = clone g_DynamicLightSettingsSrc;
			SerializeSettings();
			return;
		}

		if (tData = FileToString("dynamic_light/settings.txt"))
		{
			try
			{
				tData = compilestring("return " + tData)();

				if ( typeof tData != "table" )
					throw "expected table";

				foreach (key, val in g_DynamicLightSettings)
				{
					if ( tData.rawin(key) )
					{
						g_DynamicLightSettings[key] = tData[key];
					}
				}
			}
			catch (e)
			{
				SerializeSettings();

				errorl("[Dynamic Light] Failed to parse file \"settings.txt\". Reason: " + e);
				errorl("[Dynamic Light] The file's settings have been reset");
			}

			if ( g_DynamicLightSettings["Limit"] < 0 )
				g_DynamicLightSettings["Limit"] = 0;

			if ( g_DynamicLightSettings["PipeBlinkInterval"] < 0.01 )
				g_DynamicLightSettings["PipeBlinkInterval"] = 0.01;
		}
		else
		{
			SerializeSettings();
		}
	}

	RemoveParticles = function(tParams)
	{
		if ( tParams["particle"] && tParams["particle"].IsValid() )
			tParams["particle"].Kill();

		if ( tParams["particle2"] && tParams["particle2"].IsValid() )
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
		if ( hLight && hLight.IsValid() )
		{
			VSLU.CreateTimer(flDelay, function(hLight, flRadius, flDelay, bMode)
			{
				NetProps.SetPropFloat(hLight, "m_Radius", bMode ? 0.0 : flRadius);
				g_DynamicLight.Blink(hLight, flRadius, flDelay, !bMode);

			}, hLight, flRadius, flDelay, bMode);
		}
	}

	PutOutMuzzleFlash = function(hLight, idx)
	{
		if ( g_DynamicLight.flMuzzleFlashTime[idx] <= Time() )
		{
			NetProps.SetPropFloat(hLight, "m_Radius", 0.0);
			VSLU.AcceptEntityInput(hLight, "TurnOff");
		}
	}

	OnProjectileSpawn = function(hProjectile, iType)
	{
		this = ::g_DynamicLight;

		if ( g_DynamicLightSettings["Allow"] && aParticlesList.len() < g_DynamicLightSettings["Limit"] )
		{
			if ( iType == 0 ) // pipe bomb
			{
				// blink light + fuse
				if ( g_DynamicLightSettings["GlowPipeProjectile"] && aParticlesList.len() + 1 < g_DynamicLightSettings["Limit"] )
				{
					local flRadius = g_DynamicLightSettings["PipeProjectileRadius"];
					
					local hLight = SpawnEntityFromTable("light_dynamic", {
						_light = g_DynamicLightSettings["PipeProjectileBlinkColor"]
						spotlight_radius = 128
						distance = flRadius
						brightness = 0
					});

					local hLight2 = SpawnEntityFromTable("light_dynamic", {
						_light = g_DynamicLightSettings["PipeProjectileFuseColor"]
						spotlight_radius = 8
						distance = g_DynamicLightSettings["PipeProjectileFuseRadius"]
						brightness = 1
						style = 6
					});

					Blink(hLight, flRadius, g_DynamicLightSettings["PipeBlinkInterval"], true);

					VSLU.AttachEntity(hProjectile, hLight, "pipebomb_light");
					VSLU.AttachEntity(hProjectile, hLight2, "fuse");

					aParticlesList.push(hLight);
					aParticlesList.push(hLight2);
				}
			}
			else if ( iType == 1 ) // molotov
			{
				if ( g_DynamicLightSettings["GlowMolotovProjectile"] )
				{
					local hLight = SpawnEntityFromTable("light_dynamic", {
						_light = g_DynamicLightSettings["FlameColor"]
						spotlight_radius = 128
						distance = g_DynamicLightSettings["MolotovProjectileRadius"]
						brightness = 1
						style = 6
					});

					VSLU.AttachEntity(hProjectile, hLight, "wick");
					aParticlesList.push(hLight);
				}
			}
			else if ( iType == 2 ) // spit
			{
				if ( g_DynamicLightSettings["GlowSpitProjectile"] )
				{
					local hLight = SpawnEntityFromTable("light_dynamic", {
						origin = hProjectile.GetOrigin()
						_light = g_DynamicLightSettings["SpitColor"]
						spotlight_radius = 128
						distance = g_DynamicLightSettings["SpitProjectileRadius"]
						brightness = 1
						style = 6
					});

					VSLU.AttachEntity(hProjectile, hLight);
					aParticlesList.push(hLight);
				}
			}
		}
	}

	OnInfluenceEffectSpawn = function(hEntity, iType)
	{
		if ( g_DynamicLightSettings["Allow"] && g_DynamicLight.aParticlesList.len() < g_DynamicLightSettings["Limit"] )
		{
			local flInfluenceEffectLifeTime, flRadius, sColor;

			if ( iType == 0 ) // inferno
			{
				if ( !g_DynamicLightSettings["GlowInferno"] )
					return;

				flInfluenceEffectLifeTime = cvar("inferno_flame_lifetime", null, false);

				sColor = g_DynamicLightSettings["FlameColor"];
				flRadius = g_DynamicLightSettings["InfernoRadius"];
			}
			else if ( iType == 1 ) // firecracker blast
			{
				if ( !g_DynamicLightSettings["GlowFirecrackerBlast"] )
					return;

				flInfluenceEffectLifeTime = cvar("inferno_flame_lifetime", null, false) - 1.5;
					
				sColor = g_DynamicLightSettings["FirecrackerBlastColor"];
				flRadius = g_DynamicLightSettings["FirecrackerBlastRadius"];
			}
			else if ( iType == 2 ) // spit
			{
				if ( !g_DynamicLightSettings["GlowSpit"] )
					return;

				flInfluenceEffectLifeTime = 7.25;

				sColor = g_DynamicLightSettings["SpitColor"];
				flRadius = g_DynamicLightSettings["SpitRadius"];
			}

			if ( flInfluenceEffectLifeTime > 3.4 || iType == 2 )
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

				if ( flRadius > 10 )
				{
					flRadius = 0.0;
					for (local i = 0; i < iTicks; ++i)
					{
						flTime += 0.0333333;
						flRadius += flRadiusDelta;
						VSLU.CreateTimer(flTime, function(hLight, flRadius){
							if ( hLight.IsValid() ) NetProps.SetPropFloat(hLight, "m_Radius", flRadius);
						}, hLight, flRadius);
					}
					for (local j = 0; j < iTicks; ++j)
					{
						flTime -= 0.0333333;
						flRadius -= flRadiusDelta;
						VSLU.CreateTimer(flInfluenceEffectLifeTime - flTime, function(hLight, flRadius){
							if ( hLight.IsValid() ) NetProps.SetPropFloat(hLight, "m_Radius", flRadius);
						}, hLight, flRadius);
					}
				}

				VSLU.AttachEntity(hEntity, hLight);
				g_DynamicLight.aParticlesList.push(hLight);
			}
		}
	}

	DynamicLight_ThinkThread = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "inferno"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnInfluenceEffectSpawn(hEntity, 0);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}

		hEntity = null;
		while (hEntity = Entities.FindByClassname(hEntity, "pipe_bomb_projectile"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnProjectileSpawn(hEntity, 0);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}

		hEntity = null;
		while (hEntity = Entities.FindByClassname(hEntity, "insect_swarm"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnInfluenceEffectSpawn(hEntity, 2);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}
	}

	DynamicLight_Think2 = function()
	{
		this = ::g_DynamicLight;

		local idx = 0;
		local length = aParticlesList.len();

		while (idx < length)
		{
			if ( !aParticlesList[idx].IsValid() )
			{
				aParticlesList.remove(idx);
				--length;

				continue;
			}

			++idx;
		}

		if ( hMuzzleFlashParticle && hMuzzleFlashParticle.IsValid() )
		{
			local hPlayer = VSLU.GetScriptScopeVar(hMuzzleFlashParticle, "owner");

			if ( hPlayer.IsValid() )
			{
				local tTraceResult = {};

				VSLU.Player.TraceLine(hPlayer, tTraceResult, 30.0);

				local vecPos = tTraceResult["pos"];
				local vecDirection = hPlayer.EyeAngles().Forward();
				local vecEyePosition = hPlayer.EyePosition();
				local vecPos = tTraceResult["pos"];

				if ( (vecEyePosition - vecPos).LengthSqr() <= 625.0 )
					hMuzzleFlashParticle.SetOrigin( vecPos - vecDirection );
				else
					hMuzzleFlashParticle.SetOrigin( vecEyePosition + vecDirection * 25.0 );
			}
		}
	}

	FindFireCrackerBlast = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "fire_cracker_blast"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnInfluenceEffectSpawn(hEntity, 1);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}
	}

	FindSpitterProjectile = function()
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "spitter_projectile"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnProjectileSpawn(hEntity, 2);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}
	}

	OnMolotovThrown = function(tParams)
	{
		local hEntity;
		while (hEntity = Entities.FindByClassname(hEntity, "molotov_projectile"))
		{
			if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
			{
				g_DynamicLight.OnProjectileSpawn(hEntity, 1);
				VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
			}
		}
	}

	OnWeaponFire = function(tParams)
	{
		if ( g_DynamicLightSettings["Allow"] && g_DynamicLightSettings["GlowMuzzleFlash"] )
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
				local hLight = VSLU.GetScriptScopeVar(hPlayer, "dynamic_light")["muzzle_flash"];

				if ( hLight && hLight.IsValid() && VSLU.IsEntityAlive(hPlayer) && NetProps.GetPropInt(hPlayer, "m_nWaterLevel") < 3 )
				{
					VSLU.AcceptEntityInput(hLight, "TurnOn");

					if (bAutomaticWeapon)
						NetProps.SetPropFloat(hLight, "m_Radius", RandomInt(0, 1) ? 65.0 : RandomFloat(155.0, 255.0));
					else
						NetProps.SetPropFloat(hLight, "m_Radius", RandomFloat(100.0, 255.0));

					g_DynamicLight.flMuzzleFlashTime[hPlayer.GetEntityIndex()] = Time() + 0.0334;
					VSLU.CreateTimer(0.0334, g_DynamicLight.PutOutMuzzleFlash, hLight, hPlayer.GetEntityIndex());
				}
				
				break;
			}
		}
	}

	OnAbilityUse = function(tParams)
	{
		if (tParams["ability"] == "ability_spit")
			VSLU.CreateTimer(0.24, g_DynamicLight.FindSpitterProjectile);
	}

	OnBreakProp = function(tParams)
	{
		VSLU.CreateTimer(0.01, g_DynamicLight.FindFireCrackerBlast);
	}

	ResetDynamicLightSettings_Cmd = function(hPlayer, sArgs)
	{
		if ( VSLU.Player.IsHost(hPlayer) )
		{
			g_DynamicLight.ParseConfigFile(true);
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}
	}

	ReloadDynamicLightSettings_Cmd = function(hPlayer, sArgs)
	{
		if ( VSLU.Player.IsHost(hPlayer) )
		{
			g_DynamicLight.ParseConfigFile();
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}
	}
};

function DynamicLight_Think()
{
	local hPlayer;
	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		if ( !VSLU.KeyInScriptScope(hPlayer, "dynamic_light") )
		{
			VSLU.SetScriptScopeVar(hPlayer, "dynamic_light", {
				name = null
				burning = false
				particle = null
				particle2 = null
				muzzle_flash = null
			});
		}

		local sActiveWeapon;
		local tParams = VSLU.GetScriptScopeVar(hPlayer, "dynamic_light");

		if ( g_DynamicLightSettings["Allow"] )
		{
			if ( VSLU.IsEntityAlive(hPlayer) )
			{
				local length = g_DynamicLight.aParticlesList.len();
				
				if ( hPlayer.IsSurvivor() )
				{
					if ( NetProps.GetPropInt(hPlayer, "m_nWaterLevel") == 3 )
						continue;

					if ( tParams["muzzle_flash"] )
					{
						if ( !tParams["muzzle_flash"].IsValid() )
							tParams["muzzle_flash"] = null;
					}
					else if ( g_DynamicLightSettings["GlowMuzzleFlash"] )
					{
						local hLight = tParams["muzzle_flash"] = SpawnEntityFromTable("light_dynamic", {
							_light = g_DynamicLightSettings["MuzzleFlashColor"]
							spotlight_radius = 32
							brightness = 1
							distance = 0
						});

						if ( VSLU.Player.IsHost(hPlayer) )
						{
							g_DynamicLight.hMuzzleFlashParticle = hLight;
							VSLU.SetScriptScopeVar(hLight, "owner", hPlayer);
						}
						else
						{
							VSLU.AttachEntity(hPlayer, hLight, "survivor_light");
						}

						VSLU.AcceptEntityInput(hLight, "TurnOff");
					}

					local bGlowMolotov = g_DynamicLightSettings["GlowMolotov"];
					local bGlowPipe = g_DynamicLightSettings["GlowPipe"];

					if ( (bGlowMolotov || bGlowPipe) && !hPlayer.IsIncapacitated() && NetProps.GetPropInt(hPlayer, "m_MoveType") != MOVETYPE_LADDER )
					{
						local hWeapon;
						local tInv = {};

						GetInvTable(hPlayer, tInv);

						if ( (hWeapon = hPlayer.GetActiveWeapon()) && !NetProps.GetPropInt(hWeapon, "m_bRedraw") )
							sActiveWeapon = hWeapon.GetClassname();

						if ( "slot2" in tInv )
						{
							local sClass = tInv["slot2"].GetClassname();

							if ( sClass != tParams["name"] && sClass == sActiveWeapon && length < g_DynamicLightSettings["Limit"] )
							{
								if ( sClass == "weapon_molotov" )
								{
									if ( bGlowMolotov )
									{
										local hLight = SpawnEntityFromTable("light_dynamic", {
											_light = g_DynamicLightSettings["FlameColor"]
											spotlight_radius = 128
											distance = g_DynamicLightSettings["MolotovRadius"]
											brightness = 1
											style = 6
										});

										VSLU.AttachEntity(hPlayer, hLight, g_DynamicLight.GetParticleAttachment( NetProps.GetPropString(hPlayer, "m_ModelName") ));

										g_DynamicLight.aParticlesList.push(hLight);

										g_DynamicLight.RemoveParticles(tParams);

										tParams["particle"] = hLight;
										tParams["name"] = sClass;
									}
								}
								else if ( sClass == "weapon_pipe_bomb" && bGlowPipe && length + 1 < g_DynamicLightSettings["Limit"] )
								{
									local flRadius = g_DynamicLightSettings["PipeRadius"];

									local hLight = SpawnEntityFromTable("light_dynamic", {
										_light = g_DynamicLightSettings["PipeBlinkColor"]
										spotlight_radius = 128
										distance = flRadius
										brightness = 1
									});

									local hLight2 = SpawnEntityFromTable("light_dynamic", {
										origin = hPlayer.EyePosition() + hPlayer.EyeAngles().Left() * 8
										_light = g_DynamicLightSettings["PipeFuseColor"]
										spotlight_radius = 32
										distance = g_DynamicLightSettings["PipeFuseRadius"]
										brightness = 2
										style = 6
									});

									g_DynamicLight.Blink(hLight, flRadius, g_DynamicLightSettings["PipeBlinkInterval"], true);

									VSLU.AttachEntity(hPlayer, hLight, g_DynamicLight.GetParticleAttachment( NetProps.GetPropString(hPlayer, "m_ModelName") ));
									VSLU.AttachEntity(hPlayer, hLight2, "armR_T");

									g_DynamicLight.aParticlesList.push(hLight);
									g_DynamicLight.aParticlesList.push(hLight2);

									g_DynamicLight.RemoveParticles(tParams);

									tParams["particle"] = hLight;
									tParams["particle2"] = hLight2;
									tParams["name"] = sClass;
								}
							}
						}
					}
				}
				else if ( g_DynamicLightSettings["GlowBurningInfected"] )
				{
					if ( hPlayer.IsOnFire() && NetProps.GetPropInt(hPlayer, "m_nWaterLevel") < 1 )
					{
						if ( !tParams["burning"] && length < g_DynamicLightSettings["Limit"] )
						{
							local hLight = SpawnEntityFromTable("light_dynamic", {
								origin = VSLU.Player.GetBodyPosition(hPlayer, 0.35)
								_light = g_DynamicLightSettings["FlameColor"]
								spotlight_radius = 128
								distance = g_DynamicLightSettings["BurningInfectedRadius"]
								brightness = 2
								style = 6
							});

							VSLU.AttachEntity(hPlayer, hLight);

							g_DynamicLight.aParticlesList.push(hLight);

							g_DynamicLight.RemoveParticles(tParams);
							tParams["particle"] = hLight;
						}

						tParams["burning"] = true;
					}
					else
					{
						if ( tParams["burning"] )
							g_DynamicLight.RemoveParticles(tParams);

						tParams["burning"] = false;
					}
				}
			}
		}

		if ( tParams["name"] != sActiveWeapon )
		{
			g_DynamicLight.RemoveParticles(tParams);

			tParams["name"] = null;
			tParams["particle"] = null;
			tParams["particle2"] = null;
		}
	}

	local hEntity;
	while (hEntity = Entities.FindByClassname(hEntity, "inferno"))
	{
		if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
		{
			g_DynamicLight.OnInfluenceEffectSpawn(hEntity, 0);
			VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
		}
	}

	hEntity = null;
	while (hEntity = Entities.FindByClassname(hEntity, "pipe_bomb_projectile"))
	{
		if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
		{
			g_DynamicLight.OnProjectileSpawn(hEntity, 0);
			VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
		}
	}

	hEntity = null;
	while (hEntity = Entities.FindByClassname(hEntity, "insect_swarm"))
	{
		if ( !VSLU.KeyInScriptScope(hEntity, "__dl_spawned") )
		{
			g_DynamicLight.OnInfluenceEffectSpawn(hEntity, 2);
			VSLU.SetScriptScopeVar(hEntity, "__dl_spawned", true);
		}
	}

	// newthread(g_DynamicLight.DynamicLight_ThinkThread).call();
}

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginDynamicLight);