#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <colorchat>
new String:FILE_MAPS[128] = "addons/amxmodx/configs/maps.ini";
new String:FILE_BLOCKEDMAPS[156] = "addons/amxmodx/configs/blockedmaps.ini";
new String:TEMP_FILE[140] = "addons/amxmodx/configs/tempmap.ini";
new String:PREFIX[20] = "[KZ]";
new Array:g_iMapsArray;
new Array:g_iNominateArray;
new g_pLoadMapsType;
new g_pChangeMap;
new g_pChangeMapRounds;
new g_pShowSelects;
new g_pShowResultAfterVote;
new g_pShowResultType;
new g_pDebug;
new g_pTimeStartVote;
new g_pTimeLimit;
new g_pExendedMax;
new g_pExendedTime;
new g_pChatTime;
new g_pRockEnable;
new g_pRockChange;
new g_pRockPercent;
new g_pRockDelay;
new g_pRockShow;
new g_pNextMap;
new g_pMenuStopVote;
new g_pRockEndBlock;
new bool:g_bBeInVote;
new bool:g_bVoteFinished;
new bool:g_bRockVote;
new bool:g_DefaultChange;
new bool:g_bHasVoted[33];
new bool:g_bRockVoted[33];
new g_iExtendedMax;
new g_iRound;
new g_iStartPlugin;
new g_iLoadMaps;
new g_iForwardStartVote;
new g_iForwardFinishVote;
new g_iInMenu[7];
new g_iVoteItem[9];
new g_iTotal;
new g_iVoteTime;
new g_iRockVote;
new g_iNominatedMaps[33];
new g_iPage[33];
new g_iTimer;
new g_szInMenuMapName[7][33];
new g_BlockedMaps[1][34];
new g_szCurrentMap[33];
new g_szPrefixes[8];
new g_szSound[11];




// 4536 - "0"
public plugin_init()
{
	register_plugin("Mapchooser", "1.8", "Destroman");
	g_pLoadMapsType = register_cvar("mm_loadmapstype", "0");
	g_pChangeMap = register_cvar("mm_changemap", "0");
	g_pChangeMapRounds = register_cvar("mm_changemap_rounds", "0");
	g_pTimeStartVote = register_cvar("mm_timestartvote", "14");
	g_pShowSelects = register_cvar("mm_showselects", "1");
	g_pShowResultAfterVote = register_cvar("mm_show_result_aftervote", "1");
	g_pShowResultType = register_cvar("mm_showresulttype", "0");
	g_pExendedTime = register_cvar("mm_extendedtime", "15", "0");
	g_pExendedMax = register_cvar("mm_extendedmap_max", "10", "0");
	g_pMenuStopVote = register_cvar("mm_menustopvote", "0");
	g_pNextMap = register_cvar("amx_nextmap", "0");	//#Mark
	g_pRockEnable = register_cvar("mm_rtv_enable",  "1");
	g_pRockPercent = register_cvar("mm_rtv_percent", "60");
	g_pRockChange = register_cvar("mm_rtv_change", "0");
	g_pRockDelay = register_cvar("mm_rtv_delay", "0");
	g_pRockEndBlock = register_cvar("mm_rtv_beforeendblock", "0");
	g_pRockShow = register_cvar("mm_rtv_show", "1");
	g_pChatTime = get_cvar_pointer("mp_chattime");
	g_pTimeLimit = get_cvar_pointer("mp_timelimit");
	g_pDebug = register_cvar("mm_debug", "0");
	register_concmd("votestart", "Command_StartVote");
	register_concmd("startvote", "Command_StartVote");
	register_concmd("stopvote", "Command_StopVote");
	register_clcmd("say votenext", "Command_StartVote");
	register_clcmd("say nortv", "Command_StopVote");
	register_clcmd("votemap", "Command_Votemap");
	register_clcmd("say maps", "Command_MapsList");
	register_clcmd("say /maps", "Command_MapsList");
	register_clcmd("say rtv", "Command_RTV");
	register_clcmd("say /rtv", "Command_RTV");
	register_clcmd("say rockthevote", "Command_RTV");
	register_clcmd("say", "Command_Say");
	register_clcmd("say_team", "Command_Say");
	register_event("SendAudio", "Event_RoundEnd", 7212, "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw");
	register_event("TextMsg", "Event_GameRestart", 7524, "2=#Game_Commencing", "2=#Game_will_restart_in");
	register_event("30", "Event_MapEnd", 7768, 7776);
	register_menucmd(register_menuid("Vote_Menu", TeamName), 1023, "VoteMenu_Handler");
	register_menucmd(register_menuid("MapsList_Menu", TeamName), 1023, "MapsListMenu_Handler");
	g_iNominateArray = ArrayCreate(35, 32);
	g_iStartPlugin = get_systime(TeamName);
	g_iForwardStartVote = CreateMultiForward("mapmanager_startvote", TeamName);
	g_iForwardFinishVote = CreateMultiForward("mapmanager_finishvote", TeamName);
	set_task(1084227584, "CheckTime", 978662, 8248, TeamName, 8240, TeamName);
	get_mapname(g_szCurrentMap, 32);
	if (get_pcvar_num(g_pDebug))
	{
		log_to_file("mapmanager_debug.log", "PLUGIN_INIT: %s", g_szCurrentMap);
	}
	Load_BlockedMaps();
	Load_MapList();
	return 0;
}

