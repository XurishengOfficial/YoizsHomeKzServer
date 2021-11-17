new Float:VEC_NULL[3];
new TeamName[4][] =
{
	{
		0, ... /* 可能是开头的一个字串 */
	},
	{
		84, ... /* 可能是T开头的一个字串 */
	},
	{
		67, ... /* 可能是C开头的一个字串 */
	},
	{
		83, ... /* 可能是S开头的一个字串 */
	}
};
new g_iDHudProperties[9] =
{
	16, 16, 52, 60, 0, 84, 69, 82, 82
};
new sHudObj;
new g_szPrefix[32];
new bool:g_bPlayerVoted[33];
new bool:g_bKZMenuOpened[33];
new Float:g_flInitTime;
new bool:g_bVoteStarted;
new bool:g_bVoteFinished;
new bool:g_bNotEnoughMaps;
new g_iWinner;
new g_iCounterVoting[33];
new g_iCounterForTask;
new g_szMap[5][32];
new g_szMenuItem[5][40];
new g_iMapVotes[6];
new g_szCurrentMap[34];
new g_szActualMapName[34];
new Trie:g_tAllMapsLow;
new Array:g_aAllMaps;
new Float:g_flOldOrigin[33][3];
new Float:g_flNewOrigin[33][3];
new g_iMenuPosition[33];
new g_iMenuPlayers[33][32];
new g_szMapCycle[128];
is_zero_vec(Float:flVec[3])
{
	new var1;
	return flVec[0] == 0.0 && flVec[1] == 0.0 && flVec[2] == 0.0;
}

vector_copy(Float:flVec1[3], Float:flVec2[3])
{
	flVec2[0] = flVec1[0];
	flVec2[1] = flVec1[1];
	flVec2[2] = flVec1[2];
	return 0;
}

get_player_position(id, Float:flOrigin[3], Float:flAngles[3], &Float:flGravity)
{
	pev(id, 118, flOrigin);
	pev(id, 126, flAngles);
	pev(id, 34, flGravity);
	return 0;
}

set_player_origin(id, Float:flOrigin[3], Float:flAngles[3], Float:flGravity, Float:flFuser2)
{
	new iFlags = pev(id, 84);
	iFlags &= -4194305;
	iFlags |= 16384;
	set_pev(id, 84, iFlags);
	new Float:VEC_DUCK_HULL_MIN[3] = {4.6188E-41,4.6188E-41,5.1928E-41};
	new Float:VEC_DUCK_HULL_MAX[3] = {4.6009E-41,4.6009E-41,9.2E-44};
	new Float:VEC_DUCK_VIEW[3] = {0.0,0.0,2.305E-41};
	engfunc(5, id, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX);
	engfunc(26, id, flOrigin);
	set_pev(id, 135, VEC_DUCK_VIEW);
	set_pev(id, 120, VEC_NULL);
	set_pev(id, 121, VEC_NULL);
	if (flGravity > 0.0)
	{
		set_pev(id, 34, flGravity);
	}
	set_pev(id, 60, flFuser2);
	if (!is_zero_vec(flAngles))
	{
		set_pev(id, 126, VEC_NULL);
		set_pev(id, 124, flAngles);
		set_pev(id, 140, VEC_NULL);
		set_pev(id, 65, 1);
	}
	return 0;
}

register_saycmd(command[], function[], flags, info[])
{
	new szTemp[64];
	formatex(szTemp, 63, "say /%s", command);
	register_clcmd(szTemp, function, flags, info, -1);
	formatex(szTemp, 63, "say .%s", command);
	register_clcmd(szTemp, function, flags, info, -1);
	formatex(szTemp, 63, "say_team /%s", command);
	register_clcmd(szTemp, function, flags, info, -1);
	formatex(szTemp, 63, "say_team .%s", command);
	register_clcmd(szTemp, function, flags, info, -1);
	return 0;
}

send_cmd(id, text[])
{
	message_begin(1, 51, 216, id);
	write_byte(strlen(text) + 2);
	write_byte(10);
	write_string(text);
	message_end();
	return 0;
}

is_user_localhost(id)
{
	new szIP[16];
	get_user_ip(id, szIP, 15, 1);
	new var1;
	if (equal(szIP, "loopback", VEC_NULL) || equal(szIP, "127.0.0.1", VEC_NULL))
	{
		return 1;
	}
	return 0;
}

