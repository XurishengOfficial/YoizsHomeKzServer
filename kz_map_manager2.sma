#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <messages> 
#include <colorchat>
#include <dhudmessage>
#include <float>

#define PLUGIN_NAME "KZ Map Manager"
#define KZ_ADMIN ADMIN_IMMUNITY
#define KZ_LEVEL ADMIN_KICK 
#define KZ_LEVEL_VIP ADMIN_LEVEL_C
#define CHECK_FREQ 5
#define MIN_AFK_TIME 30	

new g_szPrefix[32];
new bool:g_bPlayerVoted[33];
new bool:g_bKZMenuOpened[33];
new Float:g_flInitTime;
new bool:g_bVoteStarted;
new bool:g_bVoteFinished;
new bool:g_bNotEnoughMaps;
new g_iWinner;
new g_iCounterVoting[33];
new g_iCounterForTask;	// 投票前的倒计时 
new g_szMap[7][32];			// 备选的5张地图名 + curMap + nextMap
new g_szMenuItem[7][128];	// 保存备选5个地图菜单选项
new g_iMapVotes[7];	// 0~4 随机5张图的票数 5 延长 6 amx_nextmap
new g_szCurrentMap[34];
new g_iMapNum;
new g_iCurMapIdx;
new Array:g_aAllMaps;
new Array:g_aNominateMaps;
new g_iNominatedMaps[33];
// new g_iMaxNominateNum = 5;
new g_szMapCycle[128];
new g_pRockPercent;
new bool:g_bRockVoted[33];
new g_iRockNum;
new g_iRandomNum[5];	// 5个随机数
new g_iRtvMenuId = 0;

new g_iOldAngles[33][3]
new g_iAfkTime[33]
new g_bAFKing[33];

new const KZ_DIR[] = "addons/amxmodx/configs/kz"
new const KZ_MAPTYPE_FILE[] = "map_type.ini"
new Trie: g_tMapType;

stock is_user_vip(id) { return get_user_flags(id) & KZ_LEVEL_VIP; }

stock server_print_custom(const msg[], any:...) {
	server_print("=======================")
	server_print("%s", msg);
	server_print("=======================")
}

register_saycmd(command[], function[], flags=-1, const info[]="")
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

show_my_menu(index, keys, menu[], time, title[]) {
	set_pdata_int(index, 205, 0, 5, 5);
	show_menu(index, keys, menu, time, title);
	return 0;
}

// 生成0 ~ iUperBound - 1的5个随机数(同时排除了iCurMap)
stock get5randomNum(iUperBound, iCurMap)
{
	if(iUperBound <= 5) return;
	do {
		g_iRandomNum[0] = random_num(0, iUperBound - 1);
	} while (iCurMap == g_iRandomNum[0]);

	g_iRandomNum[1] = random_num(0, iUperBound - 1);
	while (g_iRandomNum[0] == g_iRandomNum[1] || iCurMap == g_iRandomNum[1])
	{
		g_iRandomNum[1] = random_num(0, iUperBound - 1);
	}

	g_iRandomNum[2] = random_num(0, iUperBound - 1);
	while (g_iRandomNum[0] == g_iRandomNum[2] || g_iRandomNum[1] == g_iRandomNum[2] || iCurMap == g_iRandomNum[2])
	{
		g_iRandomNum[2] = random_num(0, iUperBound - 1);
	}

	g_iRandomNum[3] = random_num(0, iUperBound - 1);
	while (g_iRandomNum[0] == g_iRandomNum[3] || g_iRandomNum[1] == g_iRandomNum[3] || g_iRandomNum[2] == g_iRandomNum[3] || iCurMap == g_iRandomNum[3])
	{
		g_iRandomNum[3] = random_num(0, iUperBound - 1);
	}
	g_iRandomNum[4] = random_num(0, iUperBound - 1);
	while (g_iRandomNum[0] == g_iRandomNum[4] || g_iRandomNum[1] == g_iRandomNum[4] || g_iRandomNum[2] == g_iRandomNum[4] || g_iRandomNum[3] == g_iRandomNum[4] || iCurMap == g_iRandomNum[4])
	{
		g_iRandomNum[4] = random_num(0, iUperBound - 1);
	}
	return;
}