public plugin_end()
{
	if (g_iExtendedMax)
	{
		set_pcvar_num(g_pTimeLimit, get_pcvar_num(g_pTimeLimit) - get_pcvar_num(g_pExendedTime) * g_iExtendedMax);
	}
	set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) - 6);
	new iVar = 1;
	if (iVar < 2)
	{
		return 0;
	}
	new iTemp = fopen(TEMP_FILE, "wt");
	if (iTemp)
	{
		new i;
		while (i < 1)
		{
			if (g_BlockedMaps[i][33])
			{
				fprintf(iTemp, "\"%s\" \"%d\"\n", g_BlockedMaps[i], g_BlockedMaps[i][33]);
			}
			i++;
		}
		fprintf(iTemp, "\"%s\" \"%d\"\n", g_szCurrentMap, 1);
		fclose(iTemp);
		delete_file(FILE_BLOCKEDMAPS);
		new iRename = rename_file(TEMP_FILE, FILE_BLOCKEDMAPS, 1);
		if (get_pcvar_num(g_pDebug))
		{
			log_to_file("mapmanager_debug.log", "PLUGIN_END: File Renamed ? %d", iRename);
		}
	}
	else
	{
		if (get_pcvar_num(g_pDebug))
		{
			log_to_file("mapmanager_debug.log", "PLUGIN_END: Can't write file");
		}
	}
	return 0;
}

Load_BlockedMaps()
{
	new var1;
	if (!file_exists(FILE_BLOCKEDMAPS) || 1)
	{
		return 0;
	}
	new iFile = fopen(FILE_BLOCKEDMAPS, "rt");
	new iTemp = fopen(TEMP_FILE, "wt");
	new szBuffer[64];
	new szMap[33];
	new szCount[8];
	new iCount;
	new i;
	while (!feof(iFile))
	{
		fgets(iFile, szBuffer, 63);
		parse(szBuffer, szMap, 32, szCount, 7);
		new var2;
		if (!(get_blocked_map_count(szMap) || !is_map_valid(szMap) || equali(szMap, g_szCurrentMap, TeamName)))
		{
			iCount = str_to_num(szCount) - 1;
			if (iCount)
			{
				if (iCount > 1)
				{
					fprintf(iTemp, "\"%s\" \"%d\"\n", szMap, 1);
					iCount = 1;
				}
				else
				{
					fprintf(iTemp, "\"%s\" \"%d\"\n", szMap, iCount);
				}
				formatex(g_BlockedMaps[i], 32, szMap);
				i++;
				g_BlockedMaps[i][33] = iCount;
				if (i >= 1)
				{
					fclose(iFile);
					fclose(iTemp);
					delete_file(FILE_BLOCKEDMAPS);
					new iRename = rename_file(TEMP_FILE, FILE_BLOCKEDMAPS, 1);
					if (get_pcvar_num(g_pDebug))
					{
						log_to_file("mapmanager_debug.log", "LOAD_BLOCKEDMAPS: File Renamed? %d; Blocked ? %d", iRename, i);
					}
					return 0;
				}
			}
		}
	}
	fclose(iFile);
	fclose(iTemp);
	delete_file(FILE_BLOCKEDMAPS);
	new iRename = rename_file(TEMP_FILE, FILE_BLOCKEDMAPS, 1);
	if (get_pcvar_num(g_pDebug))
	{
		log_to_file("mapmanager_debug.log", "LOAD_BLOCKEDMAPS: File Renamed? %d; Blocked ? %d", iRename, i);
	}
	return 0;
}

Load_MapList()
{
	g_iLoadMaps = 0;
	g_iMapsArray = ArrayCreate(33, 32);
	new var1;
	if (file_exists(FILE_MAPS) && get_pcvar_num(g_pLoadMapsType))
	{
		new szMapName[33];
		new f = fopen(FILE_MAPS, "rt");
		if (f)
		{
			while (!feof(f))
			{
				fgets(f, szMapName, 32);
				trim(szMapName);
				remove_quotes(szMapName);
				new var3;
				if (!(!szMapName[0] || szMapName[0] == 59 || (szMapName[0] == 47 && szMapName[1] == 47) || !valid_map(szMapName) || in_maps_array(szMapName) || equali(szMapName, g_szCurrentMap, TeamName)))
				{
					g_iLoadMaps += 1;
					ArrayPushString(g_iMapsArray, szMapName);
				}
			}
			fclose(f);
		}
	}
	else
	{
		new iDir;
		new iLen;
		new szFileName[64];
		new DirName[5] = {109,97,112,115,0};
		iDir = open_dir(DirName, szFileName, 63);
		if (iDir)
		{
			while (next_file(iDir, szFileName, 63))
			{
				iLen = strlen(szFileName) - 4;
				if (!(0 > iLen))
				{
					new var4;
					if (equali(szFileName[iLen], ".bsp", TeamName) && !equali(szFileName, g_szCurrentMap, TeamName))
					{
						szFileName[iLen] = 0;
						g_iLoadMaps += 1;
						ArrayPushString(g_iMapsArray, szFileName);
					}
				}
			}
			close_dir(iDir);
		}
	}
	if (!g_iLoadMaps)
	{
		if (get_pcvar_num(g_pDebug))
		{
			log_to_file("mapmanager_debug.log", "LOAD_MAPS: Nothing loaded");
		}
		set_fail_state("LOAD_MAPS: Nothing loaded");
		return 0;
	}
	if (0 >= g_iLoadMaps - get_blocked_maps())
	{
		clear_blocked_maps();
	}
	new szMap[33];
	do {
		ArrayGetString(g_iMapsArray, random_num(TeamName, g_iLoadMaps + -1), szMap, 32);
	} while (get_blocked_map_count(szMap));
	if (get_pcvar_num(g_pDebug))
	{
		log_to_file("mapmanager_debug.log", "LOAD_MAPS: Loaded Maps ? %d", g_iLoadMaps);
	}
	return 0;
}

