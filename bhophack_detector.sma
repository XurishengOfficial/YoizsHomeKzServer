#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "BhopHack Detector"
#define VERSION "0.1"
#define AUTHOR "Mistrick"

#pragma semicolon 1

#define LOGFILE "bhopdetector.log"

enum _:PLAYER_DATA
{
	m_GroundFrames,
	m_OldGroundFrames,
	m_PreJumpGroundFrames,
	m_OldPreJumpGroundFrames,
	m_AirFrames,//useless
	m_JumpHoldFrames,
	m_JumpPressCount,
	m_DuckHoldFrames,
	Float:m_Velocity//useless
};
enum _:WARNINGS_DATA
{
	m_WarnEqualFrames,
	m_WarnGroundEqualFrames,
	m_WarnJumpSpam
}

#define MAX_JUMPCOUNT 16
#define MAX_GROUND_FRAME_COINCIDENCE 16
#define MAX_JUMP_SPAM 8

new g_ePlayerInfo[33][PLAYER_DATA];
new g_ePlayerWarn[33][WARNINGS_DATA];
new g_ePlayerWarnMax[33][WARNINGS_DATA];


new g_szLogFile[128];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_Pre", false);	
}
public plugin_cfg()
{
	get_localinfo("amxx_logs", g_szLogFile, charsmax(g_szLogFile));
	format(g_szLogFile, charsmax(g_szLogFile), "/%s/%s", g_szLogFile, LOGFILE);
}
public client_putinserver(id)
{
	g_ePlayerWarn[id][m_WarnEqualFrames] = 0;
	g_ePlayerWarn[id][m_WarnGroundEqualFrames] = 0;
	g_ePlayerWarn[id][m_WarnJumpSpam] = 0;
}
public client_disconnect(id)
{
	UTIL_LogUser(id, "onground %d, equaljump %d, jumpspam %d", g_ePlayerWarnMax[id][m_WarnGroundEqualFrames], g_ePlayerWarnMax[id][m_WarnEqualFrames], g_ePlayerWarnMax[id][m_WarnJumpSpam]);
	
	g_ePlayerWarnMax[id][m_WarnEqualFrames] = 0;
	g_ePlayerWarnMax[id][m_WarnGroundEqualFrames] = 0;
	g_ePlayerWarnMax[id][m_WarnJumpSpam] = 0;
}
public FM_PlayerPreThink_Pre(id)
{
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	new buttons = pev(id, pev_button);
	new oldbuttons = pev(id, pev_oldbuttons);
	
	if(buttons & IN_JUMP)
	{
		g_ePlayerInfo[id][m_JumpHoldFrames]++;
	}
	if(buttons & IN_JUMP && ~oldbuttons & IN_JUMP)
	{
		g_ePlayerInfo[id][m_JumpPressCount]++;
	}
	if(~buttons & IN_JUMP && oldbuttons & IN_JUMP)
	{
		///**************************************
	}
	if(buttons & IN_DUCK)
	{
		g_ePlayerInfo[id][m_DuckHoldFrames]++;
	}
	
	new on_ground = bool:(pev(id, pev_flags) & FL_ONGROUND);
	
	if(on_ground)
	{
		g_ePlayerInfo[id][m_GroundFrames]++;
	}
	else
	{
		if(g_ePlayerInfo[id][m_GroundFrames])
		{
			new Float:velocity[3]; pev(id, pev_velocity, velocity); velocity[2] = 0.0;
			g_ePlayerInfo[id][m_Velocity] = _:vector_length(velocity);
			g_ePlayerInfo[id][m_PreJumpGroundFrames] = g_ePlayerInfo[id][m_GroundFrames];
		}
		g_ePlayerInfo[id][m_GroundFrames] = 0;
		g_ePlayerInfo[id][m_AirFrames]++;
	}
	
	if(g_ePlayerInfo[id][m_OldGroundFrames] == 0 && g_ePlayerInfo[id][m_GroundFrames])
	{
		if(g_ePlayerInfo[id][m_JumpPressCount] == 0 && g_ePlayerInfo[id][m_JumpHoldFrames] == 0 && g_ePlayerInfo[id][m_DuckHoldFrames] == 0)
		{
			//console_print(id, "wtf? JumpPressCount 0, JumpHoldFrames 0, DuckHoldFrames 0");
		}
		if(g_ePlayerInfo[id][m_JumpPressCount] > 0)
		{
			/// if g_ePlayerInfo[id][m_JumpHoldFrames] == g_ePlayerInfo[id][m_JumpPressCount] cheat
			/// if g_ePlayerInfo[id][m_JumpPressCount] > 16 script
			
			//console_print(id, "ground [%d], air [%d], jumphold [%d], jumpcount [%d], velocity [%.3f]", g_ePlayerInfo[id][m_PreJumpGroundFrames],  g_ePlayerInfo[id][m_AirFrames], g_ePlayerInfo[id][m_JumpHoldFrames], g_ePlayerInfo[id][m_JumpPressCount], g_ePlayerInfo[id][m_Velocity]);
			
			/// TODO: сделать цикл
			if(g_ePlayerInfo[id][m_JumpHoldFrames] == g_ePlayerInfo[id][m_JumpPressCount])
			{
				g_ePlayerWarn[id][m_WarnEqualFrames]++;
				if(g_ePlayerWarn[id][m_WarnEqualFrames] > g_ePlayerWarnMax[id][m_WarnEqualFrames])
				{
					g_ePlayerWarnMax[id][m_WarnEqualFrames] = g_ePlayerWarn[id][m_WarnEqualFrames];
				}
			}
			else if(g_ePlayerWarn[id][m_WarnEqualFrames])
			{
				g_ePlayerWarn[id][m_WarnEqualFrames]--;
			}
			
			if(g_ePlayerInfo[id][m_PreJumpGroundFrames] == g_ePlayerInfo[id][m_OldPreJumpGroundFrames])
			{
				g_ePlayerWarn[id][m_WarnGroundEqualFrames]++;
				if(g_ePlayerWarn[id][m_WarnGroundEqualFrames] > g_ePlayerWarnMax[id][m_WarnGroundEqualFrames])
				{
					g_ePlayerWarnMax[id][m_WarnGroundEqualFrames] = g_ePlayerWarn[id][m_WarnGroundEqualFrames];
				}
			}
			else if(g_ePlayerWarn[id][m_WarnGroundEqualFrames])
			{
				g_ePlayerWarn[id][m_WarnGroundEqualFrames]--;
			}
			
			if(g_ePlayerInfo[id][m_JumpPressCount] >= MAX_JUMPCOUNT)
			{
				g_ePlayerWarn[id][m_WarnJumpSpam]++;
				if(g_ePlayerWarn[id][m_WarnJumpSpam] > g_ePlayerWarnMax[id][m_WarnJumpSpam])
				{
					g_ePlayerWarnMax[id][m_WarnJumpSpam] = g_ePlayerWarn[id][m_WarnJumpSpam];
				}
			}
			else if(g_ePlayerWarn[id][m_WarnJumpSpam])
			{
				g_ePlayerWarn[id][m_WarnJumpSpam]--;
			}
			
			//console_print(id, "groundequal [%d], jumpequal[%d], jumpspam [%d]", g_ePlayerWarn[id][m_WarnGroundEqualFrames], g_ePlayerWarn[id][m_WarnEqualFrames], g_ePlayerWarn[id][m_WarnJumpSpam]);
			
			if(g_ePlayerWarn[id][m_WarnGroundEqualFrames] >= MAX_GROUND_FRAME_COINCIDENCE)
			{
				PunishPlayer(id, "BhopHack[g]");
				g_ePlayerWarn[id][m_WarnGroundEqualFrames] = 0;
			}
			if(g_ePlayerWarn[id][m_WarnJumpSpam] >= MAX_JUMP_SPAM)
			{
				PunishPlayer(id, "BhopHack[s]");
				g_ePlayerWarn[id][m_WarnJumpSpam] = 0;
			}
		}
		
		g_ePlayerInfo[id][m_AirFrames] = 0;
		g_ePlayerInfo[id][m_JumpHoldFrames] = 0;
		g_ePlayerInfo[id][m_JumpPressCount] = 0;
		g_ePlayerInfo[id][m_DuckHoldFrames] = 0;
		g_ePlayerInfo[id][m_OldPreJumpGroundFrames] = g_ePlayerInfo[id][m_PreJumpGroundFrames];
	}
	
	g_ePlayerInfo[id][m_OldGroundFrames] = g_ePlayerInfo[id][m_GroundFrames];
	
	return FMRES_IGNORED;
}
PunishPlayer(id, reason[])
{
	new name[32]; get_user_name(id, name, charsmax(name));
	client_print(0, print_chat, "[BH Detector] %s using %s", name, reason);
	server_cmd("amx_ban 0 #%d %s", get_user_userid(id), reason);
	
	UTIL_LogUser(id, "using %s", reason);
}
stock UTIL_LogUser(const id, const szCvar[], any:...)
{
	new iFile;
	if( (iFile = fopen(g_szLogFile, "a")) )
	{
		new szName[32], szAuthid[32], szIp[32], szTime[22];
		new message[128]; vformat(message, charsmax(message), szCvar, 3);
		
		get_user_name(id, szName, charsmax(szName));
		get_user_authid(id, szAuthid, charsmax(szAuthid));
		get_user_ip(id, szIp, charsmax(szIp), 1);
		get_time("%m/%d/%Y - %H:%M:%S", szTime, charsmax(szTime));
		
		fprintf(iFile, "L %s: <%s><%s><%s> %s^n", szTime, szName, szAuthid, szIp, message);
		fclose(iFile);
	}
}