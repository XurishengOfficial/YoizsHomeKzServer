#include <amxmodx>
#include <amxxarch>
#include <hamsandwich>
#include <fakemeta_util>
#include <curl>
#include <fun>

#pragma tabsize 0
#pragma semicolon 1

#define PLUGIN "KZ:Bots"
#define VERSION "2.0.5b"
#define AUTHOR "Garey - Destroman Edited"

#define MAX_SOURCES 16

//#define DEBUG

enum source_data
{
	source_id,
	source_type,
	source_name[32],
	source_time[32],
	source_path[128],
	source_startframe,
Float:source_starttime,
Float:source_stoptime,
Array:source_array
}

new bot_sources[MAX_SOURCES][source_data];

new iArchiveName[256], RARArchive[128], g_szCurrentMap[32], Ext[4];

new Array: update_file_data;
new Array: need_update_com;

new bool:bFoundDemo = false;
new bool:CheckAgain = false;
new bool:CheckExt = false;
new bool:DemosUpdateComplete = false;


new dl_dir[64] = "addons/amxmodx/data/kz_downloader";
new update_file[64] = "addons/amxmodx/data/kz_downloader/wr_filetime.ini";
new archive_dir[64] = "addons/amxmodx/data/kz_downloader/archives";
new temp_dir[64] = "addons/amxmodx/data/kz_downloader/temp";
new local_demo_folder[64] = "addons/amxmodx/data/kz_bot";
new kz_lj[64] = "addons/amxmodx/configs/kz_longjumps2.txt";
new bool:kz_lj2 = false;

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
////////////////////////////////////////////////////////////////////////////////////////////

enum FWrite
{
	FW_NONE = 0,
	FW_DELETESOURCE = (1<<0),
	FW_CANOVERRIDE = (1<<1)
}

enum 
{
	SOURCE_REC = 1,
	SOURCE_WR = 2
}

new map_records_dir[128];

new const rec_recorder[] = "ent_recorder";
new const rec_demoparser[] = "dem_think";
new Array:record_info[33];

new global_bot;


new sources_num = 0;

enum _:MODES
{
	MODE_CYCLE,
	MODE_USE,
	MODE_WAIT
}

new bot_modes[MODES][] =
{
	"Cycle Run",
	"Restart on USE",
	"Restart on USE + Wait on distance"
};

new bool:plr_botnamed[33];
new plr_sound[33];
new plr_mode[33];
new plr_source[33];
new plr_frame_it[33];
new plr_jump[33] = {300, ... };
new plr_saverun_time[32][32];
new bool:plr_delayed_save[33];
new Float:plr_delayed_timer[33];
new bool:plr_playback[33];
new bool:bot_inrestart[33];
new Float:bot_restarttime[33];
new bool:is_recording[33];

enum frame_data
{
Float:frame_origin[3],
Float:frame_angles[3],
Float:frame_velocity[3],
frame_buttons,
Float:frame_time
}

new ghost_data[33][frame_data];

new maxplayers;

new cvar_mode;
new cvar_speed;
new cvar_keys;
new cvar_deletedemos;


new Trie:start_buttons;
new Trie:stop_buttons;

new step_sounds[5][4];

new PlayerName[128];
new sWRTime[24];
//new CheckVisibilityForward;


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////


public plugin_init ()
{
	register_plugin( PLUGIN, VERSION, AUTHOR);
	
	register_clcmd( "kzbot_settings","kzbot_settings" );
	register_clcmd( "amx_botmenu","kzbot_settings" );
	register_clcmd( "say /bot","kzbot_settings" );
	register_clcmd( "say /replay","kzbot_settings" );
	register_clcmd( "say /demo","kzbot_settings" );
	
	cvar_mode = register_cvar("kzbot_on", "1");
	cvar_keys = register_cvar("kzbot_keys", "1");
	cvar_speed = register_cvar("kzbot_speed", "1");
	cvar_deletedemos = register_cvar("kzbot_removedemos", "0");

	start_buttons = TrieCreate();	
	stop_buttons = TrieCreate();	
	new const start_names[][] = { "counter_start", "clockstartbutton", "firsttimerelay", "gogogo", "startcounter", "multi_start" };
	new const stop_names[][] = { "counter_off", "clockstopbutton", "clockstop", "stop_counter", "stopcounter", "multi_stop" };
	for(new i = 0; i < sizeof(start_names); i++)
	{
		TrieSetCell(start_buttons, start_names[i], 1);
	}
	for(new i = 0; i < sizeof(stop_names); i++)
	{
		TrieSetCell(stop_buttons, stop_names[i], 1);
	}
	
	
	RegisterHam( Ham_Use, "func_button", "fwdUse", 1);
	register_forward(FM_AddToFullPack,"fw_addtofullpack_pre", 1);
	register_forward(FM_AddToFullPack,"fw_addtofullpack", 1);
	register_forward(FM_UpdateClientData, "fw_updateclientdata", 1);
	register_forward(FM_CheckVisibility,"checkVisibility");
	register_forward(FM_ClientUserInfoChanged, "fw_clientinfochanged", 1);

	new ent = fm_create_entity( "info_target" );
	if ( ent )
	{
		set_pev( ent, pev_classname, rec_recorder );
		set_pev( ent, pev_nextthink, get_gametime() + 0.01 );
		RegisterHam( Ham_Think, "info_target", "forward_think", 1 );
	}
	maxplayers = get_maxplayers();
	for ( new i = 1; i <= maxplayers; i++ )
	{
		record_info[i] = ArrayCreate( frame_data );
	}	
	for ( new i = 0;  i < MAX_SOURCES; i++)
	{
		bot_sources[i][source_array] = _:ArrayCreate( frame_data );
	}
	
	get_mapname(g_szCurrentMap, charsmax(g_szCurrentMap));
	if(equali(g_szCurrentMap, "kz_longjumps2"))
	{
		kz_lj2 = true;
	}
	Check_Download_Demos( 0, 0, 0, "", "", ""); 
}

public kz_longjumps2()
{
	if(file_exists(kz_lj))
	{
		new lj2_file  = fopen( kz_lj, "rb" );
		new Line[64];			
		new ExplodedString[4][65];

		while (!feof(lj2_file))
		{
			fgets (lj2_file, Line, charsmax(Line));
			
			ExplodeString(ExplodedString, 3, 64, Line, ' ');
			if(strlen(Line) > 0) {
				trim(ExplodedString[0]);
				trim(ExplodedString[1]);
				trim(ExplodedString[2]);
				
				if(!equal(ExplodedString[0], "Block")){
				
					formatex(PlayerName, charsmax(PlayerName), ExplodedString[2]);
					formatex(sWRTime, charsmax(sWRTime), "%s_%s", ExplodedString[0], ExplodedString[1]);
					
					if(!already_parsed(PlayerName, sWRTime))
						Check_Download_Demos( 1, 1, 1, ExplodedString[0], ExplodedString[2], ExplodedString[1]);
				}
			}
		}
		fclose(lj2_file);
	}
	else
	{
		server_print("File %s not exists", kz_lj);
	}
}
public plugin_precache()
{
	step_sounds[0][0] = precache_sound("player/pl_step1.wav");
	step_sounds[0][1] = precache_sound("player/pl_step2.wav");
	step_sounds[0][2] = precache_sound("player/pl_step3.wav");
	step_sounds[0][3] = precache_sound("player/pl_step4.wav");

	step_sounds[1][0] = precache_sound("player/pl_slosh1.wav");
	step_sounds[1][1] = precache_sound("player/pl_slosh2.wav");
	step_sounds[1][2] = precache_sound("player/pl_slosh3.wav");
	step_sounds[1][3] = precache_sound("player/pl_slosh4.wav");

	step_sounds[2][0] = precache_sound("player/pl_wade1.wav");
	step_sounds[2][1] = precache_sound("player/pl_wade2.wav");
	step_sounds[2][2] = precache_sound("player/pl_wade3.wav");
	step_sounds[2][3] = precache_sound("player/pl_wade4.wav");

	step_sounds[3][0] = precache_sound("player/pl_swim1.wav");
	step_sounds[3][1] = precache_sound("player/pl_swim2.wav");
	step_sounds[3][2] = precache_sound("player/pl_swim3.wav");
	step_sounds[3][3] = precache_sound("player/pl_swim4.wav");

	step_sounds[4][0] = precache_sound("player/pl_ladder1.wav");
	step_sounds[4][1] = precache_sound("player/pl_ladder2.wav");
	step_sounds[4][2] = precache_sound("player/pl_ladder3.wav");
	step_sounds[4][3] = precache_sound("player/pl_ladder4.wav");
}
public plugin_natives()
{
	register_native("save_run", "native_save_run");
	register_native("pause_run", "native_pause_run");
	register_native("unpause_run", "native_unpause_run");
	register_native("reset_run", "native_reset_run");
}

