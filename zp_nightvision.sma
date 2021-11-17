/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */
#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <zombieplague>
#include <acg>

#define PLUGINNAME		"新夜视仪"
#define VERSION			"1.1"
#define AUTHOR			"Fly"
//https://tieba.baidu.com/p/2253221326?red_tag=1288081844
new cvar_nvg[7], nvg[33], g_cached_lighting[2]

public plugin_init() 
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	register_message(get_user_msgid("NVGToggle"), "message_nvgtoggle")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink_Post", 1)

	cvar_nvg[0] = register_cvar("new_nvg_hm_color_R", "0")		// 人类 红(1-255)
	cvar_nvg[1] = register_cvar("new_nvg_hm_color_G", "250")	// 人类 绿(1-255)
	cvar_nvg[2] = register_cvar("new_nvg_hm_color_B", "0")		// 人类 蓝(1-255)

	cvar_nvg[3] = register_cvar("new_nvg_zb_color_R", "200")	// 僵尸 红(1-255)
	cvar_nvg[4] = register_cvar("new_nvg_zb_color_G", "0")		// 僵尸 绿(1-255)
	cvar_nvg[5] = register_cvar("new_nvg_zb_color_B", "0")		// 僵尸 蓝(1-255)

	cvar_nvg[6] = register_cvar("new_nvg_A", "70")			// 透明度(1-255)

        RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
}

public message_nvgtoggle(msg_id, msg_dest, msg_entity)
{
	nvg[msg_entity] = get_msg_arg_int(1)
	return PLUGIN_HANDLED
}

public fw_PlayerPostThink_Post(id)
{
	if (!is_user_alive(id))
	{
		message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
		write_byte(0)
		write_string("#")
		message_end()
	}
	get_cvar_string("zp_lighting", g_cached_lighting, charsmax(g_cached_lighting))
	if (nvg[id] == true)
	{
		message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
		write_byte(0)
		write_string("#")
		message_end()

		new Float:origin[3]
		pev(id, pev_origin, origin)

		message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
		write_byte(TE_ELIGHT)
		write_short(id)
		engfunc(EngFunc_WriteCoord, origin[0])
		engfunc(EngFunc_WriteCoord, origin[1])
		engfunc(EngFunc_WriteCoord, origin[2])
		engfunc(EngFunc_WriteCoord, 50.0)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(1)
		engfunc(EngFunc_WriteCoord, 0.0)
		message_end()


		if (zp_get_user_zombie(id)) 
		{ 
			acg_screenfade(id, get_pcvar_num(cvar_nvg[3]), get_pcvar_num(cvar_nvg[4]), get_pcvar_num(cvar_nvg[5]), get_pcvar_num(cvar_nvg[6]), -1.0, 0.0, 0.2)

			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"),{0,0,0},id) 
			write_short(200) //更新速率 
			write_short(200) //更新速率 
			write_short(0x0000) 
			write_byte(0) //红 
			write_byte(0) //绿 
			write_byte(0) //蓝 
			write_byte(get_pcvar_num(cvar_nvg[6]))
			message_end()

			//acg_screenfade(id, random_num(1, 255), random_num(1, 255), random_num(1, 255), get_pcvar_num(cvar_nvg[6]), -1.0, 0.0, 0.0)
		} 
		else
		{ 
			acg_screenfade(id, get_pcvar_num(cvar_nvg[0]), get_pcvar_num(cvar_nvg[1]), get_pcvar_num(cvar_nvg[2]), get_pcvar_num(cvar_nvg[6]), -1.0, 0.0, 0.2)

			//acg_screenfade(id, random_num(1, 255), random_num(1, 255), random_num(1, 255), get_pcvar_num(cvar_nvg[6]), -1.0, 0.0, 0.0)
		}
	}
	if (nvg[id] == false)
	{
		message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
		write_byte(0)
		write_string(g_cached_lighting)
		message_end()
		acg_removedrawnimage(id, 5, -1)
	}
}
public zp_user_infected_post(id, infector)
{ 
   nvg[id] = true
}

public fw_PlayerSpawn_Post(id)
{
	cs_set_user_nvg(id, 0)
}