// Cinematic Camera

class CPluginCinematicCamera extends VSLU.IScriptPlugin
{
	function Load()
	{
		::__ccam_frametime__ <- 1.0 / 30.0;

		VSLU.RegisterLoopFunction("CinematicCamera_Think2", 0.1);

		VSLU.RegisterButtonListener(IN_ATTACK, "g_CinematicCamera.OnAttackHold", BUTTON_STATE_HOLD);
		VSLU.RegisterButtonListener(IN_ATTACK2, "g_CinematicCamera.OnAttack2Hold", BUTTON_STATE_HOLD);
		VSLU.RegisterButtonListener(IN_ATTACK3, "g_CinematicCamera.OnAttack3Press", BUTTON_STATE_PRESSED);

		VSLU.RegisterButtonListener(IN_ALT1, "g_CinematicCamera.OnAlt1Press", BUTTON_STATE_PRESSED);
		VSLU.RegisterButtonListener(IN_ALT2, "g_CinematicCamera.OnAlt2Press", BUTTON_STATE_PRESSED);

		VSLU.RegisterButtonListener(IN_GRENADE1, "g_CinematicCamera.OnGrenade1Hold", BUTTON_STATE_HOLD);
		VSLU.RegisterButtonListener(IN_GRENADE2, "g_CinematicCamera.OnGrenade2Hold", BUTTON_STATE_HOLD);

		VSLU.HookEvent("player_incapacitated_start", g_CinematicCamera.OnPlayerIncapacitatedStart, g_CinematicCamera);
		VSLU.HookEvent("player_ledge_grab", g_CinematicCamera.OnPlayerLedgeGrab, g_CinematicCamera);
		VSLU.HookEvent("player_disconnect", g_CinematicCamera.OnPlayerDisconnect, g_CinematicCamera);

		VSLU.Hooks.RegisterHook(VSLU.Hooks.OnIteratePlayersPerTick, g_CinematicCamera.OnIteratePlayersPerTick);

		VSLU.RegisterChatCommand("!cc_reset", g_CinematicCamera.ResetRollAxis);
		VSLU.RegisterChatCommand("!cc_fov", g_CinematicCamera.ChangeFOV);
		VSLU.RegisterChatCommand("!cam", g_CinematicCamera.SwitchCamera);
		VSLU.RegisterChatCommand("!dec", g_CinematicCamera.DecreaseSpeed);
		VSLU.RegisterChatCommand("!inc", g_CinematicCamera.IncreaseSpeed);

		printl("[Cinematic Camera]\nAuthor: Sw1ft\nVersion: 2.1.7");
	}

