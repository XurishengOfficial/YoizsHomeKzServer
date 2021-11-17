/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <fakemeta_util>
#include <xs>
#include <maths>
#include <cshack>
#include <dhudmessage>
#include <hamsandwich>

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

new BUYZONECLASS[] = "func_buyzone"

new stuck[33]

#define AUTO_TEAM_JOIN_DELAY 0.1
#define TEAM_SELECT_VGUI_MENU_ID 2

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

new mode[33], stoping, viewspeed, flashtg[33]
new gEnergy[33], showplayer[33], Float:wait_ghostsd[33]
new ghostspr, flashspr, setvgb[33], Float:utime[33]
new r_bot, checkzb, g_msgFlashBat, g_msgFlashlight, flashlight_decay
new playershow[33], setinv[33], showpc[33], Float:xtime[33], Float:ftime[33]
new timer[33], Save_See[33], Float:ptime[33], knifedmg, iszb[33]
new Float:VisOffset[33], ghostnext_attack, Float:itime[33], RoundCount, g_attacking[33]
new dmg3, ghostnext_attack2


new g_pcvar_team
new g_pcvar_class
new g_pcvar_imm

#define CT_FOG 0.002
#define T_FOG 0.0005

new amx_gamename



public plugin_init()
{
	RegisterHam(Ham_Killed, "player", "Inven_Player")
	RegisterHam(Ham_Spawn, "player", "Inven_Player_Spawn", 1)
	RegisterHam(Ham_CS_RoundRespawn, "player", "NewSpawn")
	RegisterHam(Ham_Touch, "weaponbox", "Block_Touch")
	RegisterHam(Ham_Touch, "func_buyzone", "BuyZone_BlockTouch")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_Deploy_Knife", 1)
	register_forward(FM_ClientKill, "Forward_ClientKill" );
	register_forward(FM_EmitSound, "FlyGhost_Sound")

	set_task(0.1,"checkstuck",0,"",0,"b")
	
	register_message(get_user_msgid("ResetHUD"), "msgResetHUD")
	register_message(get_user_msgid("Flashlight"), "msgFlashlight")
	
	/*
	register_event("TeamInfo", "event_TeamInfo", "a");
	register_message(get_user_msgid("ShowMenu"), "message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu");
	*/
	
	register_forward(FM_TraceLine, "fw_TraceLine") //线
	register_forward(FM_TraceHull, "fw_TraceHull") //hull
	
	register_forward(FM_SetModel, "Grenade_Remove")
	register_forward(FM_ClientCommand, "fw_ClientCommand")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	//RegisterHam(Ham_TraceAttack, "player", "fw_PlayerTraceAttack")
	register_forward(FM_PlayerPreThink, "FM_Player_PostThink")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_message(get_user_msgid("StatusIcon"),	"message_StatusIcon")
	register_impulse(100, "Block_FlashLight")
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_PlayerTakeDmg")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Knife_Attack1")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Knife_Attack1_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Knife_Attack2")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Knife_Attack2_Post", 1)

	knifedmg = register_cvar("ghost_knifedmg", "10.0") //女鬼左键攻击伤害
	stoping = register_cvar("ghost_stop", "100.0") //
	dmg3 = register_cvar("ghost_knifedmg2", "19.0") //女鬼右键攻击伤害
	ghostnext_attack2 = register_cvar("ghost_nextattack2", "0.8") //女鬼爪子右键攻击速度
	ghostnext_attack = register_cvar("ghost_nextattack", "0.5") //女鬼近战武器攻击速度
	viewspeed = register_cvar("viewspeed", "350.0") //女鬼飞行速度
	flashlight_decay = register_cvar("flashlight_decay","999") //手电亮度减小（越高越小）

	register_clcmd("lastinv", "hook_inv")
	register_clcmd("fullupdate", "clcmd_fullupdate")
	register_clcmd("buy", "buy_block")
	register_clcmd("buyz", "buy_cmdto")
	register_clcmd("say /buy", "buy_zone")
}

public Knife_Attack1_Post(ent)
{
	if(!pev_valid(ent)) return
	
	new id = pev(ent, pev_owner)
	if(get_team(id) == 1 || iszb[id]) g_attacking[id] = 0
}

stock get_team(id) return get_pdata_int(id, 114, 5)

public Knife_Attack2_Post(ent)
{
	if(!pev_valid(ent)) return
	
	new id = pev(ent, pev_owner)
	if(get_team(id) == 1 || iszb[id]) g_attacking[id] = 0
}

public fw_TraceLine(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, handle)
{
	// Not alive
	if (!is_user_alive(id))
	return FMRES_IGNORED;
	
	// Not using knife
	if (get_user_weapon(id) != CSW_KNIFE || !iszb[id] || get_team(id) != 1)
		return FMRES_IGNORED;
	
	// Not attacking
	if (!g_attacking[id])
	return FMRES_IGNORED;
	
	pev(id, pev_v_angle, vector_end)
	angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
	
	if(g_attacking[id]==1) //左键攻击距离
	xs_vec_mul_scalar(vector_end, 83.0, vector_end)
	else if(g_attacking[id]==2) //右键攻击距离
	xs_vec_mul_scalar(vector_end, 65.0, vector_end)
	
	xs_vec_add(vector_start, vector_end, vector_end)
	engfunc(EngFunc_TraceLine, vector_start, vector_end, DONT_IGNORE_MONSTERS, id, handle)
	
	return FMRES_SUPERCEDE;
}

