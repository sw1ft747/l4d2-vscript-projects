// Selfie Camera

class CSelfieCamera extends IScriptPlugin
{
	function Load()
	{
		RegisterOnTickFunction("g_SelfieCamera.Camera_Think");
		HookEvent("player_disconnect", g_SelfieCamera.OnPlayerDisconnect, g_SelfieCamera);

		printl("[Selfie Camera]\nAuthor: Sw1ft\nVersion: 2.1.1");
	}

	function Unload()
	{
		RemoveOnTickFunction("g_SelfieCamera.Camera_Think");
		UnhookEvent("player_disconnect", g_SelfieCamera.OnPlayerDisconnect, g_SelfieCamera);

		RemoveChatCommand("!sc");
		RemoveChatCommand("!sc_dist");
	}

	function OnRoundStartPost()
	{
	}

	function OnRoundEnd()
	{
	}

	function OnExtendClassMethods()
	{
		g_Hooks.RegisterHook(g_Hooks.OnIteratePlayersPerTick, g_SelfieCamera.OnIteratePlayersPerTick);

		RegisterChatCommand("!sc", g_SelfieCamera.SwitchCamera, true);
		RegisterChatCommand("!sc_dist", g_SelfieCamera.SwitchCameraDistance, true, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CSelfieCamera";
	static m_sScriptPluginName = "Selfie Camera";
}

g_PluginSelfieCamera <- CSelfieCamera();

if (!("g_SC_flCameraDistance" in this)) g_SC_flCameraDistance <- array(MAXCLIENTS + 1, 25.0);

g_SelfieCamera <-
{
	bSelfieCamera = array(MAXCLIENTS + 1, false)

	OnIteratePlayersPerTick = function(hPlayer)
	{
		if (hPlayer.IsAlive() && g_SelfieCamera.bSelfieCamera[hPlayer.GetEntityIndex()])
		{
			if (KeyInScriptScope(hPlayer, "selfie_camera"))
			{
				local hEntity = GetScriptScopeVar(hPlayer, "selfie_camera")["camera"];
				if (hEntity.IsValid())
				{
					local vecAngles = hPlayer.EyeAngles();
					local vecCameraOrigin = hPlayer.EyeAngles().Forward() * g_SC_flCameraDistance[hPlayer.GetEntityIndex()] + hPlayer.GetVelocity() * NetProps.GetPropFloat(hPlayer, "m_fLerpTime");
					local flCameraDistance = vecCameraOrigin.Length();
					local vecTrace = hPlayer.DoTraceLine(eTrace.Type_Pos, flCameraDistance, eTrace.Mask_Shot);

					if ((hPlayer.EyePosition() - vecTrace).Length() - 1 >= flCameraDistance)
						hEntity.__KeyValueFromVector("origin", hPlayer.EyePosition() + vecCameraOrigin);
					else
						hEntity.__KeyValueFromVector("origin", vecTrace);

					hEntity.__KeyValueFromVector("angles", Vector(vecAngles.x * -1, vecAngles.y + 180, 0));
				}
				else
				{
					GetScriptScopeVar(hPlayer, "selfie_camera")["disable"]();
					RemoveScriptScopeKey(hPlayer, "selfie_camera");
				}
			}
		}

		return HOOK_CONTINUE;
	}

	SwitchCameraDistance = function(hPlayer, sValue)
	{
		sValue = split(sValue, " ")[0];
		try
		{
			if (sValue.tointeger() >= 0 && sValue.tointeger() <= 100)
			{
				g_SC_flCameraDistance[hPlayer.GetEntityIndex()] = sValue.tointeger();
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
		}
		catch (error)
		{
		}
	}

	SwitchCamera = function(hPlayer)
	{
		if ("__smooth_target__" in getroottable() && __smooth_target__)
				return;

		if (KeyInScriptScope(hPlayer, "cinema_camera"))
		{
			if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
				return;
		}

		if (!KeyInScriptScope(hPlayer, "selfie_camera"))
		{
			SetScriptScopeVar(hPlayer, "selfie_camera", {
				camera = SpawnEntityFromTable("point_viewcontrol_survivor", { targetname = "camera_" + hPlayer.GetPlayerUserId() })
				enable = function(){ AcceptEntityInput(this.camera, "Enable", "", 0.0, hPlayer); }
				disable = function(){ AcceptEntityInput(this.camera, "Disable", "", 0.0, hPlayer); }
			});
		}
		else if (!GetScriptScopeVar(hPlayer, "selfie_camera")["camera"].IsValid())
		{
			RemoveScriptScopeKey(hPlayer, "selfie_camera");
			g_SelfieCamera.SwitchCamera(hPlayer);

			return;
		}

		local idx = hPlayer.GetEntityIndex();

		if (g_SelfieCamera.bSelfieCamera[idx])
		{
			GetScriptScopeVar(hPlayer, "selfie_camera")["disable"]();
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
		else
		{
			GetScriptScopeVar(hPlayer, "selfie_camera")["enable"]();
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}

		g_SelfieCamera.bSelfieCamera[idx] = !g_SelfieCamera.bSelfieCamera[idx];
	}

	OnPlayerDisconnect = function(tParams)
	{
		local hEntity;
		g_SelfieCamera.bSelfieCamera[tParams["_player"].GetEntityIndex()] = false;
		g_SC_flCameraDistance[tParams["_player"].GetEntityIndex()] = 25.0;
		if (hEntity = Entities.FindByName(null, "camera_" + tParams["_player"].GetPlayerUserId())) hEntity.Kill()
	}
};

g_ScriptPluginsHelper.AddScriptPlugin(g_PluginSelfieCamera);