	function Unload()
	{
		VSLU.RemoveLoopFunction("CinematicCamera_Think2", 0.1);

		VSLU.RemoveButtonListener(IN_ATTACK, "g_CinematicCamera.OnAttackHold");
		VSLU.RemoveButtonListener(IN_ATTACK2, "g_CinematicCamera.OnAttack2Hold");
		VSLU.RemoveButtonListener(IN_ATTACK3, "g_CinematicCamera.OnAttack3Press");

		VSLU.RemoveButtonListener(IN_ALT1, "g_CinematicCamera.OnAlt1Press");
		VSLU.RemoveButtonListener(IN_ALT2, "g_CinematicCamera.OnAlt2Press");

		VSLU.RemoveButtonListener(IN_GRENADE1, "g_CinematicCamera.OnGrenade1Hold");
		VSLU.RemoveButtonListener(IN_GRENADE2, "g_CinematicCamera.OnGrenade2Hold");

		VSLU.UnhookEvent("player_incapacitated_start", g_CinematicCamera.OnPlayerIncapacitatedStart, g_CinematicCamera);
		VSLU.UnhookEvent("player_ledge_grab", g_CinematicCamera.OnPlayerLedgeGrab, g_CinematicCamera);
		VSLU.UnhookEvent("player_disconnect", g_CinematicCamera.OnPlayerDisconnect, g_CinematicCamera);

		VSLU.Hooks.RemoveHook(VSLU.Hooks.OnIteratePlayersPerTick, g_CinematicCamera.OnIteratePlayersPerTick);

		VSLU.RemoveChatCommand("!cc_reset");
		VSLU.RemoveChatCommand("!cc_fov");
		VSLU.RemoveChatCommand("!cam");
		VSLU.RemoveChatCommand("!dec");
		VSLU.RemoveChatCommand("!inc");
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
	static m_sClassName = "CPluginCinematicCamera";
	static m_sScriptPluginName = "Cinematic Camera";
}

g_PluginCinematicCamera <- CPluginCinematicCamera();

if (!("g_CC_iSpeedFactorIndex" in this)) g_CC_iSpeedFactorIndex <- array(MAXCLIENTS + 1, 3);

g_CinematicCamera <-
{
	aSpeedFactor = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
	bCinematicCamera = array(MAXCLIENTS + 1, false)

	GetTickrate = function()
	{
		local __time__ = Time() + 1.0;
		local __ticks__ = 0;

		::get_tickrate <- function()
		{
			if (__time__ - Time() < 0.0)
			{
				// if (__ticks__ < 30) __ticks__ = 30;

				::__tickrate__ <- __ticks__;
				::__ccam_frametime__ <- 1.0 / __ticks__;

				RemoveOnTickFunction("get_tickrate");
				delete ::get_tickrate;

				printf(">> Tickrate - %d\n>> Frametime - %f", __tickrate__, __ccam_frametime__);
			}

			__ticks__++;
		}

		RegisterOnTickFunction("get_tickrate");
	}

	OnIteratePlayersPerTick = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()] && VSLU.KeyInScriptScope(hPlayer, "__cinema_camera"))
		{
			local tParams = VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera");
			local hEntity = tParams["camera"];

			if (hEntity.IsValid())
			{
				local flRoll = hEntity.GetAngles().z;

				// camera movement
				if (tParams["velocity"].IsZero(0.1))
					tParams["velocity"] *= 0;
				else
					tParams["velocity"] *= 0.85; // drag factor

				local flMaxSpeed = 900.0 * g_CinematicCamera.aSpeedFactor[g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()]];
				local buttons = NetProps.GetPropInt(hPlayer, "m_nButtons");

				if (buttons & IN_SPEED)
					flMaxSpeed /= 2;

				local flAddSpeed = flMaxSpeed - tParams["velocity"].Length();

				if (flAddSpeed > 0)
				{
					local flForwardSpeed = 0.0;
					local flSideSpeed = 0.0;
					local flUpSpeed = 0.0;

					local vecForward = hEntity.GetAngles().Forward();
					local vecLeft = hEntity.GetAngles().Left();

					if (buttons & IN_JUMP) flUpSpeed = flMaxSpeed;
					if (buttons & IN_DUCK) flUpSpeed = flUpSpeed + -flMaxSpeed;
					if (buttons & IN_FORWARD) flForwardSpeed = flMaxSpeed;
					if (buttons & IN_BACK) flForwardSpeed = flForwardSpeed + -flMaxSpeed;
					if (buttons & IN_MOVELEFT) flSideSpeed = -flMaxSpeed;
					if (buttons & IN_MOVERIGHT) flSideSpeed = flSideSpeed + flMaxSpeed;

					if (flForwardSpeed != 0 || flSideSpeed != 0 || flUpSpeed != 0)
					{
						local vecWishSpeed = Vector();
						vecWishSpeed.x = vecForward.x * flForwardSpeed + vecLeft.x * flSideSpeed;
						vecWishSpeed.y = vecForward.y * flForwardSpeed + vecLeft.y * flSideSpeed;
						vecWishSpeed.z = vecForward.z * flForwardSpeed + vecLeft.z * flSideSpeed;

						if (flRoll != 0)
						{
							local vecUp = hEntity.GetAngles().Up();
							vecWishSpeed.x += vecUp.x * flUpSpeed;
							vecWishSpeed.y += vecUp.y * flUpSpeed;
							vecWishSpeed.z += vecUp.z * flUpSpeed;
						}
						else
						{
							vecWishSpeed.z += flUpSpeed;
						}

						tParams["velocity"] += vecWishSpeed.Normalize() * flAddSpeed * ::__ccam_frametime__ * 5;
					}
				}

				// camera orientation
				local eAngles = hPlayer.EyeAngles();
				local eAnglesDifference = eAngles - tParams["previous_angles"];

				if (fabs(eAngles.y - tParams["previous_angles"].y) > fabs(eAngles.y + tParams["previous_angles"].y))
					eAnglesDifference.y = eAngles.y + tParams["previous_angles"].y;

				tParams["angular_vel"] += eAnglesDifference;
				tParams["previous_angles"] = eAngles;

				local eAnglesAngularVel = tParams["angular_vel"] * 0.15; // smooth factor

				if (flRoll != 0)
				{
					eAnglesAngularVel.z = flRoll;
					eAnglesAngularVel = VSLU.Math.RotateOrientationWithQuaternion(eAnglesAngularVel);
					eAnglesAngularVel.z = 0;
				}

				local eAnglesOrientation = hEntity.GetAngles() + eAnglesAngularVel;
				eAnglesOrientation.y = VSLU.Math.NormalizeAngle(eAnglesOrientation.y);

				if (Vector(tParams["angular_vel"].x, tParams["angular_vel"].y, 0).IsZero(0.1))
					tParams["angular_vel"] *= 0;
				else
					tParams["angular_vel"] *= 0.95; // drag factor

				if (flRoll == 0)
				{
					if (eAnglesOrientation.x < -90.0 || eAnglesOrientation.x > 90.0)
					{
						eAnglesOrientation.x = eAnglesOrientation.x > 90.0 ? 90.0 : -90;
						tParams["angular_vel"].x = 0;
					}
				}
				else
				{
					while (eAnglesOrientation.x < -180.0) eAnglesOrientation.x += 360.0;
					while (eAnglesOrientation.x > 180.0) eAnglesOrientation.x -= 360.0;
				}

				// apply calculations
				hEntity.__KeyValueFromVector("origin", hEntity.GetOrigin() + tParams["velocity"] * __ccam_frametime__);
				hEntity.SetAngles(eAnglesOrientation);
			}
			else // this won't help if someone will delete the player's camera, but still.. why not?
			{
				tParams["disable"]();
				VSLU.RemoveScriptScopeKey(hPlayer, "__cinema_camera");
			}
		}

		return HOOK_CONTINUE;
	}

	SwitchCamera = function(hPlayer, sArgs)
	{
		if (VSLU.IsEntityAlive(hPlayer) && !hPlayer.IsIncapacitated())
		{
			if ("__smooth_target__" in getroottable() && __smooth_target__)
				return;

			if (VSLU.KeyInScriptScope(hPlayer, "__selfie_camera"))
			{
				if (g_SelfieCamera.bSelfieCamera[hPlayer.GetEntityIndex()])
					return;
			}

			if (!VSLU.KeyInScriptScope(hPlayer, "__cinema_camera"))
			{
				VSLU.SetScriptScopeVar(hPlayer, "__cinema_camera", {
					velocity = Vector()
					angular_vel = QAngle()
					previous_angles = QAngle()
					camera = SpawnEntityFromTable("point_viewcontrol_survivor", { targetname = "camera_" + hPlayer.GetPlayerUserId() })

					enable = function(){
						this.velocity = Vector(0, 0, 0);
						this.angular_vel = QAngle(0, 0, 0);
						this.previous_angles = QAngle(0, 0, 0);
						this.camera.SetOrigin(hPlayer.EyePosition());
						this.camera.SetAngles(hPlayer.EyeAngles());

						hPlayer.SetForwardVector(Vector(1, 0, 0));
						VSLU.Player.HideHUD(hPlayer, HIDE_HUD_WEAPON_SELECTION | HIDE_HUD_FLASHLIGHT | HIDE_HUD_HEALTH | HIDE_HUD_MISC | HIDE_HUD_CROSSHAIR);

						NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
						NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", IN_USE | IN_ZOOM);
						NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") | FL_ATCONTROLS);

						VSLU.AcceptEntityInput(this.camera, "Enable", "", 0.0, hPlayer);
					}

					disable = function(){
						if (hPlayer.GetActiveWeapon()) NetProps.SetPropFloat(hPlayer.GetActiveWeapon(), "m_flNextPrimaryAttack", Time());
						VSLU.Player.HideHUD(hPlayer, 0);

						NetProps.SetPropFloat(hPlayer, "m_flNextShoveTime", Time());
						NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
						NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", 0);
						NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") & ~FL_ATCONTROLS);

						VSLU.AcceptEntityInput(this.camera, "Disable", "", 0.0, hPlayer);
					}
				});
			}
			else if (!VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera")["camera"].IsValid())
			{
				VSLU.RemoveScriptScopeKey(hPlayer, "__cinema_camera");
				g_CinematicCamera.SwitchCamera(hPlayer, null);
				return;
			}

			local idx = hPlayer.GetEntityIndex();
			if (g_CinematicCamera.bCinematicCamera[idx])
			{
				VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera")["disable"]();
				EmitSoundOnClient("Buttons.snd11", hPlayer);
			}
			else
			{
				VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera")["enable"]();
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}

			g_CinematicCamera.bCinematicCamera[idx] = !g_CinematicCamera.bCinematicCamera[idx];
		}
	}

	ChangeFOV = function(hPlayer, sValue)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			if (sValue != null)
			{
				try
				{
					local iValue = sValue[0].tointeger();
					if (iValue >= 1 && iValue <= 180)
						NetProps.SetPropInt(hPlayer, "m_iFOV", iValue);
				}
				catch (e)
				{
				}
			}
			else
			{
				NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
			}
		}
	}

	ResetRollAxis = function(hPlayer, sArgs)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams = VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera");
			tParams["camera"].SetAngles(QAngle(tParams["camera"].GetAngles().x, tParams["camera"].GetAngles().y, 0));
			tParams["angular_vel"].z = 0.0;
		}
	}

	OnGrenade1Hold = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local fov = NetProps.GetPropInt(hPlayer, "m_iFOV");
			if (fov > 1) NetProps.SetPropInt(hPlayer, "m_iFOV", fov - 1);
		}
	}

	OnGrenade2Hold = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local fov = NetProps.GetPropInt(hPlayer, "m_iFOV");
			if (fov < 179) NetProps.SetPropInt(hPlayer, "m_iFOV", fov + 1);
		}
	}

	OnAttackHold = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams = VSLU.GetScriptScopeVar(hPlayer, "__cinema_camera");
			local eAngles = tParams["camera"].GetAngles();
			if (eAngles.z > -90) tParams["camera"].SetAngles(eAngles - QAngle(0, 0, 0.5));
		}
	}

	OnAttack2Hold = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams =VSLU. GetScriptScopeVar(hPlayer, "__cinema_camera");
			local eAngles = tParams["camera"].GetAngles();
			if (eAngles.z < 90) tParams["camera"].SetAngles(eAngles + QAngle(0, 0, 0.5));
		}
	}

	OnAttack3Press = function(hPlayer)
	{
		g_CinematicCamera.SwitchCamera(hPlayer, null);
	}

	DecreaseSpeed = function(hPlayer, sArgs)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()] && g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()] > 0)
			g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()]--;
	}

	IncreaseSpeed = function(hPlayer, sArgs)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()] && g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()] < 6)
			g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()]++;
	}

	OnAlt1Press = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()] && g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()] > 0)
			g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()]--;
	}

	OnAlt2Press = function(hPlayer)
	{
		if (g_CinematicCamera.bCinematicCamera[hPlayer.GetEntityIndex()] && g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()] < 6)
			g_CC_iSpeedFactorIndex[hPlayer.GetEntityIndex()]++;
	}

	OnPlayerIncapacitatedStart = function(tParams)
	{
		if (g_CinematicCamera.bCinematicCamera[tParams["_player"].GetEntityIndex()] && VSLU.KeyInScriptScope(tParams["_player"], "__cinema_camera"))
			VSLU.GetScriptScopeVar(tParams["_player"], "__cinema_camera")["disable"]();
	}

	OnPlayerLedgeGrab = function(tParams)
	{
		if (g_CinematicCamera.bCinematicCamera[tParams["_player"].GetEntityIndex()] && VSLU.KeyInScriptScope(tParams["_player"], "__cinema_camera"))
			VSLU.GetScriptScopeVar(tParams["_player"], "__cinema_camera")["disable"]();
	}

	OnPlayerDisconnect = function(tParams)
	{
		local hEntity;

		g_CinematicCamera.bCinematicCamera[tParams["_player"].GetEntityIndex()] = false;
		g_CC_iSpeedFactorIndex[tParams["_player"].GetEntityIndex()] = 3;
		
		if (hEntity = Entities.FindByName(null, "camera_" + tParams["_player"].GetPlayerUserId()))
			hEntity.Kill();
	}
};

function CinematicCamera_Think2()
{
	foreach (idx, val in g_CinematicCamera.bCinematicCamera)
	{
		if (val)
		{
			local hPlayer = PlayerInstanceFromIndex(idx);
			local hWeapon = hPlayer.GetActiveWeapon();

			if (hWeapon && NetProps.GetPropFloat(hWeapon, "m_flNextPrimaryAttack") <= Time())
				NetProps.SetPropFloat(hWeapon, "m_flNextPrimaryAttack", (1 << 30));

			if (NetProps.GetPropFloat(hPlayer, "m_flNextShoveTime") <= Time())
				NetProps.SetPropFloat(hPlayer, "m_flNextShoveTime", (1 << 30));
		}
	}
}

VSLU.ScriptPluginsHelper.AddScriptPlugin(g_PluginCinematicCamera);