public fw_TraceHull(Float:vector_start[3], Float:vector_end[3], ignored_monster, hull, id, handle)
{
	if (!is_user_alive(id))
	return FMRES_IGNORED;
	
	if (get_user_weapon(id) != CSW_KNIFE || !iszb[id] || get_team(id) != 1)
	return FMRES_IGNORED;

	if (!g_attacking[id])
	return FMRES_IGNORED;
	
	pev(id, pev_v_angle, vector_end)
	angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
	
	if(g_attacking[id]==1) //左键攻击距离
	xs_vec_mul_scalar(vector_end, 83.0, vector_end)
	else if(g_attacking[id]==2) //右键攻击距离
	xs_vec_mul_scalar(vector_end, 65.0, vector_end)
	
	xs_vec_add(vector_start, vector_end, vector_end)
	engfunc(EngFunc_TraceLine, vector_start, vector_end, DONT_IGNORE_MONSTERS, id, handle)
	
	return FMRES_SUPERCEDE;
}

public buy_block(id)
{
	if(timer[id] || checkzb) return PLUGIN_CONTINUE
	show_dhud(id, "你已经不能购买任何武器了。")
	return PLUGIN_HANDLED
}

public buy_cmdto(id)
{
	if(!timer[id] || checkzb)
	{
		show_dhud(id, "你已经不能购买任何武器了。")
		return PLUGIN_CONTINUE
	}
	
	set_task(0.1, "Task_ClientBuyCmd", id)
	
	return PLUGIN_HANDLED
}
public Task_ClientBuyCmd(id)
{
	client_cmd(id, "buy")
}

public buy_zone(id)
{
	new Float:absmin[3] = {-8191.0, -8191.0, -8191.0}
	new Float:absmax[3] = {8191.0, 8191.0, 8191.0}

	new buyzone
	//if (!(buyzone = find_ent_by_class(buyzone, BUYZONECLASS))) // is the map have "func_buyzone"?
	buyzone = create_entity("func_buyzone") // we create one when no buyzone here 

	DispatchSpawn(buyzone)
	entity_set_size(buyzone, absmin, absmax) // set it max size of map let player always touch it
}

public BuyZone_BlockTouch(ent, id)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	if(!is_user_alive(id) || timer[id] || !checkzb) return HAM_IGNORED
	//show_dhud(id, "你不在购买区，无法购买武器。+")
	return HAM_SUPERCEDE
}

public plugin_precache()
{
	precache_model("models/player/flyghost/flyghost.mdl")
	precache_model("models/v_knife.mdl")
	
	precache_sound("zbdm/zombi_attack_1.wav")
	precache_sound("zbdm/zombi_attack_2.wav")
	precache_sound("zbdm/zombi_attack_3.wav")
	
	precache_sound("zbdm/zombi_swing_1.wav")
	precache_sound("zbdm/zombi_swing_2.wav")
	precache_sound("zbdm/zombi_swing_3.wav")
	
	precache_sound("zbdm/zombi_wall_1.wav")
	precache_sound("zbdm/zombi_wall_2.wav")
	precache_sound("zbdm/zombi_wall_3.wav")
	
	precache_sound("zbdm/zombi_death_female_1.wav")
	precache_sound("zbdm/zombi_death_female_2.wav")
	
	precache_sound("zbdm/zombi_heal_female.wav")
	
	precache_sound("zbdm/count/1.wav")
	precache_sound("zbdm/count/2.wav")
	precache_sound("zbdm/count/3.wav")
	precache_sound("zbdm/count/4.wav")
	precache_sound("zbdm/count/5.wav")
	precache_sound("zbdm/count/6.wav")
	precache_sound("zbdm/count/7.wav")
	precache_sound("zbdm/count/8.wav")
	precache_sound("zbdm/count/9.wav")
	precache_sound("zbdm/count/10.wav")
}

