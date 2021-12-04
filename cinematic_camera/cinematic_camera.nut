// Squirrel
// Cinematic Camera

class CCinematicCamera extends IScriptPlugin
{
	function Load()
	{
		::__frametime__ <- 1.0 / 30.0;

		RegisterOnTickFunction("g_tCinematicCamera.Camera_Think");
		RegisterLoopFunction("CinematicCamera_Think2", 0.1);

		RegisterButtonListener(IN_ATTACK, "g_tCinematicCamera.OnAttackHold", eButtonType.Hold);
		RegisterButtonListener(IN_ATTACK2, "g_tCinematicCamera.OnAttack2Hold", eButtonType.Hold);
		RegisterButtonListener(IN_ATTACK3, "g_tCinematicCamera.OnAttack3Press", eButtonType.Pressed);

		RegisterButtonListener(IN_ALT1, "g_tCinematicCamera.OnAlt1Press", eButtonType.Pressed);
		RegisterButtonListener(IN_ALT2, "g_tCinematicCamera.OnAlt2Press", eButtonType.Pressed);

		RegisterButtonListener(IN_GRENADE1, "g_tCinematicCamera.OnGrenade1Hold", eButtonType.Hold);
		RegisterButtonListener(IN_GRENADE2, "g_tCinematicCamera.OnGrenade2Hold", eButtonType.Hold);

		HookEvent("player_incapacitated_start", g_tCinematicCamera.OnPlayerIncapacitatedStart, g_tCinematicCamera);
		HookEvent("player_ledge_grab", g_tCinematicCamera.OnPlayerLedgeGrab, g_tCinematicCamera);
		HookEvent("player_disconnect", g_tCinematicCamera.OnPlayerDisconnect, g_tCinematicCamera);

		printl("[Cinematic Camera]\nAuthor: Sw1ft\nVersion: 2.1.5");
	}

	function Unload()
	{

	}

	function OnRoundStartPost()
	{
		// CreateTimer(3.0, g_tCinematicCamera.GetTickrate);
	}

	function OnRoundEnd()
	{

	}

	function AdditionalClassMethodsInjected()
	{
		RegisterChatCommand("!cc_reset", g_tCinematicCamera.ResetRollAxis, true);
		RegisterChatCommand("!cc_fov", g_tCinematicCamera.ChangeFOV, true, true);
		RegisterChatCommand("!cam", g_tCinematicCamera.SwitchCamera, true);
		RegisterChatCommand("!dec", g_tCinematicCamera.DecreaseSpeed, true);
		RegisterChatCommand("!inc", g_tCinematicCamera.IncreaseSpeed, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	function _set(key, val) { throw null; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CCinematicCamera";
	static m_sScriptPluginName = "Cinematic Camera";
}

g_CinematicCamera <- CCinematicCamera();

g_bCinematicCamera <- array(MAXCLIENTS + 1, false);
g_aSpeedFactor <- [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

if (!("g_iSpeedFactorIndex" in this)) g_iSpeedFactorIndex <- array(MAXCLIENTS + 1, 3);

g_tCinematicCamera <-
{
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
				::__frametime__ <- 1.0 / __ticks__;

				RemoveOnTickFunction("get_tickrate");
				delete ::get_tickrate;

				printf(">> Tickrate - %d\n>> Frametime - %f", __tickrate__, __frametime__);
			}

			__ticks__++;
		}

		RegisterOnTickFunction("get_tickrate");
	}

	Camera_Think = function()
	{
		local hPlayer;
		while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
		{
			if (g_bCinematicCamera[hPlayer.GetEntityIndex()] && KeyInScriptScope(hPlayer, "cinema_camera"))
			{
				local tParams = GetScriptScopeVar(hPlayer, "cinema_camera");
				local hEntity = tParams["camera"];

				if (hEntity.IsValid())
				{
					local flRoll = hEntity.GetAngles().z;

					// camera movement
					if (tParams["velocity"].IsZero(0.1))
						tParams["velocity"] *= 0;
					else
						tParams["velocity"] *= 0.85; // drag factor

					local flMaxSpeed = 900.0 * g_aSpeedFactor[g_iSpeedFactorIndex[hPlayer.GetEntityIndex()]];
					local buttons = NetProps.GetPropInt(hPlayer, "m_nButtons");

					if (buttons & IN_SPEED) flMaxSpeed /= 2;

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

							tParams["velocity"] += vecWishSpeed.Normalize() * flAddSpeed * __frametime__ * 5;
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
						eAnglesAngularVel = RotateOrientationWithQuaternion(eAnglesAngularVel);
						eAnglesAngularVel.z = 0;
					}

					local eAnglesOrientation = hEntity.GetAngles() + eAnglesAngularVel;
					eAnglesOrientation.y = Math.NormalizeAngle(eAnglesOrientation.y);

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
					hEntity.__KeyValueFromVector("origin", hEntity.GetOrigin() + tParams["velocity"] * __frametime__);
					hEntity.SetAngles(eAnglesOrientation);
				}
				else // this won't help if someone will delete the player's camera, but still.. why not?
				{
					tParams["disable"]();
					RemoveScriptScopeKey(hPlayer, "cinema_camera");
				}
			}
		}
	}

