#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <colorchat>

#define PLUGIN "replaceModel"
#define VERSION "1.0"
#define AUTHOR "Azuki dasuki~"


#define MAX_PLAYER_NAME = 32

stock const m_pPlayer = 41;
// new g_has_set_model[33];

new AZUKI[] = "models/player/azuki/azuki.mdl";
new COCONUT[] = "models/player/coconut/coconut.mdl";
new DIONA[] = "models/player/diona_yoizHome/diona_yoizHome.mdl";

//每次进行添加修改的时候记得同时修改N
new PLAYER_N = 6;
new PLAYER[][] = {
    "azuki",
    "coconut",
    "eve",
    "x _admin",
    "xj_user",
    "akaiHaato"
}

new PLAYER_MODEL[][] = {
    "models/player/azuki/azuki.mdl",
    "models/player/coconut/coconut.mdl",
    "models/player/eve_in_cs_16/eve_in_cs_16.mdl",
    "models/player/xj_admin/xj_admin.mdl",
    "models/player/xj_user/xj_user.mdl",
    "models/player/akaiHaato/akaiHaato.mdl"
}

new USP_N = 9;
new USP[][] = {
    "usp_cyrex",
    "usp_hyper_beast",
    "usp_oil_filter",
    "usp_red_dragon",
    "usp_s_kill_confirmed",
    "usp_s_orion",
    "usp_sakura",
    "usp_sakura_black",
    "usp_sakura_hd"
}
new V_USP[][] = {
    "models/usp/usp_cyrex/v_usp.mdl",
    "models/usp/usp_hyper_beast/v_usp.mdl",
    "models/usp/usp_oil_filter/v_usp.mdl",
    "models/usp/usp_red_dragon/v_usp.mdl",
    "models/usp/usp_s_kill_confirmed/v_usp.mdl",
    "models/usp/usp_s_orion/v_usp.mdl",
    "models/usp/usp_sakura/v_usp.mdl",
    "models/usp/usp_sakura_black/v_usp.mdl",
    "models/usp/usp_sakura_hd/v_usp.mdl"
}

new P_USP[][] = {
    "models/usp/usp_cyrex/p_usp.mdl",
    "models/usp/usp_hyper_beast/p_usp.mdl",
    "models/usp/usp_oil_filter/p_usp.mdl",
    "models/usp/usp_red_dragon/p_usp.mdl",
    "models/usp/usp_s_kill_confirmed/p_usp.mdl",
    "models/usp/usp_s_orion/p_usp.mdl",
    "models/usp/usp_sakura/p_usp.mdl",
    "models/usp/usp_sakura_black/p_usp.mdl",
    "models/usp/usp_sakura_hd/p_usp.mdl"
}

new KNIFE_N = 8;
new KNIFE[][] = {
    "csgo_bowie_knife",
    "csgo_butterfly_knife",
    "csgo_karambit",
    "csgo_m9_bayonet",
    "knife_default_fade",
    "knife_dragon_wolf",
    "knife_dragon_xun",
    "knife_sakura"
}
new V_KNIFE[][] = {
    "models/knife/csgo_bowie_knife/v_knife.mdl",
    "models/knife/csgo_butterfly_knife/v_knife.mdl",
    "models/knife/csgo_karambit/v_knife.mdl",
    "models/knife/csgo_m9_bayonet/v_knife.mdl",
    "models/knife/knife_default_fade/v_knife.mdl",
    "models/knife/knife_dragon_wolf/v_knife.mdl",
    "models/knife/knife_dragon_xun/v_knife.mdl",
    "models/knife/knife_sakura/v_knife.mdl"
}

new P_KNIFE[][] = {
    "models/knife/csgo_bowie_knife/p_knife.mdl",
    "models/knife/csgo_butterfly_knife/p_knife.mdl",
    "models/knife/csgo_karambit/p_knife.mdl",
    "models/knife/csgo_m9_bayonet/p_knife.mdl",
    "models/knife/knife_default_fade/p_knife.mdl",
    "models/knife/knife_dragon_wolf/p_knife.mdl",
    "models/knife/knife_dragon_xun/p_knife.mdl",
    "models/knife/knife_sakura/p_knife.mdl"
}