public menu_block(id)
{
	if (timer[id] <= 0 && RoundCount && checkzb)
	return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public clcmd_fullupdate() {
	return PLUGIN_HANDLED
}

stock is_alive(id) return is_user_alive(id)

public fw_Deploy_Knife(iEntity)
{
	static id
	id = get_pdata_cbase(iEntity, 41, 4)
	
	if(is_alive(id))
	{
		if(get_team(id) == 1 && iszb[id])
		{
			set_pev(id, pev_viewmodel2, "models/v_knife.mdl") //V模型
			set_pev(id, pev_weaponmodel2, "") //P模型
		}
		if(get_team(id) == 2)
		{
			set_pev(id, pev_viewmodel2, "models/v_knife.mdl") //V模型
			set_pev(id, pev_weaponmodel2, "models/p_knife.mdl") //P模型
		}
	}
}

//屏蔽手电筒（幽灵无法开灯）
public Block_FlashLight(id)
{
	if(!is_alive(id)) return HAM_IGNORED
	if(get_team(id) != 2 && !flashtg[id] && iszb[id])
	return HAM_SUPERCEDE
	
	return PLUGIN_CONTINUE
}

//HOOK Q键
public hook_inv(id)
{
	if(get_team(id) == 1 && get_user_weapon(id) == CSW_KNIFE && iszb[id])
	{
		if(!mode[id])
		{
			mode[id] = 1
			client_print(id, print_center, "已开启浮空模式。")
		}
		else
		{
			mode[id] = 0
			set_pev(id, pev_gravity, 1.0)
			set_pev(id, pev_maxspeed, 300.0)
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			set_pdata_float(id, 108, 1.0)
			
			client_print(id, print_center, "恢复到行走模式。")
		}
		
		return HAM_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public Task_TipShow(id)
{
	if(!is_user_connected(id)) return
	
	set_dhudmessage(random_num(100, 255), random_num(100, 255), random_num(100, 255), -1.0, 0.32, 0, 6.0, 3.0)
	//show_dhudmessage(id, "用手电筒照出恶灵并消灭他们!")
}

//女鬼的近身攻击延迟
public Knife_Attack1(ent)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	
	new id = pev(ent, pev_owner)
	if(ptime[id] >= get_gametime()) return HAM_SUPERCEDE
	
	if(get_pdata_int(id, 114, 5) == 1 && iszb[id])
	{
		g_attacking[id] = 1
		ptime[id] = get_gametime() + get_pcvar_float(ghostnext_attack)
		set_nkattack(id, get_pcvar_float(ghostnext_attack))
		return HAM_IGNORED
	}
	
	return HAM_IGNORED
}

stock gtm(id) return get_team(id)

stock set_nkattack(id, Float:xtime, const modex = 0, const moder = 0)
{
	if(!is_user_alive(id))
	return
	
	new ent = get_pdata_cbase(id, 373)
	
	if(pev_valid(ent))
	{
		if(!modex) set_pdata_float(ent, 48, xtime + 1.0, 4)
		else set_pdata_float(ent, 48, xtime, 4)
		
		if(moder)
		{
			set_pdata_float(ent, 46, xtime, 4)
			set_pdata_float(ent, 47, xtime, 4)
		}
	}
	
	set_pdata_float(id, 83, xtime, 5)
}

//女鬼的近身攻击延迟
public Knife_Attack2(ent)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	
	new id = pev(ent, pev_owner)
	if(ptime[id] >= get_gametime()) return HAM_SUPERCEDE
	
	if(get_pdata_int(id, 114, 5) == 1 && iszb[id])
	{
		g_attacking[id] = 2
		ptime[id] = get_gametime() + get_pcvar_float(ghostnext_attack2)
		set_nkattack(id, get_pcvar_float(ghostnext_attack2))
		return HAM_IGNORED
	}
	
	return HAM_IGNORED
}


//女鬼不能捡起武器
public Block_Touch(ent, id)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	
	if(is_user_alive(id))
	if(get_pdata_int(id, 114, 5) != 1 || !iszb[id]) return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

//判断是不是开启了手电筒
public msgFlashlight(msg_id, msg_dest, msg_entity)
{
	if(is_user_alive(msg_entity))
	{
		if(gtm(msg_entity) != 2 || iszb[msg_entity]) return HAM_SUPERCEDE
		
		if(get_msg_arg_int(1) && !flashtg[msg_entity])
		{
			flashtg[msg_entity] = 1
		}
		else
		{
			set_msg_arg_int(1, get_msg_argtype(1), 0)
			flashtg[msg_entity] = 0
		}
		
		set_pev(msg_entity, pev_effects, pev(msg_entity, pev_effects) & ~EF_DIMLIGHT)
	}
	
	return PLUGIN_CONTINUE
}

//刀子的伤害不能太高对吧
public Ham_PlayerTakeDmg(vic, inf, attacker, Float:damage)
{
	if(!is_user_alive(vic) || !is_user_alive(attacker)) return HAM_IGNORED

	if (vic != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_KNIFE && (get_team(attacker) == 1 && get_team(vic) == 2)) 
		{
			new Float:newdmg2 = get_pcvar_float(knifedmg)
			new Float:newdmg5 = get_pcvar_float(dmg3)
			
			if(iszb[attacker])
			{
				if(g_attacking[attacker] == 1) SetHamParamFloat(4, 10.0)
				if(g_attacking[attacker] == 2) SetHamParamFloat(4, 13.0)
				
				/*
				SetHamParamFloat(4, 1.0)
				
				cs_set_user_model(vic, "flyghost")
				change_team(vic, 1)
				iszb[vic] = 1
				fm_strip_user_weapons(vic)
				fm_give_item(vic, "weapon_knife")
				//engclient_cmd(vic, "weapon_knife")
					
				if(get_user_weapon(vic) == CSW_KNIFE)
				{
					set_pev(vic, pev_viewmodel2, "models/v_knife.mdl") //V模型
					set_pev(vic, pev_weaponmodel2, "") //P模型
				}
			
				set_pev(vic, pev_weaponmodel2, "")
				set_pev(vic, pev_health, 255.0)
				set_pev(vic, pev_takedamage, 1.0)
				//set_pev(rp, pev_solid, SOLID_BBOX)
				SetEnvFog(vic, 28, 28, 28, T_FOG, false) 
				mode[vic] = 1
					
				hui_playsd(vic, "zbdm/zombi_heal_female.wav")
				*/
					
				//return HAM_SUPERCEDE
				
			}
		}
		if(get_team(attacker) == 2 && (get_team(vic) == 1 || iszb[vic]) )
		{
			set_pdata_float(vic, 108, 1.0)
		}
	}
	
	return HAM_IGNORED
}

VicThan(attacker, vic)
{
	message_begin(MSG_ALL, get_user_msgid("DeathMsg"))
	write_byte(attacker) // killer
	write_byte(vic) // victim
	write_byte(0) // headshot flag
	write_string("knife") // killer's weapon
	message_end()
}

public NewSpawn(id)
{
	if(!is_user_connected(id)) return
	
	RoundCount += 1
	
	change_team(id, 2)
	cs_set_user_model(id, "sas")
}

change_team(id, zbs)
{
	new team = get_pdata_int(id, 114, 5)
	
	if(zbs == 2)
	{
		set_pdata_int(id, 114, 2)
		message_begin(MSG_ALL, get_user_msgid("TeamInfo"))
		write_byte(id)
		write_string("CT")
		message_end()
	}
	else if(zbs == 1)
	{
		set_pdata_int(id, 114, 1)
		message_begin(MSG_ALL, get_user_msgid("TeamInfo"))
		write_byte(id)
		write_string("TERRORIST")
		message_end()
	}
}


public Event_NewRound()
{
	for(new i=1; i<=32 ;i++)
	{
		if(!is_user_connected(i)) continue
		if(get_team(i) != 2) change_team(i, 2)
		if(iszb[i] != 0) iszb[i] = 0
		
		timer[i] = 20
		checkzb = 0
		
		set_pev(i, pev_gravity, 1.0)
		ExecuteHamB(Ham_Player_ResetMaxSpeed, i)
	}
	
	new Float:absmin[3] = {-8191.0, -8191.0, -8191.0}
	new Float:absmax[3] = {8191.0, 8191.0, 8191.0}

	new buyzone
	//if (!(buyzone = find_ent_by_class(buyzone, BUYZONECLASS))) // is the map have "func_buyzone"?
	buyzone = create_entity(BUYZONECLASS) // we create one when no buyzone here 

	DispatchSpawn(buyzone)
	entity_set_size(buyzone, absmin, absmax) // set it max size of map let player always touch it
}