	SwitchCamera = function(hPlayer)
	{
		if (hPlayer.IsAlive() && !hPlayer.IsIncapacitated())
		{
			if ("__smooth_target__" in getroottable() && __smooth_target__)
				return;

			if (KeyInScriptScope(hPlayer, "selfie_camera"))
			{
				if (g_bSelfieCamera[hPlayer.GetEntityIndex()])
					return;
			}

			if (!KeyInScriptScope(hPlayer, "cinema_camera"))
			{
				SetScriptScopeVar(hPlayer, "cinema_camera", {
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
						hPlayer.HideHUD(HIDE_HUD_WEAPON_SELECTION | HIDE_HUD_FLASHLIGHT | HIDE_HUD_HEALTH | HIDE_HUD_MISC | HIDE_HUD_CROSSHAIR);

						NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
						NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", IN_USE | IN_ZOOM);
						NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") | FL_ATCONTROLS);

						AcceptEntityInput(this.camera, "Enable", "", 0.0, hPlayer);
					}

					disable = function(){
						if (hPlayer.GetActiveWeapon()) NetProps.SetPropFloat(hPlayer.GetActiveWeapon(), "m_flNextPrimaryAttack", Time());
						hPlayer.HideHUD(0);

						NetProps.SetPropFloat(hPlayer, "m_flNextShoveTime", Time());
						NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
						NetProps.SetPropInt(hPlayer, "m_afButtonDisabled", 0);
						NetProps.SetPropInt(hPlayer, "m_fFlags", NetProps.GetPropInt(hPlayer, "m_fFlags") & ~FL_ATCONTROLS);

						AcceptEntityInput(this.camera, "Disable", "", 0.0, hPlayer);
					}
				});
			}
			else if (!GetScriptScopeVar(hPlayer, "cinema_camera")["camera"].IsValid())
			{
				RemoveScriptScopeKey(hPlayer, "cinema_camera");
				g_tCinematicCamera.SwitchCamera(hPlayer);
				return;
			}

			local idx = hPlayer.GetEntityIndex();
			if (g_bCinematicCamera[idx])
			{
				GetScriptScopeVar(hPlayer, "cinema_camera")["disable"]();
				EmitSoundOnClient("Buttons.snd11", hPlayer);
			}
			else
			{
				GetScriptScopeVar(hPlayer, "cinema_camera")["enable"]();
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}

			g_bCinematicCamera[idx] = !g_bCinematicCamera[idx];
		}
	}

	ChangeFOV = function(hPlayer, sValue)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			if (sValue != CMD_EMPTY_ARGUMENT)
			{
				sValue = split(sValue, " ")[0];
				try {
					sValue = sValue.tointeger();
					if (sValue >= 1 && sValue <= 180)
						NetProps.SetPropInt(hPlayer, "m_iFOV", sValue);
				}
				catch (error) {
					
				}
			}
			else
			{
				NetProps.SetPropInt(hPlayer, "m_iFOV", 90);
			}
		}
	}

	ResetRollAxis = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams = GetScriptScopeVar(hPlayer, "cinema_camera");
			tParams["camera"].SetAngles(QAngle(tParams["camera"].GetAngles().x, tParams["camera"].GetAngles().y, 0));
			tParams["angular_vel"].z = 0.0;
		}
	}

	OnGrenade1Hold = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local fov = NetProps.GetPropInt(hPlayer, "m_iFOV");
			if (fov > 1) NetProps.SetPropInt(hPlayer, "m_iFOV", fov - 1);
		}
	}

	OnGrenade2Hold = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local fov = NetProps.GetPropInt(hPlayer, "m_iFOV");
			if (fov < 179) NetProps.SetPropInt(hPlayer, "m_iFOV", fov + 1);
		}
	}

	OnAttackHold = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams = GetScriptScopeVar(hPlayer, "cinema_camera");
			local eAngles = tParams["camera"].GetAngles();
			if (eAngles.z > -90) tParams["camera"].SetAngles(eAngles - QAngle(0, 0, 0.5));
		}
	}

	OnAttack2Hold = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
		{
			local tParams = GetScriptScopeVar(hPlayer, "cinema_camera");
			local eAngles = tParams["camera"].GetAngles();
			if (eAngles.z < 90) tParams["camera"].SetAngles(eAngles + QAngle(0, 0, 0.5));
		}
	}

	OnAttack3Press = function(hPlayer)
	{
		g_tCinematicCamera.SwitchCamera(hPlayer);
	}

	DecreaseSpeed = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()] && g_iSpeedFactorIndex[hPlayer.GetEntityIndex()] > 0)
			g_iSpeedFactorIndex[hPlayer.GetEntityIndex()]--;
	}

	IncreaseSpeed = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()] && g_iSpeedFactorIndex[hPlayer.GetEntityIndex()] < 6)
			g_iSpeedFactorIndex[hPlayer.GetEntityIndex()]++;
	}

	OnAlt1Press = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()] && g_iSpeedFactorIndex[hPlayer.GetEntityIndex()] > 0)
			g_iSpeedFactorIndex[hPlayer.GetEntityIndex()]--;
	}

	OnAlt2Press = function(hPlayer)
	{
		if (g_bCinematicCamera[hPlayer.GetEntityIndex()] && g_iSpeedFactorIndex[hPlayer.GetEntityIndex()] < 6)
			g_iSpeedFactorIndex[hPlayer.GetEntityIndex()]++;
	}

	OnPlayerIncapacitatedStart = function(tParams)
	{
		if (g_bCinematicCamera[tParams["_player"].GetEntityIndex()] && KeyInScriptScope(tParams["_player"], "cinema_camera"))
			GetScriptScopeVar(tParams["_player"], "cinema_camera")["disable"]();
	}

	OnPlayerLedgeGrab = function(tParams)
	{
		if (g_bCinematicCamera[tParams["_player"].GetEntityIndex()] && KeyInScriptScope(tParams["_player"], "cinema_camera"))
			GetScriptScopeVar(tParams["_player"], "cinema_camera")["disable"]();
	}

	OnPlayerDisconnect = function(tParams)
	{
		local hEntity;
		g_bCinematicCamera[tParams["_player"].GetEntityIndex()] = false;
		g_iSpeedFactorIndex[tParams["_player"].GetEntityIndex()] = 3;
		if (hEntity = Entities.FindByName(null, "camera_" + tParams["_player"].GetPlayerUserId())) hEntity.Kill();
	}
};

function CinematicCamera_Think2()
{
	foreach (idx, val in g_bCinematicCamera)
	{
		if (val)
		{
			local hPlayer = PlayerInstanceFromIndex(idx);
			local hWeapon = hPlayer.GetActiveWeapon();
			if (hWeapon && NetProps.GetPropFloat(hWeapon, "m_flNextPrimaryAttack") <= Time()) NetProps.SetPropFloat(hWeapon, "m_flNextPrimaryAttack", (1 << 30));
			if (NetProps.GetPropFloat(hPlayer, "m_flNextShoveTime") <= Time()) NetProps.SetPropFloat(hPlayer, "m_flNextShoveTime", (1 << 30));
		}
	}
}

g_ScriptPluginsHelper.AddScriptPlugin(g_CinematicCamera);