client_print_f(id, ColorType:type, msg[])
{
	new message[256];
	switch (type)
	{
		case 1:
		{
			message[0] = 1;
		}
		case 2:
		{
			message[0] = 4;
		}
		default:
		{
			message[0] = 3;
		}
	}
	vformat(message[1], 251, msg, 4);
	message[192] = 0;
	new team;
	new ColorChange;
	new index;
	new MSG_Type;
	if (id)
	{
		MSG_Type = 1;
		index = id;
	}
	else
	{
		index = FindPlayer();
		MSG_Type = 2;
	}
	team = get_user_team(index, {0}, VEC_NULL);
	new var1;
	if (team >= 0 && team < 4)
	{
		ColorChange = ColorSelection(index, MSG_Type, type);
		ShowColorMessage(index, MSG_Type, message);
		if (ColorChange)
		{
			Team_Info(index, MSG_Type, TeamName[team]);
		}
	}
	return 0;
}

ShowColorMessage(id, type, message[])
{
	static bool:saytext_used;
	static get_user_msgid_saytext;
	if (!saytext_used)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
		saytext_used = true;
	}
	message_begin(type, get_user_msgid_saytext, 216, id);
	write_byte(id);
	write_string(message);
	message_end();
	return 0;
}

Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if (!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, 216, id);
	write_byte(id);
	write_string(team);
	message_end();
	return 1;
}

ColorSelection(index, type, ColorType:Type)
{
	switch (Type)
	{
		case 4:
		{
			new var1 = TeamName;
			return Team_Info(index, type, var1[0][var1]);
		}
		case 5:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case 6:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		default:
		{
			return 0;
		}
	}
}

FindPlayer()
{
	new i = -1;
	while (get_maxplayers() >= i)
	{
		i++;
		if (is_user_connected(i))
		{
			return i;
		}
	}
	return -1;
}

show_my_menu(index, keys, menu[], time, title[])
{
	set_pdata_int(index, 205, VEC_NULL, 5, 5);
	show_menu(index, keys, menu, time, title);
	return 0;
}

public plugin_init()
{
	register_plugin("KZ Demo MC", "3.1", "Kpoluk");
	sHudObj = CreateHudSyncObj(VEC_NULL);
	register_saycmd("timeleft", "cmdTimeleft", -1, {0});
	register_clcmd("say timeleft", "cmdTimeleft", -1, 9172, -1);
	register_clcmd("say_team timeleft", "cmdTimeleft", -1, 9172, -1);
	register_saycmd("tl", "cmdTimeleft", -1, {0});
	register_clcmd("say tl", "cmdTimeleft", -1, 9172, -1);
	register_clcmd("say_team tl", "cmdTimeleft", -1, 9172, -1);
	register_saycmd("thetime", "cmdTheTime", -1, {0});
	register_clcmd("say thetime", "cmdTheTime", -1, 9172, -1);
	register_clcmd("say_team thetime", "cmdTheTime", -1, 9172, -1);
	register_saycmd("rtv", "cmdRTV", -1, {0});
	register_clcmd("say rtv", "cmdRTV", -1, 9172, -1);
	register_clcmd("say_team rtv", "cmdRTV", -1, 9172, -1);
	register_saycmd("rockthevote", "cmdRTV", -1, {0});
	register_clcmd("say rockthevote", "cmdRTV", -1, 9172, -1);
	register_clcmd("say_team rockthevote", "cmdRTV", -1, 9172, -1);
	register_saycmd("currentmap", "cmdCurrentMap", -1, {0});
	register_clcmd("say currentmap", "cmdCurrentMap", -1, 9172, -1);
	register_clcmd("say_team currentmap", "cmdCurrentMap", -1, 9172, -1);
	register_saycmd("curmap", "cmdCurrentMap", -1, {0});
	register_clcmd("say curmap", "cmdCurrentMap", -1, 9172, -1);
	register_clcmd("say_team curmap", "cmdCurrentMap", -1, 9172, -1);
	register_saycmd("nextmap", "cmdNextMap", -1, {0});
	register_clcmd("say nextmap", "cmdNextMap", -1, 9172, -1);
	register_clcmd("say_team nextmap", "cmdNextMap", -1, 9172, -1);
	register_clcmd("randommap", "cmdRandomMap", -1, 9172, -1);
	register_saycmd("vip", "cmdVIP", -1, {0});
	register_saycmd("vipmenu", "cmdVIP", -1, {0});
	register_saycmd("teleport", "cmdTeleport", -1, {0});
	get_cvar_string("kz_prefix", g_szPrefix, "AB");
	if (!g_szPrefix[0])
	{
		formatex(g_szPrefix, "AB", "KZ");
	}
	g_flInitTime = get_gametime();
	get_mapname(g_szCurrentMap, 33);
	g_bNotEnoughMaps = false;
	g_tAllMapsLow = TrieCreate();
	g_aAllMaps = ArrayCreate(30, 32);
	get_localinfo("amxx_datadir", g_szMapCycle, 127);
	format(g_szMapCycle, 127, "%s/maps.txt", g_szMapCycle);
	if (file_exists(g_szMapCycle))
	{
		readMapCycle();
		new szLowMapName[34];
		formatex(szLowMapName, 33, g_szCurrentMap);
		strtolower(szLowMapName);
		if (!TrieKeyExists(g_tAllMapsLow, szLowMapName))
		{
			findMaps();
			TrieClear(g_tAllMapsLow);
			ArrayClear(g_aAllMaps);
			readMapCycle();
		}
		new iNum = -1;
		TrieGetCell(g_tAllMapsLow, szLowMapName, iNum);
		if (0 <= iNum)
		{
			ArrayGetString(g_aAllMaps, iNum, g_szActualMapName, 33);
			if (!equal(g_szCurrentMap, g_szActualMapName, VEC_NULL))
			{
				set_task(1056964608, "taskCorrectMap", 1500, 11700, VEC_NULL, 11704, VEC_NULL);
			}
		}
	}
	else
	{
		findMaps();
		if (file_exists(g_szMapCycle))
		{
			readMapCycle();
		}
		log_amx("maps.txt does not exists");
		g_bNotEnoughMaps = true;
	}
	g_bVoteStarted = false;
	g_bVoteFinished = false;
	g_iWinner = -1;
	set_task(1065353216, "taskStartVote", 1100, 11864, VEC_NULL, 11868, VEC_NULL);
	register_menucmd(register_menuid("MapMenu", VEC_NULL), 895, "handleMapMenu");
	register_menucmd(register_menuid("VIPMenu", VEC_NULL), 1023, "handleVIPMenu");
	register_menucmd(register_menuid("TeleMenu", VEC_NULL), 1023, "handleTeleMenu");
	return 0;
}

