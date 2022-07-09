#include <amxmodx>
#include <amxmisc>
#include <colorchat>

#define PLUGIN "ReportHack"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

#define MAX_PLAYER_NAME  32
#define MAX_PLAYERS 32
#define KZ_ADMIN ADMIN_IMMUNITY

new rpInfo[33][256];
new prefix[] = "[KZ]";
new datadir[64];
new reportHackFilePath[64];
//读取当前玩家列表 并选择其中某位玩家 并写入到data/reportHack/reportHack.log文件

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /rp", "Report_Menu");
    register_clcmd("rp", "Report_Menu");
    register_clcmd("say_team /rp", "Report_Menu");
    register_clcmd("_rpHackReason", "rpHackReason")

    get_datadir(datadir, charsmax(datadir));
    formatex(reportHackFilePath, charsmax(reportHackFilePath), "%s/reportHack/reportHack.log", datadir);

    set_task(600.0, "taskPrintInfo", 0, _, _, "b");
}

stock createRpFile() {
    new f = fopen(reportHackFilePath, "wt");
    fclose(f);
}

public taskPrintInfo() {
    ColorChat(0, GREEN,  "[Holo]^x01如果发现有玩家^x03作弊^x01或者^x03SR异常^x01, 输入 ^x03/rp ^x01进行^x03举报^x01并^x03填写举报原因.");
}