stock get_ctnum()
{
	new pl = 0
	for(new i=1;i<=32;i++)
	{
		if(!is_user_alive(i) || !is_user_connected(i)) continue
		if(get_pdata_int(i, 114, 5) != 2) continue
		
		pl ++
	}
	
	return pl
	
}

stock get_allnum()
{
	new pl = 0
	for(new i=1;i<=32;i++)
	{
		if(!is_alive(i)) continue
		if(!get_pdata_int(i, 114, 5)) continue
		
		pl ++
	}
	
	return pl
	
}

stock get_tnum()
{
	new pl = 0
	for(new i=1;i<=32;i++)
	{
		if(!is_user_connected(i)) continue
		if(get_pdata_int(i, 114, 5) != 1) continue
		
		pl ++
	}
	
	return pl
}

// stocks
stock samurai_create_ent(const classname[])
{
    // return create a entity called "classname"
    return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname));
}

stock hui_playsd(id, sounlist[], const weaponmod = 0)
{
	if(!weaponmod)
	engfunc(EngFunc_EmitSound, id, CHAN_VOICE, sounlist, 1.0, ATTN_NORM, 0, PITCH_NORM)
	else engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, sounlist, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

//玩家被女鬼感染（玩家被女鬼杀死的时候）
public Inven_Player(id, attacker)
{
	if(!is_user_connected(id)) return HAM_IGNORED
	
	if(get_team(attacker) == 1 && get_team(id) == 2)
	{
		mode[id] = 1
		iszb[id] = 1
		new Float:attackerhp
		pev(attacker, pev_health, attackerhp)
		if(attackerhp > 200.0) set_pev(id, pev_health, attackerhp - 100.0)
		
		hui_playsd(id, "zbdm/zombi_heal_female.wav", 1)
		
		if(get_user_weapon(id) == CSW_KNIFE)
		{
			set_pev(id, pev_viewmodel2, "models/v_knife.mdl") //V模型
			set_pev(id, pev_weaponmodel2, "") //P模型
		}
		
		for(new i=1; i<=32; i++)
		{
			if(!is_user_alive(i) || !is_user_connected(i) || get_team(i) != 1) continue
			if(flashtg[i]) continue
			client_cmd(i, "impulse 100")
		}
		
		set_pev(id, pev_maxspeed, 0.0001)
		cs_set_user_model(id, "flyghost")
		set_zombie(id)
		SetEnvFog(id, 28, 28, 28, T_FOG, false)
		
		if(get_ctnum() <= 0)
		{
			show_dhud(0, "恶灵胜利！")
			CS_TerminateRound(3.5, WINSTATUS_TERRORIST)
		}
		
		return HAM_SUPERCEDE
	}
		
	return HAM_IGNORED
}

stock SetEnvFog(const index = 0, const red = 127, const green = 127, const blue = 127, const Float:density_f = 0.001, bool:clear = false) 
{    
    static msgFog;
    
    if (msgFog || (msgFog = get_user_msgid("Fog")))     
    {         
        new density = _:floatclamp(density_f, 0.0001, 0.25) * _:!clear;                 
        message_begin(index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgFog, .player = index);         
        write_byte(clamp(red, 0, 255));         
        write_byte(clamp(green, 0, 255));         
        write_byte(clamp(blue , 0, 255));         
        write_byte((density & 0xFF));         
        write_byte((density >>  8) & 0xFF);         
        write_byte((density >> 16) & 0xFF);         
        write_byte((density >> 24) & 0xFF);         
        message_end();     
    } 
}

/*
public client_putinserver(id)
{
	if(!r_bot && is_user_bot(id))
	{
		r_bot = 1
		set_task(0.1, "Reg_bot", id)
	}
}

public Reg_bot(id)
{
	RegisterHamFromEntity(Ham_Killed, id, "Inven_Player")
	RegisterHamFromEntity(Ham_Spawn, id, "Inven_Player_Spawn", 1)
}
*/
public Inven_Player_Spawn(id)
{
	if(!is_user_alive(id) || !get_user_team(id) || !is_user_connected(id) )
	return

	if(get_pdata_int(id, 114, 5) == 1)
	{
		mode[id] = 1
		fm_strip_user_weapons(id)
		cs_set_user_model(id, "flyghost")
		set_pev(id, pev_health, 200.0)
		fm_give_item(id, "weapon_knife")
	}
	else if(get_pdata_int(id, 114, 5) == 2)
	{
		cs_set_user_model(id, "sas")
		mode[id] = 0
		timer[id] = 10
		SetEnvFog(id, 28, 28, 28, CT_FOG, false)
		
		fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)		
	}
	
	set_pev(id, pev_movetype, MOVETYPE_WALK)
	set_pev(id, pev_gravity, 1.0)
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}

public set_zombie(id)
{
	iszb[id] = 1
	change_team(id, 1)
	cs_set_user_model(id, "flyghost")
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	set_pev(id, pev_viewmodel2, "models/v_knife.mdl") //V模型
	set_pev(id, pev_weaponmodel2, "")
}

stock get_random_player()
{
	new Lucky[33], Amount, LuckyId

	for(new i = 1; i < 33; i ++)
	{
		if(!is_user_alive(i) || !is_user_connected(i))
		continue
		
		if(get_pdata_int(i, 114, 5) == 1) continue
		if(get_pdata_int(i, 114, 5) == 3) continue
		
		Amount ++
		Lucky[Amount] = i
	}
		
	if(!Amount)
	return 0
		
	LuckyId = Lucky[random_num(1, Amount)]
	
	return LuckyId
}

