// Squirrel
// Smoothing Tools

const SMOOTH_INTERP_NONE = -1;
const SMOOTH_INTERP_LINEAR = 0;
const SMOOTH_INTERP_SPLINE = 1; // Catmull-Rom Spline used as default
const SMOOTH_INTERP_KOCHANEK_BARTELS_SPLINE = 2;
const SMOOTH_INTERP_KOCHANEK_BARTELS_SPLINE_NORM = 3;
const SMOOTH_INTERP_HERMITE_SPLINE = 4;
const SMOOTH_INTERP_CUBIC_SPLINE = 5;
const SMOOTH_INTERP_CUBIC_SPLINE_NORM = 6;
const SMOOTH_INTERP_BSPLINE = 7;
const SMOOTH_INTERP_PARABOLIC_SPLINE = 8;

class CSmoothingTools extends IScriptPlugin
{
	function Load()
	{
		::g_SmoothMaster <- CSmoothMaster(); // exposing the singleton object

        printl("[Smoothing Tools]\nAuthor: Sw1ft\nVersion: 1.0");
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
        RegisterChatCommand("!s_load", g_tRealTimeSmoother.LoadSmooth, true, true);
        RegisterChatCommand("!s_save", g_tRealTimeSmoother.SaveSmooth, true, true);
        RegisterChatCommand("!s_play", g_tRealTimeSmoother.PlaySmooth, true, false);
        RegisterChatCommand("!s_stop", g_tRealTimeSmoother.StopSmooth, true, false);
        RegisterChatCommand("!s_add", g_tRealTimeSmoother.AddSample, true, true);
        RegisterChatCommand("!s_remove", g_tRealTimeSmoother.RemoveSample, true, false);
        RegisterChatCommand("!s_remove_all", g_tRealTimeSmoother.RemoveAllSamples, true, false);
        RegisterChatCommand("!s_sremove", g_tRealTimeSmoother.RemoveSelectedSample, true, false);
        RegisterChatCommand("!s_replace", g_tRealTimeSmoother.ReplaceSelectedSample, true, false);
        RegisterChatCommand("!s_add_before", g_tRealTimeSmoother.AddSampleBeforeSelected, true, true);
        RegisterChatCommand("!s_add_after", g_tRealTimeSmoother.AddSampleAfterSelected, true, true);
        RegisterChatCommand("!s_add_tick", g_tRealTimeSmoother.AddTicksToSelectedSample, true, true);
        RegisterChatCommand("!s_tick", g_tRealTimeSmoother.GetTick, true, false);
        RegisterChatCommand("!s_static", g_tRealTimeSmoother.MakeStaticSample, true, false);
        RegisterChatCommand("!s_nonstatic", g_tRealTimeSmoother.MakeNonStaticSample, true, false);
        RegisterChatCommand("!s_next", g_tRealTimeSmoother.SelectNextSample, true, false);
        RegisterChatCommand("!s_prev", g_tRealTimeSmoother.SelectPreviousSample, true, false);
        RegisterChatCommand("!s_toggle_unialloc", g_tRealTimeSmoother.ToggleUniformAllocation, true, false);
        RegisterChatCommand("!s_toggle_process", g_tRealTimeSmoother.ToggleAutoProcess, true, false);
        RegisterChatCommand("!s_toggle_preview", g_tRealTimeSmoother.TogglePreview, true, false);
        RegisterChatCommand("!s_preview", g_tRealTimeSmoother.DrawPreview, true, false);
        RegisterChatCommand("!s_process_origin", g_tRealTimeSmoother.InterpSampleOrigin, true, true);
        RegisterChatCommand("!s_process_angles", g_tRealTimeSmoother.InterpSampleAngles, true, true);
        RegisterChatCommand("!s_set_interp", g_tRealTimeSmoother.SetInterpType, true, true);
        RegisterChatCommand("!s_kb_params", g_tRealTimeSmoother.SetKBParams, true, true);

        RegisterUserCommand("s_load", g_tRealTimeSmoother.LoadSmooth, true, true);
        RegisterUserCommand("s_save", g_tRealTimeSmoother.SaveSmooth, true, true);
        RegisterUserCommand("s_play", g_tRealTimeSmoother.PlaySmooth, false, true);
        RegisterUserCommand("s_stop", g_tRealTimeSmoother.StopSmooth, false, true);
        RegisterUserCommand("s_add", g_tRealTimeSmoother.AddSample, true, true);
        RegisterUserCommand("s_remove", g_tRealTimeSmoother.RemoveSample, false, true);
        RegisterUserCommand("s_remove_all", g_tRealTimeSmoother.RemoveAllSamples, false, true);
        RegisterUserCommand("s_sremove", g_tRealTimeSmoother.RemoveSelectedSample, false, true);
        RegisterUserCommand("s_replace", g_tRealTimeSmoother.ReplaceSelectedSample, false, true);
        RegisterUserCommand("s_add_before", g_tRealTimeSmoother.AddSampleBeforeSelected, true, true);
        RegisterUserCommand("s_add_after", g_tRealTimeSmoother.AddSampleAfterSelected, true, true);
        RegisterUserCommand("s_add_tick", g_tRealTimeSmoother.AddTicksToSelectedSample, true, true);
        RegisterUserCommand("s_tick", g_tRealTimeSmoother.GetTick, false, true);
        RegisterUserCommand("s_static", g_tRealTimeSmoother.MakeStaticSample, false, true);
        RegisterUserCommand("s_nonstatic", g_tRealTimeSmoother.MakeNonStaticSample, false, true);
        RegisterUserCommand("s_next", g_tRealTimeSmoother.SelectNextSample, false, true);
        RegisterUserCommand("s_prev", g_tRealTimeSmoother.SelectPreviousSample, false, true);
        RegisterUserCommand("s_toggle_unialloc", g_tRealTimeSmoother.ToggleUniformAllocation, false, true);
        RegisterUserCommand("s_toggle_process", g_tRealTimeSmoother.ToggleAutoProcess, false, true);
        RegisterUserCommand("s_toggle_preview", g_tRealTimeSmoother.TogglePreview, false, true);
        RegisterUserCommand("s_preview", g_tRealTimeSmoother.DrawPreview, false, true);
        RegisterUserCommand("s_process_origin", g_tRealTimeSmoother.InterpSampleOrigin, true, true);
        RegisterUserCommand("s_process_angles", g_tRealTimeSmoother.InterpSampleAngles, true, true);
        RegisterUserCommand("s_set_interp", g_tRealTimeSmoother.SetInterpType, true, true);
        RegisterUserCommand("s_kb_params", g_tRealTimeSmoother.SetKBParams, true, true);
	}

	function GetClassName() { return m_sClassName; }

	function GetScriptPluginName() { return m_sScriptPluginName; }

	function GetInterfaceVersion() { return m_InterfaceVersion; }

	static m_InterfaceVersion = 1;
	static m_sClassName = "CSmoothingTools";
	static m_sScriptPluginName = "Smoothing Tools";
}

class CSmoothMaster
{
// public:
    constructor()
    {
        m_aSamplePoints = [];
        m_aProcessedPoints = [];

        InitCamera();
    }

    /** Load smooth from the file
    * Signature: void LoadSmooth(string fileName)
    */