//读取bot文件 并设置创建3s后创建BOT的任务
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
	// new local_demo_folder[64] = "addons/amxmodx/data/kz_bot";

	if(!dir_exists(archive_dir))
		mkdir(archive_dir);
	if(!dir_exists(temp_dir))
		mkdir(temp_dir);
	if(!dir_exists(local_demo_folder))
		mkdir(local_demo_folder);
	if(get_pcvar_num(cvar_deletedemos))
		rmdir_recursive(local_demo_folder);
	format(map_records_dir, charsmax(map_records_dir), "%s/%s", local_demo_folder ,g_szCurrentMap);
	if(!dir_exists(map_records_dir))
	{
		mkdir(map_records_dir);
	}

	
	new szFileName[64];
	new hDir = open_dir(map_records_dir, szFileName, charsmax(szFileName));
	do
	{
		if(equal(szFileName, "..") || equal(szFileName, "."))
		continue;
		
		new len = strlen(szFileName);
		if(!equal(szFileName[len-3], "rec"))
		{
			continue;
		}
		
		new path[128];
		format(path, 128, "%s/%s", map_records_dir, szFileName);
		load_run(path);			
	}
	while ( next_file( hDir, szFileName, charsmax( szFileName ) ) );
	close_dir(hDir);
	
	set_task(3.0, "create_bot");
	
	update_file_data = ArrayCreate(32);
	need_update_com = ArrayCreate(COMMUNITIES);
}


public client_putinserver(id)
{
	plr_playback[id] = true;
	plr_source[id] = 0;
	plr_frame_it[id] = 0;
	plr_botnamed[id] = false;
}