public client_disconnect(id)
{
	if (task_exists(id + 978162, TeamName))
	{
		remove_task(id + 978162, TeamName);
	}
	if (g_bRockVoted[id])
	{
		g_iRockVote -= 1;
		g_bRockVoted[id] = 0;
	}
	if (g_iNominatedMaps[id])
	{
		clear_nominated_maps(id);
	}
	return 0;
}

public Command_Votemap(id)
{
	return 1;
}

public Command_StartVote(id, flag)
{
	if (!g_bBeInVote)
	{
		new var1;
		if (flag & ~get_user_flags(id, TeamName))
		{
			var1 = 1;
		}
		else
		{
			var1 = StartVote(id);
		}
		return var1;
	}
	return 1;
}

public Command_StopVote(id, flag)
{
	if (!g_DefaultChange)
	{
		if (flag & ~get_user_flags(id, TeamName))
		{
			return 1;
		}
		if (g_bBeInVote)
		{
			g_bBeInVote = false;
			g_bRockVote = false;
			g_iRockVote = 0;
			arrayset(g_bRockVoted, TeamName, 33);
			new i = 1;
			while (i <= 32)
			{
				if (is_user_connected(i))
				{
					g_bRockVoted[i] = 0;
				}
				i++;
			}
			if (task_exists(978262, TeamName))
			{
				remove_task(978262, TeamName);
			}
			if (task_exists(978362, TeamName))
			{
				remove_task(978362, TeamName);
			}
			if (task_exists(978462, TeamName))
			{
				remove_task(978462, TeamName);
			}
			new id = 1;
			while (id <= 32)
			{
				if (task_exists(id + 978162, TeamName))
				{
					remove_task(id + 978162, TeamName);
				}
				id++;
			}
			show_menu(TeamName, TeamName, 9836, 1, 9844);
			new szName[32];
			get_user_name(id, szName, 31);
			ColorChat(0, Color:3, "\x04%s\x01 Vote cancelled by\x03 %s", PREFIX, szName);
		}
	}
	return 1;
}

public Command_MapsList(id)
{
	g_iPage[id] = 0;
	Show_MapsListMenu(id, 0);
	return 1;
}

public Show_MapsListMenu(id, iPage)
{
	if (0 > iPage)
	{
		return 1;
	}
	new iMax = ArraySize(g_iMapsArray);
	new i = min(iPage * 8, iMax);
	new iStart = i - i % 8;
	new iEnd = min(iStart + 8, iMax);
	iPage = iStart / 8;
	g_iPage[id] = iPage;
	new szMenu[512];
	new iLen;
	new szMapName[33];
	iLen = formatex(szMenu, 511, "\yMaps List \w[%d/%d]:\n", iPage + 1, iMax + -1 / 8 + 1);
	new Keys;
	new Item;
	new iBlock;
	new iNominator;
	i = iStart;
	while (i < iEnd)
	{
		ArrayGetString(g_iMapsArray, i, szMapName, 32);
		iBlock = get_blocked_map_count(szMapName);
		iNominator = is_map_nominated(szMapName);
		if (iBlock)
		{
			Item++;
			iLen = formatex(szMenu[iLen], 511 - iLen, "\n\r%d.\d %s[\r%d\d]", Item, szMapName, iBlock) + iLen;
		}
		else
		{
			if (iNominator)
			{
				if (id == iNominator)
				{
					Keys = 1 << Item | Keys;
					Item++;
					iLen = formatex(szMenu[iLen], 511 - iLen, "\n\r%d.\w %s[\y*\w]", Item, szMapName) + iLen;
				}
				else
				{
					Item++;
					iLen = formatex(szMenu[iLen], 511 - iLen, "\n\r%d.\d %s[\y*\d]", Item, szMapName) + iLen;
				}
			}
			Keys = 1 << Item | Keys;
			Item++;
			iLen = formatex(szMenu[iLen], 511 - iLen, "\n\r%d.\w %s", Item, szMapName) + iLen;
		}
		i++;
	}
	while (Item <= 8)
	{
		Item++;
		iLen = formatex(szMenu[iLen], 511 - iLen, 10332) + iLen;
	}
	if (iEnd < iMax)
	{
		Keys |= 768;
		new var1;
		if (iPage)
		{
			var1 = 10444;
		}
		else
		{
			var1 = 10464;
		}
		formatex(szMenu[iLen], 511 - iLen, "\n\r9.\w More...\n\r0.\w %s", var1);
	}
	else
	{
		Keys |= 512;
		new var2;
		if (iPage)
		{
			var2 = 10532;
		}
		else
		{
			var2 = 10552;
		}
		formatex(szMenu[iLen], 511 - iLen, "\n\n\r0.\w %s", var2);
	}
	show_menu(id, Keys, szMenu, -1, "MapsList_Menu");
	return 1;
}

public MapsListMenu_Handler(id, key)
{
	switch (key)
	{
		case 8:
		{
			new var3 = g_iPage[id];
			var3++;
			Show_MapsListMenu(id, var3);
		}
		case 9:
		{
			new var2 = g_iPage[id];
			var2--;
			Show_MapsListMenu(id, var2);
		}
		default:
		{
			new szMapName[33];
			ArrayGetString(g_iMapsArray, g_iPage[id] * 8 + key, szMapName, 32);
			new var1;
			if (g_iNominatedMaps[id] && is_map_nominated(szMapName))
			{
				remove_nominated_map(id, szMapName);
			}
			else
			{
				NominateMap(id, szMapName);
			}
		}
	}
	return 1;
}

