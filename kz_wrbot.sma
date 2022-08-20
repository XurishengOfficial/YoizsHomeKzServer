#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <amxxarch>
#include <curl>
#pragma tabsize 0
#pragma semicolon 1

/////////#pragma dynamic 32767 - Deprecated

#define PLUGIN "KZ_WRBOT"
#define VERSION "1.1"
#define AUTHOR "Destroman Edited"

//#define DEBUG

#define NUM_THREADS 256

#define PEV_PDATA_SAFE    2

#define OFFSET_TEAM            114
#define OFFSET_DEFUSE_PLANT    193
#define HAS_DEFUSE_KIT        (1<<16)
#define OFFSET_INTERNALMODEL    126

#define SetBhopBlocks(%1,%2)   %1[%2>>5] |=  1<<(%2 & 31)
#define GetBhopBlocks(%1,%2)   %1[%2>>5] &   1<<(%2 & 31)


new iArchiveName[256], RARArchive[128], g_szCurrentMap[32], Ext[4], delete_local_WR_files, country_flag;

new Array:fPlayerAngle, Array:fPlayerKeys, Array:fPlayerVelo, Array:fPlayerOrigin;
new g_timer;
new Float:timer_time[33], bool:timer_started[33], bool:IsPaused[33], Float:g_pausetime[33], bool:bot_finish_use[33];
new g_bot_start, g_bot_enable, g_bot_frame, wr_bot_id;
new SyncHudTimer;
new Trie:g_tButtons[2];
new g_Bot_Icon_ent, url_sprite[64], url_sprite_xz[64];
new WR_TIME[130], WR_NAME[130], WR_PREFIX[3];
new Float:nExttHink = 0.009;
new hud_message, cooldown_startbot;


new Array: update_file_data;
new Array: need_update_com;

new bool:bFoundDemo = false;
new bool:CheckAgain = false;
new bool:CheckExt = false;
new bool:DemosUpdateComplete = false;



new g_bBlocks[64];

new iDemo_header_size;
new iDemoName[256];
new iNavName[256], FLAG[10];
new iFile;
new iParsedFile;

new dl_dir[64] = "addons/amxmodx/data/kz_downloader";
new update_file[64] = "addons/amxmodx/data/kz_downloader/wr_filetime.ini";
new archive_dir[64] = "addons/amxmodx/data/kz_downloader/archives";
new temp_dir[64] = "addons/amxmodx/data/kz_downloader/temp";
new local_demo_folder[64] = "addons/amxmodx/data/kz_wrbot";


const COMMUNITIES = 4;

new const g_szDemoFiles[][][] = 
{
	{ "demofilesurl", "demosfilename", "rarfilelink", "community", "extension", "botname" },
	{ "https://xtreme-jumps.eu/demos.txt", "demos.txt", "http://files.xtreme-jumps.eu/demos", "Xtreme-Jumps", "rar" , "WR" },
	{ "https://cosy-climbing.net/demoz.txt", "demoz.txt", "https://cosy-climbing.net/files/demos", "Cosy-Climbing", "rar", "WR"  },
	{ "http://kz-rush.ru/xr_extended/world_records_update/cache/7e54c98f770108322b53ec33de682402.dat", "demokzr.txt", "https://kz-rush.ru/xr_public/demos/maps/cs16", "KZ-Rush", "zip", "WR"}, //https://kz-rush.ru/cs16_demos.txt
	{ "http://kz-rush.ru/xr_extended/world_records_update/cache/c4abde1a45fc954f25541f7cefd6cb73.dat", "democp.txt", "https://kz-rush.ru/xr_public/demos/maps/cs16", "KZ-Rush CP", "zip", "CP" } //https://kz-rush.ru/cs16_cp_demos.txt
};

enum _:RecordDemo
{
	URLS,
	DEMOS,
	LINK,
	NAME,
	EXT,
	BOT
};

enum _:Consts
{
	HEADER_SIZE         = 544,
	HEADER_SIGNATURE_CHECK_SIZE = 6,
	HEADER_SIGNATURE_SIZE       = 8,
	HEADER_MAPNAME_SIZE     = 260,
	HEADER_GAMEDIR_SIZE     = 260,

	MIN_DIR_ENTRY_COUNT     = 1,
	MAX_DIR_ENTRY_COUNT     = 1024,
	DIR_ENTRY_SIZE          = 92,
	DIR_ENTRY_DESCRIPTION_SIZE  = 64,

	MIN_FRAME_SIZE          = 12,
	FRAME_CONSOLE_COMMAND_SIZE  = 64,
	FRAME_CLIENT_DATA_SIZE      = 32,
	FRAME_EVENT_SIZE        = 84,
	FRAME_WEAPON_ANIM_SIZE      = 8,
	FRAME_SOUND_SIZE_1      = 8,
	FRAME_SOUND_SIZE_2      = 16,
	FRAME_DEMO_BUFFER_SIZE      = 4,
	FRAME_NETMSG_SIZE       = 468,
	FRAME_NETMSG_DEMOINFO_SIZE  = 436,
	FRAME_NETMSG_MOVEVARS_SIZE  = 32,
	FRAME_NETMSG_MIN_MESSAGE_LENGTH = 0,
	FRAME_NETMSG_MAX_MESSAGE_LENGTH = 65536
};

enum DemoHeader 
{
	netProtocol,
	demoProtocol,
	mapName[HEADER_MAPNAME_SIZE],
	gameDir[HEADER_GAMEDIR_SIZE],
	mapCRC,
	directoryOffset
};

enum DemoEntry 
{
	dirEntryCount,
	type,
	description[DIR_ENTRY_DESCRIPTION_SIZE],
	flags,
	CDTrack,
	trackTime,
	frameCount,
	offset,
	fileLength,
	frames,
	ubuttons /* INT 16 */
};

enum FrameHeader
{
	Type,
	Float:Timestamp,
	Number
}


enum NetMsgFrame 
{
	Float:timestamp,
	Float:view[3],
	viewmodel
}

new iDemoEntry[DemoEntry];
new iDemoHeader[DemoHeader];
new iDemoFrame[FrameHeader];

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