// 建立各种类型的哈希表 方便查询
new Trie:steamId_player;
new Trie:steamId_v_usp;
new Trie:steamId_p_usp;
new Trie:steamId_v_knife;
new Trie:steamId_p_knife;

//保存当前已设置的信息
new bool: G_PLAYER_SET[33];
new bool: G_USP_SET[33][2];
new bool: G_KNIFE_SET[33][2];

new bool: g_bHideUspAndKnife[33];

//读取VIP的默认配置文件
public readCfgFile() {
    steamId_player = TrieCreate();
    steamId_v_usp = TrieCreate();
    steamId_p_usp = TrieCreate();
    steamId_v_knife = TrieCreate();
    steamId_p_knife = TrieCreate();
    new cfgDir[64];
    new cfgPath[64];
    get_localinfo("amxx_configsdir", cfgDir, charsmax(cfgDir));
    formatex(cfgPath, charsmax(cfgPath), "%s/modelsChange.cfg", cfgDir);
    
    new const ReadFlags[] = "rt"
    new FilePointer = fopen( cfgPath, ReadFlags );
    //检查文件是否打开成功
    if(!FilePointer) {
        server_print("modelsChange.cfg open failed at %s, please check", cfgPath);
        log_amx("[%s.amxx]: modelsChange.cfg open failed at %s, please check", PLUGIN, cfgPath);
        //PLUGIN_HANDLED 1
        //PLUGIN_CONTINUE 0
        return PLUGIN_HANDLED;
    }
    new FileData[256];
    new _vipSteamId[64];
    //接收文件夹名字
    new _player[64];    //保存玩家模型名字
    new _player_Path[64];
    new _player_T_Path[64];
    new _usp[64];
    new _knife[64];
    //保存p模 v模
    new p_usp[64];
    new v_usp[64];

    new p_knife[64];
    new v_knife[64];
    
    //Returns 1 if the file is ended, 0 otherwise
    while(!feof(FilePointer)) {
        fgets(FilePointer, FileData, charsmax(FileData));
        trim(FileData);

        if(!FileData[0] || FileData[0] == ';' || FileData[0] == '#' || FileData[0] == '/')
        {
            continue
        }
        parse
        (
            FileData,
            _vipSteamId, charsmax(_vipSteamId),
            _player, charsmax(_player),
            _usp, charsmax(_usp),
            _knife, charsmax(_knife)
        )
        // server_print("%s, %s, %s, %s", _vipSteamId, _player_mdl, _usp_mdl, _knife_mdl);
        // "models/player/_player/_player.mdl"
        // "models/_usp/p__usp.mdl"
        // "models/_usp/v__usp.mdl"
        
        formatex(_player_T_Path, charsmax(_player_T_Path), "models/player/%s/%sT.mdl", _player, _player);
        formatex(_player_Path, charsmax(_player_Path), "models/player/%s/%s.mdl", _player, _player);
        
        formatex(v_usp, charsmax(v_usp), "models/usp/%s/v_usp.mdl", _usp);
        formatex(p_usp, charsmax(p_usp), "models/usp/%s/p_usp.mdl", _usp);

        formatex(v_knife, charsmax(v_knife), "models/knife/%s/v_knife.mdl", _knife, _knife);
        formatex(p_knife, charsmax(p_knife), "models/knife/%s/p_knife.mdl", _knife, _knife);

        // server_print("%s", _vipSteamId);
        // server_print("%s", _player);
        // server_print("%s", v_usp);
        // server_print("%s", p_usp);
        // server_print("%s", v_knife);
        // server_print("%s", p_knife);

        if(file_exists(_player_Path)) {
            precache_model(_player_Path);
            TrieSetString(steamId_player, _vipSteamId, _player);
            if(file_exists(_player_T_Path)) 
                precache_model(_player_T_Path);
        }
        
        if(file_exists(v_usp)) {
            precache_model(v_usp);
            TrieSetString(steamId_v_usp, _vipSteamId, v_usp);
        }
        if(file_exists(p_usp)) {
            precache_model(p_usp);
            TrieSetString(steamId_p_usp, _vipSteamId, p_usp);
        }
        if(file_exists(v_knife)) {
            precache_model(v_knife);
            TrieSetString(steamId_v_knife, _vipSteamId, v_knife);
        }
        if(file_exists(p_knife)) {
            precache_model(p_knife);
            TrieSetString(steamId_p_knife, _vipSteamId, p_knife);
        }
    }
    return PLUGIN_CONTINUE;
}

