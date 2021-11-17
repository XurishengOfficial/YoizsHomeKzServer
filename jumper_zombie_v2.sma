#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <zombieplague>

new _gJumpCount[33]
new cvar_multi_jump_amount
new g_zclass_jumper

new const zclass_name[] = {"Jumper"} 
new const zclass_info[] = {"Double Jump"} 
new const zclass_model[] = {"zombie_source"} 
new const zclass_clawmodel[] = {"v_knife_zombie.mdl"}
const zclass_health = 4500 
const zclass_speed = 269 
const Float:zclass_gravity = 0.7 
const Float:zclass_knockback = 1.3 

public plugin_init() 
{
	register_plugin("[ZP] Zombie Class: Jumper", "1.0", "zmd94")
	RegisterHam(Ham_Player_Jump, "player", "fw_PlayerJump", 0)
	
	cvar_multi_jump_amount = register_cvar("zp_multi_jump_amount", "1")
}

public plugin_precache()
{
    g_zclass_jumper = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
}

public fw_PlayerJump(id) 
{
	if(!is_user_alive(id) || !zp_get_user_zombie(id))
	{
		return HAM_IGNORED
	}  
	if(zp_get_user_zombie_class(id) == g_zclass_jumper) 
	{
		new Flags = pev(id, pev_flags)
		
		if( Flags & FL_WATERJUMP || pev(id, pev_waterlevel) >= 2 || !(get_pdata_int(id, 246) & IN_JUMP) )
		{
			return HAM_IGNORED
		}
		if(Flags & FL_ONGROUND) 
		{
			_gJumpCount[id] = 0
			return HAM_IGNORED
		}
		if(get_pcvar_num(cvar_multi_jump_amount)) 
		{
			if( get_pdata_float(id, 251) < 500 && ++_gJumpCount[id] <= get_pcvar_num(cvar_multi_jump_amount)) 
			{
				new Float:fVelocity[3]
				pev(id, pev_velocity, fVelocity)
				fVelocity[2] = 268.328157
				set_pev(id, pev_velocity, fVelocity)
				
				return HAM_HANDLED
			}
		}
	}
	return HAM_IGNORED
}