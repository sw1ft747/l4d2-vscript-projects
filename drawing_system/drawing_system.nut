// Drawing System

class CDrawingSystem extends IScriptPlugin
{
	function Load()
	{
		RegisterOnTickFunction("g_DrawingSystem.Lines_Think");

		HookEvent("player_disconnect", g_DrawingSystem.OnPlayerDisconnect, g_DrawingSystem);

		printl("[Drawing System]\nAuthor: Sw1ft\nVersion: 1.0.2");
	}

	function Unload()
	{
		RemoveOnTickFunction("g_DrawingSystem.Lines_Think");

		UnhookEvent("player_disconnect", g_DrawingSystem.OnPlayerDisconnect, g_DrawingSystem);

		RemoveChatCommand("!ds_save");
		RemoveChatCommand("!ds_load");
		RemoveChatCommand("!ds_usage");
		RemoveChatCommand("!ds_point");
		RemoveChatCommand("!ds_determine");
		RemoveChatCommand("!ds_autostart");
		RemoveChatCommand("!ds_lremove");
		RemoveChatCommand("!ds_prst");
		RemoveChatCommand("!ds_color");
		RemoveChatCommand("!ds_width");
		RemoveChatCommand("!ds_scroll");
		RemoveChatCommand("!ds_amplitude");
		RemoveChatCommand("!ds_figure");
		RemoveChatCommand("!ds_clr");
		RemoveChatCommand("!ds_remove");

		RemoveUserCommand("ds_save");
		RemoveUserCommand("ds_load");
		RemoveUserCommand("ds_usage");
		RemoveUserCommand("ds_point");
		RemoveUserCommand("ds_determine");
		RemoveUserCommand("ds_autostart");
		RemoveUserCommand("ds_lremove");
		RemoveUserCommand("ds_prst");
		RemoveUserCommand("ds_color");
		RemoveUserCommand("ds_width");
		RemoveUserCommand("ds_scroll");
		RemoveUserCommand("ds_amplitude");
		RemoveUserCommand("ds_figure");
		RemoveUserCommand("ds_clr");
		RemoveUserCommand("ds_remove");
		RemoveUserCommand("ds_figure_radius");
	}

	function OnRoundStartPost()
	{
	}

	function OnRoundEnd()
	{
	}

