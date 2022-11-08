#include <amxmodx>
#include <engine>
// #include <colorchat>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <float>
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
    register_clcmd( "say /test5", "testHandler5" );              // 测试跟随spr
    register_clcmd( "say /tr", "testTraceLine" );              // 测试跟随spr
    register_clcmd( "/tr", "testTraceLine" );              // 测试跟随spr
    // register_forward(FM_AddToFullPack, "addToFullPack", 1);
    // RegisterHam(Ham_Player_PreThink, "player", "Ham_PlayerPreThink", 0);

}

public Ham_PlayerPreThink(id) {
    if(!id) {
        // server_print("Player id invalid");
        return;
    }
    if(!is_user_alive(id) || is_user_bot(id)) {
        // server_print("Player is dead or bot");
        return;
    }

    // client_print(id, print_chat, "%d", pev(id, pev_movetype));
    // FL_FLOAT
    // client_print(id, print_chat, "%d", pev(id, pev_flags) & FL_FLOAT);

    new icon_ent_id = pev(id, pev_iuser4);
    if(!pev_valid(g_Icon_ent)){
        // server_print("icon_ent_id is %d, invalid", icon_ent_id);
        return;
    } 
    // server_print("Valid icon_ent_id");
    new Float: playerOrigin[3];
    new Float: speed[3];

    pev(id, pev_origin, playerOrigin); 
    pev(id, pev_velocity, speed);
    // client_print(0, print_chat, "dx: %f    dy: %f     dz: %f", dx, dy, dz);
    playerOrigin[2] += 40;                  // 由于是头顶 需要增加z轴高度
    playerOrigin[0] += speed[0] / 250 * 30;
    playerOrigin[1] += speed[1] / 250 * 30;
    playerOrigin[2] += speed[2] / 250 * 20;
    set_pev(g_Icon_ent, pev_origin, playerOrigin);
    // client_print(0, print_chat, "dx: %f    dy: %f     dz: %f", speed[0], speed[1], speed[2]);

    // server_print("Ham_PlayerPreThink");
    return;
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
    set_pev(id, pev_iuser4, g_Icon_ent);
}

// ent应该指服务端要要发送给客户端的实体 (这里指spr) 从本地图载入的中循环发送
// host是接收服务器包的玩家id
// player为判断该实体是否是玩家
// ent == e

#if 0
public addToFullPack(es, e, ent, host, hostflags, player, pSet)
{
    // server_print("========== es: %d, e: %d, ent: %d, host: %d, hostflags: %d, player: %d ==========", es, e, ent, host, hostflags, player);
    // if(pev_valid(ent) && (pev(ent, pev_iuser1) == pev(ent, pev_owner))) // ent持有者是自身?
    if( pev_valid(ent) && pev(ent, pev_iuser2) ) // 之前设置过spr的pev_iuser2
    {
        new user = pev(ent, pev_iuser2);    // 之前在create_icon中进行过绑定 找到对应玩家的id

        if(is_user_alive(user))
        {
            new Float: playerOrigin[3];
            pev(user, pev_origin, playerOrigin);    // 获取被spr绑定玩家的位置
            playerOrigin[2] += 42;                  // 由于是头顶 需要增加z轴高度
            engfunc(EngFunc_SetOrigin, ent, playerOrigin);
            new ent_name[64];
            pev(ent, pev_classname, ent_name, charsmax(ent_name));
            // server_print("ent_name:%s set origin", ent_name);
            // if(specmode == 4)
            // {
            // 	set_es(es, ES_Effects, EF_NODRAW);  // Don't draw entity
            // }
        }
    }
    return FMRES_IGNORED;
}
#endif

public testHandler5(id) {
    new float: playerPos[3] = {1.0, 0.0, 0.0};
    new float: verticalVec[3];
    new float: zGround[3] = {0.0, 0.0, 1.0};
    client_print(id, print_chat, "zGround is [%.2f, %.2f, %.2f]", zGround[0], zGround[1], zGround[2]);

    // pev(id, pev_origin, playerPos);
    if(trace_line(-1, playerPos, zGround, verticalVec)) {
        client_print(id, print_chat, "verticalVec is [%.2f, %.2f, %.2f]", verticalVec[0], verticalVec[1], verticalVec[2]);
    }
    else {
        client_print(id, print_chat, "Did not hit anything");
        client_print(id, print_chat, "verticalVec is [%.2f, %.2f, %.2f]", verticalVec[0], verticalVec[1], verticalVec[2]);

    }
    return ;
}

public create_icon_with_origin(id, float:x, float:y, float: z)
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

    new Float: sprOrigin[3];
    sprOrigin[0] = x;
    sprOrigin[1] = y;
    sprOrigin[2] = z;
    server_print("sprOrigin: %.2f, %.2f, %.2f", sprOrigin[0], sprOrigin[1], sprOrigin[2]);
    set_pev(g_Icon_ent, pev_origin, sprOrigin);
    // set_pev(id, pev_iuser4, g_Icon_ent);
}

public testTraceLine(id)
{
    // new Float:temp_origin[3];
    new Float: playerOrigin[3];
    pev(id, pev_origin, playerOrigin);
    new Float:view_angle[3];
    pev(id, pev_v_angle, view_angle);
    new Float: angle = view_angle[1];
    new Float: distance = 500.00;
    new Float: traceLineEnd[3];
    traceLineEnd[0] = playerOrigin[0] + distance * floatcos(angle, 1);
    traceLineEnd[1] = playerOrigin[1] + distance * floatsin(angle, 1);
    traceLineEnd[2] = playerOrigin[2];
    // server_print("angle: %.2f", angle);
    // server_print("floatcos: %.2f", floatcos(angle, 1));
    // server_print("floatsin: %.2f", floatsin(angle, 1));
    // server_print("100.0 * floatcos: %.2f", 100.0 * floatcos(angle, 1));
    // server_print("100.0 * floatsin: %.2f", 100.0 * floatsin(angle, 1));
    // server_print("player: %.2f, %.2f, %.2f", playerOrigin[0], playerOrigin[1], playerOrigin[2]);
    // server_print("spr: %.2f, %.2f, %.2f", traceLineEnd[0], traceLineEnd[1], traceLineEnd[2]);
    server_print("Create traceEnd position spr");
    create_icon_with_origin(id, traceLineEnd[0], traceLineEnd[1], traceLineEnd[2]);


    new Float: vRet[3];
    // 第一个参数是需要忽略的实体 
    // 0: dont ignore monster; 1: ignore monster; 2: igore missile; 3: ignore glass 
    if(trace_line(0, playerOrigin, traceLineEnd, vRet))
    {
        // hit
        server_print("Create first hit position spr");

        server_print("vRet: %.2f, %.2f, %.2f", vRet[0], vRet[1], vRet[2]);
        create_icon_with_origin(id, vRet[0], vRet[1], vRet[2]);
    }
    else
        server_print("not hit");

    
    return;
}