public Command_RTV(id)
{
	new var1;
	if (g_bVoteFinished || g_bBeInVote)
	{
		return 1;
	}
	if (!get_pcvar_num(g_pRockEnable))
	{
		return 0;
	}
	if (get_pcvar_num(g_pRockEndBlock) > get_timeleft() / 60)
	{
		ColorChat(id, Color:3, "\x04%s\x01 Too late to vote", PREFIX);
		return 1;
	}
	new iTime = get_systime(TeamName);
	if (get_pcvar_num(g_pRockDelay) * 60 > iTime - g_iStartPlugin)
	{
		new iMin = get_pcvar_num(g_pRockDelay) * 60 - iTime - g_iStartPlugin / 60 + 1;
		new szMin[16];
		get_ending(iMin, "minutes", "minutes", "minutes", szMin, 15);
		ColorChat(id, Color:3, "\x04%s\x01 You cannot vote. Wait:\x03 %d\x01 %s", PREFIX, iMin, szMin);
		return 1;
	}
	if (!g_bRockVoted[id])
	{
		g_bRockVoted[id] = 1;
		g_iRockVote += 1;
		new iVote = floatround(get_pcvar_num(g_pRockPercent) * get_players_num() / 1120403456, 2) - g_iRockVote;
		if (0 < iVote)
		{
			new szVote[16];
			get_ending(iVote, "votes", "votes", "votes", szVote, 15);
			switch (get_pcvar_num(g_pRockShow))
			{
				case 0:
				{
					new szName[33];
					get_user_name(id, szName, 32);
					ColorChat(0, Color:3, "\x04%s\x03 %s\x01 voted for change map. Need:\x03 %d\x01 %s", PREFIX, szName, iVote, szVote);
				}
				case 1:
				{
					ColorChat(id, Color:3, "\x04%s\x01 Your vote accepted. Need:\x03 %d\x01 %s", PREFIX, iVote, szVote);
				}
				default:
				{
				}
			}
		}
		else
		{
			g_bRockVote = true;
			StartVote(0);
			ColorChat(0, Color:3, "\x04%s\x01 Voting in progress...", PREFIX);
		}
	}
	else
	{
		new iVote = floatround(get_pcvar_num(g_pRockPercent) * get_players_num() / 1120403456, 2) - g_iRockVote;
		if (0 < iVote)
		{
			new szVote[16];
			get_ending(iVote, "votes", "votes", "votes", szVote, 15);
			ColorChat(id, Color:3, "\x04%s\x01 You have already voted. Need:\x03 %d\x01 %s", PREFIX, iVote, szVote);
		}
		else
		{
			g_bRockVote = true;
			StartVote(0);
			ColorChat(0, Color:3, "\x04%s\x01 Voting in progress...", PREFIX);
		}
	}
	return 0;
}

public Command_Say(id)
{
	new var1;
	if (g_bVoteFinished || g_bBeInVote)
	{
		return 0;
	}
	new szText[33];
	read_args(szText, 32);
	remove_quotes(szText);
	trim(szText);
	strtolower(szText);
	if (in_maps_array(szText))
	{
		new var2;
		if (g_iNominatedMaps[id] && is_map_nominated(szText))
		{
			remove_nominated_map(id, szText);
		}
		else
		{
			NominateMap(id, szText);
		}
	}
	else
	{
		new i;
		while (i < 8)
		{
			new szFormat[33];
			formatex(szFormat, 32, "%s%s", g_szPrefixes[i], szText);
			if (in_maps_array(szFormat))
			{
				new var3;
				if (g_iNominatedMaps[id] && is_map_nominated(szFormat))
				{
					remove_nominated_map(id, szFormat);
				}
				else
				{
					NominateMap(id, szFormat);
				}
			}
			i++;
		}
	}
	return 0;
}

NominateMap(id, map[33])
{
	if (g_iNominatedMaps[id] == 5)
	{
		ColorChat(id, Color:3, "\x04%s\x01 Maximum number of nominations has been reached", PREFIX);
		return 1;
	}
	if (get_blocked_map_count(map))
	{
		ColorChat(id, Color:3, "\x04%s\x01 You cannot nominate a map from the last maps played", PREFIX);
		return 1;
	}
	if (is_map_nominated(map))
	{
		ColorChat(id, Color:3, "\x04%s\x01 Map has already been nominated", PREFIX);
		return 1;
	}
	new szMap[33];
	new i;
	while (i < g_iLoadMaps)
	{
		ArrayGetString(g_iMapsArray, i, szMap, 32);
		if (equali(map, szMap, TeamName))
		{
			new Data[35];
			new var1 = map;
			Data = var1;
			Data[33] = id;
			Data[34] = i;
			ArrayPushArray(g_iNominateArray, Data);
			g_iNominatedMaps[id]++;
			new szName[33];
			get_user_name(id, szName, 32);
			ColorChat(0, Color:2, "\x04%s\x03 %s\x01 has nominated map\x03 %s\x01", PREFIX, szName, map);
			return 1;
		}
		i++;
	}
	new Data[35];
	new var1 = map;
	Data = var1;
	Data[33] = id;
	Data[34] = i;
	ArrayPushArray(g_iNominateArray, Data);
	g_iNominatedMaps[id]++;
	new szName[33];
	get_user_name(id, szName, 32);
	ColorChat(0, Color:2, "\x04%s\x03 %s\x01 has nominated map\x03 %s\x01", PREFIX, szName, map);
	return 1;
}

