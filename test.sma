#include <amxmodx>
// #include <colorchat>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#define PLUGIN "Test"
#define VERSION "1.0"
#define AUTHOR "Rashaun"

new url_sprite[] = "sprites/cn.spr"
new g_Icon_ent;

public plugin_precache() {
    precache_model(url_sprite);
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    register_clcmd( "say /test4", "testHandler" );              // 测试跟随spr
    register_forward(FM_AddToFullPack, "addToFullPack", 1);
}

public testHandler(id) {
    create_icon(id);
}

public create_icon(id)
{
    server_print("========== create_icon ==========");
	g_Icon_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"));

	if(file_exists(url_sprite))
	{
		engfunc(EngFunc_SetModel, g_Icon_ent, url_sprite);
        server_print("========== file_exists and set_model ==========");
	}
	else
	{
        server_print("%s file not exist", url_sprite);
		return;
	}
	set_pev(g_Icon_ent, pev_solid, SOLID_NOT);  // 设置无碰撞
	set_pev(g_Icon_ent, pev_movetype, MOVETYPE_FLYMISSILE);
    // pev(spectator, pev_iuser2) == player spectator是否在观察player
    // pev_iuser详解 https://tieba.baidu.com/p/4249834841   https://www.zybuluo.com/sogouwap/note/590177#%E6%9B%B4%E5%A4%9A%E7%9A%84pev
	set_pev(g_Icon_ent, pev_iuser2, id);    // 将spr和玩家(本身也是实体)进行绑定 正在观察的玩家ID存储在pev->iuser2里
	set_pev(g_Icon_ent, pev_scale, 0.25);   // 设置spr大小

    new Float: playerOrigin[3];
    pev(id, pev_origin, playerOrigin); 
    playerOrigin[2] += 42;                  // 由于是头顶 需要增加z轴高度
    set_pev(g_Icon_ent, pev_origin, playerOrigin);
}

// ent应该指服务端要要发送给客户端的实体 (这里指spr) 从本地图载入的中循环发送
// host是接收服务器包的玩家id
// player常年为0?
// ent == e
public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
    // server_print("========== es: %d, e: %d, ent: %d, host: %d, hostflags: %d, player: %d ==========", es, e, ent, host, hostflags, player);
    if(pev_valid(ent) && (pev(ent, pev_iuser1) == pev(ent, pev_owner))) // ent持有者是自身?
    {
        new user = pev(ent, pev_iuser2);    // 之前在create_icon中进行过绑定 找到对应玩家的id

        if(is_user_alive(user))
        {
            new Float: playerOrigin[3];
            pev(user, pev_origin, playerOrigin);    // 获取被spr绑定玩家的位置
            playerOrigin[2] += 42;                  // 由于是头顶 需要增加z轴高度
            engfunc(EngFunc_SetOrigin, ent, playerOrigin);

            // if(specmode == 4)
            // {
            // 	set_es(es, ES_Effects, EF_NODRAW);  // Don't draw entity
            // }
        }
    }
	return FMRES_IGNORED;
}

