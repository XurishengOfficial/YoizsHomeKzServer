#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <engine>
#include <hamsandwich>

#define PLUGIN "StrafeHack Blocker"
#define VERSION "0.8"
#define AUTHOR "Mistrick"

#pragma semicolon 1

#define TASK_TIME 0.2

#define MAX_KEYWARNING 5
#define MAX_PUNISHWARNING 5
#define MAX_ANGLEDIFF 25.0
#define MAX_STRAFES 14

#define LOGFILE "strafehack.log"

#define LEFT 1
#define RIGHT 2

#define FL_ONGROUND2	(FL_ONGROUND|FL_PARTIALGROUND|FL_INWATER|FL_CONVEYOR|FL_FLOAT)

const XO_CBASEPLAYERWEAPON = 4;
const m_pPlayer = 41;

enum _:KEYS
{
	KEY_A, KEY_D, KEY_W, KEY_S
}

enum _:DATA
{
	BUTTON, KEY
}

new g_eInfo[][DATA] = 
{
	{IN_MOVELEFT, KEY_A}, {IN_MOVERIGHT, KEY_D}, {IN_FORWARD, KEY_W}, {IN_BACK, KEY_S}
};

new g_szKeyName[KEYS][] = 
{
	"[A]", "[D]", "[W]", "[S]"
};

static szLogFile[64];

