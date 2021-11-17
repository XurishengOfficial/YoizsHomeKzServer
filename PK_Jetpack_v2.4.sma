#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "ProKreedz Jetpack"
#define VERSION "v2.4"
#define AUTHOR "vato loco [GE-S]"

#define KZ_ACCESS  ADMIN_KICK		

enum color {normal = 1, green, team}
enum {JETPACK_OFF, JETPACK_RELEASE, JETPACK_ON}

new is_plr_connected[33]
new bool:g_bCanUseJetPack[33]
new g_bJetPack[33]
new g_bPlayerIsAdmin[33]
new g_SpriteSmoke
new g_SpriteTrail
new g_SayText
new g_iMaxPlayers
new g_kz_tag

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Think, "fw_ThinkEnt")
	register_clcmd("+jet", "JetPackOn", KZ_ACCESS)
	register_clcmd("-jet", "JetPackOff", KZ_ACCESS)
	register_clcmd("kz_jetpack", "cmd_give_jetpack", KZ_ACCESS ,"<name|#userid|steamid|@ALL> <on/off>")
	
	register_dictionary("prokreedz_v2.4.txt")
	g_kz_tag = register_cvar("kz_tag", "[ProKreedz]")
	
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString , "info_target"))
	set_pev(iEnt, pev_classname, "jetpack_think")
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	
	g_SayText = get_user_msgid("SayText")
	g_iMaxPlayers = get_maxplayers()
}

public plugin_precache() 
{
	g_SpriteSmoke = engfunc(EngFunc_PrecacheModel, "sprites/portal1.spr")
	g_SpriteTrail = engfunc(EngFunc_PrecacheModel, "sprites/xspark3.spr")
}

public client_putinserver(id) 
{
	is_plr_connected[id] = true
	g_bJetPack[id] = JETPACK_OFF
	if(get_user_flags(id) & KZ_ACCESS) 
		g_bPlayerIsAdmin[id] = true
}

public client_disconnect(id) 
{
	is_plr_connected[id] = false
	g_bJetPack[id] = JETPACK_OFF
	if(g_bPlayerIsAdmin[id]) 
		g_bPlayerIsAdmin[id] = false
}

public kz_prize_jetpack(id, status[])
{
	switch(status[0])
	{
		case '0': g_bCanUseJetPack[id] = false
			
		case '1': 
		{
			g_bCanUseJetPack[id] = true
                        set_task(10.0, "kz_jet_msg", id)
		}
	}
}

public kz_jet_msg(id)
{
	kz_colorchat(id, green, "%L", id, "PKU_JET_PRIZE_CG")
	kz_colorchat(id, green, "%L", id, "PKU_JET_PRIZE")
}

public cmd_give_jetpack(id,level,cid) 
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED
	
	new name[32]
	get_user_name(id,name,31)
	
	new szarg1[32], szarg2[8], bool:mode
	read_argv(1,szarg1,31)
	read_argv(2,szarg2,7)
	if(equal(szarg2,"on"))
		mode = true
	
	if(equal(szarg1,"@ALL")) 
	{
		for(new i = 1; i <= g_iMaxPlayers; i++) 
		{
			if(is_plr_connected[i] && is_user_alive(i)) 
			{
				g_bCanUseJetPack[i] = mode
				if(mode) 
					kz_colorchat(i, green, "%L", i, "PKU_JET_AT_ALL", name)
				else 
					kz_colorchat(i, green, "%L", i, "PKU_JET_TAKE_ALL", name)
			}
		}
	}
	else 
	{
		new pid = cmd_target(id,szarg1,2)
		if(pid > 0) 
		{
			g_bCanUseJetPack[pid] = mode
			if(mode) 
				kz_colorchat(pid, green, "%L", pid, "PKU_JET_AT_TARGET", name)
			else 
				kz_colorchat(pid, green, "%L", pid, "PKU_JET_TAKE_TARGET", name)
		}
	}
	return PLUGIN_HANDLED
}