public client_putinserver(id)
{
	if (!is_user_bot(id))
	{
		g_bPlayerVoted[id] = 0;
		g_bKZMenuOpened[id] = 0;
		g_iCounterVoting[id] = 0;
		vector_copy(VEC_NULL, g_flOldOrigin[id]);
		vector_copy(VEC_NULL, g_flNewOrigin[id]);
	}
	return 0;
}

public taskCorrectMap(id)
{
	server_cmd("changelevel \"%s\"", g_szActualMapName);
	return 0;
}

public findMaps()
{
	new szFileName[120];
	new namelen;
	new hDir = open_dir("maps", szFileName, 119);
	if (!hDir)
	{
		log_amx("Cannot open maps directory");
		return 0;
	}
	new f = fopen(g_szMapCycle, "wt");
	do {
		namelen = strlen(szFileName);
		if (namelen > 4)
		{
			if (equal(szFileName[namelen + -4], ".bsp", VEC_NULL))
			{
				szFileName[namelen + -4] = 0;
				if (is_map_valid(szFileName))
				{
					format(szFileName, 119, "%s\n", szFileName);
					fputs(f, szFileName);
				}
			}
		}
	} while (next_file(hDir, szFileName, 119));
	fclose(f);
	close_dir(hDir);
	return 0;
}