public plugin_init ()
{
	register_plugin( PLUGIN, VERSION, AUTHOR);
	
	get_mapname(g_szCurrentMap, charsmax(g_szCurrentMap));


	RegisterHam(Ham_TakeDamage, "player", "BotAfterDamage", 0);
	register_concmd("amx_wrbotmenu", "ClCmd_ReplayMenu");
	register_clcmd( "say /bot","ClCmd_ReplayMenu" );

	if(get_pcvar_num(country_flag))
	{
		register_forward(FM_AddToFullPack, "addToFullPack", 1);
	}

	new iTimer = create_entity("info_target");
	entity_set_float(iTimer, EV_FL_nextthink, get_gametime() + 0.08);
	entity_set_string(iTimer, EV_SZ_classname, "hud_update");
	register_think("hud_update", "timer_task");
	

	SyncHudTimer = CreateHudSyncObj();
	Check_Download_Demos( 0, 0, 0, ""); 
}


public plugin_cfg()
{
	if(!dir_exists(dl_dir))
		mkdir(dl_dir);
		
	if(!file_exists(update_file))
	{
		new file = fopen(update_file, "w");
		fclose(file);
	}
	
	if(file_size(update_file, 1) < COMMUNITIES)
	{
		delete_file(update_file);
		new file = fopen(update_file, "w");
		for(new data = 1; data <= COMMUNITIES; data++)
		{
			new line[32];
			format(line, charsmax(line), "%d 1337%d", data, data);
			write_file(update_file, line, -1);
		}
		fclose(file);
	}
	
	if(!dir_exists(archive_dir))
		mkdir(archive_dir);
	if(!dir_exists(temp_dir))
		mkdir(temp_dir);
	if(!dir_exists(local_demo_folder))
		mkdir(local_demo_folder);
	if(get_pcvar_num(delete_local_WR_files))
		rmdir_recursive(local_demo_folder);
		
	update_file_data = ArrayCreate(32);
	need_update_com = ArrayCreate(COMMUNITIES);
	
	SetTouch();
}

public plugin_precache()
{

	country_flag = register_cvar("country_flag","1");
	delete_local_WR_files = register_cvar("delete_local_WR_files","0");
	hud_message = register_cvar("hud_message","1");
	cooldown_startbot = register_cvar("cooldown_startbot","5");
	
	new kreedz_cfg[128], ConfigDir[64];
	get_configsdir(ConfigDir, 64);
	formatex(kreedz_cfg,128,"%s/wrbot.cfg", ConfigDir);

	if(file_exists(kreedz_cfg))
	{
		server_cmd("exec %s",kreedz_cfg);
		server_exec();
	}
	else
	{
		server_print("[WR_BOT] Config file is not connected, please check.");
	}
	
	
	
	new szIP[16];
	get_user_ip( !is_dedicated_server(), szIP, charsmax(szIP));
	
	// 本地服务器屏蔽flag
	// if(containi(szIP,"loopback") > -1 || containi(szIP,"127.0.0.1") > -1 || strlen(szIP) == 0)
	// 	set_pcvar_num(country_flag,0);
	

	if(get_pcvar_num(country_flag))
	{
		new bool:g_Demos = false;
		
		new data;
		for(data = 1; data <= COMMUNITIES; data++)
		{
			new demoslist[128];
			format (demoslist, charsmax(demoslist), "%s/%s", dl_dir, g_szDemoFiles[data][DEMOS] );
			
			new iDemosList  = fopen( demoslist, "rb" );
			new ExplodedString[7][128];
			new Line[128], Extens[32], Mapa[32];
			new Float:BestTime = 10000000.0;
			new MapName[64];
			get_mapname( MapName, 63 );
			
			while ( !feof( iDemosList ) )
			{
				fgets(iDemosList, Line, charsmax(Line));
				ExplodeString(ExplodedString, 6, 127, Line, ' ');
				new parsedmap[128];
				
				parsedmap = ExplodedString[0];
				trim(parsedmap);
		
				if (containi(parsedmap, MapName ) == 0 )
				{			
					new Float:Time = str_to_float( ExplodedString[1]);
					split(parsedmap, Mapa, 31, Extens, 31, "[");
					trim(Mapa);
					trim(Extens);
					
					if(equali(Mapa, MapName))
					{
						if(Time < BestTime &&  Time > 0.0)
						{						
							if(data == COMMUNITIES) // CP COMMUNITY FILE
							{
								formatex(FLAG, charsmax(FLAG), "%s", ExplodedString[5]);
							}
							else 
							{
								formatex(FLAG, charsmax(FLAG), "%s", ExplodedString[3]);
							}
							trim(FLAG);
							g_Demos = true;
						}
					}
				}
			}
			fclose(iDemosList);
			
			if(g_Demos)
				break;
		}
		if(g_Demos)
			parsing_country();
	}
	
	
	new i;
	for(i = 0; i < sizeof(g_tButtons); i++)
	{
		g_tButtons[i] = TrieCreate();
	}
	new szStartTargets[][] = 
	{
		"counter_start", "clockstartbutton", "firsttimerelay", "but_start",
		"counter_start_button", "multi_start", "timer_startbutton", "start_timer_emi", "gogogo"
	};

	for(i = 0; i < sizeof szStartTargets ; i++)
	{
		TrieSetCell(g_tButtons[0], szStartTargets[i], i);
	}
	new szFinishTargets[][] = 
	{
		"counter_off", "clockstopbutton", "clockstop", "but_stop",
		"counter_stop_button", "multi_stop", "stop_counter", "m_counter_end_emi"
	};

	for (i = 0; i < sizeof szFinishTargets; i++)
	{
		TrieSetCell(g_tButtons[1], szFinishTargets[i], i);
	}
	new Ent = engfunc( EngFunc_CreateNamedEntity , engfunc( EngFunc_AllocString,"info_target" ) );
	set_pev(Ent, pev_classname, "BotThink");
	set_pev(Ent, pev_nextthink, get_gametime() + 0.01 );
	register_forward( FM_Think, "fwd_Think", 1 );
	fPlayerAngle  = ArrayCreate( 2 );
	fPlayerOrigin = ArrayCreate( 3 );
	fPlayerVelo   = ArrayCreate( 3 );
	fPlayerKeys   = ArrayCreate( 1 );
}