public plugin_precache() {
    readCfgFile();
    precache_model(AZUKI);
    precache_model(COCONUT);
    precache_model(DIONA);

    //===========================================
    //         #PLAYER SKIN MENU PRECACHE
    //===========================================
    // //PLAYER
    // for(new i = 0; i < PLAYER_N; ++i) {
    //     if(!file_exists(PLAYER_MODEL[i])) continue;
    //     precache_model(PLAYER_MODEL[i]);
    // }

    // //USP
    // for(new i = 0; i < USP_N; ++i) {
    //     if(!file_exists(V_USP[i])) continue;
    //     precache_model(V_USP[i]);
    // }
    
    // for(new i = 0; i < USP_N; ++i) {
    //     if(!file_exists(P_USP[i])) continue;
    //     precache_model(P_USP[i]);
    // }

    // //KNIFE
    // for(new i = 0; i < KNIFE_N; ++i) {
    //     if(!file_exists(V_KNIFE[i])) continue;
    //     precache_model(V_KNIFE[i]);
    // }
    
    // for(new i = 0; i < KNIFE_N; ++i) {
    //     if(!file_exists(P_KNIFE[i])) continue;
    //     precache_model(P_KNIFE[i]);
    // }
}

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
    // RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");

    // 玩家菜单是否能更换皮肤
    // register_clcmd( "say /myskin",     "SkinsMenu" );
    // register_clcmd( "/myskin",     "SkinsMenu" );
    // register_clcmd( "say /mod",     "SkinsMenu" );
    // register_clcmd( "/mod",     "SkinsMenu" );    // RegisterHam(Ham_Spawn, "player" , "fw_playerSpawn", 1);
    set_task(673.0, "taskPrintInfo", 0, _, _, "b");

    register_cvar("rt", "0");
    register_cvar("rr", "0");
    register_cvar("rg", "165");
    register_cvar("rb", "0");
    register_cvar("rm", "0");

    register_clcmd( "say /hw",     "hideUspAndKnife" );
}

public taskPrintInfo() {
    ColorChat(0, TEAM_COLOR,  "^x04[News] ^x01输入 ^x03/hw ^x01可以隐藏当前武器, 仅限USP和Knife, 切换武器后生效!"); 
}

// 防止BOT/玩家摔死
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) {
    if(is_user_alive(victim)) {
        set_user_godmode(victim, 1);
    }
}

public hideUspAndKnife(id)
{
    g_bHideUspAndKnife[id] = !g_bHideUspAndKnife[id];
    set_pev(id, pev_viewmodel, ""); // 切枪就会被刷走
}

public client_putinserver(id) {

    //设置模型需要进行延时处理
    new args[1];
    args[0] = id;
    set_task(1.0, "changeModel", 0, args, 1);
    g_bHideUspAndKnife[id] = false;
}

public client_disconnect(id) {
    G_PLAYER_SET[id] = false;
    G_USP_SET[id][0] = false;
    G_USP_SET[id][1] = false;
    G_KNIFE_SET[id][0] = false;
    G_KNIFE_SET[id][1] = false;
}