    function LoadSmooth(sFileName)
    {
        if (m_bPlayingSmooth)
        {
            SayMsg("Playing smooth right now");
            return;
        }
        
        local forbiddenSymbols = regexp(format("[\\\\/:*?%c<>|]", 34)); // 34 = \" , faq you VSC

        if (forbiddenSymbols.match(sFileName))
        {
            SayMsg("Invalid file name, remove forbidden symbols and try again");
            return;
        }

        local nIterations = 0;
        local nOriginInterpType = SMOOTH_INTERP_NONE;
        local nAnglesInterpType = SMOOTH_INTERP_NONE;

        local aSamplePoints = [];
        local sInput = FileToString("smoothing_tools/smooth/" + sFileName + ".nut");

        if (sInput == null)
        {
            sayf("Smooth file '%s.nut' doesn't exist", sFileName);
            return;
        }

        try
        {
            local length;
            local aSmoothData = compilestring("return " + sInput)();

            if (typeof aSmoothData != "array")
                throw "verybad";
            
            length = aSmoothData.len();
            
            if (length <= 1)
                throw "empty array";

            local bSelectedFound = false;
            local aCommonData = aSmoothData[length - 1];
            local aSeekKeys = ["origin", "angles", "tick", "interp_type", "kb_params"];
            local aSeekKeys2 = ["mapname", "origin_interp", "angles_interp", "version"];

            // validate keys of tables
            for (local i = 0; i < length; i++)
            {
                nIterations++;

                if (typeof aSmoothData[i] != "table")
                    throw "verybad";
                
                if (length - 1 == i)
                {
                    foreach (key in aSeekKeys2)
                    {
                        if (!(key in aCommonData))
                        {
                            sayf("Failed to get key '%s' of last table", key);
                            throw "missing important keys";
                        }
                    }

                    break;
                }

                foreach (key in aSeekKeys)
                {
                    if (!(key in aSmoothData[i]))
                    {
                        sayf("Failed to get key '%s' of table #%d", key, i);
                        throw "missing important keys";
                    }
                }

                local data = aSmoothData[i];
                local params = data["kb_params"];

                if ("is_static" in data && typeof data["is_static"] != "bool")
                    throw "key 'is_static': expected boolean type";
                
                if ("selected" in data && typeof data["selected"] != "bool")
                    throw "key 'selected': expected boolean type";
                
                if (data["tick"] < 0)
                    throw "key 'tick': lower than 0";
                
                if (!(data["origin"] instanceof Vector))
                    throw "key 'origin': expected Vector";
                
                if (!(data["angles"] instanceof QAngle))
                    throw "key 'angles': expected QAngle";
                
                if (SMOOTH_INTERP_NONE < data["interp_type"] || data["interp_type"] > SMOOTH_INTERP_PARABOLIC_SPLINE)
                    throw "key 'interp_type': unknown interpolation type";

                // clamp Kochanek-Bartels Spline parameters
                params[0] = Math.Clamp(params[0], -1.0, 1.0);
                params[1] = Math.Clamp(params[1], -1.0, 1.0);
                params[2] = Math.Clamp(params[2], -1.0, 1.0);
            }

            if (aCommonData["mapname"] != g_sMapName)
            {
                SayMsg("WARNING: Current map's different from the one in the smooth!");
                SayMsg("WARNING: Defined map in the smooth is '%s'", aCommonData["mapname"]);
            }

            nOriginInterpType = aCommonData["origin_interp"];
            nAnglesInterpType = aCommonData["angles_interp"];

            for (local i = 0; i < length - 1; i++)
            {
                if (i > 0 && aSmoothData[i]["tick"] < 1)
                    throw "key 'tick' must be bigger than 0";

                local data = aSmoothData[i];
                local params = data["kb_params"];
                local point = CSmoothSample(data["origin"], data["angles"], (i == 0) ? 0 : data["tick"].tointeger());

                point.SetInterpType(data["interp_type"]);
                point.SetKochanekBartelsParams(params[0], params[1], params[2]);

                if ("is_static" in data && data["is_static"])
                    point.MakeStatic();

                if ("selected" in data && data["selected"] && !bSelectedFound)
                {
                    point.Select();
                    bSelectedFound = true;
                    m_nSelectedSample = i;
                }

                aSamplePoints.push(point);
            }

            if (!bSelectedFound)
            {
                m_nSelectedSample = aSamplePoints.len() - 1;
                aSamplePoints[m_nSelectedSample].Select();
            }
        }
        catch (exception)
        {
            SayMsg("Failed to parse the smooth file");

            if (exception == "verybad")
            {
                SayMsg("The smooth file is corrupted");
                return;
            }

            SayMsg("Error Log: " + exception);
            SayMsg("Error Log: last iterated sample #" + nIterations);

            return;
        }

        m_aSamplePoints.clear();
        collectgarbage();

        m_aSamplePoints = aSamplePoints;
        
        CountTicks();
        OnSamplePointsChanged();

        if (nOriginInterpType != SMOOTH_INTERP_NONE && nAnglesInterpType != SMOOTH_INTERP_NONE)
        {
            InterpSampleOrigin(nOriginInterpType);
            InterpSampleAngles(nAnglesInterpType);
        }
    }

    /** Save smooth in the file
    * Signature: void SaveSmooth(string fileName)
    */

    function SaveSmooth(sFileName)
    {
        if (m_aSamplePoints.len() < 2)
        {
            SayMsg("Not enough sample points to save smooth");
            return;
        }

        local forbiddenSymbols = regexp(format("[\\\\/:*?%c<>|]", 34));

        if (forbiddenSymbols.match(sFileName))
        {
            SayMsg("Invalid file name, remove forbidden symbols and try again");
            return;
        }

        local sOutput;
        local aSmoothData = [];

        for (local i = 0; i < m_aSamplePoints.len(); i++)
        {
            local p = m_aSamplePoints[i];

            local tbl =
            {
                origin = p.GetViewOrigin()
                angles = p.GetViewAngles()
                tick = p.GetTick()
                interp_type = p.GetInterpType()
                kb_params = p.GetKochanekBartelsParams()
            };

            if (p.IsStatic())
                tbl["is_static"] <- true;
            
            if (p.IsSelected())
                tbl["selected"] <- true;

            aSmoothData.push(tbl);
        }

        aSmoothData.push({
            mapname = g_sMapName
            origin_interp = m_nLastOriginInterp
            angles_interp = m_nLastAnglesInterp
            version = 1 // in case I update smoother and it will affect I/O system
        });

        sOutput = g_tRealTimeSmoother.SerializeObject(aSmoothData, "[\n", "]\n", false);
        StringToFile("smoothing_tools/smooth/" + sFileName + ".nut", sOutput);

        sayf("Smooth saved to file 'left4dead2/ems/smoothing_tools/smooth/%s.nut'", sFileName);
    }

    /** Play processed smooth
    * Signature: void PlaySmooth()
    */

    function PlaySmooth(hPlayer)
    {
        if (KeyInScriptScope(hPlayer, "selfie_camera"))
        {
            if (g_bSelfieCamera[hPlayer.GetEntityIndex()])
                return;
        }

		if (KeyInScriptScope(hPlayer, "cinema_camera"))
		{
			if (g_bCinematicCamera[hPlayer.GetEntityIndex()])
				return;
		}

        if (m_bPlayingSmooth)
        {
            Assert(m_hTargetPlayer.IsValid());
            sayf("Already playing smooth for %s", m_hTargetPlayer.GetPlayerName());
            return;
        }

        if (!m_bSampleOriginProcessed || !m_bSampleAnglesProcessed)
        {
            SayMsg("Sample points haven't been processed");
            return;
        }

        Assert(m_aSamplePoints.len() >= 2);

        m_hTargetPlayer = hPlayer;
        m_hTargetPlayer.HideHUD(HIDE_HUD_WEAPON_SELECTION | HIDE_HUD_FLASHLIGHT | HIDE_HUD_HEALTH | HIDE_HUD_MISC | HIDE_HUD_CROSSHAIR);

        ::__smooth_target__ <- m_hTargetPlayer;

        local start_point = m_aProcessedPoints[0];

        m_nPlayTick = 0;
        m_bPlayingSmooth = true;

        ArrangeCamera(start_point.GetViewOrigin() + (start_point.GetViewOrigin() - m_aProcessedPoints[1].GetViewOrigin()).Normalize() * 24.0, start_point.GetViewAngles(), false);
        EnableCamera();

        m_SmoothStartTimer = CreateTimer(1.0, function(SmoothMaster){
            RegisterOnTickFunction("g_tRealTimeSmoother.CameraSmooth_Think", SmoothMaster);
            SmoothMaster.m_SmoothStartTimer = null;
        }, this);
    }