public client_disconnect( id )
{
	if(id == wr_bot_id)
	{
		timer_time[id] = 0.0;
		IsPaused[wr_bot_id] = false;
		timer_started[wr_bot_id] = false;
		g_bot_enable = 0;
		g_bot_frame = 0;
		wr_bot_id = 0;
		destroy_bot_icon();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


public BotAfterDamage ( victim, weapon, attacker, Float:damage, damagebits )
{
	if (is_user_bot(victim) || is_user_bot(attacker))
	{
		if ( damagebits & DMG_FALL )
		{
			set_pev(wr_bot_id,pev_health,9999.0);
		}
	}
	else
	{
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}


public Ham_ButtonUse( id )
{
	new Float:origin[3];
	pev( id, pev_origin, origin );
	new ent = -1;
	while ( (ent = find_ent_in_sphere( ent, origin, 100.0 ) ) != 0 )
	{
		new classname[32];
		pev( ent, pev_classname, classname, charsmax( classname ) );

		new Float:eorigin[3];
		get_brush_entity_origin( ent, eorigin );
		static Float:Distance[2];
		new szTarget[32];
		pev( ent, pev_target, szTarget, 31 );

		if ( TrieKeyExists( g_tButtons[0], szTarget ) )
		{
			if( g_bot_start < 0 )
				g_bot_start = 0;

			if ( vector_distance( origin, eorigin ) >= Distance[0] )
			{
				timer_time[id] = get_gametime();
				IsPaused[id] = false;
				timer_started[id] = true;
				bot_finish_use[id] = false;
			}
			Distance[0] = vector_distance( origin, eorigin );
		}
		if ( TrieKeyExists( g_tButtons[1], szTarget ) )
		{
			if ( vector_distance( origin, eorigin ) >= Distance[1] )
			{
				if (!bot_finish_use[id])
				{
					if(timer_started[id])
					{
						if(get_pcvar_num(cooldown_startbot) == 0)
							Start_Bot();
						else
							StartCountDown();
					}
					timer_started[id] = false;
					bot_finish_use[id] = true;
				}
			}
			Distance[1] = vector_distance( origin, eorigin );
		}
	}
}

public BhopTouch(iBlock, id)
{
	if(GetBhopBlocks(g_bBlocks, iBlock))
	{
		if(is_user_bot(id))
		{
			return HAM_SUPERCEDE;
		}
	}
	return PLUGIN_CONTINUE;
}

SetTouch()
{
	RegisterHam(Ham_Touch, "func_door", "BhopTouch");
	new iDoor = FM_NULLENT;
	while((iDoor = find_ent_by_class( iDoor, "func_door")))
	{
		SetBhopBlocks(g_bBlocks, iDoor);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////TIMER//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public timer_task(iTimer)
{
	new Dead[32], deadPlayers;
	get_players(Dead, deadPlayers, "bh");
	for(new i=0;i<deadPlayers;i++)
	{
		new specmode = pev(Dead[i], pev_iuser1);
		if(specmode == 2 || specmode == 4)
		{
			new target = pev(Dead[i], pev_iuser2);
			if(is_user_alive(target))
			{
				if (timer_started[target] && target == wr_bot_id)
				{
					new Float:kreedztime = get_gametime() - (IsPaused[target] ? get_gametime() - g_pausetime[target] : timer_time[target]);
					new imin = floatround( kreedztime / 60.0, floatround_floor );
					new isec = floatround( kreedztime - imin * 60, floatround_floor );
					new mili = floatround( ( kreedztime - ( imin * 60 + isec ) ) * 100, floatround_floor );
					client_print(Dead[i], print_center , "[ %02i:%02i.%02i ]",imin, isec, mili, IsPaused[target] ? "| *Paused*" : "");

				}
				else if (!timer_started[target] && target == wr_bot_id)
				{
					client_print(Dead[i], print_center, "");
				}
			}
		}
	}
	entity_set_float(iTimer, EV_FL_nextthink, get_gametime() + 0.07);
}

public Pause()
{
	if(!IsPaused[wr_bot_id])
	{
		g_pausetime[wr_bot_id] = get_gametime() - timer_time[wr_bot_id];
		timer_time[wr_bot_id] = 0.0;
		IsPaused[wr_bot_id] = true;
		g_bot_enable = 2;
	}
	else
	{
		if(timer_started[wr_bot_id])
		{
			timer_time[wr_bot_id] = get_gametime() - g_pausetime[wr_bot_id];
		}
		IsPaused[wr_bot_id] = false;
		g_bot_enable = 1;
	}
}

public fwd_Think( iEnt )
{
	if ( !pev_valid( iEnt ) )
	{
		return(FMRES_IGNORED);
	}
	static className[32];
	pev( iEnt, pev_classname, className, 31 );

	if ( equal( className, "DemThink" ) )
	{
		static bool:Finished;
		for(new i = 0; i < NUM_THREADS; i++)
		{
			if(ReadFrames(iFile))
			{
				Finished = true;
				break;
			}
		}

		if(Finished)
		{
			fclose(iParsedFile);
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
			fclose( iFile );
			LoadParsedInfo( iNavName );
		}
		else
		{
			set_pev( iEnt, pev_nextthink, get_gametime() + 0.001 );
		}
	}
	if ( equal( className, "NavThink" ) )
	{
		static bool:Finished;
		for(new i = 0; i < NUM_THREADS; i++)
		{
			if(!ReadParsed(iEnt))
			{
				Finished = true;
				break;
			}
		}

		if(Finished)
		{
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
			fclose( iFile );
			set_task( 2.0, "StartCountDown");
		}
	}


	if(equal(className, "kz_time_think"))
	{
		timer_task(1);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.08);
	}

	if ( equal( className, "BotThink" ) )
	{
		BotThink( wr_bot_id );
		set_pev( iEnt, pev_nextthink, get_gametime() + nExttHink );
	}

	return(FMRES_IGNORED);
}

public BotThink( id )
{
	static Float:ViewOrigin[3], Float:ViewAngle[3], Float:ViewVelocity[3], ViewKeys;
	static Float:last_check, Float:game_time, nFrame;
	game_time = get_gametime();

	if( game_time - last_check > 1.0 )
	{
		if (nFrame < 100)
		{
			nExttHink = nExttHink - 0.0001;
		}
		else if (nFrame > 100)
		{
			nExttHink = nExttHink + 0.0001;
		}
		nFrame = 0;
		last_check = game_time;
	}

	if(g_bot_enable == 1 && wr_bot_id)
	{
		g_bot_frame++;
		if ( g_bot_frame < ArraySize( fPlayerAngle ) )
		{
			ArrayGetArray( fPlayerOrigin, g_bot_frame, ViewOrigin );
			ArrayGetArray( fPlayerAngle, g_bot_frame, ViewAngle );
			ArrayGetArray( fPlayerVelo, g_bot_frame, ViewVelocity);
			ViewKeys = ArrayGetCell( fPlayerKeys, g_bot_frame );

			if(ViewKeys&IN_ALT1) ViewKeys|=IN_JUMP;
			if(ViewKeys&IN_RUN)  ViewKeys|=IN_DUCK;

			if(ViewKeys&IN_RIGHT)
			{
				engclient_cmd(id, "weapon_usp");
				ViewKeys&=~IN_RIGHT;
			}
			if(ViewKeys&IN_LEFT)
			{
				engclient_cmd(id, "weapon_knife");
				ViewKeys&=~IN_LEFT;
			}
			if ( ViewKeys & IN_USE )
			{
				Ham_ButtonUse( id );
				ViewKeys &= ~IN_USE;
			}

			engfunc(EngFunc_RunPlayerMove, id, ViewAngle, ViewVelocity[0], ViewVelocity[1], 0.0, ViewKeys, 0, 10);
			set_pev( id, pev_v_angle, ViewAngle );
			ViewAngle[0] /= -3.0;
			set_pev(id, pev_velocity, ViewVelocity);
			set_pev(id, pev_angles, ViewAngle);
			set_pev(id, pev_origin, ViewOrigin);
			set_pev(id, pev_button, ViewKeys );

			if( pev( id, pev_gaitsequence ) == 4 && ~pev( id, pev_flags ) & FL_ONGROUND )
			{
				set_pev( id, pev_gaitsequence, 6 );
			}
			if(nFrame == ArraySize( fPlayerAngle ) - 1)
			{

				StartCountDown();
			}

		} else  {
			g_bot_frame = 0;
		}
	}
	nFrame++;
}


////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////MENU//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public ClCmd_ReplayMenu(id)
{
	if(!access(id,ADMIN_MENU))
	{
		return PLUGIN_HANDLED;
	}
	new title[512];
	formatex(title, 500, "\wSetting Bot Replay Menu^nName: \y%s\w^nRecord: \y%s", WR_NAME, WR_TIME);
	new menu = menu_create(title, "ReplayMenu_Handler");
	menu_additem(menu, "Start/Reset", "1");

	if (g_bot_enable == 1)
	{
	   menu_additem(menu, "Pause^n", "2");
	}
	else
	{
		menu_additem(menu, "Play^n", "2");
	}

	menu_additem(menu, "Kick bot", "3");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ReplayMenu_Handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		return PLUGIN_HANDLED;
	}
	switch(item)
	{
		case 0:
		{
			if(!wr_bot_id)
			{
				StartCountDown();
			}
			else
			{
				Start_Bot();
			}
		}
		case 1: 
				Pause();
				
		case 2:
		{
			if(wr_bot_id)
			{
				server_cmd("kick #%d", get_user_userid(wr_bot_id));
			}
		}
	}
	ClCmd_ReplayMenu(id);
	return PLUGIN_HANDLED;
}

Create_Bot()
{
	if (file_exists(iDemoName))	delete_file(iDemoName);
	new txt[64];
	formatex(txt, charsmax(txt), "[%s] %s %s", WR_PREFIX, WR_NAME, WR_TIME);
	new id = engfunc(EngFunc_CreateFakeClient, txt);
	if(pev_valid(id))
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

		dllfunc(DLLFunc_ClientConnect, id, "WR BOT", "127.0.0.1");
		dllfunc(DLLFunc_ClientPutInServer, id);

		cs_set_user_team(id, CS_TEAM_CT);
		cs_set_user_model(id, "sas");

		ham_give_weapon(id,"weapon_knife");
		// ham_give_weapon(id,"weapon_usp");
		// cs_set_user_bpammo(id, CSW_USP, 250);

		if(get_pcvar_num(country_flag)) 
		{
			create_bot_icon(id);
		}
		if(!is_user_alive(id)) 
		{
			dllfunc(DLLFunc_Spawn, id);
		}
		return id;
	}
	return 0;
}

public StartCountDown()
{
	if(!wr_bot_id)
	{
		wr_bot_id = Create_Bot();
	}
	g_timer = get_pcvar_num(cooldown_startbot);
	set_task(1.0, "Show");
}

public Show()
{
	g_timer--;
	set_hudmessage(255, 255, 255, 0.05, 0.2, 0, 6.0, 1.0);

	if(g_timer && g_timer >= 0)
	{
		if(get_pcvar_num(hud_message)) ShowSyncHudMsg(0, SyncHudTimer, "WR bot starts run in: %i sec", g_timer);
		set_task(1.0, "Show");
	}
	else {
		if(get_pcvar_num(hud_message)) ShowSyncHudMsg(0, SyncHudTimer, "Bot has started");
		g_bot_enable = 1;
		Start_Bot();
	}
}

Start_Bot()
{
	g_bot_frame = g_bot_start;
	timer_started[wr_bot_id] = false;
	set_hudmessage(255, 255, 255, 0.05, 0.2, 0, 6.0, 1.0);
	if(get_pcvar_num(hud_message)) ShowSyncHudMsg(0, SyncHudTimer, "Bot has started");
}



////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////BOT ICON//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public create_bot_icon(id)
{
	g_Bot_Icon_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));

	if(file_exists(url_sprite))
	{
		engfunc(EngFunc_SetModel, g_Bot_Icon_ent, url_sprite);
	}
	else if(file_exists(url_sprite_xz))
	{
		engfunc(EngFunc_SetModel, g_Bot_Icon_ent, url_sprite_xz);
	}
	else
	{
		return;
	}
	set_pev(g_Bot_Icon_ent, pev_solid, SOLID_NOT);
	set_pev(g_Bot_Icon_ent, pev_movetype, MOVETYPE_FLYMISSILE);
	set_pev(g_Bot_Icon_ent, pev_iuser2, id);
	set_pev(g_Bot_Icon_ent, pev_scale, 0.25);
}