new Float:g_fOldAngles[33][3], /*Float:g_fOldVAngles[33][3],*/ Float:g_fOldUCVAngles[33][3];
new g_iKeyFrames[33][KEYS], g_iOldKeyFrames[33][KEYS], g_iKeyWarning[33][KEYS];
new g_iPunishWarningKeys[33], g_iPunishWarningMove[33];
new bool:g_bTurningLeft[33], bool:g_bTurningRight[33], g_iOldTurning[33], g_iStrafes[33];
new bool:g_bIgnore[33], bool:g_bBanned[33];
new g_iTaskEnt, g_iMaxPlayers;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_CmdStart, "FM_CmdStart_Pre", 0);
	register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_Pre", false);
	register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_Post", true);
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true);
	register_cvar("ac_strafe_punish", "0");
	
	new szWeaponName[32];
	for(new iId = CSW_P228; iId <= CSW_P90; iId++)
	{
		if(get_weaponname(iId, szWeaponName, charsmax(szWeaponName) ))
		{
			RegisterHam(Ham_Item_Deploy, szWeaponName, "Ham_Item_Deploy_Pre", 0);
		}
	}
	
	CreateTask();
	
	g_iMaxPlayers = get_maxplayers();
}
public plugin_cfg()
{
	get_localinfo("amxx_logs", szLogFile, 63);
	new thetime[64];
	get_time("%Y%m%d", thetime, charsmax(thetime));
	format(szLogFile, 63, "/%s/strafehack_%s.log", szLogFile, thetime);
	if (!file_exists(szLogFile))
	{
		write_file(szLogFile, "StrafeHack LogFile");
	}
}
CreateTask()
{
	register_think("task_ent", "Task_StrafesCheck");
	g_iTaskEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	set_pev(g_iTaskEnt, pev_classname, "task_ent");
	set_pev(g_iTaskEnt, pev_nextthink, get_gametime() + 1.01);
}
public client_putinserver(id)
{
	g_bBanned[id] = false;
}
public Ham_PlayerSpawn_Post(id)
{
	g_iPunishWarningKeys[id] = 0;
	g_iPunishWarningMove[id] = 0;
	//g_bIgnore[id] = true;
	//remove_task(id); set_task(0.5, "Task_RemoveIgnore", id);
}
public Task_StrafesCheck(ent)
{
	set_pev(ent, pev_nextthink,  get_gametime() + TASK_TIME);
	new Float:fVelocity[3];
	for(new id = 1; id <= g_iMaxPlayers; id++)
	{
		if(!is_user_alive(id) || is_user_bot(id))
		{
			g_iStrafes[id] = 0;
			continue;
		}
		
		if(g_iStrafes[id] >= MAX_STRAFES)
		{
			pev(id, pev_velocity, fVelocity);
			fVelocity[0] *= 0.2;
			fVelocity[1] *= 0.2;
			set_pev(id, pev_velocity, fVelocity);
			UTIL_LogUser(id, "CheatStrafes: %d strafes in %.1f sec", g_iStrafes[id], TASK_TIME);
			PunishPlayer(id, "CheatStrafes");
		}
		g_iStrafes[id] = 0;
	}
}
public Ham_Item_Deploy_Pre(weapon)
{
	new player = get_pdata_cbase(weapon, m_pPlayer, XO_CBASEPLAYERWEAPON);
	g_bIgnore[player] = true;
	remove_task(player); set_task(0.5, "Task_RemoveIgnore", player);
}
public Task_RemoveIgnore(id)
{
	g_bIgnore[id] = false;
}
public FM_CmdStart_Pre(id, uc_handle, seed)
{
	if(!is_user_alive(id) || g_bIgnore[id] || is_user_bot(id)) return FMRES_IGNORED;		
	
	new iFlags = pev(id, pev_flags);
	new Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
	
	if(iFlags & FL_FROZEN || vector_length(fVelocity) < 100.0) return FMRES_IGNORED;
	
	new bool:bBlockSpeed, iButtons = get_uc(uc_handle, UC_Buttons);
	new Float:fForwardMove; get_uc(uc_handle, UC_ForwardMove, fForwardMove);
	new Float:fSideMove; get_uc(uc_handle, UC_SideMove, fSideMove);
	new Float:fViewAngles[3]; get_uc(uc_handle, UC_ViewAngles, fViewAngles);
	new Float:fValue = floatsqroot(fForwardMove * fForwardMove + fSideMove * fSideMove);
	new Float:fMaxSpeed = get_user_maxspeed(id);
	
	static Float:fAngles[3]; pev(id, pev_angles, fAngles);
	//static Float:fVAngles[3]; pev(id, pev_v_angle, fVAngles);
	static Float:fAnglesDiff[3]; vec_diff(fAnglesDiff, fAngles, g_fOldAngles[id]);
	//static Float:fVAnglesDiff[3]; vec_diff(fVAnglesDiff, fVAngles, g_fOldVAngles[id]);
	static Float:fUCVAnglesDiff[3]; vec_diff(fUCVAnglesDiff, fViewAngles, g_fOldUCVAngles[id]);
	
	if(!(equal_null(fAnglesDiff)/* && equal_null(fVAnglesDiff) && equal_null(fUCVAnglesDiff)*/ && fValue) && ~iFlags & FL_ONGROUND2)
	{
		if((fForwardMove > 0.0 && ~iButtons & IN_FORWARD || fForwardMove < 0.0 && ~iButtons & IN_BACK) && fUCVAnglesDiff[0] != 0.0)
		{
			bBlockSpeed = true;
			UTIL_LogUser(id, "CheatMoves: forward move without button[%.1f]", fForwardMove);
		}
		if(fSideMove > 0.0 && ~iButtons & IN_MOVERIGHT || fSideMove < 0.0 && ~iButtons & IN_MOVELEFT)
		{
			bBlockSpeed = true;
			UTIL_LogUser(id, "CheatMoves: side move without button[%.1f]", fSideMove);
		}
	}
	if(fValue > fMaxSpeed && fMaxSpeed > 100.0)
	{
		bBlockSpeed = true;
		UTIL_LogUser(id, "CheatMoves: value[%.1f], fw[%.1f], sd[%.1f], maxspeed[%.1f]", fValue, fForwardMove, fSideMove, fMaxSpeed);
	}
	if(iButtons & IN_LEFT || iButtons & IN_RIGHT)
	{
		fVelocity[0] *= 0.2;
		fVelocity[1] *= 0.2;
		set_pev(id, pev_velocity, fVelocity);
	}
	/*if(fAnglesDiff[0] > MAX_ANGLEDIFF)
	{
		bBlockSpeed = true;
		UTIL_LogUser(id, "CheatMoves: angles diff[%.1f]", fAnglesDiff[0]);
	}*/
	
	g_bTurningRight[id] = false;
	g_bTurningLeft[id] = false;
	
	if(fAngles[1] < g_fOldAngles[id][1])
	{
		g_bTurningRight[id] = true;
		if(g_iOldTurning[id] == LEFT) g_iStrafes[id]++;
	}
	else if(fAngles[1] > g_fOldAngles[id][1])
	{
		g_bTurningLeft[id] = true;
		if(g_iOldTurning[id] == RIGHT) g_iStrafes[id]++;
	}
	
	if(g_bTurningRight[id]) g_iOldTurning[id] = RIGHT;
	else if(g_bTurningLeft[id]) g_iOldTurning[id] = LEFT;
	
	if(bBlockSpeed)
	{		
		fVelocity[0] *= 0.2;
		fVelocity[1] *= 0.2;
		set_pev(id, pev_velocity, fVelocity);
		
		if(++g_iPunishWarningMove[id] >= MAX_PUNISHWARNING && !g_bBanned[id])
		{
			PunishPlayer(id, "CheatMove");
			g_iPunishWarningMove[id] = 0;
		}
	}
	
	g_fOldAngles[id] = fAngles;
	//g_fOldVAngles[id] = fVAngles;
	g_fOldUCVAngles[id] = fViewAngles;
	
	return FMRES_IGNORED;
}
public FM_PlayerPreThink_Pre(id)
{
	if(!is_user_alive(id) || is_user_bot(id)) return FMRES_IGNORED;
	
	new bool:bOnGround = bool:(pev(id, pev_flags) & FL_ONGROUND);
	
	if(bOnGround) return FMRES_IGNORED;
	
	new bool:bBlockSpeed = false;
	new iButtons; iButtons = pev(id, pev_button);
	new iOldButton; iOldButton = pev(id, pev_oldbuttons);
	
	for(new i; i < sizeof(g_eInfo); i++)
	{
		new CheckButton = g_eInfo[i][BUTTON];
		new CheckKey = g_eInfo[i][KEY];
		
		if(iButtons & CheckButton)
		{
			g_iKeyFrames[id][CheckKey]++;
		}
		
		if(~iButtons & CheckButton && iOldButton & CheckButton)
		{			
			if(g_iKeyFrames[id][CheckKey] == g_iOldKeyFrames[id][CheckKey])
			{
				if(++g_iKeyWarning[id][CheckKey] >= MAX_KEYWARNING)
				{
					bBlockSpeed = true;
					UTIL_LogUser(id, "CheatKeys: keyframe agreement[%d], key %s", g_iKeyFrames[id][CheckKey], g_szKeyName[CheckKey]);
				}			
			}
			else
			{
				g_iKeyWarning[id][CheckKey] = 0;
			}
			//console_print(id, "key frame%s is %d", g_szKeyName[CheckKey], g_iKeyFrames[id][CheckKey]);
			g_iOldKeyFrames[id][CheckKey] = g_iKeyFrames[id][CheckKey];
			g_iKeyFrames[id][CheckKey] = 0;
		}
	}
			
	if(bBlockSpeed)
	{
		new Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
		fVelocity[0] *= 0.2;
		fVelocity[1] *= 0.2;
		set_pev(id, pev_velocity, fVelocity);
		
		if(++g_iPunishWarningKeys[id] >= MAX_PUNISHWARNING)
		{
			PunishPlayer(id, "CheatKeys");
			g_iPunishWarningKeys[id] = 0;
		}
	}
	
	return FMRES_IGNORED;
}
stock PunishPlayer(id, reason[])
{
	g_bBanned[id] = true;
	new punishType = get_cvar_num("ac_strafe_punish");
	switch(punishType)
	{
		case 0:
		{
			server_cmd("amx_kick #%d %s", get_user_userid(id), reason);
		}
		case 1:
		{
			server_cmd("amx_ban 0 #%d %s", get_user_userid(id), reason);
		}
		default:
		{
		}
	}
}
vec_diff(Float:vec[3], Float:new_vec[3], Float:old_vec[3])
{
	vec[0] = floatabs(new_vec[0] - old_vec[0]);
	vec[1] = floatabs(new_vec[1] - old_vec[1]);
	vec[2] = floatabs(new_vec[2] - old_vec[2]);
}
equal_null(Float:vec[3])
{
	return (vec[0] == 0.0 && vec[1] == 0.0) ? true : false;
}
public UTIL_LogUser(const id, const szCvar[], any:...)
{
	new iFile;
	if( (iFile = fopen(szLogFile, "a")) )
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
stock show_status(id, const szMsg[], any:...)
{
	new szStatus[128]; vformat(szStatus, 127, szMsg, 3);
	
	static msgStatusText=0;
	if(!msgStatusText) msgStatusText = get_user_msgid("StatusText");
		
	message_begin(MSG_ONE_UNRELIABLE, msgStatusText, _, id);
	write_byte(0);
	write_string(szStatus);
	message_end();
}