public FM_Player_PostThink(id)
{
	if(!is_user_alive(id) || !is_user_connected(id)) return
	
	//女鬼的呻吟声
	if(wait_ghostsd[id] <= get_gametime()) 
	{
		if(get_team(id) && iszb[id]) hui_playsd(id, "zbdm/zombi_heal_female.wav", 1)
		wait_ghostsd[id] = get_gametime() + random_float(3.8, 5.0)
	}
	
	if(get_allnum() <= 1 && !RoundCount)
	{
		//client_print(id, print_center, "战斗即将开始，请等待更多的玩家加入！(当前玩家数：2/%d )", get_allnum() )
	}
	else if(!RoundCount && get_allnum() >= 2)
	{
		server_cmd("sv_restart 1")
		RoundCount = 1
	}
	/*else if(RoundCount > 0 && get_allnum() == 1)
	{
		server_cmd("sv_restartround 1")
		CurPlay = 0
		RoundCount = 0
	}
	*/
	
	if(gtm(id) == 1 && is_alive(id) && iszb[id])
	{
		if(flashtg[id])
		{
			client_cmd(id, "impulse 100")
			flashtg[id] = 0
		}
		else if(get_user_weapon(id) != CSW_KNIFE)
		{
			engclient_cmd(id, "weapon_knife")
			set_pev(id, pev_viewmodel2, "models/v_knife.mdl") //V模型
			set_pev(id, pev_weaponmodel2, "") //P模型
		}
	}
	
	if(utime[id] <= get_gametime())
	{
		if(showplayer[id])
		{
			setvgb[id] = 255
		}
		else
		{
			if(setvgb[id] <= 60)
			{
				setvgb[id] = 0
				//return
			}
			if(setvgb[id] > 0) setvgb[id] -= 60 //渐隐速度
		}
		
		//client_print(0,print_chat, "实体透明度: < %d > [255 不透明, 0是透明], 是否被手电筒照到了: %d", setvgb[id], showplayer[id])
		
		utime[id] = get_gametime() + 0.07
	}
	
	if(ftime[id] <= get_gametime() && !checkzb && RoundCount)
	{
		if(timer[id] >= 1)
		{
			timer[id] -= 1
			Spk_DownCoundSd(id)
			set_dhudmessage(255, 255, 255, -1.0, 0.32, 0, 0.0, 1.0, 0.0, 0.0, 1)
			show_dhudmessage(id, "恶灵将在%d秒后出现！", timer[id])
			
			set_hudmessage(255, 0, 0, -1.0, 0.36, 0, 3.0, 1.0)
			show_hudmessage(id, "用手电筒照出恶灵并消灭他们!")
			
			ftime[id] = get_gametime() + 1.0
		}
		else
		{
			if(!checkzb)
			{
				new rp = get_random_player()
				
				if(is_user_alive(rp))
				{
					cs_set_user_model(rp, "flyghost")
					change_team(rp, 1)
					iszb[rp] = 1
					fm_strip_user_weapons(rp)
					fm_give_item(rp, "weapon_knife")
					engclient_cmd(rp, "weapon_knife")
					
					if(get_user_weapon(id) == CSW_KNIFE)
					{
						set_pev(rp, pev_viewmodel2, "models/v_knife.mdl") //V模型
						set_pev(rp, pev_weaponmodel2, "") //P模型
					}
			
					set_pev(rp, pev_weaponmodel2, "")
					set_pev(rp, pev_health, 500.0)
					set_pev(rp, pev_takedamage, 1.0)
					set_pev(rp, pev_maxspeed, 0.0001)
					//set_pev(rp, pev_solid, SOLID_BBOX)
					SetEnvFog(id, 28, 28, 28, T_FOG, false) 
					mode[rp] = 1
					
					hui_playsd(rp, "zbdm/zombi_heal_female.wav", 1)
					
					new fname[33]
					pev(rp, pev_netname, fname, sizeof(fname))
					//client_print(0, print_center, "恶灵出现了！小心了%s是被选定的首个幽灵！", fname)
					
					set_dhudmessage(255, 0, 0, -1.0, 0.32, 0, 6.0, 4.0)
					
					set_dhudmessage(255, 255, 255, -1.0, 0.32, 0, 3.0, 2.0)
					show_dhudmessage(rp, "成为恶灵！")
					
					set_hudmessage(255, 0, 0, -1.0, 0.36, 0, 3.0, 2.0)
					show_hudmessage(rp, "点击Q键可以开关漂浮状态")
					
					//client_print(rp, print_center, "恶灵出现了！小心了%s是被选定的首个幽灵！", fname)
				}
				
				checkzb = 1
				
				if(RoundCount)
				{
					new ent
					ent = -1
					while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_buyzone")) != 0)
					{
						engfunc(EngFunc_SetSize, ent, {-1.0 ,-1.0 ,-1.0}, {1.0 ,1.0 ,1.0})
					}
					
					//延迟0.2开启手电筒
					set_task(random_float(0.3, 0.8), "Task_ONLight", id + 18501)
					set_task(3.0, "Task_TipShow", id)
				}
			}
		}
	}
	
	/*
	new fname[33]
	pev(id, pev_netname, fname, sizeof(fname))
	*/
	if(is_user_alive(id) && get_team(id) == 1 && mode[id] && get_user_weapon(id) == CSW_KNIFE)
	CameraMove(id, id)
}

public Task_ONLight(id)
{
	id -= 18501
	for(new i=1; i<=32; i++)
	{
		if(!is_user_alive(i) || !is_user_connected(i) || get_team(i) != 2) continue
		if(flashtg[i]) continue
		client_cmd(i, "impulse 100")
	}
	
	remove_task(id + 18501)
}

public msgResetHUD(msg_id, msg_dest, msg_entity)
{
	set_task(1.3, "reset_ghost2", msg_entity)
}

