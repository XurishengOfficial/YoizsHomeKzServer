#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "ProKreedz Hook"
#define VERSION "v2.4"
#define AUTHOR "vato loco [GE-S] & p4ddY"

#define KZ_ACCESS  ADMIN_KICK
#define RANDOM_NUM random_num(0,255)
#define RED        255
#define GREEN      99
#define	BLUE	   71

enum color {normal = 1, green, team}
enum {HOOK_OFF, HOOK_RELEASE, HOOK_ON}

new is_plr_connected[33]
new bool:g_bCanUseHook[33]
new g_bIsHooked[33]
new g_iHookOrigin[33][3]
new g_bPlayerIsAdmin[33]
new g_SpriteBeam
new g_SpriteLaser
new g_SayText
new g_iMaxPlayers
new g_kz_tag

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Think, "fw_ThinkEnt")
	register_clcmd("+hook", "HookOn", KZ_ACCESS)
	register_clcmd("-hook", "HookOff", KZ_ACCESS)
	register_clcmd("kz_hook", "cmd_give_hook", KZ_ACCESS ,"<name|#userid|steamid|@ALL> <on/off>")
	
	register_dictionary("prokreedz_v2.4.txt")
	g_kz_tag = register_cvar("kz_tag", "[ProKreedz]")
	
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString , "info_target"))
	set_pev(iEnt, pev_classname, "hook_think")
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	
	g_SayText = get_user_msgid("SayText")
	g_iMaxPlayers = get_maxplayers()
}

public plugin_precache() 
{
	g_SpriteBeam = engfunc(EngFunc_PrecacheModel, "sprites/lgtning.spr")
	g_SpriteLaser = engfunc(EngFunc_PrecacheModel,"sprites/zbeam4.spr")
}

public client_putinserver(id) 
{
	is_plr_connected[id] = true
	g_bIsHooked[id] = HOOK_OFF
	if(get_user_flags(id) & KZ_ACCESS) 
		g_bPlayerIsAdmin[id] = true
}

public client_disconnect(id) 
{
	is_plr_connected[id] = false
	g_bIsHooked[id] = HOOK_OFF
	if(g_bPlayerIsAdmin[id]) 
		g_bPlayerIsAdmin[id] = false
}

public kz_prize_hook(id, status[])
{
	switch(status[0])
	{
		case '0': g_bCanUseHook[id] = false
			
		case '1': 
		{
			g_bCanUseHook[id] = true
			set_task(5.0, "kz_hook_msg", id)
		}
	}
}

public kz_hook_msg(id)
{
        kz_colorchat(id, green, "%L", id, "PKU_PRIZE_HOOK")
}

public cmd_give_hook(id,level,cid) 
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
				g_bCanUseHook[i] = mode
				if(mode) 
					kz_colorchat(i, green, "%L", i, "PKU_HOOK_AT_ALL", name)
				else 
					kz_colorchat(i, green, "%L", i, "PKU_HOOK_TAKE_ALL", name)
			}
		}
	}
	else 
	{
		new pid = cmd_target(id,szarg1,2)
		if(pid > 0) 
		{
			g_bCanUseHook[pid] = mode
			if(mode) 
				kz_colorchat(pid, green, "%L", pid, "PKU_HOOK_AT_TARGET", name)
			else 
				kz_colorchat(pid, green, "%L", pid, "PKU_HOOK_TAKE_TARGET", name)
		}
	}
	return PLUGIN_HANDLED
}

public HookOn(id)  
{
	if(!g_bCanUseHook[id] && !g_bPlayerIsAdmin[id])
		return PLUGIN_HANDLED
	
	if(is_plr_connected[id] && is_user_alive(id))
	{
		get_user_origin(id, g_iHookOrigin[id], 3)
		
		if(callfunc_begin("DetectCheat","ProKreedz_v2.4.amxx") == 1) 
		{
			callfunc_push_int(id)
			callfunc_push_str("Hook")
			callfunc_end()
		}
		g_bIsHooked[id] = HOOK_ON
	}
	return PLUGIN_HANDLED
}

public HookOff(id) 
{
	g_bIsHooked[id] = HOOK_RELEASE
	return PLUGIN_HANDLED
}

public fw_ThinkEnt(iEnt)
{
	if (pev_valid(iEnt)) 
	{ 
		static ClassName[32]
		pev(iEnt, pev_classname, ClassName, 31)
		
		if(equal(ClassName, "hook_think"))
		{
			fw_HookThink()
			set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
		}
	}
}

public fw_HookThink()
{
	static id, origin[3], Float:velocity[3], distance
	for(id = 1 ; id <= g_iMaxPlayers ; id++) 
	{
		if(g_bIsHooked[id] == HOOK_ON)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(1)			  // TE_BEAMENTPOINT
			write_short(id)			  // entid
			write_coord(g_iHookOrigin[id][0]) // origin
			write_coord(g_iHookOrigin[id][1]) // origin
			write_coord(g_iHookOrigin[id][2]) // origin
			if(g_bPlayerIsAdmin[id])
			{
				write_short(g_SpriteBeam)	  // sprite index
				write_byte(0)			  // start frame
				write_byte(0)			  // framerate
				write_byte(2)			  // life
				write_byte(20)			  // width
				write_byte(0)
				write_byte(RANDOM_NUM) // r
				write_byte(RANDOM_NUM) // g
				write_byte(RANDOM_NUM) // b
			}
			else 
			{
				write_short(g_SpriteLaser)	  // sprite index
				write_byte(0)			  // start frame
				write_byte(0)			  // framerate
				write_byte(2)			  // life
				write_byte(10)			  // width
				write_byte(0)
				write_byte(RED)	       // r
				write_byte(GREEN)      // g
				write_byte(BLUE)       // b
			}
			write_byte(150)			       // brightness
			write_byte(0)			       // speed
			message_end()
			
			get_user_origin(id, origin)
			distance = get_distance(g_iHookOrigin[id], origin)
			if(distance > 25)  
			{ 
				velocity[0] = (g_iHookOrigin[id][0] - origin[0]) * (2.0 * 350 / distance)
				velocity[1] = (g_iHookOrigin[id][1] - origin[1]) * (2.0 * 350 / distance)
				velocity[2] = (g_iHookOrigin[id][2] - origin[2]) * (2.0 * 350 / distance)
				set_pev(id, pev_velocity, velocity)
			}
		}
		else if(g_bIsHooked[id] == HOOK_RELEASE)
		{
			g_bIsHooked[id] = HOOK_OFF
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