public readMapCycle()
{
	new szData[50];
	new iMaps;
	new iCurMap;
	new f = fopen(g_szMapCycle, "rt");
	while (!feof(f))
	{
		fgets(f, szData, 49);
		trim(szData);
		if (equali(szData, g_szCurrentMap, VEC_NULL))
		{
			iCurMap = iMaps;
		}
		if (!equali(szData, 12404, VEC_NULL))
		{
			if (is_map_valid(szData))
			{
				ArrayPushString(g_aAllMaps, szData);
				strtolower(szData);
				TrieSetCell(g_tAllMapsLow, szData, iMaps);
				iMaps++;
			}
		}
	}
	log_amx("%d maps loaded from maps.txt", iMaps);
	fclose(f);
	if (iMaps < 7)
	{
		log_amx("Not enough maps in maps.txt");
		g_bNotEnoughMaps = true;
	}
	else
	{
		new iRandomNums[5];
		do {
			iRandomNums[0] = random_num(VEC_NULL, iMaps + -1);
		} while (iCurMap == iRandomNums[0]);
		while (iRandomNums[0] != iRandomNums[1] && iCurMap != iRandomNums[1])
		{
		}
		while (iRandomNums[0] != iRandomNums[2] && iRandomNums[1] != iRandomNums[2] && iCurMap != iRandomNums[2])
		{
		}
		while (iRandomNums[0] != iRandomNums[3] && iRandomNums[1] != iRandomNums[3] && iRandomNums[2] != iRandomNums[3] && iCurMap != iRandomNums[3])
		{
		}
		while (iRandomNums[0] != iRandomNums[4] && iRandomNums[1] != iRandomNums[4] && iRandomNums[2] != iRandomNums[4] && iRandomNums[3] != iRandomNums[4] && iCurMap != iRandomNums[4])
		{
		}
		new i;
		while (i < 5)
		{
			ArrayGetString(g_aAllMaps, iRandomNums[i], g_szMap[i], "AB");
			i++;
		}
	}
	return 0;
}

public cmdRandomMap(id)
{
	if (!is_user_localhost(id))
	{
		return 1;
	}
	new iMaps = ArraySize(g_aAllMaps);
	if (iMaps < 2)
	{
		client_print_f(id, ColorType:5, "\x03[%s]\x01 Not enough maps", g_szPrefix);
		return 1;
	}
	new iRandomNum;
	new szMap[34];
	do {
		iRandomNum = random_num(VEC_NULL, iMaps + -1);
		ArrayGetString(g_aAllMaps, iRandomNum, szMap, 33);
	} while (equali(szMap, g_szCurrentMap, VEC_NULL));
	server_cmd("changelevel \"%s\"", szMap);
	return 1;
}

public taskStartVote()
{
	static iTimeleft;
	if (0 < get_cvar_num("mp_timelimit"))
	{
		iTimeleft = get_timeleft();
		if (iTimeleft < 60)
		{
			new var1;
			if (!g_bVoteStarted && !g_bVoteFinished)
			{
				StartVote();
			}
			if (iTimeleft == 1)
			{
				message_begin(2, 30, 216, VEC_NULL);
				message_end();
			}
			if (iTimeleft <= 1)
			{
				if (!task_exists(1300, VEC_NULL))
				{
					set_task(1077936128, "taskChangeLevel", 1300, 11700, VEC_NULL, 11704, VEC_NULL);
				}
			}
		}
	}
	return 0;
}

public cmdTimeleft(id)
{
	if (get_cvar_num("mp_timelimit"))
	{
		if (g_bVoteStarted)
		{
			client_print_f(id, ColorType:5, "\x03[%s]\x01 Voting is in progress", g_szPrefix);
			return 1;
		}
		new timeleft;
		new iMinutes;
		new iSeconds;
		timeleft = get_timeleft();
		if (0 > timeleft)
		{
			return 1;
		}
		iMinutes = timeleft / 60;
		iSeconds = timeleft - iMinutes * 60;
		if (iMinutes <= 99)
		{
			client_print_f(id, ColorType:5, "\x04[%s]\x01 Timeleft:\x04 %02d:%02d", g_szPrefix, iMinutes, iSeconds);
		}
		else
		{
			client_print_f(id, ColorType:5, "\x04[%s]\x01 Timeleft:\x04 %03d:%02d", g_szPrefix, iMinutes, iSeconds);
		}
		return 1;
	}
	client_print_f(id, ColorType:5, "\x03[%s]\x01 No Time Limit", g_szPrefix);
	return 1;
}

public cmdTheTime(id)
{
	new curdate[30];
	new curtime[30];
	get_time("%d.%m.%Y", curdate, 29);
	get_time("%H:%M:%S", curtime, 29);
	client_print_f(id, ColorType:5, "\x04[%s]\x01 The time is:\x04 %s\x01 -\x04 %s", g_szPrefix, curdate, curtime);
	return 1;
}

public cmdNextMap(id)
{
	new var1;
	if (g_iWinner < 0 || g_iWinner == 5)
	{
		client_print_f(id, ColorType:5, "\x03[%s]\x01 Not voted yet", g_szPrefix);
	}
	else
	{
		if (g_iWinner < 5)
		{
			client_print_f(id, ColorType:5, "\x04[%s]\x01 Next map:\x04 %s", g_szPrefix, g_szMap[g_iWinner]);
		}
	}
	return 1;
}