public Event_RoundEnd()
{
	g_iRound += 1;
	new iCvar = get_pcvar_num(g_pChangeMapRounds);
	new var1;
	if (iCvar && g_iRound >= iCvar)
	{
		StartVote(0);
	}
	new var4;
	if (g_bVoteFinished && (get_pcvar_num(g_pChangeMap) == 1 || (g_bRockVote && get_pcvar_num(g_pRockChange) == 1)))
	{
		set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) + 6);
		set_task(1084227584, "ChangeLevel", 978562, 8248, TeamName, 12600, TeamName);
		if (get_pcvar_num(g_pDebug))
		{
			log_to_file("mapmanager_debug.log", "EVENT_ROUNDEND: ChangeLevel");
		}
	}
	return 0;
}

public Event_GameRestart()
{
	g_iRound = 0;
	g_iStartPlugin = get_systime(TeamName);
	return 0;
}

public Event_MapEnd()
{
	set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) + 6);
	set_task(1084227584, "ChangeLevel", 978562, 8248, TeamName, 12600, TeamName);
	if (get_pcvar_num(g_pDebug))
	{
		log_to_file("mapmanager_debug.log", "EVENT_MAPEND: ChangeLevel");
	}
	return 0;
}

public CheckTime()
{
	new var1;
	if (g_bVoteFinished || g_bBeInVote)
	{
		return 0;
	}
	static iTimeLimit;
	iTimeLimit = get_pcvar_num(g_pTimeLimit);
	if (123 >= get_timeleft())
	{
		g_DefaultChange = true;
		StartVote(0);
	}
	else
	{
		if (!iTimeLimit)
		{
			if (get_pcvar_num(g_pTimeStartVote) * 60 <= get_systime(TeamName) - g_iStartPlugin)
			{
				StartVote(0);
			}
		}
	}
	return 0;
}

public StartVote(id)
{
	new szName[32];
	get_user_name(id, szName, 31);
	if (0 < id)
	{
		ColorChat(0, Color:3, "\x04%s \x03%s\x01 start the vote for the next map", PREFIX, szName);
	}
	g_bBeInVote = true;
	g_iTotal = 0;
	arrayset(g_iVoteItem, TeamName, 9);
	arrayset(g_iInMenu, -1, 7);
	arrayset(g_bHasVoted, TeamName, 33);
	new Num;
	new NomInMenu;
	new Data[35];
	new iMax = 8;
	new Limits[2];
	Limits[0] = 7;
	Limits[1] = g_iLoadMaps - get_blocked_maps();
	new i;
	while (i < 2)
	{
		if (Limits[i] < iMax)
		{
			iMax = Limits[i];
		}
		i++;
	}
	new iNomMax;
	new iNomNum = ArraySize(g_iNominateArray);
	new var1;
	if (iNomNum > 5)
	{
		var1 = 5;
	}
	else
	{
		var1 = iNomNum;
	}
	iNomMax = var1;
	new i;
	while (i < iMax)
	{
		if (NomInMenu < iNomMax)
		{
			Num = random_num(TeamName, ArraySize(g_iNominateArray) - 1);
			ArrayGetArray(g_iNominateArray, Num, Data);
			formatex(g_szInMenuMapName[i], 32, Data);
			g_iInMenu[i] = Data[34];
			NomInMenu++;
			ArrayDeleteItem(g_iNominateArray, Num);
			g_iNominatedMaps[Data[33]]--;
		}
		i++;
	}
	g_iTimer = 3;
	if (g_iTimer > 10)
	{
		g_iTimer = 10;
	}
	set_task(1065353216, "Show_Timer", 978362, 8248, TeamName, 13248, g_iTimer);
	set_task(floatadd(1065353216, float(g_iTimer)), "Show_Menu", 978262, 8248, TeamName, 12600, TeamName);
	new iRet;
	ExecuteForward(g_iForwardStartVote, iRet);
	if (get_pcvar_num(g_pDebug))
	{
		new var3;
		if (g_bRockVote)
		{
			var3 = 1;
		}
		else
		{
			var3 = 0;
		}
		log_to_file("mapmanager_debug.log", "START_VOTE: RTV ? %d", var3);
	}
	return 1;
}

public Show_Timer()
{
	new szSec[16];
	get_ending(g_iTimer, "second", "seconds", "seconds", szSec, 15);
	new i = 1;
	while (i <= 32)
	{
		if (is_user_connected(i))
		{
			new var1;
			if (is_user_alive(i))
			{
				var1 = 1063675494;
			}
			else
			{
				var1 = 1050253722;
			}
			set_hudmessage(50, 255, 50, -1082130432, var1, TeamName, TeamName, 1065353216, TeamName, TeamName, 4);
			show_hudmessage(i, "Map voting will begin in %d %s!", g_iTimer, szSec);
		}
		i++;
	}
	g_iTimer -= 1;
	client_cmd(TeamName, "spk %s", g_szSound[g_iTimer]);
	return 0;
}

public Show_Menu()
{
	new Players[32];
	new pNum;
	new iPlayer;
	get_players(Players, pNum, "ch", 13724);
	g_iVoteTime = 20;
	new i;
	while (i < pNum)
	{
		iPlayer = Players[i];
		VoteMenu(iPlayer + 978162);
		set_task(1065353216, "VoteMenu", iPlayer + 978162, 8248, TeamName, 13764, "TERRORIST");
		i++;
	}
	set_task(1065353216, "Timer", 978462, 8248, TeamName, 13796, 21);
	client_cmd(TeamName, "spk Gman/Gman_Choose2");
	return 0;
}

