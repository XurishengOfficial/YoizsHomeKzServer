#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#define PLUGIN "Test"
#define VERSION "1.0"
#define AUTHOR "Azuki daisuki~"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    register_event("CurWeapon", "curweapon", "be", "1=1");
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