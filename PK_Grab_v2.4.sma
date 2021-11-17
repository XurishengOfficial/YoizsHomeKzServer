#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "ProKreedz Grab"
#define VERSION "v2.4"
#define AUTHOR "vato loco [GE-S] & p4ddY"

#define KZ_ACCESS   ADMIN_KICK
#define MIN_DIST    70.0
#define THROW_POWER 1500

enum color {normal = 1, green, team}
enum {GRAB_OFF, GRAB_ON, GRAB_RELEASE, GRAB_SEARCH}

new is_plr_connected[33]
new Float:g_fGrabDistance[33]
new g_iGrab[33]
new g_bGrabSearch[33]
new g_bPlayerIsAdmin[33]
new g_SayText
new g_iMaxPlayers
new g_kz_tag

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1)
	RegisterHam(Ham_Player_PreThink, "player", "fw_PlayerPreThink")
	register_clcmd("+grab", "GrabOn", KZ_ACCESS)
	register_clcmd("-grab", "GrabOff", KZ_ACCESS)
	
	register_dictionary("prokreedz_v2.4.txt")
	g_kz_tag = register_cvar("kz_tag", "[ProKreedz]")
	
	g_SayText = get_user_msgid("SayText")
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(id) 
{
	if (get_user_flags(id) & KZ_ACCESS) 
		g_bPlayerIsAdmin[id] = true
	is_plr_connected[id] = true
	g_bGrabSearch[id] = GRAB_OFF
	g_iGrab[id] = 0
}

public client_disconnect(id) 
{
	if(g_bPlayerIsAdmin[id])
		g_bPlayerIsAdmin[id] = false
	is_plr_connected[id] = false
	g_bGrabSearch[id] = GRAB_OFF
	g_iGrab[id] = 0
}

public GrabOn(id) 
{
	if(!g_bPlayerIsAdmin[id]) 
		return PLUGIN_HANDLED
	
	g_bGrabSearch[id] = GRAB_SEARCH
	
	return PLUGIN_HANDLED
}

public GrabOff(id) 
{
	if(!g_bPlayerIsAdmin[id]) 
		return PLUGIN_HANDLED
	
	g_bGrabSearch[id] = GRAB_RELEASE
	
	return PLUGIN_HANDLED
}

public GrapPlayer(id, target) 
{
	if(!is_user_alive(id))
                return
        
        new Float:origin1[3], Float:origin2[3], szName[32]
	g_iGrab[id] =  target
	g_bGrabSearch[id] = GRAB_ON
	pev(id, pev_origin, origin1)
	pev(target, pev_origin, origin2)
	g_fGrabDistance[id] = get_distance_f(origin1, origin2)
	if(!g_bPlayerIsAdmin[target])
		set_rendering(target, kRenderFxGlowShell, 50, 0, 0,kRenderNormal, 16)
	get_user_name(target, szName, 31)
	kz_colorchat(id, green, "%L", id, "PKU_GRAB_TARGET", szName)
	if(callfunc_begin("DetectCheat","ProKreedz_v2.4.amxx") == 1) 
	{
		callfunc_push_int(target)
		callfunc_push_str("Grab")
		callfunc_end()
	}
}

public is_plr_grabbed(id) 
{
	static i
	for(i = 1; i <= g_iMaxPlayers; i++) 
	{
		if(g_iGrab[i] == id)
			return i
	}
	return 1
}

public fw_PlayerSpawn(id)
{
	if(is_user_alive(id))
	{
		if(g_bGrabSearch[id] == GRAB_ON)
			g_bGrabSearch[id] = GRAB_RELEASE 
	}
}

public fw_PlayerPreThink(id) 
{
	static Buttons 
	Buttons = pev(id, pev_button)
	if(!is_user_alive(id))
	{
		if(g_bGrabSearch[id] == GRAB_ON)
			g_bGrabSearch[id] = GRAB_RELEASE 
	}
	if(g_bGrabSearch[id] == GRAB_SEARCH) 
	{
		new aimid, aimbody
		if(get_user_aiming(id, aimid, aimbody) != 0.0 && aimid != 0) 
		{
			new targetclass[16]
			pev(aimid, pev_classname, targetclass, 15)
			if(equal(targetclass,"player")) 
			{
				if(is_plr_grabbed(aimid) == 1)
					GrapPlayer(id,aimid)
				else 
				{
					kz_colorchat(id, green, "%L", id, "PKU_GRAB_ALREADY")
					g_bGrabSearch[id] = GRAB_OFF
				}
			}
		}
	}
	else if(g_bGrabSearch[id] == GRAB_ON) 
	{ 
		if(g_iGrab[id] > 0)
		{
			if(!is_user_alive(g_iGrab[id]))
				g_bGrabSearch[id] = GRAB_RELEASE
			
			static Float:origin1[3], Float:origin2[3], ilook[3], Float:look[3], Float:direction[3], Float:moveto[3], Float:grabbedorigin[3], Float:velocity[3], Float:length
			get_user_origin(id, ilook, 3)
			IVecFVec(ilook, look)
			pev(g_iGrab[id], pev_origin, grabbedorigin)
			
			pev(id, pev_origin, origin1)
			pev(g_iGrab[id], pev_origin, origin2)
			
			direction[0] = look[0] - origin1[0]
			direction[1] = look[1] - origin1[1]
			direction[2] = look[2] - origin1[2]
			length = get_distance_f(look, origin1)
			if(!length)
				length = 1.0 
			
			moveto[0] = origin1[0] + direction[0] * g_fGrabDistance[id] / length
			moveto[1] = origin1[1] + direction[1] * g_fGrabDistance[id] / length
			moveto[2] = origin1[2] + direction[2] * g_fGrabDistance[id] / length
			
			velocity[0] = (moveto[0] - origin2[0]) * 8
			velocity[1] = (moveto[1] - origin2[1]) * 8
			velocity[2] = (moveto[2] - origin2[2]) * 8
			
			set_pev(g_iGrab[id], pev_velocity, velocity)
			
			if(Buttons & IN_ATTACK) 
			{
				set_pev(id, pev_button, Buttons & ~IN_ATTACK)
				g_fGrabDistance[id] += 7
			}
			else if(Buttons & IN_ATTACK2) 
			{
				set_pev(id, pev_button, Buttons & ~IN_ATTACK2)
				g_fGrabDistance[id] -= 7
				if(g_fGrabDistance[id] < MIN_DIST)
					g_fGrabDistance[id] = MIN_DIST
			}
			else if(Buttons & IN_JUMP) 
			{
				set_pev(id, pev_button, Buttons & ~IN_JUMP)
				velocity_by_aim(id, THROW_POWER, velocity)
				set_pev(g_iGrab[id], pev_velocity, velocity)
				g_bGrabSearch[id] = GRAB_RELEASE
			}
		}
	}
	else if(g_bGrabSearch[id] == GRAB_RELEASE)
	{
		if(!g_bPlayerIsAdmin[g_iGrab[id]])
			set_rendering(g_iGrab[id])
		g_iGrab[id] = 0
		g_bGrabSearch[id] = GRAB_OFF
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