destroy_bot_icon()
{
	if(g_Bot_Icon_ent)
	{
		engfunc(EngFunc_RemoveEntity, g_Bot_Icon_ent);
	}
	g_Bot_Icon_ent = 0;
}

public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
	if(wr_bot_id == host)	// 机器人本身不做任何操作
	{
		return FMRES_IGNORED;
	}
	if(wr_bot_id)
	{
		if(pev_valid(ent) && (pev(ent, pev_iuser1) == pev(ent, pev_owner)))
		{
			new user = pev(ent, pev_iuser2);	// 通过绑定到bot上的spr获取到bot的id?
			new specmode = pev(host, pev_iuser1);

			if(is_user_alive(user))
			{
				new Float: playerOrigin[3];
				pev(user, pev_origin, playerOrigin);	
				playerOrigin[2] += 42;
				engfunc(EngFunc_SetOrigin, ent, playerOrigin); //设置spr在头顶

				if(specmode == 4)
				{
					set_es(es, ES_Effects, EF_NODRAW);
				}
			}
		}
	}
	return FMRES_IGNORED;
}



////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////CURL FOR CHECK AND DOWNLOAD DEMOS AND ARCHIVES////////////////////
////////////////////////////////////////FileType////////////////////////////////////////////
/////////////////////////////// 0 - Demos, 1 - Archive /////////////////////////////////////