    /** Stop playing smooth
    * Signature: void StopSmooth()
    */

    function StopSmooth()
    {
        if (m_bPlayingSmooth)
        {
            if (IsOnTickFunctionRegistered("g_tRealTimeSmoother.CameraSmooth_Think", this))
            {
                RemoveOnTickFunction("g_tRealTimeSmoother.CameraSmooth_Think");
            }
            else
            {
                Assert(m_SmoothStartTimer || m_SmoothEndTimer, "Where's the timers??");

                local sIdentifier;

                if (m_SmoothStartTimer != null)
                    sIdentifier = m_SmoothStartTimer.GetIdentifier();
                else if (m_SmoothEndTimer != null)
                    sIdentifier = m_SmoothEndTimer.GetIdentifier();

                foreach (idx, timer in g_aTimers)
                {
                    if (timer.GetIdentifier() == sIdentifier)
                    {
                        g_aTimers.remove(idx);
                        break;
                    }
                }
            }

            DisableCamera();
            m_hTargetPlayer.HideHUD(0);
            
            m_bPlayingSmooth = false;
            m_hTargetPlayer = __smooth_target__ = null;
        }
    }

    /** Add a sample point to top of m_aSamplePoints array
    * Signature: void AddSample(Vector origin, QAngle angles, int tick)
    */

    function AddSample(vecOrigin, eAngles, nTick)
    {
        if (m_bPlayingSmooth || (m_nSelectedSample != -1 && nTick < 1))
            return;

        nTick = GetSampleTick(nTick, vecOrigin, false);

        if (m_nSelectedSample != -1)
            m_aSamplePoints[m_nSelectedSample].Unselect();
        
        if (m_aSamplePoints.len() <= 0)
            nTick = 0;

        m_nSelectedSample = m_aSamplePoints.len();

        m_aSamplePoints.push(CSmoothSample(vecOrigin, eAngles, nTick));
        m_aSamplePoints.top().Select();

        m_nTicks += nTick;

        OnSamplePointsChanged();
    }

    /** Remove all sample points
    * Signature: void RemoveAllSamples()
    */

    function RemoveAllSamples()
    {
        if (m_bPlayingSmooth)
            return;

        m_aSamplePoints.clear();
        m_nSelectedSample = -1;

        m_nTicks = 0;

        OnSamplePointsChanged();
    }

    /** Remove a sample point from top of array
    * Signature: void RemoveSample()
    */

    function RemoveSample()
    {
        if (m_nSelectedSample == -1 || m_bPlayingSmooth)
            return;

        m_nTicks -= m_aSamplePoints.top().GetTick();

        m_aSamplePoints.pop();

        if (m_aSamplePoints.len() <= 0)
        {
            m_nSelectedSample = -1;
        }
        else
        {
            m_nSelectedSample = Math.Clamp(m_nSelectedSample, 0, m_aSamplePoints.len() - 1);
            m_aSamplePoints[m_nSelectedSample].Select();
        }

        OnSamplePointsChanged();
    }

    /** Remove selected sample point
    * Signature: void RemoveSelectedSample()
    */

    function RemoveSelectedSample()
    {
        if (m_nSelectedSample == -1 || m_bPlayingSmooth)
            return;

        m_nTicks -= m_aSamplePoints[m_nSelectedSample].GetTick();

        m_aSamplePoints.remove(m_nSelectedSample);

        if (m_aSamplePoints.len() <= 0)
        {
            m_nSelectedSample = -1;
        }
        else
        {
            m_nSelectedSample = Math.Clamp(m_nSelectedSample, 0, m_aSamplePoints.len() - 1);
            m_aSamplePoints[m_nSelectedSample].Select();
        }

        OnSamplePointsChanged();
    }

    /** Replace position and orientation of selected sample
    * Signature: void ReplaceSelectedSample(Vector origin, QAngle angles)
    */

    function ReplaceSelectedSample(vecOrigin, eAngles)
    {
        if (m_nSelectedSample == -1 || m_bPlayingSmooth)
            return;

        local point = m_aSamplePoints[m_nSelectedSample];
        point.SetViewOrigin(vecOrigin);
        point.SetViewAngles(eAngles);

        OnSamplePointsChanged();
    }

    /** Add a sample point after selected sample
    * Signature: void AddSampleAfterSelected(Vector origin, QAngle angles, int tick)
    */

    function AddSampleAfterSelected(vecOrigin, eAngles, nTick)
    {
        if (m_nSelectedSample == -1 || m_bPlayingSmooth)
            return;
        
        nTick = GetSampleTick(nTick, vecOrigin, true);

        local point = CSmoothSample(vecOrigin, eAngles, nTick);

        m_aSamplePoints.insert(m_nSelectedSample + 1, point);

        m_aSamplePoints[m_nSelectedSample].Unselect();
        m_nSelectedSample++;
        m_aSamplePoints[m_nSelectedSample].Select();

        m_nTicks += nTick;

        OnSamplePointsChanged();
    }

    /** Add a sample point before selected sample
    * Signature: void AddSampleBeforeSelected(Vector origin, QAngle angles, int tick)
    */

    function AddSampleBeforeSelected(vecOrigin, eAngles, nTick)
    {
        if (m_nSelectedSample == -1 || m_bPlayingSmooth)
            return;
        
        nTick = GetSampleTick(nTick, vecOrigin, true);
        
        local point = CSmoothSample(vecOrigin, eAngles, (m_nSelectedSample == 0) ? 0 : nTick);
        
        if (m_nSelectedSample == 0)
            m_aSamplePoints[m_nSelectedSample].SetTick(nTick);

        m_aSamplePoints[m_nSelectedSample].Unselect();
        m_aSamplePoints.insert(m_nSelectedSample, point);
        m_aSamplePoints[m_nSelectedSample].Select();

        m_nTicks += nTick;

        OnSamplePointsChanged();
    }

    /** Add/subtract amount of ticks in the sample point
    * Signature: void AddTicksToSelectedSample(int tick)
    */

    function AddTicksToSelectedSample(nTick)
    {
        if (m_nSelectedSample <= 0 || nTick == 0 || m_bPlayingSmooth)
            return;
        
        local point = m_aSamplePoints[m_nSelectedSample];
        local tick = point.GetTick();

        if (nTick < 0 && tick + nTick < 1)
            return;
        
        point.SetTick(tick + nTick);

        m_nTicks += nTick;

        OnSamplePointsChanged();
    }

    /** Select the next sample point
    * Signature: void SelectNextSample()
    */

    function SelectNextSample()
    {
        local length = m_aSamplePoints.len();

        if (length <= 0)
            return;
        
        Assert(m_nSelectedSample != -1);
        
        m_aSamplePoints[m_nSelectedSample].Unselect();

        m_nSelectedSample++;
        
        m_nSelectedSample = Math.Clamp(m_nSelectedSample, 0, length -1);
        m_aSamplePoints[m_nSelectedSample].Select();

        DrawPreview();
    }

    /** Select the previous sample point
    * Signature: void SelectPreviousSample()
    */

    function SelectPreviousSample()
    {
        local length = m_aSamplePoints.len();

        if (length <= 0)
            return;
        
        Assert(m_nSelectedSample != -1);

        m_aSamplePoints[m_nSelectedSample].Unselect();

        m_nSelectedSample--;
        
        m_nSelectedSample = Math.Clamp(m_nSelectedSample, 0, length -1);
        m_aSamplePoints[m_nSelectedSample].Select();

        DrawPreview();
    }

    /** Make selected sample is static
    * Signature: void MakeSelectedSampleStatic()
    */

