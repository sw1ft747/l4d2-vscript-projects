// Squirrel
// Prop Hunt Commands

/*function g_HnS::Commands::Freeze(hPlayer)
{
	if (!g_bIsFirstTimeUse[hPlayer.GetEntityIndex()] && IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		local idx = hPlayer.GetEntityIndex();
		local flags = NetProps.GetPropInt(hPlayer, "m_fFlags");
		if (!g_bIsFrozen[idx])
		{
			if (hPlayer.GetVelocity().Length() > 0 || NetProps.GetPropEntity(hPlayer, "m_hGroundEntity") == null) return Say(hPlayer, "[Prop Hunt] Can't use the freeze command in motion/air", true);;
			if (!(flags & FL_ATCONTROLS)) NetProps.SetPropInt(hPlayer, "m_fFlags", flags | FL_ATCONTROLS);
			Say(hPlayer, "[Prop Hunt] You froze own movement", true);
			g_fFreezePosition[idx] = hPlayer.GetOrigin();
			g_bIsFrozen[idx] = true;
		}
		else
		{
			if (flags & FL_ATCONTROLS) NetProps.SetPropInt(hPlayer, "m_fFlags" flags & ~FL_ATCONTROLS);
			g_fFreezePosition[idx] = null;
			g_bIsFrozen[idx] = false;
		}
		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}
}*/

function g_HnS::Commands::ThirdPerson(hPlayer)
{
	if (!g_bIsFirstTimeUse[hPlayer.GetEntityIndex()] && IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		local observer_type = NetProps.GetPropInt(hPlayer, "m_iObserverMode");

		if (observer_type != OBSERVER_THIRD_PERSON) NetProps.SetPropInt(hPlayer, "m_iObserverMode", OBSERVER_THIRD_PERSON);
		else if (observer_type == OBSERVER_THIRD_PERSON) NetProps.SetPropInt(hPlayer, "m_iObserverMode", OBSERVER_FIRST_PERSON);

		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}
}

function g_HnS::Commands::Hint(hPlayer)
{
	if (!g_bIsFirstTimeUse[hPlayer.GetEntityIndex()] && IsHunter(hPlayer) && hPlayer.IsAlive() && g_iRoundType == GAME_ROUND)
	{
		if (IsHunter(hPlayer) && hPlayer.IsAlive() && g_iRoundType == GAME_ROUND)
		{
			EmitSound(hPlayer.GetOrigin(), "Bot.StuckSound");
		}
	}
}

function g_HnS::Commands::Choose(hPlayer, iValue)
{
	foreach (val in g_bIsReady)
		if (val) return;

	if (g_iRoundType == PREPARATION_ROUND && IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		for (local i = 1; i <= g_HnS.PropList.len(); i++)
		{
			if (iValue == i.tostring())
			{
				CreateProp(hPlayer, i);
				EmitSoundOnClient("Buttons.snd37", hPlayer);
				break;
			}
		}
	}
}

function g_HnS::Commands::Random(hPlayer)
{
	foreach (val in g_bIsReady)
		if (val) return;

	if (g_iRoundType == PREPARATION_ROUND && IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		CreateProp(hPlayer, RandomInt(1, g_HnS.PropList.len()));
		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}
}
		
function g_HnS::Commands::Switch(hPlayer)
{
	foreach (val in g_bIsReady)
		if (val) return;

	if (g_iRoundType == PREPARATION_ROUND && IsHunter(hPlayer) && hPlayer.IsAlive())
	{
		local idx = hPlayer.GetEntityIndex();

		CreateProp(hPlayer, g_iSwitchValue[idx]);

		g_iSwitchValue[idx] += 1;
		if (g_iSwitchValue[idx] > g_HnS.PropList.len()) g_iSwitchValue[idx] = 1;

		EmitSoundOnClient("Buttons.snd37", hPlayer);
	}
}

