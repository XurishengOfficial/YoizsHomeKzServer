#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <float>
#include <fun>

#define PLUGIN "Test"
#define VERSION "1.0"
#define AUTHOR "Azuki daisuki~"

new g_kz_disDiff;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    // register_clcmd("say /test4", "test4")
    register_clcmd("say /test5", "test5")
    register_clcmd("say /test6", "test6")
    // register_clcmd("say /test6", "test6")
    // register_clcmd("say /test7", "test7")
    // register_clcmd("say /test8", "test8")
	// RegisterHam(Ham_Player_PreThink, "player", "Ham_PlayerPreThink", 0);

	g_kz_disDiff = register_cvar("kz_disDiff", "10");
}

public test4(id) {
	new str[] = "12345";
	new str2[32];
	copy(str2, 16, str);
	client_print(id, print_chat, "%s", str2);
	str2[30] = 'a';
	str2[31] = 'b';
	client_print(id, print_chat, "%s", str2);
	client_print(id, print_chat, "%c %c", str2[30], str2[31]);
}
public curweapon(id) {
    static wpn_name[16], wpn_id;
    new weapon_num = read_data(2);	// read_data用于读取全局事件中的第几个参数 
	if( weapon_num != 16 && weapon_num != 22 )  // not usp or m4a1
	{
		return PLUGIN_HANDLED;
	}
	get_weaponname( weapon_num, wpn_name, sizeof wpn_name - 1 );
	while( ( wpn_id = engfunc( EngFunc_FindEntityByString, wpn_id, "classname", wpn_name ) ) && pev( wpn_id, pev_owner ) != id ) { }
	if( !wpn_id )
	{
		return PLUGIN_HANDLED;
	}
	cs_set_weapon_silen( wpn_id, 1, 0 );
    return 0;
}

public test5(id)
{
	static Float: origin[3];
	new g_msgDamage = get_user_msgid("Damage");
	pev(id, pev_origin, origin);
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
    write_byte(1) // damage save
    write_byte(1) // damage take
    write_long(DMG_BULLET) // damage type - DMG_BULLET hlsdk_const
    write_coord(origin[0]) // x
    write_coord(origin[1] + 100.0) // y
    write_coord(origin[2]) // z
    message_end()
}

public test6(id)
{
	// native Float:floatsinh(Float:angle, anglemode:mode=radian);
	strip_user_weapons(id);

}

public Ham_PlayerPreThink(id)
{
	if( (is_user_bot(id)) || !is_user_alive(id) ) return;
	new Float:angle[3];
	new Float:pos[3];
	pev(id, pev_v_angle, angle);
	pev(id, pev_origin, pos);
	client_print(id, print_chat, "%.2f	%.2f	%.2f", angle[0], angle[1], angle[2])
	client_print(id, print_center, "%.2f	%.2f	%.2f", pos[0], pos[1], pos[2])
	// client_print(0, print_chat, "====================================")
}