    function MakeSelectedSampleStatic()
    {
        local point = GetSelectedSample();

        if (!point)
            return;
        
        point.MakeStatic();
        OnSamplePointsChanged();
    }

    /** Make selected sample is non-static
    * Signature: void MakeSelectedSampleNonStatic()
    */

    function MakeSelectedSampleNonStatic()
    {
        local point = GetSelectedSample();

        if (!point)
            return;
        
        point.MakeNonStatic();
        OnSamplePointsChanged();
    }

    /** Set interpolation type for selected sample
    * Signature: void SetInterpType(int interpType)
    */

    function SetInterpType(nInterpType)
    {
        local point = GetSelectedSample();

        if (!point)
            return;
        
        point.SetInterpType(nInterpType);
        OnSamplePointsChanged();
    }

    /** Set tension, bias and continuity for selected sample
    * Signature: void SetKochanekBartelsParams(float tension, float bias, float continuity)
    */

    function SetKochanekBartelsParams(tension, bias, continuity)
    {
        if (m_nSelectedSample == -1)
            return;
        
        m_aSamplePoints[m_nSelectedSample].SetKochanekBartelsParams(tension, bias, continuity);
        OnSamplePointsChanged();
    }

    /** Toggle drawing preview
    * Signature: void TogglePreview()
    */

    function TogglePreview()
    {
        SayMsg("Drawing preview " + (m_bDrawPreview ? "disabled" : "enabled"));
        m_bDrawPreview = !m_bDrawPreview;

        DrawPreview();
    }

    /** Toggle auto processing of origin and angles
    * Signature: void ToggleAutoProcess()
    */

    function ToggleAutoProcess()
    {
        SayMsg("Auto processing " + (m_bAutoProcess ? "disabled" : "enabled"));
        m_bAutoProcess = !m_bAutoProcess;
    }

    /** Toggle uniform allocation
    * Signature: void ToggleUniformAllocation()
    */

    function ToggleUniformAllocation()
    {
        SayMsg("Uniform allocation " + (m_bUniformAllocation ? "disabled" : "enabled"));
        m_bUniformAllocation = !m_bUniformAllocation;
    }

    /** Interpolate sample origin
    * Signature: void InterpSampleOrigin(int interpolationType)
    */