public hamusp(iEntity)
{
    /*
        获取玩家id的：
        【1】new id = get_pdata_cbase(iEntity, m_pPlayer, 4) ，m_pPlayer=41,还有后面4都是怎么来的
        【2】static id;id=pev(iEntity,pev_owner) ，这个懂，但是static id ，为什么不 new id =
        【3】new id = get_pdata_cbase(iEntity, 373) //373.怎么来的
        还有武器的CSW_*的
        【4】 get_pdata_int(iEntity, 43, 4) 这个后面43，4怎么来的
    */
    //由于changeModel设置了时间差 BOT的切枪事件会早于changeModel中设置G_USP_SET等值 从而导致无法正常加载 故直接在这加载即可
    // new id = get_pdata_cbase(iEntity, m_pPlayer, 4);

    // if(is_user_bot(id)) {
    //     if(TrieKeyExists(steamId_v_usp, "BOT")) {
    //         new v_usp[64];
    //         TrieGetString(steamId_v_usp, "BOT", v_usp, 63);
    //         set_pev(id, pev_viewmodel2, v_usp);
    //     }
    //     if(TrieKeyExists(steamId_p_usp, "BOT")) {
    //         new p_usp[64];
    //         TrieGetString(steamId_p_usp, "BOT", p_usp, 63);
    //         set_pev(id, pev_weaponmodel2, p_usp);
    //     }
    //     return;
    // }
    // if(G_USP_SET[id][0]) {
    //     set_pev(id, pev_viewmodel2, USP[id][0]);
    // }
    // if(G_USP_SET[id][1])
    //     set_pev(id, pev_weaponmodel2, USP[id][1]);
    // ========================================
    // 老版本写法
    // ========================================
    new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    new v_usp[64];
    new p_usp[64]; 
    new steamId[64];
    get_user_authid(id, steamId, 64);
    /*
        设置第一人称模型 V模
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, USP_V_MODEL_VIP);
        设置第三人称模型 P模
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_weaponmodel2, USP_P_MODEL_VIP)
    */
    if(is_user_bot(id)) {
        new name[64];
        get_user_name(id, name, charsmax(name));
        if(equal(name, "[PRO]", 5)) {
            formatex(steamId, charsmax(steamId), "PRO");
        }
        else if(equal(name, "[NUB]", 5)) {
            formatex(steamId, charsmax(steamId), "NUB");
        }
    }
    if(g_bHideUspAndKnife[id])
    {
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, "");
        return;
    }
    if(TrieKeyExists(steamId_v_usp, steamId)) {
        TrieGetString(steamId_v_usp, steamId, v_usp, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, v_usp);
    }
    if(TrieKeyExists(steamId_p_usp, steamId)) {
        TrieGetString(steamId_p_usp, steamId, p_usp, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_weaponmodel2, p_usp);
    }
}

public hamknife(iEntity)
{
    // new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    // if(is_user_bot(id)) {
    //     if(TrieKeyExists(steamId_v_knife, "BOT")) {
    //         new v_knife[64];
    //         TrieGetString(steamId_v_knife, "BOT", v_knife, 63);
    //         set_pev(id, pev_viewmodel2, v_knife);
    //     }
    //     if(TrieKeyExists(steamId_p_knife, "BOT")) {
    //         new p_knife[64];
    //         TrieGetString(steamId_p_knife, "BOT", p_knife, 63);
    //         set_pev(id, pev_weaponmodel2, p_knife);
    //     }
    //     return;
    // }
    // if(G_KNIFE_SET[id][0]) {
    //     set_pev(id, pev_viewmodel2, KNIFE[id][0]);
    // }
    // if(G_KNIFE_SET[id][1])
    //     set_pev(id, pev_weaponmodel2, KNIFE[id][1]);
    new v_knife[64];
    new p_knife[64];
    
    new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    new steamId[64];
    get_user_authid(id, steamId, 64);
    if(is_user_bot(id)) {
        new name[64];
        get_user_name(id, name, charsmax(name));
        if(equal(name, "[PRO]", 5)) {
            formatex(steamId, charsmax(steamId), "PRO");
        }
        else if(equal(name, "[NUB]", 5)) {
            formatex(steamId, charsmax(steamId), "NUB");
        }
    }
    if(g_bHideUspAndKnife[id])
    {
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, "");
        return;
    }
    if(TrieKeyExists(steamId_v_knife, steamId)) {
        TrieGetString(steamId_v_knife, steamId, v_knife, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, v_knife);
    }
    if(TrieKeyExists(steamId_p_knife, steamId)) {
        TrieGetString(steamId_p_knife, steamId, p_knife, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_weaponmodel2, p_knife);
    }
}