public cmdCurrentMap(id)
{
	client_print_f(id, ColorType:5, "\x04[%s]\x01 Current Map:\x04 %s", g_szPrefix, g_szCurrentMap);
	return 1;
}

public cmdRTV(id)
{
	if (!get_user_flags(id, VEC_NULL) & 512)
	{
		return 1;
	}
	if (g_bVoteStarted)
	{
		client_print_f(id, ColorType:5, "\x03[%s]\x01 Voting is in progress", g_szPrefix);
		return 1;
	}
	if (g_bNotEnoughMaps)
	{
		client_print_f(id, ColorType:5, "\x03[%s]\x01 Voting failed. Not enough maps", g_szPrefix);
		return 1;
	}
	StartVote();
	client_print_f(0, ColorType:5, "\x04[%s]\x01 Voting started", g_szPrefix);
	return 1;
}

public cmdVIP(id)
{
	if (!is_user_localhost(id))
	{
		return 1;
	}
	new szMenu[400];
	if (0 < get_cvar_num("mp_timelimit"))
	{
		formatex(szMenu, 399, "\rVIP \yMenu\n\n\r1. Teleport \wMenu\n\r2. GAG \wMenu\n\r3. \wExtend Map for \r15 \wminutes\n\r4. \wForce \rRTV\n\n\r6. Ban \wMenu\n\n\n\n\r9. \wBack\n\r0. \wExit");
		show_my_menu(id, 815, szMenu, -1, "VIPMenu");
	}
	else
	{
		formatex(szMenu, 399, "\rVIP \yMenu\n\n\r1. Teleport \wMenu\n\r2. GAG \wMenu\n\r3. \dExtend Map for 15 minutes\n\r4. \wForce \rRTV\n\n\r6. Ban \wMenu\n\n\n\n\r9. \wBack\n\r0. \wExit");
		show_my_menu(id, 811, szMenu, -1, "VIPMenu");
	}
	return 1;
}

public handleVIPMenu(id, item)
{
	switch (item)
	{
		case 0:
		{
			send_cmd(id, "say /teleport");
		}
		case 1:
		{
			send_cmd(id, "amx_gagmenu");
		}
		case 2:
		{
			if (get_cvar_num("mp_timelimit"))
			{
				if (g_bVoteStarted)
				{
					client_print_f(id, ColorType:5, "\x03[%s]\x01 Voting is in progress", g_szPrefix);
					return 1;
				}
				if (3 > get_timeleft())
				{
					client_print_f(id, ColorType:5, "\x03[%s]\x01 It's too late", g_szPrefix);
					return 1;
				}
				new name[32];
				get_user_name(id, name, "AB");
				replace_all(name, 31, 15956, 15964);
				replace_all(name, 31, 15968, 15976);
				new Float:fCurrTimelimit = get_cvar_float("mp_timelimit");
				server_cmd("mp_timelimit %.2f", floatadd(1097859072, fCurrTimelimit));
				client_print_f(0, ColorType:5, "\x03[%s] %s\x01 extended current map for\x03 15\x01 minutes", g_szPrefix, name);
				set_task(1065353216, "taskShowNewTimeLeft", 1450, 11700, VEC_NULL, 11704, VEC_NULL);
				g_bVoteFinished = false;
				cmdVIP(id);
			}
			client_print_f(id, ColorType:5, "\x03[%s]\x01 No Time Limit", g_szPrefix);
			return 1;
		}
		case 3:
		{
			if (g_bVoteStarted)
			{
				client_print_f(id, ColorType:5, "\x03[%s]\x01 Voting is in progress", g_szPrefix);
				return 1;
			}
			if (0 < get_cvar_num("mp_timelimit"))
			{
				if (3 > get_timeleft())
				{
					client_print_f(id, ColorType:5, "\x03[%s]\x01 It's too late", g_szPrefix);
					return 1;
				}
			}
			new name[32];
			get_user_name(id, name, "AB");
			replace_all(name, 31, 16628, 16636);
			replace_all(name, 31, 16640, 16648);
			StartVote();
			client_print_f(0, ColorType:5, "\x03[%s] %s\x01 has started the voting", g_szPrefix, name);
			cmdVIP(id);
		}
		case 5:
		{
			send_cmd(id, "amx_banmenu");
		}
		case 8:
		{
			send_cmd(id, "say /main");
		}
		case 9:
		{
		}
		default:
		{
		}
	}
	return 1;
}

