#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <colorchat>

#define PLUGIN "Yoiz's Home Kz Menu"
#define VERSION "1.0"
#define AUTHOR "Azuki dasuki~"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    /*
        HamHook:RegisterHam(Ham:function, const EntityClass[], const Callback[], Post=0);
        1 需要勾住的事件(函数)
        2 需要勾住的实体名称
        3 你写的对应事件处理函数
        4 你写的函数和勾住的事件的发生先后顺序: 0 则先发生回调函数再执行勾住的函数 1则先执行勾住的函数再执行回调函数
    */
    //post设置为0 无效 可能是模型覆盖?
    RegisterHam(Ham_Item_Deploy, "weapon_usp" , "hamusp", 1);
    RegisterHam(Ham_Item_Deploy, "weapon_knife" , "hamknife", 1);
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
    register_clcmd( "say /myskin",     "SkinsMenu" );
    register_clcmd( "/myskin",     "SkinsMenu" );
    register_clcmd( "say /mod",     "SkinsMenu" );
    register_clcmd( "/mod",     "SkinsMenu" );    // RegisterHam(Ham_Spawn, "player" , "fw_playerSpawn", 1);
    set_task(500.0, "taskPrintInfo", 0, _, _, "b");

    register_clcmd( "test",     "test" );

    register_cvar("rt", "0");
    register_cvar("rr", "0");
    register_cvar("rg", "165");
    register_cvar("rb", "0");
    register_cvar("rm", "0");
	formatex(title, 285, "\d[xiaokz] \r#KZ Server \dVisit \ywww.csxiaokz.com \n\rQQ群:719383105\n\dBeiJing time \y%s\n\dMap \y%s\d & Timeleft \y%d:%02d\n\dType map \y%s", thetime, MapName, tl / 60, tl % 60, MapType);


}