public changeModel(args[]) {
// public changeModel(id) {
    new id = args[0];
    new steamId[64];
    new name[64];
    get_user_authid(id, steamId, 64);
    get_user_name(id, name, charsmax(name));
    client_cmd(id, "cl_minmodels 0");
    server_print("#%d %s %s", id, steamId, name);
    if(is_user_bot(id)) {
        //NUB BOT
        if(equal(name, "[PRO]", 5)) {
            formatex(steamId, charsmax(steamId), "PRO");
        }
        else if(equal(name, "[NUB]", 5)) {
            formatex(steamId, charsmax(steamId), "NUB");
        }
        //WR & PRO
            // cs_set_user_model(id, "azuki");
        // G_PLAYER_SET[id] = true;
        // return;
    }

    //设置玩家模型 如果已经设置
    if(TrieKeyExists(steamId_player, steamId)) {
        new player[64];
        TrieGetString(steamId_player, steamId, player, 63);
        cs_set_user_model(id, player);
    }
}

public SkinsMenu( id ) 
{ 
    if(!is_user_alive(id)) {
        client_print(id, print_center, "请复活后再使用该命令");
        return;
    }
    new title[256];
    formatex(title, charsmax(title), "\w#\rSkin Menu \yver \w1.0 \d by Azuki dasuki~ ^n\dPowered \wby ^n    \yhttps://gamebanana.com/^n    \yhttps://www.amxmodx.org/");

    new menu = menu_create(title, "SkinsMenuHandler") 
    /*
        menu_additem(menu,const text[],const info[]="",access=0,callback=-1)
    */
    
    menu_additem( menu, "人物皮肤", "1", 0 ); 
    menu_additem( menu, "手枪皮肤", "2", 0 ); 
    menu_additem( menu, "刀皮肤", "3", 0 ); 
    menu_addblank( menu, 0);
    menu_additem( menu, "切换视角", "9", 0 ); 
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    /*
        menu_display(id, menu, page=0)
        id 玩家索引
        menu 菜单句柄
        page = 0 默认显示第一页
    */
    menu_display( id, menu, 0 ); 
} 

public SkinsMenuHandler(id, menu, item)
{
    // 选择退出时 销毁菜单
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new info[3]
    new access, callback;

    menu_item_getinfo(menu, item, access, info, 2, _, _, callback)
   
    new key = str_to_num(info)

    switch(key)
    {
        case 1:
        {
            playerSkinMemu(id);
        }
        case 2:
        {
            uspSkinMemu(id);
            
        }
        case 3:
        {
            knifeSkinMemu(id);
        }
        case 9:
        {
            client_cmd(id, "amx_view");
            menu_display( id, menu, 0 ); 
        }
    }
    return PLUGIN_CONTINUE;
}

