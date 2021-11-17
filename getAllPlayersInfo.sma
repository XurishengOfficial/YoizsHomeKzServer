#include <amxmodx>

#define PLUGIN "getAllPlayersInfo"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    register_clcmd( "players", "getAllPlayersInfo" );
}

public getAllPlayersInfo( id ) 
{ 
    new players[32];
    new playersNum = 0;
    new name[32];
    new nameLen = 32;
    new model[32];
    new modelLen = 32;
    new ipStr[64];
    new ipStrLen = 64;
    //将所有player的id保存在数组中 跳过hltv和bot
    client_print(id, print_console,     "=========================================");
    client_print(id, print_console,     " Name               Model               Ip");
    get_players(players, playersNum, "h");
    for(new i = 0; i < 32; ++i) {
        // client_print(id, print_console, "%d", players[i])
        if(players[i] == 0) continue;
        get_user_info(players[i], "name", name, nameLen);
        get_user_info(players[i], "model", model, modelLen);
        get_user_ip(players[i], ipStr, ipStrLen, 0);
        client_print(id, print_console, "# %d %s             %s              %s", players[i], name, model, ipStr);
    }
    client_print(id, print_console,     "=========================================");
}

