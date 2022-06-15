// Squirrel
// Spawn Chance of Jimmy Gibbs Jr.

__tSpawnChance <-
{
	bCheckChanceOnce = true

	sMonth =
	[
		"Jan"
		"Feb"
		"Mar"
		"Apr"
		"May"
		"Jun"
		"Jul"
		"Aug"
		"Sep"
		"Oct"
		"Nov"
		"Dec"
	]

	nMonth = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

	CanJimmySpawn = function(nDay, nYear)
	{
		if (nYear > 2009 || nDay > 330)
			return !((365 * nYear + nDay - 733616) % 15);
		
		return false;
	}

	IsLeapYear = function(nYear)
	{
		return (nYear % 4 == 0 && (nYear % 100 != 0 || nYear % 400 == 0));
	}

	DateToDays = function(tDate)
	{
		local nDays = 0;

		local nDay = tDate.day;
		local nMonths = tDate.month - 1;
		local nYear = tDate.year;

		local bLeapYear = __tSpawnChance.IsLeapYear(nYear);

		for (local i = 0; i < nMonths; ++i)
		{
			if (bLeapYear && i == 1)
				++nDays;
			
			nDays += __tSpawnChance.nMonth[i];
		}
		
		return nDays + nDay;
	}

	DayOfYearToDate = function(nDay, nYear)
	{
		local bLeapYear = __tSpawnChance.IsLeapYear(nYear);
		
		local i = 0;

		while (0 < nDay)
		{
			local nMonthDay = __tSpawnChance.nMonth[i];

			if (bLeapYear && i == 1)
				nMonthDay += 1;
			
			if (nDay - nMonthDay > 0)
			{
				nDay -= nMonthDay;
				++i;
			}
			else
			{
				break;
			}
		}

		return {
			day = nDay
			month = i + 1
			year = nYear

			output = format("%d.%d.%d", nDay, i + 1, nYear)
			output2 = format("%d %s %d", nDay, __tSpawnChance.sMonth[i], nYear)
		};
	}

	OnGameEvent_player_say = function(tParams)
	{
		local hPlayer;

		if (hPlayer = GetPlayerFromUserID(tParams["userid"]))
		{
			local idx = hPlayer.GetEntityIndex();
			local aText = split(tParams["text"].tolower(), " ");

			if (aText.len() < 1)
				return;

			local sText = aText[0];

			switch (sText)
			{
			case "!chance_nearest":
			case "/chance_nearest":
			{
				local local_time = {};
				LocalTime(local_time);

				local nYear = local_time["year"];
				local nDay = local_time["dayofyear"];

				local bFound = false;
				local nDays = 365 + __tSpawnChance.IsLeapYear(nYear).tointeger();

				for (local i = nDay; i <= nDays; ++i)
				{
					if (__tSpawnChance.CanJimmySpawn(i - 1, nYear))
					{
						ClientPrint(null, 3, "\x05Jimmy Gibbs Jr. nearest appearance date:");

						local tDate = __tSpawnChance.DayOfYearToDate(i, nYear);
						ClientPrint(null, 3, "\x04" + tDate.output2);

						bFound = true;
						break;
					}
				}

				if (!bFound)
				{
					ClientPrint(null, 3, "\x05Jimmy Gibbs Jr. won't appear in this year :(");
				}

				break;
			}
			
			case "!chance_year":
			case "/chance_year":
			{
				local nYear;

				if (aText.len() >= 2)
				{
					nYear = aText[1];

					try { nYear = nYear.tointeger(); }
					catch (_error_) { return };
				}
				else
				{
					local local_time = {};
					LocalTime(local_time);

					nYear = local_time["year"];
				}

				local bOnce = true;
				local nDays = 365 + __tSpawnChance.IsLeapYear(nYear).tointeger();

				for (local i = 1; i <= nDays; ++i)
				{
					if (__tSpawnChance.CanJimmySpawn(i - 1, nYear))
					{
						if (bOnce)
						{
							ClientPrint(null, 3, "\x05Jimmy Gibbs Jr. appearance dates:");
							bOnce = false;
						}

						local tDate = __tSpawnChance.DayOfYearToDate(i, nYear);
						ClientPrint(null, 3, "\x04" + tDate.output2);
					}
				}

				break;
			}
			}
		}
	}

	OnGameEvent_door_unlocked = function(tParams)
	{
		if (!bCheckChanceOnce)
			return;
		
		bCheckChanceOnce = false;

		if (Director.GetMapName() == "c1m4_atrium")
		{
			local local_time = {};
			LocalTime(local_time);

			local nYear = local_time["year"];
			local nDay = local_time["dayofyear"];

			if (__tSpawnChance.CanJimmySpawn(nDay - 1, nYear))
				ClientPrint(null, 3, "\x05Jimmy Gibbs Jr. can appear today!");
		}
	}
};

__CollectEventCallbacks(::__tSpawnChance, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);

printl("[Spawn Chance of Jimmy Gibbs Jr]\nAuthor: Sw1ft\nVersion: 1.0.1");