public taskShowNewTimeLeft(id)
{
	cmdTimeleft(0);
	return 0;
}

public StartVote()
{
	if (g_bNotEnoughMaps)
	{
		client_print_f(0, ColorType:5, "\x03[%s]\x01 Voting failed. Not enough maps", g_szPrefix);
	}
	else
	{
		g_bVoteStarted = true;
		g_iCounterForTask = 9;
		set_task(1065353216, "taskCount", 1150, 17064, VEC_NULL, 17068, 9);
	}
	return 0;
}

public taskCount()
{
	g_iCounterForTask = g_iCounterForTask + -1;
	if (g_iCounterForTask)
	{
		set_hudmessage(200, 200, 200, -1082130432, 1043878380, VEC_NULL, VEC_NULL, 1066192077, 1036831949, 1045220557, 4);
		ShowSyncHudMsg(VEC_NULL, sHudObj, "Voting will begin in %d", g_iCounterForTask);
		if (g_iCounterForTask == 1)
		{
			new players[32];
			new pnum;
			new iPlayer;
			get_players(players, pnum, 17172, 17176);
			new i;
			while (i < pnum)
			{
				iPlayer = players[i];
				new var1;
				if (is_user_connected(iPlayer) && !is_user_bot(iPlayer))
				{
					new var2;
					if (isKZMenuOpened(iPlayer))
					{
						var2 = 1;
					}
					else
					{
						var2 = 0;
					}
					g_bKZMenuOpened[iPlayer] = var2;
					g_iCounterVoting[iPlayer] = 15;
					set_task(1065353216, "taskShowMapMenu", iPlayer + 1200, 17244, VEC_NULL, 17248, 18);
				}
				i++;
			}
			set_task(float(18), "taskCheckVotes", 1250, 11700, VEC_NULL, 11704, VEC_NULL);
		}
	}
	return 0;
}

public isKZMenuOpened(id)
{
	return 0;
}

public taskShowMapMenu(id)
{
	if (is_user_bot(id))
	{
		return 0;
	}
	static szMenu[450];
	static szMinutesLeft[15];
	g_iCounterVoting[id]--;
	if (0 < g_iCounterVoting[id])
	{
		formatex(szMinutesLeft, "�����", "(%d)", g_iCounterVoting[id]);
	}
	else
	{
		g_bPlayerVoted[id] = 1;
		formatex(szMinutesLeft, "�����", "(\rFinished\y)");
	}
	if (g_iCounterVoting[id] == -3)
	{
		if (g_bKZMenuOpened[id])
		{
			send_cmd(id, "say /kzmenu");
		}
		else
		{
			show_my_menu(id, 0, 19304, 1, 19312);
		}
	}
	else
	{
		if (g_bPlayerVoted[id])
		{
			new i;
			while (i < 5)
			{
				formatex(g_szMenuItem[i], 39, "\d%s \y[%d]", g_szMap[i], g_iMapVotes[i]);
				i++;
			}
			if (g_bKZMenuOpened[id])
			{
				new var1 = g_szMenuItem;
				formatex(szMenu, 449, "\yChoose Next Map %s:\n\n\r1. \wCheckPoint\n\r2. \wGoCheck\n\r3. %s\n\r4. %s\n\r5. %s\n\r6. %s\n\r7. %s\n\n\r9. \dExtend %s for %d minutes \y[%d]\n\r0. \wExit", szMinutesLeft, var1[0][var1], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szCurrentMap, 15, 2536 + 20);
				show_my_menu(id, 515, szMenu, -1, "MapMenu");
			}
			else
			{
				new var2 = g_szMenuItem;
				formatex(szMenu, 449, "\yChoose Next Map %s:\n\n\r1. \dCheckPoint\n\r2. \dGoCheck\n\r3. %s\n\r4. %s\n\r5. %s\n\r6. %s\n\r7. %s\n\n\r9. \dExtend %s for %d minutes \y[%d]\n\r0. \wExit", szMinutesLeft, var2[0][var2], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szCurrentMap, 15, 2536 + 20);
				show_my_menu(id, 512, szMenu, -1, "MapMenu");
			}
		}
		new i;
		while (i < 5)
		{
			formatex(g_szMenuItem[i], 39, "\w%s \y[%d]", g_szMap[i], g_iMapVotes[i]);
			i++;
		}
		if (g_bKZMenuOpened[id])
		{
			new var3 = g_szMenuItem;
			formatex(szMenu, 449, "\yChoose Next Map %s:\n\n\r1. \wCheckPoint\n\r2. \wGoCheck\n\r3. %s\n\r4. %s\n\r5. %s\n\r6. %s\n\r7. %s\n\n\r9. \yExtend \w%s \yfor %d minutes [%d]\n\r0. \wDo not vote", szMinutesLeft, var3[0][var3], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szCurrentMap, 15, 2536 + 20);
			show_my_menu(id, 895, szMenu, -1, "MapMenu");
		}
		new var4 = g_szMenuItem;
		formatex(szMenu, 449, "\yChoose Next Map %s:\n\n\r1. \dCheckPoint\n\r2. \dGoCheck\n\r3. %s\n\r4. %s\n\r5. %s\n\r6. %s\n\r7. %s\n\n\r9. \yExtend \w%s \yfor %d minutes [%d]\n\r0. \wDo not vote", szMinutesLeft, var4[0][var4], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szCurrentMap, 15, 2536 + 20);
		show_my_menu(id, 892, szMenu, -1, "MapMenu");
	}
	return 0;
}