public Report_Menu( id ) 
{ 
    new menu;
    if(is_user_kz_admin(id))
        menu = menu_create("\rKreedz Report Hack Menu^n\dCode Created by Azuki daisuki~^n^n\y#请选择要举报的玩家或者SR^n\r#超级管理员举报SR会直接重置该地图的排名信息和SRBOT信息^n\y#选择完成后请输入举报理由", "report_menu");
    else
        menu = menu_create("\rKreedz Report Hack Menu^n\dCode Created by Azuki daisuki~^n^n\y#请选择要举报的玩家或者SR^n\y#选择完成后请输入举报理由", "report_menu");
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

stock bool: is_user_kz_admin(id) {
    return get_user_flags(id) & KZ_ADMIN;
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

    // new datadir[64];
    // new reportHackFilePath[64];
    // get_basedir(basedir, charsmax(basedir));             addons/amxmodx
    // get_configsdir(configsdir, charsmax(configsdir));    addons/amxmodx/configs
    // get_datadir(datadir, charsmax(datadir));             addons/amxmodx/data
    // server_print("%s, %s, %s", basedir, configsdir, datadir);

    // get_datadir(datadir, charsmax(datadir));
    // formatex(reportHackFilePath, charsmax(reportHackFilePath), "%s/reportHack/reportHack.log", datadir);
    
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
    //非BOT则仅仅是记录在案 
    formatex(rpInfo[id], 255, "^"%s^" <%s> report ^"%s^" <%s> on the map: ^"%s^"", reportName, reportSteamId, hackName, hackSteamId, mapName);
    // log_to_file(reportHackFilePath, "^"%s^" <%s> report ^"%s^" <%s> on the map: ^"%s^"", reportName, reportSteamId, hackName, hackSteamId, mapName);
    // fprintf(fp, "%s ^"\n^"", "Test");
    // fprintf(fp, "^"%s^" < %s > report ^"%s^" < %s > on the map: ^"%s^"", reportName, reportSteamId, hackName, hackSteamId, mapName);
    // fclose(fp);
    client_cmd(id, "messagemode _rpHackReason");
    //是admin 如果举报的是BOT则直接删除本地的bot文件和排名文件
    if(is_user_kz_admin(id)) {
        if(equal(hackSteamId, "BOT")) {
            new rpFilePrefix[] = "SR"
            new configdir[64];
            new top15FilePath[128];
            new botFilePath[128];
            new rankFileType[8];    //1 PRO 2 NUB
            get_configsdir(configdir, charsmax(configdir));

            if(equal(hackName, "[N", 2)) {
                formatex(top15FilePath, charsmax(top15FilePath), "%s/kz/top15/Noob_%s.cfg", configdir, mapName);
                formatex(botFilePath, charsmax(botFilePath), "%s/records/Nub/%s.txt", datadir, mapName);
                formatex(rankFileType, charsmax(rankFileType), "NUB");
            }
            else if(equal(hackName, "[P", 2)) {
                formatex(top15FilePath, charsmax(top15FilePath), "%s/kz/top15/pro_%s.cfg", configdir, mapName);
                formatex(botFilePath, charsmax(botFilePath), "%s/records/Pro/%s.txt", datadir, mapName);
                formatex(rankFileType, charsmax(rankFileType), "PRO");
            }
            
            // 删除RANK文件
            if(file_exists(top15FilePath)) {
                server_print("%s exists!", top15FilePath);
                if(delete_file(top15FilePath)) {
                    server_print("delete file %s success!", top15FilePath);
                    log_to_file(reportHackFilePath, "[%s] Success: Admin ^"%s^" <%s> Deleted [%s RANK] info on the map: ^"%s^"", rpFilePrefix, reportName, reportSteamId, rankFileType, mapName);
                    client_print(id, print_chat, "对应地图的排行已重置, 重启服务器生效!");
                }
                else {
                    server_print("delete file %s failed!", top15FilePath); 
                    log_to_file(reportHackFilePath, "[%s] Error: Admin: ^"%s^" <%s> Deleted [%s RANK] info on the map: ^"%s^" Failed!!! Reason: Delete Fail!", rpFilePrefix, reportName, reportSteamId, rankFileType, mapName);
                    client_print(id, print_chat, "删除相应地图排行文件失败!");
                }
            }
            else {
                server_print("file %s NOT exists!", top15FilePath);
                client_print(id, print_chat, "相关地图排行文件不存在, 删除失败!");
                log_to_file(reportHackFilePath, "[%s] Error: Admin: ^"%s^" <%s> Deleted [%s RANK] info on the map: ^"%s^" Failed!!! Reason: File DO NOT EXIST", rpFilePrefix, reportName, reportSteamId, rankFileType, mapName);
            }

            // 删除BOT文件
            if(file_exists(botFilePath)) {
                server_print("%s exists!", botFilePath);
                if(delete_file(botFilePath)) {
                    server_print("delete file %s success!", botFilePath);
                    log_to_file(reportHackFilePath, "[%s] Success: Admin ^"%s^" <%s> Deleted ^"%s^" <%s> on the map: ^"%s^"", rpFilePrefix, reportName, reportSteamId, hackName, hackSteamId, mapName);
                    client_print(id, print_chat, "对应地图的Demo已重置, 重启服务器生效!");
                }
                else {
                    server_print("delete file %s failed!", botFilePath); 
                    log_to_file(reportHackFilePath, "[%s] Error: Admin: ^"%s^" <%s> Deleted ^"%s^" <%s> on the map: ^"%s^" Failed!!! Reason: Delete Fail!", rpFilePrefix, reportName, reportSteamId, hackName, hackSteamId, mapName);
                    client_print(id, print_chat, "删除相应地图Demo文件失败!");
                }
            }
            else {
                server_print("file %s NOT exists!", botFilePath);
                client_print(id, print_chat, "相关地图Demo文件不存在, 删除失败!")
                log_to_file(reportHackFilePath, "[%s] Error: Admin: ^"%s^" <%s> Deleted ^"%s^" <%s> on the map: ^"%s^" Failed!!! Reason: File DO NOT EXIST", rpFilePrefix, reportName, reportSteamId, hackName, hackSteamId, mapName)
            }
        }
    }

    ColorChat(id, Color:5, "^x04%s^x01 请输入^x03 举报的理由...", prefix);
    ColorChat(id, Color:5, "^x04%s^x01 请输入^x03 举报的理由...", prefix);
    ColorChat(id, Color:5, "^x04%s^x01 请输入^x03 举报的理由...", prefix);
    return PLUGIN_CONTINUE;
}

public rpHackReason(id) {
    new szReason[128];
    read_args(szReason, charsmax(szReason));
    remove_quotes(szReason);
    format(rpInfo[id], 255, "%s, reason:[ %s ]", rpInfo[id], szReason);
    // client_print(id, print_chat, "%s", rpInfo[id]);
    if(!file_exists(reportHackFilePath))
        createRpFile();
    if(file_exists(reportHackFilePath)) {
        if(is_user_kz_admin(id))
            log_to_file(reportHackFilePath, "[Admin] %s", rpInfo[id]);
        else {
            log_to_file(reportHackFilePath, "[Player] %s", rpInfo[id]);
        }
        client_print(id, print_chat, "您的反馈已记录, 管理员将会不定期处理, 感谢您的支持!");
    }  
    else
        log_amx("Create ReportHack File Failed!");

    return PLUGIN_HANDLED;
}