    function InterpSampleOrigin(interpType)
    {
        if (m_bPlayingSmooth)
        {
            SayMsg("Playing smooth right now");
            return;
        }

        if (m_aSamplePoints.len() < 2)
        {
            SayMsg("Not enough sample points");
            return;
        }
        
        InitPoints();
        
        local idx = 0;
        local start_tick = 0;
        local end_tick = 0;

        for (local i = 0; i < m_aSamplePoints.len() - 1; i++)
        {
            local nIterations = 0;

            local earliest = GetBoundedSample(i - 1);
            local current = GetBoundedSample(i);
            local next = GetBoundedSample(i + 1);
            local latest = GetBoundedSample(i + 2);

            start_tick = end_tick;
            end_tick += next.GetTick();

            Assert(end_tick > start_tick);

            local dt = (end_tick - start_tick).tofloat();
            local _interpType = interpType;

            // use interpolation type set at the sample 
            if (current.GetInterpType() != SMOOTH_INTERP_NONE)
                _interpType = current.GetInterpType();

            // interp points between two samples
            for (local j = start_tick; j < end_tick; j++)
            {
                local result;
                nIterations++;

                if (current.IsStatic())
                {
                    result = current.GetViewOrigin();

                    // don't interpolate camera after 5 interations (to don't cause it instantly teleport to static sample)
                    if (nIterations > 4) m_aProcessedPoints[idx].MakeNonInterp();

                    m_aProcessedPoints[idx++].SetViewOrigin(Vector(result.x, result.y, result.z));
                    continue;
                }
                else if (earliest.IsStatic() && j == start_tick && idx > 0 && !m_aProcessedPoints[idx - 1].IsInterp())
                {
                    // don't interpolate camera in one tick after static sample was processed (to don't cause interpolated teleport to the start point of next sample)
                    m_aProcessedPoints[idx].MakeNonInterp();
                }

                local frac = Math.Clamp((j - start_tick) / dt, 0.0, 1.0);

                switch (_interpType)
                {
                case SMOOTH_INTERP_LINEAR:
                    result = VectorLerp(current.GetViewOrigin(), next.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_SPLINE:
                    result = g_tRealTimeSmoother.Catmull_Rom_Spline_Normalize(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), latest.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_KOCHANEK_BARTELS_SPLINE:
                    local params = current.GetKochanekBartelsParams();
                    result = g_tRealTimeSmoother.Kochanek_Bartels_Spline(
                        params[0],
                        params[1],
                        params[2],
                        earliest.GetViewOrigin(),
                        current.GetViewOrigin(),
                        next.GetViewOrigin(),
                        latest.GetViewOrigin(),
                        frac
                    );
                    break;
                
                case SMOOTH_INTERP_KOCHANEK_BARTELS_SPLINE_NORM:
                    local params = current.GetKochanekBartelsParams();
                    result = g_tRealTimeSmoother.Kochanek_Bartels_Spline_NormalizeX(
                        params[0],
                        params[1],
                        params[2],
                        earliest.GetViewOrigin(),
                        current.GetViewOrigin(),
                        next.GetViewOrigin(),
                        latest.GetViewOrigin(),
                        frac
                    );
                    break;
                
                case SMOOTH_INTERP_HERMITE_SPLINE:
                    result = g_tRealTimeSmoother.Hermite_Spline(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_CUBIC_SPLINE:
                    result = g_tRealTimeSmoother.Cubic_Spline(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), latest.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_CUBIC_SPLINE_NORM:
                    result = g_tRealTimeSmoother.Cubic_Spline_NormalizeX(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), latest.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_BSPLINE:
                    result = g_tRealTimeSmoother.BSpline(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), latest.GetViewOrigin(), frac);
                    break;
                
                case SMOOTH_INTERP_PARABOLIC_SPLINE:
                    result = g_tRealTimeSmoother.Parabolic_Spline(earliest.GetViewOrigin(), current.GetViewOrigin(), next.GetViewOrigin(), latest.GetViewOrigin(), frac);
                    break;
                
                default:
                    throw format("Unknown interpolation type (sample #%d)", i);
                }

                m_aProcessedPoints[idx++].SetViewOrigin(result);
            }
        }

        Assert(m_nTicks == end_tick);

        local vecOrigin;
        local penult = m_aSamplePoints[m_aSamplePoints.len() - 2];

        if (penult.IsStatic())
            vecOrigin = penult.GetViewOrigin();
        else
            vecOrigin = m_aSamplePoints.top().GetViewOrigin();

        m_aProcessedPoints.top().SetViewOrigin(Vector(vecOrigin.x, vecOrigin.y, vecOrigin.z));

        // processed without errors
        m_bSampleOriginProcessed = true;
        m_nLastOriginInterp = interpType;

        DrawPreview();
    }

    /** Interpolate sample angles
    * Signature: void InterpSampleAngles(int interpolationType)
    */

    function InterpSampleAngles(interpType)
    {
        if (m_bPlayingSmooth)
        {
            SayMsg("Playing smooth right now");
            return;
        }

        if (m_aSamplePoints.len() < 2)
        {
            SayMsg("Not enough sample points");
            return;
        }
        
        InitPoints();
        
        local idx = 0;
        local start_tick = 0;
        local end_tick = 0;

        for (local i = 0; i < m_aSamplePoints.len() - 1; i++)
        {
            local nIterations = 0;

            local earliest = GetBoundedSample(i - 1);
            local current = GetBoundedSample(i);
            local next = GetBoundedSample(i + 1);

            start_tick = end_tick;
            end_tick += next.GetTick();

            Assert(end_tick > start_tick);

            local dt = (end_tick - start_tick).tofloat();

            for (local j = start_tick; j < end_tick; j++)
            {
                local result;
                nIterations++;

                if (current.IsStatic())
                {
                    result = current.GetViewAngles();

                    if (nIterations > 4) m_aProcessedPoints[idx].MakeNonInterp();

                    m_aProcessedPoints[idx++].SetViewAngles(QAngle(result.x, result.y, result.z));
                    continue;
                }
                else if (earliest.IsStatic() && j == start_tick && idx > 0 && !m_aProcessedPoints[idx - 1].IsInterp())
                {
                    m_aProcessedPoints[idx].MakeNonInterp();
                }

                local frac = Math.Clamp((j - start_tick) / dt, 0.0, 1.0);

                switch (interpType)
                {
                case SMOOTH_INTERP_LINEAR:
                    result = g_tRealTimeSmoother.InterpolateAngles(current.GetViewAngles(), next.GetViewAngles(), frac);
                    break;
                
                case SMOOTH_INTERP_SPLINE:
                    result = g_tRealTimeSmoother.InterpolateAngles(current.GetViewAngles(), next.GetViewAngles(), g_tRealTimeSmoother.SimpleSpline(frac));
                    break;
                
                default:
                    throw format("Unknown interpolation type (sample #%d)", i);
                }

                m_aProcessedPoints[idx++].SetViewAngles(result);
            }
        }

        Assert(m_nTicks == end_tick);

        local eAngles;
        local penult = m_aSamplePoints[m_aSamplePoints.len() - 2];

        if (penult.IsStatic())
            eAngles = penult.GetViewAngles();
        else
            eAngles = m_aSamplePoints.top().GetViewAngles();

        m_aProcessedPoints.top().SetViewAngles(QAngle(eAngles.x, eAngles.y, eAngles.z));

        m_bSampleAnglesProcessed = true;
        m_nLastAnglesInterp = interpType;

        DrawPreview();
    }

    /** Draw processed/sample points
    * Signature: void DrawPreview()
    */

    function DrawPreview()
    {
        DebugDrawClear();

        if (!m_bDrawPreview)
            return;

        local aSampleTicks = [];

        foreach (sample in m_aSamplePoints)
        {
            local last_point = (sample == m_aSamplePoints.top());

            if (sample.IsSelected())
            {
                // highlight selected point (faded blue)
                Mark(sample.GetViewOrigin(), 1e6, Vector(2, 2, 2), Vector(-2, -2, -2), 50, 100, 250, 92);
                Line(sample.GetViewOrigin(), sample.GetViewOrigin() + sample.GetViewAngles().Forward() * 64.0, 1e6, 255, 0, 0);
            }
            else
            {
                if (sample.IsStatic())
                {
                    // static point (red)
                    Mark(sample.GetViewOrigin(), 1e6, Vector(2, 2, 2), Vector(-2, -2, -2), 255, 0, 0, 127);
                    Line(sample.GetViewOrigin(), sample.GetViewOrigin() + sample.GetViewAngles().Forward() * 16.0, 1e6, 0, 255, 0);
                }
                else if (last_point)
                {
                    // last point (turquoise)
                    Mark(sample.GetViewOrigin(), 1e6, Vector(2, 2, 2), Vector(-2, -2, -2), 0, 255, 255, 127);
                    Line(sample.GetViewOrigin(), sample.GetViewOrigin() + sample.GetViewAngles().Forward() * 64.0, 1e6, 200, 100, 255);
                }
                else
                {
                    // non-selected/last point (green)
                    Mark(sample.GetViewOrigin(), 1e6, Vector(2, 2, 2), Vector(-2, -2, -2), 0, 255, 0, 127);
                    Line(sample.GetViewOrigin(), sample.GetViewOrigin() + sample.GetViewAngles().Forward() * 16.0, 1e6, 0, 255, 0);
                }
            }
            
            aSampleTicks.push(sample.GetTick());
        }
        
        if (!m_bSampleOriginProcessed)
        {
            if (m_aSamplePoints.len() > 1)
            {
                for (local i = 0; i < m_aSamplePoints.len() - 1; i++)
                {
                    local point = m_aSamplePoints[i];

                    // connect adjacent points
                    Line(point.GetViewOrigin(), m_aSamplePoints[i + 1].GetViewOrigin(), 1e6, point.IsStatic() ? 232 : 0, 232, 0);
                }
            }
        }
        else if (m_aProcessedPoints.len() > 1)
        {
            local border = m_aProcessedPoints.len() - 1;
            for (local i = 0; i < m_aProcessedPoints.len(); i++)
            {
                local point = m_aProcessedPoints[i];

                // show point's angle
                if (m_bSampleAnglesProcessed && aSampleTicks.find(point.GetTick()) == null)
                    Line(point.GetViewOrigin(), point.GetViewOrigin() + point.GetViewAngles().Forward() * 16.0, 1e6, 180, 180, 180); // 200, 100, 255

                if (i == border)
                    break;

                // connect adjacent points
                Line(point.GetViewOrigin(), m_aProcessedPoints[i + 1].GetViewOrigin(), 1e6, point.IsInterp() ? 0 : 232, 232, 0);
            }
        }
    }

// private:

    /** Get tick for uniform allocation, otherwise use passed through parameters 
    * Signature: int GetSampleTick(int tick, Vector origin, bool selected)
    */

    function GetSampleTick(nTick, vecOrigin, bSelected)
    {
        if (m_bUniformAllocation)
        {
            local p1, p2, tick;

            if (bSelected)
            {
                if (m_nSelectedSample > 0)
                {
                    p1 = m_aSamplePoints[m_nSelectedSample];
                    p2 = m_aSamplePoints[m_nSelectedSample - 1];

                    tick = ((p1.GetViewOrigin() - vecOrigin).Length() / (p1.GetViewOrigin() - p2.GetViewOrigin()).Length()) * p1.GetTick();
                    tick = tick.tointeger();

                    if (tick > 0)
                        return tick;
                }
            }
            else if (m_aSamplePoints.len() > 1)
            {
                local last = m_aSamplePoints.len() - 1;

                p1 = m_aSamplePoints[last];
                p2 = m_aSamplePoints[last - 1];

                tick = ((p1.GetViewOrigin() - vecOrigin).Length() / (p1.GetViewOrigin() - p2.GetViewOrigin()).Length()) * p1.GetTick();
                tick = tick.tointeger();

                if (tick > 0)
                    return tick;
            }
        }

        return nTick;
    }

    /** Get a clamped sample from array
    * Signature: CSmoothSample GetBoundedSample(int index)
    */

    function GetBoundedSample(sample)
    {
        local c = m_aSamplePoints.len();

        if (sample < 0)
            return m_aSamplePoints[0];
        else if (sample >= c)
            return m_aSamplePoints[c - 1];
        
        return m_aSamplePoints[sample];
    }

    /** Returns selected sample point
    * Signature: CSmoothSample GetSelectedSample()
    */

    function GetSelectedSample()
    {
        if (m_nSelectedSample != -1)
            return m_aSamplePoints[m_nSelectedSample];
    }

    /** Count ticks of all sample points
    * Signature: void CountTicks()
    */

    function CountTicks()
    {
        m_nTicks = 0;

        foreach (point in m_aSamplePoints)
            m_nTicks += point.GetTick();
    }

    /** Initialize processing points
    * Signature: void InitPoints()
    */

    function InitPoints()
    {
        Assert(m_aSamplePoints.len() > 0);

        if (m_aProcessedPoints.len() > 0)
        {
            if (m_aProcessedPoints.len() - 1 == m_nTicks)
                return;
            
            // sample points were changed, reset everything
            InvalidateProcessedPoints();

            m_aProcessedPoints.clear();
            collectgarbage();
        }

        m_aProcessedPoints = array(m_nTicks + 1, null);

        local idx = 0;
        local length = m_nTicks;
        
        while (idx <= length)
        {
            m_aProcessedPoints[idx] = CSmoothPoint(null, null, idx);
            idx++;
        }
    }

    /** Make us process sample points again
    * Signature: void InvalidateProcessedPoints()
    */

    function InvalidateProcessedPoints()
    {
        m_bSampleOriginProcessed = m_bSampleAnglesProcessed = false;
        m_aProcessedPoints.clear();
    }

    /** Called when sample points were changed
    * Signature: void OnSamplePointsChanged()
    */

    function OnSamplePointsChanged()
    {
        InvalidateProcessedPoints();

        if (m_bAutoProcess && m_aSamplePoints.len() > 1)
        {
            InterpSampleOrigin(m_nLastOriginInterp);
            InterpSampleAngles(m_nLastAnglesInterp);
        }
        else
        {
            DrawPreview();
        }
    }

    /** Called when smooth playback has finished
    * Signature: void OnSmoothEnd()
    */

    function OnSmoothEnd()
    {
        m_SmoothEndTimer = CreateTimer(1.0, function(SmoothMaster){
            SmoothMaster.DisableCamera();
            SmoothMaster.m_hTargetPlayer.HideHUD(0);

            SmoothMaster.m_bPlayingSmooth = false;
            SmoothMaster.m_SmoothEndTimer = null;

            SmoothMaster.m_hTargetPlayer = __smooth_target__ = null;
        }, this);
    }

    /** Enable smooth camera
    * Signature: void EnableCamera()
    */

    function EnableCamera()
    {
        InitCamera();

        Assert(m_hSmoothCamera.IsValid());
        Assert(!m_bSmoothCameraEnabled);

        m_bSmoothCameraEnabled = true;
        AcceptEntityInput(m_hSmoothCamera, "Enable", "", 0.0, m_hTargetPlayer);
    }

    /** Disable smooth camera
    * Signature: void DisableCamera()
    */

    function DisableCamera()
    {
        InitCamera();

        Assert(m_hSmoothCamera.IsValid());
        Assert(m_bSmoothCameraEnabled);

        m_bSmoothCameraEnabled = false;
        AcceptEntityInput(m_hSmoothCamera, "Disable", "", 0.0, m_hTargetPlayer);
    }

    /** Initialize smooth camera
    * Signature: void InitCamera()
    */

    function InitCamera()
    {
        if (m_hSmoothCamera)
            return;
        
        m_hSmoothCamera = SpawnEntityFromTable("point_viewcontrol_survivor", { targetname = "_smooth_camera_" + UniqueString() })
        m_bSmoothCameraEnabled = false;
    }

    /** Set position and orientation of camera
    * Signature: void ArrangeCamera(Vector origin, QAngle angles, bool interpPosition)
    */

    function ArrangeCamera(vecOrigin, eAngles, bInterp)
    {
        if (bInterp)
            m_hSmoothCamera.__KeyValueFromVector("origin", vecOrigin);
        else
            m_hSmoothCamera.SetOrigin(vecOrigin);

        m_hSmoothCamera.SetAngles(eAngles);
    }

    m_bUniformAllocation = false;
    m_bAutoProcess = false;
    m_bDrawPreview = true;

    m_aProcessedPoints = null;

    m_bSampleOriginProcessed = false;
    m_bSampleAnglesProcessed = false;

    m_nLastOriginInterp = SMOOTH_INTERP_SPLINE;
    m_nLastAnglesInterp = SMOOTH_INTERP_SPLINE;

    // sample points
    m_nTicks = 0;
    m_aSamplePoints = null;
    m_nSelectedSample = -1;

    // smooth camera
    m_SmoothStartTimer = null;
    m_SmoothEndTimer = null;
    m_hTargetPlayer = null;
    m_hSmoothCamera = null;
    m_bSmoothCameraEnabled = false;
    m_bPlayingSmooth = false;
    m_nPlayTick = 0;
}

class CSmoothPoint
{
// public:
    constructor(vecOrigin, eAngles, nTick)
    {
        m_vecOrigin = vecOrigin;
        m_eAngles = eAngles;
        m_nTick = nTick;
    }