public client_disconnect(id)
{
	if(plr_delayed_save[id])
	{
		save_run(id, plr_saverun_time[id], false);
		plr_delayed_save[id] = false;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////BOT////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public create_bot()
{
	global_bot = makebot("Record Bot");
	//	is_recbot[global_bot] = true;	
}


public fw_clientinfochanged(id, buffer)
{
	if(id == global_bot)
	{
		arrayset(plr_botnamed, false, 32);
	}
}

public fw_prethink(id)
{		
	static Float:oldorigin[33][3];
	static Float:oldangles[33][3];
	static oldbuttons[33];
	static damaged_frames[33];
	new bool:dontstep = false;
	if(id == global_bot)
	{
		return FMRES_IGNORED;
	}	
	
	if(is_user_connected(id) && !plr_botnamed[id] && global_bot && bot_sources[plr_source[id]][source_type] && plr_frame_it[id])
	{
		update_sourcename(id);
		plr_botnamed[id] = true;
	}
	if(bot_inrestart[id])
	{
		if(get_gametime() > bot_restarttime[id])
		{
			bot_inrestart[id] = false;
			plr_frame_it[id] = 0;
		}
	}
	if(bot_sources[plr_source[id]][source_stoptime] && plr_frame_it[id] > 100 && ghost_data[id][frame_time] >= bot_sources[plr_source[id]][source_stoptime])
	{
		if(!bot_inrestart[id])
		{
			bot_inrestart[id] = true;			
			bot_restarttime[id] = get_gametime()+0.7;
		}
	}
	if(plr_playback[id])
	{		
		if(plr_mode[id] == MODE_WAIT )
		{
			new Float:origin[2][3];
			pev(id, pev_origin, origin[0]);
			xs_vec_copy(ghost_data[id][frame_origin], origin[1]);
			if(get_distance_f(origin[0], origin[1]) < 200.0)
			{
				plr_frame_it[id]++;
			}
			else
			{
				dontstep = true;
			}
		}
		else
		plr_frame_it[id]++;
	}
	else
	{
		dontstep = true;
	}
	if(!bot_sources[plr_source[id]][source_array] || !ArraySize(bot_sources[plr_source[id]][source_array]))
	{
		return FMRES_IGNORED;
	}
	if(plr_frame_it[id] > ArraySize(bot_sources[plr_source[id]][source_array])-1)
	{
		if(!bot_inrestart[id])
		{
			bot_inrestart[id] = true;
			bot_restarttime[id] = get_gametime()+0.7;
			get_gametime();
		}
		plr_frame_it[id] = ArraySize(bot_sources[plr_source[id]][source_array])-1;
		return FMRES_IGNORED;
	}	
	new Float:vel[3], Float:origins[3];		
	//xs_vec_copy(ghost_data[id][frame_origin], origins);
	ArrayGetArray(bot_sources[plr_source[id]][source_array], plr_frame_it[id], ghost_data[id]);
	
	new onground = ghost_data[id][frame_velocity][2] == 0.0 || ghost_data[id][frame_velocity][2] == 260.25 ? true : false;		
	
	xs_vec_copy(ghost_data[id][frame_origin], origins);			
	xs_vec_copy(ghost_data[id][frame_velocity], vel);
	
	if(ghost_data[id][frame_buttons] & IN_USE && ~oldbuttons[id] & IN_USE)
	{
		if(!bot_sources[plr_source[id]][source_starttime] || !bot_sources[plr_source[id]][source_stoptime])
		{					
			CheckButton(id);
		}
	}
	
	if(get_distance_f(oldorigin[id], origins) > 100.0)
	{			
		damaged_frames[id]++;
	}
	else
	{
		xs_vec_copy(origins, oldorigin[id]);	
		xs_vec_copy(ghost_data[id][frame_angles], oldangles[id]);	
		damaged_frames[id] = 0;
	}
	if(damaged_frames[id] > 10)
	{
		damaged_frames[id] = 0;
		xs_vec_copy(origins, oldorigin[id]);	
		xs_vec_copy(ghost_data[id][frame_angles], oldangles[id]);
	}
	xs_vec_copy(oldorigin[id], ghost_data[id][frame_origin]);
	xs_vec_copy(oldangles[id], ghost_data[id][frame_angles]);
	if(get_distance_f(origins, oldorigin[id]) < 100.0 && !damaged_frames[id])
	{
		xs_vec_copy(ghost_data[id][frame_origin], oldorigin[id]);
		xs_vec_copy(ghost_data[id][frame_angles], oldangles[id]);
	}
	vel[2] = 0.0;
	if(!dontstep)
	{
		static Float:botorigin[3];
		pev(id, pev_origin, botorigin);

		new on_ladder;
		new ent = 0;
		static Float:entorigin[3];
		static Classname[33];

		// Change distance if you want.
		const Float:Distance_ladder = 15.0;
		while((ent = engfunc(EngFunc_FindEntityInSphere, ent, botorigin, Distance_ladder)) != 0) {
		      if(!pev_valid(ent))
		            continue;
		  
		      pev(ent, pev_classname, Classname, 32);		    
		      if(equal(Classname, "func_ladder"))
		      {
		      		pev(ent, pev_origin, entorigin);
		      		on_ladder = 1;
	    			break;
		      }
		}

		if(/*pev(id, pev_movetype) == MOVETYPE_FLY*/on_ladder)
		{
			playback_sound(id, origins, 4);
		}
		else if(pev(id, pev_watertype) == CONTENTS_WATER)
   		{
   			if(pev(id, pev_waterlevel) >= 2)
   			{
   				playback_sound(id, origins, 3);
   			}
   			else if(pev(id, pev_waterlevel) == 1)
   			{
   				playback_sound(id, origins, 2);
   			}
   			else
   			{
   				playback_sound(id, origins, 1);
   			}
   		}
   		else
   		{
			if(onground && (vector_length(vel) > 120.0))
			{			
				if(ghost_data[id][frame_buttons] & IN_JUMP  && ~oldbuttons[id] & IN_JUMP && plr_sound[id] < 200)
				{			
					plr_sound[id] = 0;
				}
				if(pev(id, pev_groupinfo) && pev(id, pev_iuser2) == global_bot)
				{
					playback_sound(id, origins,0);
				}
				else if(!pev(id, pev_groupinfo))
				{
					playback_sound(id, origins, 0);
				}
			}
		}		
	}
	oldbuttons[id] = ghost_data[id][frame_buttons];
	
	plr_sound[id] -= 10;

	
	return FMRES_IGNORED;
}


public fw_updateclientdata(id, sendweapons, cd_handle )
{	
	if(id == global_bot)
	return FMRES_IGNORED;
	
	new ent = pev(id, pev_iuser2);
	if(!ent)
	return FMRES_IGNORED;
	
	if((global_bot == ent && sources_num) && (ArraySize(bot_sources[plr_source[id]][source_array]) > plr_frame_it[id]))
	{
		//forward_return(FMV_CELL, dllfunc(DLLFunc_UpdateClientData, ent, sendweapons, cd_handle));
		set_cd(cd_handle, CD_Origin, ghost_data[id][frame_origin]);

		static Float:neworigin[3];
		xs_vec_copy(ghost_data[id][frame_origin], neworigin);
		neworigin[2]+= 20.0;
		set_pev(ent, pev_origin, neworigin);
		set_cd(cd_handle, CD_iUser1, pev(id, pev_iuser1));
		set_cd(cd_handle, CD_iUser2, ent);
		set_cd(cd_handle, CD_Velocity, ghost_data[id][frame_velocity]);
		if(ghost_data[id][frame_buttons] & IN_DUCK)		
		set_cd(cd_handle, CD_ViewOfs, Float:{0.0, 0.0, 12.0});
		else
		set_cd(cd_handle, CD_ViewOfs, Float:{0.0, 0.0, 17.0});		
		static sz_time[12];	
		static Float:ftime;
		
		if(bot_sources[plr_source[id]][source_stoptime] && plr_frame_it[id] > 100 && ghost_data[id][frame_time] >= bot_sources[plr_source[id]][source_stoptime])
		{
			ftime = bot_sources[plr_source[id]][source_stoptime]-bot_sources[plr_source[id]][source_starttime];
			if(!bot_inrestart[id])
			{
				bot_inrestart[id] = true;			
				bot_restarttime[id] = get_gametime()+0.7;
			}
		}
		else
		{			
			ftime = ghost_data[id][frame_time]-bot_sources[plr_source[id]][source_starttime];
		}
		
		fnConvertTime( ftime, sz_time, charsmax( sz_time ) );
		if(ftime > 0.0 && !kz_lj2)
		{
			client_print(id, print_center, "[ %.2s:%.2s.%.2s ]", sz_time, sz_time[2], sz_time[5]);
		}
		//else client_print(id, print_center, "");
		
		if(get_pcvar_num(cvar_speed))
		{
			new Float:vel[3];
			xs_vec_copy(ghost_data[id][frame_velocity], vel);
			vel[2] = 0.0;
			set_hudmessage( 255, 255, 225, -1.0, 0.83, 0, 0.0, 0.05, 0.0, 0.0, 2);
			show_hudmessage(id, "%0.f units", vector_length(vel));
		}
		if(get_pcvar_num(cvar_keys))
		{
			new b = ghost_data[id][frame_buttons];
			set_hudmessage(255, 255, 225, -1.0, 0.490, 0, 0.0, 0.05, 0.0, 0.0, 4);
			show_hudmessage(id, "   %s^n %s     %s^n    %s^n%s^n%s", 
			b & IN_FORWARD ? "W" : " ", 
			b & IN_MOVELEFT ? "A" : " ", 
			b & IN_MOVERIGHT ? "D" : " ", 
			b & IN_BACK ? "S" : " ", 
			b & IN_JUMP ? "JUMP" : " ", 
			b & IN_DUCK ? "DUCK" : " ");
		}
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}


public checkVisibility(id, pset)
{
	if(!pev_valid(id))
	{
		return FMRES_IGNORED;
	}

	if(id == global_bot)
	{
		/*unregister_forward(FM_CheckVisibility,CheckVisibilityForward);
	    CheckVisibilityForward = 0;*/

	    forward_return(FMV_CELL, 1);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public fw_addtofullpack_pre(es, e, ent, host, hostflags, player, pSet)
{
	if(global_bot == host)
	{		
		return FMRES_IGNORED;
	}
	if(player)
	{	
		if((global_bot == ent || pev(host, pev_iuser2) == global_bot) && sources_num)
		{
			engfunc(EngFunc_CheckVisibility,ent, pSet);

			/*if(!engfunc(EngFunc_CheckVisibility,ent, pSet))
            {
                if(!CheckVisibilityForward)
                {
                    CheckVisibilityForward = register_forward(FM_CheckVisibility, "checkVisibility");
                }
            }*/
		}
	}
	return FMRES_IGNORED;
}

public fw_addtofullpack(es_handle,e,ent,host,hostflags,player,pSet)
{
	if(global_bot == host)
	{		
		return FMRES_IGNORED;
	}
	if(player)
	{		
		if(ArraySize(bot_sources[plr_source[host]][source_array]) > plr_frame_it[host])
		{
			if(global_bot == ent && sources_num)
			{
				new Float:origin[2][3];
				pev(host, pev_origin, origin[0]);
				xs_vec_copy(ghost_data[host][frame_origin], origin[1]);
				new spec = pev(host, pev_iuser2);
				if(spec && spec != ent)
				{
					ghost_data[host] = ghost_data[spec];
				}
				set_es(es_handle, ES_Velocity, ghost_data[host][frame_velocity]);
				ghost_data[host][frame_angles][0] /= -3.0;
				new bool:onground = ghost_data[host][frame_velocity][2] == 0.0 ? true : false;
				animate_legs(es_handle, ghost_data[host][frame_buttons], onground);
				set_es(es_handle, ES_Angles, ghost_data[host][frame_angles]);
				set_es(es_handle, ES_Origin, ghost_data[host][frame_origin]);				
				set_es(es_handle, ES_Solid, SOLID_NOT);			
				// fix ugly sequence
				set_es(es_handle, ES_Sequence , 75);
				set_es(es_handle, ES_RenderMode, kRenderTransAdd);			
				set_es(es_handle, ES_RenderFx, kRenderFxSolidFast, 0);			
				//set_es(es_handle, ES_RenderFx, kRenderFxSolidSlow, 0);

				if(is_user_alive(host))	
					set_es(es_handle, ES_RenderAmt, floatround(get_distance_f(origin[0], origin[1]) * 255.0 / 360.0, floatround_floor));
				else
					set_es(es_handle, ES_RenderAmt, 150.0);
				//return FMRES_SUPERCEDE;
			}
		}
	} 	
	return FMRES_IGNORED;
}




public fwdUse(ent, id)
{
	if(!pev_valid(id) ||  id > maxplayers)
	{
		return HAM_IGNORED;
	}

	new target[32];
	pev(ent, pev_target, target, charsmax(target));
	
	new bool:start_timer = false;
	new bool:stop_timer = false;
	if(TrieKeyExists(start_buttons, target))
	{
		start_timer = true;
	}
	else if(TrieKeyExists(stop_buttons, target))
	{
		stop_timer = true;
	}
	
	if(id == global_bot)
	{
		if(start_timer && !bot_sources[plr_source[id]][source_starttime])
		{
			bot_sources[plr_source[id]][source_starttime] = _:ghost_data[id][frame_time];
			bot_sources[plr_source[id]][source_startframe] = plr_frame_it[id];
		}
		else if(stop_timer && !bot_sources[plr_source[id]][source_stoptime])
		{
			bot_sources[plr_source[id]][source_stoptime] = _:ghost_data[id][frame_time];
		}
		return HAM_SUPERCEDE;
	}
	
	if(start_timer && plr_mode[id] >= MODE_USE)
	{	
		plr_frame_it[id] = bot_sources[plr_source[id]][source_startframe];
	}
	
	return HAM_IGNORED;
}

/************************************************
* 						*
*	RECORDING & PLAYBACK ARRAYS SECTION 	*
*	 					*
*************************************************/

#define NUM_THREADS 256

public forward_think( ent )
{	
	static classname[64];
	pev(ent, pev_classname, classname, 63);
	if ( equal( classname, rec_demoparser ) )
	{
		new file = pev(ent, pev_iuser1);
		new source_index = pev(ent, pev_iuser2);
		if(!file)
		{
			set_pev( ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
			return FMRES_IGNORED;
		}
		new bool:Finished;
		if(!Finished)
		{
			for(new i = 0; i < NUM_THREADS; i++)
			{
				if(read_frames(file, bot_sources[source_index][source_array]))
				{
					Finished = true;
					break;
				}
			}
		}
		if(Finished)
		{
			new filename[128];
			DecodeText(pev(ent, pev_iuser3), filename, charsmax(filename));
			fclose( file );
			delete_file(filename);
			
			new demo_time[32];
			demo_time = bot_sources[source_index][source_time];
			//
			save_run(source_index, demo_time, true);
			set_pev(ent, pev_iuser1, 0);
			set_pev( ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
		}
		else
		{
			set_pev( ent, pev_nextthink, get_gametime() + 0.001 );
		}		
		return FMRES_IGNORED;	
	}
	else if(equal(classname, rec_recorder))
	{
		new Float:nextthink =  0.01;
		//new Float:nextthink =  1//0.009;
		if(!get_pcvar_num(cvar_mode))
			return FMRES_IGNORED;
		else
		{
			static players[32], inum;
			get_players( players, inum );
			
			if(global_bot && inum == 1)
			{
				set_pev( ent, pev_nextthink, get_gametime()+nextthink);
				//server_print("paused");
				return FMRES_IGNORED;
			}		
			for ( new i = 0; i < inum; i++ )
			{	
				
				new id = players[i];
				
				if(global_bot == id)
				{	
					//dllfunc(DLLFunc_PlayerPreThink, id);
					dllfunc(DLLFunc_PlayerPostThink,  id);
					//dllfunc(DLLFunc_UpdateClientData,  id);
					//set_pev(id, pev_solid, SOLID_SLIDEBOX)
					set_pev(id, pev_deadflag, DEAD_NO);
					set_pev(id, pev_health, 100.0);					
				}	
				else 
				{
					if(global_bot && sources_num)
					fw_prethink(id);
					
					if(is_recording[id] || plr_delayed_save[id])
					{						
						if(plr_delayed_save[id])
						{
							if(get_gametime() > plr_delayed_timer[id])
							{
								plr_delayed_save[id] = false;
								save_run(id, plr_saverun_time[id], false);
							}
						}
						player_record( id );
					}
				}								
			}
		}
		
		set_pev( ent, pev_nextthink, get_gametime()+nextthink);
	}
		
	return FMRES_IGNORED;	
}

public CheckButton( id )
{	
	static ent = -1;
	static Float:origin[3];
	xs_vec_copy(ghost_data[id][frame_origin], origin);
	while ( (ent = fm_find_ent_in_sphere( ent, origin, 100.0 ) ) != 0 )
	{
		new classname[32];
		pev( ent, pev_classname, classname, charsmax( classname ) );
		if ( equal( classname, "func_button" ) )
		{
			new Float:eorigin[3];
			fm_get_brush_entity_origin( ent, eorigin );
			static target[32];
			pev( ent, pev_target, target, 31 );
			if(global_bot)
			{
				if (!bot_sources[plr_source[id]][source_starttime] && TrieKeyExists( start_buttons, target ) )
				{		
					//bot_findbuttons(id, global_bot)
					bot_sources[plr_source[id]][source_startframe] = plr_frame_it[id];
					bot_sources[plr_source[id]][source_starttime] = _:ghost_data[id][frame_time];
				}
				if (!bot_sources[plr_source[id]][source_stoptime] && TrieKeyExists( stop_buttons, target ) )
				{
					//bot_findbuttons(id, global_bot)
					bot_sources[plr_source[id]][source_stoptime] = _:ghost_data[id][frame_time];
				}
			}
		}
	}
}


public player_record( id )
{
	static temp_data[frame_data];
	
	temp_data[frame_buttons] 	= pev(id, pev_button);
	
	pev(id, pev_origin, 	temp_data[frame_origin]);
	pev(id, pev_v_angle, 	temp_data[frame_angles]);
	pev(id, pev_velocity,  	temp_data[frame_velocity]);	
	temp_data[frame_time] = _:get_gametime();
	
	ArrayPushArray(record_info[id], temp_data);
}


stock  bool:read_demo_header( file )
{
	static temp, entries;
	fseek( file, 8,    SEEK_SET );
	fread( file, temp, BLOCK_INT );

	if ( temp != 5 )
	{
		return false;
	}

	fread( file, temp, BLOCK_INT );

	if ( temp != 48 )
	{
		return false;
	}

	fseek( file, 260, SEEK_CUR );
	fseek( file, 260, SEEK_CUR );

	fseek( file, BLOCK_INT, SEEK_CUR );
	fread( file, temp, BLOCK_INT );

	fseek( file, temp, SEEK_SET );

	fread( file, entries, BLOCK_INT );
	for ( new i = 0; i < entries; i++ )
	{		
		fseek( file, BLOCK_INT, SEEK_CUR );
		fseek( file, 64, SEEK_CUR );
		fseek( file, BLOCK_INT, SEEK_CUR );
		fseek( file, BLOCK_INT, SEEK_CUR );
		fseek( file, BLOCK_INT, SEEK_CUR );
		fseek( file, BLOCK_INT, SEEK_CUR );
		fread( file, temp, BLOCK_INT );
		fseek( file, BLOCK_INT, SEEK_CUR );
	}

	fseek( file, temp, SEEK_SET );
	
	return true;

	/* server_print( "%d %d %s %s %d %d %d", iDemoHeader[demoProtocol], iDemoHeader[netProtocol], iDemoHeader[mapName], iDemoHeader[gameDir], iDemoHeader[mapCRC], iDemoHeader[directoryOffset], iDemoEntry[dirEntryCount] ); */
}



public read_frame_header( file, &Float:gametime)
{
	static type;
	fread( file, type, BLOCK_BYTE );
	fread( file, _:gametime, BLOCK_INT );
	fseek( file, 4, SEEK_CUR);

	return(type);
}


public read_frames( file, Array:array_to )
{
	new temp_data[frame_data];
	//if ( !feof( file ) )
	{
		new Float:gametime;
		new type = read_frame_header( file, gametime );
		new bool:breakme;		
		
		switch ( type )
		{
		case 0:
			{				
			}
		case 1:
			{				
				static length;	
				fseek( file, 84, SEEK_CUR );
				//fread( file, _:temp_data[frame_onground], BLOCK_INT );
				fseek( file, 8, SEEK_CUR );
				//fseek( file, 92, SEEK_CUR );
				fread( file, _:temp_data[frame_velocity][0], BLOCK_INT );
				fread( file, _:temp_data[frame_velocity][1], BLOCK_INT );
				fread( file, _:temp_data[frame_velocity][2], BLOCK_INT );
				for ( new i = 0; i < 3; ++i )
				fread( file, _:temp_data[frame_origin][i], BLOCK_INT );
				fseek( file, 124, SEEK_CUR );
				fread( file, _:temp_data[frame_angles][0], BLOCK_INT );
				fread( file, _:temp_data[frame_angles][1], BLOCK_INT );
				fread( file, _:temp_data[frame_angles][2], BLOCK_INT );
				fseek( file, 14, SEEK_CUR );
				fread( file, temp_data[frame_buttons], BLOCK_SHORT );
				fseek( file, 196, SEEK_CUR );
				fread( file, length, BLOCK_INT );
				fseek( file, length, SEEK_CUR );
			}
		case 2:
			{
			}
		case 3:
			{
				fseek( file, 64, SEEK_CUR);
			}
		case 4:
			{
				//for ( new i = 0; i < 3; ++i )
				//fread( file, _:temp_data[frame_origin][i], BLOCK_INT );
				
				fseek( file, 32, SEEK_CUR );

			}
		case 5:
			{
				breakme = true;
			}
		case 6:
			{
				fseek( file, 84, SEEK_CUR );
			}
		case 7:
			{
				fseek( file, 8, SEEK_CUR );
			}
		case 8:
			{				
				static length;
				fseek( file, 4, SEEK_CUR );
				fread( file, length, BLOCK_INT );
				fseek( file, length, SEEK_CUR );
				fseek( file, 16, SEEK_CUR );
			}
		case 9:
			{
				static length;
				fread( file, length, BLOCK_INT );
				fseek( file, length, SEEK_CUR );
			}
		default:
			{
				breakme = true;
			}
		}

		if(type == 1)
		{
			temp_data[frame_time] = _:gametime;
			ArrayPushArray(array_to, temp_data);		
		}
		
		if(breakme)
		{
			return true;
		}		
	}

	return false;
}

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////CURL FOR CHECK AND DOWNLOAD DEMOS AND ARCHIVES////////////////////
////////////////////////////////////////FileType////////////////////////////////////////////
/////////////////////////////// 0 - Demos, 1 - Archive /////////////////////////////////////
////////////////for kz_lj2 community, download, filetype, block, name, type/////////////////

public Check_Download_Demos(Community, Download, FileType, FileName[], Player_Name[], WR_Time[])
{
	if(kz_lj2)
	{
		new CURL:curl = curl_easy_init();	
		new data[256];
		format(data[3], strlen(FileName), "%s", FileName);
		format(data[129], strlen(Player_Name), "%s", Player_Name);
		strtolower(WR_Time);
		format(data[193], strlen(WR_Time), "%s", WR_Time);

		new Link[256];
		
		format(Ext, charsmax(Ext), "%s", g_szDemoFiles[Community][EXT] );
		format(Link, charsmax(Link), "%s/lj/%s/%s_%s_%s.%s", g_szDemoFiles[Community][LINK], WR_Time, FileName, WR_Time, Player_Name, Ext);
		
		#if defined DEBUG
			server_print("[LINK] : %s", Link);
		#endif
		
		curl_easy_setopt(curl, CURLOPT_URL, Link);
		new archivefile[256];
		format (archivefile, charsmax(archivefile), "%s/%s_%s_%s.%s", archive_dir, FileName, WR_Time, Player_Name, Ext );
		
		
		data[0] = fopen(archivefile, "wb");
		curl_easy_setopt(curl, CURLOPT_BUFFERSIZE, 512);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, data[0]);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, "write");
		curl_easy_perform(curl, "complete", data, sizeof(data)); 
	}
	else
	{
		new CURL:curl = curl_easy_init();	
		new data[256];
		data[2] = Community;
		format(data[3], strlen(FileName), "%s", FileName);
		format(data[129], strlen(Player_Name), "%s", Player_Name);
		format(data[193], strlen(WR_Time), "%s", WR_Time);
		
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
}

public complete(CURL:curl, CURLcode:code, data[])
{	
	fclose(data[0]);
	new Community = data[2];
	
	if(kz_lj2)
	{
		new iResponceCode;
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, iResponceCode);
		
		new filename[128];
		format( filename, charsmax( filename ), "%s/%s_%s_%s.%s", archive_dir, data[3], data[193], data[129], Ext);
		
		
		if (iResponceCode > 399)
		{
			delete_file(filename);			
			#if defined DEBUG
				server_print("[ERROR] : iResponceCode: %d", iResponceCode);
			#endif
			server_print("*No World Record on this map!");
			
		}
		else
		{
			DownloadArchiveComplete(filename, data[3], data[129], data[193]);
			
			#if defined DEBUG
				server_print("[COMPLETE] : iResponceCode: %d - file: %s", iResponceCode, filename);
			#endif
		}
	}
	else
	{
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
				Check_Download_Demos(Community, 0, 0, "", "", "");
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
				if(kz_lj2)
				{
					set_task(5.0, "kz_longjumps2");
				}
			}
			else
			{
				CheckAgain = false;
				CheckExt = false;
				DownloadArchiveComplete(filename, data[3], data[129], data[193]);
				
				#if defined DEBUG
					server_print("[COMPLETE] : iResponceCode: %d - file: %s", iResponceCode, filename);
				#endif
			}
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
			Check_Download_Demos(comm, 1, 0, "", "", "");
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
		if(kz_lj2)
		{
			set_task(1.0, "kz_longjumps2");
		}
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
	new Line[128];
	
	while ( !feof( iDemosList ) )
	{
		fgets(iDemosList, Line, charsmax(Line));
		ExplodeString(ExplodedString, 6, 127, Line, ' ');
		new parsedmap[128], DLMap[64], Extens[32], Mapa[32];
		
		parsedmap = ExplodedString[0];
		trim(parsedmap);
		new Float:Time = str_to_float( ExplodedString[1]);

		if (containi(parsedmap, g_szCurrentMap ) == 0 && Time > 0.0)
		{			
			split(parsedmap, Mapa, 31, Extens, 31, "[");
			trim(Mapa);
			trim(Extens);
			
			if(equali(Mapa, g_szCurrentMap))
			{
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
				
				fnConvertTime( Time, sWRTime, charsmax( sWRTime ) );

				format( iArchiveName, charsmax( iArchiveName ), "%s_%s_%s", DLMap, PlayerName, sWRTime );
				
				#if defined DEBUG
					server_print("Archivename %s", iArchiveName);
				#endif
				if(!already_parsed(PlayerName, sWRTime))
					Check_Download_Demos(Community, 1, 1, iArchiveName, PlayerName, sWRTime);
			}
		}
	}
	fclose(iDemosList);
}

public already_parsed(player_name[], wr_time[])
{
	for(new i = 0; i < MAX_SOURCES; i++)
	{
		remove_quotes(bot_sources[i][source_name]);
		remove_quotes(bot_sources[i][source_time]);
		trim(bot_sources[i][source_name]);
		trim(bot_sources[i][source_time]);
		if(equal(bot_sources[i][source_time],wr_time) && equal(bot_sources[i][source_name], player_name))
		{
			return true;
		}		
	}
	return false;
}

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////AMXXARCH FOR UNARCHIVE ZIP AND RAR FILES//////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public DownloadArchiveComplete(Archive[], FileName[], Player_Name[], WR_Time[])
{
	format( RARArchive, charsmax( RARArchive ), "%s", Archive);
	formatex(PlayerName, charsmax(PlayerName), Player_Name);

	if(kz_lj2)
	{
		formatex(sWRTime, charsmax(sWRTime), "%s_%s", FileName, WR_Time);
		format( iArchiveName, charsmax( iArchiveName ), "%s_%s_%s", FileName, WR_Time, Player_Name );
	}
	else
	{
		formatex(sWRTime, charsmax(sWRTime), WR_Time);
		formatex(iArchiveName, charsmax(iArchiveName), FileName);
	}
	#if defined DEBUG
		server_print("RARArchive: %s", RARArchive);
	#endif
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
			server_print("Encoded - %s, %s", PlayerName, sWRTime);
			server_print("Decoded - %s", iArchiveName);
		#endif
		delete_file(RARArchive);
		new destname[128];
		format(destname, charsmax(destname), "%s/%s.dem", temp_dir, iArchiveName);

		
		new file = fopen(destname, "rb");
		if(is_valid_demo_file(file))
		{
			if(read_demo_header( file ))
			{
				new Ent = engfunc( EngFunc_CreateNamedEntity , engfunc( EngFunc_AllocString,"info_target" ) );
				set_pev(Ent, pev_classname, rec_demoparser);
				set_pev(Ent, pev_iuser1, file );
				set_pev(Ent, pev_iuser2, sources_num );
				set_pev(Ent, pev_iuser3, EncodeText(destname) );
				formatex(bot_sources[sources_num][source_name], 32, "%s", PlayerName, sWRTime);
				formatex(bot_sources[sources_num][source_time], 32, "%s", sWRTime);
				set_pev(Ent, pev_nextthink, get_gametime() + 3.0 );				
				sources_num++;
			}
		}
		
	}
}



////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////BOT MANAGE SECTION////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

public kzbot_settings(id)
{
	new menu = menu_create( "\rBot Playback:", "kzbot_settings_handle" );
	new text[256];	
	menu_additem( menu, "\wStart/Restart Bot", "1");	
	menu_additem( menu, "\wPause/Unpause Bot", "2");
	menu_additem( menu, "\wStop Bot", "3");
	if(global_bot)
		menu_additem( menu, "\wKick Bot", "4", ADMIN_KICK);			
	else
		menu_additem( menu, "\wAdd Bot", "4", ADMIN_KICK);	
	menu_additem( menu, "\wFast forward", "5");	
	menu_additem( menu, "\wFast backward", "6");
	format(text, charsmax(text), "\wFast Interval: %0.f sec ", float(plr_jump[id])/100.0);	
	menu_additem(menu, text, "7");
	format(text, charsmax(text), "\wBot mode: %s", bot_modes[plr_mode[id]]);	
	menu_additem(menu, text, "8");
	new sz_name[32];
	if(kz_lj2)
		format(sz_name, charsmax(sz_name), "[%s] %s %s", bot_sources[plr_source[id]][source_type] == SOURCE_WR ? "WR" : "REC", bot_sources[plr_source[id]][source_name], bot_sources[plr_source[id]][source_time]);
	else
		format(sz_name, charsmax(sz_name), "[%s] %s %.2s:%.2s.%.2s", bot_sources[plr_source[id]][source_type] == SOURCE_WR ? "WR" : "REC", bot_sources[plr_source[id]][source_name], bot_sources[plr_source[id]][source_time], bot_sources[plr_source[id]][source_time][2], bot_sources[plr_source[id]][source_time][5]);
	format(text, charsmax(text), "\wBot Source: %s", sz_name);
	menu_additem( menu, text, "9");
	menu_additem( menu, "Exit", "0" );
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
	
	return PLUGIN_HANDLED;
}

public kzbot_settings_handle(id, menu, item)
{
	if( item == MENU_EXIT ) 
	{ 
		menu_destroy( menu ); 
		return PLUGIN_HANDLED; 
	} 
	switch( item )
	{
		case 0:
		{		
			plr_frame_it[id] = 0;
			plr_playback[id] = true;
		}
		case 1:
		{		
			plr_playback[id] = !plr_playback[id];
		}
		case 2:
		{		
			plr_frame_it[id] = 0;
			plr_playback[id] = false;
		}
		case 3:
		{
			if((get_user_flags(id) & ADMIN_KICK))
			{
				if(global_bot)
				{
					server_cmd("kick #%d",get_user_userid(global_bot));			
					global_bot = 0;
				}
				else
				{
					global_bot = makebot("Record Bot");
					//set_task(0.1, "update_sourcename", id)
				}
			}
		}
		case 4:
		{
			plr_frame_it[id] += plr_jump[id];			
			if(plr_frame_it[id] > ArraySize(bot_sources[plr_source[id]][source_array])-1)
			{
				plr_frame_it[id] = 0;
			}
		}
		case 5:
		{
			plr_frame_it[id] -= plr_jump[id];
			
			if(plr_frame_it[id] < 0)
			{
				plr_frame_it[id] = 0;
			}
		}
		case 6:
		{
			plr_jump[id] += 300;
			if(plr_jump[id] > 3000)
			{
				plr_jump[id] = 300;
			}
			
		}
		case 7:
		{
			if(++plr_mode[id] > sizeof(bot_modes)-1)
				plr_mode[id] = 0;
		}
		case 8:
		{
			if(++plr_source[id] == sources_num)
				plr_source[id] = 0;
			
			if(global_bot)
				update_sourcename(id);				
		}
		case 9:
		{
			menu_destroy( menu ); 
			return PLUGIN_HANDLED; 
		}
	}
	
	kzbot_settings(id);
	
	return PLUGIN_HANDLED; 
}

// global_bot = makebot("Record Bot");
public makebot(name[64])
{	
	remove_quotes(name);	//删除引号
	trim(name);
	new bot = engfunc( EngFunc_CreateFakeClient, name );
	if ( !bot )
	{
		server_print( "Couldn't create a bot, server full?" );
		return 0;
	}
	
	engfunc( EngFunc_FreeEntPrivateData, bot );
	bot_settings( bot );

	static szRejectReason[128];
	dllfunc( DLLFunc_ClientConnect, bot, name, "127.0.0.1", szRejectReason );
	if ( !is_user_connected( bot ) )
	{
		server_print( "Connection rejected: %s", szRejectReason );
		return 0;
	}

	dllfunc( DLLFunc_ClientPutInServer, bot );
	set_pev( bot, pev_spawnflags, pev( bot, pev_spawnflags ) | FL_FAKECLIENT );
	set_pev( bot, pev_flags, pev( bot, pev_flags ) | FL_FAKECLIENT );

	engclient_cmd( bot , "jointeam" , "2" );
	engclient_cmd( bot , "joinclass" , "1" );
	fm_cs_set_user_team(bot, 2);
	ExecuteHamB( Ham_CS_RoundRespawn, bot );
	fm_give_item(bot, "weapon_knife" );
	fm_set_user_godmode( bot, 1 );
	set_pev(bot, pev_origin, Float:{8192.0, 8192.0, 8192.0});
	return bot;
}

public bot_settings( id )
{
	set_user_info( id, "model", "gordon" );
	set_user_info( id, "rate", "3500" );
	set_user_info( id, "cl_updaterate", "30" );
	set_user_info( id, "cl_lw", "0" );
	set_user_info( id, "cl_lc", "0" );
	set_user_info( id, "tracker", "0" );
	set_user_info( id, "cl_dlmax", "128" );
	set_user_info( id, "lefthand", "1" );
	set_user_info( id, "friends", "0" );
	set_user_info( id, "dm", "0" );
	set_user_info( id, "ah", "1" );

	set_user_info( id, "*bot", "1" );
	set_user_info( id, "_cl_autowepswitch", "1" );
	set_user_info( id, "_vgui_menu", "0" );         /* disable vgui so we dont have to */
	set_user_info( id, "_vgui_menus", "0" );        /* register both 2 types of menus :) */
}

public delayed_save(id, data[32])
{
	plr_saverun_time[id] = data;
	plr_delayed_save[id] = true;
	plr_delayed_timer[id] = get_gametime() + 1.0;
}

public native_save_run(plugin_id, params)
{
	static id; id = get_param(1);
	new demo_time[32];
	get_string(2,demo_time,31);
	delayed_save(id, demo_time);
}

public native_reset_run(plugin_id, params)
{
	static id; id = get_param(1);
	if(plr_delayed_save[id])
	{
		save_run(id, plr_saverun_time[id], false);
		plr_delayed_save[id] = false;
	}
	if(global_bot != id)
		ArrayClear(record_info[id]);
}

public native_pause_run(plugin_id, params)
{
	static id; id = get_param(1);
	is_recording[id] = false;
}

public native_unpause_run(plugin_id, params)
{
	static id; id = get_param(1);
	is_recording[id] = true;	
}

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////STOCKS////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

stock EncodeText( const text[] )
{
	return engfunc( EngFunc_AllocString, text );
}

stock DecodeText( const text, string[], const length )
{
	global_get( glb_pStringBase, text, string, length );
}

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
		
			new demfile = fopen(sz_dest, "r");
			new string[300];
			new demo_type[32];

			fgets(demfile, string, charsmax(string));
			static ExplodedString[14][32];
			ExplodeString( ExplodedString, 4, 127, string, ' ' );

			copy(demo_type, 32, ExplodedString[2]);
			trim(demo_type);
			if(equal(demo_type, "DEMO"))
			{
				fclose(demfile);
				delete_file(sz_dest);
			}
			else
				fclose(demfile);
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

public bool:is_valid_demo_file( file )
{
	fseek( file, 0, SEEK_END );
	new header_size = ftell( file );


	if ( header_size < 544 )
	{
		return(false);
	}

	fseek( file, 0, SEEK_SET );
	new signature[6];

	fread_blocks( file, signature, sizeof(signature), BLOCK_CHAR );

	if ( !contain( "HLDEMO", signature ) )
	{
		return(false);
	}

	return(true);
}



#define PEV_PDATA_SAFE    2
#define OFFSET_TEAM            114
#define OFFSET_DEFUSE_PLANT    193
#define HAS_DEFUSE_KIT        (1<<16)
#define OFFSET_INTERNALMODEL    126

stock fm_cs_set_user_team(id, team)
{
	if(!(1 <= id <= maxplayers) || pev_valid(id) != PEV_PDATA_SAFE)
	{
		return 0;
	}

	switch(team)
	{
		case 1:
		{
			new iDefuser = get_pdata_int(id, OFFSET_DEFUSE_PLANT);
			if(iDefuser & HAS_DEFUSE_KIT)
			{
				iDefuser -= HAS_DEFUSE_KIT;
				set_pdata_int(id, OFFSET_DEFUSE_PLANT, iDefuser);
			}
			set_pdata_int(id, OFFSET_TEAM, 1);
		//    set_pdata_int(id, OFFSET_INTERNALMODEL, 4)
		}
		case 2:
		{
			if(pev(id, pev_weapons) & (1<<CSW_C4))
			{
				engclient_cmd(id, "drop", "weapon_c4");
			}
			set_pdata_int(id, OFFSET_TEAM, 2);
		//    set_pdata_int(id, OFFSET_INTERNALMODEL, 6)
		}
	}

	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id));

	return 1;
}



stock animate_legs(es_handle,  keys, bool:onground)
{
	#define InMove (keys & IN_FORWARD || keys & IN_LEFT || keys & IN_RIGHT || keys & IN_BACK)
	
	//client_print(0, print_chat, "%d", onground);
	if (onground)
	{
		if ( keys & IN_DUCK && InMove )
		{
			set_es(es_handle, ES_GaitSequence, 5 );
		}else if ( keys & IN_DUCK )
		{
			set_es(es_handle, ES_GaitSequence, 2 );
		}else  {
			set_es(es_handle, ES_GaitSequence, 4 );
		}
		if ( keys & IN_JUMP )
		{
			set_es(es_handle, ES_GaitSequence, 6 );
		}else  {
			set_es(es_handle, ES_GaitSequence, 4 );
		}
	}else  {
		set_es(es_handle, ES_GaitSequence, 6 );
		
		if ( keys & IN_DUCK )
		{
			set_es(es_handle, ES_GaitSequence, 5 );
		}
	}
}

stock CloneRun( Array:source_arr, Array:dest_arr, bool:clean )
{
	static len; len = ArraySize(source_arr);	
	static data[frame_data];
	
	if(clean)
		ArrayClear(dest_arr);
		
	for(new i = 0; i < len; i++)
	{
		ArrayGetArray(source_arr, i, data);
		ArrayPushArray(dest_arr, data);
	}
}


public playback_sound(id, Float:origin[3], type)
{
	static stepleft[33];
	
	if(plr_sound[id] > 0)
	{
		return 0;
	}
	
	stepleft[id] = !stepleft[id];
	new irand = random_num(0,1) + (stepleft[id] * 2);
	plr_sound[id] = 300;
	spawnStaticSound(id, origin, step_sounds[type][irand], 1.0, ATTN_NORM, PITCH_NORM, 0);
	
	return 0;
}

#define clamp_byte(%1)     ( clamp( %1, 0, 255 ) ) 
#define write_coord_f(%1)  ( engfunc( EngFunc_WriteCoord, %1 ) )

stock spawnStaticSound( const index, const Float:origin[3], const soundIndex, const Float:vol, const Float:atten, const pitch, const flags ) 
{     
	message_begin( index ? MSG_ONE : MSG_ALL, SVC_SPAWNSTATICSOUND, .player = index );
	{
		write_coord_f( origin[0] ); 
		write_coord_f( origin[1] ); 
		write_coord_f( origin[2] );
		write_short( soundIndex );
		write_byte( clamp_byte( floatround( vol * 255 ) ) );
		write_byte( clamp_byte( floatround( atten * 64 ) ) );
		write_short( 0 );        
		write_byte( pitch ); 
		write_byte( flags );   
	}
	message_end();
}

stock set_user_fake_name(const id, const name[])
{	
	message_begin(MSG_ONE, SVC_UPDATEUSERINFO, _, id);	
	write_byte(global_bot - 1);
	write_long(get_user_userid(global_bot));
	write_char('\');
	write_char('n');
	write_char('a');
	write_char('m');
	write_char('e');
	write_char('\');
	write_string(name);
	for(new i; i < 16; i++) write_byte(0);
	message_end();
}

public update_sourcename( id )
{
	new sz_name[32];
	
	if(kz_lj2)
		format(sz_name, charsmax(sz_name), "[%s] %s %s", bot_sources[plr_source[id]][source_type] == SOURCE_WR ? "WR" : "REC", bot_sources[plr_source[id]][source_name], bot_sources[plr_source[id]][source_time]);
	else
		format(sz_name, charsmax(sz_name), "[%s] %s %.2s:%.2s.%.2s", bot_sources[plr_source[id]][source_type] == SOURCE_WR ? "WR" : "REC", bot_sources[plr_source[id]][source_name], bot_sources[plr_source[id]][source_time], bot_sources[plr_source[id]][source_time][2], bot_sources[plr_source[id]][source_time][5]);
	
	
	set_user_fake_name(id, sz_name);	
}

new RecordFile[128];

public load_run(filename[128])
{
	new file = fopen(filename, "r");
	new string[300];
	new player_name[32], demo_time[32], demo_type[32];
	
	fgets(file, string, charsmax(string));
	if(containi(string, "HEADER") == -1)
	{		
		fclose(file);
		return -1;
	}
	static ExplodedString[14][32];
	ExplodeString( ExplodedString, 4, 127, string, ' ' );
	
	copy(player_name, 32, ExplodedString[1]);
	copy(demo_type, 32, ExplodedString[2]);
	copy(demo_time, 32, ExplodedString[3]);
	static temp_frame[frame_data];
	new id = sources_num;	
	bot_sources[id][source_type] = SOURCE_REC;
	bot_sources[id][source_id] = sources_num;
	bot_sources[id][source_name] = player_name;
	bot_sources[id][source_time] = demo_time;
	bot_sources[id][source_path] = filename;	
	remove_quotes(bot_sources[id][source_name]);
	remove_quotes(bot_sources[id][source_time]);
	remove_quotes(demo_type);
	trim(bot_sources[id][source_name]);
	trim(bot_sources[id][source_time]);
	trim(demo_type);
	if(equal(demo_type, "DEMO"))
	{
		bot_sources[id][source_type] = SOURCE_WR;
	}
	else
	{
		format(RecordFile, charsmax(RecordFile), filename);
	}
	sources_num++;
	ArrayClear(bot_sources[id][source_array]);
	while(fgets(file, string, charsmax(string)))
	{
		ExplodeString( ExplodedString, 13, 31, string, ' ' );
		temp_frame[frame_origin][0] = _:str_to_float(ExplodedString[1]);
		temp_frame[frame_origin][1] = _:str_to_float(ExplodedString[2]);
		temp_frame[frame_origin][2] = _:str_to_float(ExplodedString[3]);
		temp_frame[frame_angles][0] = _:str_to_float(ExplodedString[4]);
		temp_frame[frame_angles][1] = _:str_to_float(ExplodedString[5]);
		temp_frame[frame_angles][2] = _:str_to_float(ExplodedString[6]);
		temp_frame[frame_velocity][0] = _:str_to_float(ExplodedString[7]); 
		temp_frame[frame_velocity][1] = _:str_to_float(ExplodedString[8]);
		temp_frame[frame_velocity][2] = _:str_to_float(ExplodedString[9]);
		temp_frame[frame_buttons] = _:str_to_num(ExplodedString[10]);
		temp_frame[frame_time] = _:str_to_float(ExplodedString[11]);
		ArrayPushArray(bot_sources[id][source_array], temp_frame);
		
	}
	fclose(file);
	
	return id;
}

//保存记录文件 amxmodx\data\kz_bot\map_records_dir
public save_run(id, demo_time[32], bool:is_demofile)
{
	server_print("=====================================================");
	server_print("save_run called!");
	new sz_name[32], sz_steam[32], filename[128];
	if(!is_demofile)
	{
		get_user_name(id, sz_name, 63);	
		server_print("sz_name %s", sz_name);
		get_user_authid(id, sz_steam, 63);
		server_print("sz_steam %s", sz_steam);
		if(file_exists(RecordFile))
			delete_file(RecordFile);
		server_print("RecordFile is %s", RecordFile);
	}
	else
	{
		server_print("This is  a demo file!");
		copy(sz_name, 32, bot_sources[id][source_name]);
		copy(demo_time, 32, bot_sources[id][source_time]);
		bot_sources[id][source_type] = SOURCE_WR;
		sz_steam = "DEMO";
	}
	replace_all(sz_name, charsmax(sz_name), "^"", "");
	replace_all(sz_name, charsmax(sz_name), "^'", "");
	
	format(filename, charsmax(filename), "%s/[%s]_%s.rec", map_records_dir, demo_time, sz_name);


	new file = fopen(filename, "wb");
	new string[300];
	format(string, charsmax(string), "HEADER ^"%s^" ^"%s^" ^"%s^" ^n", sz_name, sz_steam, demo_time);


	fputs(file, string);
	//client_print(0, print_chat, "%d", ArraySize( record_info[id] ));
	
	new Array:array;
	if(is_demofile)
	{
		array = bot_sources[id][source_array];
		
	}
	else
	{
		array = record_info[id];
	}
	
	new arrsize = ArraySize(array);
	new temp_frame[frame_data];	
	for(new i = 0; i < arrsize; i++ )
	{
		ArrayGetArray( array, i, temp_frame );		
		format(string, charsmax(string), "INFO %f %f %f %f %f %f %f %f %f %d %f^n", temp_frame[frame_origin][0],
		temp_frame[frame_origin][1], temp_frame[frame_origin][2], temp_frame[frame_angles][0], temp_frame[frame_angles][1],
		temp_frame[frame_angles][2], temp_frame[frame_velocity][0], temp_frame[frame_velocity][1], temp_frame[frame_velocity][2],
		temp_frame[frame_buttons], temp_frame[frame_time]);
		fputs(file, string);
	}
		
	fclose(file);

	if(!is_demofile)
	{
		format(RecordFile, charsmax(RecordFile), filename);		
		new bool:replacesource = false;
		new replaceid;
		server_print("sources_num is %d", sources_num);
		if(sources_num)
		{
			for(new i = 0; i < sources_num; i++)
			{
				if(bot_sources[i][source_type] == SOURCE_REC)
				{
					replacesource = true;
					ArrayClear(bot_sources[i][source_array]);
					replaceid = i;
					break;
				}
			}
		}	
		
		if(replacesource)
		{
			arrayset(plr_botnamed, false, 32);
		}		
		new id = sources_num;
		server_print("replacesource is %d", replacesource);
		if(replacesource)	
			id = replaceid;
		server_print("id is %d", id);
		bot_sources[id][source_id] = id;
		server_print("1");

		bot_sources[id][source_name] = sz_name;
		server_print("2");

		//source_time溢出
		server_print("demo_time is %s", demo_time);
		bot_sources[id][source_time] = demo_time;	
		server_print("bot_sources[id][source_time] is %s", bot_sources[id][source_time]);

		bot_sources[id][source_path] = filename;
		server_print("4");

		bot_sources[id][source_startframe] = 0;	
		server_print("=====before ArrayGetArray =====");

		ArrayGetArray( array, id, temp_frame );	
		server_print("=====after ArrayGetArray =====");

		bot_sources[id][source_starttime] = _:temp_frame[frame_time];
		bot_sources[id][source_stoptime] = _:0.0;
		bot_sources[id][source_type] = SOURCE_REC;
		CloneRun(array, bot_sources[id][source_array], true);
		if(!replacesource)
			sources_num++;		
	}
}