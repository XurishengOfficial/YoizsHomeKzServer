#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

#define PLUGIN "replaceModel"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

#define MAX_PLAYER_NAME = 32

stock const m_pPlayer = 41;
// new g_has_set_model[33];
const TaskIndex = 1735

new MAO1[] = "models/player/azuki/azuki.mdl";
new MAO2[] = "models/player/coconut/coconut.mdl";

// enum PLAYER_INFO{
//     steamId[32],
//     player_mdl[64],
//     v_usp_mdl[64],
//     p_usp_mdl[64],
//     v_knife_mdl[64],
//     p_knife_mdl[64]
// }; 

// 建立各种类型的哈希表 方便查询
new Trie:steamId_player;
new Trie:steamId_v_usp;
new Trie:steamId_p_usp;
new Trie:steamId_v_knife;
new Trie:steamId_p_knife;

public plugin_precache() {
    readCfgFile();
    precache_model(MAO1);
    precache_model(MAO2);
}
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

    // "steam_id" "usp" "v_usp.mdl" "p_usp.mdl"
    // "steam_id" "knife" "v_knife.mdl" "p_knife.mdl"
    // "steam_id" "player" "player.mdl"
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
            // server_print("%s ==> %s", _vipSteamId, _player);
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
    // RegisterHam(Ham_Spawn, "player" , "fw_playerSpawn", 1);
}

// public fw_playerSpawn(id) {
//     if(is_user_alive(id) || g_has_set_model[id])
//         return;
//     new args[1];
//     args[0] = id;
//     set_task(1.0, "changeModel", 0, args, 1);
// }
public client_putinserver(id) {
    new args[1];
    args[0] = id;
    set_task(1.0, "changeModel", 0, args, 1);
}

public client_disconnect(id) {
    
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
    new v_usp[64];
    new p_usp[64];
    
    new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    new steamId[64];
    get_user_authid(id, steamId, 64);

    /*
        设置第一人称模型 V模
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, USP_V_MODEL_VIP);
        设置第三人称模型 P模
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_weaponmodel2, USP_P_MODEL_VIP)
    */
    if(TrieKeyExists(steamId_v_usp, steamId)) {
        TrieGetString(steamId_v_usp, steamId, v_usp, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, v_usp);
        // server_print("##################### %d hamusp", id);
    }
    if(TrieKeyExists(steamId_p_usp, steamId)) {
        TrieGetString(steamId_p_usp, steamId, p_usp, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_weaponmodel2, p_usp);
    }
}

public hamknife(iEntity)
{
    new v_knife[64];
    new p_knife[64];
    
    new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    new steamId[64];
    get_user_authid(id, steamId, 64);

    if(TrieKeyExists(steamId_v_knife, steamId)) {
        TrieGetString(steamId_v_knife, steamId, v_knife, 64);
        set_pev(get_pdata_cbase( iEntity, 41, 4 ), pev_viewmodel2, v_knife);
        // server_print("# %d hamknife", id);
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
    new modelName[64];
    new name[64];
    get_user_authid(id, steamId, 64);
    get_user_name(id, name, charsmax(name));
    client_cmd(id, "cl_minmodels 0");
    server_print("#%d %s %s", id, steamId, name);
    // if(is_user_bot(id)) {
    //     //NUB BOT
    //     if(equal(name, "[N", 2) && TrieKeyExists(steamId_player, "NUB")) {
    //         TrieGetString(steamId_player, "NUB", modelName, 64);
    //         server_print("========== NUB ========== %s", modelName);
    //         // cs_set_user_model(id, "coconut");
    //     }
    //     //WR & PRO
    //     else if(equal(name, "[P", 2) && TrieKeyExists(steamId_player, "PRO")) {
    //         TrieGetString(steamId_player, "PRO", modelName, 64);
    //         server_print("========== PRO ========== %s", modelName);
    //         // cs_set_user_model(id, "azuki");
    //     }
    //     return;
    // }
    if(TrieKeyExists(steamId_player, steamId)) {
        TrieGetString(steamId_player, steamId, modelName, 64);
        // set_user_info(id, "model", modelName); //单独使用该命令无效
        server_print("%s    %s", steamId, modelName);
        cs_set_user_model(id, modelName);
        // server_print("#%d 玩家的模型已被设置为: %s", id, modelName);
        // g_has_set_model[id] = true;
    }
    // else
    //     server_print("==============Key-value not exist");
    // server_print("==============changeModel is called!");
}