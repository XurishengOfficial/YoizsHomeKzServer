#include <amxmodx>
#include <colorchat>
#include <amxmisc>
#include <ipseeker>
#define PLUGIN "logInfo"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"


public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
}

public client_putinserver(id) {
    new args[1];
    args[0] = id;
    set_task(1.0, "taskPrintInfo", 0, args, 1);
    // client_print(0, print_chat, "玩家 %s [%s] 加入了游戏", name, ip);
}
public taskPrintInfo(args[]) {
    new id = args[0];
    if(is_user_bot(id)) return;
    new name[32];
    new ip[64];
    new steamId[34];
    new country[64];
    get_user_name(id, name, 32);
    get_user_ip(id, ip, 64, 0);
    get_user_authid(id, steamId, 34);
    ipseeker(ip, _, country, charsmax(country), 1);
    // log_amx("Login: ^"%s<%d><%s><>^" became an admin (account ^"%s^") (access ^"%s^") (address ^"%s^")", name, get_user_userid(id), authid, AuthData, sflags, ip)
    server_print("[logInfo.amxx] Join: ^"%s^" (account ^"%s^") (address ^"%s^") (From ^"%s^") joined the game" , name, steamId, ip, country);
    ColorChat(0, TEAM_COLOR,  "^x04[Holo]^x01玩家 ^x03%s ^x01加入了游戏, 来自^x03%s", name, country);
    // new datadir[64];
    // new logInfoFilePath[64];
    
    // get_datadir(datadir, charsmax(datadir));
    // formatex(logInfoFilePath, charsmax(logInfoFilePath), "%s/logInfo/logInfo.log", datadir);
    // log_to_file(logInfoFilePath, "Join: ^"%s^" (account ^"%s^") (address ^"%s^") (From ^"%s^") joined the game" , name, steamId, ip, country);

    // 广西脚本FW
    // if(equal(name, "E.T", 3) || equal(ip, "180.139", 7) || equal(ip, "180.141", 7)) {
    //     server_cmd("amx_ban ^"%s^" 0", steamId);
    //     server_cmd("amx_banip ^"%s^" 0", steamId);
    //     ColorChat(0, GREEN,  "[Holo]^x01玩家 ^x03%s ^x01[^x03%s^x01]已被服务器封禁", name, ip);
    //     new autoKickFilePath[64];
    //     formatex(autoKickFilePath, charsmax(autoKickFilePath), "%s/autoKick/autoKick.log", datadir);
    //     log_to_file(autoKickFilePath, "Banned: ^"%s^" (account ^"%s^") (address ^"%s^") for 0 mins" , name, steamId, ip);
    // }
}