public Check_Download_Demos(Community, Download, FileType, FileName[])
{
	new CURL:curl = curl_easy_init();	
	new data[128];
	data[2] = Community;
	format(data[3], strlen(FileName), "%s", FileName);
	
	if (Community < COMMUNITIES+1 && !FileType)
	{		
		curl_easy_setopt(curl, CURLOPT_URL, g_szDemoFiles[Community][URLS]);
		if(Download)
		{
			new demosfile[64];
			format (demosfile, charsmax(demosfile), "%s/%s", dl_dir, g_szDemoFiles[Community][DEMOS] );
			data[0] = fopen(demosfile, "wb");
			data[1] = FileType;
		}
	}
	
	if(FileType)
	{
		new Link[256];
		
		if(!CheckExt)
			format (Ext, charsmax(Ext), "%s", g_szDemoFiles[Community][EXT] );
		else 
			format (Ext, charsmax(Ext), "rar");
			
		format(Link, charsmax(Link), "%s/%s.%s", g_szDemoFiles[Community][LINK], FileName, Ext);
			
		#if defined DEBUG
			server_print("[LINK] : %s", Link);
		#endif
		
		curl_easy_setopt(curl, CURLOPT_URL, Link);
		
		new archivefile[256];
		format (archivefile, charsmax(archivefile), "%s/%s.%s", archive_dir, FileName, Ext );
		data[0] = fopen(archivefile, "wb");
		data[1] = FileType;
	}
	
	if((Community > 1 && FileType) || !FileType) // XJ == 1
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1);
		curl_easy_setopt(curl, CURLOPT_CAINFO, "cstrike/addons/amxmodx/data/cert/cacert.pem");
	}


	curl_easy_setopt(curl, CURLOPT_BUFFERSIZE, 512);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, data[0]);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, "write");

	if(!Download)
	{
		curl_easy_setopt(curl, CURLOPT_FILETIME, 1);
	}
	curl_easy_perform(curl, "complete", data, sizeof(data));
}

public complete(CURL:curl, CURLcode:code, data[])
{	
	fclose(data[0]);
	new Community = data[2];
	if(Community < COMMUNITIES+1 && !DemosUpdateComplete) 
	{
		new filetime;
		new Line[32], ExplodedString[3][33];
		curl_easy_getinfo(curl, CURLINFO_FILETIME, filetime);
	
		new recordsfile  = fopen( update_file, "rb" );
		while (!feof(recordsfile))
		{
			fgets (recordsfile, Line, charsmax(Line));
			ExplodeString(ExplodedString, 2, 32, Line, ' ');
			
			if(strlen(Line) > 0) {

			
				new com = str_to_num(ExplodedString[0]);
				new dat = str_to_num(ExplodedString[1]);
				new newLine[32];
				new needupdLine[2];
				
				if(com == Community && dat)
				{
					if(filetime != dat && filetime > 0) 
					{
						dat = filetime;
						format(needupdLine, charsmax(needupdLine), "%d", Community);
						ArrayPushString(need_update_com, needupdLine);
					}
					format(newLine, charsmax(newLine), "%d %d", Community, dat);
					ArrayPushString(update_file_data, newLine);				
				}
			}
		}
		fclose(recordsfile);
		Community++;

		if(Community < COMMUNITIES+1)
		{
			Check_Download_Demos(Community, 0, 0, "");
		}
		else 
		{
			DemosUpdateComplete = true;
			UpdateNeeded();
		}
	}
	
	if(data[1])
	{
		new iResponceCode;
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, iResponceCode);
		
		new filename[128];
		format( filename, charsmax( filename ), "%s/%s.%s",archive_dir, data[3], Ext);
		
		if (iResponceCode > 399 && !CheckAgain && !CheckExt)
		{
			delete_file(filename);
			
			bFoundDemo = false;
			CheckAgain = true;
			
			#if defined DEBUG
				server_print("[ERROR] : iResponceCode: %d", iResponceCode);
			#endif
			
			for(new i = 1; i <= COMMUNITIES; i++)
			{
				if(!bFoundDemo)
					OnDemosComplete(i);
			}
			
		}
		else if (iResponceCode > 399 && CheckAgain && !CheckExt)
		{
			delete_file(filename);
			bFoundDemo = false;
			CheckAgain = false;
			CheckExt = true;
			
			#if defined DEBUG
				server_print("[ERROR] : iResponceCode: %d", iResponceCode);
			#endif
			
			for(new i = COMMUNITIES-1; i <= COMMUNITIES; i++) //KZRU SUPPORT ZIP FILES CHECKEXT
			{
				if(!bFoundDemo)
					OnDemosComplete(i);
			}
		}
		else if (iResponceCode > 399 && !CheckAgain && CheckExt)
		{
			delete_file(filename);
			bFoundDemo = false;
			CheckAgain = true;
			CheckExt = true;
			
			#if defined DEBUG
				server_print("[ERROR] : iResponceCode: %d", iResponceCode);
			#endif
			
			for(new i = COMMUNITIES-1; i <= COMMUNITIES; i++) //KZRU SUPPORT ZIP FILES CHECKEXT
			{
				if(!bFoundDemo)
					OnDemosComplete(i);
			}
		}
		else if (iResponceCode > 399 && CheckAgain && CheckExt)
		{
			delete_file(filename);
			server_print("*No World Record on this map!");
		}
		else
		{
			CheckAgain = false;
			CheckExt = false;
			DownloadArchiveComplete(filename);
			
			#if defined DEBUG
				server_print("[COMPLETE] : iResponceCode: %d - file: %s", iResponceCode, filename);
			#endif
		}
	}
	
	curl_easy_cleanup(curl);
}


public UpdateNeeded()
{
	new com[64];
	new i_size = ArraySize(need_update_com);
	if(i_size)
	{
		delete_file(update_file);
		new file = fopen(update_file, "w");
		for(new i = 0; i  < COMMUNITIES; i++)
		{
			ArrayGetString(update_file_data, i, com, charsmax(com));
			write_file(update_file, com);
		}
		
		for(new i = 0; i < i_size; i++)
		{
			ArrayGetString(need_update_com, i, com, charsmax(com));
			new comm = str_to_num(com);
			Check_Download_Demos(comm, 1, 0, "");
		}
		fclose(file);
	}
	set_task(5.0, "UpdateComplete");
}