public taskCheckVotes()
{
	new Float:flPassedTime = floatdiv(floatsub(get_gametime(), g_flInitTime), 1114636288);
	g_iWinner = 0;
	new i;
	new players[32];
	new pnum;
	get_players(players, pnum, 21980, 17176);
	if (0 < pnum)
	{
		i = 1;
		while (i < 6)
		{
			if (g_iMapVotes[g_iWinner] < g_iMapVotes[i])
			{
				g_iWinner = i;
			}
			i++;
		}
		new AllWinners[6];
		new WinnersNum;
		i = 1;
		while (i < 6)
		{
			if (g_iMapVotes[g_iWinner] == g_iMapVotes[i])
			{
				AllWinners[WinnersNum] = i;
				WinnersNum++;
				if (i == 5)
				{
					g_iWinner = 5;
				}
			}
			i++;
		}
		if (g_iWinner != 5)
		{
			g_iWinner = AllWinners[random_num(1, WinnersNum) - 1];
		}
	}
	if (g_iWinner == 5)
	{
		server_cmd("mp_timelimit %.2f", floatadd(flPassedTime, float(15)));
		client_print_f(0, ColorType:5, "\x04[%s]\x01 Voting finished. Current map will be\x04 extended for %d minutes", g_szPrefix, 15);
	}
	else
	{
		server_cmd("mp_timelimit %.2f", floatadd(1056964608, flPassedTime));
		set_cvar_string("amx_nextmap", g_szMap[g_iWinner]);
		client_print_f(0, ColorType:5, "\x04[%s]\x01 Voting finished. Next map will be\x04 %s\x01. Timeleft:\x04 30 seconds", g_szPrefix, g_szMap[g_iWinner]);
		g_bVoteFinished = true;
	}
	g_bVoteStarted = false;
	i = 0;
	while (i < 6)
	{
		g_iMapVotes[i] = 0;
		i++;
	}
	i = 0;
	while (i < 33)
	{
		g_bPlayerVoted[i] = 0;
		i++;
	}
	return 0;
}

public taskChangeLevel()
{
	server_cmd("changelevel \"%s\"", g_szMap[g_iWinner]);
	return 0;
}

public handleMapMenu(id, item)
{
	switch (item)
	{
		case 0:
		{
			send_cmd(id, "say /cp");
		}
		case 1:
		{
			send_cmd(id, "say /gc");
		}
		case 2, 3, 4, 5, 6:
		{
			if (!g_bPlayerVoted[id])
			{
				g_iMapVotes[item + -2] += 1;
				g_bPlayerVoted[id] = 1;
			}
		}
		case 8:
		{
			if (!g_bPlayerVoted[id])
			{
				g_iMapVotes[5] += 1;
				g_bPlayerVoted[id] = 1;
			}
		}
		case 9:
		{
			if (task_exists(id + 1200, VEC_NULL))
			{
				remove_task(id + 1200, VEC_NULL);
			}
			if (g_bKZMenuOpened[id])
			{
				send_cmd(id, "say /kzmenu");
			}
			else
			{
				show_my_menu(id, 0, 22912, 1, 19312);
			}
			return 1;
		}
		default:
		{
		}
	}
	g_iCounterVoting[id]++;
	taskShowMapMenu(id + 1200);
	return 1;
}

