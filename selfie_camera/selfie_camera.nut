// Squirrel
// Selfie Camera

class CSelfieCamera extends IScriptPlugin
{
	function Load()
	{
		RegisterOnTickFunction("g_tSelfieCamera.Camera_Think");
		HookEvent("player_disconnect", g_tSelfieCamera.OnPlayerDisconnect, g_tSelfieCamera);

		printl("[Selfie Camera]\nAuthor: Sw1ft\nVersion: 2.1");
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
		RegisterChatCommand("!sc", g_tSelfieCamera.SwitchCamera, true);
		RegisterChatCommand("!sc_dist", g_tSelfieCamera.SwitchCameraDistance, true, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	function _set(key, val) { throw null; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CSelfieCamera";
	static m_sScriptPluginName = "Selfie Camera";
}

g_SelfieCamera <- CSelfieCamera();

g_bSelfieCamera <- array(MAXCLIENTS + 1, false);
if (!("g_flCameraDistance" in this)) g_flCameraDistance <- array(MAXCLIENTS + 1, 25.0);

g_tSelfieCamera <-
{
	Camera_Think = function()
	{
		local hPlayer;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (hPlayer.IsAlive() && g_bSelfieCamera[hPlayer.GetEntityIndex()])
			{
				if (KeyInScriptScope(hPlayer, "selfie_camera"))
				{
					local hEntity = GetScriptScopeVar(hPlayer, "selfie_camera")["camera"];
					if (hEntity.IsValid())
					{
						local vecAngles = hPlayer.EyeAngles();
						local vecCameraOrigin = hPlayer.EyeAngles().Forward() * g_flCameraDistance[hPlayer.GetEntityIndex()] + hPlayer.GetVelocity() * NetProps.GetPropFloat(hPlayer, "m_fLerpTime");
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
		}
	}

	SwitchCameraDistance = function(hPlayer, sValue)
	{
		sValue = split(sValue, " ")[0];
		try {
			if (sValue.tointeger() >= 0 && sValue.tointeger() <= 100)
			{
				g_flCameraDistance[hPlayer.GetEntityIndex()] = sValue.tointeger();
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
		}
		catch (error) {

		}
	}

	SwitchCamera = function(hPlayer)
	{
		if ("__smooth_target__" in getroottable() && __smooth_target__)
				return;

		if (KeyInScriptScope(hPlayer, "cinema_camera"))
		{
			if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
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
			g_tSelfieCamera.SwitchCamera(hPlayer);
			return;
		}

		local idx = hPlayer.GetEntityIndex();
		if (g_bSelfieCamera[idx])
		{
			GetScriptScopeVar(hPlayer, "selfie_camera")["disable"]();
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
		else
		{
			GetScriptScopeVar(hPlayer, "selfie_camera")["enable"]();
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}

		g_bSelfieCamera[idx] = !g_bSelfieCamera[idx];
	}

	OnPlayerDisconnect = function(tParams)
	{
		local hEntity;
		g_bSelfieCamera[tParams["_player"].GetEntityIndex()] = false;
		g_flCameraDistance[tParams["_player"].GetEntityIndex()] = 25.0;
		if (hEntity = Entities.FindByName(null, "camera_" + tParams["_player"].GetPlayerUserId())) hEntity.Kill()
	}
};

g_ScriptPluginsHelper.AddScriptPlugin(g_SelfieCamera);