public reset_ghost2(id)
{
	if(!is_user_connected(id)) return
	SetLightstyle(id, "g")
	
	//set_pev(id, pev_solid, SOLID_BBOX)
	
	if(get_user_team(id) == 2) SetEnvFog(id, 28, 28, 28, CT_FOG, false)
	else if(get_user_team(id) == 1) SetEnvFog(id, 28, 28, 28, T_FOG, false)
}

stock SetLightstyle(iPlayer, const light[])
{
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, iPlayer)
	write_byte(0)
	write_string(light)
	message_end()
}

public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	
	if(flashtg[id])
	{
		static origin[3];
		get_user_origin(id,origin,3);
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_DLIGHT); // TE_DLIGHT 27
		write_coord(origin[0]); // X
		write_coord(origin[1]); // Y
		write_coord(origin[2]); // Z
		write_byte(9); // radius
		write_byte(255); // R
		write_byte(255); // G
		write_byte(255); // B
		write_byte(1); // life
		write_byte(get_pcvar_num(flashlight_decay)); // decay rate
		message_end();
	}
	
	/*if(!mode[id] && get_team(id) != 2 && iszb[id])
	{
		new Float:blinkSpot[3], Float:g_lastPosition[3], Float:origin[3]
		pev(id, pev_origin, blinkSpot)
		pev(id, pev_origin, g_lastPosition)
		
		origin[0] = float(blinkSpot[0])
		origin[1] = float(blinkSpot[1])
		origin[2] = float(blinkSpot[2])
		
		origin[0] += ( ( origin[0] - g_lastPosition[0] > 0 ) ? -50 : 50 );
		origin[1] += ( ( origin[1] - g_lastPosition[1] > 0 ) ? -50 : 50 );
		origin[2] += 40;
		
		set_pev(id, pev_origin, origin)
	}
	*/
	
	for(new target=1;target<get_maxplayers();++target)
	{
			if(id == target || !is_user_connected(target) || !is_user_alive(target)) continue
			//if(!can_see_player(id, target)) continue //被挡住
			if(get_pdata_int(id, 114, 5) == get_pdata_int(target, 114, 5)) continue
			
			if(IsFlashBatShootTarget(id, target))
			{
				static name[32], targetname[32]
				get_user_name(id, name, 31)
				get_user_name(target, targetname, 31)
				
				if(flashtg[id])
				{
					showplayer[target] = 1
				}
				else{
					if(showplayer[target] >= 1)
					{
						showplayer[target] = 0
					}
				}
				
			}else
			{
				showplayer[target] = 0
				Save_See[id] = 0
				
				//client_print(0, print_center, "Target: %d, ShowPlayer: %d", target, showplayer[target])
			}
		}

	return PLUGIN_CONTINUE
}

stock bool:IsFlashBatShootTarget(id, iTarget){
	static iAim[3], Float:fAim[3], Float:fOrigin[3], Float:fVec[3]
	static Float:fLimitsDist, Float:fLimitsTheta
	get_user_origin(id, iAim, 3)
	IVecFVec(iAim, fAim)
	static Float:vecViewOfs[3]
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, vecViewOfs)
	xs_vec_add(fOrigin, vecViewOfs, fOrigin)
	for(new i;i<3;++i) fVec[i] = fAim[i] - fOrigin[i]

	if(iTarget == id) return false
	static Float:fGhost[3], Float:VecP2G[3], Float:fDistanceP2G, Float:fDistanceVec
	pev(iTarget, pev_origin, fGhost)
	for(new i;i<3;++i) VecP2G[i] = fGhost[i] - fOrigin[i]
	fDistanceP2G = vector_length(VecP2G); fDistanceVec = vector_length(fVec)
	static Float:fDot, Float:theta, Float:fDistanceG2F
	fDot = xs_vec_dot(fVec, VecP2G)
	theta = acos(fDot/(fDistanceVec*fDistanceP2G))
	fDistanceG2F = fDistanceP2G * asin(theta)

	static Float:fFootpoint[3], Float:fDistP2F, Float:fRate, Float:fZoffset
	fDistP2F = floatsqroot(fDistanceP2G*fDistanceP2G+fDistanceG2F*fDistanceG2F)
	fRate = fDistP2F/fDistanceVec
	for(new i;i<3;++i) fFootpoint[i] = fOrigin[i] + fVec[i] * fRate
	fZoffset = floatabs(fFootpoint[2]-fGhost[2])

	if(fDistanceP2G<60.0){
		if(fZoffset>15.0){
			fLimitsDist = 46.0; fLimitsTheta = 0.9
		}else{
			fLimitsDist = 36.0; fLimitsTheta = 0.6
		}
	}
	else if(fDistanceP2G<100.0){
		fLimitsDist = 41.0; fLimitsTheta = 0.4
	}
	else if(fDistanceP2G<200.0){
		if(fZoffset>36.0){
			fLimitsDist = 49.0; fLimitsTheta = 0.18
		}else{
			fLimitsDist = 43.0; fLimitsTheta = 0.24
		}
	}
	else if(fDistanceP2G<300.0){
		if(fZoffset>22.0){
			fLimitsDist = 49.0; fLimitsTheta = 0.18
		}else{
			fLimitsDist = 30.2; fLimitsTheta = 0.11
		}
	}
	else if(fDistanceP2G<500.0){
		if(fZoffset>20.0){
			fLimitsDist = 46.0; fLimitsTheta = 0.11
		}else{
			fLimitsDist = 30.0; fLimitsTheta = 0.07
		}
	}
	else{
		fLimitsDist = 46.6; fLimitsTheta = 0.14
	}
	return (0.0<fDistanceG2F<=fLimitsDist && theta<fLimitsTheta)
}