Randomize5Maps(iUperBound, iCurMap) {
	if(g_bNotEnoughMaps) {
		log_amx("Not enough maps in maps.txt");
		server_print_custom("Not enough maps in maps.txt");
		return;
	}
	// 先检查是否有提名的地图 优先加入投票选项 随后再是随机生成的地图
	new nomiMapNum = ArraySize(g_aNominateMaps);
	new i;
	if(nomiMapNum <= 5)
	{
		while(i < nomiMapNum)
		{
			ArrayGetString(g_aNominateMaps, i, g_szMap[i], 31);
			i++;
		}
	}
	else
	{
		get5randomNum(nomiMapNum, iCurMap);
		while(i < nomiMapNum)
		{
			ArrayGetString(g_aNominateMaps, g_iRandomNum[i], g_szMap[i], 31);
			i++;
		}
	}
	get5randomNum(g_iMapNum, iCurMap);
	while (i < 5)
	{
		ArrayGetString(g_aAllMaps, g_iRandomNum[i], g_szMap[i], 31)
		i++;
	}
	new curMap[32], nextMap[32];
	get_mapname(curMap, charsmax(curMap));
	get_cvar_string("amx_nextmap", nextMap, charsmax(nextMap));
	formatex(g_szMap[5], 31, "%s", curMap);
	formatex(g_szMap[6], 31, "%s", nextMap);
	i = 0;

	// set map type
	i = 0;
	new data[256], map[32], mapType[64];
	new map_type_file[128];
	formatex(map_type_file, charsmax(map_type_file), "%s/%s", KZ_DIR, KZ_MAPTYPE_FILE);
	new f = fopen(map_type_file, "rt" );
	// server_print("*****************************************************");
	while( !feof( f ) )
	{
		fgets( f, data, 255 )
		// parse( data, map, charsmax(map), mapType, charsmax(mapType));
		strtok(data, map, charsmax(map), mapType, charsmax(mapType),' ')	
		trim(map);
		trim(mapType);	// 去除首尾空格
		TrieSetString(g_tMapType, map, mapType);
		// server_print("map: %s, mapInfo: %s", map, mapType);
	}
	// server_print("*****************************************************");
	fclose(f)

}

get_players_num()
{
	new iPlayers;
	new iMax = get_maxplayers();
	new id = 1;
	while (id < iMax)
	{
		if (is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id))
		{
			iPlayers++;
		}
		id++;
	}
	return iPlayers;
}

public readMapCycle()
{
	new szData[50];
	new iMaps;
	new iCurMap;
	ArrayClear(g_aAllMaps);
	new f = fopen(g_szMapCycle, "rt");
	while (!feof(f))
	{
		fgets(f, szData, charsmax(szData));
		trim(szData);
		if(is_map_valid(szData))
        {
            ArrayPushString(g_aAllMaps, szData);
            if (equali(szData, g_szCurrentMap, 0)) iCurMap = iMaps;
            iMaps++;
        }
	}
	g_iMapNum = iMaps;
	g_iCurMapIdx = iCurMap;
	server_print("===================================")
	server_print("%d maps loaded from maps.txt", iMaps)
	server_print("===================================")
	log_amx("%d maps loaded from maps.txt", iMaps);
	fclose(f);
	if (iMaps < 7)
	{
		server_print_custom("Not enough maps in maps.txt")
		log_amx("Not enough maps in maps.txt");
		g_bNotEnoughMaps = true;
	}
	// else    // 随机挑选5张不同的地图
	// {
	// 	Randomize5Maps(g_iMapNum, g_iCurMapIdx);
	// }
	return 0;
}

stock is_user_localhost(id) 
{
	new szIP[16];
	get_user_ip(id, szIP, sizeof(szIP) - 1, 1);
	if(equal(szIP, "loopback") || equal(szIP, "127.0.0.1")) 
	{
		return true;
	}
	return false;
}

public cmdUpdateMapList(id)
{
	if(get_user_flags(id) & KZ_LEVEL || is_user_localhost(id))
	{
		findMaps();
		readMapCycle();
	}
	else
	{
		client_print(id, print_console,"[KZ] 无法使用该命令.");
	}
	return;
}

// 寻找所有地图并写入txt
public findMaps()
{
	new szFileName[120];
	new namelen;
	new hDir = open_dir("maps", szFileName, charsmax(szFileName));
	if (!hDir)
	{
		log_amx("Cannot open maps directory");
		server_print_custom("Cannot open maps directory");
		return 0;
	}
	new f = fopen(g_szMapCycle, "wt");
	if(!f)
	{
		log_amx("Cannot create maps.txt");
		server_print_custom("Cannot create maps.txt");
		return 0;
	}
	do {
		namelen = strlen(szFileName);
		if (namelen > 4)
		{
			if (equal(szFileName[namelen - 4], ".bsp", 0))
			{
				szFileName[namelen - 4] = '^0'; //提前结束字符串 去除.bsp后缀 PAWN中0提前结束
				if (is_map_valid(szFileName))
				{
					format(szFileName, charsmax(szFileName), "%s^n", szFileName);
					fputs(f, szFileName);
				}
			}
		}
	} while (next_file(hDir, szFileName, charsmax(szFileName)));
	fclose(f);
	close_dir(hDir);
	return 0;
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, "3.2.1", "Kpoluk & Azuki daisuki~ ");
	register_saycmd("rtv", "cmdRTV");
	register_clcmd("say rtv", "cmdRTV");
	register_clcmd("say_team rtv", "cmdRTV");
	register_saycmd("rockthevote", "cmdRTV");
	register_clcmd("say", "Command_Say");				// nominate maps
	register_clcmd("say_team", "Command_Say");			// nominate maps
	get_cvar_string("kz_prefix", g_szPrefix, charsmax(g_szPrefix));
	register_clcmd("showMap", "cmdShowMap");
	register_clcmd("updateMapList", "cmdUpdateMapList", KZ_LEVEL);
	g_pRockPercent = register_cvar("kz_rtv_ratio", "0.6");
	register_cvar("mp_afktime", "60")	// Mark player AFKing longer than this time
	set_task(float(CHECK_FREQ),"checkPlayersAFK",_,_,_,"b")	//b 无限循环

	if (!g_szPrefix[0])
	{
		formatex(g_szPrefix, charsmax(g_szPrefix), "KZ");
	}

	g_flInitTime = get_gametime();
	get_mapname(g_szCurrentMap, charsmax(g_szCurrentMap));
	g_bNotEnoughMaps = false;
	g_aAllMaps = ArrayCreate(50, 32);
	g_aNominateMaps = ArrayCreate(50, 5);
	get_localinfo("amxx_datadir", g_szMapCycle, charsmax(g_szMapCycle));
	format(g_szMapCycle, charsmax(g_szMapCycle), "%s/maps.txt", g_szMapCycle);
	if (file_exists(g_szMapCycle))
	{
		readMapCycle(); // 读取所有地图 并选择5张加入投票备选
	}
	else // 不存在map.txt则自动创建
	{
		log_amx("File data/maps.txt NOT FOUND! Start scan the map folder and Create map.txt");
		findMaps();
		if (file_exists(g_szMapCycle))
		{
			readMapCycle();
			return;
		}
		log_amx("Create map.txt FAILED!");
		server_print_custom("Create map.txt FAILED!");
		g_bNotEnoughMaps = true;
	}
	g_bVoteStarted = false;
	g_bVoteFinished = false;
	g_iWinner = -1;
	g_tMapType = TrieCreate();
	set_task(1.0, "taskStartVote", 1100, _, _, "b", _);	// 每秒执行该函数
	g_iRtvMenuId = register_menuid("MapMenu", 0);
	register_menucmd(g_iRtvMenuId, 1023, "handleMapMenu");	//0~9十个键位 1023 = (1111111111)2
}

public checkPlayersAFK()
{
	// 仅监测活着玩家的AFK状态 观战状态玩家默认!AFKing
	for (new i = 1; i <= get_maxplayers(); i++) 
	{
		if (is_user_alive(i) && is_user_connected(i) && !is_user_bot(i) && !is_user_hltv(i)) 
		{
			new newangle[3]
			get_user_origin(i, newangle)
			
			if ( newangle[0] == g_iOldAngles[i][0] && newangle[1] == g_iOldAngles[i][1] && newangle[2] == g_iOldAngles[i][2] ) 
			{
				g_iAfkTime[i] += CHECK_FREQ
				check_afktime(i)
			} 
			else 
			{
				g_iOldAngles[i][0] = newangle[0];
				g_iOldAngles[i][1] = newangle[1];
				g_iOldAngles[i][2] = newangle[2];
				g_iAfkTime[i] = 0;
				g_bAFKing[i] = false;
			}
		}
	}
	return PLUGIN_HANDLED
}

check_afktime(id) 
{

	new maxafktime = get_cvar_num("mp_afktime")
	// 必须保证判定AFK时间>=MIN_AFK_TIME(30s)
	if (maxafktime < MIN_AFK_TIME) {
		log_amx("cvar mp_afktime %i is too low. Minimum value is %i.", maxafktime, MIN_AFK_TIME)
		maxafktime = MIN_AFK_TIME
		set_cvar_num("mp_afktime", MIN_AFK_TIME)
	}
	
	if(g_iAfkTime[id] > maxafktime) 
	{
		g_bAFKing[id] = true;
	}
}

public client_putinserver(id)
{
	if (!is_user_bot(id))
	{
		g_bPlayerVoted[id] = false;
		g_bKZMenuOpened[id] = false;
		g_iCounterVoting[id] = 0;
		g_bRockVoted[id] = false;
		g_bAFKing[id] = false;
	}
	return 0;
}
public client_disconnect(id)
{
	if(g_bRockVoted[id])
	{
		g_bRockVoted[id] = false;
		g_iRockNum--;
	}
	g_bAFKing[id] = false;
}

public taskStartVote()
{
	static iTimeleft;
	if (0 < get_cvar_num("mp_timelimit"))
	{
		iTimeleft = get_timeleft();
		if (iTimeleft < 60)
		{
			// server_print_custom("taskStartVote");
			if (!g_bVoteStarted && !g_bVoteFinished)
			{
				StartVote();
			}
			if (iTimeleft <= 1)
			{
				if (!task_exists(1300, 0))
				{
					set_task(1.0, "taskChangeLevel", 1300);
				}
			}
		}
	}
	return 0;
}

public cmdRTV(id)
{
    // 后续需要添加投票比例模块
	if (g_bVoteStarted)
	{
		ColorChat(id, GREEN, "^x03[%s] ^x01 Voting is in progress", g_szPrefix);
		return 1;
	}
	if (g_bNotEnoughMaps)
	{
		ColorChat(id, GREEN, "^x03[%s] ^x01 Voting failed. Not enough maps", g_szPrefix);
		return 1;
	}
	new afkPlayersNum = 0;
	for(new i = 1; i <= get_maxplayers(); ++i)
	{
		if(g_bAFKing[i]) ++afkPlayersNum;
	}
	new needRockNum = floatround( get_pcvar_float(g_pRockPercent) * (get_players_num() - afkPlayersNum) );
	if(!g_bRockVoted[id]) 
	{
		g_bRockVoted[id] = true;
		g_iRockNum++;
		if(g_iRockNum < needRockNum)
		{
			new playerName[64];
			get_user_name(id, playerName, charsmax(playerName));
			ColorChat(0, GREEN, "^x04[%s] ^3%s ^1has rocked to ^4Start the vote^1, still Needs: ^3%d ^1Votes, AFK players: ^3%d", g_szPrefix, playerName, needRockNum - g_iRockNum, afkPlayersNum);
			return 1;
		}
	}
	else
	{
		if(g_iRockNum < needRockNum)
		{
			ColorChat(id, GREEN, "^x04[%s] ^1You have been rocked the vote.", g_szPrefix);
			return 1;
		}
			
	}
	StartVote();
	ColorChat(0, GREEN, "^x04[%s] ^x01 Voting started", g_szPrefix);
	return 1;
}

public StartVote()
{
	// server_print_custom("StartVote()");
	if (g_bNotEnoughMaps)
	{
		ColorChat(0, GREEN, "^x03[%s] ^x01 Voting failed. Not enough maps read", g_szPrefix);
	}
	else
	{
		// 投票前的初始化工作
		g_bVoteStarted = true;
		g_iCounterForTask = 9;	// 投票倒计时为9 每秒-1
		Randomize5Maps(g_iMapNum, g_iCurMapIdx);	// 重新选取5张图	
		// 重置每个地图选项的票数
		new i = 0;
		while(i < 7) {
			g_iMapVotes[i] = 0;
			g_iWinner = 0;
			++i;
		}
		i = 0;
		while(i < 33) {
			g_bPlayerVoted[i] = false;
			++i;
		}
		set_task(1.0, "taskCount", 1150, _, _, "a", 9);	// 重复9次 1065353216 -> 1.0
	}
	return 0;
}

// 投票倒计时
public taskCount()
{
	// server_print_custom("taskCount()");
	g_iCounterForTask = g_iCounterForTask - 1;
	if (g_iCounterForTask)
	{
		// 显示倒计时HUD
		set_dhudmessage(200, 200, 200, -1.0, 0.18, 1, _, 1.0, 0.1, 0, _);
		// ShowSyncHudMsg(VEC_NULL, sHudObj, "Voting will begin in %d", g_iCounterForTask);
		show_dhudmessage(0, "Voting will begin in %d", g_iCounterForTask);
		// server_print("Voting will begin in %d", g_iCounterForTask);
		if (g_iCounterForTask == 1)
		{
			new players[32];
			new pnum;
			new iPlayer;
			get_players(players, pnum);	// 获取在线玩家索引列表并保存在数组players[] pnum为实际玩家数
			new i;
			while (i < pnum)
			{
				iPlayer = players[i];
				if (is_user_connected(iPlayer) && !is_user_bot(iPlayer))
				{
					g_bKZMenuOpened[iPlayer] = isJumpMenuOpened(iPlayer);
					g_iCounterVoting[iPlayer] = 15;
					// 为每个玩家设置了一个task taskid = iPlayer + 1200 并重复18次
					set_task(1.0, "taskShowMapMenu", iPlayer + 1200, _, _, "a", 18);	// 1.0
				}
				i++;
			}
			// 18s后检查投票结果
			set_task(18.0, "taskCheckVotes", 1250);
		}
	}
	return 0;
}

public bool:isJumpMenuOpened(id)
{
	if(callfunc_begin("isJumpMenuOpened", "prokreedz.amxx")) {
        callfunc_push_int(id);
		new bool: g_bJumpMenuOpend = callfunc_end();
        // server_print(g_bJumpMenuOpend? "=== Jump Menu Opened! ===" : "=== Jump Menu Not Opened! ===");
		return g_bJumpMenuOpend;
    }
	log_amx("%s try to call function isJumpMenuOpen() in prokreedz.amxx failed!", PLUGIN_NAME);
	server_print_custom("try to call function isJumpMenuOpen() in prokreedz.amxx failed!");
	client_print(id, print_chat, "%s try to call function isJumpMenuOpen() in prokreedz.amxx failed!", PLUGIN_NAME);
	return false;
}