public cmdTeleport(id)
{
	if (!get_user_flags(id, VEC_NULL) & 512)
	{
		return 1;
	}
	arrayset(g_iMenuPlayers[id], VEC_NULL, 32);
	g_iMenuPosition[id] = 0;
	displayTeleMenu(id, 0);
	return 1;
}

public handleTeleMenu(id, iKey)
{
	switch (iKey)
	{
		case 8:
		{
			new var2 = g_iMenuPosition[id];
			var2++;
			displayTeleMenu(id, var2);
		}
		case 9:
		{
			new var1 = g_iMenuPosition[id];
			var1--;
			displayTeleMenu(id, var1);
		}
		default:
		{
			new iPlayer = g_iMenuPlayers[id][iKey + g_iMenuPosition[id] * 6];
			if (is_user_connected(iPlayer))
			{
				if (is_user_alive(iPlayer))
				{
					new szName[32];
					new Float:fOrigin[3] = 0.0;
					new Float:fAngles[3] = 0.0;
					new Float:fGravity = 0.0;
					get_player_position(iPlayer, fOrigin, fAngles, fGravity);
					set_player_origin(id, fOrigin, fAngles, fGravity, 0.0);
					get_user_name(iPlayer, szName, "AB");
					replace_all(szName, 31, 22920, 22928);
					client_print_f(id, ColorType:5, "\x04[%s]\x01 You have been teleported to\x04 %s", g_szPrefix, szName);
				}
				client_print_f(id, ColorType:5, "\x03[%s]\x01 This player is not alive", g_szPrefix);
			}
			displayTeleMenu(id, g_iMenuPosition[id]);
		}
	}
	return 0;
}

displayTeleMenu(id, iPosition)
{
	if (0 > iPosition)
	{
		arrayset(g_iMenuPlayers[id], VEC_NULL, 32);
		return 0;
	}
	new iNum;
	new iCount;
	new szMenu[512];
	new iPlayer;
	new szName[32];
	get_players(g_iMenuPlayers[id], iNum, "ch", 17176);
	new iStart = iPosition * 6;
	if (iStart >= iNum)
	{
		g_iMenuPosition[id] = 0;
		iPosition = 0;
		iStart = 0;
	}
	new iEnd = iStart + 6;
	new iKeys = 640;
	new iLen = formatex(szMenu, 511, "\rTeleport \yMenu\R%d /%d\n\n", iPosition + 1, iNum + 6 - 1 / 6);
	if (iEnd > iNum)
	{
		iEnd = iNum;
	}
	new i = iStart;
	while (i < iEnd)
	{
		iPlayer = g_iMenuPlayers[id][i];
		get_user_name(iPlayer, szName, "AB");
		replace_all(szName, 31, 23340, 23348);
		if (id == iPlayer)
		{
			iCount++;
			iLen = formatex(szMenu[iLen], 511 - iLen, "\d%d. %s\n", iCount, szName) + iLen;
		}
		else
		{
			iKeys = 1 << iCount | iKeys;
			iCount++;
			iLen = formatex(szMenu[iLen], 511 - iLen, "\r%d.\w %s\n", iCount, szName) + iLen;
		}
		i++;
	}
	if (iNum != iEnd)
	{
		new var1;
		if (iPosition)
		{
			var1 = 23544;
		}
		else
		{
			var1 = 23564;
		}
		formatex(szMenu[iLen], 511 - iLen, "\n\r9.\w More...\n\r0.\w %s", var1);
		iKeys |= 256;
	}
	else
	{
		new var2;
		if (iPosition)
		{
			var2 = 23628;
		}
		else
		{
			var2 = 23648;
		}
		formatex(szMenu[iLen], 511 - iLen, "\n\r0.\w %s", var2);
	}
	show_my_menu(id, iKeys, szMenu, -1, "TeleMenu");
	return 0;
}

public plugin_end()
{
	TrieDestroy(g_tAllMapsLow);
	ArrayDestroy(g_aAllMaps);
	return 0;
}

public client_disconnect(id)
{
	if (task_exists(id + 1200, VEC_NULL))
	{
		remove_task(id + 1200, VEC_NULL);
	}
	return 0;
}