    function GetViewOrigin() { return m_vecOrigin; }

    function SetViewOrigin(vecOrigin) { m_vecOrigin = vecOrigin; }

    function GetViewAngles() { return m_eAngles; }

    function SetViewAngles(eAngles) { m_eAngles = eAngles; }

    function GetTick() { return m_nTick; }

    function SetTick(nTick) { m_nTick = nTick; }

    function IsInterp() { return m_bInterp; }

    function MakeInterp() { m_bInterp = true; }

    function MakeNonInterp() { m_bInterp = false; }

// private:
    m_vecOrigin = null;
    m_eAngles = null;
    m_bInterp = true;
    m_nTick = 0;
}

class CSmoothSample extends CSmoothPoint
{
// public:
    constructor(vecOrigin, eAngles, nTick)
    {
        m_vecOrigin = vecOrigin;
        m_eAngles = eAngles;
        m_nTick = nTick;
        m_aTBC = [0.0, 0.0, 0.0];
    }

    function IsStatic() { return m_bIsStatic; }

    function MakeStatic() { m_bIsStatic = true; }

    function MakeNonStatic() { m_bIsStatic = false; }

    function IsSelected() { return m_bSelected; }

    function Select() { m_bSelected = true; }

    function Unselect() { m_bSelected = false; }

    function GetInterpType() { return m_nInterpType; }

    function SetInterpType(interpType) { m_nInterpType = interpType; }

    function GetKochanekBartelsParams() { return m_aTBC; }

