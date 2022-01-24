#include <amxmodx>

#define PLUGIN "Motd Help Commands"
#define VERSION "2.0"
#define AUTHOR "Rainbow"

public server_documentations_motd(id)
{
    show_motd(id, "addons/amxmodx/configs/MotdHelpCommands/server_documentations_motd.html", "服务器帮助文档");
    return PLUGIN_HANDLED
}

public supports_motd(id)
{
    show_motd(id, "addons/amxmodx/configs/MotdHelpCommands/supports_motd.html", "投诉举报及求助管理员");
    return PLUGIN_HANDLED
}

public vip_privilege_motd(id)
{
    show_motd(id, "addons/amxmodx/configs/MotdHelpCommands/vip_privilege_motd.html", "会员特权");
    return PLUGIN_HANDLED
}

public chat_commands_motd(id)
{
    show_motd(id, "addons/amxmodx/configs/MotdHelpCommands/chat_commands_motd.html", "HUD 彩色聊天功能");
    return PLUGIN_HANDLED
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /serverdocs", "server_documentations_motd");
    register_clcmd("say /supports", "supports_motd");
    register_clcmd("say /vipprivilege", "vip_privilege_motd");
    register_clcmd("say /chatcommands", "chat_commands_motd");
}