public UpdateComplete()
{
	if(DemosUpdateComplete)
	{
		for(new i = 1; i  <= COMMUNITIES; i++)
		{		
			if(!bFoundDemo)
				OnDemosComplete(i);
		}
		if(!bFoundDemo)
			server_print("*No WR on this map!");
	}
}



public write(data[], size, nmemb, file)
{
   new actual_size = size * nmemb;
   fwrite_blocks(file, data, actual_size, BLOCK_CHAR);
   return actual_size;
}

public OnDemosComplete(Community)
{
	new demoslist[128];
	format( demoslist, charsmax(demoslist), "%s/%s", dl_dir, g_szDemoFiles[Community][DEMOS] );
	
	#if defined DEBUG
		server_print( "Parsing %s Demo List", g_szDemoFiles[Community][NAME]);
	#endif
	new iDemosList  = fopen( demoslist, "rb" );
	new ExplodedString[7][128];
	new Line[128], PlayerName[128], DLMap[64], Extens[32], Mapa[32];
	new Float:BestTime = 10000000.0;

	while ( !feof( iDemosList ) )
	{
		fgets(iDemosList, Line, charsmax(Line));
		ExplodeString(ExplodedString, 6, 127, Line, ' ');
		new parsedmap[128];
		

		parsedmap = ExplodedString[0];
		trim(parsedmap);

		if (containi(parsedmap, g_szCurrentMap ) == 0 )
		{			
			new Float:Time = str_to_float( ExplodedString[1]);
			split(parsedmap, Mapa, 31, Extens, 31, "[");
			trim(Mapa);
			trim(Extens);
			
			if(equali(Mapa, g_szCurrentMap))
			{
				if(Time < BestTime &&  Time > 0.0)
				{	

					BestTime = Time;
					if(containi(parsedmap, "[" ) > -1)
					{
						format( DLMap, charsmax( Mapa ), "%s[%s", Mapa, Extens );
						
						if(CheckAgain)
							strtolower(DLMap);
					}
					else {
						format( DLMap, charsmax( DLMap ), "%s", Mapa );
						
						if(CheckAgain)
							strtolower(DLMap);
					}
					
					#if defined DEBUG
						server_print("Parsedmap |%s|", DLMap);
					#endif
					
					if(Community == COMMUNITIES) //KZRU CP DEMOS FILE
					{
						PlayerName = ExplodedString[4];
					}
					else 
					{
						PlayerName = ExplodedString[2];
					}
					trim(PlayerName);					
					bFoundDemo = true;
				}
			}
		}
	}
	if(bFoundDemo)
	{
		new sWRTime[24];
		fnConvertTime( BestTime, sWRTime, charsmax( sWRTime ) );

		format( iArchiveName, charsmax( iArchiveName ), "%s_%s_%s", DLMap, PlayerName, sWRTime );
		
		format( iNavName, sizeof(iNavName), "%s/%s.nav", local_demo_folder, iArchiveName );
		
		StringTimer(BestTime, WR_TIME, sizeof(WR_TIME) - 1);
		WR_NAME = PlayerName;
		format( WR_PREFIX, sizeof(WR_PREFIX), g_szDemoFiles[Community][BOT]);
		
		if(file_exists(iNavName)) 
		{
			LoadParsedInfo( iNavName );
		}
		else
		{
			Check_Download_Demos(Community, 1, 1, iArchiveName);
		}
		#if defined DEBUG
			server_print("Archivename %s", iArchiveName);
		#endif
		
	}
	
	fclose(iDemosList);
}

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////AMXXARCH FOR UNARCHIVE ZIP AND RAR FILES//////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public DownloadArchiveComplete(Archive[])
{
	format( RARArchive, charsmax( RARArchive ), "%s", Archive);
	AA_Unarchive(RARArchive, temp_dir, "@OnComplete", 0);
}


@OnComplete(id, iError)
{
	if(iError != AA_NO_ERROR)
	{
		#if defined DEBUG
			server_print("Failed to unpack. Error code: %d", iError);
		#endif
	}
	else
	{
		#if defined DEBUG
			server_print("Done. Download & Unpack WR file!");
		#endif

		delete_file(RARArchive);
		
		format( iDemoName, sizeof(iDemoName), "%s/%s.dem", temp_dir, iArchiveName );
		if ( !file_exists( iNavName ) )
		{
			iFile = fopen( iDemoName, "rb" );
			if ( iFile )
			{
				iParsedFile = fopen( iNavName, "w" );
				ReadHeaderX();
	
			}
		}else  {
			LoadParsedInfo( iNavName );
		}
	}
}



////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////LOAD//READ//PARSE///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


public LoadParsedInfo(szNavName[])
{
	iFile = fopen( szNavName, "rb" );
	new Ent = engfunc( EngFunc_CreateNamedEntity , engfunc( EngFunc_AllocString,"info_target" ) );
	set_pev(Ent, pev_classname, "NavThink");
	set_pev(Ent, pev_nextthink, get_gametime() + 0.01 );
}

public ReadHeaderX()
{
	if (IsValidDemoFile( iFile ))
	{
		ReadHeader( iFile );
		new Ent = engfunc( EngFunc_CreateNamedEntity , engfunc( EngFunc_AllocString,"info_target" ) );
		set_pev(Ent, pev_classname, "DemThink");
		set_pev(Ent, pev_nextthink, get_gametime() + 0.01 );

	}else {
		server_print( "NOTVALID" );
	}
}

public bool:IsValidDemoFile( file )
{
	fseek( file, 0, SEEK_END );
	iDemo_header_size = ftell( file );
	if ( iDemo_header_size < HEADER_SIZE )
	{
		return(false);
	}
	fseek( file, 0, SEEK_SET );
	new signature[HEADER_SIGNATURE_CHECK_SIZE];
	fread_blocks( file, signature, sizeof(signature), BLOCK_CHAR );

	if ( !contain( "HLDEMO", signature ) )
	{
		return(false);
	}

	return(true);
}


