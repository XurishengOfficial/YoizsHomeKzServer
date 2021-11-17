#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <float>
#include <colorchat>

new jumpnum[33] = 0
new bool:dojump[33] = false;
new bool:is_mj_activate[33] = false;
// 只优化了二段跳滚轮 二段跳及以上未优化
new Float: firstPress[33];
new Float: secondPress[33];

public plugin_init()
{
    register_plugin("MultiJump","1.1","Azuki dasuki~ + twistedeuphoria")
    register_cvar("amx_maxjumps","1")
    register_cvar("amx_multijumpcd","0.2")
    register_clcmd("say /mj", "activateMultiJumps");
}

public client_putinserver(id)
{
    jumpnum[id] = 0
    dojump[id] = false
}

public client_disconnect(id)
{
    jumpnum[id] = 0
    dojump[id] = false
}

public activateMultiJumps(id) {
    // 普通玩家使用会暂停计时器
    if(!is_user_admin(id))
        client_cmd(id, ".noclip");
    is_mj_activate[id] = !is_mj_activate[id];
    ColorChat(id, GREEN, is_mj_activate[id]? "[Holo]^x03二段跳已开启!" : "[Holo]^x03二段跳已关闭!");
}
public client_PreThink(id)
{
    // client_print(id, print_chat, "client_PreThink");
    new nbut = get_user_button(id)
    new obut = get_user_oldbutton(id)
    if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP)) {
        firstPress[id] = get_gametime();
        // client_print(id, print_chat, "firstPress at %f", firstPress[id]);
    }
    if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
    {
        secondPress[id] = get_gametime();
        new float: timeInterval = secondPress[id] - firstPress[id];
        // client_print(id, print_chat, "secondPress at %f, timeinterval is %f", secondPress[id], timeInterval);
        if(jumpnum[id] < get_cvar_num("amx_maxjumps") && timeInterval > get_cvar_float("amx_multijumpcd") && is_mj_activate[id])
        {
            dojump[id] = true
            jumpnum[id]++;
            return PLUGIN_CONTINUE
        }
    }
    if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
    {
        // client_print(id, print_chat, "jumpnum = 0");
        jumpnum[id] = 0
        return PLUGIN_CONTINUE
    }
    return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
    // client_print(id, print_chat, "client_PostThink");
    if(dojump[id] == true)
    {
        new Float:velocity[3]
        entity_get_vector(id, EV_VEC_velocity, velocity)
        velocity[2] = 270.0;
        entity_set_vector(id, EV_VEC_velocity, velocity)
        dojump[id] = false
        // client_print(id, print_center, "二段跳触发了, 在时刻 %f", get_gametime());
        return PLUGIN_CONTINUE
    }
    return PLUGIN_CONTINUE
}