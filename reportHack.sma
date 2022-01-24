#include <amxmodx>
#include <amxmisc>
#include <colorchat>

#define PLUGIN "ReportHack"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

#define MAX_PLAYER_NAME  32
#define MAX_PLAYERS 32

//读取当前玩家列表 并选择其中某位玩家 并写入到data/reportHack/reportHack.log文件
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /rp", "Report_Menu");
    register_clcmd("rp", "Report_Menu");
    // set_task(607.0, "taskPrintInfo", 0, _, _, "b");
}

public taskPrintInfo() {
    ColorChat(0, GREEN,  "[Holo]^x01如果发现有玩家作弊或者SR异常, 输入 ^x03/rp ^x01进行^x03举报^x01,管理员会定期处理,感谢您的支持");
    // client_print(0, print_chat, "如果发现有玩家作弊或者SR异常,输入/rp进行举报,感谢支持!");
}
public Report_Menu( id ) 
{ 
    new menu = menu_create("请选择要举报的玩家或者SR", "report_menu");
    
    new name[32];
    new steamId[32];
    new players[32];
    new playersNum = 0;
    get_players(players, playersNum, "h");
    for(new i = 0; i < 32; ++i) {
        // client_print(id, print_console, "%d", players[i])
        if(players[i] == 0) continue;
        get_user_info(players[i], "name", name, charsmax(name));
        get_user_authid(players[i], steamId, charsmax(steamId));
        menu_additem( menu, name, steamId, 0 ); 
        client_print(id, print_console, "# %d %s", i, name);
    }
    // for(new i = 1; i <= 32; ++i) {
    //     if(!is_user_connected(i))   continue;
    //     server_print("%d", i);
    //     get_user_info(id, "name", name, charsmax(name));
    //     get_user_authid(id, steamId, charsmax(steamId));
    //     menu_additem( menu, name, steamId, 0 ); 
    //     client_print(id, print_console, "# %d %s", i, name);
    // }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    menu_display( id, menu, 0 ); 
} 

public report_menu(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED;
    }
    //name->hackName
    //info->hackSteamId
    new hackName[32]
    new access, callback;
    new hackSteamId[32];
    new mapName[32];
    menu_item_getinfo(menu, item, access, hackSteamId, charsmax(hackSteamId), hackName, charsmax(hackName), callback);
    get_mapname(mapName, charsmax(mapName));

    new datadir[64];
    new reportHackFilePath[64];
    // get_basedir(basedir, charsmax(basedir));             addons/amxmodx
    // get_configsdir(configsdir, charsmax(configsdir));    addons/amxmodx/configs
    // get_datadir(datadir, charsmax(datadir));             addons/amxmodx/data
    // server_print("%s, %s, %s", basedir, configsdir, datadir);

    get_datadir(datadir, charsmax(datadir));
    formatex(reportHackFilePath, charsmax(reportHackFilePath), "%s/reportHack/reportHack.log", datadir);
    
    // new fp = fopen(reportHackFilePath, "a");
    // if(!fp) {
    //     log_amx("[%s.amxx]: %s open failed", PLUGIN, reportHackFilePath);
    //     server_print("[%s.amxx]: %s open failed", PLUGIN, reportHackFilePath);
    //     return PLUGIN_CONTINUE;
    // }

    // server_print("[%s.amxx]: %s open success!", PLUGIN, reportHackFilePath);
    new reportName[32];
    new reportSteamId[32];
    get_user_info(id, "name", reportName, charsmax(reportName));
    get_user_authid(id, reportSteamId, charsmax(reportSteamId));
    //非admin则仅仅是记录在案
    if(!is_user_admin(id)) {
        log_to_file(reportHackFilePath, "^"%s^" <%s> report ^"%s^" <%s> on the map: ^"%s^"", reportName, reportSteamId, hackName, hackSteamId, mapName);
        // fprintf(fp, "%s ^"\n^"", "Test");
        // fprintf(fp, "^"%s^" < %s > report ^"%s^" < %s > on the map: ^"%s^"", reportName, reportSteamId, hackName, hackSteamId, mapName);
        // fclose(fp);
        client_print(id, print_chat, "您的反馈已记录在服务器，管理员不定期进行处理，感谢支持!");
    }
    //是admin 如果举报的是BOT则直接删除本地的bot文件和排名文件
    else {
        if(equal(hackSteamId, "BOT")) {
            new configdir[64];
            new top15FilePath[128];
            get_configsdir(configdir, charsmax(configdir));
            if(equal(hackName, "[N", 2))
                formatex(top15FilePath, charsmax(top15FilePath), "%s/kz/top15/Noob_%s.cfg", configdir, mapName);
            if(equal(hackName, "[P", 2))
                formatex(top15FilePath, charsmax(top15FilePath), "%s/kz/top15/pro_%s.cfg", configdir, mapName);
            server_print("============================");
            server_print("%s", configdir);
            server_print("%s", top15FilePath);
            
            if(file_exists(top15FilePath)) {
                server_print("file exists!");
                if(delete_file(top15FilePath)) {
                    server_print("delete file success!");
                    client_print(id, print_chat, "对应地图的排行已重置, 重启服务器生效!");
                }
                else {
                    server_print("delete file failed!"); 
                    client_print(id, print_chat, "删除相应地图排行文件失败!");
                }
            }
            else {
                server_print("file %s NOT exists!", top15FilePath);
                client_print(id, print_chat, "相关地图排行文件不存在, 删除失败!");
            }
            server_print("============================");
        }
    }
    return PLUGIN_CONTINUE;
}