public fw_AddToFullPack_Post(es_handle, e, ent, id, iHostFlags, player, iSet) 
{ 
	if(!is_user_alive(ent)) return 
	if(!is_user_alive(id)) return
	
	if(get_pdata_int(ent, 114, 5) == get_pdata_int(id, 114, 5)) return
	
	//static Float:dist; dist=Stock_Distance_Crosshir(id, ent)
	
	//static Float:amount;amount = 255.0 - 254.0 * dist/36.0
	//set_es(es_handle, ES_RenderAmt, floatround(amount))
	
	if(get_pdata_int(ent, 114, 5) == 1)
	{
		set_es(es_handle, ES_RenderAmt, setvgb[ent])
		//set_pev(ent, pev_solid, SOLID_NOT)
	}
}

stock show_dhud(id, const cg1[])
{
	set_dhudmessage(180, 160, 255, -1.0, 0.32, 0, 6.0, 4.0)
	show_dhudmessage(id, "%s", cg1)
}

public CameraMove(ent, id)
{
	static btn, Float:forw, Float:right, Float:up
	btn=pev(id,pev_oldbuttons)
	forw=right=up=0.0
	
	if (btn&IN_FORWARD) forw+=1.0
	if (btn&IN_BACK) forw-=1.0
	if (btn&IN_MOVELEFT) right-=1.0
	if (btn&IN_MOVERIGHT) right+=1.0
	if (btn&IN_JUMP) up+=1.0
	
	static Float:start[3], Float:end[3]
	pev(ent, pev_origin, start)
	
	stock_GetStartPos(ent, forw, right, up, end)
	
	static Float:length, Float:vec[3]
	xs_vec_sub(end, start, vec)
	length=vector_length(vec)
	
	if (length)
	{
		set_pev(id, pev_gravity, 0.0001)
		xs_vec_div_scalar(vec, length / get_pcvar_float(viewspeed) * get_pcvar_float(stoping), vec)
		
		//set_pev(ent, pev_velocity, vec)
		//xs_vec_div_scalar(start, 100.0, start)
		xs_vec_add(start, vec, vec)
		
		set_pev(ent, pev_origin, vec)
	}
	else
	{
		pev(ent, pev_velocity, vec)
		if (!vector_length(vec)) return
		set_pev(ent, pev_velocity, {0.0,0.0,0.0})
	}
}

stock stock_GetStartPos(ent, Float:forw=0.0, Float:right=0.0, Float:up=0.0, Float:start[3])
{
	static Float:ang[3], Float:org[3]
	if(!is_user_connected(ent)) pev(ent, pev_angles, ang)
	else pev(ent, pev_v_angle, ang)
	
	//ang[0] *= -1.0
	pev(ent, pev_origin, org)
	
	static Float:vForw[3], Float:vRight[3], Float:vUp[3]
	
	engfunc(EngFunc_AngleVectors, ang, vForw, vRight, vUp)
	
	static n
	for (n=0;n<3;n++) start[n]=org[n]+vForw[n]*forw+vRight[n]*right+vUp[n]*up
}


public Forward_ClientKill(id)
{
	if(!is_user_alive(id))
	return HAM_IGNORED
	
	set_dhudmessage(180, 160, 255, -1.0, 0.53, 0, 6.0, 4.0)
	show_dhudmessage(id, "你无法自杀")
	return HAM_SUPERCEDE
	
	return FMRES_IGNORED
}

public fw_ClientCommand(id)
{
	static szCommand[24]
	read_argv(0, szCommand, charsmax(szCommand))
	
	if(!is_user_connected(id))
	return HAM_IGNORED
	
	if(is_user_alive(id))
	{
		if(equal(szCommand, "chooseteam") || equal(szCommand, "jointeam"))
		{
			set_dhudmessage(180, 160, 255, -1.0, 0.58, 0, 6.0, 4.0)
			show_dhudmessage(id, "你无法切换阵营")
			return FMRES_SUPERCEDE
		}
		if( equal(szCommand, "buy"))
		{
			if(timer[id] && !checkzb) return HAM_IGNORED
			set_dhudmessage(180, 160, 255, -1.0, 0.58, 0, 6.0, 4.0)
			show_dhudmessage(id, "已经无法购买武器。")
			return FMRES_SUPERCEDE
		}
	}
}