public VoteMenu(id)
{
	new nextMap[32];
	get_cvar_string("amx_nextmap", nextMap, 31);
	id += -978162;
	if (g_iVoteTime)
	{
		new szMenu[512];
		new len;
		new var1;
		if (g_bHasVoted[id])
		{
			var1 = 13980;
		}
		else
		{
			var1 = 14032;
		}
		len = formatex(szMenu[len], 511 - len, "\y%s:\n\n", var1);
		new Key;
		new iPercent;
		new i;
		new iMax = maps_in_menu();
		i = 0;
		while (i < iMax)
		{
			iPercent = 0;
			if (g_iTotal)
			{
				iPercent = floatround(1120403456 * g_iVoteItem[i] / g_iTotal, TeamName);
			}
			if (!g_bHasVoted[id])
			{
				len = formatex(szMenu[len], 511 - len, "\r%d.\w %s\d[\r%d%%\d]\n", i + 1, g_szInMenuMapName[i], iPercent) + len;
				Key = 1 << i | Key;
			}
			else
			{
				len = formatex(szMenu[len], 511 - len, "\d%s[\r%d%%\d]\n", g_szInMenuMapName[i], iPercent) + len;
			}
			i++;
		}
		new var2;
		if (get_pcvar_num(g_pTimeLimit) && g_iExtendedMax < get_pcvar_num(g_pExendedMax))
		{
			iPercent = 0;
			if (g_iTotal)
			{
				iPercent = floatround(1120403456 * g_iVoteItem[i] / g_iTotal, TeamName);
			}
			if (!g_bHasVoted[id])
			{
				len = formatex(szMenu[len], 511 - len, "\n\r%d.\w Extend map %s\d[\r%d%%\d]\y\n", i + 1, g_szCurrentMap, iPercent) + len;
				Key = 1 << i | Key;
			}
			len = formatex(szMenu[len], 511 - len, "\n\dExtend map %s[\r%d%%\d]\y\n", g_szCurrentMap, iPercent) + len;
		}
		new var3;
		if (get_pcvar_num(g_pTimeLimit) && g_iExtendedMax < get_pcvar_num(g_pExendedMax))
		{
			i++;
			iPercent = 0;
			if (g_iTotal)
			{
				iPercent = floatround(1120403456 * g_iVoteItem[i] / g_iTotal, TeamName);
			}
			if (!g_bHasVoted[id])
			{
				len = formatex(szMenu[len], 511 - len, "\r%d.\w Keep current nextmap: %s\d[\r%d%%\d]\y\n", i + 1, nextMap, iPercent) + len;
				Key = 1 << i | Key;
			}
			len = formatex(szMenu[len], 511 - len, "\dKeep current nextmap: %s[\r%d%%\d]\y\n", nextMap, iPercent) + len;
		}
		new var4;
		if (!g_bHasVoted[id] && !g_DefaultChange && get_pcvar_num(g_pMenuStopVote) && get_user_flags(id, TeamName) & 32)
		{
			i++;
			new var5;
			if (i + 1 == 10)
			{
				var5 = 0;
			}
			else
			{
				var5 = i + 1;
			}
			len = formatex(szMenu[len], 511 - len, "\n\r%d. Cancel Vote\n", var5) + len;
			Key = 1 << i | Key;
		}
		new szSec[16];
		get_ending(g_iVoteTime, "seconds", "second", "seconds", szSec, 15);
		len = formatex(szMenu[len], 511 - len, "\n\r%d\d %s \dremaining", g_iVoteTime, szSec) + len;
		if (!Key)
		{
			Key |= 512;
		}
		new var6;
		if (g_bHasVoted[id] && get_pcvar_num(g_pShowResultType) == 1)
		{
			do {
			} while (replace(szMenu, 511, "\r", 15168));
			do {
			} while (replace(szMenu, 511, "\d", 15184));
			do {
			} while (replace(szMenu, 511, "\w", 15200));
			do {
			} while (replace(szMenu, 511, "\y", 15216));
			set_hudmessage(12, 122, 221, 1017370378, -1082130432, TeamName, 1086324736, 1065353216, 1036831949, 1045220557, 4);
			show_hudmessage(id, "%s", szMenu);
		}
		else
		{
			show_menu(id, Key, szMenu, -1, "Vote_Menu");
		}
		return 1;
	}
	show_menu(id, TeamName, 13940, 1, 9844);
	if (task_exists(id + 978162, TeamName))
	{
		remove_task(id + 978162, TeamName);
	}
	return 1;
}

public VoteMenu_Handler(id, key)
{
	if (g_bHasVoted[id])
	{
		VoteMenu(id + 978162);
		return 1;
	}
	new var1;
	if (get_pcvar_num(g_pMenuStopVote) && maps_in_menu() + 2 == key)
	{
		Command_StopVote(id, 32);
		return 1;
	}
	g_iVoteItem[key]++;
	g_iTotal += 1;
	new nextMap[32];
	get_cvar_string("amx_nextmap", nextMap, 31);
	g_bHasVoted[id] = 1;
	new iCvar = get_pcvar_num(g_pShowSelects);
	if (iCvar)
	{
		new szName[32];
		get_user_name(id, szName, 31);
		if (maps_in_menu() == key)
		{
			switch (iCvar)
			{
				case 1:
				{
					ColorChat(0, Color:2, "\x04%s\x01 \x03%s\x01 chose map extending", PREFIX, szName);
				}
				case 2:
				{
					ColorChat(id, Color:3, "\x04%s\x01 you chose map extending", PREFIX);
				}
				default:
				{
				}
			}
		}
		else
		{
			if (maps_in_menu() + 1 == key)
			{
				switch (iCvar)
				{
					case 1:
					{
						ColorChat(0, Color:2, "\x04%s\x03 %s\x01 chose\x03 %s\x01", PREFIX, szName, nextMap);
					}
					case 2:
					{
						ColorChat(id, Color:3, "\x04%s\x01 you chose\x03 %s\x01", PREFIX, nextMap);
					}
					default:
					{
					}
				}
			}
			switch (iCvar)
			{
				case 1:
				{
					ColorChat(0, Color:2, "\x04%s\x03 %s\x01 chose\x03 %s\x01", PREFIX, szName, g_szInMenuMapName[key]);
				}
				case 2:
				{
					ColorChat(id, Color:3, "\x04%s\x01 You chose\x03 %s\x01", PREFIX, g_szInMenuMapName[key]);
				}
				default:
				{
				}
			}
		}
	}
	if (get_pcvar_num(g_pShowResultAfterVote))
	{
		VoteMenu(id + 978162);
	}
	else
	{
		if (task_exists(id + 978162, TeamName))
		{
			remove_task(id + 978162, TeamName);
		}
	}
	return 1;
}