public JetPackOn(id)  
{
	if(!g_bCanUseJetPack[id] && !g_bPlayerIsAdmin[id])
		return PLUGIN_HANDLED
	
	if(is_plr_connected[id] && is_user_alive(id))
	{
		if(callfunc_begin("DetectCheat","ProKreedz_v2.4.amxx") == 1) 
		{
			callfunc_push_int(id)
			callfunc_push_str("JetPack")
			callfunc_end()
		}
		g_bJetPack[id] = JETPACK_ON
	}
	return PLUGIN_HANDLED
}

public JetPackOff(id) 
{
	g_bJetPack[id] = JETPACK_RELEASE
	return PLUGIN_HANDLED
}

public fw_ThinkEnt(iEnt)
{
	if (pev_valid(iEnt)) 
	{ 
		static ClassName[32]
		pev(iEnt, pev_classname, ClassName, 31)
		
		if(equal(ClassName, "jetpack_think"))
		{
			fw_JetPackThink()
			set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
		}
	}
}

public fw_JetPackThink()
{
	static id, iOrigin[3], Float:fVelocity[3], Float:fsVelocity[3] 
	for(id = 1 ; id <= g_iMaxPlayers ; id++) 
	{
		if(g_bJetPack[id] == JETPACK_ON)
		{
			static Float:maxspeed ; maxspeed = pev(id, pev_maxspeed)*2.0
			
			velocity_by_aim(id, floatround(maxspeed), fsVelocity)
			
			fVelocity[0] = fsVelocity[0]
			fVelocity[1] = fsVelocity[1]
			fVelocity[2] = fsVelocity[2]
			
			set_pev(id, pev_velocity, fVelocity)
			get_user_origin(id, iOrigin, 0)
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_SPRITE)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2] - 10)
			if(g_bPlayerIsAdmin[id])
			{
				write_short(g_SpriteSmoke)
			}
			else
			{
				write_short(g_SpriteTrail)
			}
			write_byte(10)       
			write_byte(150)    
			message_end()
			
			set_pev(id, pev_gaitsequence, 8)
		}
		else if(g_bJetPack[id] == JETPACK_RELEASE)
		{
			g_bJetPack[id] = JETPACK_OFF
		}
	}
}

kz_colorchat(id, color:type, const msg[], {Float,Sql,Result,_}:...) {
	
	static message[256], pkmsg[180], changed[8], argscount,j
	argscount = numargs()
	
	switch(type) 
	{
		case normal: message[0] = 0x01
			
		case green: message[0] = 0x04
			
		default: message[0] = 0x03
		
	}
	new pktag[32]
	get_pcvar_string(g_kz_tag, pktag, 31)
	
	if(id)
	{
		if(is_plr_connected[id])
		{
			vformat(pkmsg, 179, msg, 4)
			formatex(message[1], 255, "%s %s", pktag, pkmsg)
			message[192] = '^0'
			
			replace_all(message, 191, "!g", "^x04")
			replace_all(message, 191, "!n", "^x01")
			replace_all(message, 191, "!t", "^x03")
			kz_print_msg(id, message)
		}
	} 
	else 
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(is_plr_connected[i])
			{
				new changedcount = 0
				
				for(j = 2; j < argscount; j++)
				{
					if(getarg(j) == LANG_PLAYER)
					{
						setarg(j, 0, i);
						changed[changedcount++] = j;
					}
				}
				vformat(pkmsg, 179, msg, 4)
				formatex(message[1], 255, "%s %s", pktag, pkmsg)
				message[192] = '^0'
				
				replace_all(message, 191, "!g", "^x04")
				replace_all(message, 191, "!n", "^x01")
				replace_all(message, 191, "!t", "^x03")
				kz_print_msg(i, message)
				
				for(j = 0; j < changedcount; j++)
				{
					setarg(changed[j], 0, LANG_PLAYER)
				}
			}
		}
	}
}

stock kz_print_msg(id, const msg[])
{
	message_begin(MSG_ONE_UNRELIABLE, g_SayText, _, id)
	write_byte(id)		
	write_string(msg)
	message_end()
}