	function OnExtendClassMethods()
	{
		RegisterChatCommand("!ds_save", g_DrawingSystem.SaveLines, true);
		RegisterChatCommand("!ds_load", g_DrawingSystem.LoadLines, true);
		RegisterChatCommand("!ds_usage", g_DrawingSystem.SwitchUsage, true);
		RegisterChatCommand("!ds_point", g_DrawingSystem.SetLinePoint, true);
		RegisterChatCommand("!ds_determine", g_DrawingSystem.DetermineWallNormal, true);
		RegisterChatCommand("!ds_autostart", g_DrawingSystem.AutoLineStart, true);
		RegisterChatCommand("!ds_lremove", g_DrawingSystem.RemovePreviousLine, true);
		RegisterChatCommand("!ds_prst", g_DrawingSystem.ResetPreviousPoint, true);
		RegisterChatCommand("!ds_color", g_DrawingSystem.ChangeLineColor, true, true);
		RegisterChatCommand("!ds_width", g_DrawingSystem.ChangeWidth, true, true);
		RegisterChatCommand("!ds_scroll", g_DrawingSystem.ChangeScroll, true, true);
		RegisterChatCommand("!ds_amplitude", g_DrawingSystem.ChangeAmplitude, true, true);
		RegisterChatCommand("!ds_figure", g_DrawingSystem.DrawFigure_Cmd, true, true);
		RegisterChatCommand("!ds_clr", g_DrawingSystem.ClearLines, true, true);
		RegisterChatCommand("!ds_remove", g_DrawingSystem.RemoveLine, true, true);

		RegisterUserCommand("ds_save", g_DrawingSystem.SaveLines);
		RegisterUserCommand("ds_load", g_DrawingSystem.LoadLines);
		RegisterUserCommand("ds_usage", g_DrawingSystem.SwitchUsage);
		RegisterUserCommand("ds_point", g_DrawingSystem.SetLinePoint);
		RegisterUserCommand("ds_determine", g_DrawingSystem.DetermineWallNormal);
		RegisterUserCommand("ds_autostart", g_DrawingSystem.AutoLineStart);
		RegisterUserCommand("ds_lremove", g_DrawingSystem.RemovePreviousLine);
		RegisterUserCommand("ds_prst", g_DrawingSystem.ResetPreviousPoint);
		RegisterUserCommand("ds_color", g_DrawingSystem.ChangeLineColor, true);
		RegisterUserCommand("ds_width", g_DrawingSystem.ChangeWidth, true);
		RegisterUserCommand("ds_scroll", g_DrawingSystem.ChangeScroll, true);
		RegisterUserCommand("ds_amplitude", g_DrawingSystem.ChangeAmplitude, true);
		RegisterUserCommand("ds_figure", g_DrawingSystem.DrawFigure_Cmd, true);
		RegisterUserCommand("ds_clr", g_DrawingSystem.ClearLines, true);
		RegisterUserCommand("ds_remove", g_DrawingSystem.RemoveLine, true);
		RegisterUserCommand("ds_figure_radius", g_DrawingSystem.SetFigureRadius, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CDrawingSystem";
	static m_sScriptPluginName = "Drawing System";
}

g_PluginDrawingSystem <- CDrawingSystem();

class CDSLine
{
	constructor(hEntity, vecEndPos, sColor, iScroll, flWidth, flAmplitude)
	{
		m_hEntity = hEntity;
		m_vecEndPos = vecEndPos;
		m_sColor = sColor;
		m_iScroll = iScroll;
		m_flWidth = flWidth;
		m_flAmplitude = flAmplitude;
	}

	function SetEndPosition() { NetProps.SetPropVector(m_hEntity, "m_vecEndPos", m_vecEndPos); }

	m_sColor = null;
	m_iScroll = null;
	m_flWidth = null;
	m_flAmplitude = null;
	m_hEntity = null;
	m_vecEndPos = null;
}

if (!("g_bDSHostOnly" in this)) g_bDSHostOnly <- false;
if (!("g_bDSDetermineWallNormal" in this)) g_bDSDetermineWallNormal <- true;

if (!("g_bDSAutoLineStart" in this)) g_bDSAutoLineStart <- array(MAXCLIENTS + 1, false);
if (!("g_sDSLineColor" in this)) g_sDSLineColor <- array(MAXCLIENTS + 1, "0 255 0");
if (!("g_iDSLineScroll" in this)) g_iDSLineScroll <- array(MAXCLIENTS + 1, 50);
if (!("g_flDSLineWidth" in this)) g_flDSLineWidth <- array(MAXCLIENTS + 1, 2.0);
if (!("g_flDSLineAmplitude" in this)) g_flDSLineAmplitude <- array(MAXCLIENTS + 1, 0.0);
if (!("g_flDSFigureRadius" in this)) g_flDSFigureRadius <- array(MAXCLIENTS + 1, 100.0);

g_aDSLines <- [];
g_aDSPreviousLines <- [];
g_vecDSPreviousPoint <- array(MAXCLIENTS + 1, null);

for (local i = 0; i < MAXCLIENTS + 1; i++)
	g_aDSPreviousLines.push([]);

function __kvstr_to_vec(str)
{
	local vec = split(str, " ");
	local x = vec[0].tofloat();
	local y = vec[1].tofloat();
	local z = vec[2].tofloat();
	return Vector(x, y, z);
}

g_DrawingSystem <-
{
	SerializeObject = function(tObject, sStart = "{\n", sEnd = "}\n", bIndice = true)
	{
		local sOutput = sStart;
		local sIndiceString, keyType, keyStr, reg;

		foreach (key, val in tObject)
		{
			keyType = typeof key;
			if (keyType == "instance" || keyType == "class" || keyType == "function")
				continue;

			keyStr = key.tostring();
			sIndiceString = (bIndice ? (keyStr + " = ") : "");

			switch (typeof val)
			{
			case "integer":
			case "float":
				sOutput += sIndiceString + val + "\n";
				break;

			case "bool":
				sOutput += sIndiceString + (val ? "true" : "false") + "\n";
				break;

			case "table":
				sOutput += sIndiceString + g_DrawingSystem.SerializeObject(val);
				break;

			case "array":
				sOutput += sIndiceString + g_DrawingSystem.SerializeObject(val, "[\n", "],\n", false);
				break;

			case "string":
				sOutput += sIndiceString + format("\"%s\"\n", val);
				break;
			}
		}

		sOutput += sEnd;
		return sOutput;
	}

	CreateLine = function(idx, userid, vecStart, vecEnd, bSoundNotification, sColor = null, iScroll = null, flWidth = null, flAmplitude = null)
	{
		if (sColor == null) sColor = g_sDSLineColor[idx];
		if (iScroll == null) iScroll = g_iDSLineScroll[idx];
		if (flWidth == null) flWidth = g_flDSLineWidth[idx];
		if (flAmplitude == null) flAmplitude = g_flDSLineAmplitude[idx];

		local line = CDSLine(SpawnEntityFromTable("env_laser", {
			renderamt = 255
			damage = 0
			origin = vecStart
			rendercolor = sColor
			TextureScroll = iScroll
			NoiseAmplitude = flAmplitude
			width = flWidth
			texture = "sprites/laserbeam.spr"
		}), vecEnd, sColor, iScroll, flWidth, flAmplitude);

		line.m_hEntity.__KeyValueFromString("targetname", "line_owner_" + userid);
		g_aDSLines.push(line);
		g_aDSPreviousLines[idx].push(line);

		if (bSoundNotification) EmitSoundOnClient("Buttons.snd37", PlayerInstanceFromIndex(idx));
	}

	DrawFigure = function(hPlayer, flRadius = null, iPoints = null, flCorrectionAngle = null)
	{
		if (g_bDSHostOnly && !hPlayer.IsHost() || iPoints < 3)
			return;

		local idx = hPlayer.GetEntityIndex();

		if (flRadius == null) flRadius = g_flDSFigureRadius[hPlayer.GetEntityIndex()];

		if (flCorrectionAngle == null)
		{
			if (iPoints == 4) flCorrectionAngle = 45;
			else if (iPoints % 2 == 1) flCorrectionAngle = 270;
			else flCorrectionAngle = 0;
		}

		local aPoints = [];
		local eAngles, eAnglesDirection;
		local flAngle = 360.0 / iPoints;
		local userid = hPlayer.GetPlayerUserId();
		local vecPos = hPlayer.DoTraceLine(eTrace.Type_Pos);

		if (g_bDSDetermineWallNormal)
		{
			local vecPointA = DoTraceLine(hPlayer.EyePosition(), (hPlayer.EyeAngles() - QAngle(0.01, 0, 0)).Forward(), eTrace.Type_Pos, eTrace.Distance, eTrace.Mask_Shot, hPlayer);
			local vecPointB = DoTraceLine(hPlayer.EyePosition(), (hPlayer.EyeAngles() - QAngle(0, 0.01, 0)).Forward(), eTrace.Type_Pos, eTrace.Distance, eTrace.Mask_Shot, hPlayer);
			eAnglesDirection = VectorToQAngle((vecPointA - vecPos).Cross(vecPointB - vecPos));
		}
		else
		{
			eAnglesDirection = hPlayer.EyeAngles();
		}

		for (local angle = 0; angle < 360; angle += flAngle)
		{
			eAngles = eAnglesDirection;
			eAngles.z = flCorrectionAngle + angle;
			aPoints.push(vecPos + eAngles.Left() * flRadius);
		}

		for (local i = 0; i < aPoints.len() - 1; i++)
			g_DrawingSystem.CreateLine(idx, userid, aPoints[i], aPoints[i + 1], false);

		g_DrawingSystem.CreateLine(idx, userid, aPoints[aPoints.len() - 1], aPoints[0], false);
		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	DrawFigure_Cmd = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local flRadius, iPoints, flCorrectionAngle;
			sValue = split(sValue, " ");

			if (sValue.len() == 2)
			{
				flRadius = sValue[0];
				iPoints = sValue[1];

				if (flRadius != "null")
				{
					try (flRadius = flRadius.tofloat())
					catch (error) return;
				}
				else
				{
					flRadius = null;
				}

				try (iPoints = iPoints.tointeger())
				catch (error) return;

				if (iPoints > 30 || flRadius > 1000)
					return;

				g_DrawingSystem.DrawFigure(hPlayer, flRadius, iPoints);
			}
			else if (sValue.len() == 3)
			{
				flRadius = sValue[0];
				iPoints = sValue[1];
				flCorrectionAngle = sValue[2];

				if (flRadius != "null")
				{
					try (flRadius = flRadius.tofloat())
					catch (error) return;
				}
				else
				{
					flRadius = null;
				}

				try (iPoints = iPoints.tointeger())
				catch (error) return;

				try (flCorrectionAngle = flCorrectionAngle.tofloat())
				catch (error) return;

				g_DrawingSystem.DrawFigure(hPlayer, flRadius, iPoints, flCorrectionAngle);
			}
		}
	}

	SetLinePoint = function(hPlayer)
	{
		if (g_bDSHostOnly && !hPlayer.IsHost())
			return;
		
		local vecEnd;
		local idx = hPlayer.GetEntityIndex();

		if (g_vecDSPreviousPoint[idx])
		{
			g_DrawingSystem.CreateLine(idx, hPlayer.GetPlayerUserId(), g_vecDSPreviousPoint[idx], vecEnd = hPlayer.DoTraceLine(eTrace.Type_Pos), true);
			g_vecDSPreviousPoint[idx] = g_bDSAutoLineStart[idx] ? vecEnd : null;
			return;
		}

		g_vecDSPreviousPoint[idx] = hPlayer.DoTraceLine(eTrace.Type_Pos);
		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}

	RemoveLine = function(hPlayer, sValue)
	{
		local hEntity, flRadius;
		local sName = "line_owner_" + hPlayer.GetPlayerUserId();
		local vecPos = hPlayer.DoTraceLine(eTrace.Type_Pos);

		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			flRadius = split(sValue, " ")[0];
			try {flRadius = flRadius.tofloat()}
			catch (error) return;
			if (flRadius <= 0)
				return;
		}
		else 
		{
			flRadius = 10.0;
		}

		while (hEntity = Entities.FindByNameWithin(hEntity, sName, vecPos, flRadius))
			hEntity.Kill();
		
		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	RemovePreviousLine = function(hPlayer)
	{
		local idx = hPlayer.GetEntityIndex();
		if (g_aDSPreviousLines[idx].len() > 0)
		{
			local line = g_aDSPreviousLines[idx].pop();
			if (line.m_hEntity.IsValid())
			{
				g_vecDSPreviousPoint[idx] = g_bDSAutoLineStart[idx] ? line.m_hEntity.GetOrigin() : null;
				line.m_hEntity.Kill();
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
				return;
			}
			g_DrawingSystem.RemovePreviousLine(hPlayer);
		}
		else
		{
			g_vecDSPreviousPoint[idx] = null;
			EmitSoundOnClient("Buttons.snd37", hPlayer);
		}
	}

	ResetPreviousPoint = function(hPlayer)
	{
		g_vecDSPreviousPoint[hPlayer.GetEntityIndex()] = null;
		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}

	SetFigureRadius = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			try {sValue = sValue.tofloat()}
			catch (error) return;

			g_flDSFigureRadius[hPlayer.GetEntityIndex()] = sValue;
			EmitSoundOnClient("Buttons.snd37", hPlayer);
		}
	}

	ClearLines = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT && hPlayer.IsHost())
		{
			if (sValue == "all")
			{
				foreach (line in g_aDSLines)
					if (line.m_hEntity.IsValid())
						line.m_hEntity.Kill();

				foreach (idx, arr in g_aDSPreviousLines)
				{
					g_vecDSPreviousPoint[idx] = null;
					arr.clear();
				}
					
				g_aDSLines.clear();
			}
			else
			{
				try {sValue = sValue.tointeger()}
				catch (error) return;

				if (sValue > 32)
					return;

				foreach (line in g_aDSPreviousLines[sValue])
					if (line.m_hEntity.IsValid())
						line.m_hEntity.Kill();

				g_aDSPreviousLines[sValue].clear();
				g_vecDSPreviousPoint[sValue] = null;
			}
		}
		else
		{
			foreach (line in g_aDSPreviousLines[hPlayer.GetEntityIndex()])
				if (line.m_hEntity.IsValid())
					line.m_hEntity.Kill();

			g_aDSPreviousLines[hPlayer.GetEntityIndex()].clear();
			g_vecDSPreviousPoint[hPlayer.GetEntityIndex()] = null;
		}

		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	ChangeLineColor = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local sColor = split(sValue, " ");
			if (sColor.len() == 1)
			{
				switch (sColor[0])
				{
				case "white":		sColor = "255 255 255";		break;
				case "red":			sColor = "255 0 0";			break;
				case "orange":		sColor = "255 155 0";		break;
				case "yellow":		sColor = "255 255 0";		break;
				case "green":		sColor = "0 255 0";			break;
				case "aquamarine":	sColor = "0 255 255";		break;
				case "azure":		sColor = "0 127 255";		break;
				case "blue":		sColor = "0 0 255";			break;
				case "purple":		sColor = "255 0 255";		break;
				default:										return;
				}

				g_sDSLineColor[hPlayer.GetEntityIndex()] = sColor;
			}
			else if (sColor.len() == 3)
			{
				local r = sColor[0];
				local g = sColor[1];
				local b = sColor[2];

				try {r = r.tointeger()}
				catch (error) return;

				try {g = g.tointeger()}
				catch (error) return;

				try {b = b.tointeger()}
				catch (error) return;

				g_sDSLineColor[hPlayer.GetEntityIndex()] = r + " " + g + " " + b;
			}
			else
			{
				return;
			}

			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x04[Drawing System] Now your color is\x03 %s", sColor));
		}
		else
		{
			g_sDSLineColor[hPlayer.GetEntityIndex()] = "0 255 0";
		}

		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	ChangeWidth = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local flWidth = split(sValue, " ")[0];

			try {flWidth = flWidth.tofloat()}
			catch (error) return;

			if (flWidth >= 0 && flWidth <= 100)
				g_flDSLineWidth[hPlayer.GetEntityIndex()] = flWidth;
		}
		else
		{
			g_flDSLineWidth[hPlayer.GetEntityIndex()] = 2;
		}

		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	ChangeScroll = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local iScroll = split(sValue, " ")[0];

			try {iScroll = iScroll.tointeger()}
			catch (error) return;

			if (iScroll >= 0 && iScroll < 101)
				g_iDSLineScroll[hPlayer.GetEntityIndex()] = iScroll;
		}
		else
		{
			g_iDSLineScroll[hPlayer.GetEntityIndex()] = 50;
		}

		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	ChangeAmplitude = function(hPlayer, sValue)
	{
		if (sValue != CMD_EMPTY_ARGUMENT)
		{
			local flAmplitude = split(sValue, " ")[0];

			try {flAmplitude = flAmplitude.tofloat()}
			catch (error) return;

			if (flAmplitude >= 0 && flAmplitude <= 100)
				g_flDSLineAmplitude[hPlayer.GetEntityIndex()] = flAmplitude;
		}
		else
		{
			g_flDSLineAmplitude[hPlayer.GetEntityIndex()] = 0;
		}

		EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
	}

	AutoLineStart = function(hPlayer)
	{
		local idx = hPlayer.GetEntityIndex();

		if (g_bDSAutoLineStart[idx])
		{
			ClientPrint(hPlayer, HUD_PRINTTALK, "\x04[Drawing System]\x03 Auto-Line Start\x04 has been disabled");
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
		else
		{
			ClientPrint(hPlayer, HUD_PRINTTALK, "\x04[Drawing System]\x03 Auto-Line Start\x04 has been enabled")
			EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
		}

		g_bDSAutoLineStart[idx] = !g_bDSAutoLineStart[idx];
		g_vecDSPreviousPoint[idx] = null;
	}

	DetermineWallNormal = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			if (g_bDSDetermineWallNormal)
			{
				ClientPrint(null, HUD_PRINTTALK, "\x04[Drawing System]\x03 Determine Wall Normal\x04 has been disabled");
				EmitSoundOnClient("Buttons.snd11", hPlayer);
			}
			else
			{
				ClientPrint(null, HUD_PRINTTALK, "\x04[Drawing System]\x03 Determine Wall Normal\x04 has been enabled");
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
			g_bDSDetermineWallNormal = !g_bDSDetermineWallNormal;
		}
	}

	SwitchUsage = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			if (g_bDSHostOnly)
			{
				ClientPrint(null, HUD_PRINTTALK, "\x04[Drawing System]\x03 Allowed\x04 to use by clients");
				EmitSoundOnClient("Buttons.snd11", hPlayer);
			}
			else
			{
				ClientPrint(null, HUD_PRINTTALK, "\x04[Drawing System]\x03 Forbidden\x04 to use by clients");
				EmitSoundOnClient("EDIT_TOGGLE_PLACE_MODE", hPlayer);
			}
			g_bDSHostOnly = !g_bDSHostOnly;
		}
	}

	SaveLines = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			local sInput;
			local idx = 0;
			local length = g_aDSLines.len();
			local aLinesToProcess = [];
			local sPath = "drawing_system/" + Director.GetMapName();

			while (idx < length)
			{
				if (g_aDSLines[idx].m_hEntity.IsValid())
				{
					aLinesToProcess.push([
						kvstr(g_aDSLines[idx].m_hEntity.GetOrigin()),
						kvstr(g_aDSLines[idx].m_vecEndPos),
						g_aDSLines[idx].m_sColor,
						g_aDSLines[idx].m_iScroll,
						g_aDSLines[idx].m_flWidth,
						g_aDSLines[idx].m_flAmplitude,
					]);
				}
				idx++;
			}

			if (sInput = FileToString(sPath + ".nut")) StringToFile(sPath + "_autosave.nut", sInput);

			StringToFile(sPath + ".nut", g_DrawingSystem.SerializeObject(aLinesToProcess, "[\n", "]\n", false));
			ClientPrint(hPlayer, HUD_PRINTTALK, format("\x04[Drawing System] Saved\x03 %d\x04 lines", aLinesToProcess.len()));
			EmitSoundOnClient("Buttons.snd4", hPlayer);
		}
	}

	LoadLines = function(hPlayer)
	{
		if (hPlayer.IsHost())
		{
			local sInput;
			if (sInput = FileToString("drawing_system/" + Director.GetMapName() + ".nut"))
			{
				local iCount = 0;

				try {
					local vec;
					local idx = hPlayer.GetEntityIndex();
					local userid = hPlayer.GetPlayerUserId();
					local aLinesToProcess = compilestring("return " + sInput)();

					foreach (params in aLinesToProcess)
					{
						try {
							g_DrawingSystem.CreateLine(idx, userid, __kvstr_to_vec(params[0]), __kvstr_to_vec(params[1]), false, params[2], params[3], params[4], params[5]);
							iCount++;
						}
						catch (error) {

						}
					}
				}
				catch (error) {
					ClientPrint(hPlayer, HUD_PRINTTALK, "\x04[Drawing System] Couldn't compile the saved file");
					return;
				}

				ClientPrint(hPlayer, HUD_PRINTTALK, format("\x04[Drawing System] Loaded\x03 %d\x04 lines", iCount));
				EmitSoundOnClient("Buttons.snd4", hPlayer);
				return;
			}
			ClientPrint(hPlayer, HUD_PRINTTALK, "\x04[Drawing System] Couldn't find a saved file");
		}
	}

	Lines_Think = function()
	{
		local idx = 0;
		local length = g_aDSLines.len();

		while (idx < length)
		{
			if (!g_aDSLines[idx].m_hEntity.IsValid())
			{
				g_aDSLines.remove(idx);
				length--;
				continue;
			}

			g_aDSLines[idx].SetEndPosition();
			idx++;
		}
	}

	OnPlayerDisconnect = function(tParams)
	{
		local idx = tParams["_player"].GetEntityIndex();
		g_sDSLineColor[idx] = "0 255 0";
		g_bDSAutoLineStart[idx] = false;
		g_iDSLineScroll[idx] = 50;
		g_flDSLineWidth[idx] = 2.0;
		g_flDSLineAmplitude[idx] = 0.0;
		g_flDSFigureRadius[idx] = 100.0;
		g_aDSPreviousLines[idx].clear();
		EntFire("line_owner_" + tParams["userid"], "Kill");
	}
};

PrecacheEntityFromTable({classname = "env_laser", texture = "sprites/laserbeam.spr"});

g_ScriptPluginsHelper.AddScriptPlugin(g_PluginDrawingSystem);