    function SetKochanekBartelsParams(tension, bias, continuity) { m_aTBC[0] = tension; m_aTBC[1] = bias; m_aTBC[2] = continuity; }

// private:
    m_aTBC = null;
    m_bSelected = false;
    m_bIsStatic = false;
    m_nInterpType = SMOOTH_INTERP_NONE;
}

g_tRealTimeSmoother <-
{
    Spline_Normalize = function(p1, p2, p3, p4, output_list)
    {
        local dt = p3.x - p2.x;

        output_list[0] = p1;
        output_list[1] = p4;

        if (dt != 0.0)
        {
            if (p1.x != p2.x)
                output_list[0] = VectorLerp(p2, p1, dt / (p2.x - p1.x));

            if (p4.x != p3.x)
                output_list[1] = VectorLerp(p3, p4, dt / (p4.x - p3.x));
        }
    }

    Cubic_Spline = function(p1, p2, p3, p4, t)
    {
        local tSqr = t * t;
        local tSqrSqr = t * tSqr;

        local b = p2 * (tSqrSqr * 2.0);
        local c = p3 * (tSqrSqr * -2.0);

        local output = b + c;

        b = p2 * (tSqr * -3.0);
        c = p3 * (tSqr * 3.0);

        return output + b + c + p2;
    }

    Cubic_Spline_NormalizeX = function(p1, p2, p3, p4, t)
    {
        local vectors = [null, null];
        g_tRealTimeSmoother.Spline_Normalize(p1, p2, p3, p4, vectors);
        return g_tRealTimeSmoother.Cubic_Spline(vectors[0], p2, p3, vectors[1], t);
    }

    BSpline = function(p1, p2, p3, p4, t)
    {
        local oneOver6 = 0.166667;

        local th = t * oneOver6;
        local tSqr = t * th;
        local tSqrSqr = t * tSqr;

        t = th;

        local a = p1 * -tSqrSqr;
        local b = p2 * (tSqrSqr * 3.0);
        local c = p3 * (tSqrSqr * -3.0);
        local d = p4 * tSqrSqr;

        local output = a + b + c + d;

        a = p1 * (tSqr * 3.0);
        b = p2 * (tSqr * -6.0);
        c = p3 * (tSqr * 3.0);

        output += a + b + c;

        a = p1 * (t * -3.0);
        c = p3 * (t * 3.0);

        output += a + c;

        a = p1 * oneOver6;
        b = p2 * (4.0 * oneOver6);
        c = p3 * oneOver6;

        return output + a + b + c;
    }

    BSpline_NormalizeX = function(p1, p2, p3, p4, t)
    {
        local vectors = [null, null];
        g_tRealTimeSmoother.Spline_Normalize(p1, p2, p3, p4, vectors);
        return g_tRealTimeSmoother.BSpline(vectors[0], p2, p3, vectors[1], t);
    }

    Parabolic_Spline = function(p1, p2, p3, p4, t)
    {
        local th = t * 0.5;
        local tSqr = t * th;

        t = th;

        local a = p1 * ( tSqr );
        local b = p2 * ( tSqr * -2.0 );
        local c = p3 * ( tSqr );

        local output = a + b + c;

        local t2 = t * 2.0;
        a = p1 * -t2;
        b = p2 * t2;

        output += a + b;

        a = p1 * 0.5;
        b = p2 * 0.5;

        return output + a + b;
    }

    Parabolic_Spline_NormalizeX = function(p1, p2, p3, p4, t)
    {
        local vectors = [null, null];
        g_tRealTimeSmoother.Spline_Normalize(p1, p2, p3, p4, vectors);
        return g_tRealTimeSmoother.Parabolic_Spline(vectors[0], p2, p3, vectors[1], t);
    }

    Hermite_Spline = function(p0, p1, p2, t)
    {
        local tSqr = t * t;
        local tCube = t * tSqr;

        local b1 = 2.0 * tCube - 3.0 * tSqr + 1.0;
        local b2 = 1.0 - b1;
        local b3 = tCube - 2 * tSqr + t;
        local b4 = tCube - tSqr;

        local output = p1 * b1;
        output += p2 * b2;
        output += (p1 - p0) * b3;
        output += (p2 - p1) * b4;

        return output;
    }

    Kochanek_Bartels_Spline = function(tension, bias, continuity, p1, p2, p3, p4, t)
    {
        local ffa = (1.0 - tension) * (1.0 + continuity) * (1.0 + bias);
        local ffb = (1.0 - tension) * (1.0 - continuity) * (1.0 - bias);
        local ffc = (1.0 - tension) * (1.0 - continuity) * (1.0 + bias);
        local ffd = (1.0 - tension) * (1.0 + continuity) * (1.0 - bias);

        local th = t * 0.5;
        local tSqr = t * th;
        local tSqrSqr = t * tSqr;

        t = th;

        local a = p1 * (tSqrSqr * -ffa);
        local b = p2 * (tSqrSqr * (4.0 + ffa - ffb - ffc));
        local c = p3 * (tSqrSqr * (-4.0 + ffb + ffc - ffd));
        local d = p4 * (tSqrSqr * ffd);

        local output = a + b + c + d;

        a = p1 * (tSqr * 2.0 * ffa);
        b = p2 * (tSqr * (-6.0 - 2.0 * ffa + 2.0 * ffb + ffc));
        c = p3 * (tSqr * (6.0 - 2.0 * ffb - ffc + ffd));
        d = p4 * (tSqr * -ffd);

        output += a + b + c + d;

        a = p1 * (t * -ffa);
        b = p2 * (t * (ffa - ffb));
        c = p3 * (t * ffb);

        return output + a + b + c + p2;
    }

    Kochanek_Bartels_Spline_NormalizeX = function(tension, bias, continuity, p1, p2, p3, p4, t)
    {
        local vectors = [null, null];
        g_tRealTimeSmoother.Spline_Normalize(p1, p2, p3, p4, vectors);
        return Kg_tRealTimeSmoother.ochanek_Bartels_Spline(tension, bias, continuity, vectors[0], p2, p3, vectors[1], t);
    }

    Catmull_Rom_Spline = function(p1, p2, p3, p4, t)
    {
        local tSqr = t * t * 0.5;
        local tSqrSqr = t * tSqr;

        t *= 0.5;

        local a = p1 * -tSqrSqr;
        local b = p2 * (tSqrSqr * 3.0);
        local c = p3 * (tSqrSqr * -3.0);
        local d = p4 * tSqrSqr;

        local output = a + b + c + d;

        a = p1 * (tSqr * 2.0);
        b = p2 * (tSqr * -5.0);
        c = p3 * (tSqr * 4.0);
        d = p4 * -tSqr;

        output += a + b + c + d;

        a = p1 * -t;
        b = p3 * t;

        return output + a + b + p2;
    }

    Catmull_Rom_Spline_Normalize = function(p1, p2, p3, p4, t)
    {
        local dt = (p3 - p2).Length();

        local p1n = (p1 - p2).Normalize();
        local p4n = (p4 - p3).Normalize();

        p1n = p2 + (p1n * dt);
        p4n = p3 + (p4n * dt);
        
        return g_tRealTimeSmoother.Catmull_Rom_Spline(p1n, p2, p3, p4n, t);
    }

    SimpleSpline = function(value)
    {
        local valueSquared = value * value;
        return 3.0 * valueSquared - 2.0 * valueSquared * value;
    }

    InterpolateAngles = function(start, end, frac)
    {
        return ::OrientationLerp(start, end, frac, true, true);
    }

	SerializeObject = function(tObject, sStart = "{\n", sEnd = "}\n", bIndice = true, nTabs = 0)
	{
        nTabs++;

		local sOutput = sStart;
		local sIndiceString, keyType, keyStr, reg;

        local sTab = "";
        local sEndTab = "";

        for (local i = 0; i < nTabs; i++)
            sTab += "\t";
        
        if (nTabs > 0)
        {
            for (local i = 0; i < nTabs - 1; i++)
                sEndTab += "\t";
        }

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
				sOutput += sTab + sIndiceString + val + "\n";
				break;

			case "bool":
				sOutput += sTab + sIndiceString + (val ? "true" : "false") + "\n";
				break;

			case "table":
				sOutput += sTab + sIndiceString + g_tRealTimeSmoother.SerializeObject(val, "{\n", "}\n", true, nTabs);
				break;

			case "array":
				sOutput += sTab + sIndiceString + g_tRealTimeSmoother.SerializeObject(val, "[\n", "]\n", false, nTabs);
				break;

			case "string":
				sOutput += sTab + sIndiceString + format("\"%s\"\n", val);
				break;

            case "Vector":
				sOutput += sTab + sIndiceString + format("Vector(%f, %f, %f)\n", val.x, val.y, val.z);
				break;

			case "QAngle":
				sOutput += sTab + sIndiceString + format("QAngle(%f, %f, %f)\n", val.x, val.y, val.z);
				break;
			}
		}