//幽灵声音
public FlyGhost_Sound(id, channel, sample[], Float:volume, Float:attn, flag, pitch)
{
	if(!is_user_connected(id) || !iszb[id])
	return HAM_IGNORED
	
	if(get_team(id) == 1 && iszb[id])
	{
		//死亡时
		if (equal(sample, "player/die1.wav") || equal(sample, "player/die2.wav") 
		|| equal(sample, "player/die3.wav") || equal(sample, "player/death6.wav"))
		{
			switch(random_num(1, 2))
			{
				case 1: hui_playsd(id, "zbdm/zombi_death_female_1.wav", 1)
				case 2: hui_playsd(id, "zbdm/zombi_death_female_2.wav", 1)
			}
			return HAM_SUPERCEDE
		}
		
		//当他们受伤的时候
		if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' ||
		sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
		return HAM_SUPERCEDE
		
		//爪子的声音
		new attack_type
		if (equal(sample,"weapons/knife_hitwall1.wav")) attack_type = 1
		else if (equal(sample,"weapons/knife_hit1.wav") ||
		equal(sample,"weapons/knife_hit3.wav") ||
		equal(sample,"weapons/knife_hit2.wav") ||
		equal(sample,"weapons/knife_hit4.wav") ||
		equal(sample,"weapons/knife_stab.wav")) attack_type = 2
		else if(equal(sample,"weapons/knife_slash1.wav") ||
		equal(sample,"weapons/knife_slash2.wav")) attack_type = 3
		if (attack_type)
		{
			new sound[64]
			new pgz = random_num(1,3)
			if (attack_type == 1)
			{
				if (pgz == 1) emit_sound(id, CHAN_VOICE, "zbdm/zombi_wall_1.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 2) emit_sound(id, CHAN_VOICE, "zbdm/zombi_wall_2.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 3) emit_sound(id, CHAN_VOICE, "zbdm/zombi_wall_3.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				
			}
			//攻击到了玩家
			else if (attack_type == 2)
			{
				if (pgz == 1) emit_sound(id, CHAN_VOICE, "zbdm/zombi_attack_1.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 2) emit_sound(id, CHAN_VOICE, "zbdm/zombi_attack_2.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 3) emit_sound(id, CHAN_VOICE, "zbdm/zombi_attack_3.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				
			}
			//空气
			else if (attack_type == 3)
			{
				if (pgz == 1) emit_sound(id, CHAN_VOICE, "zbdm/zombi_swing_1.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 2) emit_sound(id, CHAN_VOICE, "zbdm/zombi_swing_2.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				else if (pgz == 3) emit_sound(id, CHAN_VOICE, "zbdm/zombi_swing_3.wav",1.0, ATTN_NORM, 0, PITCH_NORM)
				
			}

			return FMRES_SUPERCEDE;
		}
		
	}
	
	return HAM_IGNORED
}

public fw_PlayerTraceAttack(Victim, Attacker, Float:Damage, Float:Direction[3], TraceResult, DamageBits) 
{
	if(is_user_alive(Attacker))
	{
		if(get_team(Attacker) == 2 && (get_team(Victim) == 1 && iszb[Victim] ))
		return HAM_SUPERCEDE
	}
		
	return HAM_HANDLED
}

stock Spk_DownCoundSd(id)
{
	new funcount = timer[id]
	
	if(!is_user_connected(id)) return
	
	if(funcount == 1)
	client_cmd(id, "spk zbdm/count/1.wav")
	else if(funcount == 2)
	client_cmd(id, "spk zbdm/count/2.wav")
	else if(funcount == 3)
	client_cmd(id, "spk zbdm/count/3.wav")
	else if(funcount == 4)
	client_cmd(id, "spk zbdm/count/4.wav")
	else if(funcount == 5)
	client_cmd(id, "spk zbdm/count/5.wav")
	else if(funcount == 6)
	client_cmd(id, "spk zbdm/count/6.wav")
	else if(funcount == 7)
	client_cmd(id, "spk zbdm/count/7.wav")
	else if(funcount == 8)
	client_cmd(id, "spk zbdm/count/8.wav")
	else if(funcount == 9)
	client_cmd(id, "spk zbdm/count/9.wav")
	else if(funcount == 10)
	client_cmd(id, "spk zbdm/count/10.wav")
}

public Grenade_Remove(ent, model[])
{
	if(!pev_valid(ent)) return HAM_IGNORED

	new class[33]
	pev(ent, pev_classname, class, sizeof(class))
	if(!equal(class, "grenade")) return HAM_IGNORED
	
	if(equal(model, "models/w_smokegrenade.mdl") || equal(model, "models/w_flashbang.mdl") || equal(model, "models/w_hegrenade.mdl"))
	{
		set_pev(ent, pev_flags, FL_KILLME)
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public message_StatusIcon(msgid, msg_dest, id)
{
	new icon[8]
	get_msg_arg_string(2, icon, 7)
	
	if (!equal(icon,"buyzone")) return PLUGIN_CONTINUE
	
	if (!get_msg_arg_int(1)) return PLUGIN_CONTINUE
	
	if(timer[id] || !checkzb) return PLUGIN_CONTINUE
	
	show_dhud(id, "你无法购买武器。")
	
	set_pdata_int(id, 235, get_pdata_int(id,235)&~(1<<0))
	
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	set_task(0.1, "Hook_BuyHold", id)
}

public client_disconnect(id)
{
	client_cmd(id, "bind b buy")
}

public Hook_BuyHold(id)
{
	client_cmd(id, "bind b buyz")
}

public set_to_origin(id, const Float:origin[3], const Float:position[3])
{
	static Float:point[3]
	xs_vec_add(origin, position, point)
	set_pev(id, pev_origin, point)
}

stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	return true;
	
	return false;
}

public player_check_origin(id, Float:start[3], Float:org[3])
{
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,0.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,0.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,0.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,0.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,0.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,0.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,0.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,0.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,16.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,-16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,-16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{0.0,-16.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,16.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,16.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,-16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,-16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{16.0,-16.0,-36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,-16.0,0.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,-16.0,36.0})
	if (is_player_stuck(id)) set_to_origin(id, org, Float:{-16.0,-16.0,-36.0})
	if (is_player_stuck(id))
	{
		set_pev(id, pev_origin, start)
	}
	else
	{
		show_dhud(id, "自动解除卡住。")
	}
}

stock is_hull_vacantx(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true
	
	return false
}

public checkstuck() 
{
		static players[32], pnum, player
		get_players(players, pnum)
		static Float:origin[3]
		static Float:mins[3], hull
		static Float:vec[3]
		static o,i
		for(i=0; i<pnum; i++){
			player = players[i]
			if (is_user_connected(player) && is_user_alive(player))
			{
				pev(player, pev_origin, origin)
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
				if (!is_hull_vacant(origin, hull,player) && !(pev(player,pev_solid) & SOLID_NOT) && !mode[player] && get_team(player) == 1)
				{
					++stuck[player]
					if(stuck[player] >= 1)
					{
						pev(player, pev_mins, mins)
						vec[2] = origin[2]
						for (o=0; o < sizeof size; ++o) {
							vec[0] = origin[0] - mins[0] * size[o][0]
							vec[1] = origin[1] - mins[1] * size[o][1]
							vec[2] = origin[2] - mins[2] * size[o][2]
							if (is_hull_vacant(vec, hull,player))
							{
								show_dhud(player, "你可能在墙里。已经为你解除卡住。")
								engfunc(EngFunc_SetOrigin, player, vec)
								//set_pev(player,pev_velocity,{0.0,0.0,0.0})
								o = sizeof size
							}
						}
					}
				}
				else
				{
					stuck[player] = 0
				}
			}
		}
}
