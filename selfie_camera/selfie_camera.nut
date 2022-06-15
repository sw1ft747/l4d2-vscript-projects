// Selfie Camera

class CPluginSelfieCamera extends VSLU.IScriptPlugin
{
	function Load()
	{
		VSLU.RegisterOnTickFunction("g_SelfieCamera.Camera_Think");
		VSLU.HookEvent("player_disconnect", g_SelfieCamera.OnPlayerDisconnect, g_SelfieCamera);

		VSLU.Hooks.RegisterHook(VSLU.Hooks.OnIteratePlayersPerTick, g_SelfieCamera.OnIteratePlayersPerTick);

		VSLU.RegisterChatCommand("!sc", g_SelfieCamera.SwitchCamera);
		VSLU.RegisterChatCommand("!sc_dist", g_SelfieCamera.SwitchCameraDistance);

		printl("[Selfie Camera]\nAuthor: Sw1ft\nVersion: 2.1.2");
	}

	function Unload()
	{
		VSLU.RemoveOnTickFunction("g_SelfieCamera.Camera_Think");
		VSLU.UnhookEvent("player_disconnect", g_SelfieCamera.OnPlayerDisconnect, g_SelfieCamera);

		VSLU.Hooks.RemoveHook(VSLU.Hooks.OnIteratePlayersPerTick, g_SelfieCamera.OnIteratePlayersPerTick);

		VSLU.RemoveChatCommand("!sc");
		VSLU.RemoveChatCommand("!sc_dist");
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
	static m_sClassName = "CPluginSelfieCamera";
	static m_sScriptPluginName = "Selfie Camera";
}

g_PluginSelfieCamera <- CPluginSelfieCamera();

if (!("g_SC_flCameraDistance" in this)) g_SC_flCameraDistance <- array(MAXCLIENTS + 1, 25.0);

g_SelfieCamera <-
{
	bSelfieCamera = array(MAXCLIENTS + 1, false)

	OnIteratePlayersPerTick = function(hPlayer)
	{
		if (VSLU.IsEntityAlive(hPlayer) && g_SelfieCamera.bSelfieCamera[hPlayer.GetEntityIndex()])
		{
			if (VSLU.KeyInScriptScope(hPlayer, "__selfie_camera"))
			{
				local hEntity = VSLU.GetScriptScopeVar(hPlayer, "__selfie_camera")["camera"];

				if (hEntity.IsValid())
				{
					local tTraceResult = {};

					local vecAngles = hPlayer.EyeAngles();
					local vecCameraOrigin = hPlayer.EyeAngles().Forward() * g_SC_flCameraDistance[hPlayer.GetEntityIndex()] + hPlayer.GetVelocity() * NetProps.GetPropFloat(hPlayer, "m_fLerpTime");
					local flCameraDistance = vecCameraOrigin.Length();

					VSLU.Player.TraceLine(hPlayer, tTraceResult);
					local vecTrace = tTraceResult["pos"];

					if ((hPlayer.EyePosition() - vecTrace).Length() - 1 >= flCameraDistance)
						hEntity.__KeyValueFromVector("origin", hPlayer.EyePosition() + vecCameraOrigin);
					else
						hEntity.__KeyValueFromVector("origin", vecTrace);

					hEntity.__KeyValueFromVector("angles", Vector(vecAngles.x * -1, vecAngles.y + 180, 0));
				}
				else
				{
					VSLU.GetScriptScopeVar(hPlayer, "__selfie_camera")["disable"]();
					VSLU.RemoveScriptScopeKey(hPlayer, "__selfie_camera");
				}
			}
		}

		return HOOK_CONTINUE;
	}

	SwitchCameraDistance = function(hPlayer, sValue)
	{
		if (sValue == null)
		{
			g_SC_flCameraDistance[hPlayer.GetEntityIndex()] = 25.0;
			return;
		}

		try
		{
			local iValue = sValue[0].tointeger();

			if (iValue >= 0 && iValue <= 100)
			{
				g_SC_flCameraDistance[hPlayer.GetEntityIndex()] = iValue;
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
		}
		catch (e)
		{
		}
	}

	SwitchCamera = function(hPlayer, sArgs)
	{
		if ("__smooth_target__" in getroottable() && __smooth_target__)
				return;

		if (VSLU.KeyInScriptScope(hPlayer, "__cinema_camera"))
		{
			if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
				return;
		}

		if (!VSLU.KeyInScriptScope(hPlayer, "__selfie_camera"))
		{
			VSLU.SetScriptScopeVar(hPlayer, "__selfie_camera", {
				camera = SpawnEntityFromTable("point_viewcontrol_survivor", { targetname = "camera_" + hPlayer.GetPlayerUserId() })
				enable = function(){ VSLU.AcceptEntityInput(this.camera, "Enable", "", 0.0, hPlayer); }
				disable = function(){ VSLU.AcceptEntityInput(this.camera, "Disable", "", 0.0, hPlayer); }
			});
		}
		else if (!VSLU.GetScriptScopeVar(hPlayer, "__selfie_camera")["camera"].IsValid())
		{
			VSLU.RemoveScriptScopeKey(hPlayer, "__selfie_camera");
			g_SelfieCamera.SwitchCamera(hPlayer, null);

			return;
		}

		local idx = hPlayer.GetEntityIndex();

		if (g_SelfieCamera.bSelfieCamera[idx])
		{
			VSLU.GetScriptScopeVar(hPlayer, "__selfie_camera")["disable"]();
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
		else
		{
			VSLU.GetScriptScopeVar(hPlayer, "__selfie_camera")["enable"]();
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

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginSelfieCamera);