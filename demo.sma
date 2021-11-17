#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <fun>
new Array:g_DemoReplay[33];
new Array:g_DemoPlaybot[1];
new bool:timer_started[33];
new bool:g_fileRead;
new g_bot_enable;
new g_bot_id;
new g_bot_frame;
new Float:nExttHink = 0.009; // 1007908028 => 0.009
new g_bot_speed = 1;

enum _:DemoData {
	Float:flBotAngle[2],
	Float:flBotPos[3],
	Float:flBotVel[3],
	iButton
};

public plugin_init() {
    register_plugin("Demo Test", "1.0", "Azuki daisuki~");
    // 需要测试的pre还是post
    RegisterHam(57, "player", "Ham_PlayerPreThink"); //HAM_THINK
    register_clcmd("say test", "demoMenu");
    new i = 0;
    while(i < 33) {
        g_DemoReplay[i] = ArrayCreate(DemoData, 1);
        ++i;
    }
    g_DemoPlaybot[0] = ArrayCreate(DemoData, 1);
    // gc_DemoPlaybot[0] = ArrayCreate(9, 1);
    register_forward(FM_Think, "fwd_Think", 1);	//FM_Think,
	// register_forward(92, "fwd_Think_c", 1);
    new Ent = engfunc(21, engfunc(43, "info_target"));
	set_pev(Ent, 1, "bot_record");	// pev_classname
	set_pev(Ent, 33, 0.01);			// pev_nextthink 1008981770 -> 0.01 内存中保存的形式
}

public demoMenu(id) {
    if (!is_user_connected(id) || is_user_bot(id))
	{
		return 1;
	}
    new menu = menu_create("Demo Test Menu", "demoMenu_Handler");
    menu_additem(menu, "模拟 开始计时", "0");
    menu_additem(menu, "模拟 结束计时[非SR]", "1");
    menu_additem(menu, "模拟 结束计时[SR]", "2");
    menu_display( id, menu, 0 ); 
    return 0;
}

public demoMenu_Handler(id, menu, item) {
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    switch(item) {
        case 0: {
            startTimer(id);
            demoMenu(id);
        }
        case 1: {
            stopTimer(id);
            demoMenu(id);
        }
        case 2: {
            ClCmd_UpdateReplay(id);
            demoMenu(id);
        }
    }
}

public startTimer(id) {
    ArrayClear(g_DemoReplay[id]);
    timer_started[id] = true;
    // client_print(id, print_chat, "开始计时");
    return 0;
}

public stopTimer(id) {
    timer_started[id] = false;
    // client_print(id, print_chat, "停止计时");
    return 0;
}

//=================================
//              #BOT
//=================================
public ReadBestRunFile()
{
    // client_print(0, print_chat, "ReadBestRunFile");
	new ArrayData[DemoData];
	new szFile[] = "addons/amxmodx/configs/demoTest.txt"
	new len;
	// format(szFile, 127, "%s/records/Pro", DATADIR);
	// if (!dir_exists(szFile))
	// {
	// 	mkdir(szFile);
	// }
	// format(szFile, 127, "%s/%s.txt", szFile, MapName);
	if (file_exists(szFile))
	{
		g_fileRead = true;
        /*
            199.747222
            Azuki dasuki~
            STEAM_ID_LAN
            2021/06/13 - 15:50:16
            IANA保留地址  CZ88.NET
         */ 
		// read_file(szFile, 1, g_ReplayName, "", len);
		// read_file(szFile, 2, g_authid, "", len);
		// read_file(szFile, "", g_date, "", len);
		// read_file(szFile, 4, g_country, "", len);
		// fopen(const file[],const flags[])
		new hFile = fopen(szFile, "r");
		new szData[1024];
		new szBotAngle[2][40], szBotPos[3][60], szBotVel[3][60], szBotButtons[12];
		new line;
        // client_print(0, print_chat, "Prepare to Read Files");
		while (!feof(hFile))
		{
			fgets(hFile, szData, charsmax(szData));

            if(!szData[0] || szData[0] == '^n') continue;
			
				// if (!line)  //读取REC时间
				// {
				// 	g_ReplayBestRunTime = str_to_float(szData);
				// 	g_bestruntime = str_to_float(szData);
				// 	line++;
				// }
				// 字符串分割
				// strtok(const sSrc[], strL[], lenL, strR[], lenR,ch=' ',trimSpaces = 0)

				// strtok(szData, szBotAngle[0][szBotAngle], 39, szData, 1023, _, 1);
            strtok(szData, szBotAngle[0], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)
			strtok(szData, szBotAngle[1], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)

			strtok(szData, szBotPos[0], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
			strtok(szData, szBotPos[1], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
			strtok(szData, szBotPos[2], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)

			strtok(szData, szBotVel[0], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
			strtok(szData, szBotVel[1], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
			strtok(szData, szBotVel[2], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)

			strtok(szData, szBotButtons, charsmax(szBotButtons), szData, charsmax(szData), ' ', true)

            ArrayData[flBotAngle][0] = _:str_to_float(szBotAngle[0]);
			ArrayData[flBotAngle][1] = _:str_to_float(szBotAngle[1]);

			ArrayData[flBotPos][0] = _:str_to_float(szBotPos[0]);
			ArrayData[flBotPos][1] = _:str_to_float(szBotPos[1]);
			ArrayData[flBotPos][2] = _:str_to_float(szBotPos[2]);

			ArrayData[flBotVel][0] = _:str_to_float(szBotVel[0]);
			ArrayData[flBotVel][1] = _:str_to_float(szBotVel[1]);
			ArrayData[flBotVel][2] = _:str_to_float(szBotVel[2]);

			ArrayData[iButton] = _: str_to_num(szBotButtons);

			ArrayPushArray(g_DemoPlaybot[0], ArrayData);
			line++;
            // server_print("%f %f %f %f %f %f %f %f %d", ArrayData[0], ArrayData[1], ArrayData[2], ArrayData[3], ArrayData[4], ArrayData[5], ArrayData[6], ArrayData[7], ArrayData[8]);
		}
		fclose(hFile);
		// int 1077936128 => float 3.0
		// bot_restart
		bot_restart();
		return 1;
	}
	return 1;
}

public bot_restart()
{
	if (g_fileRead)
	{
		if (!g_bot_id)
			g_bot_id = Create_Bot();
		Start_Bot();
	}
	return 0;
}
public Create_Bot() {
    new txt[64];
	// StringTimer(g_ReplayBestRunTime, g_bBestTimer, 13, 1);
	// formatex(txt, "", "[PRO] %s %s", g_ReplayName, g_bBestTimer);
    
	new id = engfunc(EngFunc_CreateFakeClient, "BOT DEMO"); // EngFunc_CreateFakeClient = 53
	if (pev_valid(id))
	{
		set_user_info(id, "rate", "10000");
		set_user_info(id, "cl_updaterate", "60");
		set_user_info(id, "cl_cmdrate", "60");
		set_user_info(id, "cl_lw", "1");
		set_user_info(id, "cl_lc", "1");
		set_user_info(id, "cl_dlmax", "128");
		set_user_info(id, "cl_righthand", "1");
		set_user_info(id, "_vgui_menus", "0");
		set_user_info(id, "_ah", "0");
		set_user_info(id, "dm", "0");
		set_user_info(id, "tracker", "0");
		set_user_info(id, "friends", "0");
		set_user_info(id, "*bot", "1");

        set_pev(id, pev_flags, pev(id, pev_flags) | FL_FAKECLIENT);
		set_pev(id, pev_colormap, id);
        
		dllfunc(DLLFunc_ClientConnect, id, "BOT DEMO", "127.0.0.1");    // DLLFunc_ClientConnect = 8
		dllfunc(DLLFunc_ClientPutInServer, id);    // DLLFunc_ClientPutInServer = 11
		if (!is_user_alive(id))
		{
			dllfunc(DLLFunc_Spawn, id); // DLLFunc_Spawn = 1
		}
        set_pev(id, pev_takedamage, DAMAGE_NO); // pev_takedamage
        // native cs_set_user_team(index, any:team, any:model = CS_DONTCHANGE, bool:send_teaminfo = true)
		cs_set_user_team(id, 1);
		cs_set_user_model(id, "leet");
		give_item(id, "weapon_knife");
		give_item(id, "weapon_usp");
		g_bot_enable = 1;
		return id;
	}
	return 0;
}
public Start_Bot()
{
	g_bot_frame = 0;
	start_climb_bot(g_bot_id);
	return 0;
}

public start_climb_bot(id)
{
	set_pev(id, pev_gravity, 1.0);  // pev_gravity
	set_pev(id, pev_movetype, MOVETYPE_WALK);   // pev_movetype
	// reset_checkpoints(g_bot_id);
	// IsPaused[g_bot_id] = 0;
	timer_started[g_bot_id] = 1;
	// timer_time[g_bot_id] = get_gametime();
	return 0;
}

public fwd_Think(Ent)
{
	if (!pev_valid(Ent))
	{
		return 1;
	}
	static className[32];
	pev(Ent, 1, className, 31);
	if (equal(className, "bot_record"))
	{
		BotThink(g_bot_id);
		set_pev( Ent, pev_nextthink, get_gametime() + nExttHink );
	}
	return 1;
}

public BotThink( id )
{
	static Float:last_check, Float:game_time, nFrame;
	game_time = get_gametime();

	if( game_time - last_check > 1.0 )
	{
		if (nFrame < 100)
			nExttHink = nExttHink - 0.0001
		else if (nFrame > 100)
			nExttHink = nExttHink + 0.0001

		nFrame = 0;
		last_check = game_time;
	}

	if(g_bot_enable == 1 && g_bot_id)
	{
		g_bot_frame++;
		if ( g_bot_frame < ArraySize( g_DemoPlaybot[0] ) )
		{
			new ArrayData[DemoData], Float:ViewAngles[3];
			ArrayGetArray(g_DemoPlaybot[0], g_bot_frame, ArrayData);

			ViewAngles[0] = ArrayData[flBotAngle][0];
			ViewAngles[1] = ArrayData[flBotAngle][1];
			ViewAngles[2] = 0.0;

			if(ArrayData[iButton]&IN_ALT1) ArrayData[iButton]|=IN_JUMP;
			if(ArrayData[iButton]&IN_RUN)  ArrayData[iButton]|=IN_DUCK;

			if(ArrayData[iButton]&IN_RIGHT)
			{
				engclient_cmd(id, "weapon_usp");
				ArrayData[iButton]&=~IN_RIGHT;
			}
			if(ArrayData[iButton]&IN_LEFT)
			{
				engclient_cmd(id, "weapon_knife");
				ArrayData[iButton]&=~IN_LEFT;
			}
			//if ( ArrayData[iButton] & IN_USE )
			//{
			//	Ham_ButtonUse( id );
			//	ArrayData[iButton] &= ~IN_USE;
			//}
			engfunc(EngFunc_RunPlayerMove, id, ViewAngles, ArrayData[flBotVel][0], ArrayData[flBotVel][1], 0.0, ArrayData[iButton], 0, 10);
			set_pev(id, pev_v_angle, ViewAngles );
			ViewAngles[0] /= -3.0;
			set_pev(id, pev_velocity, ArrayData[flBotVel]);
			set_pev(id, pev_angles, ViewAngles);
			set_pev(id, pev_origin, ArrayData[flBotPos]);
			set_pev(id, pev_button, ArrayData[iButton] );
			set_pev(id, pev_health, 999.0);

			if( pev( id, pev_gaitsequence ) == 4 && ~pev( id, pev_flags ) & FL_ONGROUND )
				set_pev( id, pev_gaitsequence, 6 );

			if(nFrame == ArraySize( g_DemoPlaybot[0] ) - 1)
				Start_Bot();

		} else  {
			g_bot_frame = 0;
		}
	}
	nFrame++;
}

// ================================
//              #UPDATE
// ================================
public ClCmd_UpdateReplay(id)
{
    if(!timer_started[id]) return 0;
    stopTimer(id);
    // client_print(0, print_chat, "开始更新BOT");
    
	new configDir[64];
	get_configsdir(configDir, 64);
    
	// new szFile[128];
    new szFile[] = "addons/amxmodx/configs/demoTest.txt";
	new szData[128];
    
	// format(szFile, 127, "%s/demoTest.txt", configDir);
    client_print(id, print_chat, "%s", szFile);
    if(file_exists(szFile))
        delete_file(szFile);

	new hFile = fopen(szFile, "wt");    //没有则创建 有则覆盖

	new ArrayData[DemoData], ArrayData2[DemoData];
    // 遍历
    // client_print(id, print_chat, "开始写入文件");
    // 据数组句柄中获取一个元素
	for(new i; i < ArraySize(g_DemoReplay[id]); i++)
	{
		ArrayGetArray(g_DemoReplay[id], i, ArrayData);
		ArrayData2[flBotAngle][0] = _:ArrayData[flBotAngle][0]
		ArrayData2[flBotAngle][1] = _:ArrayData[flBotAngle][1]
		ArrayData2[flBotVel][0] = _:ArrayData[flBotVel][0]
		ArrayData2[flBotVel][1] = _:ArrayData[flBotVel][1]
		ArrayData2[flBotVel][2] = _:ArrayData[flBotVel][2]
		ArrayData2[flBotPos][0] = _:ArrayData[flBotPos][0]
		ArrayData2[flBotPos][1] = _:ArrayData[flBotPos][1]
		ArrayData2[flBotPos][2] = _:ArrayData[flBotPos][2]
		ArrayData2[iButton] = ArrayData[iButton]
		if(i >= ArraySize(g_DemoReplay[id]))
		{
			ArrayPushArray(g_DemoReplay[id], ArrayData2);
		}
		else
		{
			ArraySetArray(g_DemoReplay[id], i, ArrayData2);
		}
		formatex(szData, sizeof(szData) - 1, "%f %f %f %f %f %f %f %f %d^n", ArrayData2[flBotAngle][0], ArrayData2[flBotAngle][1],
        ArrayData2[flBotPos][0], ArrayData2[flBotPos][1], ArrayData2[flBotPos][2], ArrayData2[flBotVel][0], ArrayData2[flBotVel][1], ArrayData2[flBotVel][2], ArrayData2[iButton]);
		fputs(hFile, szData);
	}
	fclose(hFile);

	set_task(2.0, "bot_overwriting")
	fclose(hFile);
	ArrayClear(g_DemoReplay[id]);
    // client_print(id, print_chat, "文件写入完成");
	return 0;
}

public bot_overwriting()
{
	// 将Pro 和 Nub bot的数据读取都并保存在g_DemoPlaybot[0]中
    client_print(0, print_chat, "bot_overwriting");
	ArrayClear(g_DemoPlaybot[0]);
	ReadBestRunFile();
	// if (g_bot_id)
	// {
	// 	new txt[64];
	// 	StringTimer(g_ReplayBestRunTime, g_bBestTimer, 13, 1);
	// 	formatex(txt, "", "[PRO] %s %s", g_ReplayName, g_bBestTimer);
	// 	set_user_info(g_bot_id, "name", txt);
	// }
	return 0;
}

public Ham_PlayerPreThink(id)
{
	if (is_user_alive(id) && timer_started[id])
	{
        new ArrayData[DemoData];
        pev(id, pev_origin, ArrayData[flBotPos]);	//pev(id, pev_origin, angle) 2 3 4对应xyz
        new Float:angle[3] = 0.0;
        pev(id, pev_v_angle, angle); 
        pev(id, pev_velocity, ArrayData[flBotVel]);
        ArrayData[flBotAngle][0] = _:angle[0];
        ArrayData[flBotAngle][1] = _:angle[1];
        ArrayData[iButton] = get_user_button(id)
        ArrayPushArray(g_DemoReplay[id], ArrayData);	// g_DemoReplay[id]本身是一个二维数组 用于保存玩家时刻的状态
        /*
            ArrayData
                0~1 pev_v_angle
                2~4 pev_origin
                5~7 pev_velocity
                8	button
        */
    }
	return 0;
}