public ReadHeader( file )
{
	fseek( file, HEADER_SIGNATURE_SIZE, SEEK_SET );
	fread( file, iDemoHeader[demoProtocol], BLOCK_INT );
	fread( file, iDemoHeader[netProtocol], BLOCK_INT );

	fread_blocks( file, iDemoHeader[mapName], HEADER_MAPNAME_SIZE, BLOCK_CHAR );
	fread_blocks( file, iDemoHeader[gameDir], HEADER_GAMEDIR_SIZE, BLOCK_CHAR );

	fread( file, iDemoHeader[mapCRC], BLOCK_INT );
	fread( file, iDemoHeader[directoryOffset], BLOCK_INT );

	fseek( file, iDemoHeader[directoryOffset], SEEK_SET );

	fread( file, iDemoEntry[dirEntryCount], BLOCK_INT );
	for ( new i = 0; i < iDemoEntry[dirEntryCount]; i++ )
	{
		fread( file, iDemoEntry[type], BLOCK_INT );
		fread_blocks( file, iDemoEntry[description], DIR_ENTRY_DESCRIPTION_SIZE, BLOCK_CHAR );
		fread( file, iDemoEntry[flags], BLOCK_INT );
		fread( file, iDemoEntry[CDTrack], BLOCK_INT );
		fread( file, iDemoEntry[trackTime], BLOCK_INT );
		fread( file, iDemoEntry[frameCount], BLOCK_INT );
		fread( file, iDemoEntry[offset], BLOCK_INT );
		fread( file, iDemoEntry[fileLength], BLOCK_INT );
	}

	fseek( file, iDemoEntry[offset], SEEK_SET );

/* server_print( "%d %d %s %s %d %d %d", iDemoHeader[demoProtocol], iDemoHeader[netProtocol], iDemoHeader[mapName], iDemoHeader[gameDir], iDemoHeader[mapCRC], iDemoHeader[directoryOffset], iDemoEntry[dirEntryCount] ); */
}

public ReadParsed( iEnt )
{
	if (iFile)
	{
		new szLineData[512];
		static sExplodedLine[11][150];
		if ( !feof( iFile ) )
		{
			fseek(iFile, 0, SEEK_CUR);
			new iSeek = ftell(iFile);
			fseek(iFile, 0, SEEK_END);
			fseek(iFile, iSeek, SEEK_SET);

			fgets( iFile, szLineData, charsmax( szLineData ) );

			ExplodeString( sExplodedLine, 10, 50, szLineData, '|' );
			if (equal( sExplodedLine[1], "ASD" ))
			{
				new Keys        = str_to_num( sExplodedLine[2] );
				new Float:Angles[3];
				Angles[0]   = str_to_float( sExplodedLine[3] );
				Angles[1]   = str_to_float( sExplodedLine[4] );
				Angles[2]   = 0.0;
				new Float:Origin[3];
				Origin[0]   = str_to_float( sExplodedLine[5] );
				Origin[1]   = str_to_float( sExplodedLine[6] );
				Origin[2]   = str_to_float( sExplodedLine[7] );
				new Float:velocity[3];
				velocity[0] = str_to_float( sExplodedLine[8] );
				velocity[1] = str_to_float( sExplodedLine[9] );
				velocity[2] = 0.0;

				ArrayPushArray( fPlayerAngle, Angles );
				ArrayPushArray( fPlayerOrigin, Origin );
				ArrayPushArray( fPlayerVelo, velocity );
				ArrayPushCell( fPlayerKeys, Keys );
			}
			set_pev( iEnt, pev_nextthink, get_gametime()+0.0001 );
			return true;
		}
		else
		{
			return false;
		}
	}

	return false;
	// sum | iDemoEntry[ubuttons] | ViewAngles[0] | ViewAngles[1] | Origin[0] | Origin[1] | Origin[2] | velocity[0] | velocity[1] | velocity[2]
	// velocity[2] = 0.0
}
public ReadFrames( file )
{
	fseek(file, 0, SEEK_CUR);
	new iSeek = ftell(file);
	fseek(file, 0, SEEK_END);
	fseek(iFile, iSeek, SEEK_SET);
	static sum;

	if (!feof(file))
	{
		new FrameType = ReadFrameHeader(file);
		new breakme;
		switch (FrameType)
		{
			case 0:
			{
			}
			case 1:
			{
				new Float:Origin[3], Float:ViewAngles[3], Float:velocity[3], iAsd[1024];
				fseek( file, 4, SEEK_CUR );                             // read_object(demo, f.DemoInfo.timestamp);
				for ( new i = 0; i < 3; ++i )
				{
					fseek( file, 4, SEEK_CUR );                     // read_object(demo, f.DemoInfo.RefParams.vieworg);
				}
				for ( new i = 0; i < 3; ++i )
				{
					fread( file, _:ViewAngles[i], BLOCK_INT );  // read_object(demo, f.DemoInfo.RefParams.viewangles);
				}
				fseek( file, 64, SEEK_CUR );                            // пропуск до следующего участка.

				for ( new i = 0; i < 3; ++i )
				{
					fread( file, _:velocity[i], BLOCK_INT );        // read_object(demo, f.DemoInfo.RefParams.simvel);
				}
				for ( new i = 0; i < 3; ++i )
				{
					fread( file, _:Origin[i], BLOCK_INT );          // read_object(demo, f.DemoInfo.RefParams.simorg);
				}
				fseek( file, 124, SEEK_CUR );                       // пропуск до следующего участка.

				for ( new i = 0; i < 3; ++i )
				{
					fseek( file, 4, SEEK_CUR );                     // read_object(demo, f.DemoInfo.UserCmd.viewangles);
				}
				fseek( file, 4, SEEK_CUR );                     /* read_object(demo, f.ForwardMove); */
				fseek( file, 4, SEEK_CUR );                     /* read_object(demo, f.SideMove); */
				fseek( file, 4, SEEK_CUR );                     /* read_object(demo, f.UpmoveMove); */
				fseek( file, 2, SEEK_CUR );                     /* read_object(demo, f.lightlevel && f.align_2; */
				fread( file, iDemoEntry[ubuttons], BLOCK_SHORT );

				format( iAsd, charsmax( iAsd ), "%d|ASD|%d|%.4f|%.4f|%.3f|%.3f|%f|%.3f|%.3f|%.3f^n",sum, iDemoEntry[ubuttons], ViewAngles[0], ViewAngles[1], Origin[0],Origin[1],Origin[2], velocity[0], velocity[1], velocity[2] );
				fputs( iParsedFile, iAsd );
				fseek( file, 196, SEEK_CUR ); // static
				new length;
				fread( file, length, BLOCK_INT ); // static
				fseek( file, length, SEEK_CUR ); // static
			}
			case 2:
			{
			}
			case 3:
			{
				new ConsoleCmd[FRAME_CONSOLE_COMMAND_SIZE];
				fread_blocks( file, ConsoleCmd, FRAME_CONSOLE_COMMAND_SIZE, BLOCK_CHAR );
			}
			case 4:
			{
				sum++;
				for ( new i = 0; i < 3; ++i )                               // Бот чуть выше земли и pre будет показывать, как UP
				{
					fseek( file, 4, SEEK_CUR );                             // write_object(o, f->origin[i]);
				}
				for ( new i = 0; i < 3; ++i )                               // write_object(o, f->viewangles[i]);
				{
					fseek( file, 4, SEEK_CUR );
				}
				fseek( file, 4, SEEK_CUR );                             // write_object(o, f->weaponBits);
				fseek( file, 4, SEEK_CUR );                             // write_object(o, f->fov);
			}
			case 5:
			{
				breakme = 2;
			}
			case 6:
			{
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.flags); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.index); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.delay); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.flags); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.entityIndex); */
				for ( new i = 0; i < 3; ++i )
				{
					fseek( file, 4, SEEK_CUR );     /* read_object(demo, f.EventArgs.origin[i]); */
				}
				for ( new i = 0; i < 3; ++i )
				{
					fseek( file, 4, SEEK_CUR );     /* read_object(demo, f.EventArgs.angles[i]); */
				}
				for ( new i = 0; i < 3; ++i )
				{
					fseek( file, 4, SEEK_CUR );     /* read_object(demo, f.EventArgs.velocity[i]); */
				}
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.ducking); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.fparam1); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.fparam2); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.iparam1); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.iparam2); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.bparam1); */
				fseek( file, 4, SEEK_CUR );             /* read_object(demo, f.EventArgs.bparam2); */
			}
			case 7:
			{
				fseek( file, 8, SEEK_CUR );
			}
			case 8:
			{
				fseek( file, 4, SEEK_CUR );
				new length;
				fread( file, length, BLOCK_INT );
				new msg[128];
				fread_blocks( file, msg, length, BLOCK_CHAR );
				fseek( file, 16, SEEK_CUR );
			}
			case 9:
			{
				new length = 0;
				fread( file, length, BLOCK_INT );
				new buffer[4];
				fread_blocks( file, buffer, length, BLOCK_BYTE );
			}
			default:
			{
				breakme = 2;
			}
		}
		if(breakme == 2)
		{
			return true;
		}
	}
	return false;
}