public Timer()
{
	g_iVoteTime -= 1;
	if (!g_iVoteTime)
	{
		FinishVote();
		show_menu(TeamName, TeamName, 15876, 1, 9844);
		if (task_exists(978462, TeamName))
		{
			remove_task(978462, TeamName);
		}
	}
	return 0;
}

FinishVote()
{
	new MaxVote;
	new iInMenu = maps_in_menu();
	new iRandom;
	new iMax = iInMenu + 2;
	new i = 1;
	while (i < iMax)
	{
		iRandom = random_num(TeamName, 1);
		switch (iRandom)
		{
			case 0:
			{
				if (g_iVoteItem[i] > g_iVoteItem[MaxVote])
				{
					MaxVote = i;
				}
			}
			case 1:
			{
				if (g_iVoteItem[i] >= g_iVoteItem[MaxVote])
				{
					MaxVote = i;
				}
			}
			default:
			{
			}
		}
		i++;
	}
	g_bBeInVote = false;
	g_bVoteFinished = true;
	new var2;
	if (!g_iTotal || (iInMenu != MaxVote && iInMenu + 1 != MaxVote))
	{
		if (g_iTotal)
		{
			client_print(TeamName, "", "[KZ] Nextmap: %s", g_szInMenuMapName[MaxVote]);
			set_pcvar_string(g_pNextMap, g_szInMenuMapName[MaxVote]);
		}
		else
		{
			new nextMap[64];
			get_cvar_string("amx_nextmap", nextMap, 64);
			client_print(TeamName, "", "[KZ] Nextmap: %s", nextMap);
			set_pcvar_string(g_pNextMap, nextMap);
		}
		new var3;
		if ((g_bRockVote && get_pcvar_num(g_pRockChange)) || get_pcvar_num(g_pChangeMap))
		{
			if (!g_DefaultChange)
			{
				ColorChat(0, Color:3, "\x04%s\x01 Map will change in\x03 10\x01 seconds", PREFIX);
				set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) + 6);
				set_task(1092616192, "ChangeLevel", 978562, 8248, TeamName, 12600, TeamName);
				if (get_pcvar_num(g_pDebug))
				{
					log_to_file("mapmanager_debug.log", "FINISH_VOTE: ChangeLevel");
				}
			}
		}
		else
		{
			new var5;
			if ((g_bRockVote && !g_DefaultChange && get_pcvar_num(g_pRockChange) == 1) || get_pcvar_num(g_pChangeMap) == 1)
			{
				ColorChat(0, Color:3, "\x04%s\x01 Map will change at end of this round", PREFIX);
			}
		}
	}
	else
	{
		if (iInMenu == MaxVote)
		{
			g_bVoteFinished = false;
			g_bBeInVote = false;
			g_iExtendedMax += 1;
			new iMin = get_pcvar_num(g_pExendedTime);
			new szMin[16];
			get_ending(iMin, "minutes", "minutes", "minutes", szMin, 15);
			ColorChat(0, Color:3, "\x04%s\x01 Current map will be extended to next \x03%d\x01 %s", PREFIX, iMin, szMin);
			new i = 1;
			while (i <= 32)
			{
				if (is_user_connected(i))
				{
					g_bRockVoted[i] = 0;
				}
				i++;
			}
			g_iRockVote = 0;
			set_cvar_num("mp_timelimit", iMin + get_pcvar_num(g_pTimeLimit));
		}
		new nextMap[32];
		get_cvar_string("amx_nextmap", nextMap, 31);
		client_print(TeamName, "", "[KZ] Nextmap: %s", nextMap);
		set_pcvar_string(g_pNextMap, nextMap);
		new var7;
		if ((g_bRockVote && !g_DefaultChange && get_pcvar_num(g_pRockChange)) || get_pcvar_num(g_pChangeMap))
		{
			if (!g_DefaultChange)
			{
				ColorChat(0, Color:3, "\x04%s\x01 Map will change in\x03 10\x01 seconds", PREFIX);
				set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) + 6);
				set_task(1092616192, "ChangeLevel", 978562, 8248, TeamName, 12600, TeamName);
				if (get_pcvar_num(g_pDebug))
				{
					log_to_file("mapmanager_debug.log", "FINISH_VOTE: ChangeLevel");
				}
			}
		}
		else
		{
			new var9;
			if ((g_bRockVote && !g_DefaultChange && get_pcvar_num(g_pRockChange) == 1) || get_pcvar_num(g_pChangeMap) == 1)
			{
				ColorChat(0, Color:3, "\x04%s\x01 Map will change at end of this round", PREFIX);
			}
		}
	}
	new iRet;
	ExecuteForward(g_iForwardFinishVote, iRet);
	return 0;
}