public taskShowMapMenu(taskid)
{
	new id = taskid - 1200;
	if (is_user_bot(id))
	{
		return 0;
	}
	static szMenu[1024];
	static szMinutesLeft[15];
	g_iCounterVoting[id]--;
	// 显示15s的投票时间
	if (0 < g_iCounterVoting[id])
	{
		formatex(szMinutesLeft, charsmax(szMinutesLeft), "(\r%d\y)", g_iCounterVoting[id]);
	}
	else
	{
		// 15s后自动设置为投过
		g_bPlayerVoted[id] = true;
		formatex(szMinutesLeft, charsmax(szMinutesLeft), "(\rFinished\y)");
	}
	// 投票结束 总的task 18s 15s选图 18s完成后打开kz菜单
	if (g_iCounterVoting[id] == -3)
	{
		if (g_bKZMenuOpened[id]) 
			client_cmd(id, "/jumpMenu");
		else
			show_menu(id, 0, "^n", -1);	// 显示空菜单
	}
	// 投票ing
	else
	{
		// 已投
		if (g_bPlayerVoted[id])
		{
			new i;
			// 将7个地图选项变成灰色
			while (i < 7)
			{	
				// 灰色 dyd_bhop [2] 两人选择
				new mapType[64];
				if(TrieKeyExists(g_tMapType, g_szMap[i]))
				{
					TrieGetString(g_tMapType, g_szMap[i], mapType, charsmax(mapType));
				}
				else formatex(mapType, charsmax(mapType), "Unknown");
				// server_print("%#d %s: %s", i, g_szMap[i], mapType);
				formatex(g_szMenuItem[i], 127, "\d%s \y [%d] \d [%s]", g_szMap[i], g_iMapVotes[i], mapType);
				i++;
			}
			// 如果打开了读点存点 响应 MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2
			formatex(szMenu, charsmax(szMenu), "\yChoose Next Map %s:^n^n\r1. \wCheckPoint^n\r2. \wGoCheck^n^n\r3. %s^n\r4. %s^n\r5. %s^n\r6. %s^n\r7. %s^n^n\r8. \dExtend %s for %d minutes \y[%d]^n\r9. %s\d(Next Map)^n", szMinutesLeft, g_szMenuItem[0], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szMap[5], 15, g_iMapVotes[5], g_szMenuItem[6]);
			// 已投票普通玩家响应1.2. vip玩家响应1.2.0.
			if(is_user_vip(id)) {
				// Forced termination of voting
				format(szMenu, charsmax(szMenu), "%s^n\r0. \wForce \rStop the Vote", szMenu);
				show_my_menu(id, MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2, szMenu, -1, "MapMenu");	
			}
			else
			{
				format(szMenu, charsmax(szMenu), "%s^n\r0. \wDo not Want to \rVote", szMenu);
				show_my_menu(id, MENU_KEY_1 | MENU_KEY_2, szMenu, -1, "MapMenu");	
			}
		}
		else
		// 未投
		{
			new i;
			while (i < 6)
			{
				// 7个地图选项变成白色
				new mapType[64];
				if(TrieKeyExists(g_tMapType, g_szMap[i]))
				{
					TrieGetString(g_tMapType, g_szMap[i], mapType, charsmax(mapType));
				}
				else formatex(mapType, charsmax(mapType), "Unknown");
				// server_print("%s: %s", g_szMap[i], mapType);
				formatex(g_szMenuItem[i], 127, "\w%s \y [%d] \d [%s]", g_szMap[i], g_iMapVotes[i], mapType);
				i++;
			}
			// i = 6 nextmap
			formatex(g_szMenuItem[i], 127, "\y%s \y [%d]", g_szMap[i], g_iMapVotes[i]);
			formatex(szMenu, charsmax(szMenu), "\yChoose Next Map %s:^n^n\r1. \wCheckPoint^n\r2. \wGoCheck^n^n\r3. %s^n\r4. %s^n\r5. %s^n\r6. %s^n\r7. %s^n^n\r8. \dExtend \y%s \dfor \y%d \dminutes \y[%d]^n\r9. %s\d(Next Map)^n", szMinutesLeft, g_szMenuItem[0], g_szMenuItem[1], g_szMenuItem[2], g_szMenuItem[3], g_szMenuItem[4], g_szMap[5], 15, g_iMapVotes[5], g_szMenuItem[6]);
			if(is_user_vip(id))
				format(szMenu, charsmax(szMenu), "%s^n\r0. \wForce \rStop the Vote", szMenu);
			else
				format(szMenu, charsmax(szMenu), "%s^n\r0. \wDo not Want to \rVote", szMenu);
			// else show_my_menu(id, MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9, szMenu, -1, "MapMenu");
			show_my_menu(id, MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9, szMenu, -1, "MapMenu");	
		}
	}
	return 0;
}

// 检查票数 需要考虑服里没人的情况
public taskCheckVotes()
{
	new Float:flPassedTime = (get_gametime() - g_flInitTime) / 60;
	g_iWinner = 0;
	new i;
	new players[32];
	new pnum;
	get_players(players, pnum);
	// 服内有活人则统计winner 否则自动换下张图
	if (0 < pnum)
	{
		i = 1;
		while (i < 7)
		{
			if (g_iMapVotes[g_iWinner] < g_iMapVotes[i])
			{
				g_iWinner = i;
			}
			i++;
		}
		// g_iWinner指向第一个winner
		new AllWinners[7];
		new WinnersNum;
		i = 0;
		// 对存在多个相同最大值进行处理
		while (i < 7)
		{
			if (g_iMapVotes[g_iWinner] == g_iMapVotes[i])
			{
				AllWinners[WinnersNum] = i;
				WinnersNum++;
				// if (i == 5)
				// {
				// 	g_iWinner = 5;
				// }
			}
			i++;
		}
		// if (g_iWinner != 5)
		if (WinnersNum > 1) // 存在多个winner
		{
			if(g_iMapVotes[g_iWinner] == 0)	// 没人投票
				g_iWinner = 6;	// 默认下张图
			else 
				g_iWinner = AllWinners[random_num(1, WinnersNum) - 1];
		}
	}
	if (g_iWinner == 5)	// extend 15 min
	{
		server_cmd("mp_timelimit %.2f", 15 + flPassedTime);	// iTimeleft < 1 ==> taskChangeLevel 不会执行taskChangeLevel()
		ColorChat(0, GREEN, "^x04[%s]^x01 Voting finished. Current map will be^x04 extended for %d minutes", g_szPrefix, 15);
	}
	else
	{
		server_cmd("mp_timelimit %.2f", 0.15 + flPassedTime);	// 0.5min changelevel
		set_cvar_string("amx_nextmap", g_szMap[g_iWinner]);
		ColorChat(0, GREEN, "^x04[%s]^x01 Voting finished. Next map will be^x04 %s^x01. Timeleft:^x04 10 seconds", g_szPrefix, g_szMap[g_iWinner]);
		g_bVoteFinished = true;
	}
	// 投票完成后 参数进行初始化
	g_bVoteStarted = false;
	i = 0;
	while (i < 7)
	{
		g_iMapVotes[i] = 0;
		i++;
	}
	i = 0;
	while (i < 33)
	{
		g_bPlayerVoted[i] = false;
		i++;
	}
	i = 1;
	return 0;
}

