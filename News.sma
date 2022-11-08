#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <ColorChat>
#define PLUGIN "Server News"
#define VERSION "1.0"
#define AUTHOR "Azuki daisuki~"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    set_task(500.0, "tskShowNews1", _, _, _, "b");
    set_task(600.0, "tskShowNews2", _, _, _, "b");
}

public tskShowNews1()
{
    ColorChat(0, GREEN, "[News]^x01 由于近期服务器恶意炸服频发，有需要的玩家可打开^x03转服菜单^x01收藏新增服务器地址!");
}

public tskShowNews2()
{
    ColorChat(0, GREEN, "[News]^x01 温馨提示: 输入指令^x03/showpre^x01可关闭地速及FOG显示^x01!");
}