public playerSkinMemu(id) {
    if(!is_user_alive(id)) {
        client_print(id, print_center, "请复活后再使用该命令");
        return;
    }
	// formatex(hidespec, 63, "隐藏在观察者 - %s",  g_bHideMe[id] ? "\yOn" : "\rOff" )

    new menu = menu_create("请选择需要设置的皮肤种类", "playerSkinMemuHandler");
    new numStr[4];
    for(new i = 0; i < PLAYER_N; ++i) {
        num_to_str(i, numStr, 3);
        menu_additem( menu, PLAYER[i], numStr, 0 ); 
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    menu_display( id, menu, 0 ); 
}

public playerSkinMemuHandler(id, menu, item) {
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        SkinsMenu(id);
        return PLUGIN_HANDLED;
    }
    new info[3];
    new access, callback;
    new authId[64];
    get_user_authid(id, authId, charsmax(authId));

    menu_item_getinfo(menu, item, access, info, 2, _, _, callback)
    new key = str_to_num(info);
    cs_set_user_model(id, PLAYER[key]);
    client_print(id, print_center, "您的人物模型已被修改为%s, 请手动修改视角以查看(技术力不够写不出)", PLAYER[key]);

    TrieSetString(steamId_player, authId, PLAYER[key]);

    menu_destroy(menu);
    SkinsMenu(id);
    return PLUGIN_CONTINUE;
}

public uspSkinMemu(id) {
    if(!is_user_alive(id)) {
        client_print(id, print_center, "请复活后再使用该命令");
        return;
    }
	// formatex(hidespec, 63, "隐藏在观察者 - %s",  g_bHideMe[id] ? "\yOn" : "\rOff" )

    new menu = menu_create("请选择需要设置的皮肤种类", "uspSkinMemuHandler");
    new numStr[4];
    for(new i = 0; i < USP_N; ++i) {
        num_to_str(i, numStr, 3);
        menu_additem( menu, USP[i], numStr, 0 ); 
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    menu_display( id, menu, 0 ); 
}

public uspSkinMemuHandler(id, menu, item) {
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        SkinsMenu(id);
        return PLUGIN_HANDLED;
    }
    new info[3];
    new access, callback;
    new authId[64];
    get_user_authid(id, authId, charsmax(authId));

    menu_item_getinfo(menu, item, access, info, 2, _, _, callback)
    new key = str_to_num(info);
    client_print(id, print_chat, "您的USP模型已被修改为%s", USP[key]);

    TrieSetString(steamId_v_usp, authId, V_USP[key]);
    TrieSetString(steamId_p_usp, authId, P_USP[key]);
    strip_user_weapons(id);
    give_item(id, "weapon_usp");
    give_item(id, "weapon_knife");
    menu_display( id, menu, 0 ); 
    return PLUGIN_CONTINUE;
}

public knifeSkinMemu(id) {
    if(!is_user_alive(id)) {
        client_print(id, print_center, "请复活后再使用该命令");
        return;
    }
	// formatex(hidespec, 63, "隐藏在观察者 - %s",  g_bHideMe[id] ? "\yOn" : "\rOff" )

    new menu = menu_create("请选择需要设置的皮肤种类", "knifeSkinMemuHandler");
    new numStr[4];
    for(new i = 0; i < KNIFE_N; ++i) {
        num_to_str(i, numStr, 3);
        menu_additem( menu, KNIFE[i], numStr, 0 ); 
    }
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    menu_display( id, menu, 0 ); 
}

public knifeSkinMemuHandler(id, menu, item) {
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        SkinsMenu(id);
        return PLUGIN_HANDLED;
    }
    new info[3];
    new access, callback;
    new authId[64];
    get_user_authid(id, authId, charsmax(authId));

    menu_item_getinfo(menu, item, access, info, 2, _, _, callback)
    new key = str_to_num(info);
    client_print(id, print_chat, "您的KNIFE模型已被修改为%s", KNIFE[key]);

    TrieSetString(steamId_v_knife, authId, V_KNIFE[key]);
    TrieSetString(steamId_p_knife, authId, P_KNIFE[key]);
    strip_user_weapons(id);
    give_item(id, "weapon_knife");
    give_item(id, "weapon_usp");
    menu_display( id, menu, 0 ); 
    return PLUGIN_CONTINUE;
}