public taskChangeLevel()
{
	new cmd[64];
	new nextMap[32];
	get_cvar_string("amx_nextmap", nextMap, charsmax(nextMap));
	// formatex(cmd, charsmax(cmd), "changelevel %s", nextMap);
	// server_print("amx_nextmap is %s", nextMap);
	// server_print("%s", cmd);
	server_cmd(cmd);
	return 0;
}

public handleMapMenu(id, item)
{
	if(is_user_bot(id) || !is_user_connected(id)) return
	new playerName[64];
	get_user_name(id, playerName, charsmax(playerName));
	switch (item)
	{
		case 0:
		{
			client_cmd(id, "say /cp");
		}
		case 1:
		{
			client_cmd(id, "say /gc");
		}
		case 2, 3, 4, 5, 6, 8:
		{
			if (!g_bPlayerVoted[id])
			{
				g_iMapVotes[item - 2] += 1;	// 选项选择计数
				g_bPlayerVoted[id] = true;
				ColorChat(0, GREEN, "^x04[%s] ^3%s ^1choose [^4%d^1] ^3%s", g_szPrefix, playerName, item + 1, g_szMap[item - 2]);
			}
		}
		case 7: // Extend
		{
			if (!g_bPlayerVoted[id])
			{
				g_iMapVotes[item - 2] += 1;	// 选项选择计数
				g_bPlayerVoted[id] = true;
				ColorChat(0, GREEN, "^x04[%s] ^3%s ^1choose ^4extending current map.", g_szPrefix, playerName);
			}
		}
		case 9: // 管理员取消
		{
			if(!is_user_vip(id))	// 非VIP or Admin Do not want to Vote
			{
				if(task_exists(id + 1200))
					remove_task(id + 1200);
				if(g_bKZMenuOpened[id])  client_cmd(id, "/jumpMenu");
				return;
			} 
			new players[32];
			new pnum;
			new iPlayer;
			get_players(players, pnum);	// 获取在线玩家索引列表并保存在数组players[] pnum为实际玩家数
			new i;
			// 移除每个玩家的菜单显示并显示空菜单
			while (i < pnum) {
				iPlayer = players[i];
				if (is_user_connected(iPlayer) && !is_user_bot(iPlayer))
				{
					if (task_exists(iPlayer + 1200))
						remove_task(iPlayer + 1200);
					show_menu(iPlayer, 0, "^n", -1); // 显示空菜单 防止取消后还可以选择(虽然选取也无效)
				}
				if (g_bKZMenuOpened[iPlayer]) client_cmd(iPlayer, "/jumpMenu");
				++i;
			}
			if(task_exists(1250)) remove_task(1250);	// 移除checkVotes
			ColorChat(0, GREEN, "^x04[%s] ^x01 Voting Canceled by ^3%s.", g_szPrefix, playerName);
			g_bVoteStarted = false;
			g_bVoteFinished = false;
			return;
		}
		default:
		{
		}
	}
	// g_iCounterVoting[id]++; ???
	// taskShowMapMenu(id + 1200);
	return;
}