public ReadFrameHeader( file )
{
	fread( file, iDemoFrame[Type], BLOCK_BYTE );
	fread( file, _:iDemoFrame[Timestamp], BLOCK_INT );
	fread( file, iDemoFrame[Number], BLOCK_INT );
	return(iDemoFrame[Type]);
}



public parsing_country()
{
	if(strlen(FLAG) == 0 || equali(FLAG, "n-")) 
	{
		FLAG = "xz";
	}
	
	formatex(url_sprite, charsmax(url_sprite), "sprites/wrbot/%s.spr", FLAG);
	formatex(url_sprite_xz, charsmax(url_sprite_xz), "sprites/wrbot/xz.spr");
	if(file_exists(url_sprite))
	{
		precache_model(url_sprite);
	}
	else if (file_exists(url_sprite_xz))
	{
		precache_model(url_sprite_xz);
	}
	else
	{
		return;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////STOCKS////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

stock fnConvertTime( Float:time, convert_time[], len )
{
	new sTemp[24];
	new Float:fSeconds = time, iMinutes;
	iMinutes        = floatround( fSeconds / 60.0, floatround_floor );
	fSeconds        -= iMinutes * 60.0;
	new intpart     = floatround( fSeconds, floatround_floor );
	new Float:decpart   = (fSeconds - intpart) * 100.0;
	intpart         = floatround( decpart );
	formatex( sTemp, charsmax( sTemp ), "%02i%02.0f.%02d", iMinutes, fSeconds, intpart );
	formatex( convert_time, len, sTemp );
	return(PLUGIN_HANDLED);
}


stock ExplodeString( p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter )
{
	new nIdx = 0, l = strlen( p_szInput );
	new nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter ) );
	while ((nLen < l) && (++nIdx < p_nMax))
	{
		nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter ) );
	}
	return(nIdx);
}

stock rmdir_recursive(local_demo_folder[])
{
	new szFileName[64], sz_dest[512];
	new hDir = open_dir(local_demo_folder, szFileName, charsmax(szFileName));

	if(!hDir)
	{
		new file = fopen(local_demo_folder, "rb");
		if(file)
		{
			fclose(file);
		}
		return;
	}
	do
	{
		if(szFileName[0] != '.' && szFileName[1] != '.')
		{
			format(sz_dest, 511, "%s/%s", local_demo_folder, szFileName);
			
			if(!dir_exists(sz_dest)) {
				delete_file(sz_dest);
				//new result = delete_file(sz_dest);	
				//server_print("File delete? - %s - %s", sz_dest, result ? "Yes" : "No");		
			}
			else {
				rmdir(sz_dest);	
				rmdir_recursive(sz_dest);
			}
		}
	}	
	while ( next_file( hDir, szFileName, charsmax( szFileName )));
  	close_dir(hDir);
}


stock ham_give_weapon(id,weapon[])
{
	new wEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,weapon));
	set_pev(wEnt,pev_spawnflags,SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn,wEnt);

	if(!equal(weapon,"weapon_",7))
	{
		return 0;
	}
	if(!pev_valid(wEnt))
	{
		return 0;
	}
	if(!ExecuteHamB(Ham_AddPlayerItem,id,wEnt))
	{
		if(pev_valid(wEnt)) set_pev(wEnt,pev_flags,pev(wEnt,pev_flags) | FL_KILLME);
		return 0;
	}
	ExecuteHamB(Ham_Item_AttachToPlayer,wEnt,id);
	return 1;
}

stock StringTimer(const Float:flRealTime, szOutPut[], const iSizeOutPut)
{
	static Float:flTime, iMinutes, iSeconds, iMiliSeconds, Float:iMili;
	new string[12];
	flTime = flRealTime;
	if(flTime < 0.0) 
	{
		flTime = 0.0;
	}
	iMinutes = floatround(flTime / 60, floatround_floor);
	iSeconds = floatround(flTime - (iMinutes * 60), floatround_floor);
	iMili = floatfract(flRealTime);
	formatex(string, 11, "%.02f", iMili >= 0 ? iMili + 0.005 : iMili - 0.005);
	iMiliSeconds = floatround(str_to_float(string) * 100, floatround_floor);
	formatex(szOutPut, iSizeOutPut, "%02d:%02d.%02d", iMinutes, iSeconds, iMiliSeconds);
}