public ChangeLevel()
{
	new szMap[33];
	get_pcvar_string(g_pNextMap, szMap, 32);
	set_cvar_num("mp_timelimit", 40);
	set_pcvar_num(g_pChatTime, get_pcvar_num(g_pChatTime) - 6);
	server_cmd("changelevel %s", szMap);
	return 0;
}

public SoundTimer()
{
	set_task(1065353216, "Show_Timer2", 978362, 8248, TeamName, 17788, 10);
	return 0;
}

public Show_Timer2()
{
	static iTimer;
	if (!iTimer)
	{
		iTimer = 10;
	}
	new szSec[16];
	get_ending(iTimer, "second", "seconds", "seconds", szSec, 15);
	new i = 1;
	while (i <= 32)
	{
		if (is_user_connected(i))
		{
			new var1;
			if (is_user_alive(i))
			{
				var1 = 1063675494;
			}
			else
			{
				var1 = 1050253722;
			}
			set_hudmessage(50, 255, 50, -1082130432, var1, TeamName, TeamName, 1065353216, TeamName, TeamName, 4);
			show_hudmessage(i, "Map will change in %d %s!", iTimer, szSec);
		}
		i++;
	}
	iTimer -= 1;
	client_cmd(TeamName, "spk %s", g_szSound[iTimer]);
	return 0;
}

bool:valid_map(map[])
{
	if (is_map_valid(map))
	{
		return true;
	}
	new len = strlen(map) - 4;
	if (0 > len)
	{
		return false;
	}
	if (equali(map[len], ".bsp", TeamName))
	{
		map[len] = 0;
		if (is_map_valid(map))
		{
			return true;
		}
	}
	return false;
}

bool:in_maps_array(map[])
{
	new szMap[33];
	new iMax = ArraySize(g_iMapsArray);
	new i;
	while (i < iMax)
	{
		ArrayGetString(g_iMapsArray, i, szMap, 32);
		if (equali(szMap, map, TeamName))
		{
			return true;
		}
		i++;
	}
	return false;
}

get_blocked_maps()
{
	new iCount;
	new i;
	while (i < 1)
	{
		if (g_BlockedMaps[i][33])
		{
			iCount++;
		}
		i++;
	}
	return iCount;
}

clear_blocked_maps()
{
	new i;
	while (i < 1)
	{
		g_BlockedMaps[i][33] = 0;
		i++;
	}
	delete_file(FILE_BLOCKEDMAPS);
	return 0;
}

get_blocked_map_count(map[])
{
	new i;
	while (i < 1)
	{
		if (equali(g_BlockedMaps[i], map, TeamName))
		{
			return g_BlockedMaps[i][33];
		}
		i++;
	}
	return 0;
}

clear_nominated_maps(id)
{
	new Data[35];
	new i;
	while (ArraySize(g_iNominateArray) > i)
	{
		ArrayGetArray(g_iNominateArray, i, Data);
		if (id == Data[33])
		{
			i--;
			ArrayDeleteItem(g_iNominateArray, i);
			new var1 = g_iNominatedMaps[id];
			var1--;
			if (!var1)
			{
				return 0;
			}
		}
		i++;
	}
	return 0;
}

remove_nominated_map(id, map[])
{
	new Data[35];
	new iMax = ArraySize(g_iNominateArray);
	new i;
	while (i < iMax)
	{
		ArrayGetArray(g_iNominateArray, i, Data);
		new var1;
		if (id == Data[33] && equali(Data, map, TeamName))
		{
			new szName[32];
			get_user_name(id, szName, 31);
			g_iNominatedMaps[id]--;
			ArrayDeleteItem(g_iNominateArray, i);
			ColorChat(0, Color:6, "\x04%s\x03 %s\x01 delete map from nominations\x03 %s\x01", PREFIX, szName, map);
			return 0;
		}
		i++;
	}
	return 0;
}

is_map_nominated(map[])
{
	new Data[35];
	new iMax = ArraySize(g_iNominateArray);
	new i;
	while (i < iMax)
	{
		ArrayGetArray(g_iNominateArray, i, Data);
		if (equali(Data, map, TeamName))
		{
			return Data[33];
		}
		i++;
	}
	return 0;
}

bool:in_menu(num)
{
	new i;
	while (i < 7 && i < 8)
	{
		if (g_iInMenu[i] == num)
		{
			return true;
		}
		i++;
	}
	return false;
}

bool:is_blocked(num)
{
	new szMap[33];
	ArrayGetString(g_iMapsArray, num, szMap, 32);
	new i;
	while (i < 1)
	{
		if (equali(g_BlockedMaps[i], szMap, TeamName))
		{
			return true;
		}
		i++;
	}
	return false;
}

maps_in_menu()
{
	new map;
	new i;
	while (i < 7)
	{
		if (g_iInMenu[i] != -1)
		{
			map++;
		}
		i++;
	}
	return map;
}

get_players_num()
{
	new iPlayers;
	new iMax = get_maxplayers();
	new id = 1;
	while (id < iMax)
	{
		new var1;
		if (is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id))
		{
			iPlayers++;
		}
		id++;
	}
	return iPlayers;
}

get_ending(num, a[], b[], c[], output[], lenght)
{
	new num100 = num % 100;
	new num10 = num % 10;
	new var1;
	if ((num100 >= 5 && num100 <= 20) || (num10 && (num10 >= 5 && num10 <= 9)))
	{
		format(output, lenght, "%s", a);
	}
	else
	{
		if (num10 == 1)
		{
			format(output, lenght, "%s", b);
		}
		new var4;
		if (num10 >= 2 && num10 <= 4)
		{
			format(output, lenght, "%s", c);
		}
	}
	return 0;
}

 