bool:in_maps_array(map[])
{
	new szMap[33];
	new iMax = ArraySize(g_aAllMaps);
	new i;
	while (i < iMax)
	{
		ArrayGetString(g_aAllMaps, i, szMap, 32);
		if (equali(szMap, map))	// 忽略大小写的字符串匹配
		{
			return true;
		}
		i++;
	}
	return false;
}

bool:is_map_nominated(map[33])
{
	static Data[35];	// 必须声明为static!! 否则memory access
	new iMax = ArraySize(g_aNominateMaps);
	new i;
	while (i < iMax)
	{
		ArrayGetArray(g_aNominateMaps, i, Data);
		if (equali(Data, map, 32))
		{
			return true;
		}
		i++;
	}
	return false;
}

stock NominateMap(id, map[33])
{
	if (g_iNominatedMaps[id] == 5)
	{
		ColorChat(id, GREEN, "^x04[%s] ^x01 Maximum number of nominations has been reached", g_szPrefix);
		return;
	}
	if (is_map_nominated(map))
	{
		ColorChat(id, Color:3, "^x04[%s] ^x01 Map has already been nominated", g_szPrefix);
		return;
	}
	new szMap[33];
	new i;
	while (i < g_iMapNum)
	{
		ArrayGetString(g_aAllMaps, i, szMap, charsmax(szMap));
		if (equali(map, szMap))
		{
			new Data[35];
			// new var1 = map;
			// Data = var1;
			copy(Data, 33, map);
			Data[33] = id;	// 谁提名的
			Data[34] = i;	// 提名的mapIdx
			ArrayPushArray(g_aNominateMaps, Data);
			g_iNominatedMaps[id]++;
			new szName[33];
			get_user_name(id, szName, charsmax(szName));
			ColorChat(0, Color:5, "^x04[%s]^x03%s ^x01has nominated map ^x03%s", g_szPrefix, szName, map);
			return;
		}
		i++;
	}
	return;
}

stock bool:remove_nominated_map(id, map[])
{
	static Data2[35];	//必须static
	new iMax = ArraySize(g_aNominateMaps);
	new i;
	while (i < iMax)
	{
		ArrayGetArray(g_aNominateMaps, i, Data2);
		if (id == Data2[33] && equali(Data2, map, 32))	// 谁提名谁删除
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			g_iNominatedMaps[id]--;
			ArrayDeleteItem(g_aNominateMaps, i);
			return true;
		}
		i++;
	}
	return false;
}

public Command_Say(id)
{
	new szText[33];
	read_args(szText, charsmax(szText));	// 以字符串形式读取所有参数
	remove_quotes(szText);	// 删去引号
	trim(szText); // 删除前后空格
	strtolower(szText);		// 全转成小写
	if (in_maps_array(szText))
	{
		// 开始投票和投票完成后不能进行提名
		if (g_bVoteStarted)
		{
			ColorChat(id, GREEN, "^x04[%s]^x01 Voting Has been started.Cannot nominate Maps.", g_szPrefix);
			return 0;
		}
		if (g_bVoteFinished)
		{
			ColorChat(id, GREEN, "^x04[%s]^x01 Voting Has Finished. Cannot nominate Maps.", g_szPrefix);
			return 0;
		}
		if (g_iNominatedMaps[id] && is_map_nominated(szText)) // 自己提名自己删
		{
			if(remove_nominated_map(id, szText))
			{
				new playerName[32];
				get_user_name(id, playerName, charsmax(playerName));
				ColorChat(0, GREEN, "^x04[%s]^x03%s^x01 canceled nominated map ^x03%s", g_szPrefix, playerName, szText);
			}
		}
		else
		{
			NominateMap(id, szText);
		}
	}
	return 0;
}

public cmdShowMap()
{
	server_print("============      g_szMap[]     ==============");
	new i = 0;
	while(i < 7)
	{
		server_print("#%d %s", i + 1, g_szMap[i]);
		++i;
	}

	server_print("============  g_aNominateMaps[] ==============");
	i = 0;
	while(i < ArraySize(g_aNominateMaps))
	{
		new tmp[32];
		ArrayGetString(g_aNominateMaps, i, tmp, 31)
		server_print("#%d: %s", i + 1, tmp);
		++i;
	}
	server_print("==============================================")
}

public plugin_end()
{
	TrieDestroy(g_tMapType);
}