function g_HnS::Commands::ReadyUp(hPlayer)
{
	if (hPlayer.IsHost())
	{
		if (!g_bPlayersIsReady && g_HnS.Data.readyup && g_iRoundType == PREPARATION_ROUND && g_bIsReadyUp)
		{
			SayMsg("[Ready Up System] Denied, can't switch right now");
			return;
		}

		if (g_HnS.Data.readyup)
		{
			SayMsg("[Prop Hunt] Ready Up System has been disabled");
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
		else
		{
			SayMsg("[Prop Hunt] Ready Up System has been enabled");
			EmitSoundOnClient("Buttons.snd37", hPlayer);
		}

		g_HnS.Data.readyup = !g_HnS.Data.readyup;
		UpdateDataTable(g_HnS.Data);
	}
}

function g_HnS::Commands::Ready(hPlayer)
{
	if (!g_bPlayersIsReady && g_HnS.Data.readyup && g_iRoundType == PREPARATION_ROUND)
	{
		if (!g_bIsReady[hPlayer.GetEntityIndex()])
		{
			sayf("[Ready Up] %s is ready", hPlayer.GetPlayerName());
			g_bIsReady[hPlayer.GetEntityIndex()] = true;
			EmitSoundOnClient("Buttons.snd37", hPlayer);
		}
	}
}

function g_HnS::Commands::Unready(hPlayer)
{
	if (!g_bPlayersIsReady && g_HnS.Data.readyup && g_iRoundType == PREPARATION_ROUND)
	{
		if (g_bIsReady[hPlayer.GetEntityIndex()])
		{
			sayf("[Ready Up] %s is unready", hPlayer.GetPlayerName());
			g_bIsReady[hPlayer.GetEntityIndex()] = false;
			EmitSoundOnClient("Buttons.snd11", hPlayer);
		}
	}
}
			
function g_HnS::Commands::List()
{
	if (!g_bPlayersIsReady && g_HnS.Data.readyup && g_iRoundType == PREPARATION_ROUND)
	{
		local hPlayer;
		local sMsg = "";
		foreach (idx, val in g_bIsReady)
		{
			hPlayer = PlayerInstanceFromIndex(idx);
			if (hPlayer != null)
			{
				if (!IsPlayerABot(hPlayer))
				{
					if (sMsg == "") sMsg += "[Ready Up]";
					sMsg += format("\nPlayer %s is %s", hPlayer.GetPlayerName(), (val ? "ready" : "unready"));
				}
			}
		}
		SayMsg(sMsg);
	}
}

function g_HnS::Commands::Restart(hPlayer)
{
	if (hPlayer.IsHost())
	{
		printl("[RestartGame] Executed game restart");
		RestartGame(null, true, 3.0);
	}
}

function g_HnS::Commands::JoinToHunters(hPlayer)
{
	if (NetProps.GetPropInt(hPlayer, "m_iTeamNum") != SURVIVOR_TEAM)
	{
		if (hPlayer.IsAlive()) KillEntity(hPlayer);
		g_bIsPropAlive[hPlayer.GetEntityIndex()] = false;
		NetProps.SetPropInt(hPlayer, "m_iTeamNum", SURVIVOR_TEAM);
		NetProps.SetPropInt(hPlayer, "m_iVersusTeam", 1);
	}
}

function g_HnS::Commands::JoinToProps(hPlayer)
{
	if (NetProps.GetPropInt(hPlayer, "m_iTeamNum") != INFECTED_TEAM)
	{
		if (hPlayer.IsAlive()) KillEntity(hPlayer);
		g_bIsHunterAlive[hPlayer.GetEntityIndex()] = false;
		NetProps.SetPropInt(hPlayer, "m_iTeamNum", INFECTED_TEAM);
		NetProps.SetPropInt(hPlayer, "m_iVersusTeam", 2);
	}
}

function g_HnS::Commands::CallVote(hPlayer, sMap)
{
	if (!g_bVoteCalled)
	{
		if (g_HnS.MapList.rawin(sMap))
		{
			g_bVoteCalled = true;
			g_sMapToChange = g_HnS.MapList.rawget(sMap);
			g_bPlayerVote[hPlayer.GetEntityIndex()] = true;
			sayf("[Prop Hunt] %s started voting for changing map to %s", hPlayer.GetPlayerName(), g_HnS.MapList.rawget(sMap));
			SayMsg("[Prop Hunt] Voting will end in 20 seconds");
			SayMsg("[Prop Hunt] Type [!vote yes] or [!vote no] to vote");
			CreateTimer(20.0, CheckVoteStatus);
			EmitSoundToAll("Vote.Created");
		}
		else
		{
			PrintSupportedMaps();
			sayf("[CallVote] Wrong map name (Caller: %s)", hPlayer.GetPlayerName());
		}
	}
}
	
function g_HnS::Commands::Vote(hPlayer, sVote)
{
	if (g_bVoteCalled && g_sMapToChange != "")
	{
		if (g_bPlayerVote[hPlayer.GetEntityIndex()] == null)
		{
			if (sVote == "yes")
			{
				g_bPlayerVote[hPlayer.GetEntityIndex()] = true;
				sayf("Player %s voted 'Yes'", hPlayer.GetPlayerName());
				EmitSoundToAll("Vote.Cast.Yes");
			}
			if (sVote == "no")
			{
				g_bPlayerVote[hPlayer.GetEntityIndex()] = false;
				sayf("Player %s voted 'No'", hPlayer.GetPlayerName());
				EmitSoundToAll("Vote.Cast.No");
			}
		}
	}
}

/*===============================*\
 *            Hooks              *
\*===============================*/

function AdditionalClassMethodsInjected()
{
	RegisterChatCommand("!rst", g_HnS.Commands.Restart, true);
	RegisterChatCommand("!jh", g_HnS.Commands.JoinToHunters, true);
	RegisterChatCommand("!jp", g_HnS.Commands.JoinToProps, true);
	RegisterChatCommand("!readyup", g_HnS.Commands.ReadyUp, true);
	RegisterChatCommand("!vote", g_HnS.Commands.Vote, true, true);
	RegisterChatCommand("!callvote", g_HnS.Commands.CallVote, true, true);
	RegisterUserCommand("hns_vote", g_HnS.Commands.Vote, true);
	RegisterUserCommand("hns_callvote", g_HnS.Commands.CallVote, true);
	RegisterUserCommand("hns_jp", g_HnS.Commands.JoinToProps, false);
	RegisterUserCommand("hns_jh", g_HnS.Commands.JoinToHunters, false);
}