		sOutput += sEndTab + sEnd;
		return sOutput;
	}

    TeleportToSample = function(hPlayer)
    {
        local point = g_SmoothMaster.GetSelectedSample();

        if (point)
        {
            if (KeyInScriptScope(hPlayer, "cinema_camera") && g_bCinematicCamera[hPlayer.GetEntityIndex()])
            {
                local hCamera = GetScriptScopeVar(hPlayer, "cinema_camera")["camera"];
                hCamera.SetOrigin(point.GetViewOrigin());
                hCamera.SetAngles(point.GetViewAngles());
            }
            else if (NetProps.GetPropInt(hPlayer, "m_MoveType") == MOVETYPE_NOCLIP)
            {
                TP(hPlayer, point.GetViewOrigin() - NetProps.GetPropVector(hPlayer, "m_vecViewOffset"), point.GetViewAngles());
            }
        }
    }

    CameraSmooth_Think = function(SmoothMaster)
    {
        local tick = SmoothMaster.m_nPlayTick;

        if (SmoothMaster.m_aProcessedPoints.len() - 1 <= tick)
        {
            RemoveOnTickFunction("g_tRealTimeSmoother.CameraSmooth_Think");
            SmoothMaster.OnSmoothEnd();
            return;
        }

        local point = SmoothMaster.m_aProcessedPoints[tick];

        SmoothMaster.ArrangeCamera(point.GetViewOrigin(), point.GetViewAngles(), point.IsInterp());  
        SmoothMaster.m_nPlayTick++;
    }

    // Commands

    LoadSmooth = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");
        g_SmoothMaster.LoadSmooth(sArgs[0]);
    }

    SaveSmooth = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");
        g_SmoothMaster.SaveSmooth(sArgs[0]);
    }

    PlaySmooth = function(hPlayer)
    {
        g_SmoothMaster.PlaySmooth(hPlayer);
    }

    StopSmooth = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.StopSmooth();
    }

    AddSample = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local vecOrigin, eAngles;
        local nTick = str_to_int(sArgs[0]);

        if (KeyInScriptScope(hPlayer, "cinema_camera") && g_bCinematicCamera[hPlayer.GetEntityIndex()])
        {
            local hCamera = GetScriptScopeVar(hPlayer, "cinema_camera")["camera"];
            vecOrigin = hCamera.GetOrigin();
            eAngles = hCamera.GetAngles();
        }
        else
        {
            vecOrigin = hPlayer.EyePosition();
            eAngles = hPlayer.EyeAngles();
        }

        g_SmoothMaster.AddSample(vecOrigin, eAngles, nTick);
    }

    RemoveAllSamples = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;

        g_SmoothMaster.RemoveAllSamples();
    }

    RemoveSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.RemoveSample();
        g_tRealTimeSmoother.TeleportToSample(hPlayer);
    }

    RemoveSelectedSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.RemoveSelectedSample();
        g_tRealTimeSmoother.TeleportToSample(hPlayer);
    }

    ReplaceSelectedSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        local vecOrigin, eAngles;

        if (KeyInScriptScope(hPlayer, "cinema_camera") && g_bCinematicCamera[hPlayer.GetEntityIndex()])
        {
            local hCamera = GetScriptScopeVar(hPlayer, "cinema_camera")["camera"];
            vecOrigin = hCamera.GetOrigin();
            eAngles = hCamera.GetAngles();
        }
        else
        {
            vecOrigin = hPlayer.EyePosition();
            eAngles = hPlayer.EyeAngles();
        }

        g_SmoothMaster.ReplaceSelectedSample(vecOrigin, eAngles);
    }

    AddSampleAfterSelected = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local vecOrigin, eAngles;
        local nTick = str_to_int(sArgs[0]);

        if (KeyInScriptScope(hPlayer, "cinema_camera") && g_bCinematicCamera[hPlayer.GetEntityIndex()])
        {
            local hCamera = GetScriptScopeVar(hPlayer, "cinema_camera")["camera"];
            vecOrigin = hCamera.GetOrigin();
            eAngles = hCamera.GetAngles();
        }
        else
        {
            vecOrigin = hPlayer.EyePosition();
            eAngles = hPlayer.EyeAngles();
        }

        g_SmoothMaster.AddSampleAfterSelected(vecOrigin, eAngles, nTick);
    }

    AddSampleBeforeSelected = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local vecOrigin, eAngles;
        local nTick = str_to_int(sArgs[0]);

        if (KeyInScriptScope(hPlayer, "cinema_camera") && g_bCinematicCamera[hPlayer.GetEntityIndex()])
        {
            local hCamera = GetScriptScopeVar(hPlayer, "cinema_camera")["camera"];
            vecOrigin = hCamera.GetOrigin();
            eAngles = hCamera.GetAngles();
        }
        else
        {
            vecOrigin = hPlayer.EyePosition();
            eAngles = hPlayer.EyeAngles();
        }

        g_SmoothMaster.AddSampleBeforeSelected(vecOrigin, eAngles, nTick);
    }

    AddTicksToSelectedSample = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local nTick = str_to_int(sArgs[0]);
        g_SmoothMaster.AddTicksToSelectedSample(nTick);
    }

    GetTick = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        local point = g_SmoothMaster.GetSelectedSample();
        if (point) sayf("Sample #%d: %d ticks", (g_SmoothMaster.m_nSelectedSample + 1), point.GetTick());
    }

    MakeStaticSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.MakeSelectedSampleStatic();
    }

    MakeNonStaticSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.MakeSelectedSampleNonStatic();
    }

    SelectNextSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.SelectNextSample();
        g_tRealTimeSmoother.TeleportToSample(hPlayer);
    }

    SelectPreviousSample = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.SelectPreviousSample();
        g_tRealTimeSmoother.TeleportToSample(hPlayer);
    }

    ToggleUniformAllocation = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.ToggleUniformAllocation();
    }

    ToggleAutoProcess = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.ToggleAutoProcess();
    }

    TogglePreview = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;
        
        g_SmoothMaster.TogglePreview();
    }

    DrawPreview = function(hPlayer)
    {
        if (!hPlayer.IsHost())
            return;

        g_SmoothMaster.DrawPreview();
    }

    InterpSampleOrigin = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local nInterpType = str_to_int(sArgs[0]);

        if (nInterpType < SMOOTH_INTERP_LINEAR || nInterpType > SMOOTH_INTERP_PARABOLIC_SPLINE)
        {
            SayMsg("No such interpolation type!");
            return;
        }

        g_SmoothMaster.InterpSampleOrigin(nInterpType);
    }

    InterpSampleAngles = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local nInterpType = str_to_int(sArgs[0]);

        if (nInterpType < SMOOTH_INTERP_LINEAR || nInterpType > SMOOTH_INTERP_SPLINE)
        {
            SayMsg("No such interpolation type!");
            return;
        }

        g_SmoothMaster.InterpSampleAngles(nInterpType);
    }

    SetInterpType = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        if (sArgs.len() < 1)
            return;
        
        local nInterpType = str_to_int(sArgs[0]);

        if (nInterpType < SMOOTH_INTERP_NONE || nInterpType > SMOOTH_INTERP_PARABOLIC_SPLINE)
        {
            SayMsg("No such interpolation type!");
            return;
        }

        g_SmoothMaster.SetInterpType(nInterpType);
    }

    SetKBParams = function(hPlayer, sArgs)
    {
        if (!hPlayer.IsHost() || sArgs == CMD_EMPTY_ARGUMENT)
            return;
        
        sArgs = split(sArgs, " ");

        local length = sArgs.len();
        local p = g_SmoothMaster.GetSelectedSample();

        if (length < 1 || !p)
            return;
        
        local bias, tension, continuity;
        local params = p.GetKochanekBartelsParams();

        if (length == 1)
        {
            bias = ( sArgs[0] == 'n' ? params[0] : Math.Clamp(str_to_float(sArgs[0]), -1.0, 1.0) );
            tension = params[1];
            continuity = params[2];
        }
        else if (length == 2)
        {
            bias = ( sArgs[0] == 'n' ? params[0] : Math.Clamp(str_to_float(sArgs[0]), -1.0, 1.0) );
            tension = ( sArgs[1] == 'n' ? params[1] : Math.Clamp(str_to_float(sArgs[1]), -1.0, 1.0) );
            continuity = params[2];
        }
        else
        {
            bias = ( sArgs[0] == 'n' ? params[0] : Math.Clamp(str_to_float(sArgs[0]), -1.0, 1.0) );
            tension = ( sArgs[1] == 'n' ? params[1] : Math.Clamp(str_to_float(sArgs[1]), -1.0, 1.0) );
            continuity = ( sArgs[2] == 'n' ? params[2] : Math.Clamp(str_to_float(sArgs[2]), -1.0, 1.0) );
        }

        g_SmoothMaster.SetKochanekBartelsParams(bias, tension, continuity);
    }
};

g_SmoothingTools <- CSmoothingTools();
g_ScriptPluginsHelper.AddScriptPlugin(g_SmoothingTools);