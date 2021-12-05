/*
插件原作2.31版本: nucLeaR

此插件我修改的所有功能未针对MySql数据库.(不需要MySql支持即能正常运行 所有数据储存在服务器本地)
在此感谢一些相关人员:
**************************
Acy
SiMen.K
97club.PchUn
Destroman

还有其他插件的一些代码:
kz_arg.amxx
kzdemogds.amxx by gladius
kz_demo.amxx by Kr1zo
mpbhop.amxx
**************************
// 主要添加:

#define KZ_ADMIN ADMIN_IMMUNITY		//标识 [ADMIN] 
#define KZ_LEVEL_VIP ADMIN_LEVEL_C	//标识 [VIP]

1.ADMIN 最高权限是恐怖分子. (必须开启roundendblock模块 防止刷新阵容)
2.自动加入CT.
3.其他武器Climb与Top.
4.玩家互相传送.(和终点传送,保存规则逻辑和保存起点一样 也可以手动保存)
5./wr /cc /nt等多社区记录显示 如果选择自动更新则使用#define KZ_AUTO_DOWNLOAD_WRTXT 手动更新请注释掉此定义, ADMIN控制台输入amx_udwr做为手动更新.
6.传送到终点计时器 在传送菜单.
7.显示WR区域同时显示当前地图Pro No.1,nub No.1,wpn No.1
8.KZ 1v1单跳Climb模式 如果kz_duel.amxx数据库异常或没有使用该插件 必须注释掉 #define KZ_DUEL.
9.AXN模式 \data\kzaxnmaps\amx_maps.ini 配置文件添加AXN地图名字可运行.
10.鼠标准星瞄准玩家以HUD的显示方式获取玩家身份与计时状态.
11.屏蔽开始与摔伤获得武器等一系列没必要的音效.
12.屏蔽原始CS 金钱 计时器 血量护甲 Cvars
13.KZ地图类型显示 (手动设置)
14.双语言文档 可切换双语言(英文||中文)在功能菜单.
15.命令addtime 1 增加当前地图剩余时间.
16.世界纪录与中国记录 完成时间与记录时间相差提示. Cvars 
17.Topcss文件与显示方式 ++Top内显示完成时间与WR时间的相差.
18.玩家进入服务器TAB记分牌实施更新当前地图的完成时间.(判断steamid)
19.Savepos功能 自动保存退出服务器前的计时进度.
20.KZ管理员便捷菜单.
21.Top WEB_URL整理设置 kz_webtop_url "http://kreedz.cn/...?"          网站搭建目录要连接到//http://kreedz.cn/addons/amxmodx/configs/kz/
22.完成地图后当完成时间小于WR时间 会触发godlike音效.
23.slide地图空中可以存点.
24.html css flags images 本地文件addons/amxmodx/configs/kz/目录下

// 主要修改的规则:
1.暂停方式 计时中使用一系列违规功能如(Hook Noclip TpPlayer)等, 为暂停计时可移动 如果恢复计时 则回到原位置.
2.计时器时间显示格式 kz_show_time (1/2)  1=TXT格式 2=HUD格式.//由于HUD通道极少 MAX=4 所以不推荐使用HUD输出显示
3.semiclip同队透明体渐隐渐现(光波不可穿透待优化)
4.Top显示格式为HTML. Top储存数量为100名,(需要WEB服务器路径支持)**(by 97club.PchUn)**


// 主要修复:
1.   0.1秒死亡复活在原点刷Top bug
2.各种暂停中 在Mpbhop 临时起点 Savepos 等一系列bug.
3.控制台某些地图刷 Non Sprite Glowfix 之类的垃圾命令.
4.禁止某地图打开购买菜单.
5.Invis屏蔽玩家模型 观察者与CT切换和运行在观察者的bug.
6.NVG夜视仪在观察者的bug.
7.Savepos自动保存进度功能 与读取的的bug +++wpn15.
8.Savepos保存的进度只能在你最后离开地面的位置.
9.光波卡墙bug失重速度bug.
10.完成后时间与储存在Top的时间相差0.1毫秒的bug 
11.WR时间与官方数据相差0.1毫秒的bug.
12.进服后Top和Tab重新更新统计 name / time等.
13.Topshow 中文与英文字符对齐.


注意 使用addtime功能 必须在amxx.cfg里控制每张地图的时间 mp_timelimit 30.

必须开启orpheu amxx 模块 插件才能正常运行 axn环境支持.

//======================= #更新日志#================================
*2021/11/16
	1.新增PRO和NUB BOT功能
	2.修改夜视仪 提高帧数
*/


#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich> 
#include <message_stocks>
#include <engine>
#include <dhudmessage>
#include <xs>
#include <orpheu_stocks>
#include <sockets>	
#include <string2>//ID字符转换
#include <colorchat1>
#include <geoip>
// #include <kz>

// #define KZ_AUTO_DOWNLOAD_WRTXT
#define KZ_AUTO_JOIN_CT

// #define KZ_DUEL
// #define USE_SQL

#if defined USE_SQL
 #include <sqlx>
#endif

#define MSG MSG_ONE_UNRELIABLE
#define MAX_ENTITYS 900+15*32
#define IsOnLadder(%1) (pev(%1, pev_movetype) == MOVETYPE_FLY)  
#define VERSION "2.31++"
#define LAST_EDIT "2017-1-1"


#define is_user(%1) (1 <= %1 <= get_maxplayers())

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_BOMB    ( 1 << 1 )
#define SCOREATTRIB_VIP  ( 1 << 2 )

#define OFFSET_LINUX 5
const groupNone = 0
new g_iPlayers[32], g_iNum, g_iPlayer
new const g_szAliveFlags[] = "a" 
#define RefreshPlayersList()    get_players(g_iPlayers, g_iNum, g_szAliveFlags) 

#define TASK_HELPINFO	12222
#define TASK_ADMINTEAM 13333

#define KZ_ADMIN ADMIN_IMMUNITY
#define KZ_LEVEL ADMIN_KICK 
#define KZ_LEVEL_VIP ADMIN_LEVEL_C

// UpdateGameName
new szGameName[33]
//.

//Top 100
new const NULLSTR[ ] = ""
new WRTime[501] 
new WRTimes[501]
new NTTimes[501]
#if !defined USE_SQL
new PRO_PATH[100]
new NUB_PATH[100]
new WPN_PATH[100]
new WEB_URL[64]
new kz_webtop_url

#define RANKLEN 2
new num = 100 
#endif

new cvar_respawndelay
//#define TASK_GOPOS	767767


// speclist hide+++
new bool:g_bHideMe[33];
//


// shwo WR
new const e_DownloadLinks[3][] = 
{
	"https://xtreme-jumps.eu/demos.txt",	//XJ
	"https://cosy-climbing.net/demoz.txt",	//Cosy
	"http://ntjump.cn/demos.txt"		//NTjump
}

new kz_wr_diff
new Float:g_flWorldRecordTime[5];
new Float:DiffWRTime[16]
new Float:DiffNTRTime[16]
new norecord;
// new g_szWorldRecordTime[5][16];
new g_szWorldRecordPlayer[5][32];
new g_iWorldRecordsNum;
new g_iNtRecordsNum;
new e_UpdatedNR = 1;
new e_LastUpdate[128];
new e_Buffer[25001]; 
new e_MapName[32]; 
new e_Records_CC[128]; 
new e_Records_WR[128]; 
new e_Records_SU[128]; 
new e_Records_CR[128]; 
new cce_CountryText[128];
new cre_CountryText[128];
new counwr[32];
new councr[32];
new rank[32];
new Pro1message[512];
new Nub1message[512];
new Wpn1message[512]
new kz_type_wr[33];


new const FL_ONGROUND2 = ( FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER |  FL_CONVEYOR | FL_FLOAT )
new const KZ_STARTFILE[] = "start.ini"
new const KZ_STARTFILE_TEMP[] = "temp_start.ini"

new const KZ_FINISHFILE[] = "finish.ini"
new const KZ_FINISHFILE_TEMP[] = "temp_finish.ini"

new const g_szDirFile[] = "kzaxnmaps";
new const g_szAxnMapFile[] = "axn_maps.ini";

new const KZ_DIR[] = "addons/amxmodx/configs/kz"
new const KZ_MAPTYPE[] = "map_type.ini"
new const file[]={"\addons\amxmodx\configs\kz\map_type.ini"} 

//屏蔽音频
new Trie:g_tSounds

//axn
new g_szDir[128];
new Float:g_flOldMaxSpeed;
new OrpheuStruct:g_ppmove;
new g_bAxnBhop;

//Mpbhop 和暂停
new bool:isFalling[33]
new bool:isMpbhop[33]
new Float:vFallingStart[33][3]
new Float:MpbhopOrigin[33][3]
new Float:vFallingTime[33]


//=======隐藏
// 血量护甲
#define HUD_HIDE_RHA (1<<3)

// 计时器时间
#define HUD_HIDE_TIMER (1<<4)

// 金钱
#define HUD_HIDE_MONEY (1<<5)

new bool:g_bHideRHA
new bool:g_bHideTimer
new bool:g_bHideMoney
new kz_hiderhr
new kz_hidetime
new kz_hidemoney
new g_msgHideWeapon
//======end

//自动加入CT阵营
#if defined KZ_AUTO_JOIN_CT

#define TEAM_SELECT_VGUI_MENU_ID 2

#endif

//1v1

#if defined KZ_DUEL

native kz_player_duel_cp(id);
native kz_player_in_duel(id);
native kz_player_can_hook(id);
#endif

//延长时间
new mp_timelimit;
new addtimemapcount[33];

//武器
new bool:wpn_15[33];
//new bool:hasscout[33];
new g_playergiveweapon[33];
new g_numerodearma[33];

enum (+= 1000)
{
	TASK_ID_STARTWEAPONS = 1000,
	TASK_ID_RESPAWN_WPNS,
	TASK_ID_RESPWAN_SPEC,
	TASK_ID_RESPAWN
}

#if defined USE_SQL
new Handle:g_SqlTuple
new Handle:SqlConnection
new g_Error[512]
new kz_sql_host
new kz_sql_user
new kz_sql_pass
new kz_sql_db
new kz_sql_name
new kz_sql_files
#else
//武器Top
new Float:Wpn_Timepos[104]
new Wpn_AuthIDS[104][32]
new Wpn_Names[104][32]
new Wpn_Date[104][32]
new Wpn_CheckPoints[104]
new Wpn_GoChecks[104]
new Wpn_Weapon[104][32]
new Wpn_maxspeed[104]

new Float:Pro_Times[104]
new Pro_AuthIDS[104][32]
new Pro_Names[104][32]
new Pro_Date[104][32]
new Float:Noob_Tiempos[104]
new Noob_AuthIDS[104][32]
new Noob_Names[104][32]
new Noob_Date[104][32]
new Noob_CheckPoints[104]
new Noob_GoChecks[104]
new Noob_Weapon[104][32]
new Pro_Country[104][8]//TOP显示国旗
new Noob_Country[104][8]//TOP显示国旗
new Wpn_Country[104][8]//TOP显示国旗
#endif

new g_maxplayers;
new max_players;
new Float:gCheckpointAngle[33][3];	
new Float:gLastCheckpointAngle[33][3];
new Float:gCheckpointStartAngle[33][3]
new Float:gLastCheckpointStartAngle[33][3];
new Float:CheckpointStarts[33][2][3]
new Float:InPauseCheckpoints[33][2][3]
new Float:antinoclipstart[33]
new Float:antiteleport[33]
new Float:antidiestart[33]
new Float:Checkpoints[33][2][3]
new Float:timer_time[33]
new Float:g_pausetime[33]
new Float:antihookcheat[33]
new g_iHookWallOrigin[33][3];
new Float:SpecLoc[33][3]
// new Float:NoclipPos[33][3]
new Float:PauseOrigin[33][3]
new Float:SavedStart[33][3]
new Float:SavedStop[33][3]
new hookorigin[33][3]
new Float:DefaultStartPos[3]
new Float:DefaultStopPos[3]

new Float:SavedTime[33]
new SavedChecks[33]
new SavedGoChecks[33]
new SavedWeapon[33]
new SavedOrigins[33][3]
new SavedVelocity[33][3]
new Float:pausedvelocity[33][3]	

new bool:gCheckpoint[33];  
new bool:gCheckpointStart[33];  
new bool:g_bCpAlternate[33]
new bool:g_bInPauseCpAlternate[33]
new bool:g_bCpAlternateStart[33]
new bool:timer_started[33]
new bool:IsPaused[33]
new bool:WasPlayed[33]
new bool:firstspawn[33]
new bool:canusehook[33]
new bool:ishooked[33]
new bool:GoPosed[33]
new bool:GoPosCp[33]
new bool:GoPosHp[33]
new bool:user_has_scout[33]
new bool:spec_user[33]
new bool:tphook_user[33]
new bool:tptostart[33]
#if defined KZ_AUTO_JOIN_CT
new bool:block_change[33]
#endif
new bool:NightVisionUse[33]
new bool:HealsOnMap
new bool:SlideMap
new bool:WasInvisPlayer[33]
new bool:gViewInvisible[33]
new bool:gMarkedInvisible[33] = { true, ...};
new bool:gWaterInvisible[33]
new bool:gWaterEntity[MAX_ENTITYS]
new bool:gWaterFound
new bool:DefaultStart
new bool:DefaultStop
new bool:GodMap
new bool:AutoStart[33]
new bool:tpfenabled[33]
new bool:gc1[33]

new Trie:g_tStarts
new Trie:g_tStops;

new checknumbers[33]
new inpausechecknumbers[33]
new gochecknumbers[33]
new chatorhud[33]
new ShowTime[33]
new MapName[64]
new Kzdir[128]
new SavePosDir[128]
new prefix[33]
#if !defined USE_SQL
new Topdir[128]
#endif

new kz_type_wr_num
new kz_startmoney
new kz_damage
new kz_checkpoints
new kz_checkpoints_num;
new kz_spawn_mainmenu
new kz_show_timer
new kz_chatorhud
new kz_hud_color
new kz_chat_prefix
new hud_message
new kz_other_weapons
new kz_maxspeedmsg
new kz_drop_weapons
new kz_remove_drops
new kz_pick_weapons
new kz_reload_weapons
new kz_use_radio
new kz_hook_sound
new kz_hook_speed
new kz_pause
new kz_noclip_pause
new kz_nvg
new kz_nvg_colors
new kz_vip
new kz_respawn_ct

new bool:Autosavepos[33]

new kz_autosavepos
new kz_save_pos
new kz_semiclip
new kz_spec_saves
new kz_save_autostart
new kz_top15_authid
new Sbeam = 0


stock menu_vadditem(menu, const info[]="", paccess=0, callback=-1, const fmt[], ...) 
{
	static buf[128]
	vformat(buf, 127, fmt, 6)
	menu_additem(menu, buf, info, paccess, callback)
}

new const other_weapons[8] = 
{
	CSW_SCOUT, CSW_P90, CSW_FAMAS, CSW_SG552,
	CSW_M4A1, CSW_M249, CSW_AK47, CSW_AWP
}

new const other_weapons_name[8][] = 
{
	"weapon_scout", "weapon_p90", "weapon_famas", "weapon_sg552",
	"weapon_m4a1", "weapon_m249", "weapon_ak47", "weapon_awp"
}

new const g_weaponconst[][] =
{
	"", // NULL
	"weapon_p228", "weapon_shield", "weapon_scout", "weapon_hegrenade",
	"weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug",
	"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45",
	"weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18",
	"weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1",
	"weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle",
	"weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90"
}

new const g_weaponsnames[][] =
{
	"", // NULL
	"p228", "shield", "scout", "hegrenade", "xm1014", "c4",
	"mac10", "aug", "smokegrenade", "elite", "fiveseven",
	"ump45", "sg550", "galil", "famas", "usp", "glock18",
	"awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1",
	"flashbang", "deagle", "sg552", "ak47", "knife", "p90",
	"glock",  "elites", "fn57", "mp5", "vest", "vesthelm", 
	"flash", "hegren", "sgren", "defuser", "nvgs", "primammo", 
	"secammo", "km45", "9x19mm", "nighthawk", "228compact", 
	"12gauge", "autoshotgun", "mp", "c90", "cv47", "defender", 
	"clarion", "krieg552", "bullpup", "magnum", "d3au1", 
	"krieg550"
}

new const g_block_commands[][]=
{
	"buy", "buyammo1", "buyammo2", "buyequip",
	"cl_autobuy", "cl_rebuy", "cl_setautobuy", "cl_setrebuy"/*,
	"jointeam", "jointeam 1"*/

}

#if defined USE_SQL
enum
{
	TOP_NULL,
	PRO_TOP,
	NUB_TOP,
	LAST_PRO10,
	PRO_RECORDS,
	PLAYERS_RANKING,
	MAPS_STATISTIC
}
#endif

new bool:REC_AC[33];
new bool:p_lang[33];
new g_bitBots;

enum _:DemoData {
	Float:flBotAngle[2],
	Float:flBotPos[3],
	Float:flBotVel[3],
	iButton
};

enum _:CheckPointData {
	Float:flVAngle[3],
	Float:flPos[3]
}

//======================= #MARK: CHECKPOINTS================================
new Array:g_CheckPointArray[33];
new g_CheckPointIndex[33];
new g_MaxCheckPointIndex[33];
new unDoCheckPoint[33][CheckPointData];

//======================= #MARK: BOT & RECORD================================
// PRO
new Array:g_DemoPlaybot[1];
new Array:g_DemoReplay[33];
new Float:g_ReplayBestRunTime;
new Float:g_bestruntime;
new g_ReplayName[32];
new g_bBestTimer[14];
new bool:g_fileRead;
new g_bot_enable;
new g_bot_frame;
new g_bot_id;
new Float:nExttHink = 0.009;
new DATADIR[128];
new g_bot_speed = 1;
new g_authid[32];
new g_date[64];
new g_country[128];

// NUB
new Array:gc_DemoPlaybot[1];
new Array:gc_DemoReplay[33];
new Float:gc_ReplayBestRunTime;
new Float:gc_bestruntime;
new gc_ReplayName[32];
new gc_bBestTimer[14];
new bool:gc_fileRead;
new gc_bot_enable;
new gc_bot_frame;
new gc_bot_id;
new gc_bot_speed = 1;
new gc_authid[32];
new gc_date[64];
new gc_country[128];

new g_szMapName[32];



// =================================================================================================
public plugin_init()
{
	register_plugin("ProKreedz", VERSION, "P & nucLeaR & p4ddY")
	g_maxplayers = get_maxplayers()
	mp_timelimit = get_cvar_pointer("mp_timelimit")
	register_menucmd(register_menuid("ServerMenu", 0), 1023, "handleServerMenu");
	kz_type_wr_num = register_cvar("kz_type_wr_num", "1") 
	kz_hiderhr = register_cvar("kz_hiderhr", "1") 
	kz_hidetime = register_cvar("kz_hidetime", "1") 
	kz_hidemoney = register_cvar("kz_hidemoney", "0")
	kz_checkpoints = register_cvar("kz_checkpoints","1")
	kz_checkpoints_num = register_cvar("kz_checkpoints_num","10")	// 最大存点数量 设置后需要重启服务器才会更换
	kz_spawn_mainmenu = register_cvar("kz_spawn_mainmenu", "1")
	kz_show_timer = register_cvar("kz_show_timer", "1")
	kz_chatorhud = register_cvar("kz_chatorhud", "2") 
	kz_startmoney = register_cvar("kz_startmoney", "1337")  
	kz_chat_prefix = register_cvar("kz_chat_prefix", "[KZ]")
	kz_hud_color = register_cvar("kz_hud_color", "12 122 221")
	kz_other_weapons = register_cvar("kz_other_weapons","1") 
	kz_drop_weapons = register_cvar("kz_drop_weapons", "0")
	kz_remove_drops = register_cvar("kz_remove_drops", "1")
	kz_pick_weapons = register_cvar("kz_pick_weapons", "0")
	kz_reload_weapons = register_cvar("kz_reload_weapons", "1")
	kz_maxspeedmsg = register_cvar("kz_maxspeedmsg","1")
	// kz_hook_prize = register_cvar("kz_hook_prize","1")
	kz_hook_sound = register_cvar("kz_hook_sound","1")
	kz_hook_speed = register_cvar("kz_hook_speed", "300.0")
	kz_use_radio = register_cvar("kz_use_radio", "0")
	kz_pause = register_cvar("kz_pause", "1")
	kz_noclip_pause = register_cvar("kz_noclip_pause", "1")
	kz_nvg = register_cvar("kz_nvg","1")
	kz_nvg_colors = register_cvar("kz_nvg_colors","5 0 255")
	kz_vip = register_cvar("kz_vip","1")
	kz_respawn_ct = register_cvar("kz_respawn_ct", "1")
	kz_semiclip = register_cvar("kz_semiclip", "1")
	kz_damage = register_cvar("kz_damage", "1") //1=CT和T打枪无伤害  0=正常
	// kz_semiclip_transparency = register_cvar ("kz_semiclip_transparency", "85")
	kz_spec_saves = register_cvar("kz_spec_saves", "1")
	kz_save_autostart = register_cvar("kz_save_autostart", "1")
	kz_autosavepos = register_cvar("kz_autosavepos","1")
	kz_top15_authid = register_cvar("kz_top15_authid", "1")
	kz_save_pos = register_cvar("kz_save_pos", "1")
	max_players=get_maxplayers()+1;
	
	#if defined USE_SQL
	kz_sql_host = register_cvar("kz_sql_host", "") // Host of DB
	kz_sql_user = register_cvar("kz_sql_user", "") // Username of DB
	kz_sql_pass = register_cvar("kz_sql_pass", "", FCVAR_PROTECTED) // Password for DB user
	kz_sql_db = register_cvar("kz_sql_db", "") // DB Name for the top 15
	kz_sql_name = register_cvar("kz_sql_server", "") // Name of server
	kz_sql_files = register_cvar("kz_sql_files", "") // Path of the PHP files
	#else
	// kz_webtop_url = register_cvar("kz_webtop_url", "http://60.205.191.245/amxmodx/kz/")		//My Servers by Perfectslife
	kz_webtop_url = register_cvar("kz_webtop_url", "http://60.205.191.245/addons/amxmodx/configs/kz")		//Top URL http://....
	get_pcvar_string(kz_webtop_url, WEB_URL, 63)
	#endif

	register_clcmd("test1","ReadBestRunFile")
	register_clcmd("test2","ReadBestRunFile_c")
	register_clcmd("test3","test3")
	
	register_clcmd("amx_udwr","cmdUpdateWRdata")
	register_clcmd("amx_mapsmod","setmaps")
	register_clcmd("say /adminmenu","AdminMenu",KZ_LEVEL)
	register_clcmd("say /op","AdminMenu",KZ_LEVEL)
	register_clcmd("say /tep", "Teleport")
	register_clcmd("/cp","CheckPoint")
	register_clcmd("/gc", "GoCheck")
	register_clcmd("/tp", "GoCheck")
	register_clcmd("/gcf","GoCheck")
	// register_clcmd("/gcf","GoCheck")
	register_clcmd("+hook","hook_on",KZ_LEVEL)
	register_clcmd("-hook","hook_off",KZ_LEVEL)	
	register_clcmd("say /wr", "CmdSayWR")
	register_clcmd("say /cc", "CmdSayWR")
	register_clcmd("say /cr", "CmdSayCR")
	register_clcmd("say /nt", "CmdSayCR")
	register_clcmd("say /ntr", "CmdSayCR")
	register_clcmd("/tp","GoCheck")
	register_clcmd("say menu","kz_menu")
	register_clcmd("addtime", "ExtendTime", KZ_LEVEL)
	
	register_concmd("drop", "BlockDrop")
	register_concmd("nightvision","ToggleNVG")
	register_concmd("radio1", "BlockRadio") 
	register_concmd("radio2", "BlockRadio") 
	register_concmd("radio3", "BlockRadio") 
	register_concmd("chooseteam", "kz_menu")

	kz_register_saycmd("duel","DuelMenu",0)
	kz_register_saycmd("wrtype","WRDIFF_Type_Menu",0)
	kz_register_saycmd("cs","CheckPointStart",0)
	kz_register_saycmd("ss","CheckPointStart",0)
	kz_register_saycmd("set","CheckPointStart",0)
	kz_register_saycmd("mapsmod","setmaps",0)
	kz_register_saycmd("cp","CheckPoint",0)
	kz_register_saycmd("CheckPoint","CheckPoint",0)
	kz_register_saycmd("chatorhud", "ChatHud", 0)
	kz_register_saycmd("ct","ct",0)
	kz_register_saycmd("gc", "GoCheck",0)
	kz_register_saycmd("gocheck", "GoCheck",0)
	kz_register_saycmd("god", "GodMode",0)
	kz_register_saycmd("godmode", "GodMode", 0)
	kz_register_saycmd("invis", "InvisMenu", 0)
	kz_register_saycmd("kz", "kz_menu", 0)
	kz_register_saycmd("kreedz", "kz_menu", 0)
	kz_register_saycmd("menu","kz_menu", 0)
	kz_register_saycmd("kzdemo","kz_menu", 0)
	kz_register_saycmd("kzcnmenu","kz_menu", 0)
	kz_register_saycmd("kzcn","kz_menu", 0)
	kz_register_saycmd("nt","kz_menu", 0)
	kz_register_saycmd("nc", "noclip", 0)
	kz_register_saycmd("noclip", "noclip", 0)
	kz_register_saycmd("noob10", "NoobTop_show", 0)
	kz_register_saycmd("noob15", "NoobTop_show", 0)
	kz_register_saycmd("nub10", "NoobTop_show", 0)
	kz_register_saycmd("nub15", "NoobTop_show", 0)
	kz_register_saycmd("pause", "Pause", 0)
	kz_register_saycmd("p", "Pause", 0)
	kz_register_saycmd("pinvis", "cmdInvisible", 0)
	kz_register_saycmd("showtimer", "ShowTimer_Menu", 0)
	kz_register_saycmd("pro10", "ProTop_show", 0)
	kz_register_saycmd("pro15", "ProTop_show", 0)
	kz_register_saycmd("wpn10", "WpnTop_show", 0)
	kz_register_saycmd("wpn15", "WpnTop_show", 0)
	kz_register_saycmd("showpos", "Origin", KZ_LEVEL)
	kz_register_saycmd("help", "cmd_help", 0)
	kz_register_saycmd("reset", "reset_checkpoints1", 0)
	kz_register_saycmd("rs", "reset_checkpoints1", 0)
	kz_register_saycmd("respawn", "goStartPos", 0) 
	kz_register_saycmd("scout", "cmdScout", 0)
	kz_register_saycmd("setstart", "setStart", KZ_LEVEL)
	kz_register_saycmd("setfinish", "setStop", KZ_LEVEL)
	kz_register_saycmd("setfs", "setStop", KZ_LEVEL)
	kz_register_saycmd("spec", "ct", 0)
	kz_register_saycmd("start", "goStartPos", 0) 
	kz_register_saycmd("stuck", "Stuck", 0)
	kz_register_saycmd("ungocheck", "Stuck", 0)
	kz_register_saycmd("teleport", "GoCheck", 0)
	kz_register_saycmd("top15", "top15menu",0)
	kz_register_saycmd("top10", "top15menu",0)
	kz_register_saycmd("top", "top15menu",0)
	kz_register_saycmd("top100", "top15menu",0)
	kz_register_saycmd("tp", "GoCheck",0)
	kz_register_saycmd("usp", "cmdUsp", 0)
	kz_register_saycmd("version", "Version", 0)
	kz_register_saycmd("weapons", "weapons", 0)
	kz_register_saycmd("guns", "weapons", 0)	
	kz_register_saycmd("winvis", "cmdWaterInvisible", 0)
	// kz_register_saycmd("server", "cmdServerMenu", 0)
	
	#if defined USE_SQL
	kz_register_saycmd("prorecords", "ProRecs_show", 0)
	kz_register_saycmd("prorecs", "ProRecs_show", 0)
	#endif
	
	set_task(0.5, "show_Top1msg",0,"",0,"b") 
	
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	register_event("ResetHUD", "onResetHUD", "b")
	register_message(g_msgHideWeapon, "msgHideWeapon")
	register_event("CurWeapon", "curweapon", "be", "1=1")
	
	// register_event("StatusValue", "EventStatusValue", "b", "1>0", "2>0" );
	register_message( get_user_msgid( "StatusIcon" ), "Msg_StatusIcon" ); //屏蔽购买图标icon
	register_forward(FM_EmitSound, "FM_PlayerEmitSound", 0);	//屏蔽音频
	register_forward(FM_AddToFullPack, "FM_client_AddToFullPack_Post", 1) 
	register_forward(FM_PlayerPreThink, "fwdPlayerPreThink", 0)
	register_forward(FM_GetGameDescription,"fnGetGameDescription")
	fnUpdateGameName()

	RegisterHam( Ham_Player_PreThink, "player", "Ham_CBasePlayer_PreThink_Post", 1)
	RegisterHam( Ham_Use, "func_button", "fwdUse", 0)
	RegisterHam( Ham_Killed, "player", "Ham_CBasePlayer_Killed_Pre")	
	RegisterHam( Ham_Killed, "player", "Ham_CBasePlayer_Killed_Post", 1)
	RegisterHam( Ham_Touch, "weaponbox", "FwdSpawnWeaponbox" )
	RegisterHam( Ham_Spawn, "player", "FwdHamPlayerSpawn", 1 )
	RegisterHam( Ham_Touch, "weaponbox", "GroundWeapon_Touch") 
	RegisterHam( Ham_TakeDamage, "player", "eventHamPlayerDamage")
	RegisterHam( Ham_TraceAttack, "player", "fw_TraceAttack")

	RegisterHam( Ham_Touch, "worldspawn", "Ham_HookTouch", false); 
	RegisterHam( Ham_Touch, "func_wall", "Ham_HookTouch", false); 
	RegisterHam( Ham_Touch, "func_breakable", "Ham_HookTouch", false); 
	RegisterHam( Ham_Touch, "player", "Ham_HookTouch", false); 
	#if defined KZ_AUTO_JOIN_CT
	register_message(get_user_msgid("ShowMenu"), "message_show_menu")
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")
	#endif
	register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" )
	register_dictionary("prokreedz.txt")
	get_pcvar_string(kz_chat_prefix, prefix, 31)
	get_mapname(MapName, 63)

	register_event("DeathMsg", "event_deathmsg", "a")
	cvar_respawndelay = register_cvar("amx_respawndelay", "3.0")
	
	// axn
	
	g_bAxnBhop = ReadMaps();	
	OrpheuRegisterHook(OrpheuGetFunction("PM_Move"), "OR_PMMove");
	
	new OrpheuFunction:orPMJump = OrpheuGetFunction("PM_Jump");
	OrpheuRegisterHook(orPMJump, "OR_PMJump");
	OrpheuRegisterHook(orPMJump, "OR_PMJump_P", OrpheuHookPost);
	// axn end
	
	//show wr
	kz_wr_diff = register_cvar("kz_wr_diff","1")

	
	get_mapname(e_MapName, 31)
	strtolower(e_MapName)

	new e_Temp[128];
	get_localinfo("amxx_datadir", e_Temp, 127)
	format(e_Temp, 127,"%s/records", e_Temp)
	
	if ( !dir_exists(e_Temp) )
	mkdir(e_Temp);

	format(e_Records_WR,127,"%s/xj.txt", e_Temp)
	format(e_Records_CC,127,"%s/cc.txt", e_Temp)
	format(e_Records_SU,127,"%s/su.txt", e_Temp)
	format(e_Records_CR,127,"%s/nt.txt", e_Temp)
	format(e_LastUpdate,127,"%s/demos_last_update.ini", e_Temp );	
	
	#if defined KZ_AUTO_DOWNLOAD_WRTXT
	// 当没有文件的时候执行更新
	if(!file_exists(e_LastUpdate))	
	{
		UpdateRecords( );
		return;
	}
	
	
	new iYear, iMonth, iDay, szDate[ 11 ];
	date( iYear, iMonth, iDay );

	new iFile = fopen( e_LastUpdate, "rt" );
	fgets( iFile, szDate, 10 );
	fclose( iFile );
	
	// 比对日期 每天一更新
	if( iYear > str_to_num( szDate[ 0 ] ) || iMonth > str_to_num( szDate[ 5 ] ) || iDay > str_to_num( szDate[ 8 ] ) )
	{
		UpdateRecords();
	}
	#endif
	
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	// set_task(0.2,"timer_task",2000,"",0,"ab")   
	
	register_forward(FM_Think,"kz_TimerEntity")
	new iEnt
	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString , "info_target"))
	set_pev(iEnt, pev_classname, "kz_time_think")
	set_pev(iEnt, pev_nextthink, get_gametime() + 1.0)
	
	#if defined USE_SQL
	set_task(0.2, "plugin_sql")
	#endif
	
	new kreedz_cfg[128], ConfigDir[64]
	get_configsdir( ConfigDir, 64)
	formatex(Kzdir,128, "%s/kz", ConfigDir)
	if( !dir_exists(Kzdir) )
		mkdir(Kzdir)
	
	#if !defined USE_SQL
	formatex(Topdir,128, "%s/top15", Kzdir)
	if( !dir_exists(Topdir) )
		mkdir(Topdir)

	formatex( NUB_PATH, 99, "%s/nub_top.html", Kzdir )
	formatex( PRO_PATH, 99, "%s/pro_top.html", Kzdir )
	formatex( WPN_PATH, 99, "%s/Wpn_top.html", Kzdir )
	#endif
	
	formatex(SavePosDir, 128, "%s/savepos", Kzdir)
	if( !dir_exists(SavePosDir) )
		mkdir(SavePosDir)
    
	formatex(kreedz_cfg,128,"%s/kreedz.cfg", Kzdir)
        
	if( file_exists( kreedz_cfg ) )
	{
		server_exec()
		server_cmd("exec %s",kreedz_cfg)
	}
	
	for(new i = 0; i < sizeof(g_block_commands) ; i++) 
		register_clcmd(g_block_commands[i], "BlockBuy")

	g_tStarts = TrieCreate( )
	g_tStops  = TrieCreate( )

	new const szStarts[ ][ ] =
	{
		"counter_start", "clockstartbutton", "firsttimerelay", "but_start", "counter_start_button",
		"multi_start", "timer_startbutton", "start_timer_emi", "gogogo"
	}

	new const szStops[ ][ ]  =
	{
		"counter_off", "clockstopbutton", "clockstop", "but_stop", "counter_stop_button",
		"multi_stop", "stop_counter", "m_counter_end_emi"
	}

	new GodMapsFile[128], MapData[128]
	formatex(GodMapsFile, 127, "%s/GodMaps.ini", Kzdir)
	new f = fopen(GodMapsFile, "rt" )
	while( !feof(f) && !GodMap)
	{
		fgets(f, MapData, 127)
		GodMap=bool:equali(MapData, MapName)
	}
		
	for( new i = 0; i < sizeof szStarts; i++ )
		TrieSetCell( g_tStarts, szStarts[ i ], 1 )
	
	for( new i = 0; i < sizeof szStops; i++ )
		TrieSetCell( g_tStops, szStops[ i ], 1 )
	
	//======================= plugin_init=#MARK: BOT & RECORD================================
	
	new Ent = engfunc(21, engfunc(43, "info_target"));	// 创建Entity
	set_pev(Ent, 1, "bot_record");						// pev_classname
	set_pev(Ent, 33, 0.01);								// pev_nextthink

	new i = 0;
	while(i < 33) {
		g_DemoReplay[i] = ArrayCreate(DemoData, 1);
		gc_DemoReplay[i] = ArrayCreate(DemoData, 1);
		g_CheckPointArray[i] = ArrayCreate(CheckPointData);
		// server_print("g_CheckPointArray size is %d", ArraySize(g_CheckPointArray[i]));
		++i;
	}
	g_DemoPlaybot[0] = ArrayCreate(DemoData, 1);
	gc_DemoPlaybot[0] = ArrayCreate(DemoData, 1);

	RegisterHam(Ham_Player_PreThink, "player", "Ham_PlayerPreThink", 0);
	register_forward(FM_Think, "fwd_Think", 1);			// FM_Think,
	register_forward(FM_Think, "fwd_Think_c", 1);			// FM_Think,

	get_mapname(g_szMapName, 31);
	get_localinfo("amxx_datadir", DATADIR, 126);
	set_task(2.0, "ReadBestRunFile");	// 需要延时 否则可能出错
	set_task(3.0, "ReadBestRunFile_c");	// 需要延时 否则可能出错

	// ============================================================================


	//------------屏蔽控制台刷Non Sprite glow!!!命令----------
	new szModel[ 2 ],
	iMaxEntities = get_global_int( GL_maxEntities );
	
	while( ++g_maxplayers <= iMaxEntities ) {
		if( is_valid_ent( g_maxplayers ) && entity_get_int( g_maxplayers, EV_INT_rendermode ) == kRenderGlow ) 
		{
			entity_get_string( g_maxplayers, EV_SZ_model, szModel, 1 );
			
			if( szModel[ 0 ] == '*' )
				entity_set_int( g_maxplayers, EV_INT_rendermode, kRenderNormal );
		}
	}
	//-------------结束------------

	HudApplyCVars();
}


#if defined USE_SQL
public plugin_sql()
{
	new host[64], user[64], pass[64], db[64]
	
	get_pcvar_string(kz_sql_host, host, 63)
	get_pcvar_string(kz_sql_user, user, 63)
	get_pcvar_string(kz_sql_pass, pass, 63)
	get_pcvar_string(kz_sql_db, db, 63)
	
	g_SqlTuple = SQL_MakeDbTuple(host, user, pass, db)
	
	new ErrorCode
	SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,511)
	
	if(!SqlConnection) 
	{
		server_print("%s TOP15 SQL: Could not connect to SQL database.!", prefix)
		log_amx("%s TOP15 SQL: Could not connect to SQL database.", prefix)
		return pause("a")
	}
	
	new createinto[1001]
	formatex(createinto, 1000, "CREATE TABLE IF NOT EXISTS `kz_pro15` (`mapname` varchar(64) NOT NULL, `authid` varchar(64) NOT NULL, `country` varchar(6) NOT NULL, `name` varchar(64) NOT NULL, `time` decimal(65,2)   NOT NULL, `date` datetime NOT NULL, `weapon` varchar(64) NOT NULL, `server` varchar(64) NOT NULL)")
	SQL_ThreadQuery(g_SqlTuple,"QueryHandle", createinto)
	formatex(createinto, 1000, "CREATE TABLE IF NOT EXISTS `kz_nub15` (`mapname` varchar(64) NOT NULL, `authid` varchar(64) NOT NULL, `country` varchar(6) NOT NULL, `name` varchar(64) NOT NULL, `time`decimal(65,2)  NOT NULL, `date` datetime NOT NULL, `weapon` varchar(64) NOT NULL, `server` varchar(64) NOT NULL, `checkpoints` real NOT NULL, `gocheck` real NOT NULL)")
	SQL_ThreadQuery(g_SqlTuple,"QueryHandle", createinto)
	
	return PLUGIN_CONTINUE
}

public QueryHandle(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	if( iFailState != TQUERY_SUCCESS )
	{
		log_amx("%s TOP15 SQL: SQL Error #%d - %s",prefix, iErrnum, szError)
		ColorChat(0, GREEN,  "%s ^x01Warning the SQL Tops can not be saved.",prefix)
	}

	server_print("%s Server Sending Info to SQL Server",prefix)
	
	return PLUGIN_CONTINUE
}
#endif


public plugin_precache()
{
	g_tSounds = TrieCreate();

	new szStupidSounds[][] = {
		"doors/doorstop1.wav", "doors/doorstop2.wav", "doors/doorstop3.wav",
		"player/pl_pain2.wav", "player/pl_pain3.wav","player/pl_pain4.wav",
		"player/pl_pain5.wav", "player/pl_pain6.wav", "player/pl_pain7.wav",
		"player/bhit_kevlar-1.wav", "player/bhit_flesh-1.wav", "player/bhit_flesh-2.wav",
		"player/bhit_flesh-3.wav","player/pl_swim1.wav", "player/pl_swim2.wav",
		"player/pl_swim3.wav", "player/pl_swim4.wav", "player/waterrun.wav", 
		"weapons/knife_hit1.wav", "weapons/knife_hit2.wav", "weapons/knife_hit3.wav",
		"weapons/knife_hit4.wav", "weapons/knife_stab.wav" // "weapons/knife_deploy1.wav", 
		// "items/gunpickup2.wav"
	};
	
	new i;
	for (i = 0; i < sizeof szStupidSounds; i++)
	{
		TrieSetCell(g_tSounds, szStupidSounds[i], i);
	}
	
	hud_message = CreateHudSyncObj()
	RegisterHam( Ham_Spawn, "func_door", "FwdHamDoorSpawn", 1 )
	precache_sound("weapons/xbow_hit2.wav")
	#if defined KZ_DUEL
	precache_sound("kzsound/gjhaha.wav")
	precache_sound("kzsound/gg.wav")
	#endif
	precache_sound("kzsound/toprec.wav")
	Sbeam = precache_model("sprites/laserbeam.spr")
}

public test3(id) {
	// server_print("g_CheckPointArray size is %d", ArraySize(g_CheckPointArray[id]));
	// mapcycle.txt
	new country[3];
	new tmpIp[] = "223.72.93.125";
	geoip_code2_ex(tmpIp, country);
	client_print(0, print_chat, country);
}
public plugin_cfg()
{
	#if !defined USE_SQL
	for (new i = 0 ; i < num; ++i)
	{
		Pro_Times[i] = 999999999.00000;
		Noob_Tiempos[i] = 999999999.00000;
		Wpn_Timepos[i] = 999999999.00000;
		Wpn_maxspeed[i] = 999999999;
	}

	read_pro15()
	read_Noob15()
	read_Wpn15()
	#endif
	
	new startcheck[100], data[256], map[64], x[13], y[13], z[13];
	formatex(startcheck, 99, "%s/%s", Kzdir, KZ_STARTFILE)
	new f = fopen(startcheck, "rt" )
	while( !feof( f ) )
	{
		fgets( f, data, sizeof data - 1 )
		parse( data, map, 63, x, 12, y, 12, z, 12)
			
		if( equali( map, MapName ) )
		{
			DefaultStartPos[0] = str_to_float(x)
			DefaultStartPos[1] = str_to_float(y)
			DefaultStartPos[2] = str_to_float(z)
			
			DefaultStart = true
			break;
		}
	}
	fclose(f)
	
	new stopcheck[100], data1[1024], map1[64], x1[13], y1[13], z1[13];
	formatex(stopcheck, 99, "%s/%s", Kzdir, KZ_FINISHFILE)
	new ff = fopen(stopcheck, "rt" )
	while( !feof( ff ) )
	{
		fgets( ff, data1, sizeof data1 - 1 )
		parse( data1, map1, 63, x1, 12, y1, 12, z1, 12)
			
		if( equali( map1, MapName ) )
		{
			DefaultStopPos[0] = str_to_float(x1)
			DefaultStopPos[1] = str_to_float(y1)
			DefaultStopPos[2] = str_to_float(z1)
			
			DefaultStop = true
			break;
		}
	}
	fclose(ff)
	
	new ent = -1;
	while( ( ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_water") ) != 0 )
	{
		if( !gWaterFound )
		{
			gWaterFound = true;
		}

		if (ent > -1)
			gWaterEntity[ent] = true;
	}
	
	ent = -1;
	while( ( ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_illusionary") ) != 0 )
	{
		if( pev( ent, pev_skin ) ==  CONTENTS_WATER )
		{
			if( !gWaterFound )
			{
				gWaterFound = true;
			}
	

			if (ent > -1)
				gWaterEntity[ent] = true;
		}
	}
	
	ent = -1;
	while( ( ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_conveyor") ) != 0 )
	{
		if( pev( ent, pev_spawnflags ) == 3 )
		{
			if( !gWaterFound )
			{
				gWaterFound = true;
			}
			if (ent > -1)
				gWaterEntity[ent] = true;
		}
	}

	if((containi(MapName, "cs_") != -1) || 
	(containi(MapName, "de_") != -1) || 
	(containi(MapName, "ae_strafers_heaven") != -1) || 
	(containi(MapName, "esc_dust2_b03") != -1))
	{
		return
	}
	else
	{
		// 移除地图本身的武器
		remove_entity_name("player_weaponstrip")
		remove_entity_name("armoury_entity")
		remove_entity_name("info_player_deathmatch")
		remove_entity_name("game_player_equip")
		
		// 移除地图本身能用武器打碎的实体
		new Float:tmpflt;	
		ent = find_ent_by_class( -1, "func_breakable" )
		while( ent > 0 )
		{
			tmpflt = entity_get_float( ent, EV_FL_health )
			if( tmpflt < 9999 ) remove_entity( ent )		
			ent = find_ent_by_class( ent, "func_breakable" )
		}
	}
	
	// ----------------------------
}

// ==================#MARK: BOT & RECORDS==================#
public Ham_PlayerPreThink(id)
{
	if (is_user_alive(id))
	{
		// 读点数据存放在gc_DemoReplay[id]
		// if (timer_started[id] && gochecknumbers[id])
		// {
		// 	if (!IsPaused[id])
		// 	{
		// 		new ArrayData[DemoData];
		// 		pev(id, pev_origin, ArrayData[flBotPos]);
		// 		new Float:angle[3];
		// 		pev(id, pev_v_angle, angle)
		// 		pev(id, pev_velocity, ArrayData[flBotVel]);
		// 		ArrayData[flBotAngle][0] = _:angle[0];
		// 		ArrayData[flBotAngle][1] = _:angle[1];
		// 		ArrayData[iButton] = get_user_button(id)
		// 		ArrayPushArray(gc_DemoReplay[id], ArrayData);
		// 	}
		// }
		// 裸跳数据放在g_DemoReplay
		if (timer_started[id])
		{
			if (!IsPaused[id])
			{
				new ArrayData[DemoData];
				pev(id, pev_origin, ArrayData[flBotPos]);
				new Float:angle[3];
				pev(id, pev_v_angle, angle)
				pev(id, pev_velocity, ArrayData[flBotVel]);
				ArrayData[flBotAngle][0] = _:angle[0];
				ArrayData[flBotAngle][1] = _:angle[1];
				ArrayData[iButton] = get_user_button(id)
				ArrayPushArray(g_DemoReplay[id], ArrayData);
			}
		}
	}
	return 0;
}
public ClCmd_UpdateReplay(id, Float:timer)
{
	new szName[32];
	new authid[32];
	new thetime[32];
	new ip[32];
	new country[128];
	get_user_name(id, szName, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d - %H:%M:%S", thetime, charsmax(thetime));
	get_user_ip(id, ip, 31, 1);
	geoip_country(ip, country, charsmax(country));
	g_ReplayBestRunTime = timer;

	new szFile[128];
	new szData[128];
	format(szFile, sizeof(szFile) - 1, "%s/records/Pro/%s.txt", DATADIR, g_szMapName)
	delete_file(szFile);

	new hFile = fopen(szFile, "wt");
	ArrayClear(g_DemoPlaybot[0]);
	new str[25];
	new nick[64];
	new stm[32];
	new date[32];
	new cty[128];
	formatex(str, charsmax(str), "%f^n", g_ReplayBestRunTime);
	formatex(nick, charsmax(nick), "%s^n", szName);
	formatex(stm, charsmax(stm), "%s^n", authid);
	formatex(date, charsmax(date), "%s^n", thetime);
	formatex(cty, charsmax(cty), "%s^n", country);
	fputs(hFile, str);
	fputs(hFile, nick);
	fputs(hFile, stm);
	fputs(hFile, date);
	fputs(hFile, cty);
	new ArrayData[DemoData];
	new ArrayData2[DemoData];
	for(new i; i < ArraySize(g_DemoReplay[id]); i++)
	{
		ArrayGetArray(g_DemoReplay[id], i, ArrayData);	// 将g_DemoReplay[id][i]保存到ArrayData
		ArrayData2[flBotAngle][0] = _:ArrayData[flBotAngle][0]
		ArrayData2[flBotAngle][1] = _:ArrayData[flBotAngle][1]
		ArrayData2[flBotVel][0] = _:ArrayData[flBotVel][0]
		ArrayData2[flBotVel][1] = _:ArrayData[flBotVel][1]
		ArrayData2[flBotVel][2] = _:ArrayData[flBotVel][2]
		ArrayData2[flBotPos][0] = _:ArrayData[flBotPos][0]
		ArrayData2[flBotPos][1] = _:ArrayData[flBotPos][1]
		ArrayData2[flBotPos][2] = _:ArrayData[flBotPos][2]
		ArrayData2[iButton] = ArrayData[iButton]
		if(i >= ArraySize(g_DemoReplay[id]))
		{
			ArrayPushArray(g_DemoReplay[id], ArrayData2);
		}
		else
		{
			ArraySetArray(g_DemoReplay[id], i, ArrayData2);
		}
		formatex(szData, sizeof(szData) - 1, "%f %f %f %f %f %f %f %f %d^n", ArrayData2[flBotAngle][0], ArrayData2[flBotAngle][1],
		ArrayData2[flBotPos][0], ArrayData2[flBotPos][1], ArrayData2[flBotPos][2], ArrayData2[flBotVel][0], ArrayData2[flBotVel][1], ArrayData2[flBotVel][2], ArrayData2[iButton]);
		fputs(hFile, szData);
	}
	fclose(hFile);
	ArrayClear(g_DemoReplay[id]);
	set_task(2.0, "bot_overwriting")
	return 0;
}

public ClCmd_UpdateReplay_c(id, Float:timer)
{
	new szName[32];
	new authid[32];
	new thetime[32];
	new ip[32];
	new country[128];
	get_user_name(id, szName, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d - %H:%M:%S", thetime, charsmax(thetime));
	get_user_ip(id, ip, 31, 1);
	geoip_country(ip, country, charsmax(country));
	gc_ReplayBestRunTime = timer;

	new szFile[128];
	new szData[128];
	format(szFile, sizeof(szFile) - 1, "%s/records/Nub/%s.txt", DATADIR, g_szMapName)
	delete_file(szFile);

	new hFile = fopen(szFile, "wt");
	ArrayClear(gc_DemoPlaybot[0]);
	new str[25];
	new nick[64];
	new stm[32];
	new date[32];
	new cty[128];
	formatex(str, charsmax(str), "%f^n", gc_ReplayBestRunTime);
	formatex(nick, charsmax(nick), "%s^n", szName);
	formatex(stm, charsmax(stm), "%s^n", authid);
	formatex(date, charsmax(date), "%s^n", thetime);
	formatex(cty, charsmax(cty), "%s^n", country);
	fputs(hFile, str);
	fputs(hFile, nick);
	fputs(hFile, stm);
	fputs(hFile, date);
	fputs(hFile, cty);
	new ArrayData[DemoData];
	new ArrayData2[DemoData];
	for(new i; i < ArraySize(g_DemoReplay[id]); i++)
	{
		ArrayGetArray(g_DemoReplay[id], i, ArrayData);	// 将g_DemoReplay[id][i]保存到ArrayData
		ArrayData2[flBotAngle][0] = _:ArrayData[flBotAngle][0]
		ArrayData2[flBotAngle][1] = _:ArrayData[flBotAngle][1]
		ArrayData2[flBotVel][0] = _:ArrayData[flBotVel][0]
		ArrayData2[flBotVel][1] = _:ArrayData[flBotVel][1]
		ArrayData2[flBotVel][2] = _:ArrayData[flBotVel][2]
		ArrayData2[flBotPos][0] = _:ArrayData[flBotPos][0]
		ArrayData2[flBotPos][1] = _:ArrayData[flBotPos][1]
		ArrayData2[flBotPos][2] = _:ArrayData[flBotPos][2]
		ArrayData2[iButton] = ArrayData[iButton]
		if(i >= ArraySize(g_DemoReplay[id]))
		{
			ArrayPushArray(g_DemoReplay[id], ArrayData2);
		}
		else
		{
			ArraySetArray(g_DemoReplay[id], i, ArrayData2);
		}
		formatex(szData, sizeof(szData) - 1, "%f %f %f %f %f %f %f %f %d^n", ArrayData2[flBotAngle][0], ArrayData2[flBotAngle][1],
		ArrayData2[flBotPos][0], ArrayData2[flBotPos][1], ArrayData2[flBotPos][2], ArrayData2[flBotVel][0], ArrayData2[flBotVel][1], ArrayData2[flBotVel][2], ArrayData2[iButton]);
		fputs(hFile, szData);
	}
	fclose(hFile);
	ArrayClear(g_DemoReplay[id]);
	set_task(2.0, "bot_overwriting_c")
	return 0;
}

stock StringTimer(const Float:flRealTime, szOutPut[], const iSizeOutPut)
{
    static Float:flTime, iMinutes, iSeconds, iMiliSeconds, Float:iMili;
    new string[12]

    flTime = flRealTime;

    if(flTime < 0.0) flTime = 0.0;

    iMinutes = floatround(flTime / 60, floatround_floor);
    iSeconds = floatround(flTime - (iMinutes * 60), floatround_floor);
    iMili = floatfract(flRealTime)
    formatex(string, 11, "%.02f", iMili >= 0 ? iMili + 0.005 : iMili - 0.005);
    iMiliSeconds = floatround(str_to_float(string) * 100, floatround_floor);

    formatex(szOutPut, iSizeOutPut, "%02d:%02d.%02d", iMinutes, iSeconds, iMiliSeconds);
}

public bot_overwriting()
{
	ArrayClear(g_DemoPlaybot[0]);
	ReadBestRunFile();
	if (g_bot_id)
	{
		new txt[64];
		StringTimer(g_ReplayBestRunTime, g_bBestTimer, sizeof(g_bBestTimer) - 1);
		formatex(txt, charsmax(txt), "[PRO] %s %s", g_ReplayName, g_bBestTimer);
		set_user_info(g_bot_id, "name", txt)
	}
}

public bot_overwriting_c()
{
	ArrayClear(gc_DemoPlaybot[0]);
	ReadBestRunFile_c();
	if (gc_bot_id) {
		new txt[64];
		StringTimer(gc_ReplayBestRunTime, gc_bBestTimer, sizeof(gc_bBestTimer) - 1);
		formatex(txt, charsmax(txt), "[NUB] %s %s", gc_ReplayName, gc_bBestTimer);
		set_user_info(gc_bot_id, "name", txt)
	}
	
}

public ReadBestRunFile()
{
	// server_print("==================================================");
	// server_print("ReadBestRunFile");
	// server_print("==================================================");

	new ArrayData[DemoData];

	new szFile[128], len
	format(szFile, sizeof(szFile) - 1, "%s/records/Pro", DATADIR) 		// data/records/Pro
	// client_print(0, 2, szFile);
	if( !dir_exists(szFile) ) mkdir(szFile);								

	format(szFile, sizeof(szFile) - 1, "%s/%s.txt", szFile, g_szMapName)	// data/records/Pro/<map>.txt

	if (file_exists(szFile)) 												
	{
		g_fileRead = true; 
		read_file(szFile, 1, g_ReplayName, 63, len);	// 读取第1行(从0开始) 读取REC名字
		read_file(szFile, 2, g_authid, charsmax(g_authid), len);
		read_file(szFile, 3, g_date, charsmax(g_date), len);
		read_file(szFile, 4, g_country, charsmax(g_country), len);
	}
	else
		return PLUGIN_HANDLED;

	new hFile = fopen(szFile, "r"); 										// Открываем файл с рекордом
	new szData[1024];
	new szBotAngle[2][40], szBotPos[3][60], szBotVel[3][60], szBotButtons[12];

	new line;

	while(!feof(hFile))
	{
		fgets(hFile, szData, charsmax(szData));

		if(!szData[0] || szData[0] == '^n')
			continue;

		if(!line)
		{
			g_ReplayBestRunTime = str_to_float(szData);
			g_bestruntime = str_to_float(szData);
			line++;
			continue;
		}

		strtok(szData, szBotAngle[0], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotAngle[1], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotPos[0], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotPos[1], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotPos[2], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotVel[0], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotVel[1], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotVel[2], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotButtons, charsmax(szBotButtons), szData, charsmax(szData), ' ', true)

		ArrayData[flBotAngle][0] = _:str_to_float(szBotAngle[0]);
		ArrayData[flBotAngle][1] = _:str_to_float(szBotAngle[1]);

		ArrayData[flBotPos][0] = _:str_to_float(szBotPos[0]);
		ArrayData[flBotPos][1] = _:str_to_float(szBotPos[1]);
		ArrayData[flBotPos][2] = _:str_to_float(szBotPos[2]);

		ArrayData[flBotVel][0] = _:str_to_float(szBotVel[0]);
		ArrayData[flBotVel][1] = _:str_to_float(szBotVel[1]);
		ArrayData[flBotVel][2] = _:str_to_float(szBotVel[2]);

		ArrayData[iButton] = _: str_to_num(szBotButtons);

		ArrayPushArray(g_DemoPlaybot[0], ArrayData);
		line++;
	}
	fclose(hFile);
	bot_restart();
	return PLUGIN_HANDLED;
}

public ReadBestRunFile_c()
{
	// server_print("==================================================");
	// server_print("ReadBestRunFile_c");
	// server_print("==================================================");

	new ArrayData[DemoData];

	new szFile[128], len
	format(szFile, sizeof(szFile) - 1, "%s/records/Nub", DATADIR) 		// data/records/Nub
	// client_print(0, 2, szFile);
	if( !dir_exists(szFile) ) mkdir(szFile);								

	format(szFile, sizeof(szFile) - 1, "%s/%s.txt", szFile, g_szMapName)	// data/records/Nub/<map>.txt

	if (file_exists(szFile)) 												
	{
		gc_fileRead = true; 
		read_file(szFile, 1, gc_ReplayName, 63, len);	// 读取第1行(从0开始) 读取REC名字
		read_file(szFile, 2, gc_authid, charsmax(gc_authid), len);
		read_file(szFile, 3, gc_date, charsmax(gc_date), len);
		read_file(szFile, 4, gc_country, charsmax(gc_country), len);
	}
	else
		return PLUGIN_HANDLED;

	new hFile = fopen(szFile, "r"); 										// Открываем файл с рекордом
	new szData[1024];
	new szBotAngle[2][40], szBotPos[3][60], szBotVel[3][60], szBotButtons[12];

	new line;

	while(!feof(hFile))
	{
		fgets(hFile, szData, charsmax(szData));

		if(!szData[0] || szData[0] == '^n')
			continue;

		if(!line)
		{
			gc_ReplayBestRunTime = str_to_float(szData);
			gc_bestruntime = str_to_float(szData);
			line++;
			continue;
		}

		strtok(szData, szBotAngle[0], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotAngle[1], charsmax(szBotAngle[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotPos[0], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotPos[1], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotPos[2], charsmax(szBotPos[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotVel[0], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotVel[1], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)
		strtok(szData, szBotVel[2], charsmax(szBotVel[]), szData, charsmax(szData), ' ', true)

		strtok(szData, szBotButtons, charsmax(szBotButtons), szData, charsmax(szData), ' ', true)

		ArrayData[flBotAngle][0] = _:str_to_float(szBotAngle[0]);
		ArrayData[flBotAngle][1] = _:str_to_float(szBotAngle[1]);

		ArrayData[flBotPos][0] = _:str_to_float(szBotPos[0]);
		ArrayData[flBotPos][1] = _:str_to_float(szBotPos[1]);
		ArrayData[flBotPos][2] = _:str_to_float(szBotPos[2]);

		ArrayData[flBotVel][0] = _:str_to_float(szBotVel[0]);
		ArrayData[flBotVel][1] = _:str_to_float(szBotVel[1]);
		ArrayData[flBotVel][2] = _:str_to_float(szBotVel[2]);

		ArrayData[iButton] = _: str_to_num(szBotButtons);

		ArrayPushArray(gc_DemoPlaybot[0], ArrayData);
		line++;
	}
	fclose(hFile);
	bot_restart_c();
	return PLUGIN_HANDLED;
}
public bot_restart()
{
	if (g_fileRead)
	{
		if(!g_bot_id)
     		g_bot_id = Create_Bot(); // Создает бота с id
		else
			Start_Bot();
	}
}

public bot_restart_c()
{
	if (gc_fileRead)
	{
		if (!gc_bot_id)
		{
			gc_bot_id = Create_Bot_c();
		}
		else
			Start_Bot_c();
	}
	return 0;
}

Create_Bot()
{
	new txt[64];
	StringTimer(g_ReplayBestRunTime, g_bBestTimer, sizeof(g_bBestTimer) - 1);
	formatex(txt, charsmax(txt), "[PRO] %s %s", g_ReplayName, g_bBestTimer);
	new id = engfunc(EngFunc_CreateFakeClient, txt);
	if(pev_valid(id))
	{
		set_user_info(id, "rate", "10000");
		set_user_info(id, "cl_updaterate", "60");
		set_user_info(id, "cl_cmdrate", "101");
		set_user_info(id, "cl_lw", "1");
		set_user_info(id, "cl_lc", "1");
		set_user_info(id, "cl_dlmax", "512");
		set_user_info(id, "cl_righthand", "1");
		set_user_info(id, "_vgui_menus", "0");
		set_user_info(id, "_ah", "0");
		set_user_info(id, "dm", "0");
		set_user_info(id, "tracker", "0");
		set_user_info(id, "friends", "0");
		set_user_info(id, "*bot", "1");

		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FAKECLIENT);
		set_pev(id, pev_colormap, id);

		dllfunc(DLLFunc_ClientConnect, id, "BOT DEMO", "127.0.0.1");
		dllfunc(DLLFunc_ClientPutInServer, id);

		cs_set_user_team(id, 1);
		cs_set_user_model(id, "leet");

		if(!is_user_alive(id))
			dllfunc(DLLFunc_Spawn, id);

		set_pev(id, pev_takedamage, DAMAGE_NO);
		give_item(id, "weapon_knife");
		give_item(id, "weapon_usp");
		g_bot_enable = 1;
		return id;
	}
	return 0;
}
Create_Bot_c()
{
	new txt[64];
	StringTimer(gc_ReplayBestRunTime, gc_bBestTimer, sizeof(gc_bBestTimer) - 1);
	formatex(txt, charsmax(txt), "[NUB] %s %s", gc_ReplayName, gc_bBestTimer);
	new id = engfunc(EngFunc_CreateFakeClient, txt);
	if(pev_valid(id))
	{
		set_user_info(id, "rate", "10000");
		set_user_info(id, "cl_updaterate", "60");
		set_user_info(id, "cl_cmdrate", "101");
		set_user_info(id, "cl_lw", "1");
		set_user_info(id, "cl_lc", "1");
		set_user_info(id, "cl_dlmax", "512");
		set_user_info(id, "cl_righthand", "1");
		set_user_info(id, "_vgui_menus", "0");
		set_user_info(id, "_ah", "0");
		set_user_info(id, "dm", "0");
		set_user_info(id, "tracker", "0");
		set_user_info(id, "friends", "0");
		set_user_info(id, "*bot", "1");

		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FAKECLIENT);
		set_pev(id, pev_colormap, id);

		dllfunc(DLLFunc_ClientConnect, id, "BOT DEMO2", "127.0.0.1");
		dllfunc(DLLFunc_ClientPutInServer, id);

		cs_set_user_team(id, 1);
		cs_set_user_model(id, "leet");

		if(!is_user_alive(id))
			dllfunc(DLLFunc_Spawn, id);

		set_pev(id, pev_takedamage, DAMAGE_NO);
		give_item(id, "weapon_knife");
		give_item(id, "weapon_usp");
		gc_bot_enable = 1;
		return id;
	}
	return 0;
}
Start_Bot()
{
	g_bot_frame = 0;
	start_climb_bot(g_bot_id);
	return 0;
}

Start_Bot_c()
{
	gc_bot_frame = 0;
	start_climb_bot_c(gc_bot_id);
	return 0;
}

Remove_Bot()
{
	server_cmd("kick #%d", get_user_userid(g_bot_id))
	//destroy_bot_icon(g_bot_id)
	g_bot_id = 0;
	g_bot_enable = 0;
	g_bot_frame = 0;
	ArrayClear(g_DemoPlaybot[0]);
}

Remove_Bot_c()
{
	server_cmd("kick #%d", get_user_userid(gc_bot_id));
	gc_bot_id = 0;
	gc_bot_enable = 0;
	gc_bot_frame = 0;
	ArrayClear(gc_DemoPlaybot[0]);
	return 0;
}

start_climb_bot(id)
{
	set_pev(g_bot_id, pev_gravity, 1.0);  // pev_gravity
	set_pev(g_bot_id, pev_movetype, MOVETYPE_WALK);   // pev_movetype
	reset_checkpoints(g_bot_id);
	IsPaused[g_bot_id] = false;
	timer_started[g_bot_id] = true;
	timer_time[g_bot_id] = get_gametime();
	return 0;
}

start_climb_bot_c(id)
{
	set_pev(gc_bot_id, pev_gravity, 1.0);  // pev_gravity
	set_pev(gc_bot_id, pev_movetype, MOVETYPE_WALK);   // pev_movetype
	reset_checkpoints(gc_bot_id);
	IsPaused[gc_bot_id] = false;
	timer_started[gc_bot_id] = true;
	timer_time[gc_bot_id] = get_gametime();
	return 0;
}

public fwd_Think(Ent)
{
	if (!pev_valid(Ent))
	{
		return 1;
	}
	static className[32];
	pev(Ent, 1, className, 31);
	if (equal(className, "bot_record"))
	{
		BotThink(g_bot_id);
		set_pev( Ent, pev_nextthink, get_gametime() + nExttHink );
	}
	return 1;
}

public fwd_Think_c(Ent)
{
	if (!pev_valid(Ent))
	{
		return 1;
	}
	static className[32];
	pev(Ent, 1, className, 31);
	if (equal(className, "bot_record"))
	{
		BotThink_c(gc_bot_id);
		set_pev( Ent, pev_nextthink, get_gametime() + nExttHink );
	}
	return 1;
}

public BotThink( id )
{
	static Float:last_check, Float:game_time, nFrame;
	game_time = get_gametime();

	if( game_time - last_check > 1.0 ) //?帧数时差补偿？
	{
		if (nFrame < 100)
			nExttHink = nExttHink - 0.0001
		else if (nFrame > 100)
			nExttHink = nExttHink + 0.0001

		nFrame = 0;
		last_check = game_time;
	}

	if(g_bot_enable == 1 && g_bot_id)
	{
		// g_bot_frame++;
		new i;
		while (i < g_bot_speed) // 等价于 g_bot_frame += g_bot_speed
		{
			g_bot_frame += 1;
			i++;
		}
		if ( g_bot_frame < ArraySize( g_DemoPlaybot[0] ) )
		{
			new ArrayData[DemoData], Float:ViewAngles[3];
			ArrayGetArray(g_DemoPlaybot[0], g_bot_frame, ArrayData);

			ViewAngles[0] = ArrayData[flBotAngle][0];
			ViewAngles[1] = ArrayData[flBotAngle][1];
			ViewAngles[2] = 0.0;

			if(ArrayData[iButton]&IN_ALT1) ArrayData[iButton]|=IN_JUMP;
			if(ArrayData[iButton]&IN_RUN)  ArrayData[iButton]|=IN_DUCK;

			if(ArrayData[iButton]&IN_RIGHT)
			{
				engclient_cmd(id, "weapon_usp");
				ArrayData[iButton]&=~IN_RIGHT;
			}
			if(ArrayData[iButton]&IN_LEFT)
			{
				engclient_cmd(id, "weapon_knife");
				ArrayData[iButton]&=~IN_LEFT;
			}
			//if ( ArrayData[iButton] & IN_USE )
			//{
			//	Ham_ButtonUse( id );
			//	ArrayData[iButton] &= ~IN_USE;
			//}
			engfunc(EngFunc_RunPlayerMove, id, ViewAngles, ArrayData[flBotVel][0], ArrayData[flBotVel][1], 0.0, ArrayData[iButton], 0, 10);
			set_pev(id, pev_v_angle, ViewAngles );
			ViewAngles[0] /= -3.0;
			set_pev(id, pev_velocity, ArrayData[flBotVel]);
			set_pev(id, pev_angles, ViewAngles);
			set_pev(id, pev_origin, ArrayData[flBotPos]);
			// set_pev(id, pev_button, ArrayData[iButton] );
			set_pev(id, pev_health, 99999.0);

			if( pev( id, pev_gaitsequence ) == 4 && ~pev( id, pev_flags ) & FL_ONGROUND )
				set_pev( id, pev_gaitsequence, 6 );

			if(nFrame == ArraySize( g_DemoPlaybot[0] ) - 1)
				Start_Bot();

		} else  {
			start_climb_bot(g_bot_id);
			g_bot_frame = 0;
		}
	}
	nFrame++;
	return 0;
}

public BotThink_c(id)
{
	static Float:last_check, Float:game_time, nFrame;
	game_time = get_gametime();

	if( game_time - last_check > 1.0 ) //?帧数时差补偿？
	{
		if (nFrame < 100)
			nExttHink = nExttHink - 0.0001
		else if (nFrame > 100)
			nExttHink = nExttHink + 0.0001

		nFrame = 0;
		last_check = game_time;
	}

	if(gc_bot_enable == 1 && gc_bot_id)
	{
		new i;
		while (i < gc_bot_speed) // 确定bot的播放速度 默认 1
		{
			gc_bot_frame += 1;
			i++;
		}
		if ( gc_bot_frame < ArraySize( gc_DemoPlaybot[0] ) )
		{
			new ArrayData[DemoData], Float:ViewAngles[3];
			ArrayGetArray(gc_DemoPlaybot[0], gc_bot_frame, ArrayData);

			ViewAngles[0] = ArrayData[flBotAngle][0];
			ViewAngles[1] = ArrayData[flBotAngle][1];
			ViewAngles[2] = 0.0;

			if(ArrayData[iButton]&IN_ALT1) ArrayData[iButton]|=IN_JUMP;
			if(ArrayData[iButton]&IN_RUN)  ArrayData[iButton]|=IN_DUCK;

			if(ArrayData[iButton]&IN_RIGHT)
			{
				engclient_cmd(id, "weapon_usp");
				ArrayData[iButton]&=~IN_RIGHT;
			}
			if(ArrayData[iButton]&IN_LEFT)
			{
				engclient_cmd(id, "weapon_knife");
				ArrayData[iButton]&=~IN_LEFT;
			}
			//if ( ArrayData[iButton] & IN_USE )
			//{
			//	Ham_ButtonUse( id );
			//	ArrayData[iButton] &= ~IN_USE;
			//}
			engfunc(EngFunc_RunPlayerMove, id, ViewAngles, ArrayData[flBotVel][0], ArrayData[flBotVel][1], 0.0, ArrayData[iButton], 0, 10);
			set_pev(id, pev_v_angle, ViewAngles );
			ViewAngles[0] /= -3.0;
			set_pev(id, pev_velocity, ArrayData[flBotVel]);
			set_pev(id, pev_angles, ViewAngles);
			set_pev(id, pev_origin, ArrayData[flBotPos]);
			// set_pev(id, pev_button, ArrayData[iButton] );
			set_pev(id, pev_health, 99999.0);

			if( pev( id, pev_gaitsequence ) == 4 && ~pev( id, pev_flags ) & FL_ONGROUND )
				set_pev( id, pev_gaitsequence, 6 );

			if(nFrame == ArraySize( gc_DemoPlaybot[0] ) - 1)
				Start_Bot_c();

		}
		// 播放完毕 重置相关帧数
		else{
			start_climb_bot_c(gc_bot_id);
			gc_bot_frame = 0;
		}
	}
	nFrame++;
	return 0;
}

public fnUpdateGameName()
{ 
	static id,num;id++;num=0;
	switch(id)
	{
		/*case 1:
		{
			for(new i=1; i  <= max_players; i++)
			{	
				if(is_user_connected(i))
				{
					if(is_user_steam(i))
					{	
						num++;
					}
				}
			}
			format(szGameName,charsmax(szGameName),"Steam players (%i / %i)",num,max_players);
		}*/
		case 2:
		{
			for(new i=1; i  <= max_players; i++)
			{
				if(is_user_connected(i))
				{
					if(is_user_admin(i))
					{
						num++;
					}
				}
			}
			format(szGameName,charsmax(szGameName),"Admins Online(%i / %i)",num,max_players);
		}
		case 3:
		{
			format(szGameName,charsmax(szGameName),"Counter-Strike");
		}
		case 4:
		{
			format(szGameName,charsmax(szGameName),"#KZ Server");
			id=1;

		}
	}
	set_task(6.0,"fnUpdateGameName");
}

/*
stock bool:is_user_steam(id) //Sho0ter
{
	static dp_pointer;
	if( dp_pointer || ( dp_pointer = get_cvar_pointer ("dp_r_id_provider")))
	{
		server_cmd("dp_clientinfo %d",id);
		server_exec();
		return (get_pcvar_num(dp_pointer)==2) ? true : false;
	}
	return false;
}*/


public fnGetGameDescription()
{
	forward_return(FMV_STRING,szGameName);
	return FMRES_SUPERCEDE;
}

public onResetHUD(id)
{
	HudApplyCVars()
	new iHideFlags = GetHudHideFlags()
	if(iHideFlags)
	{
		message_begin(MSG_ONE, g_msgHideWeapon, _, id)
		write_byte(iHideFlags)
		message_end()
	}	
}

GetHudHideFlags()
{
	new iFlags

	if( g_bHideRHA )
		iFlags |= HUD_HIDE_RHA
	if( g_bHideTimer )
		iFlags |= HUD_HIDE_TIMER
	if( g_bHideMoney )
		iFlags |= HUD_HIDE_MONEY 

	return iFlags
}

public msgHideWeapon()
{
	new iHideFlags = GetHudHideFlags()
	if(iHideFlags)
		set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | iHideFlags)
}

HudApplyCVars()
{
	g_bHideRHA = bool:get_pcvar_num(kz_hiderhr)
	g_bHideTimer = bool:get_pcvar_num(kz_hidetime)
	g_bHideMoney = bool:get_pcvar_num(kz_hidemoney)
}

public cmdUpdateWRdata(id)
{
	if (!is_user_bot(id) && get_playersnum() < 2)
	{
		new authid[32]
		get_user_authid(id, authid,31)
		
		if(get_user_flags(id) & KZ_LEVEL || equali(authid, "STEAM_0:0:60711210") || is_user_localhost(id))
		{
			UpdateRecords();
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print(id, print_console,"[KZ] 无法使用该命令.");
		}
	}
	else
	{
		client_print(id, print_chat,"[KZ] 当前SERVER玩家人数必须小于2 才可以更新!");
	}
	return PLUGIN_HANDLED;
}

#if defined KZ_AUTO_JOIN_CT
public message_show_menu(msgid, dest, id) 
{
	if (is_user_bot (id))
	{
		return PLUGIN_HANDLED
	}
	
	if(block_change[id]) 
	{
		return PLUGIN_HANDLED
	}
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(12288); // 8192 = 2 seconds
	write_short(512);
	write_short(0x0000);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	static team_select[] = "#Team_Select"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE

	set_force_team_join_task(id, msgid)
	block_change[id] = true
	return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id)
{
	if (is_user_bot (id))
	{
		return PLUGIN_HANDLED
	}
	if(block_change[id]) 
	{
		return PLUGIN_HANDLED
	}	

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(12288); // 8192 = 2 seconds
	write_short(512);
	write_short(0x0000);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();
	
	if (get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID)
		return PLUGIN_CONTINUE

	set_force_team_join_task(id, msgid)
	block_change[id] = true
	return PLUGIN_HANDLED
}

set_force_team_join_task(id, menu_msgid) {
	static param_menu_msgid[2]
	param_menu_msgid[0] = menu_msgid
	set_task(0.1, "task_force_team_join", id, param_menu_msgid, sizeof param_menu_msgid)
}

public task_force_team_join(menu_msgid[], id) {
	if (get_user_team(id))
		return

	force_team_join(id, menu_msgid[0])
}

stock force_team_join(id, menu_msgid)
{
	static jointeam[] = "jointeam"
	static msg_block, joinclass[] = "joinclass"
	msg_block = get_msg_block(menu_msgid)
	set_msg_block(menu_msgid, BLOCK_SET)
	engclient_cmd(id, jointeam, "2")
	engclient_cmd(id, joinclass, "5")


	set_msg_block(menu_msgid, msg_block)
}
#endif

public ExtendTime(id)//延长时间
{
	if (! (get_user_flags( id ) & KZ_LEVEL ))
	{
		return PLUGIN_HANDLED
	}
	new arg[32];
	read_argv(1, arg, 31);
 	new curlimit = get_pcvar_num(mp_timelimit);
	new newlimit = curlimit + str_to_num(arg);
	new name[32];
  	get_user_name(id, name, 31);
	
	if (addtimemapcount[id] < 10)
	{
	
		if (str_to_num(arg) < 30)
		{
			set_pcvar_num(mp_timelimit, newlimit);
			new tl = get_timeleft();
			ColorChat(0, GREEN, "%s ^1ADMIN: ^3%s ^1%L^3 %d ^1Min, TiMe Left: (^3%d:%02d^1)", prefix, name, LANG_PLAYER, "KZ_ETIME_ADDTIME", str_to_num(arg), (tl / 60), (tl % 60));
		}
		else
		{
			ColorChat(id, GREEN, "%s ^1%L", prefix, id, "KZ_ETIME_ADDNB");		
		}		
	}
	else
	{
		ColorChat(id, GREEN, "%s ^1%L", prefix, id, "KZ_ETIME_LOSTIME");
	}
	addtimemapcount[id]++;
	return PLUGIN_HANDLED;
}

public client_command(id)
{
	
	new sArg[13];
	if( read_argv(0, sArg, 12) > 11 )
	{
		return PLUGIN_CONTINUE;
	}
	
	for( new i = 0; i < sizeof(g_weaponsnames); i++ )
	{
		if( equali(g_weaponsnames[i], sArg, 0) )
		{
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public iRank() {
  
	if(equali(counwr, "err" )) rank = "Unknown"
	else if(equali(counwr, "AE" )) rank = "The United Arab Emirates"
	else if(equali(counwr, "SA" )) rank = "Saudi"
	else if(equali(counwr, "AR" )) rank = "Argentina"
	else if(equali(counwr, "AM" )) rank = "Armenia"
	else if(equali(counwr, "AU" )) rank = "Australia"
	else if(equali(counwr, "AT" )) rank = "Austria"
	else if(equali(counwr, "AZ" )) rank = "Azerbaijan"
	else if(equali(counwr, "BD" )) rank = "Bengali"
	else if(equali(counwr, "BE" )) rank = "Belgium"
	else if(equali(counwr, "BZ" )) rank = "Belize"
	else if(equali(counwr, "BY" )) rank = "Belarus"
	else if(equali(counwr, "BO" )) rank = "bolivia" 
	else if(equali(counwr, "BA" )) rank = "Bosnia and Herzegovina"
	else if(equali(counwr, "BR" )) rank = "Brazil"
	else if(equali(counwr, "BG" )) rank = "Bulgaria"
	else if(equali(counwr, "CL" )) rank = "Chile"
	else if(equali(counwr, "CN" )) rank = "China"
	else if(equali(counwr, "HR" )) rank = "Croatia"
	else if(equali(counwr, "CY" )) rank = "Cyprus"
	else if(equali(counwr, "TD" )) rank = "Chad"
	else if(equali(counwr, "ME" )) rank = "Montenegro"
	else if(equali(counwr, "CZ" )) rank = "Czech"
	else if(equali(counwr, "DK" )) rank = "Denmark"
	else if(equali(counwr, "DM" )) rank = "Dominican"
	else if(equali(counwr, "DO" )) rank = "Dominican Republic" 
	else if(equali(counwr, "EG" )) rank = "Egypt"
	else if(equali(counwr, "EE" )) rank = "Estonia" 
	else if(equali(counwr, "PH" )) rank = "The Philippines"
	else if(equali(counwr, "FI" )) rank = "Finland"
	else if(equali(counwr, "FR" )) rank = "France" 
	else if(equali(counwr, "TF" )) rank = "Southern territory of France"
	else if(equali(counwr, "GH" )) rank = "Ghana" 
	else if(equali(counwr, "GR" )) rank = "Greece"
	else if(equali(counwr, "GD" )) rank = "Grenada"
	else if(equali(counwr, "GL" )) rank = "Greenland" 
	else if(equali(counwr, "GE" )) rank = "Georgia"
	else if(equali(counwr, "GU" )) rank = "Guam"
	else if(equali(counwr, "GF" )) rank = "French Guiana"
	else if(equali(counwr, "GY" )) rank = "Guyana" 
	else if(equali(counwr, "ES" )) rank = "Spain" 
	else if(equali(counwr, "NL" )) rank = "Netherlands"
	else if(equali(counwr, "HK" )) rank = "Hong Kong" 
	else if(equali(counwr, "IN" )) rank = "India"
	else if(equali(counwr, "ID" )) rank = "Indonesia"
	else if(equali(counwr, "IQ" )) rank = "Iraq" 
	else if(equali(counwr, "IR" )) rank = "Iran"
	else if(equali(counwr, "IE" )) rank = "Ireland"
	else if(equali(counwr, "IS" )) rank = "Iceland" 
	else if(equali(counwr, "IL" )) rank = "Israel"
	else if(equali(counwr, "JM" )) rank = "Jamaica"
	else if(equali(counwr, "JP" )) rank = "Japan" 
	else if(equali(counwr, "YE" )) rank = "Yemen"
	else if(equali(counwr, "JE" )) rank = "Jersey"
	else if(equali(counwr, "JO" )) rank = "Jordan"
	else if(equali(counwr, "KH" )) rank = "Cambodia"
	else if(equali(counwr, "CA" )) rank = "Canada"
	else if(equali(counwr, "QA" )) rank = "Qatar"
	else if(equali(counwr, "KZ" )) rank = "Kazakhstan"
	else if(equali(counwr, "KG" )) rank = "Kyrgyzstan"
	else if(equali(counwr, "CO" )) rank = "Columbia"
	else if(equali(counwr, "KR" )) rank = "Korea"
	else if(equali(counwr, "KP" )) rank = "North Korea"
	else if(equali(counwr, "CU" )) rank = "Cuba"
	else if(equali(counwr, "KW" )) rank = "Kuwait"
	else if(equali(counwr, "LA" )) rank = "Laos"
	else if(equali(counwr, "LB" )) rank = "Lebanon"
	else if(equali(counwr, "LY" )) rank = "Libya"
	else if(equali(counwr, "LT" )) rank = "Lithuania"
	else if(equali(counwr, "LU" )) rank = "Luxembourg"
	else if(equali(counwr, "LV" )) rank = "Latvia"
	else if(equali(counwr, "MK" )) rank = "Macedonia < Yugoslavia >"
	else if(equali(counwr, "MO" )) rank = "Macao"
	else if(equali(counwr, "MY" )) rank = "Malaysia"
	else if(equali(counwr, "MA" )) rank = "Morocco"
	else if(equali(counwr, "MU" )) rank = "Mauritius"
	else if(equali(counwr, "MX" )) rank = "Mexico"
	else if(equali(counwr, "MC" )) rank = "Monaco"
	else if(equali(counwr, "MN" )) rank = "Mongolia"
	else if(equali(counwr, "NP" )) rank = "Nepal"
	else if(equali(counwr, "DE" )) rank = "Germany"
	else if(equali(counwr, "NO" )) rank = "Norway"
	else if(equali(counwr, "NZ" )) rank = "New Zealand"
	else if(equali(counwr, "PK" )) rank = "Pakistan"
	else if(equali(counwr, "PS" )) rank = "Palestine"
	else if(equali(counwr, "PA" )) rank = "Panama"
	else if(equali(counwr, "PE" )) rank = "Peru"
	else if(equali(counwr, "PF" )) rank = "French Polynesia"
	else if(equali(counwr, "PL" )) rank = "poland"
	else if(equali(counwr, "PT" )) rank = "Portugal"
	else if(equali(counwr, "TW" )) rank = "Taiwan"
	else if(equali(counwr, "ZA" )) rank = "South Africa"
	else if(equali(counwr, "CF" )) rank = "CAR" 
	else if(equali(counwr, "RU" )) rank = "Russia"
	else if(equali(counwr, "RO" )) rank = "Romania"
	else if(equali(counwr, "EH" )) rank = "Western Sahara"
	else if(equali(counwr, "MF" )) rank = "Saint Martin < France >"
	else if(equali(counwr, "RS" )) rank = "Serbia"
	else if(equali(counwr, "SG" )) rank = "Singapore"
	else if(equali(counwr, "SK" )) rank = "Slovakia"
	else if(equali(counwr, "SI" )) rank = "Slovenia"
	else if(equali(counwr, "LK" )) rank = "Sri Lanka"
	else if(equali(counwr, "US" )) rank = "U.S.A"
	else if(equali(counwr, "SD" )) rank = "Sultan"
	else if(equali(counwr, "SY" )) rank = "Syria"
	else if(equali(counwr, "CH" )) rank = "Switzerland"
	else if(equali(counwr, "SE" )) rank = "Sweden"
	else if(equali(counwr, "TJ" )) rank = "Tajikistan"
	else if(equali(counwr, "TH" )) rank = "Thailand"
	else if(equali(counwr, "TZ" )) rank = "Tanzania"
	else if(equali(counwr, "TN" )) rank = "Tunisia"
	else if(equali(counwr, "TR" )) rank = "Turkey"
	else if(equali(counwr, "TM" )) rank = "Turkmenistan"
	else if(equali(counwr, "UA" )) rank = "Ukraine"
	else if(equali(counwr, "UY" )) rank = "Uruguay"
	else if(equali(counwr, "UZ" )) rank = "Uzbekistan"
	else if(equali(counwr, "VE" )) rank = "Venezuela"
	else if(equali(counwr, "HU" )) rank = "Hungary"
	else if(equali(counwr, "GB" )) rank = "Britain"
	else if(equali(counwr, "VN" )) rank = "Vietnam"
	else if(equali(counwr, "IT" )) rank = "Italy"
	else if(equali(counwr, "CK" )) rank = "Cook Islands"
	else rank = "n/a"

	return rank
}

public iRankcr()
{
	if(equali(councr, "err" )) rank = "Unknown"
		else if(equali(councr, "CN" )) rank = "China"
		else if(equali(councr, "HK" )) rank = "Hong Kong" 
		else if(equali(councr, "MO" )) rank = "Macao"
		else if(equali(councr, "TW" )) rank = "Taiwan"
		else rank = "n/a"
	
	return rank
}

//# /wr
public show_Top1msg(id)
{
	new Pro1name[32],Nub1name[32],Wpn1name[32],authid[32]
	get_user_authid(id, authid, 31)
	
	for (new i = 0; i < num; i++) 
	{	
		Pro1name = Pro_Names[i]
		
		new imin,isec,ims
		imin = floatround(Pro_Times[i] / 60.0, floatround_floor)
		isec = floatround(Pro_Times[i] - imin * 60.0,floatround_floor)
		ims = floatround((Pro_Times[i] - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )

		if(Pro_Times[i] > 9999999.0 ) 
		{
			format(Pro1message, 127, "ProTop  [#1] No Record")
		}
		else{
			format(Pro1message, 511, "ProTop  [#1] %02i:%02i.%02i by %s", imin, isec, ims, Pro1name)  
		}
		
		new imin1,isec1,ims1
		imin1 = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
		isec1 = floatround(Noob_Tiempos[i] - imin1 * 60.0,floatround_floor)
		ims1 = floatround((Noob_Tiempos[i] - ( imin1 * 60.0 + isec1 ) ) * 100.0, floatround_round )
		Nub1name = Noob_Names[i]
		
		if(Noob_Tiempos[i] > 9999999.0 ) 
		{
			format(Nub1message, 127, "NubTop [#1] No Record")
		}
		else{
			format(Nub1message, 511, "NubTop [#1] %02i:%02i.%02i by %s", imin1, isec1, ims1, Nub1name) 
		}

		
		new Wpn1Weapon[32]
		Wpn1Weapon = Wpn_Weapon[i]
		Wpn1name = Wpn_Names[i]
		
		new imin2,isec2,ims2
		imin2 = floatround(Wpn_Timepos[i] / 60.0, floatround_floor)
		isec2 = floatround(Wpn_Timepos[i] - imin2 * 60.0,floatround_floor)
		ims2 = floatround((Wpn_Timepos[i] - ( imin2 * 60.0 + isec2 ) ) * 100.0, floatround_round )
		
		if(Wpn_Timepos[i] > 9999999.0 ) 
		{
			format(Wpn1message, 127, "WpnTop [#1] No Record")
		}
		else{
			format(Wpn1message, 511, "WpnTop [#1] %02i:%02i.%02i by %s", imin2, isec2, ims2, Wpn1name) 
		}
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED	
}

public CmdSayWR(id) 
{
	new e_Message[401], e_Author[6][32], e_Time[6][9], e_cnt[6][8], e_Extension[6][8], iLen, iFounds; 
	new cce_Author[6][32], cce_Time[6][9],cce_cnt[6][8], cce_Extension[6][8], cciFounds;
	new sue_Author[6][32], sue_Time[6][9],sue_cnt[6][8], sue_Extension[6][8], suiFounds;

	new e_Whatmap[32];
	new e_WhatFile[128];
	e_WhatFile = e_Records_WR

	new cce_WhatFile[128];
	cce_WhatFile = e_Records_CC

	new sue_WhatFile[128];
	sue_WhatFile = e_Records_SU

	if ( !e_Whatmap[0] ) 
	{
		e_Whatmap = e_MapName
	}

	//WR 从本地的cstrike\data\records\xj.txt cc.txt
	iFounds = GetRecordData( e_Whatmap, e_Author, e_Time,e_cnt, e_Extension, e_WhatFile );
	cciFounds = ccGetRecordData( e_Whatmap, cce_Author, cce_Time,cce_cnt,cce_Extension, cce_WhatFile );
	suiFounds = suGetRecordData( e_Whatmap, sue_Author, sue_Time,sue_cnt,sue_Extension, sue_WhatFile ); 

	if( iFounds > 0 )
	cce_CountryText = "[XJ]";

	if( cciFounds > 0 )
	cce_CountryText = "[Cosy]";

	if( suiFounds > 0 )
	cce_CountryText = "[SURF]";

	iLen = formatex( e_Message, 400, "Map Name: %s^n^n%s^n%s^n%s^n",e_Whatmap[0],Pro1message,Nub1message,Wpn1message);
	
	if( iFounds > 0 ) 
	{
		for( new i; i < iFounds; i++ )	//XJ
		{
			if( !e_Author[i][0] )
			break;
		
			new XJExtension[21]
			if( e_Extension[i][0] ) 
				format( XJExtension, 20, "[%s]",e_Extension[i])
			else 
				format( XJExtension, 20, "%s","[Routine]") 
			
			// 设置ProTop网页
			if( e_Time[ i ][ 0 ] == '*' )
			{
				// format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>**:**.**</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/err.png> <b>n/a </b><p><font color=#EEEEE0>Map of Website</font> Xtreme-Jumpst.eu",MapName, WEB_URL ); //web top
				format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>**:**.**</b></font> <font color=#EEEEE0>by</font> <img src = flags/err.png> <b>n/a </b><p><font color=#EEEEE0>Map of Website</font> Xtreme-Jumpst.eu",MapName); //web top
				format(WRTimes, 400, "\dWR - **:**.** by n/a" ); //top menu
				iLen += formatex( e_Message[ iLen ], 400 - iLen, "WR(XJ): **:**.** by n/a" ); //hud
			}
			else
			{
				// format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>%s</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/%s.png align=absmiddle height=32 width=32 /> <b>%s </b><p><font color=#EEEEE0>Record of Website</font> Xtreme-Jumpst.eu",MapName , e_Time[ i ], WEB_URL, e_cnt[ i ], e_Author[ i ] );		
				format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>%s</b></font> <font color=#EEEEE0>by</font> <img src = flags/%s.png align=absmiddle height=32 width=32 /> <b>%s </b><p><font color=#EEEEE0>Record of Website</font> Xtreme-Jumpst.eu",MapName , e_Time[ i ], e_cnt[ i ], e_Author[ i ] );		
				format(WRTimes, 400, "\dWR - \y%s \dby \y%s", e_Time[ i ], e_Author[ i ] );		
				format(counwr, 31, "%s",e_cnt[i]); 
				iLen += formatex( e_Message[iLen], 400 - iLen, "^n%s%s %s by %s [%s]",cce_CountryText,XJExtension, e_Time[i], e_Author[i],iRank());//e_cnt[i] 
			}
		}
	}
	
	else if( cciFounds > 0 ) 
	{ 
		for( new i; i < cciFounds; i++ ) 	//cosy
		{
			if( !cce_Author[i][0] )
			break;
			new Extension[21]
				
			if( cce_Extension[i][0]) 
				format( Extension, 20, "[%s]",cce_Extension[i])
			else 
				format( Extension, 20, "%s","[Routine]")
			
			if( cce_Time[ i ][ 0 ] == '*' )	// 没找到对应的CC记录
			{
				// format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>**:**.**</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/err.png> <b>n/a </b><p><font color=#EEEEE0>Map of Website</font> <font color=#4876FF>Cosy-climbing.net</font>",MapName ,WEB_URL ); //web top
				format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>**:**.**</b></font> <font color=#EEEEE0>by</font> <img src = flags/err.png> <b>n/a </b><p><font color=#EEEEE0>Map of Website</font> <font color=#4876FF>Cosy-climbing.net</font>", MapName); //web top
				format(WRTimes, 400, "\dWR -  **:**.** by n/a" ); //top menu
				iLen += formatex( e_Message[ iLen ], 400 - iLen, "WR[CC]: **:**.** by n/a" ); //hud
			}
			else
			{
				format(counwr, 31, "%s",cce_cnt[i]);
				format(WRTimes, 400, "\dWR - \y%s \dby \y%s", cce_Time[ i ], cce_Author[ i ] );		
				// format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>%s</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/%s.png align=absmiddle height=32 width=32 /> <b>%s </b><p><font color=#EEEEE0>Record of Website</font> <font color=#4876FF>Cosy-climbing.net</font>",MapName , cce_Time[ i ], WEB_URL, cce_cnt[ i ], cce_Author[ i ] );
				format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>%s</b></font> <font color=#EEEEE0>by</font> <img src=flags/%s.png align=absmiddle height=32 width=32 /> <b>%s </b><p><font color=#EEEEE0>Record of Website</font> <font color=#4876FF>Cosy-climbing.net</font>",MapName , cce_Time[ i ], cce_cnt[ i ], cce_Author[ i ] );
				iLen += formatex(e_Message[iLen], 400 - iLen, "^n%s%s %s by %s [%s]",cce_CountryText,Extension, cce_Time[i], cce_Author[i] ,iRank());//cce_cnt[i]
			}
		}
	}
	else if( suiFounds > 0 ) //surf
	{
		for( new i; i < suiFounds; i++ ) 
		{//SURF纪录
		 
			if( !sue_Author[i][0] )
			break;

			new SUExtension[21]
			
			if( sue_Extension[i][0])
				format( SUExtension, 20, "[%s]",sue_Extension[i])
			
			else format( SUExtension, 20, "%s","[Routine]")
			
			format(counwr, 31, "%s",sue_cnt[i]);
			iLen += formatex(e_Message[iLen], 400 - iLen, "^n%s%s %s by %s [%s]",cce_CountryText,SUExtension, sue_Time[i], sue_Author[i] ,iRank());//sue_cnt[i]
			
		}
	}
		
	else 
	{
		iLen += formatex( e_Message[iLen], 400 - iLen, "No Map" );
		format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> This Map not </font>WR. <p><font color=#EEEEE0>Map of Website</font> Unknown.",MapName);
		format(WRTimes, 400, "\dWR - Website Unknown or No Map" );
	}
	
	set_hudmessage(12, 122, 221, 0.01, 0.13, _, _,6.0, 0.5, 2.0, -1);	
	show_hudmessage(id,e_Message);
	
	return PLUGIN_HANDLED
	
}

public CmdSayCR(id) 
{
	new cre_Message[401];
	new cre_Author[6][32], cre_Time[6][9],cre_cnt[6][8], cre_Extension[6][8], criLen,criFounds;

	new e_Whatmap[32];

	new cre_WhatFile[128];
	cre_WhatFile = e_Records_CR
	
	if ( !e_Whatmap[0] ) {
	  
		e_Whatmap = e_MapName
	}
	
	criFounds = crGetRecordData( e_Whatmap, cre_Author, cre_Time,cre_cnt,cre_Extension, cre_WhatFile );

	cre_CountryText = "[NTJUMP]";
	criLen = formatex( cre_Message, 400, "Map Name: %s^n^n",e_Whatmap[0]);
	
	if( criFounds > 0 ) 
	{
		for( new i; i < criFounds; i++ ) 
		{
		  
			if( !cre_Author[i][0] )
			break;
			
			new CRExtension[21]
			if( cre_Extension[i][0] ) 
				format( CRExtension, 20, "[%s]",cre_Extension[i])
			else 
				format( CRExtension, 20, "%s","[Routine]")
		
			if( cre_Time[ i ][ 0 ] == '*' )
			{
				format(NTTimes, 400, "\dNT - **:**:** by n/a" );	//top menu
				criLen += formatex( cre_Message[ criLen ], 400 - criLen, "[NTjump]: **:**:** by n/a" );	//hud
			}
			else
			{
				format(councr, 31, "%s",cre_cnt[i]);
				format(NTTimes, 400, "\dNT - \y%s \dby \y%s", cre_Time[ i ], cre_Author[ i ] );		
				criLen += formatex( cre_Message[criLen], 400 - criLen, "^n%s%s %s by %s [%s]^n^n",cre_CountryText,CRExtension, cre_Time[i], cre_Author[i],iRankcr());//cre_cnt[i]
			}
		}
	}
	
	else 
	{ 
		criLen += formatex( cre_Message[criLen], 400 - criLen, "[NTjump] No Map" );
		format(NTTimes, 400, "\dNT - Website Unknown or No Map" );
	}
	
	set_hudmessage(255, 192, 203, 0.01, 0.13, _, _,6.0, 0.5, 2.0, -1);	
	show_hudmessage(id,cre_Message);
	
	return PLUGIN_HANDLED
}

ClimbtimeToString( const Float:flClimbTime, szOutPut[], const iLen ) {
  
	if( !flClimbTime ) {
		copy( szOutPut, iLen, "**:**.**" );
		return;
	}
	
	new iMinutes = floatround( flClimbTime / 60.0, floatround_floor );
	new iSeconds = floatround( flClimbTime - iMinutes * 60, floatround_floor );
	new iMiliSeconds = floatround( ( flClimbTime - ( iMinutes * 60 + iSeconds ) ) * 100 , floatround_round );
	
	formatex( szOutPut, iLen, "%02i:%02i.%02i", iMinutes, iSeconds, iMiliSeconds );
	
}

GetRecordData( const Map[ 32 ], Jumper[ 6 ][ 32 ], Time[ 6 ][ 9 ],cnt[ 6 ][ 8 ], Extension[ 6 ][ 8 ], e_WhatFile[ 128 ]) {
  
	new szData[ 64 ], szMap[ 32 ], szTime[ 9 ], /*tmpTime[9],*/ iFounds, iLen, iMapLen = strlen( Map );
	new RecFile[128]
	
	RecFile = e_WhatFile

	new iFile = fopen( RecFile, "rt" );

	if( !iFile )
	
		return 0;

	while( !feof( iFile ) )
	{
	  
		fgets( iFile, szData, 63 );
		trim( szData );

		if( !szData[ 0 ] || !equali( szData, Map, iMapLen ) )
		
			continue;
		
		iLen = 1 + copyc( szMap, 31, szData, ' ' );

		if( szMap[ iMapLen ] != '[' && iMapLen != strlen( szMap ) )
			continue;

		iLen += 1 + copyc( szTime, 8, szData[ iLen ], ' ' );
		iLen += 1 + copyc( Jumper[ iFounds ], 32, szData[ iLen ], ' ' );
		
		
		copyc( cnt[ iFounds ], 2, szData[ iLen ], ' ' );

		if(szTime[0] == '*' || (equal(Jumper[ iFounds ], "n/a") && str_to_float(szTime) == 0.0))
		{
			norecord = 1;
		}
		else
		{
			if(equali(Map, MapName) && iFounds < 5)
			{
				g_flWorldRecordTime[iFounds] = FloatTimer(szTime);
				DiffWRTime[iFounds] = FloatTimer(szTime);
				if (DiffWRTime[iFounds] < DiffWRTime[0] && iFounds > 0 ) 
				{
					DiffWRTime[0] = DiffWRTime[iFounds];
				}
				copy(g_szWorldRecordPlayer[iFounds], sizeof(g_szWorldRecordPlayer[]) - 1, Jumper[ iFounds ]);
			}
		}

		
		ClimbtimeToString( str_to_float( szTime ), szTime, 8 );
		
		copy( Time[ iFounds ], 8, szTime );
		
		if( szMap[ iMapLen ] == '[' )
		
		copyc( Extension[ iFounds ], 8, szMap[ iMapLen + 1 ], ']' );

		iFounds++;
		if(equali(Map, MapName) && !g_iWorldRecordsNum && iFounds && (norecord != 1))
		{
			g_iWorldRecordsNum = iFounds;
			if(g_iWorldRecordsNum > 5)
				g_iWorldRecordsNum = 5;
		}
	}	
	fclose( iFile );
	return iFounds;
}

ccGetRecordData( const ccMap[ 32 ], ccJumper[ 6 ][ 32 ], ccTime[ 6 ][ 9 ],cccnt[ 6 ][ 8 ],ccExtension[ 6 ][ 8 ], cce_WhatFile[ 128 ]) {
  
	new ccszData[ 64 ], ccszMap[ 32 ], ccszTime[ 9 ], cciFounds, cciLen, cciMapLen = strlen( ccMap );
	new ccRecFile[128]
	
	ccRecFile = cce_WhatFile

	new cciFile = fopen( ccRecFile, "rt" );
	
	if( !cciFile )
		return 0;

	while( !feof( cciFile ) ) 
	{
	  
		fgets( cciFile, ccszData, 63 );
		trim( ccszData );

		if( !ccszData[ 0 ] || !equali( ccszData, ccMap, cciMapLen ) )
		
			continue;

		cciLen = 1 + copyc( ccszMap, 31, ccszData, ' ' );

		if( ccszMap[ cciMapLen ] != '[' && cciMapLen != strlen( ccszMap ) )
		
			continue;

		cciLen += 1 + copyc( ccszTime, 8, ccszData[ cciLen ], ' ' );
		cciLen += 1 +copyc( ccJumper[ cciFounds ], 32, ccszData[ cciLen ], ' ' );
		copyc( cccnt[ cciFounds ], 2, ccszData[ cciLen ], ' ');
		
		if(ccszTime[0] == '*' || (equal(ccJumper[ cciFounds ], "n/a") && str_to_float(ccszTime) == 0.0))
		{
			norecord = 1;
		}
		else
		{
			if(equali(ccMap, MapName) && cciFounds < 5)
			{
				g_flWorldRecordTime[cciFounds] = FloatTimer(ccszTime);
				DiffWRTime[cciFounds] = FloatTimer(ccszTime);
				if (DiffWRTime[cciFounds] < DiffWRTime[0] && cciFounds > 0 ) 
				{
					DiffWRTime[0] = DiffWRTime[cciFounds];
				}
				copy(g_szWorldRecordPlayer[cciFounds], sizeof(g_szWorldRecordPlayer[]) - 1, ccJumper[cciFounds]);
			}
		}

		ClimbtimeToString( str_to_float( ccszTime ), ccszTime, 8 );

		copy( ccTime[ cciFounds ], 8, ccszTime );
		if( ccszMap[ cciMapLen ] == '[' )
		
		copyc( ccExtension[ cciFounds ], 8, ccszMap[ cciMapLen + 1 ], ']' );

		cciFounds++;
		if(equali(ccMap, MapName) && !g_iWorldRecordsNum && cciFounds && (norecord != 1))
		{
			g_iWorldRecordsNum = cciFounds;
			if(g_iWorldRecordsNum > 5)
				g_iWorldRecordsNum = 5;
		}
	}
	fclose( cciFile );
	
	return cciFounds;
}

suGetRecordData( const suMap[32], suJumper[6][32], suTime[6][9],sucnt[6][8],suExtension[6][8], sue_WhatFile[128]) {
  
	new suszData[64], suszMap[32], suszTime[9], suiFounds, suiLen, suiMapLen = strlen( suMap );

	new suRecFile[128]
	
	suRecFile = sue_WhatFile

	new suiFile = fopen( suRecFile, "rt" );
	
	if( !suiFile )
		return 0;

	while( !feof( suiFile ) ) 
	{
		fgets( suiFile, suszData, 63 );
		trim( suszData );

		if( !suszData[ 0 ] || !equali( suszData, suMap, suiMapLen ) )
		
			continue;

		suiLen = 1 + copyc( suszMap, 31, suszData, ' ' );

		if( suszMap[ suiMapLen ] != '[' && suiMapLen != strlen( suszMap ) )
		
			continue;

		suiLen += 1 + copyc( suszTime, 8, suszData[ suiLen ], ' ' );
		suiLen += 1 +copyc( suJumper[ suiFounds ], 32, suszData[ suiLen ], ' ' );
		
		copyc( sucnt[ suiFounds ], 2, suszData[ suiLen ], ' ');

		if(equali(suMap, MapName) && suiFounds < 5)
		{
			g_flWorldRecordTime[suiFounds] = FloatTimer(suszTime);
			DiffWRTime[suiFounds] = FloatTimer(suszTime);
			if (DiffWRTime[suiFounds] < DiffWRTime[0] && suiFounds > 0 ) 
			{
				DiffWRTime[0] = DiffWRTime[suiFounds];
			}
			copy(g_szWorldRecordPlayer[suiFounds], sizeof(g_szWorldRecordPlayer[]) - 1, suJumper[ suiFounds ]);
		}
		
		ClimbtimeToString( str_to_float( suszTime ), suszTime, 8 );

		copy( suTime[ suiFounds ], 8, suszTime );
		if( suszMap[ suiMapLen ] == '[' )
		
		copyc( suExtension[ suiFounds ], 8, suszMap[ suiMapLen + 1 ], ']' );

		suiFounds++;
		g_iWorldRecordsNum = suiFounds;
	}
	fclose( suiFile );
	return suiFounds;
}

crGetRecordData( const crMap[ 32 ], crJumper[ 6 ][ 32 ], crTime[ 6 ][ 9 ], crcnt[6][8],crExtension[ 6 ][ 8 ], cre_WhatFile[ 128 ]) {
	new crszData[ 64 ], crszMap[ 32 ], crszTime[ 9 ], criFounds, criLen, criMapLen = strlen( crMap );
	new crRecFile[128]
	
	crRecFile = cre_WhatFile

	new criFile = fopen( crRecFile, "rt" );
	if( !criFile )
		return 0;

	while( !feof( criFile ) ) {
	  
		fgets( criFile, crszData, 63 );
		trim( crszData );

		if( !crszData[ 0 ] || !equali( crszData, crMap, criMapLen ) )
		
			continue;

		criLen = 1 + copyc( crszMap, 31, crszData, ' ' );

		if( crszMap[ criMapLen ] != '[' && criMapLen != strlen( crszMap ) )
		
			continue;

		criLen += 1 + copyc( crszTime, 8, crszData[ criLen ], ' ' );
		criLen += 1 + copyc( crJumper[ criFounds ], 32, crszData[ criLen ], ' ' );
		
		copyc( crcnt[ criFounds ], 2, crszData[ criLen ], ' ');

		if(crszTime[0] == '*' || (equal(crJumper[ criFounds ], "n/a") && str_to_float(crszTime) == 0.0))
		{
			norecord = 1;
		}
		else
		{
			if(equali(crMap, MapName) && criFounds < 5)
			{
				g_flWorldRecordTime[criFounds] = FloatTimer(crszTime);
				DiffNTRTime[criFounds] = FloatTimer(crszTime);
				if (DiffNTRTime[criFounds] < DiffNTRTime[0] && criFounds > 0 ) 
				{
					DiffNTRTime[0] = DiffNTRTime[criFounds];
				}
				copy(g_szWorldRecordPlayer[criFounds], sizeof(g_szWorldRecordPlayer[]) - 1, crJumper[ criFounds ]);
			}
		}

		
		ClimbtimeToString( str_to_float( crszTime ), crszTime, 8 );

		copy( crTime[criFounds], 8, crszTime );

		if( crszMap[criMapLen] == '[' )
		
		copyc( crExtension[criFounds], 8, crszMap[criMapLen + 1], ']' );

		criFounds++;
		if(equali(crMap, MapName) && !g_iNtRecordsNum && criFounds && (norecord != 1))
		{
			g_iNtRecordsNum = criFounds;
			if(g_iNtRecordsNum > 5)
				g_iNtRecordsNum = 5;
		}
	}
	
	fclose( criFile );
	return criFounds;
}

public ReadWeb ( const iSocket) 
{
	new RecFile[128]
	
	if ( e_UpdatedNR == 1 ) 
	RecFile = e_Records_WR

	if ( e_UpdatedNR == 2 ) 
	RecFile = e_Records_CC

	if ( e_UpdatedNR == 3 ) 
	RecFile = e_Records_CR

	e_UpdatedNR++;
	while (socket_recv( iSocket, e_Buffer, 25000 )) 
	{
		if( e_Buffer[0] ) 
		{
			if( e_Buffer[0] == 'H' && e_Buffer[1] == 'T' ) // Header
			{
				new iPos;
				iPos = contain( e_Buffer, "^r^n^r^n" ) + 4;
				iPos += contain( e_Buffer[iPos], "^n" ) + 1;
				formatex( e_Buffer, charsmax( e_Buffer ), e_Buffer[iPos] );
			}
			new iFile = fopen( RecFile, "at" );
			fputs( iFile, e_Buffer );
			fclose( iFile ); 
		}
	}
	e_Buffer[0] = 0; // Clean the memory.
	socket_close( iSocket ); 
}

public UpdateRecords( ) 
{

	if ( file_exists( e_Records_WR ) )
		delete_file(e_Records_WR);

	if ( file_exists( e_Records_CC ) )
		delete_file(e_Records_CC);
	
	if ( file_exists( e_Records_CR ) )
		delete_file(e_Records_CR);

	if( file_exists( e_LastUpdate ) )
		delete_file( e_LastUpdate );

	new iYear, iMonth, iDay, szTemp[255];
	date( iYear, iMonth, iDay );

	new iFile = fopen( e_LastUpdate, "wt" );
	formatex( szTemp, 254, "%04i/%02i/%02i", iYear, iMonth, iDay );
	fputs( iFile, szTemp );
	fclose( iFile );
	//
	new e_Host[ 96 ], e_Url[ 96 ], e_Socket[ 256 ], iPos, iSocket;

	for( new i; i < 3; i++ ) 
	{
		copy( e_Host, 95, e_DownloadLinks[i][7] );
		iPos = contain( e_Host, "/" );

		if( iPos != -1 ) 
		{
			copy( e_Url, 95, e_Host[iPos + 1] );

			e_Host[iPos] = 0;
		}
	
		iSocket = socket_open( e_Host, 80, SOCKET_TCP, iPos );
		if( iPos > 0 )
		{ 
			switch(iPos) 
			{
				case 1: log_amx("Socket错误(%d) 无法建立 Socket", iPos);
				case 2: log_amx("Socket错误(%d) 无法解析 %s",iPos, e_Host);
				case 3: log_amx("Socket错误(%d) 无法连接 %s:80",iPos, e_Host);
			}
			continue;
		}
		formatex( e_Socket, 255, "GET /%s HTTP/1.1^nHost: %s^r^n^r^n", e_Url, e_Host );
		socket_send( iSocket, e_Socket, 255 );
		set_task( 0.25, "ReadWeb", iSocket );
	}
}

stock Float:FloatTimer(const szInPut[])
{
	new Float:flTime = 0.0;
	
	if(szInPut[2] == ':' && szInPut[5] == '.')
	{
		flTime+= ((szInPut[0] - 48) * 600.0) + ((szInPut[1] - 48) * 60.0);
		flTime+= ((szInPut[3] - 48) * 10.0) + (szInPut[4] - 48);
		flTime+= ((szInPut[6] - 48) / 10.0) + ((szInPut[7] - 48) / 100.0);
	}
	else
	{
		flTime = str_to_float(szInPut);
	}
	return flTime;
}

stock WRTimer(const Float:flRealTime, szOutPut[], const iSizeOutPut, bMiliSeconds = true, gametime = true)
{
	static Float:flTime, iMinutes, iSeconds;
	if(gametime)
	{
		flTime = get_gametime() - flRealTime;
	}
	else
	{
		flTime = flRealTime;
	}
	if(flTime < 0.0)
	{
		flTime = 0.0;
	}
	iMinutes = floatround(flTime / 60, floatround_floor);
	iSeconds = floatround(flTime - (iMinutes * 60), floatround_floor);
	formatex(szOutPut, iSizeOutPut, "%02d:%02d", iMinutes, iSeconds);
	
	if(bMiliSeconds)
	{
		static iMiliSeconds;
		iMiliSeconds = floatround((flTime - (iMinutes * 60 + iSeconds)) * 100, floatround_round);
		format(szOutPut, iSizeOutPut, "%s.%02d", szOutPut, iMiliSeconds);
	}
}

public cmd_help(id)
{
	//HTML转移符 &quot = "引号"
	
	static MOTD[2048], MLTITEL[24], Pos
	formatex(MLTITEL,23,"Server help", id)

	Pos = formatex(MOTD,sizeof MOTD - 1,"<meta charset=UTF-8><style type=^"text/css^">.h1 { color:#ffffff;font-weight:bold;} .h2 { color:#8b8b7a; font-weight:bold; font-family: Times New Roman}</style><body bgcolor=^"#000000^"><table width=^"100%%^" border=^"0^">")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Main Menu:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /menu")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Scout:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /scout")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Usp/knife +USP ammunition:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /usp")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Server Top:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /top15")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Vote map:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say rtv")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Change Server:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /server")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Checkpoint:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /cp Recommended bind &quotF4&quot console input: bind &quotf4&quot &quotsay /cp&quot")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* GoCheck:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /gc Recommended bind &quotF5&quot console input: bind &quotf5&quot &quotsay /gc&quot")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Stuck:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /stuck")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* GoStart:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /start Recommended bind &quotF2&quot console input: bind &quotf2&quot &quotsay /start&quot")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /respawn")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Restarttime:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /reset")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Go SPEC/CT:", id)
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /spec")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Check WR:", id) 
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /wr")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* Custom start point:", id) 
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /ss")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /set")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /cs")
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h1>* 1V1 Duel:", id) 
	Pos += formatex(MOTD[Pos],sizeof MOTD - 1 - Pos,"<tr><td class=h2>say /duel")
	show_motd(id,MOTD,MLTITEL)

	return PLUGIN_CONTINUE
}

public fwdPlayerPreThink(id)
{
	new entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32);	
	if(!is_user_alive(id) || is_user_bot(id)){
		return FMRES_IGNORED
	}
	if(!(pev(id, pev_flags)&FL_ONGROUND) && !(pev(id, pev_flags)&FL_INWATER) && !isFalling[id] && timer_started[id] && !IsPaused[id] && !equal(entname, "func_door") )
	{
		pev(id, pev_origin, vFallingStart[id])
		vFallingTime[id] = get_gametime() - timer_time[id]
		isFalling[id] = true
	}
	if(pev(id, pev_flags)&FL_ONGROUND && isFalling[id] && timer_started[id] && !IsPaused[id] && !is_user_bot(id)  && !equal(entname, "func_door"))
	{
		isFalling[id] = false
	}
	return FMRES_IGNORED	
}	

// =================================================================================================
// Global Functions
// =================================================================================================

public Pause(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_DUEL_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if (get_pcvar_num(kz_pause) == 0)
	{	
		kz_chat(id, "%L", id, "KZ_PAUSE_DISABLED")
		
		return PLUGIN_HANDLED
	}
	
	if(! is_user_alive(id) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		
		return PLUGIN_HANDLED
	}
	
	if(! timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_PAUSE_NOT_STARTED")			
		return PLUGIN_HANDLED
	}
		
	static Float:hpp[33]
	new entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32);
	
	if(!IsPaused[id]) 
	{
		if( ((!( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id)) || (equal(entname, "func_door") && !IsOnLadder(id))) && timer_started[id] && !tptostart[id])
		{
			kz_chat(id, "%L", id, "KZ_GROUND_PAUSE")
			return PLUGIN_HANDLED
		}
		
		tphook_user[id] = true
		
		g_pausetime[id] = get_gametime() - timer_time[id]
		timer_time[id] = 0.0
		
		static Float:velocityy[33][3], Float:v_angle[33][3];
		pev(id, pev_health, hpp[id])
		pev(id, pev_velocity, velocityy[id])
		pev(id, pev_velocity, pausedvelocity[id])
		pev(id, pev_origin, PauseOrigin[id])
		pev(id, pev_v_angle, v_angle[id])

		if(isFalling[id] && tptostart[id]) {
			MpbhopOrigin[id] = vFallingStart[id]
			isMpbhop[id] = true
		}
		
		IsPaused[id] = true
		
		// kz_chat(id, "%L", id, "KZ_PAUSE_ON")
	}
	else 
	{
		if( (!( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id)) || (equal(entname, "func_door") && !IsOnLadder(id)))
		{
			kz_chat(id, "%L", id, "KZ_GROUND_UNPAUSE")
			return PLUGIN_HANDLED
		}
		
		if(ishooked[id]) 
		{
			remove_hook(id)
		}
		
		if(get_user_noclip(id)) 
		{
			set_user_noclip(id,0)
		}
		
		if(timer_started[id])
		{
			// kz_chat(id, "%L", id, "KZ_PAUSE_OFF")
			client_print(id, print_center, " ")
			timer_time[id] = get_gametime() - g_pausetime[id] 			
		}
		
		IsPaused[id] = false
		set_pev(id, pev_angles	, v_angle[id])
		if(isMpbhop[id] && !GoPosed[id]) 
		{
			if(callfunc_begin("setprokreedzorigin","mpbhop.amxx") == 1) 
			{
				callfunc_push_int(id)
				callfunc_push_float(MpbhopOrigin[id][0])
				callfunc_push_float(MpbhopOrigin[id][1])
				callfunc_push_float(MpbhopOrigin[id][2])
				callfunc_end()
			}
			isMpbhop[id] = false
			set_pev(id, pev_fixangle, 1);
		}
		tptostart[id] = false
		set_pev(id, pev_origin, PauseOrigin[id])
		set_pev(id, pev_velocity, velocityy[id])
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_DUCKING );

		if(!GoPosHp[id] && !HealsOnMap) 
		{
			set_pev(id, pev_health, hpp[id])
		}
		tphook_user[id] = false
		inpausechecknumbers[id] = 0
		
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(255)
		write_byte(192)
		write_byte(203)
		write_byte(65)
		message_end()
	}
		
	return PLUGIN_HANDLED
}

public Teleport(id)
{
	if ( get_playersnum() > 1 && is_user_alive(id) || DefaultStop) 
	{
		static menuid, player, name[32], buffer[1]
		menuid = menu_create("\rTeleport Menu", "TeleportHandle")
		if(DefaultStop) 
		{
			menu_vadditem(menuid, "1", _, _, "%L", id, "KZ_TELEPORT_MENU1")
		}
		for (player = 1; player <= g_maxplayers; player++)
		{
			if (!is_user_alive(player) || /*is_user_bot(player) ||*/ player == id)
				continue;
			
			get_user_name(player, name, charsmax(name))
			
			if(DefaultStop)
			{
				buffer[0] = player + 1
			}
			else
			{
				buffer[0] = player
			}
			
			menu_additem(menuid, name, buffer)
		}
	
		menu_display(id, menuid)
	} 
	else 
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_ISDISABLED")
		kz_menu(id)
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}


public TeleportHandle(id, menuid, item)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id,"KZ_DUEL_DISABLED")
		return PLUGIN_HANDLED
	}
#endif

	if (item == MENU_EXIT)
	{
		kz_menu(id)
		return PLUGIN_HANDLED;
	}
	static buffer[1], dummy, player
	menu_item_getinfo(menuid, item, dummy, buffer, sizeof(buffer), _, _, dummy)
	
	if(DefaultStop) 
	{
		player = buffer[0] - 1
	} 
	else 
	{
		player = buffer[0]
	}
	
	new szPlayerName[32], szName[32]
	get_user_name(id, szName, 32)
	get_user_name(player, szPlayerName, 32)

	new entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32);
	if( ((!( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id)) || (equal(entname, "func_door") && !IsOnLadder(id))) && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L",id ,"KZ_GROUND_DISABLED")
		Teleport(id)
		return PLUGIN_HANDLED
	}
	
	if (timer_started[id] && !IsPaused[id]) 
	{
		tphook_user[id] = true
		Pause(id)
	}
	else if (timer_started[id] && IsPaused[id]) 
	{
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)
		tphook_user[id] = true
	}
	
	if (item == 0 && DefaultStop)
	{
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
		set_pev(id, pev_origin, DefaultStopPos)
		delay_duck(id)
		Teleport(id)
		return PLUGIN_HANDLED;
	}
	
	if (!is_user_alive(player) || player == id)
    {
		menu_destroy(menuid)

		return PLUGIN_HANDLED;
    }
	if ( get_gametime() - antiteleport[id] < 3.0 )
	{
		ColorChat(id, GREEN, "%s^x01 等待3秒冷却时间!", prefix)
		Teleport(id)
		return PLUGIN_HANDLED;
	} 
	static Float:pos[3]
	entity_get_vector(player, EV_VEC_origin, pos)
	entity_set_origin(id, pos)
	delay_duck(id)

	Teleport(id)
	
	antiteleport[id] = get_gametime()
	menu_destroy(menuid)
	
	return PLUGIN_HANDLED;
}

public delay_duck(id){
	new ida[1]
	ida[0]=id
	set_task(0.01,"force_duck",_,ida,1)
	set_entity_flags(ida[0],FL_DUCKING,1)
}

public force_duck(ida[1])
{
	set_entity_flags(ida[0],FL_DUCKING,1)
}

public kz_TimerEntity(iEnt)
{
	if(pev_valid(iEnt)) 
	{ 
		static ClassName[32]
		pev(iEnt, pev_classname, ClassName, 31)
		
		if(equal(ClassName, "kz_time_think"))
		{
			timer_task()
			set_pev(iEnt, pev_nextthink, get_gametime() + 0.08)
		}
	}
}


public timer_task()
{
	if ( get_pcvar_num(kz_show_timer) > 0 )
	{
		new Alive[32], Dead[32], alivePlayers, deadPlayers;
		get_players(Alive, alivePlayers, "ach")
		get_players(Dead, deadPlayers, "bch")
			
		for(new i=0;i<alivePlayers;i++)
		{
			new output[128];
			new Float:kreedztime, imin, Float:isec 
			
			kreedztime = get_gametime() - (IsPaused[Alive[i]] ? get_gametime() - g_pausetime[Alive[i]] : timer_time[Alive[i]])
			imin = floatround(kreedztime , floatround_floor)/60
			isec = kreedztime - (60*imin) + 0.02
			
			if( timer_started[Alive[i]])
			{
				if( ShowTime[Alive[i]] == 1)	//TXT TIME
				{
					if(HealsOnMap)
					{
						format(output, 127, "[ %02d:%s%.2f | %d/%d | HP: Godmode %s]",imin,isec < 10 ? "0" : "",isec,checknumbers[Alive[i]], gochecknumbers[Alive[i]], /*get_user_health(Alive[i]),*/ IsPaused[Alive[i]] ? "| *Paused* " : "");
					}
					else 
					{
						format(output, 127, "[ %02d:%s%.2f | %d/%d | HP: %d %s]", imin,isec < 10 ? "0" : "",isec,checknumbers[Alive[i]], gochecknumbers[Alive[i]], get_user_health(Alive[i]), IsPaused[Alive[i]] ? "| *Paused* " : "");
					}
				}
				else if( ShowTime[Alive[i]] == 2) //HUD TIME
				{
					if( IsPaused[Alive[i]]) 
					{
						set_hudmessage(200, 3, 0, 0.01, 0.91, 0, 0.0, 0.2, 0.0, 0.0, 3)
					} 
					else 
					{
						set_hudmessage(12, 122, 221, 0.01, 0.91, 0, 0.0, 0.2, 0.0, 0.0, 3)
					}
					
					if(HealsOnMap)
					{
						show_hudmessage(Alive[i], "[ %02d:%s%.2f | %d/%d | HP: Godmode %s]",imin,isec < 10 ? "0" : "",isec,checknumbers[Alive[i]], gochecknumbers[Alive[i]], /*get_user_health(Alive[i]),*/ IsPaused[Alive[i]] ? "| *Paused* " : "");
					}
					else
					{
						show_hudmessage(Alive[i], "[ %02d:%s%.2f | %d/%d | HP: %d %s]",imin,isec < 10 ? "0" : "",isec,checknumbers[Alive[i]], gochecknumbers[Alive[i]], get_user_health(Alive[i]), IsPaused[Alive[i]] ? "| *Paused* " : "");
					}
				}
				if (IsPaused[Alive[i]])
				{
					client_print(Alive[i], print_center, "%L", Alive[i] , "KZ_ALIVE_ISPAUSE")
				}
			}
			else 
			{
				if( ShowTime[Alive[i]] == 1)	//TXT TIME
				{
					if(HealsOnMap)
					{
						format(output, 127,"[ OFF | %d/%d | HP: Godmode ]", checknumbers[Alive[i]], gochecknumbers[Alive[i]]);
					}
					else{
						format(output, 127,"[ OFF | %d/%d | HP: %d ]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], get_user_health(Alive[i]));
					}
				}
				else if( ShowTime[Alive[i]] == 2) //HUD TIME
				{
					set_hudmessage(12, 122, 221, 0.01, 0.91, 0, 0.0, 0.2, 0.0, 0.0, 3)
	
					if(HealsOnMap)
					{
						show_hudmessage(Alive[i], "[ OFF | %d/%d | HP: Godmode ]",checknumbers[Alive[i]], gochecknumbers[Alive[i]]);
					}
					else
					{
						show_hudmessage(Alive[i], "[ OFF | %d/%d | HP: %d ]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], get_user_health(Alive[i]));
					}
				}
			}
			
			
			message_begin(MSG_ONE, get_user_msgid( "StatusText"), _, Alive[i])
			write_byte( 0 )
			write_string( output )
			message_end( )
		}
		
		for(new i=0;i<deadPlayers;i++)
		{
			new Float:kreedztime, imin, Float:isec 
			new specmode = pev(Dead[i], pev_iuser1)
			if(specmode == 2 || specmode == 4)
			{
				new target = pev(Dead[i], pev_iuser2)
				if(target != Dead[i])
					if(is_user_alive(target) && timer_started[target])
					{
						new name[32];
						get_user_name (target, name, 31)

						kreedztime = get_gametime() - (IsPaused[target] ? get_gametime() - g_pausetime[target] : timer_time[target])
						imin = floatround(kreedztime , floatround_floor)/60
						isec = kreedztime - (60*imin) + 0.02
					
						if( ShowTime[target] == 1)
						{
							if(HealsOnMap) 
							{
								client_print (Dead[i], print_center,"[ %02d:%s%.2f | %d/%d | HP: Godmode %s]", imin,isec < 10 ? "0" : "",isec, checknumbers[target], gochecknumbers[target], /*get_user_health(target),*/ IsPaused[target] ? "| *Paused* " : "")
							}
							else 
							{
								client_print (Dead[i], print_center,"[ %02d:%s%.2f | %d/%d | HP: %d %s]", imin,isec < 10 ? "0" : "",isec, checknumbers[target], gochecknumbers[target], get_user_health(target), IsPaused[target] ? "| *Paused* " : "")
							}
						}
						else if( ShowTime[target] == 2)
						{
							if( IsPaused[target]) 
							{
								set_hudmessage(200, 3, 0, -1.0, 0.2, 0, 0.0, 0.2, 0.0, 0.0, 3)
							} 
							else 
							{
								set_hudmessage(12, 122, 221, -1.0, 0.2, 0, 0.0, 0.2, 0.0, 0.0, 3)
							}
							
							if(HealsOnMap) 
							{
								show_hudmessage(Dead[i],"[ %02d:%s%.2f | %d/%d | HP: Godmode %s]", imin,isec < 10 ? "0" : "",isec, checknumbers[target], gochecknumbers[target], /*get_user_health(target),*/ IsPaused[target] ? "| *Paused* " : "")
							}
							else 
							{
								show_hudmessage(Dead[i], "[ %02d:%s%.2f | %d/%d | HP: %d %s]", imin,isec < 10 ? "0" : "",isec, checknumbers[target], gochecknumbers[target], get_user_health(target), IsPaused[target] ? "| *Paused* " : "")
							}
						}
					}	
			}
		}
	}
}

// ============================ Block Commands ================================


public BlockRadio(id)
{
	if (get_pcvar_num(kz_use_radio) == 1)
		return PLUGIN_CONTINUE
	return PLUGIN_HANDLED
}

public BlockDrop(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if (get_pcvar_num(kz_drop_weapons) == 1)
		return PLUGIN_CONTINUE
	return PLUGIN_HANDLED
}

public BlockBuy(id)
{
	return PLUGIN_HANDLED
}

public CmdRespawn(id)
{
	if ( get_user_team(id) == 3 ) 
		return PLUGIN_HANDLED
	else
		ExecuteHamB(Ham_CS_RoundRespawn, id)

	return PLUGIN_HANDLED
}

public Version(id)
{
	ColorChat(id, GREEN, "%s^1 Server use ProKZ ^3%s ^1, Last Edit ^3%s ^1by ^3Azuki daisuki~.", prefix, VERSION, LAST_EDIT)
}

public ChatHud(id)
{
	if(get_pcvar_num(kz_chatorhud) == 0)
	{
		ColorChat(id, GREEN,  "%s^x01 %L", prefix, id, "KZ_CHATORHUD_OFF")
		return PLUGIN_HANDLED
	}
	if(chatorhud[id] == -1)
		++chatorhud[id];
		
	++chatorhud[id];
	
	if(chatorhud[id] == 3)
		chatorhud[id] = 0;
	else
		kz_chat(id, "%L", id, "KZ_CHATORHUD", chatorhud[id] == 1 ? "Chat" : "HUD")
		
	return PLUGIN_HANDLED
}

public post_player_die(id)
{
	id -= TASK_ID_RESPAWN
	
	if( timer_started[id] )
	{
		// Player haves checkspoints?
		if( checknumbers[id] > 0 )
		{
			// Reset Player Velocity And Then Teleport
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
			set_pev(id, pev_origin, Checkpoints[id][g_bCpAlternate[id]]);
			gochecknumbers[id]++;
		}
		else
		{
			// Reset Player Velocity And Then Teleport
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
			set_pev(id, pev_origin, SavedStart[id])
		}
		// Dont flood the player
		set_task(0.2, "givedieweapons", id + TASK_ID_RESPAWN_WPNS)
	}
	else
	{
		//Give default Weapon
		give_uspknife(id)
		// set_task(0.2, "givedieweapons", id + TASK_ID_RESPAWN_WPNS)

	}

	if( cs_get_user_team(id) == CS_TEAM_T)	//+++ CS_TEAM_T 死亡 respawn 后传送到起点.
	{
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
		set_pev(id, pev_origin, DefaultStartPos)	
	}
}

public post_player_spec(id)
{
	id -= TASK_ID_RESPWAN_SPEC
	
	set_task(0.2, "givedieweapons", id + TASK_ID_RESPAWN_WPNS)
}

public ct(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if ( get_gametime() - antidiestart[id] < 0.5)
	{
		kz_chat(id, "Can't use this command now")
		return PLUGIN_HANDLED	
	}
	if( is_user_alive(id) )
	{
		if((pev(id, pev_movetype) == MOVETYPE_NOCLIP)) 
		{
			kz_chat(id, "%L", id, "KZ_NCMOD_DISABLED") 
			return PLUGIN_HANDLED	
		}
	}
	
	new CsTeams:team = cs_get_user_team(id)
	if (team == CS_TEAM_CT || team == CS_TEAM_T) 
	// if (team == CS_TEAM_CT )
	{
		if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id) && timer_started[id] && !IsPaused[id])
		{
			kz_chat(id, "%L", id, "KZ_GROUND_DISABLED")
			return PLUGIN_HANDLED	
		}

		if (get_pcvar_num(kz_spec_saves) == 1)
		{
			pev(id, pev_origin, SpecLoc[id])

			if ( timer_started[id] )
			{
				if (!IsPaused[id] )
				{					
					g_pausetime[id] =   get_gametime() - timer_time[id]
					timer_time[id] = 0.0
				}
				kz_chat(id, "%L", id, "KZ_PAUSE_ON")
			}
		}
		
		if(gViewInvisible[id]){
			gViewInvisible[id] = false
			WasInvisPlayer[id] = true
		}
		
		spec_user[id] = true
		
		cs_set_user_team(id,CS_TEAM_SPECTATOR)
		set_pev(id, pev_solid, SOLID_NOT)
		set_pev(id, pev_movetype, MOVETYPE_FLY)
		set_pev(id, pev_effects, EF_NODRAW)
		set_pev(id, pev_deadflag, DEAD_DEAD)
	}
	else 
	{
		if(get_user_flags(id) & KZ_ADMIN)
		{
			cs_set_user_team(id,CS_TEAM_T)
		}
		else
		{
			cs_set_user_team(id,CS_TEAM_CT)
		}
		
		set_pev(id, pev_effects, 0)
		set_pev(id, pev_movetype, MOVETYPE_WALK)
		set_pev(id, pev_deadflag, DEAD_NO)
		set_pev(id, pev_takedamage, DAMAGE_AIM)	
		
		if(WasInvisPlayer[id])
		{
			gViewInvisible[id] = true
			WasInvisPlayer[id] = false
		}
		
		CmdRespawn(id)
		spec_user[id] = false

		if (get_pcvar_num(kz_spec_saves) == 1)
		{
			set_pev(id, pev_origin, SpecLoc[id])
			set_pev(id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
			if ( timer_started [id] ) 
			{
				if(!IsPaused[id])
				{
					timer_time[id] = get_gametime() - g_pausetime[id] + timer_time[id]
				}
				else
				{
					timer_time[id] = g_pausetime[id] 
				}
			}
		}	
		set_task(0.2, "post_player_spec", id + TASK_ID_RESPWAN_SPEC)
	}
	return PLUGIN_HANDLED
}


//=================== Weapons ==============
public curweapon(id)
{ 
 	static last_weapon[33];
	static weapon_active, weapon_num
	weapon_active = read_data(1)
	weapon_num = read_data(2)
	
 	if( ( weapon_num != last_weapon[id] ) && weapon_active && get_pcvar_num(kz_maxspeedmsg) == 1)
	{
		last_weapon[id] = weapon_num;
		
		static Float:maxspeed;
		pev(id, pev_maxspeed, maxspeed );

		
		if( maxspeed <= 1.0 )
			maxspeed = 250.0;
		
		kz_hud_message(id,"%L",id, "KZ_WEAPONS_SPEED",floatround( maxspeed, floatround_floor ));
	}
	return PLUGIN_HANDLED
}
 
public weapons(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if(!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(kz_other_weapons) == 0)
	{
		kz_chat(id, "%L", id, "KZ_OTHER_WEAPONS_ZERO")
		return PLUGIN_HANDLED
	}
	
	if (timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN")
		return PLUGIN_HANDLED
	}

	static wpncmdent;
	
	if( is_user_alive(id) )
	{
		if( !timer_started[id])
		{
			for(new i = 0; i < 8; i++)
			{
				if( !user_has_weapon(id, other_weapons[i]) )
				{
					wpncmdent = give_item(id, other_weapons_name[i] );
					cs_set_weapon_ammo(wpncmdent, 10)
				}
			}
			if( !user_has_weapon(id, CSW_USP) )
			cmdUsp(id)
		}
		give_uspknife(id)
	}
	
	ColorChat(id, GREEN, "%s^x01 %L", prefix, id, "KZ_WEAPONS_START")
		
	return PLUGIN_HANDLED
}


// ========================= Scout =======================
public cmdScout(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if (timer_started[id])
	{
		user_has_scout[id] = true
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN")
		return PLUGIN_HANDLED
	}
	
	if (wpn_15[id] && timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN")
		return PLUGIN_HANDLED
	}
	
	strip_user_weapons(id)
	if( !user_has_weapon(id, CSW_SCOUT))
		give_item(id,"weapon_scout")
	
	return PLUGIN_HANDLED
}

public cmdUsp(id)
{	
	if (wpn_15[id] && timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN")
		return PLUGIN_HANDLED
	}
#if defined KZ_DUEL	
	if(kz_player_in_duel(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif
	give_item(id, g_weaponconst[CSW_USP])
	cs_set_user_bpammo(id, CSW_USP, 132)
	give_item(id, g_weaponconst[CSW_KNIFE])
	
	return PLUGIN_HANDLED
}

stock give_uspknife(id, toknife=0)
{	

	if( !user_has_weapon(id, CSW_USP) )
	{ 
		give_item(id, g_weaponconst[CSW_USP] )	
		set_pdata_int(id, 382, 24, OFFSET_LINUX)
	}
		
	if( !user_has_weapon(id, CSW_KNIFE) )
		give_item(id, g_weaponconst[CSW_KNIFE] )
		
	if( toknife == CSW_KNIFE )
	{
		engclient_cmd(id, g_weaponconst[CSW_KNIFE] )
	}
}

public give_scout(id, armita)
{	
	new ent = give_item(id, g_weaponconst[armita]);
	cs_set_weapon_ammo(ent, 2)
}

public givedieweapons(id)
{
	id -= TASK_ID_RESPAWN_WPNS
	
	strip_user_weapons(id);
	
	// User start with proweapons?
	if( !wpn_15[id] )
	{
		give_uspknife(id)
	}
	else
	{
		give_scout(id,  g_numerodearma[id])
	}		
}

// ========================== Start location =================

public goStartPos(id)
{
#if defined KZ_DUEL
	if(kz_player_in_duel(id))
	{
		kz_chat(id, "%L", id, "KZ_DUEL_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	if ( get_gametime() - antidiestart[id] < 0.5) {
		kz_chat(id, "Can't use this command now")
		return PLUGIN_HANDLED	
	}
	if( !is_user_alive( id ) )
	{	
		if (!timer_started[id]) 
		{
			if(get_user_flags(id) & KZ_ADMIN)
			{
				cs_set_user_team(id,CS_TEAM_T)
			}
			else
			{
				cs_set_user_team(id,CS_TEAM_CT)
			}
			
			set_pev(id, pev_effects, 0)
			set_pev(id, pev_movetype, MOVETYPE_WALK)
			set_pev(id, pev_deadflag, DEAD_NO)
			set_pev(id, pev_takedamage, DAMAGE_AIM)
			CmdRespawn(id)
			strip_user_weapons(id)
			cmdUsp(id)
			if(gCheckpointStart[id]) 
			{
				set_pev( id, pev_angles, gCheckpointStartAngle[id]);
				set_pev( id, pev_fixangle, 1);
				
				set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} );
				set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 } );
				set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
				set_pev( id, pev_fuser2, 0.0 );
				engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } );
				set_pev(id, pev_origin, CheckpointStarts[ id ][ !g_bCpAlternateStart[id] ] )
			}

			else {
				if (AutoStart[id])
				{
					set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
					set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
					set_pev(id, pev_origin, SavedStart [id] )
				} 
				else 
				{
					set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
					set_pev(id, pev_origin, DefaultStartPos)
				}
			}
		}
		else 
		{
			ct(id)
		}
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(kz_save_autostart) == 1 && AutoStart [id] )
	{	
		tptostart[id] = true
		if(gCheckpointStart[id]) 
		{
			if (timer_started[id] && !IsPaused[id]) 
			{
				tphook_user[id] = true
				Pause(id)
			}				
			set_pev( id, pev_angles, gCheckpointStartAngle[id]);
			set_pev( id, pev_fixangle, 1);
			
			set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} );
			set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 } );
			set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
			set_pev( id, pev_fuser2, 0.0 );
			engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } );
			set_pev(id, pev_origin, CheckpointStarts[ id ][ !g_bCpAlternateStart[id] ] )

		} 
		else 
		{
			if (timer_started[id] && !IsPaused[id]) 
			{
				tphook_user[id] = true
				Pause(id)
			}				
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
			set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
			set_pev(id, pev_origin, SavedStart [id] )
		}
		return PLUGIN_HANDLED
	}
	else if ( DefaultStart )
	{	
		tptostart[id] = true
		if(gCheckpointStart[id]) {
			if (timer_started[id] && !IsPaused[id]) {
				tphook_user[id] = true
				Pause(id)
			}	
			set_pev( id, pev_angles, gCheckpointStartAngle[id]);
			set_pev( id, pev_fixangle, 1);
			
			set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} );
			set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 } );
			set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
			set_pev( id, pev_fuser2, 0.0 );
			engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } );
			set_pev(id, pev_origin, CheckpointStarts[ id ][ !g_bCpAlternateStart[id] ] )

		} else {
			if (timer_started[id] && !IsPaused[id]) {
				tphook_user[id] = true
				Pause(id)
			}				
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
			set_pev(id, pev_origin, DefaultStartPos)
		}
		return PLUGIN_HANDLED
	}
	else
	{	
		kz_chat(id, "%L", id, "KZ_NO_START")
		CmdRespawn(id)
		
		return PLUGIN_HANDLED
    }

	return PLUGIN_HANDLED
}



public setStart(id)
{
	if (! (get_user_flags( id ) & KZ_LEVEL ))
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS")
		return PLUGIN_HANDLED
	}
    
	new Float:origin[3]
	pev(id, pev_origin, origin)
	kz_set_start(MapName, origin)
	AutoStart[id] = false;
	ColorChat(id, GREEN, "%s^x01 %L.", prefix, id, "KZ_SET_START")
	
	return PLUGIN_HANDLED
}
public setStop(id)
{
	if (! (get_user_flags( id ) & KZ_LEVEL ))
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS")
		return PLUGIN_HANDLED
	}
    
	new Float:origin[3]
	pev(id, pev_origin, origin)
	kz_set_stop(MapName, origin)
	ColorChat(id, GREEN, "%s^x01 Finish position set for this map", prefix)
	
	return PLUGIN_HANDLED
}

public Origin(id)
{
	if (! (get_user_flags( id ) & KZ_LEVEL ))
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS")
		return PLUGIN_HANDLED
	}
    
	new Float:sporigin[3]
	pev(id, pev_origin, sporigin)
	ColorChat(id, GREEN, "%s^x01 %d,%d,%d", prefix, sporigin[0], sporigin[1], sporigin[2])
	
	return PLUGIN_HANDLED
}

// ========= Respawn CT if dies ========

public Ham_CBasePlayer_Killed_Pre(id) 
{
	antidiestart[id] = get_gametime()

}

public Ham_CBasePlayer_Killed_Post(id) 
{
	if( !is_user_alive(id) )
	{
		entity_set_int id, EV_INT_groupinfo, groupNone ;
	}

	if(get_pcvar_num(kz_respawn_ct) == 1)
	{
		if( cs_get_user_team(id) == CS_TEAM_CT || cs_get_user_team(id) == CS_TEAM_T)
		// if( cs_get_user_team(id) == CS_TEAM_CT)
		{
			set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
   			cs_set_user_deaths(id, 0)
			set_user_frags(id, 0) 
			set_task(0.2, "post_player_die", id + TASK_ID_RESPAWN)
		}
	}
}


// =============================  NightVision ================================================

public ToggleNVG(id) 
{
	// client_print(id, print_chat, "kz_nvg is %d, NightVisionUse is %d", get_pcvar_num(kz_nvg), NightVisionUse[id])
	if( get_pcvar_num(kz_nvg) == 0 )
		return PLUGIN_CONTINUE;
   
	if ( NightVisionUse[id] )
		StopNVG(id) 
	else 
		StartNVG(id) 

	return PLUGIN_HANDLED
}

public StartNVG(id) 
{
	if(is_user_alive(id)) 
	{
		emit_sound(id,CHAN_ITEM,"items/nvg_on.wav",1.0,ATTN_NORM,0,PITCH_NORM) 
	}
	else 
	{
		client_cmd(id, "spk items/nvg_on.wav");
	}
	
	// set_task(0.1,"RunNVG",id+111111,_,_,"b") 
	RunNVG(id);
	NightVisionUse[id] = true;

	return PLUGIN_HANDLED
}

public StopNVG(id) 
{
	if(is_user_alive(id)) {
		emit_sound(id,CHAN_ITEM,"items/nvg_off.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	}
	else 
	{
		client_cmd(id, "spk items/nvg_off.wav");
	}
	remove_task(id+111111) 
	NightVisionUse[id] = false;
	
	return PLUGIN_HANDLED
}


// public RunNVG(taskid) 
public RunNVG(id) 
{
	// new id = taskid - 111111
    if(callfunc_begin("clientLightChange","betterLightVision.amxx") == 1) 
	{
		callfunc_push_int(id)
		callfunc_end()
	}
	else {
		client_print(id, print_chat, "betterLightVision.amxx并未加载");
	}							
	// new origin[3] 
	// get_user_origin(id,origin,3)
   
	// new color[17];
	// get_pcvar_string(kz_nvg_colors,color,16);
   
	// new iRed[5], iGreen[7], iBlue[5]
	// parse(color,iRed,4,iGreen ,6,iBlue,4)
   
   	// for(new i = 1; i < max_players; i++ )
	// {
	// 	if( (i == id || is_user_spectating_player(i,id)))
	// 	{
	// 		message_begin(MSG, SVC_TEMPENTITY, _, i)
	// 		write_byte(TE_DLIGHT)
	// 		write_coord(origin[0]) 
	// 		write_coord(origin[1]) 
	// 		write_coord(origin[2]) 
	// 		write_byte(80)
	// 		write_byte(str_to_num(iRed)) 
	// 		write_byte(str_to_num(iGreen)) 
	// 		write_byte(str_to_num(iBlue))
	// 		write_byte(2)
	// 		write_byte(0) 
	// 		message_end()
	// 	}
	// }
}

// ============================ Hook ==============================================================

public Ham_HookTouch(ent, id) 
{
	if(is_user_alive(id) && !is_user(ent) )
	{
		pev(id, pev_origin, g_iHookWallOrigin[id]);
		if(is_user_alive(ent))
		{
			pev(ent, pev_origin, hookorigin[id]);
		}
	}
}

public hook_on(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif
	if( (!canusehook[id] && !(  get_user_flags( id ) & KZ_LEVEL )) || !is_user_alive(id) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	if(get_user_noclip(id))
	{
		set_user_noclip(id,0)
	}
	
	if (!timer_started[id]) 
	{
		antihook(id)
		return PLUGIN_HANDLED
	}
	
	static entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32)
	if (equal(entname, "func_door")&& timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_TIME_START_HOOK")
		return PLUGIN_HANDLED;
	}
	
	if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id) && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_TIME_START_HOOK")
		return PLUGIN_HANDLED
	}
	
	if (timer_started[id] && IsPaused[id])	
	{
		antihook(id)
		return PLUGIN_HANDLED
	}
	if(timer_started[id] && !IsPaused[id])
	{
		Pause(id)
		antihook(id)
		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}

public antihook(id)
{
	get_user_origin(id,hookorigin[id],3)
	
	if (get_pcvar_num(kz_hook_sound) == 1)
	{
		emit_sound(id,CHAN_STATIC,"weapons/xbow_hit2.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	}
	ishooked[id] = true

	set_task(0.1,"hook_task",id,"",0,"ab")
	hook_task(id)
	
	return PLUGIN_CONTINUE
}


public hook_off(id)
{
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif	
	remove_hook(id)
	
	return PLUGIN_HANDLED
}


public hook_task(id)
{
	if(!is_user_alive(id))
	{
		remove_hook(id);
		return;
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
	{
		write_byte(TE_KILLBEAM);
		write_short(id);
	}
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
	{
		write_byte(TE_BEAMENTPOINT);
		write_short(id);
		write_coord(hookorigin[id][0]);			// origin
		write_coord(hookorigin[id][1]);			// origin
		write_coord(hookorigin[id][2]);			// origin
		write_short(Sbeam);				// sprite index
		write_byte(1);						// start frame
		write_byte(1);						// framerate
		write_byte(2);						// life
		write_byte(18);						// width
		write_byte(0);						// noise					
		write_byte(random_num(1,100))		// r
		write_byte(random_num(1,100))		// g
		write_byte(random_num(1,100))		// b
		// write_byte(200);	//r
		// write_byte(200);	//g
		// write_byte(200);	//b
		
		write_byte(200);					// brightness
		write_byte(0);						// speed
	}
	message_end();
		
	static origin[3], Float:velocity[3], distance, i;
	get_user_origin(id, origin);
	distance = get_distance(hookorigin[id], origin);
	
	set_pev(id , pev_gaitsequence , 6);

	antihookcheat[id] = get_gametime()
	
	
	if(distance > 50)
	{
		if(vector_length(Float:g_iHookWallOrigin[id]))
		{
			arrayset(g_iHookWallOrigin[id], 0, sizeof(g_iHookWallOrigin[]));
		}
		for(i = 0; i < 3; i++)
		{
			velocity[i] = (hookorigin[id][i] - origin[i]) * (1.5 * (float(get_pcvar_num(kz_hook_speed))) / distance);
		}
	}
	else if(distance > 10)
	{
		if(vector_length(Float:g_iHookWallOrigin[id]))
		{
			arrayset(g_iHookWallOrigin[id], 0, sizeof(g_iHookWallOrigin[]));
		}
		for(i = 0; i < 3; i++)
		{
			velocity[i] = (hookorigin[id][i] - origin[i]) * (float(get_pcvar_num(kz_hook_speed)/2) / (distance + 20));
		}
	}
	else
	{		
		if(vector_length(Float:g_iHookWallOrigin[id]))
		{
			set_pev(id, pev_origin, g_iHookWallOrigin[id]);
			velocity = Float:{0.0, 0.0, 0.0};
		}
	}
	set_pev(id , pev_velocity, velocity);
}

public remove_hook(id)
{
	if(task_exists(id))
		remove_task(id)
	remove_beam(id)
	ishooked[id] = false
}

public remove_beam(id)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(99) // TE_KILLBEAM
	write_short(id)
	message_end()
}


//============================ VIP In ScoreBoard =================================================

public MessageScoreAttrib( iMsgID, iDest, iReceiver )
{
	if( get_pcvar_num(kz_vip) )
	{
		new iPlayer = get_msg_arg_int(1)
		if( is_user_alive( iPlayer ) && ( get_user_flags( iPlayer ) & KZ_LEVEL ) )
		{
			set_msg_arg_int( 2, ARG_BYTE, SCOREATTRIB_VIP );
		}
	}
}

public detect_cheat(id,reason[])
{ 
	if(timer_started[id]) 
	{
		timer_started[id] = false
		if(IsPaused[id])
		{
			set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)
			IsPaused[id] = false
		}
		
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(65)
		message_end()
		
		ColorChat(id, GREEN,  "%s^x01 %L", prefix, id, "KZ_CHEAT_DETECT", reason)
	}
}
 
// =================================================================================================
// Cmds
// =================================================================================================

public CheckPoint(id)
{
#if defined KZ_DUEL
	if(kz_player_duel_cp(id))
	{
		kz_chat(id, "%L", id, "KZ_CANT_DUEL")
		return PLUGIN_HANDLED
	}
#endif
	
	//  如果玩家继续上一次跳跃 此时没有上一个存点, 通过设置将玩家上一个存点和当前存点均设置为当前位置 
	if(GoPosCp[id] && is_user_alive(id)) {
		pev(id, pev_origin, Checkpoints[id][g_bCpAlternate[id] ? 1 : 0])
		g_bCpAlternate[id] = !g_bCpAlternate[id]
		pev(id, pev_origin, Checkpoints[id][g_bCpAlternate[id] ? 1 : 0])
		g_bCpAlternate[id] = !g_bCpAlternate[id]

		g_MaxCheckPointIndex[id] = 1;
		g_CheckPointIndex[id] = 2;	// 0 1 均为当前位置
		new curPos[CheckPointData];
		pev(id, pev_origin, curPos[flPos]);
		pev(id, pev_v_angle, curPos[flVAngle]);
		ArraySetArray(g_CheckPointArray[id], 0, curPos);
		ArraySetArray(g_CheckPointArray[id], 1, curPos);
		// client_print(id, print_chat, "size is %d", ArraySize(g_CheckPointArray[id]));
		GoPosCp[id] = false
		return PLUGIN_HANDLED
	}
	
	if( !is_user_alive( id ) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(kz_checkpoints) == 0)
	{
		kz_chat(id, "%L", id, "KZ_CHECKPOINT_OFF")
		return PLUGIN_HANDLED
	}

	static entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32)
	if (equal(entname, "func_door") && !SlideMap && !IsOnLadder(id))
	{
		kz_chat(id, "%L", id, "KZ_CBBLOCK_DISABLED")
		return PLUGIN_HANDLED;
	}
	
	// if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id) && !SlideMap)
	// if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id) && timer_started[id] && !IsPaused[id])
	if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id))
	{
		kz_chat(id, "%L", id, "KZ_CHECKPOINT_AIR")
		return PLUGIN_HANDLED
	}
	
	if (gCheckpoint[id]) {
		gLastCheckpointAngle[id][0]=gCheckpointAngle[id][0]
		gLastCheckpointAngle[id][1]=gCheckpointAngle[id][1]
		gLastCheckpointAngle[id][2]=gCheckpointAngle[id][2]
	}
	
	pev(id, pev_v_angle, gCheckpointAngle[id]); 
	new curCheckPoint[CheckPointData];
	pev(id, pev_v_angle, curCheckPoint[flVAngle]);

	gCheckpoint[id]=true;
	
	// 暂停存点 没有保存角度
	if( IsPaused[id] )
	{
		kz_chat(id, "%L", id, "KZ_CHECKPOINT_INPAUSE")
		pev(id, pev_origin, InPauseCheckpoints[id][g_bInPauseCpAlternate[id] ? 1 : 0])
		g_bInPauseCpAlternate[id] = !g_bInPauseCpAlternate[id]
		inpausechecknumbers[id]++
		return PLUGIN_CONTINUE
	}
	
	// pev(id, pev_origin, Checkpoints[id][g_bCpAlternate[id] ? 1 : 0])
	// g_bCpAlternate[id] = !g_bCpAlternate[id];
	checknumbers[id]++;

	pev(id, pev_origin, curCheckPoint[flPos]);
	// client_print(id, print_chat, "g_CheckPointArray[id] size is %d, g_CheckPointIndex[id] is %d", ArraySize(g_CheckPointArray[id]), g_CheckPointIndex[id]);
	ArraySetArray(g_CheckPointArray[id], g_CheckPointIndex[id], curCheckPoint);
	g_MaxCheckPointIndex[id] = max(g_MaxCheckPointIndex[id], g_CheckPointIndex[id]);
	++g_CheckPointIndex[id];
	g_CheckPointIndex[id] %= ArraySize(g_CheckPointArray[id]);
	// server_print("#Saved Check: g_CheckPointIndex[id] is %d", g_CheckPointIndex[id]);
	//kz_chat(id, "%L", id, "KZ_CHECKPOINT", checknumbers[id])

	return PLUGIN_HANDLED

}

// #设置起点
public CheckPointStart(id)
{
	if( !is_user_alive( id ) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}

	if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ON_GROUND")
		return PLUGIN_HANDLED
	}
		
	static entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32)
	if (equal(entname, "func_door") && !SlideMap && !IsOnLadder(id))
	{
		kz_chat(id, "%L", id, "KZ_CBBLOCK_DISABLED")
		return PLUGIN_HANDLED;
	}
	
	if (gCheckpointStart[id]) {
		gLastCheckpointStartAngle[id][0]=gCheckpointStartAngle[id][0]
		gLastCheckpointStartAngle[id][1]=gCheckpointStartAngle[id][1]
		gLastCheckpointStartAngle[id][2]=gCheckpointStartAngle[id][2]
	}
	pev(id, pev_v_angle, gCheckpointStartAngle[id]);
	
	gCheckpointStart[id] = true;	
	
	pev(id, pev_origin, CheckpointStarts[id][g_bCpAlternateStart[id] ? 1 : 0])
	g_bCpAlternateStart[id] = !g_bCpAlternateStart[id]

	kz_chat(id, "%L", id, "KZ_SAVE_START")

	return PLUGIN_HANDLED
}

//# 读点
public GoCheck(id) 
{
	if( !is_user_alive( id ) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	
	if( checknumbers[id] == 0 && inpausechecknumbers[id] == 0) 
	{
		kz_chat(id, "%L", id, "KZ_NOT_ENOUGH_CHECKPOINTS")	
		return PLUGIN_HANDLED
	}
#if defined KZ_DUEL
	if(kz_player_duel_cp(id))
	{
		kz_chat(id, "%L", id, "KZ_CANT_DUEL")
		return PLUGIN_HANDLED
	}
#endif	
	// 读点后用于取消读点 
	pev(id, pev_origin, unDoCheckPoint[id][flPos]);
	pev(id, pev_v_angle, unDoCheckPoint[id][flVAngle]);

	new curCheckPoint[CheckPointData];
	// e.g. 存点存在0 index++后指向 1, 读取时读取0
	new curCheckPointIndex = g_CheckPointIndex[id] - 1;
	if(curCheckPointIndex < 0) curCheckPointIndex = ArraySize(g_CheckPointArray[id]) - 1;
	ArrayGetArray(g_CheckPointArray[id], curCheckPointIndex, curCheckPoint);
	// 设置角度
	if( tpfenabled[id] || gc1[id] )
	{
		// set_pev( id, pev_angles, gCheckpointAngle[id]);
		set_pev( id, pev_angles, curCheckPoint[flVAngle]);
		set_pev( id, pev_fixangle, 1);
	}
	
	// 暂停读点设置坐标
	if( IsPaused[id] && inpausechecknumbers[id] > 0)
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_INPAUSE")	
		set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} );
		set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 } );
		set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
		set_pev( id, pev_fuser2, 0.0 );
		set_pev(id, pev_gravity, 1.0);
		engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } );
		set_pev( id, pev_angles, gCheckpointAngle[id]);
		set_pev(id, pev_origin, InPauseCheckpoints[ id ][ !g_bInPauseCpAlternate[id] ] )
		return PLUGIN_HANDLED
	}

	// 计时读点设置坐标
	set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} );
	set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 } );
	set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING );
	set_pev( id, pev_fuser2, 0.0 );
	set_pev( id, pev_gravity, 1.0);
	engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } );
	// set_pev(id, pev_origin, Checkpoints[ id ][ !g_bCpAlternate[id] ] );

	// server_print("GoCheck: curCheckPointIndex is %d, g_CheckPointIndex[id] is %d", curCheckPointIndex, g_CheckPointIndex[id]);
	set_pev(id, pev_origin, curCheckPoint[flPos]);
	
	if (timer_started[id] && !IsPaused[id])
	{
		if (!WasPlayed[id] && !GoPosed[id]) 
		{
			client_cmd(id, "spk fvox/blip");
			WasPlayed[id] = true
		}
		// gochecknumbers[id]++
	}
	
	gochecknumbers[id]++
	
	return PLUGIN_HANDLED
}

//# 返回上一个读点 目前只能返回一个
public Stuck(id)
{
	if( !is_user_alive( id ) )
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	
	// 暂停时只有两个回点
	if(IsPaused[id] && inpausechecknumbers[id] > 1) {
		set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} )
		set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 })
		set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
		set_pev( id, pev_fuser2, 0.0 )
		engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } )
		set_pev(id, pev_origin, InPauseCheckpoints[id][g_bInPauseCpAlternate[id]] )
		g_bInPauseCpAlternate[id] = !g_bInPauseCpAlternate[id];
		return PLUGIN_HANDLED
	}
	
	if( checknumbers[id] < 2 ) 
	{
		kz_chat(id, "%L", id, "KZ_NOT_ENOUGH_STUCK_CHECKPOINTS")
		return PLUGIN_HANDLED
	}
#if defined KZ_DUEL
	if(kz_player_duel_cp(id))
	{
		kz_chat(id, "%L", id, "KZ_CANT_DUEL")
		return PLUGIN_HANDLED
	}
#endif
	set_pev( id, pev_velocity, Float:{0.0, 0.0, 0.0} )
	set_pev( id, pev_view_ofs, Float:{  0.0,   0.0,  12.0 })
	set_pev( id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
	set_pev( id, pev_fuser2, 0.0 )
	engfunc( EngFunc_SetSize, id, {-16.0, -16.0, -18.0 }, { 16.0, 16.0, 32.0 } )
	// #返回上一个存点

	new lastCheckPoint[CheckPointData];
	new lastCheckPointIndex = g_CheckPointIndex[id] - 2;	// index - 1是最新的存点 index是即将要存的点 index-2是上一个存点
	if(lastCheckPointIndex == -1) lastCheckPointIndex = min( g_MaxCheckPointIndex[id] + 1, ArraySize(g_CheckPointArray[id]) ) - 1;
	else if(lastCheckPointIndex == -2) lastCheckPointIndex = min( g_MaxCheckPointIndex[id] + 1, ArraySize(g_CheckPointArray[id]) ) - 2;
	server_print("Stuck: g_CheckPointIndex[id] is %d, lastCheckPointIndex %d", g_CheckPointIndex[id], lastCheckPointIndex);

	ArrayGetArray(g_CheckPointArray[id], lastCheckPointIndex, lastCheckPoint);

	set_pev(id, pev_origin, lastCheckPoint[flPos] );
	set_pev(id, pev_v_angle, lastCheckPoint[flVAngle]);
	// 读取完后向前移动
	g_CheckPointIndex[id]--;
	if(g_CheckPointIndex[id] < 0) g_CheckPointIndex[id] = min( g_MaxCheckPointIndex[id], ArraySize(g_CheckPointArray[id]) - 1);
	server_print("After Stuck: g_CheckPointIndex[id] is %d", g_CheckPointIndex[id]);
	// set_pev(id, pev_origin, Checkpoints[id][g_bCpAlternate[id]] );
	// g_bCpAlternate[id] = !g_bCpAlternate[id];
	
	if (timer_started[id] && !IsPaused[id])
	{
		if (!WasPlayed[id] && !GoPosed[id])
		{
			client_cmd(id, "spk fvox/blip");
			WasPlayed[id] = true
		}
		gochecknumbers[id]++
	}
	
	//kz_chat(id, "%L", id, "KZ_GOCHECK", gochecknumbers[id])
	
	return PLUGIN_HANDLED;
}
 
// =================================================================================================

// 清除存点数组并初始化相关参数
public reset_checkpoints_array(id) {
	ArrayClear(g_CheckPointArray[id]);
	new maxCheckPointsNum = get_pcvar_num(kz_checkpoints_num);
	// server_print("maxCheckPointsNum is %d", maxCheckPointsNum);
	while(maxCheckPointsNum--) {
		new emptyCheckPoint[CheckPointData];
		ArrayPushArray(g_CheckPointArray[id], emptyCheckPoint);
	}
	g_MaxCheckPointIndex[id] = 0;
	g_CheckPointIndex[id] = 0;
}
public reset_checkpoints(id) 
{
	checknumbers[id] = 0
	gochecknumbers[id] = 0
	inpausechecknumbers[id] = 0
	reset_checkpoints_array(id);

	timer_started[id] = false
	timer_time[id] = 0.0
	user_has_scout[id] = false
	IsPaused[id] = false
	WasPlayed[id] = false
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0x0000)
	write_byte(255)
	write_byte(192)
	write_byte(203)
	write_byte(65)
	message_end()
		
	if(timer_started[id] && IsPaused[id])
	{
		// client_print(id, print_center, "Timer was reset")
	}

	return PLUGIN_HANDLED
}

public reset_checkpoints1(id) 
{
	checknumbers[id] = 0
	gochecknumbers[id] = 0;

	reset_checkpoints_array(id);

	inpausechecknumbers[id] = 0
	timer_started[id] = false
	timer_time[id] = 0.0
	user_has_scout[id] = false
	IsPaused[id] = false
	WasPlayed[id] = false
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0x0000)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()
	return PLUGIN_HANDLED
}

public UndoGoCheck(id) {
	if(!timer_started[id] || !gochecknumbers[id]) return;	//未读点 不做操作
	set_pev(id, pev_origin, unDoCheckPoint[id][flPos] );
	set_pev(id, pev_v_angle, unDoCheckPoint[id][flVAngle]);
	return;
}
//===== Invis =======

public cmdInvisible(id)
{
	if(!is_user_alive(id)) 
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		InvisMenu(id)	
		return PLUGIN_HANDLED
	}
	
	gViewInvisible[id] = !gViewInvisible[id]
	if(gViewInvisible[id])
		kz_chat(id, "%L", id, "KZ_INVISIBLE_PLAYERS_ON")
	else
		kz_chat(id, "%L", id, "KZ_INVISIBLE_PLAYERS_OFF")

	return PLUGIN_HANDLED
}

public cmdWaterInvisible(id)
{	
	if( !gWaterFound )
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_NOWATER")
		InvisMenu(id)
		return PLUGIN_HANDLED
	}
	
	gWaterInvisible[id] = !gWaterInvisible[id]
	if(gWaterInvisible[id])
		kz_chat(id, "%L", id, "KZ_INVISIBLE_WATER_ON")
	else
		kz_chat(id, "%L", id, "KZ_INVISIBLE_WATER_OFF")
	InvisMenu(id)
	return PLUGIN_HANDLED
}

//======================Semiclip / Invis==========================

// host 接收包的玩家[使用屏蔽功能的玩家]
// ent 服务器发送的实体
// https://www.cnblogs.com/crsky/p/6881052.html
public FM_client_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet) 
{ 
	if( player )
	{
		if (get_pcvar_num(kz_semiclip) == 1)
		{
			if ( host != ent && get_orig_retval() && is_user_alive(host) ) 
    		{ 
				set_es(es, ES_Solid, SOLID_NOT);
				// set_es(es, ES_RenderMode, kRenderTransAdd); //设置渲染为亮度逐渐增加?
				set_es(es, ES_RenderMode, 1);	
				set_es(es, ES_RenderAmt, floatround(entity_range(host, ent) * 700.0 / 400, floatround_floor)); // 设置渲染模式为距离越近越透明
				// set_es(es, ES_RenderAmt, get_pcvar_num(kz_semiclip_transparency));
			} 
		}
		if(gMarkedInvisible[ent] && gViewInvisible[host])
		{
 		  	set_es(es, ES_RenderMode, kRenderTransTexture)
			set_es(es, ES_RenderAmt, 0)
			set_es(es, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } )
		}
	}
	else if( gWaterInvisible[host] && gWaterEntity[ent] && !is_user_bot(host) )
	{
		set_es(es, ES_Effects, get_es( es, ES_Effects ) | EF_NODRAW )
	}
	
	return FMRES_IGNORED
} 

public Ham_CBasePlayer_PreThink_Post(id) 
{ 
	if (!is_user_alive(id)) 
	{
		return;
	}
	
	new Target, aux
	get_user_aiming(id, Target, aux)
	
	if (is_user_alive(Target)) 
	{
		new Float:kreedztime = get_gametime() - (IsPaused[Target] ? get_gametime() - g_pausetime[Target] : timer_time[Target])
		new imin = floatround(kreedztime / 60.0,floatround_floor)
		new isec = floatround(kreedztime - imin * 60.0,floatround_floor)
		new ims = floatround( ( kreedztime - ( imin * 60.0 + isec ) ) * 100.0,floatround_floor)
		new name[32], authid[32];
		new uflags = get_user_flags(Target)
		
		get_user_name (Target, name, 31)
		get_user_authid(Target, authid, 31)
	
		set_hudmessage(124, 252, 0, -1.0, -1.0, 0, 0.0, 0.2, 0.0, 0.0)
		if(timer_started[Target]) 
		{ 
			if (is_user_bot(Target))
			{
				show_hudmessage(id, "BOT: %s", name)
			}
			else if (uflags & KZ_LEVEL_VIP)
			{
				show_hudmessage( id, "VIP: %s^n[%02i:%02i:%0i | %d/%d%s]", name, imin, isec,ims, checknumbers[Target], gochecknumbers[Target], IsPaused[Target] ? "| *Paused*" : "")
			}
			else if (uflags & KZ_ADMIN)
			{
				show_hudmessage( id, "ADMIN: %s^n[%02i:%02i:%02i | %d/%d%s]", name, imin, isec,ims, checknumbers[Target], gochecknumbers[Target], IsPaused[Target] ? "| *Paused*" : "")
			}
			else 
			{
				show_hudmessage( id, "%s^n[%02i:%02i:%02i | %d/%d%s]", name, imin, isec,ims, checknumbers[Target], gochecknumbers[Target], IsPaused[Target] ? "| *Paused*" : "")
			}
		}
		else
		{
			if (is_user_bot(Target))
			{
				show_hudmessage(id, "BOT: %s", name)
			}
			else if (uflags & KZ_LEVEL_VIP)
			{
				show_hudmessage( id, "VIP: %s^n[OFF | %d/%d]", name, checknumbers[Target], gochecknumbers[Target])
			}
			else if (uflags & KZ_ADMIN)
			{
				show_hudmessage( id, "ADMIN: %s^n[OFF | %d/%d]", name, checknumbers[Target], gochecknumbers[Target])
			}
			else
			{
				show_hudmessage( id, "%s^n[OFF | %d/%d]", name,checknumbers[Target], gochecknumbers[Target])
			}
		}
	}

	RefreshPlayersList() 

	// 设置玩家是否可以相互传过 solid
	if (get_pcvar_num(kz_semiclip) == 1)
	{
		for(new i = 0; i<g_iNum; i++) 
		{ 
			g_iPlayer = g_iPlayers[i] 
			if( id != g_iPlayer ) 
			{ 
				set_pev(g_iPlayer, pev_solid, SOLID_NOT) 
			} 
		} 
	}
} 

public plugin_end()
{
	TrieDestroy(g_tSounds);
}

public client_PostThink(id) 
{ 
	if( !is_user_alive(id) ) 
		return

	RefreshPlayersList() 

	if (get_pcvar_num(kz_semiclip) == 1)
	{
		for(new i = 0; i<g_iNum; i++) 
   		{ 
			g_iPlayer = g_iPlayers[i] 
			if( g_iPlayer != id ) 
			{
				set_pev(g_iPlayer, pev_solid, SOLID_SLIDEBOX) 
			}
   		} 
	}
} 


public FM_PlayerEmitSound(id, channel, const sound[]) 
{
	if(TrieKeyExists(g_tSounds, sound)) 
	{
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public noclip(id)
{
	new noclip = !get_user_noclip(id)
	
	static entname[33];
	pev(pev(id, pev_groundentity), pev_classname, entname, 32)
	if (equal(entname, "func_door") && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_NBBLOCK_DISABLED")
		return PLUGIN_HANDLED;
	}
	
#if defined KZ_DUEL
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif
	
	if(!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}
	
	if( !( pev( id, pev_flags ) & FL_ONGROUND2 ) && !IsOnLadder(id) && timer_started[id] && !IsPaused[id])
	{
		return PLUGIN_HANDLED
	}
	

	set_user_noclip(id, noclip)
	
	if(!IsPaused[id] && noclip && timer_started[id])
	{
		Pause(id)
	}
	
	if(IsPaused[id] && (get_pcvar_num(kz_noclip_pause) == 1))
	{
		if(noclip)
		{
			tphook_user[id] = true
		}
		else
		{
			set_pev(id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
		}
	} 
	
	kz_chat(id, "%L", id, "KZ_NOCLIP" , noclip ? "ON" : "OFF")
	antinoclipstart[id] = get_gametime();
	
	return PLUGIN_HANDLED
}

public GodMode(id)
{
	if(!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE")
		return PLUGIN_HANDLED
	}	
#if defined KZ_DUEL	
	if(kz_player_can_hook(id))
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_DISABLED")
		return PLUGIN_HANDLED
	}
#endif
	if(timer_started[id])	
	{
		kz_chat(id, "%L", id, "KZ_INSTARTTIME")
		return PLUGIN_HANDLED
	}
	
	new godmode = !get_user_godmode(id)
	set_user_godmode(id, godmode)
	set_user_noclip(id, false)
	
	kz_chat(id, "%L", id, "KZ_GODMODE" , godmode ? "ON" : "OFF")
	
	return PLUGIN_HANDLED
}
 
// =================================================================================================
stock kz_set_start(const map[], Float:origin[3])
{
	new realfile[128], tempfile[128], formatorigin[50]
	formatex(realfile, 127, "%s/%s", Kzdir, KZ_STARTFILE)
	formatex(tempfile, 127, "%s/%s", Kzdir, KZ_STARTFILE_TEMP)
	formatex(formatorigin, 49, "%f %f %f", origin[0], origin[1], origin[2])
	
	DefaultStartPos = origin
	DefaultStart = true
	
	new file = fopen(tempfile, "wt")
	new vault = fopen(realfile, "rt")
	
	new data[128], key[64]
	new bool:replaced = false
	
	while( !feof(vault) )
	{
		fgets(vault, data, 127)
		parse(data, key, 63)
		
		if( equal(key, map) && !replaced )
		{
			fprintf(file, "%s %s^n", map, formatorigin)
			
			replaced = true
		}
		else
		{
			fputs(file, data)
		}
	}
	
	if( !replaced )
	{
		fprintf(file, "%s %s^n", map, formatorigin)
	}
	
	fclose(file)
	fclose(vault)
	
	delete_file(realfile)
	while( !rename_file(tempfile, realfile, 1) ) {}
}

stock kz_set_stop(const map[], Float:origin[3])
{
	new realfile[128], tempfile[128], formatorigin[50]
	formatex(realfile, 127, "%s/%s", Kzdir, KZ_FINISHFILE)
	formatex(tempfile, 127, "%s/%s", Kzdir, KZ_FINISHFILE_TEMP)
	formatex(formatorigin, 49, "%f %f %f", origin[0], origin[1], origin[2])
	
	DefaultStopPos = origin
	DefaultStop = true
	
	new file = fopen(tempfile, "wt")
	new vault = fopen(realfile, "rt")
	
	new data[128], key[64]
	new bool:replaced = false
	
	while( !feof(vault) )
	{
		fgets(vault, data, 127)
		parse(data, key, 63)
		
		if( equal(key, map) && !replaced )
		{
			fprintf(file, "%s %s^n", map, formatorigin)
			
			replaced = true
		}
		else
		{
			fputs(file, data)
		}
	}
	
	if( !replaced )
	{
		fprintf(file, "%s %s^n", map, formatorigin)
	}
	
	fclose(file)
	fclose(vault)
	
	delete_file(realfile)
	while( !rename_file(tempfile, realfile, 1) ) {}
}

stock ReadMaps()
{
	get_localinfo("amxx_datadir", g_szDir, sizeof(g_szDir) - 1);
	format(g_szDir, sizeof(g_szDir) - 1,"%s/%s", g_szDir, g_szDirFile);
	
	if(!dir_exists(g_szDir))
		mkdir(g_szDir);
	
	new szFile[128];
	format(szFile, sizeof(szFile) - 1, "%s/%s", g_szDir, g_szAxnMapFile);
	
	if(!file_exists(szFile)) 
	{
		new hFile = fopen(szFile, "wt");
		fputs(hFile, ";bbs.simen.com^n^n");
		fclose(hFile);	
	}
	
	new szMapName[32];
	get_mapname(szMapName, sizeof(szMapName) - 1);
	
	new hFile = fopen(szFile, "r");
	new szData[512];
	while(!feof(hFile)) 
	{
		fgets(hFile, szData, sizeof(szData) - 1);
		trim(szData);
		
		if(!szData[0] || szData[0] == '^n' || szData[0] == ';') 
		{
			continue;
		}
		
		if(equali(szData, szMapName))
		{
			return 1;
		}
	}
	fclose(hFile);
	return 0;
}

stock kz_chat(id, const message[], {Float,Sql,Result,_}:...)
{
	new cvar = get_pcvar_num(kz_chatorhud)
	if(cvar == 0)
		return PLUGIN_HANDLED
		
	new msg[200], final[198]
	if (cvar == 1 && chatorhud[id] == -1 || chatorhud[id] == 1)
	{
		vformat(msg, 199, message, 3)
		formatex(final, 197, "%s^x01 %s", prefix, msg)
		kz_remplace_colors(final, 191)
		ColorChat(id, GREEN, "%s", final)
	}
	else if( cvar ==  2 && chatorhud[id] == -1 || chatorhud[id] == 2)
	{
			vformat(msg, 199, message, 3)
			replace_all(msg, 197, "^x01", "")
			replace_all(msg, 197, "^x03", "")
			replace_all(msg, 197, "^x04", "")
			replace_all(msg, 197, ".", "")
			kz_hud_message(id, "%s", msg)
	}
	
	return 1
}

stock kz_print_config(id, const msg[])
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, id);
	write_byte(id);
	write_string(msg);
	message_end();
}

stock kz_remplace_colors(message[], len)
{
	replace_all(message, len, "!g", "^x04")
	replace_all(message, len, "!t", "^x03")
	replace_all(message, len, "!y", "^x01")
}

stock kz_hud_message(id, const message[], {Float,Sql,Result,_}:...)
{
	static msg[192], colors[12], r[4], g[4], b[4];
	vformat(msg, 191, message, 3);
	
	get_pcvar_string(kz_hud_color, colors, 11)
	parse(colors, r, 3, g, 3, b, 4)
	
	set_hudmessage(str_to_num(r), str_to_num(g), str_to_num(b), -1.0, 0.90, 2, 1.0, 2.5, 0.01, 0.2, -1);
	ShowSyncHudMsg(id, hud_message, msg);
}

stock kz_register_saycmd(const saycommand[], const function[], flags) 
{
	new temp[64]
	formatex(temp, 63, "say /%s", saycommand)
	register_clcmd(temp, function, flags)
	formatex(temp, 63, "say .%s", saycommand)
	register_clcmd(temp, function, flags)
	formatex(temp, 63, "say_team /%s", saycommand)
	register_clcmd(temp, function, flags)
	formatex(temp, 63, "say_team .%s", saycommand)
	register_clcmd(temp, function, flags)
}
/*
stock get_configsdir(name[],len)
{
	return get_localinfo("amxx_configsdir",name,len);
}*/

#if defined USE_SQL
stock GetNewRank(id, type)
{
	new createinto[1001]
	
	new cData[2]
	cData[0] = id
	cData[1] = type
	
	formatex(createinto, 1000, "SELECT authid FROM `%s` WHERE mapname='%s' ORDER BY time LIMIT 15", type == PRO_TOP ? "kz_pro15" : "kz_nub15", MapName)
	SQL_ThreadQuery(g_SqlTuple, "GetNewRank_QueryHandler", createinto, cData, 2)
}

stock kz_update_plrname(id)
{
	new createinto[1001], authid[32], name[32]
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	
	replace_all(name, 31, "\", "")
	replace_all(name, 31, "`", "")
	replace_all(name, 31, "'", "")

	if(equal(authid, "VALVE_ID_LAN") || equal(authid, "STEAM_ID_LAN") || strlen(authid) > 18)
		return 0;
	else
	{
		formatex(createinto, 1000, "UPDATE `kz_pro15` SET name='%s' WHERE authid='%s'", name, authid)
		SQL_ThreadQuery(g_SqlTuple, "QueryHandle", createinto)
		formatex(createinto, 1000, "UPDATE `kz_nub15` SET name='%s' WHERE authid='%s'", name, authid)
		SQL_ThreadQuery(g_SqlTuple, "QueryHandle", createinto)
	}
	return 1
}
#endif

public FwdSpawnWeaponbox( iEntity )
{
	if(get_pcvar_num(kz_remove_drops) == 1)
	{
		set_pev( iEntity, pev_flags, FL_KILLME )
		dllfunc( DLLFunc_Think, iEntity )
	}
	
	return HAM_IGNORED
}

public FwdHamDoorSpawn( iEntity )
{
	static const szNull[ ] = "common/null.wav";
	
	new Float:flDamage;
	pev( iEntity, pev_dmg, flDamage );
	
	if( flDamage < -999.0 ) {
		set_pev( iEntity, pev_noise1, szNull );
		set_pev( iEntity, pev_noise2, szNull );
		set_pev( iEntity, pev_noise3, szNull );
		
		if( !HealsOnMap )
			HealsOnMap = true
	}
}


public eventHamPlayerDamage(id, weapon, attacker, Float:damage, damagebits) 
{
	
	if (get_pcvar_num(kz_damage) == 1)
	{
		if(!is_user(id) || attacker || weapon) 
		{
			damage = 0.0
			return HAM_SUPERCEDE
		}
		return HAM_IGNORED
	}
	
	for(new i = 1; i < max_players; i++ )
	{
		if( (i == id || is_user_spectating_player(i,id)))
		{
			ClearDHUDMessages(i);
			if(!weapon && !HealsOnMap) {
				set_dhudmessage(255, 80, 80, -1.0, 0.83, 0, 0.0, 0.0, 0.0, 2.0)
				show_dhudmessage(i, "%s%d HP", damage > 0 ? "" : "+", floatround(damage * -1))
			}
		}
	}
	set_task(0.5, "tsk_heal", id)
	return HAM_IGNORED
}

public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tr, damage_type)
{
	if (is_user_alive(attacker) && is_user_alive(victim) && get_pcvar_num(kz_damage) == 1) 
    {
		return HAM_SUPERCEDE
    }
	return HAM_IGNORED
}


stock ClearDHUDMessages(pId, iClear = 8) {
	for(new i = 1; i < max_players; i++ )    
	{
		if( (i == pId || is_user_spectating_player(i,pId)))
		{
			for (new iDHUD = 0; iDHUD < iClear; iDHUD++) {
				show_dhudmessage(pId, "");
			}
		}
	}
}

stock is_user_spectating_player(spectator, player)
{
	if( !pev_valid(spectator) || !pev_valid(player) )
		return 0;
	if( !is_user_connected(spectator) || !is_user_connected(player) )
		return 0;
	if( is_user_alive(spectator) || !is_user_alive(player) )
		return 0;
	if( pev(spectator, pev_deadflag) != 2 )
		return 0;
	
	static specmode;
	specmode = pev(spectator, pev_iuser1);  
	if( !(specmode == 1 || specmode == 2 || specmode == 4) )
		return 0;
	
	if( pev(spectator, pev_iuser2) == player )
		return 1;
	
	return 0;
}

public tsk_heal(id)
{
	if(HealsOnMap) {
		set_pev(id, pev_health, 1999983.0);
	}
	return HAM_IGNORED
}

public FwdHamPlayerSpawn(id)
{
	
	if(get_pcvar_num(kz_autosavepos) == 0)
		Autosavepos[id]=false
	else 
		Autosavepos[id]=true
	
	if (!is_user_alive(id))
		return;
	
	// if(firstspawn[id] && !is_user_bot(id) && is_user_alive(id) && is_user_connected(id))
	// #MARK 首次进入重生 选择是否加载上一次的进度
	if(firstspawn[id] && !is_user_bot(id))
	{
		
		for (new i = 0 ; i < num; ++i)
		{
			new imin = floatround(Pro_Times[i] / 60.0, floatround_floor)
			new isec = floatround(Pro_Times[i]  - imin * 60.0,floatround_floor)
			// new ims = floatround((Pro_Times[i] - ( imin * 60.0 + isec )) * 100.0, floatround_floor)

				
			new iminz = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
			new isecz = floatround(Noob_Tiempos[i]  - iminz * 60.0,floatround_floor) 
			// new imsz = floatround((Noob_Tiempos[i] - ( iminz * 60.0 + isecz )) * 100.0, floatround_floor)

			
			new iminw = floatround(Wpn_Timepos[i] / 60.0, floatround_floor)
			new isecw = floatround(Wpn_Timepos[i]  - iminw * 60.0,floatround_floor)
			// new imsw = floatround((Wpn_Timepos[i] - ( iminw * 60.0 + isecw )) * 100.0, floatround_floor)

			new authid[32]
			get_user_authid(id, authid, 31)
			
			if(equal(Pro_AuthIDS[i], authid) || equal(Noob_AuthIDS[i], authid))
			{
				if(Pro_Times[i] < Noob_Tiempos[i])
				{
					set_user_frags(id, imin)
					cs_set_user_deaths(id, isec)
				}
				
				if(Pro_Times[i] > Noob_Tiempos[i])
				{
					set_user_frags(id, iminz)
					cs_set_user_deaths(id, isecz)
				}
			}
			else if (equal(Wpn_AuthIDS[i], authid))
			{
				set_user_frags(id, iminw)
				cs_set_user_deaths(id, isecw)
			}
		}
		
		if (user_has_weapon(id, CSW_KNIFE))
		{
			engclient_cmd(id, "weapon_knife")
		}
		
		if(Verif(id,1) && get_pcvar_num(kz_save_pos) == 1 )
		{
			Savepos_menu(id) // 继续上一次
		}
		else if(get_pcvar_num(kz_spawn_mainmenu) == 1)
		{
			kz_menu (id) // 重新
		}
		
		cs_set_user_money(id, 1336)
		
		set_task(1.0,"CmdSayWR",id)
		// set_task(8.5,"CmdSayCR",id)

		if (DefaultStart) 
		{
			set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})
			set_pev(id, pev_origin, DefaultStartPos)	
		}
		
		if(get_pcvar_num(kz_checkpoints) == 0)
		{
			ColorChat(id, GREEN,  "%s^x01 %L", id, "KZ_CHECKPOINT_OFF", prefix)
		}

		if(GodMap)
		{
			GodMode(id)
		}
		
		if(get_user_flags(id) & KZ_ADMIN)
		{
			set_task(0.2, "AdminTeam",id + TASK_ADMINTEAM)
		}
	}
	firstspawn[id] = false

	
	if ( (containi(MapName, "slide") != -1) || (containi(MapName, "surf_") != -1) ) 
	{
		HealsOnMap = true
		SlideMap = true
	}
	
	if( HealsOnMap )
		set_user_health(id, 1999983)
		
	if( IsPaused[id] )
	{
		set_pev(id, pev_origin, PauseOrigin[id])
	}
	
	if(get_pcvar_num(kz_use_radio) == 0)
	{
		#define XO_PLAYER				5
		#define	m_iRadiosLeft			192
		set_pdata_int(id, m_iRadiosLeft, 0, XO_PLAYER)
	}
}

public AdminTeam(id)
{
	id -= TASK_ADMINTEAM
	cs_set_user_team(id, CS_TEAM_T)
}

public GroundWeapon_Touch(iWeapon, id)
{
	if (( is_user_alive(id) && timer_started[id] && get_pcvar_num(kz_pick_weapons) == 0 ) )
		return HAM_SUPERCEDE

	return HAM_IGNORED
}
 
 
 
// ==================================Save positions=================================================
// 上次跳跃的存档
public GoPos(id)
{
	remove_hook(id)
	set_user_noclip(id, 0)
	
	if(Verif(id,0))
	{
		set_pev(id, pev_velocity, SavedVelocity[id])
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_DUCKING )
		set_pev(id, pev_origin, SavedOrigins[id] )
		GoPosCp[id] = true
		GoPosHp[id] = true
		CheckPoint(id)
	}

	if( HealsOnMap || SlideMap) 
	{
		set_user_health(id, 1999983)
	}
	
	checknumbers[id]=SavedChecks[id]
	gochecknumbers[id]=SavedGoChecks[id]
	cs_set_user_money(id,get_pcvar_num(kz_startmoney))

	if (gochecknumbers[id] > 0) 
	{
		GoPosed[id] = true
	}

	//加载进度给武器
	strip_user_weapons(id)
	
	if(SavedWeapon[id] == 0)
	{
		cmdUsp(id)
	}	
	if(SavedWeapon[id] == 1)
	{
		give_item(id, "weapon_scout")
	}

	if(SavedWeapon[id] == 2)
	{
		give_item(id, "weapon_p90")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 3)
	{
		give_item(id, "weapon_famas")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 4)
	{
		give_item(id, "weapon_sg552")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 5)
	{
		give_item(id, "weapon_m4a1")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 6)
	{
		give_item(id, "weapon_m249")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 7)
	{
		give_item(id, "weapon_ak47")
		wpn_15[id] = true
	}	
	if(SavedWeapon[id] == 8)
	{
		give_item(id, "weapon_awp")
		wpn_15[id] = true
	}	
	
	timer_time[id]=get_gametime()-SavedTime[id]
	timer_started[id]=true

	ColorChat(id, GREEN,  "[KZ] ^x03%L",id ,"KZ_GOPOSINFO")
}


// 读取文件 获取每个玩家的存档[存点数 计时 位置]
public Verif(id, action)
{
	new realfile[128], tempfile[128], authid[32], map[64]
	new bool:exist = false
	get_mapname(map, 63)
	get_user_authid(id, authid, 31)
	formatex(realfile, 127, "%s/%s.ini", SavePosDir, map)
	formatex(tempfile, 127, "%s/temp.ini", SavePosDir)
	
	if( !file_exists(realfile) )
		return 0

	new file = fopen(tempfile, "wt")
	new vault = fopen(realfile, "rt")
	new data[256], sid[32], time[25], checks[5], gochecks[5], x[25], y[25], z[25], weapon[5], xs[25], ys[25], zs[25]
	while( !feof(vault) )
	{
		fgets(vault, data, 255)
		parse(data, sid, 31, time, 24,  checks, 4, gochecks, 4, x, 24,  y, 24, z, 24, weapon, 4, xs, 24,  ys, 24, zs, 24)
		
		if( equal(sid, authid) && !exist) // ma aflu in fisier?
		{
			if(action == 1)
				fputs(file, data)
			exist= true 
			SavedChecks[id] = str_to_num(checks)
			SavedGoChecks[id] = str_to_num(gochecks)
			SavedTime[id] = str_to_float(time)
			SavedOrigins[id][0]=str_to_num(x)
			SavedOrigins[id][1]=str_to_num(y)
			SavedOrigins[id][2]=str_to_num(z)
			SavedWeapon[id] = str_to_num(weapon)
			SavedVelocity[id][0]=str_to_num(xs)
			SavedVelocity[id][1]=str_to_num(ys)
			SavedVelocity[id][2]=str_to_num(zs)
		}
		else
		{
			fputs(file, data) 
		}
	}

	fclose(file)
	fclose(vault)
	
	delete_file(realfile)
	if(file_size(tempfile) == 0)
		delete_file(tempfile)
	else	
		while( !rename_file(tempfile, realfile, 1) ) {}
	
	
	if(!exist)
		return 0
	
	return 1
}
public kz_savepos (id, Float:time, checkpoints, gochecks, Float:origin[3], weapon, Float:spvelocity[3])
{
	new realfile[128], formatorigin[128], map[64], authid[32]
	get_mapname(map, 63)
	get_user_authid(id, authid, 31)
	formatex(realfile, 127, "%s/%s.ini", SavePosDir, map)
	formatex(formatorigin, 127, "%s %f %d %d %d %d %d %d %d %d %d", authid, time, checkpoints, gochecks, origin[0], origin[1], origin[2], weapon, spvelocity[0], spvelocity[1], spvelocity[2])
	
	new vault = fopen(realfile, "rt+")
	write_file(realfile, formatorigin) // La sfarsit adaug datele mele
	
	fclose(vault)
	
}


// 玩家断开连接时存档
public saveposition(id) 
{
	new Float:origin[3], weapon
	new Float:spvelocity[3]
	pev(id, pev_velocity, spvelocity);
	new Float:Time,check,gocheck 
	
	if(spec_user[id] && IsPaused[id]) 
	{
		SpecLoc[id] = PauseOrigin[id]
	}


	if(timer_started[id] && is_user_alive(id) && !is_user_bot(id) && tphook_user[id])
	{
		origin = PauseOrigin[id]
		Time= g_pausetime[id]
		spvelocity = pausedvelocity[id]
		
		if(isFalling[id]) 
		{
			origin = vFallingStart[id];
			Time = vFallingTime[id]
		}

		check=checknumbers[id]
		gocheck=gochecknumbers[id]
		
		//判断使用武器保存
		
		if (user_has_weapon(id, CSW_SCOUT))
			weapon= 1
		else if (user_has_weapon(id, CSW_P90))
			weapon= 2
		else if (user_has_weapon(id, CSW_FAMAS))
			weapon= 3 
		else if (user_has_weapon(id, CSW_SG552))
			weapon= 4
		else if (user_has_weapon(id, CSW_M4A1))
			weapon= 5
		else if (user_has_weapon(id, CSW_M249))
			weapon= 6
		else if (user_has_weapon(id, CSW_AK47))
			weapon= 7
		else if (user_has_weapon(id, CSW_AWP))
			weapon= 8
		else if (user_has_weapon(id, CSW_USP) || user_has_weapon(id, CSW_KNIFE))
			weapon= 0
		
		// if (gochecknumbers[id] > 0)
		// {
			// origin = Checkpoints[id][!g_bCpAlternate[id]]

		// }
		kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity)
	}		
	else if(timer_started[id] && !is_user_alive(id) && !is_user_bot(id) && spec_user[id])
	{
		origin = SpecLoc[id]
		Time= g_pausetime[id]
		check=checknumbers[id]
		gocheck=gochecknumbers[id]
		
		if (user_has_weapon(id, CSW_SCOUT))
			weapon= 1
		else if (user_has_weapon(id, CSW_P90))
			weapon= 2
		else if (user_has_weapon(id, CSW_FAMAS))
			weapon= 3
		else if (user_has_weapon(id, CSW_SG552))
			weapon= 4
		else if (user_has_weapon(id, CSW_M4A1))
			weapon= 5
		else if (user_has_weapon(id, CSW_M249))
			weapon= 6
		else if (user_has_weapon(id, CSW_AK47))
			weapon= 7
		else if (user_has_weapon(id, CSW_AWP))
			weapon= 8
		else if (user_has_weapon(id, CSW_USP) || user_has_weapon(id, CSW_KNIFE))
			weapon= 0
		// if (gochecknumbers[id] > 0)
		// {
			// origin = Checkpoints[id][!g_bCpAlternate[id]]

		// }

		kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity)

	}	
	else if(timer_started[id] && is_user_alive(id) && !is_user_bot(id))
	{
		pev(id, pev_origin, origin)
		Time=get_gametime() - timer_time[id]
		if(isFalling[id]) 
		{
			origin = vFallingStart[id];
			Time = vFallingTime[id]
			spvelocity[0] = 0.0
			spvelocity[1] = 0.0
			spvelocity[2] = 0.0
		}
		
		check=checknumbers[id]
		gocheck=gochecknumbers[id]
		
		if (user_has_weapon(id, CSW_SCOUT))
			weapon= 1
		else if (user_has_weapon(id, CSW_P90))
			weapon= 2
		else if (user_has_weapon(id, CSW_FAMAS))
			weapon= 3
		else if (user_has_weapon(id, CSW_SG552))
			weapon= 4
		else if (user_has_weapon(id, CSW_M4A1))
			weapon= 5
		else if (user_has_weapon(id, CSW_M249))
			weapon= 6
		else if (user_has_weapon(id, CSW_AK47))
			weapon= 7
		else if (user_has_weapon(id, CSW_AWP))
			weapon= 8
		else if (user_has_weapon(id, CSW_USP) || user_has_weapon(id, CSW_KNIFE))
			weapon= 0

		// if (gochecknumbers[id] > 0)
		// {
			// origin = Checkpoints[id][!g_bCpAlternate[id]]
		// }	
		kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity)
	}
	else
	{
		checknumbers[id] = 0
		gochecknumbers[id] = 0
		user_has_scout[id] = false;

		reset_checkpoints_array(id);
	}
}


// =================================================================================================
// Events / Forwards
// =================================================================================================

public client_disconnect(id)
{
	if (Autosavepos[id] && !is_user_bot(id)) 
	{
		saveposition(id)
	}

	if(task_exists(id))
		remove_task(id)
	
	if(task_exists(id + TASK_ADMINTEAM))
		remove_task(id + TASK_ADMINTEAM )	
	if(task_exists(id + TASK_HELPINFO))
		remove_task(id + TASK_HELPINFO )	

	
	checknumbers[id] = 0
	gochecknumbers[id] = 0;

	reset_checkpoints_array(id);

	antihookcheat[id] = 0.0
	antinoclipstart[id] = 0.0
	antiteleport[id] = 0.0		//+
	antidiestart[id] = 0.0
	chatorhud[id] = -1
	timer_started[id] = false
	ShowTime[id] = get_pcvar_num(kz_show_timer)
	kz_type_wr[id] = get_pcvar_num(kz_type_wr_num)
	firstspawn[id] = true
	NightVisionUse[id] = false
	IsPaused[id] = false
	gCheckpointStart[id] = false
	spec_user[id] = false
	tpfenabled[id] = false
	tphook_user[id] = false
	GoPosed[id] = false
	GoPosCp[id] = false
	GoPosHp[id] = false
	gc1[id] = true;
	user_has_scout[id] = false
	remove_hook(id)
	tptostart[id] = false
	isFalling[id] = false
	isMpbhop[id] = false
	#if defined KZ_AUTO_JOIN_CT
	{
		block_change[id] = false	
	}
	#endif
	if (get_user_flags(id) & KZ_LEVEL)
		g_bHideMe[id] = true;
	else
		g_bHideMe[id] = false;
	
	if (is_user_connected(id))
	{
		ArrayClear(g_DemoReplay[id]);
		ArrayClear(gc_DemoReplay[id]);
	}
	p_lang[id] = true;
	return 0;
}
 
public client_putinserver(id)
{
	checknumbers[id] = 0
	inpausechecknumbers[id] = 0
	gochecknumbers[id] = 0

	reset_checkpoints_array(id);

	antihookcheat[id] = 0.0
	antinoclipstart[id] = 0.0
	antiteleport[id] = 0.0	//+
	antidiestart[id] = 0.0
 	chatorhud[id] = get_pcvar_num(kz_chatorhud)
	timer_started[id] = false
	ShowTime[id] = get_pcvar_num(kz_show_timer)
	kz_type_wr[id] = get_pcvar_num(kz_type_wr_num)
	firstspawn[id] = true
	NightVisionUse[id] = false
	IsPaused[id] = false
	user_has_scout[id] = false
	remove_hook(id)
	canusehook[id] = true
	GoPosed[id] = false
	GoPosCp[id] = false
	GoPosHp[id] = false
	gc1[id] = true;
	tptostart[id] = false
	tphook_user[id] = false
	spec_user[id] = false
	tpfenabled[id] = false
	wpn_15[id] = false
	g_playergiveweapon[id] = true
	g_numerodearma[id] = CSW_USP
	isMpbhop[id] = false
	set_task(2.1,"ServerInfo_Console",id)
	arrayset(g_iHookWallOrigin[id], 0, sizeof(g_iHookWallOrigin[]));
	
	#if defined KZ_AUTO_JOIN_CT
	{
		block_change[id] = false
	}
	#endif
	
	g_bHideMe[id] = false;
	// ===================#MARK==================
	REC_AC[id] = false;
	p_lang[id] = true;
	if (is_user_bot(id))
	{
		g_bitBots = (1 << id & 31 | g_bitBots);
	}
	else
	{
		g_bitBots = (~1 << id & 31 & g_bitBots);
	}
	set_task(0.5, "plspawn", id)
	set_task(0.1, "UpdateStats", id)

	client_cmd(id, "fps_max 99.5");	//进服设置fps上限.
}

public client_connect(id) 
{
	client_cmd(id, "setinfo lang cn");	//服务器首选语言为英文 setinfo lang cn为中文.
}

public SteamUserInfo(id) 
{
	id -= TASK_HELPINFO
	client_print(id, print_chat, "%Steam user help guide say '/help'");
	client_print(id, print_console, "Steam user help guide say '/help'");
}

public plspawn(id)
{
	if (!is_user_alive(id))
		cs_user_spawn(id)
}

public event_deathmsg()
{
    set_task(get_pcvar_float(cvar_respawndelay), "respawn_player", read_data(2))
}

public respawn_player(id)
{

    if (!is_user_connected(id) || is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR)
        return;
    
   
    set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
    dllfunc(DLLFunc_Think, id)

    if (is_user_bot(id) && pev(id, pev_deadflag) == DEAD_RESPAWNABLE)
    {
        dllfunc(DLLFunc_Spawn, id)
    }
}

public UpdateStats(id)
{
	if(is_user_bot(id)) return 0;
	new authid[32], name[32]
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	client_cmd(id, "hud_centerid 0")
	for(new i = 0; i < num; i++)
	{
		
		if( (!equali(Pro_Names[i], name) && (equali(Pro_AuthIDS[i], authid))))
		{
			
			formatex(Pro_Names[i], 31, name);
			save_pro15()
		}		
		
		if( (!equali(Noob_Names[i], name) && (equali(Noob_AuthIDS[i], authid))))
		{
			formatex(Noob_Names[i], 31, name);
			save_Noob15()
		}		
		
		if( (!equali(Wpn_Names[i], name) && (equali(Wpn_AuthIDS[i], authid))))
		{
			formatex(Wpn_Names[i], 31, name);
			save_Wpn15()
		}
	}
	
	return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
	new newname[32], oldname[32] ,authid[32]
	get_user_info(id, "name", newname,31) 
	get_user_name(id,oldname,31) 
	get_user_authid(id, authid, 31);

	for(new i = 0; i < num; i++)
	{
		if(!equal(oldname,newname) &&
		(!equali(Pro_Names[i], newname) &&
		(equali(Pro_AuthIDS[i], authid) ||
		(!equali(Noob_Names[i], newname) &&
		(equali(Noob_AuthIDS[i], authid)) ||
		(!equali(Wpn_Names[i], newname) &&
		(equali(Wpn_AuthIDS[i], authid)
		))))))
		{
			formatex(Pro_Names[i], 31, newname);
			save_pro15()
			formatex(Noob_Names[i], 31, newname);
			save_Noob15()
			formatex(Wpn_Names[i], 31, newname);
			save_Wpn15()
		}
	}
	return PLUGIN_CONTINUE
}


// =================================================================================================
// Menu
// =================================================================================================

public kz_menu(id)
{
	if (!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	
	new title[256];
	//---------
	new maptype[64],mapinfo[64];
	new thetime[64];
	get_time("%Y/%m/%d - %H:%M:%S",thetime,63)

	new tl = get_timeleft()	
	
	new data[256], map[64];
	new map_time_file[128];
	formatex(map_time_file, 127, "%s/%s", KZ_DIR, KZ_MAPTYPE);
	new f = fopen(map_time_file, "rt" );
	
	while( !feof( f ) )
	{
		fgets( f, data, 255 )
		parse( data, map, 63 ,maptype,63)
		strtok(data,map,63,maptype,63,' ')
		
		if( equali( map, MapName ) )
		{			
			format(mapinfo,63,"%s",maptype)
			break;
		} 
	}
	fclose(f)
	//-----
	
	formatex(title, 285, "\r#Yoiz's Home Kz Server ^n\dBased on \yProkreedz V2.31 \d Edited by \yAzuki daisuki~^n\dPresent time %s^nMap \y%s\d & Timeleft \y%d:%02d^n\dType map \y%s", thetime, MapName, tl/60, tl%60, mapinfo);
	// formatex(title, 285, "\d[xiaokz] \r#KZ Server \dVisit \ywww.csxiaokz.com ^n\rQQ群:719383105^n\dBeiJing time \y%s^n\dMap \y%s\d & Timeleft \y%d:%02d^n\dType map \y%s", thetime, MapName, tl / 60, tl % 60, mapinfo);
	
	new menu = menu_create(title, "MenuHandler")  
	new msgctspec[64];
	
	formatex(msgctspec, 63, "%L^n", id, (cs_get_user_team(id) == CS_TEAM_CT) || (cs_get_user_team(id) == CS_TEAM_T) ? "KZ_SPECTATOR" : "KZ_CT")
	// formatex(msgctspec, 63, "%L^n", id, (cs_get_user_team(id) == CS_TEAM_CT) ? "KZ_SPECTATOR" : "KZ_CT")
	
	menu_vadditem(menu, "1", _, _, "%L^n", id, "KZ_MAINMENG_MENU1")
	menu_vadditem(menu, "2", _, _, "%L", id, "KZ_MAINMENG_MENU2")
#if defined KZ_DUEL
	menu_vadditem(menu, "3", _, _, "%L", id, "KZ_MAINMENG_MENU3")
#else
	menu_vadditem(menu, "3", _, _, "%L", id, "KZ_MAINMENG_MENU_LANG")
#endif
	menu_vadditem(menu, "4", _, _, "%L", id, "KZ_MAINMENG_MENU4")
	menu_vadditem(menu, "5", _, _, "%L^n", id, "KZ_MAINMENG_MENU5")
	menu_additem( menu, msgctspec, "6")
	menu_vadditem(menu, "7", _, _, "%L", id, "KZ_MAINMENG_MENU7")

	menu_display(id, menu, 0)

	return PLUGIN_HANDLED
}


public MenuHandler(id , menu, item)
{
	if( item == MENU_EXIT ) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
 
	switch(item) 
	{

		case 0:
		{
			JumpMenu(id)
		}
		case 1:
		{
			top15menu(id)
		}
#if defined KZ_DUEL
		case 2:
		{
			DuelMenu(id)
		}
#else
		case 2:
		{
			langmenu(id)
		}
#endif
		case 3:
		{
			ConfigFunctionMenu(id)			
		}
		case 4:
		{
			new Playersnum[32], playerscount
			get_players(Playersnum, playerscount, "ah") 
			if(playerscount > 1 || DefaultStop){
				Teleport(id)
			} else {
				kz_menu(id)
			}
		}
		case 5:
		{
			ct(id)
			kz_menu(id)
		}
		case 6:
		{
			if(callfunc_begin("cmdMeasure","measure.amxx") == 1) 
			{
				callfunc_push_int(id)
				callfunc_end()
			}
		}
	}
	return PLUGIN_HANDLED
}

public DuelMenu(id)
{
#if defined KZ_DUEL
	new menu = menu_create("\rKreedZ Duel Menu ^n^n\wType\y/bet\w Open Btes Menu^nType\y/duels /dueltop\w List Integral Tops^nType\y/gg\w or \y/abort\w Exit Challenge!\w", "DuelMenuHandler")
	
	menu_vadditem(menu, "1", _, _, "\y%L^n", id, "KZ_DUELMENG_MENU1")
	menu_vadditem(menu, "1", _, _, "\w%L", id, "KZ_DUELMENG_MENU2")
	menu_vadditem(menu, "1", _, _, "\w%L^n", id, "KZ_DUELMENG_MENU3")
	menu_vadditem(menu, "1", _, _, "\y%L", id, "KZ_DUELMENG_MENU4")
#else	
	new menu = menu_create("\r错误: 数据库连接失败,请联系服务器管理员!^n^n\rSQL Connection failed, You now can't duel sorry!", "DuelMenuHandler")
	
	menu_vadditem(menu, "1", _, _, "\y%L^n", id, "KZ_DUELMENG_MENU1")
	menu_vadditem(menu, "1", _, _, "\w%L", id, "KZ_DUELMENG_MENU2")
	menu_vadditem(menu, "1", _, _, "\w%L^n", id, "KZ_DUELMENG_MENU3")
	menu_vadditem(menu, "1", _, _, "\y%L", id, "KZ_DUELMENG_MENU4")
#endif
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED 
}

public DuelMenuHandler (id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
#if defined KZ_DUEL	
	switch(item)
	{
		case 0:
		{
			if(callfunc_begin("duel_start","PE_DueL_SQL.amxx") == 1) 
			{
				callfunc_push_int(id)
				callfunc_end()
			}							
		}
		case 1:
		{
			if(callfunc_begin("show_duels","PE_DueL_SQL.amxx") == 1) 
			{
				callfunc_push_int(id)
				callfunc_end()
			}
			DuelMenu(id)
		}
		case 2:
		{
			if(callfunc_begin("show_top","PE_DueL_SQL.amxx") == 1) 
			{
				callfunc_push_int(id)
				callfunc_end()
			}
			DuelMenu(id)
		}
		case 3:
		{
			kz_menu(id)
		}
	}
#else 
	switch(item)
	{
		case 0:
		{
			DuelMenu(id)						
		}
		case 1:
		{
			DuelMenu(id)		
		}
		case 2:
		{
			DuelMenu(id)
		}
		case 3:
		{
			kz_menu(id)
		}
	}
#endif
	return PLUGIN_HANDLED
}
//===================================================================

public ConfigFunctionMenu(id)	
{

	new menu = menu_create ("\yConfigFunction Menu^n^n\rHere are some of the commonly used personal settings information^nBut don't provide stored offline ...\y^n^n", "ConfigFunctionMenuHandler" )

	menu_vadditem(menu, "1", _, _, "%L", id, "KZ_CFGF_MENU1")
	menu_vadditem(menu, "2", _, _, "%L", id, "KZ_CFGF_MENU2")
	menu_vadditem(menu, "3", _, _, "%L^n", id, "KZ_CFGF_MENU3")
	menu_vadditem(menu, "4", _, _, "%L", id, "KZ_CFGF_MENU4")
	menu_vadditem(menu, "5", _, _, "%L", id, "KZ_CFGF_MENU5")
	menu_vadditem(menu, "6", _, _, "%L", id, "KZ_CFGF_MENU6")
	menu_vadditem(menu, "7", _, _, "%L", id, "KZ_CFGF_MENU7")
	if(get_user_flags(id) & KZ_LEVEL)
	{
		menu_vadditem(menu, "8", _, _, "%L", id, "KZ_CFGF_MENU8")
	}
	else
	{
		menu_vadditem(menu, "8", _, _, "\d%L", id, "KZ_CFGF_MENU8")
	}
	menu_vadditem(menu, "9", _, _, "%L", id, "KZ_CFGF_MENU9")
	menu_vadditem(menu, "10", _, _, "%L", id, "KZ_CFGF_MENU10")
	menu_vadditem(menu, "11", _, _, "%L", id, "KZ_CFGF_MENU11")
	
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED 

}

public ConfigFunctionMenuHandler (id, menu, item) {

	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch(item)
	{
		case 0:
		{
			reset_checkpoints1(id)
			ConfigFunctionMenu(id)
		}
		case 1:
		{
			InvisMenu(id)
		}
		case 2:
		{
			cmdScout(id)
			ConfigFunctionMenu(id)
		}
		case 3:
		{
			client_cmd (id, "say rtv")
			ConfigFunctionMenu(id)
		}
		case 4:
		{
			weapons(id)
		}
		case 5:
		{
			client_cmd (id, "say /mute")
		}
		case 6:
		{
			langmenu(id)
		}
		case 7:
		{
			if (!( get_user_flags(id) & KZ_LEVEL))
				return PLUGIN_HANDLED
			else
				AdminMenu(id)
		}
		case 8:
		{
			cmd_help(id)
			ConfigFunctionMenu(id)
		}
		case 9:
		{
			ShowTimer_Menu(id)
		}
		case 10:
		{
			WRDIFF_Type_Menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public langmenu(id)
{
	new menu = menu_create("\r双语言切换(Language switching)", "lang_menu_handler");

	menu_vadditem(menu, "1", _, _, "%L", id, "KZ_LANG_MENU1")
	menu_vadditem(menu, "2", _, _, "%L", id, "KZ_LANG_MENU2")

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public lang_menu_handler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			client_cmd(id, "setinfo lang cn");
			set_task(0.3, "kz_menu", id)
		}
		case 1:
		{
			client_cmd(id, "setinfo lang en");
			set_task(0.3, "kz_menu", id)
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Savepos_menu(id)
{
	new menu = menu_create("\r请选择加载进度或重新开始...^n^nPlease choose moved to the savepos or restart...", "Savepos_menu_handler");
	
	menu_vadditem(menu, "1", _, _, "%L^n", id, "KZ_SAVEPOS_MENU1")
	menu_vadditem(menu, "2", _, _, "%L^n", id, "KZ_SAVEPOS_MENU2")
	
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public Savepos_menu_handler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			if(is_user_alive(id))
			{
				GoPos(id)
			}
			else
			{
				kz_chat(id, "您必须或者才能使用此功能")
				Savepos_menu(id)
			}
		}
		case 1:
		{
			goStartPos(id)
			Verif(id,0)
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

//============================================================================
//						Climb Menu
//============================================================================

public JumpMenu(id)
{
	new title[256];

	formatex(title, 255, "\rClimb Menu")
	new menu = menu_create(title, "JumpMenuHandler")  
	
	new msgcheck[64], msggocheck[64], msgpause[64], msggolastcheck[64], msgSaveAngle[64]	//, msgctspec[64]
	formatex(msgcheck, 63, "%L - [\r#%i\w]", id, "KZ_CHECK_IS",  checknumbers[id])
	formatex(msggocheck, 63, "%L - [\r#%i\w]", id, "KZ_GOCHECK_IS", gochecknumbers[id])
	formatex(msggolastcheck, 63, "%L \r*最多返回%d个*^n", id, "KZ_JUMPMENU_MENU5", get_cvar_num("kz_checkpoints_num"));
	formatex(msgpause, 63, "%L - [%s\w]^n", id, "KZ_PAUSE", IsPaused[id] ? "\yON" : "\rOFF");
	formatex(msgSaveAngle, 63, "读取存点角度 - [%s\w]", gc1[id] ? "\yON" : "\rOFF");
	// formatex(msgctspec, 63, "%L^n", id, (cs_get_user_team(id) == CS_TEAM_CT) ? "KZ_SPECTATOR" : "KZ_CT")
	
	menu_additem( menu, msgcheck, "1" )
	menu_additem( menu, msggocheck, "2" )
	menu_additem( menu, msggolastcheck, "3" )
	// menu_vadditem(menu, "3", _, _, "%L^n", id, "KZ_JUMPMENU_MENU5")
	menu_additem( menu, msgpause, "4" )
	menu_vadditem(menu, "5", _, _, "%L^n", id, "KZ_JUMPMENU_MENU1")
	
	menu_additem( menu, ( timer_started[id] && gochecknumbers[id] )? "\yUndo GoCheck" : "\dUndo GoCheck", "6")
	menu_additem( menu, msgSaveAngle, "7");	 																		// 是否保留存点角度
	menu_vadditem(menu, "8", _, _, "%L", id, "KZ_JUMPMENU_MENU8")
	// menu_vadditem(menu, "6", _, _, "%L^n", id, "KZ_JUMPMENU_MENU7")
	// menu_additem( menu, "Usp/Knife", "7")
	menu_display(id, menu, 0)
	
	return PLUGIN_HANDLED 
}

public JumpMenuHandler(id , menu, item)
{
	if( item == MENU_EXIT ) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
 
	switch(item) 
	{
		case 4:{
			goStartPos(id)
			JumpMenu(id)
		}
		case 3:{
			Pause(id)
			JumpMenu(id)
		}
		case 0:{
			CheckPoint(id)
			JumpMenu(id)	
		}
		case 1:{
			GoCheck(id)
			JumpMenu(id)
		}
		case 2:{
			Stuck(id)
			JumpMenu(id)
		}
		case 5:{
			// CheckPointStart(id)
			UndoGoCheck(id);
			JumpMenu(id)
		}
		case 7:{
			reset_checkpoints1(id)
			JumpMenu(id)
		}
		case 6:{
			// cmdUsp(id)
			gc1[id] = !gc1[id];
			JumpMenu(id)
		}
	}
	return PLUGIN_HANDLED
}

public AdminMenu(id)
{
	new menu = menu_create("\rKreedz Admin Menu\w", "AdminMenuHandler")
	new hidespec[64]
	formatex(hidespec, 63, "隐藏在观察者 - %s",  g_bHideMe[id] ? "\yOn" : "\rOff" )

		
	menu_additem( menu, "AMXX管理员菜单^n", "1" )
	menu_additem( menu, "设置地图类型", "2" )
	menu_additem( menu, "发起地图投票", "3" )
	menu_additem( menu, "直接更换地图", "4" )
	menu_additem( menu, "连跳板子设定\y(鼠标准星标记)", "5" )
	menu_additem( menu, "更新最新记录\y(XJ CC NT)^n", "6" )
	menu_additem( menu, hidespec, "7" )

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED 
}

public AdminMenuHandler (id, menu, item, level, cid)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if(callfunc_begin("cmdMenu","menufront.amxx") == 1) 	//amxmodmenu
			{
				callfunc_push_int(id)
				callfunc_end()
			}	
		}
		case 1:
		{
			setmaps(id)
		}
		case 2:
		{
			if(callfunc_begin("Command_StartVote","xmap_manager.amxx") == 1) 	//startvote
			{
				callfunc_push_int(id)
				callfunc_end()
			}	
		}
		case 3:
		{
			client_cmd(id, "messagemode amx_map");
			ColorChat(id, Color:5, "^x04%s ^x01请输入^x03地图名...", prefix);
			ColorChat(id, Color:5, "^x04%s ^x01请输入^x03地图名...", prefix);
			ColorChat(id, Color:5, "^x04%s ^x01请输入^x03地图名...", prefix);
		}
		case 4:
		{
			if(callfunc_begin("ClCmd_BhopMenu","mpbhop.amxx") == 1) 	//mpbhop menu
			{
				callfunc_push_int(id)
				callfunc_end()
			}	
		}
		case 5:
		{
			cmdUpdateWRdata(id)
		}
		case 6:
		{
			if(callfunc_begin("cmdHideme","speclist&clientinfo_src.amxx") == 1)  //speclist (hideme [admin])
			{
				callfunc_push_int(id)
				callfunc_end()
			}	
			hideme(id)
			AdminMenu(id)
		}
	}
	return PLUGIN_HANDLED
}

public hideme(id)
{
	if (!(get_user_flags(id) & KZ_LEVEL))
	
		return PLUGIN_HANDLED;

	g_bHideMe[id] = !g_bHideMe[id];
	
	return PLUGIN_HANDLED;
}

public client_kill( id )
{
	client_print(id, print_console, "%L",id ,"KZ_CLIENTKILL_INFO")
	return PLUGIN_HANDLED
}


// --------------------------------------------------------------------------------
public cmdServerMenu(id)
{
	new IP[42], Port[6];
	get_user_ip(0, IP, charsmax(IP));
	new pos = containi(IP, ":");
	formatex(Port, charsmax(Port), IP[pos+1]);

	new szMenu[1024];

	if(equali(Port, "27015"))		//5#
	{
		formatex(szMenu, charsmax(szMenu), "\rServer \yMenu^n^n\r1. \d5# KreedZ Rank Server \y[NTjump Rank]^n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]^n\r3. \d10# KreedZ Xtreme Server  \y[Steam User]^n\r4. \w9# KreedZ Test Server \y[All Maps]^n^n^n^n^n\r9. \wBack^n\r0. \wExit");
		show_menu(id, MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_9|MENU_KEY_0, szMenu, -1, "ServerMenu");
	}
	else if(equali(Port, "27016"))  //3#
	{
		formatex(szMenu, charsmax(szMenu), "\rServer \yMenu^n^n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]^n\r2. \d3# KreedZ Bhop Server \y[Bhop Easy]^n\r3. \d10# KreedZ Xtreme Server \y[Steam User]^n\r4. \w9# KreedZ Test Server \y[All Maps]^n^n^n^n^n\r9. \wBack^n\r0. \wExit");
		show_menu(id, MENU_KEY_1|MENU_KEY_3|MENU_KEY_4|MENU_KEY_9|MENU_KEY_0, szMenu, -1, "ServerMenu");
	}	
	else if(equali(Port, "27019"))	//10#
	{
		formatex(szMenu, charsmax(szMenu), "\rServer \yMenu^n^n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]^n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]^n\r3. \d10# KreedZ Xtreme Server \y[Steam User]^n\r4. \w9# KreedZ Test Server \y[All Maps]^n^n^n^n^n\r9. \wBack^n\r0. \wExit");
		show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_4|MENU_KEY_9|MENU_KEY_0, szMenu, -1, "ServerMenu");
	}
	else if(equali(Port, "27021"))	//9#
	{
		formatex(szMenu, charsmax(szMenu), "\rServer \yMenu^n^n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]^n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]^n\r3. \d10# KreedZ Xtreme Server \y[Steam User]^n\r4. \d9# KreedZ Test Server \y[All Maps]^n^n^n^n^n\r9. \wBack^n\r0. \wExit");
		show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_9|MENU_KEY_0, szMenu, -1, "ServerMenu");
	}

	return PLUGIN_HANDLED;
}

public handleServerMenu(id, item) 
{
	new name[32];
	get_user_name( id, name, 31 )
	
	switch(item) 
	{
		case 0:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;^"connect^" 61.153.110.99:27015");
			ColorChat(0, RED, "^4%s ^3%s ^1has been redirected to^3 5# KreedZ Rank Server^1. Say /server to switch between servers ...",prefix, name);
		}
		case 1:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;^"connect^" 61.153.110.99:27016");
			ColorChat(0, RED, "^4%s ^3%s ^1has been redirected to^3 3# KreedZ Bhop Server^1. Say /server ^1to switch between servers ...",prefix, name);
		}
		case 2:
		{
			// client_cmd(id, "wait;wait;wait;wait;wait;^"connect^" 61.153.110.99:27019");
			// ColorChat(0, RED, "^4%s ^3%s ^1has been redirected to^3 10# KreedZ Xtreme Server^1. Say /server ^1to switch between servers ...",prefix, name);
			cmdServerMenu(id)
		}
		case 3:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;^"connect^" 61.153.110.99:27021");
			ColorChat(0, RED, "^4%s ^3%s ^1has been redirected to^3 9# KreedZ Test Server^1. Say /server ^1to switch between servers ...",prefix, name);
		}
		case 8:
		{
			kz_menu(id);
			return PLUGIN_HANDLED;
		}
		case 9:
		{
			return PLUGIN_HANDLED;
		}
	}
	cmdServerMenu(id);
	return PLUGIN_HANDLED;
}
	
// --------------------------------------------------------------------------------

public Msg_StatusIcon(msgid, msgdest, id)
{
	static szMsg[8];
	get_msg_arg_string(2, szMsg, 7);

	if( equal( szMsg, "buyzone" ) && get_msg_arg_int(1) ) 
	{
		set_pdata_int( id, 235, get_pdata_int( id, 235) & ~(1 << 0));
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public OR_PMMove(OrpheuStruct:pmove, server)
{
	if(g_bAxnBhop)
	{
		g_ppmove = pmove;
	}
}

public OR_PMJump()
{
	if(g_bAxnBhop)
	{
		g_flOldMaxSpeed = Float:OrpheuGetStructMember(g_ppmove, "maxspeed");
		OrpheuSetStructMember(g_ppmove, "maxspeed", 0.0);
	}
}

public OR_PMJump_P()
{
	if(g_bAxnBhop)
	{
		OrpheuSetStructMember(g_ppmove, "fuser2", 0.0);
		OrpheuSetStructMember(g_ppmove, "maxspeed", g_flOldMaxSpeed);
	}
}

//-------------------------------------------------
// 进服后控制台信息 
public ServerInfo_Console(id) 
{
        new name[32], authid[32], ip[32], hostname[64], thetime[32]
        get_user_name( id, name, 31 )
        get_user_authid( id, authid, 31 )
        get_user_ip( id, ip, 31, 0 )
        get_cvar_string( "hostname", hostname, 63 )
        get_time("%Y/%m/%d - %H:%M:%S",thetime,31);

        client_cmd(id, "echo ^" ^"")
        client_cmd(id, "echo ^" ^"")
        client_cmd(id, "echo ^" ^"")
        client_cmd(id, "echo ^" ^"")		
        client_cmd(id, "echo ^"                =========================================^"")
        client_cmd(id, "echo ^"                                     Welcome: %s                           ^"", hostname)
        client_cmd(id, "echo ^"                                     Beijing Time: %s                      ^"", thetime)
        client_cmd(id, "echo ^"                        -------------------------------------------------------------^"")
        client_cmd(id, "echo ^"                        Your Message:                       ^"")
        client_cmd(id, "echo ^"                        -------------------------------------------------------------^"")
        client_cmd(id, "echo ^"                                   Name:       %s                      ^"", name)
        client_cmd(id, "echo ^"                              SteamID:       %s                      ^"", authid)
        client_cmd(id, "echo ^"                                       IP:        %s              ^"", ip)
        client_cmd(id, "echo ^"                        -------------------------------------------------------------^"")
        client_cmd(id, "echo ^"                        Based on Prokreedz V2.31 ☺              ^"")
        client_cmd(id, "echo ^"                        Edited by Azuki daisuki~ ☺              ^"")
        client_cmd(id, "echo ^"                        Special thanks to XiaoKz & Perfectslife ☺              ^"")
        // client_cmd(id, "echo ^"                        -------------------------------------------------------------^"")
        // client_cmd(id, "echo ^"                                     QQ:         375904504           ^"")      
        // client_cmd(id, "echo ^"                                   E-Mail:         375904504@qq.com     ^"")
        client_cmd(id, "echo ^"                =========================================^"")
}

public setmaps(id)
{
	if(get_user_flags(id) & KZ_LEVEL)
	{
		static opcion[64]
		formatex(opcion, charsmax(opcion),"\y%s \r%s \dMaps Type Menu",prefix, MapName)	
		new iMenu=menu_create(opcion,"choose")
		new szTempid[10]
	
		formatex(opcion, charsmax(opcion),"\wBhop")
		menu_additem(iMenu, opcion, szTempid,0)
		formatex(opcion, charsmax(opcion),"\wClimb")
		menu_additem(iMenu, opcion, szTempid,0)
		formatex(opcion, charsmax(opcion),"\wBhop/Climb")
		menu_additem(iMenu, opcion, szTempid,0)
		formatex(opcion, charsmax(opcion),"\wHard")
		menu_additem(iMenu, opcion, szTempid,0)
		formatex(opcion, charsmax(opcion),"\wSlide")
		menu_additem(iMenu, opcion, szTempid,0)
		formatex(opcion, charsmax(opcion),"\wBlocks")
		menu_additem(iMenu, opcion, szTempid,0)		
		formatex(opcion, charsmax(opcion),"\wAxn")
		menu_additem(iMenu, opcion, szTempid,0)
              
	
		menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
		formatex(opcion, charsmax(opcion),"\rBack")
		menu_setprop(iMenu, MPROP_BACKNAME, opcion)
		formatex(opcion, charsmax(opcion),"\rNext")
		menu_setprop(iMenu, MPROP_NEXTNAME, opcion)
		formatex(opcion, charsmax(opcion),"\rExit")
		menu_setprop(iMenu, MPROP_EXITNAME, opcion)
		menu_setprop(iMenu, MPROP_NUMBER_COLOR, "\y")
		menu_display(id, iMenu, 0)
	}
	else
	{
		ColorChat(id, GREEN, "^1%s ^3You can't open the menu.", prefix)
	}
	return PLUGIN_HANDLED
}

public choose(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new command[6], name[64], access, callback
	new mapsmode[33]

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 0..6:	//设置多个选项0-?
		{
			if(item==0)
			format(mapsmode,32,"Bhop")
			else if(item==1)
			format(mapsmode,32,"Climb")
			else if(item==2)
			format(mapsmode,32,"Bhop/Climb")
			else if(item==3)
			format(mapsmode,32,"Hard")
			else if(item==4)
			format(mapsmode,32,"Slide")
			else if(item==5)
			format(mapsmode,32,"Blocks")			
			else if(item==6)
			format(mapsmode,32,"Axn")
		
			ColorChat(id, GREEN, "^1%s ^3%s ^1Set Type: ^3%s",prefix, MapName,mapsmode)
			
			save_information(MapName,mapsmode)
		}

	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public save_information(MapName[],mapsmode[])
{
	new line = 0, textline[1024], len
	new line_name[64] 
	new value[33]

	if(!file_exists(file))
	{
		write_file(file, "")
	}
	new addition=0

	while((line = read_file(file, line, textline, 1023, len)))
	{
		if (len == 0 || equal(textline, ";", 1))
			continue

		parse (textline, line_name, 63)
		strtok(textline,line_name,charsmax(line_name),value,charsmax(value),' ')
		if (equali(line_name,MapName))
		{
			len = format(textline, 1023, "%s ",MapName )
			len += format(textline[len], 1023 - len, "%s",mapsmode )
			write_file(file, textline, line -1)
			addition=1
		}
	}
	if(addition!=1)
	{
		len = format(textline, 255, "%s ", MapName)
		len += format(textline[len], 255 - len, "%s", mapsmode )
		write_file(file, textline)
	}
	return 0
}
//===========================================
//				正版bind_key无效
//===========================================

// public client_bind(id)
// {
// 	new ids[2]
// 	ids[0]=id
// 	set_task(0.1,"bind_keys",id,"",0)
// }

// public bind_keys(id)
// {
// 	if(is_user_connected(id))
// 	{
// 		client_cmd(id, "bind ^"F1^" ^"say /menu^"");
// 		client_cmd(id, "bind ^"F2^" ^"say /start^"");
// 		client_cmd(id, "bind ^"F3^" ^"say /top15^"");
// 		client_cmd(id, "bind ^"F4^" ^"say /cp^"");
// 		client_cmd(id, "bind ^"F5^" ^"say /gc^"");
// 		client_cmd(id, "bind ^"F6^" ^"say /pause^"");		
// 		client_cmd(id, "bind ^"F7^" ^"say /spec^"");
// 		client_cmd(id, "bind ^"F8^" ^"say /stuck^"");
// 		client_cmd(id, "bind ^"F9^" ^"say /help^"");
// 		client_cmd(id, "bind ^"=^" ^"+hook^"");
// 	}
// 	return PLUGIN_HANDLED   
// }

public InvisMenu(id)
{
	new menu = menu_create("\yInvis Menu\w", "InvisMenuHandler")
	new msginvis[64], msgwaterinvis[64]
	
	formatex(msginvis, 63, "%L - [%s\w]", id, "INVIS_PLAYER",  gViewInvisible[id] ? "\yON" : "\rOFF" )
	formatex(msgwaterinvis, 63, "%L - [%s\w]^n^n", id, "INVIS_WATER", gWaterInvisible[id] ? "\yON" : "\rOFF" )
	
	menu_additem( menu, msginvis, "1" )
	menu_additem( menu, msgwaterinvis, "2" )
	menu_additem( menu, "Main Menu", "3" )

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED 
}

public InvisMenuHandler (id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch(item)
	{
		case 0:
		{
			cmdInvisible(id)
			InvisMenu(id)
		}
		case 1:
		{
			cmdWaterInvisible(id)
			InvisMenu(id)
		}
		case 2:
		{
			kz_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public ShowTimer_Menu(id)
{
	new menu = menu_create("\yTimer Menu\w", "TimerHandler")

	new TXTtimer[64], hudtimer[64]
	
	formatex(TXTtimer, 63, "TXT Timer - [%s\w]", ShowTime[id] == 1 ? "\yON" : "\rOFF" )
	formatex(hudtimer, 63, "HUD Timer - [%s\w]^n", ShowTime[id] == 2 ? "\yON" : "\rOFF" )
	
	menu_additem( menu, TXTtimer, "1" )
	menu_additem( menu, hudtimer, "2" )
	menu_additem( menu, "Main Menu", "3" )

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public TimerHandler (id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch(item)
	{

		case 0:
		{
			ShowTime[id]= 1
			ShowTimer_Menu(id)
		}
		case 1:
		{
			ShowTime[id]= 2
			ShowTimer_Menu(id)
		}
		case 2:
		{
			kz_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public WRDIFF_Type_Menu(id)
{
	new menu = menu_create("\yKZ Record Difference Menu^n^n\rWR? NTR? ...\w", "WRDIFF_Type_Handler")

	new WREtimer[64], NTRtimer[64]
	
	formatex(WREtimer, 63, "Official \dXJ+CC   \w- [%s\w]", kz_type_wr[id] == 1 ? "\yON" : "\rOFF" )
	formatex(NTRtimer, 63, "China \dNTjump \w- [%s\w]^n", kz_type_wr[id] == 2 ? "\yON" : "\rOFF" )
	
	menu_additem( menu, WREtimer, "1" )
	menu_additem( menu, NTRtimer, "2" )
	menu_additem( menu, "Main Menu", "3" )

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public WRDIFF_Type_Handler (id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch(item)
	{

		case 0:
		{
			kz_type_wr[id]= 1
			WRDIFF_Type_Menu(id)
		}
		case 1:
		{
			kz_type_wr[id]= 2
			WRDIFF_Type_Menu(id)
		}
		case 2:
		{
			kz_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public top15menu(id)
{
	new top15msg[1024]
	formatex(top15msg, 1023, "\dKreedz Server Top100^n\dMap \r%s^n^n%s^n%s"
	, MapName,WRTimes,NTTimes)

	new menu = menu_create(top15msg, "top15handler")
	menu_additem(menu, "\wPro Stats", "1", 0)
	menu_additem(menu, "\wNub Stats", "2", 0)
	menu_additem(menu, "\wWpn Stats [\rWPNSPEED\w]^n^n", "3", 0)
	#if defined USE_SQL
	menu_additem(menu, "Pro Records","3")
	menu_additem(menu, "Players Rankings^n","4")
	menu_additem(menu, "Last 10 Pro Entries", "5")
	menu_additem(menu, "Maps Statistic","6")
	menu_additem(menu, "Main Menu", "7")
	#else
	menu_additem(menu, "\wMain Menu", "4", 0)
	#endif
	
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

public top15handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	#if defined USE_SQL
	switch(item)
	{
		case 0:
		{
			ProTop_show(id)
			top15menu(id)
		}
		case 1:
		{
			NoobTop_show(id)
			top15menu(id)
		}
		case 2:
		{
			kz_showhtml_motd(id, PRO_RECORDS, "")
		}
		case 3:
		{
			kz_showhtml_motd(id, PLAYERS_RANKING, "")
		}
		case 4:
		{
			kz_showhtml_motd(id, LAST_PRO10, "")
		}
		case 5:
		{
			kz_showhtml_motd(id, MAPS_STATISTIC, "")
		}
		case 6:
		{
			kz_menu(id)
		}
	}
	#else
	switch(item)
	{
		case 0:
		{
			ProTop_show(id)
			top15menu(id)
		}
		case 1:
		{
			NoobTop_show(id)
			top15menu(id)
		}
		case 2:
		{
			WpnTop_show(id)
			top15menu(id)
		}
		case 3:
		{
			kz_menu(id)
		}
	}
	#endif
	
	return PLUGIN_HANDLED;
}

// =================================================================================================
// 
// Timersystem
// =================================================================================================
public fwdUse(ent, id)
{
	if( !ent || id > 32 )
	{
		return HAM_IGNORED;
	}
	
	if( !is_user_alive(id) || is_user_bot(id))
	{
		return HAM_IGNORED;
	}
	
	new name[32]
	get_user_name(id, name, 31)
	
	new szTarget[ 32 ];
	pev(ent, pev_target, szTarget, 31);
	
	if( TrieKeyExists( g_tStarts, szTarget ) )
	{
		if((!get_user_noclip(id) && get_gametime() - antinoclipstart[id] < 3.0) || get_user_noclip(id)) 
		{
			kz_chat(id, "%L", id, "KZ_TNC_LATER")
			return PLUGIN_HANDLED
		}
		
		if ( get_gametime() - antihookcheat[id] < 3.0 )
		{	
			kz_hud_message( id, "%L", id, "KZ_HOOK_PROTECTION" );
			return PLUGIN_HANDLED
		}
		
		if(Verif(id,1))
		{
			kz_chat(id,  "%L", id, "KZ_START_SAVEPOSINFO")
			Savepos_menu(id)
			return HAM_IGNORED
			
		}
		
		if ( reset_checkpoints(id) && !timer_started[id]  )
		{
			ArrayClear(g_DemoReplay[id]);	//按E后清空保存的信息
			ArrayClear(gc_DemoReplay[id]);
			start_climb(id)
				
			if( get_user_health(id) < 100 )
				set_user_health(id, 100)

			pev(id, pev_origin, SavedStart[id])
			if(get_pcvar_num(kz_save_autostart) == 1)
				AutoStart[id] = true;

			if( !DefaultStart )
			{
				kz_set_start(MapName, SavedStart[id])
				ColorChat(id, GREEN,  "^1%s^x03 %L", prefix, id, "KZ_SET_START")
			}

			remove_hook(id)
		}
		
	}
	
	if( TrieKeyExists( g_tStops, szTarget ) )
	{
		if (tphook_user[id] || IsPaused[id]) 
		{
			kz_hud_message(id, "%L", id, "KZ_TIME_ISPAUSE")
			return PLUGIN_HANDLED
		}
		
		if( timer_started[id] && !tphook_user[id && !is_user_bot(id)])	//需要排除BOT 避免BOT的完成影响SR -> 可能导致全0
		{
			if(get_user_noclip(id))
				return PLUGIN_HANDLED
			pev(id, pev_origin, SavedStop[id])
			if( !DefaultStop )
			{
				kz_set_stop(MapName, SavedStop[id])
			}
			finish_climb(id)
		}
		else
			kz_hud_message(id, "%L", id, "KZ_TIMER_NOT_STARTED")
	}
	return HAM_IGNORED
}

public start_climb(id)
{
	cs_set_user_money(id,get_pcvar_num(kz_startmoney))
	
	if( get_pcvar_num(kz_reload_weapons) == 1 )	
	{
		checkweapons(id);
		if( !task_exists(id+TASK_ID_STARTWEAPONS) )
		{
			set_task(0.5, "dararmitaon", id+TASK_ID_STARTWEAPONS);
		}
		
		if (user_has_weapon(id, CSW_GLOCK18))
		{
			strip_user_weapons(id)
			cmdUsp(id)
		}
	}
	
	if(!GodMap)
	{
		set_user_godmode(id, 0)
	}
	
	set_pev(id, pev_gravity, 1.0);
	set_pev(id, pev_movetype, MOVETYPE_WALK)
	reset_checkpoints1(id)
	IsPaused[id] = false
	timer_started[id] = true
	timer_time[id] = get_gametime()
	tphook_user[id] = false
	WasPlayed[id] = false
	GoPosCp[id] = false
	GoPosed[id] = false
	GoPosHp[id] = false
	tptostart[id] = false
	REC_AC[id] = true;
}

// ========================= checkweapons =======================
public dararmitaon(id)
{
	id -= TASK_ID_STARTWEAPONS;
	remove_task(id+TASK_ID_STARTWEAPONS);
	g_playergiveweapon[id] = true;
}
public checkweapons(id)
{
	if( !g_playergiveweapon[id] )
		return;
		
	g_playergiveweapon[id] = false;
	
	new armita = get_user_weapon(id);
	g_numerodearma[id] = armita;
	strip_user_weapons(id)
	switch( armita )
	{
		case CSW_USP, CSW_KNIFE:
		{
			// strip_user_weapons(armita)
			give_uspknife(id, g_numerodearma[id]);
			cs_set_user_bpammo(id, CSW_USP, 132)
			wpn_15[id] = false
		}
		
		case CSW_P90, CSW_FAMAS, CSW_SG552, CSW_M4A1, CSW_M249, CSW_AK47, CSW_AWP:
		{
			give_scout(id, armita);
			wpn_15[id] = true
		}
		default:
		{
			give_scout(id, armita);
			wpn_15[id] = false
		}
	}
}

public finish_climb(id)
{
	if (!is_user_alive (id))
	{
		return;
	}
	
	if ( (get_pcvar_num(kz_top15_authid) > 1) || (get_pcvar_num(kz_top15_authid) < 0) )
	{
		ColorChat(id, GREEN,  "^x01%s^x03 %L.", prefix, id, "KZ_TOP15_DISABLED")
		return;
	}
	
	#if defined USE_SQL
	new Float: time, wpn
	time = get_gametime() - timer_time[id]
	if (get_pcvar_num(kz_wr_diff) == 1) {
		WrDiffShow(id)
	} 
	else {
		show_finish_message(id, time)
	}
	
	timer_started[id] = false
	new checkpoints=checknumbers[id]
	new gocheck=gochecknumbers[id]
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon( id )

	new steam[32], name[32]
	get_user_name(id, name, 31)
	get_user_authid(id, steam, 31 )	
	client_cmd(0, "spk buttons/bell1")
	new createinto[1001]
	
	new cData[192]
	cData[0] = id
	formatex(cData[2], charsmax(cData)-2, "^"%f^" ^"%d^" ^"%d^" ^"%d^"", time, wpn, checkpoints ,gocheck)

	
	if(equal(steam, "VALVE_ID_LAN") || equal(steam, "STEAM_ID_LAN") || strlen(steam) > 18)
	{
		
		if (gochecknumbers[id] == 0 &&  !user_has_scout[id] )
		{
			cData[1] = PRO_TOP
			formatex(createinto, sizeof createinto - 1, "SELECT time FROM `kz_pro15` WHERE mapname='%s' AND name='%s'", MapName, name)
			SQL_ThreadQuery(g_SqlTuple, "Set_QueryHandler", createinto, cData, strlen(cData[2])+1)
		}
		if (gochecknumbers[id] > 0 || user_has_scout[id] )
		{
			cData[1] = NUB_TOP
			formatex(createinto, sizeof createinto - 1, "SELECT time FROM `kz_nub15` WHERE mapname='%s' AND name='%s'", MapName, name)
			SQL_ThreadQuery(g_SqlTuple, "Set_QueryHandler", createinto, cData, strlen(cData[2])+1)
		}    
	} 
	else
	{
            
		if (gochecknumbers[id] == 0 &&  !user_has_scout[id] )
		{
			cData[1] = PRO_TOP
			formatex(createinto, sizeof createinto - 1, "SELECT time FROM `kz_pro15` WHERE mapname='%s' AND authid='%s'", MapName, steam)
			SQL_ThreadQuery(g_SqlTuple, "Set_QueryHandler", createinto, cData, strlen(cData[2])+1)
		}
		if (gochecknumbers[id] > 0 || user_has_scout[id] )
		{
			cData[1] = NUB_TOP
			formatex(createinto, sizeof createinto - 1, "SELECT time FROM `kz_nub15` WHERE mapname='%s' AND authid='%s'", MapName, steam)
			SQL_ThreadQuery(g_SqlTuple, "Set_QueryHandler", createinto, cData, strlen(cData[2])+1)
		}
	}
	#else
	new Float: time, authid[32]
	new maxspeeds = pev( id, pev_maxspeed )
	time = get_gametime() - timer_time[id]
	get_user_authid(id, authid, 31)
	if (get_pcvar_num(kz_wr_diff) == 1) {
		WrDiffShow(id)
	} 
	else 
	{
		show_finish_message(id, time)
	}	timer_started[id] = false
	
	if (wpn_15[id] && !user_has_weapon(id,CSW_SCOUT))
	{
		WpnTop_update(id, time, checknumbers[id], gochecknumbers[id], maxspeeds)
	}
	else
	{
		if (gochecknumbers[id] == 0 &&  !user_has_weapon(id,CSW_SCOUT) && !wpn_15[id] && !is_user_bot(id)) // 如果是BOT 不需要更新Pro
		{
			ProTop_update(id, time)
		}
		if (gochecknumbers[id] > 0 &&  !user_has_weapon(id,CSW_SCOUT) && !wpn_15[id] && !is_user_bot(id))	// 如果是BOT 不需要更新Nub
		{
			NoobTop_update(id, time, checknumbers[id], gochecknumbers[id])
		}

	}
	#endif
	user_has_scout[id] = false;
	REC_AC[id] = false;
}

public show_finish_message(id, Float:kreedztime)
{
	static Float:maxspeed;
	pev(id, pev_maxspeed, maxspeed );
	
	if( maxspeed <= 1.0 )
		maxspeed = 250.0;
	new name[32],authid[32]
	new imin,isec,ims, wpn
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon( id ) 
	get_user_name(id, name, 31)
	
	get_user_authid(id, authid, 31);
	imin = floatround(kreedztime / 60.0, floatround_floor)
	isec = floatround(kreedztime - imin * 60.0,floatround_floor)
	ims = floatround( ( kreedztime - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )

	for(new i = 0; i < num; i++)
	{
		new iminp = floatround(Pro_Times[i] / 60.0, floatround_floor)
		new isecp = floatround(Pro_Times[i]  - iminp * 60.0,floatround_floor)
		
		new iminz = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
		new isecz = floatround(Noob_Tiempos[i]  - iminz * 60.0,floatround_floor) 

		new oldminutes60 = (get_user_frags(id)*60)
		new oldtime = oldminutes60+cs_get_user_deaths(id)

		if(equal(Pro_AuthIDS[i], authid) || equal(Noob_AuthIDS[i], authid))
		{
			if (Pro_Times[i] < Noob_Tiempos[i])
			{
				set_user_frags(id, iminp)
				cs_set_user_deaths(id, isecp)
			}
					
			if(Pro_Times[i] > Noob_Tiempos[i])
			{
				set_user_frags(id, iminz)
				cs_set_user_deaths(id, isecz)
			}
		}
		else 	if (oldtime == 0)
		{
			set_user_frags(id, imin)
			cs_set_user_deaths(id, isec)
		}
	}

	ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L: [^3%d^1/^3%d^1] %L: ^3%s ^1[^3%d^1] )", prefix, name, LANG_PLAYER, "KZ_NOWRNUM_FINISH_MSG", imin, isec, ims, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], LANG_PLAYER, "KZ_WEAPON", g_weaponsnames[wpn],floatround( maxspeed, floatround_floor ))
}




public WrDiffShow(id) 
{
	new Float:zClimbTime = get_gametime() - timer_time[id];
	new name[32],authid[32]
	get_user_name(id, name, 31)
	get_user_authid(id, authid, 31);
	
	new imin,isec,ims
	imin = floatround(zClimbTime / 60.0, floatround_floor)
	isec = floatround(zClimbTime - imin * 60.0,floatround_floor)
	ims = floatround( ( zClimbTime - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )
	
	new wpn;
	
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon( id ) 
	
	static Float:maxspeed;
	pev(id, pev_maxspeed, maxspeed );
	
	if( maxspeed <= 1.0 )
	maxspeed = 250.0;

	if (kz_type_wr[id] == 1)
	{
		if (g_iWorldRecordsNum > 0) 
		{
			for(new i = 0; i < num; i++)
			{
				new iminp = floatround(Pro_Times[i] / 60.0, floatround_floor)
				new isecp = floatround(Pro_Times[i]  - iminp * 60.0,floatround_floor)
				
				new iminz = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
				new isecz = floatround(Noob_Tiempos[i]  - iminz * 60.0,floatround_floor) 

				new oldminutes60 = (get_user_frags(id)*60)
				new oldtime = oldminutes60+cs_get_user_deaths(id)

				if(equal(Pro_AuthIDS[i], authid) || equal(Noob_AuthIDS[i], authid))
				{
					if (zClimbTime < Pro_Times[i] || zClimbTime < Noob_Tiempos[i])
					{
						set_user_frags(id, imin)
						cs_set_user_deaths(id, isec)
					}
					else if (Pro_Times[i] < Noob_Tiempos[i])
					{
						set_user_frags(id, iminp)
						cs_set_user_deaths(id, isecp)
					}
					else if (Pro_Times[i] > Noob_Tiempos[i])
					{
						set_user_frags(id, iminz)
						cs_set_user_deaths(id, isecz)
					}
				}
				else 	if (oldtime == 0)
				{
					set_user_frags(id, imin)
					cs_set_user_deaths(id, isec)
				}
			}
			
			if (zClimbTime < DiffWRTime[0]) 
			{
				new Float:sDiffTime = DiffWRTime[0] - zClimbTime;
				new szDiffTime[16]
				WRTimer(sDiffTime, szDiffTime, sizeof(szDiffTime) - 1, true, false)
				set_dhudmessage(255, 30, 30, -1.0, 0.2, 2, 0.1, 6.0, 0.02, 0.5);
				
				if (wpn_15[id] && !user_has_weapon(id ,CSW_USP) || !user_has_weapon(id, CSW_KNIFE))
				{	
					ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L: [^3%d^1/^3%d^1] %L: ^3%s ^1[^3%d^1]", prefix, name, LANG_PLAYER, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], LANG_PLAYER, "KZ_WEAPON", g_weaponsnames[wpn],floatround( maxspeed, floatround_floor ))
				}
				else
				{
					if (gochecknumbers[id] == 0)
					{	
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L [^3-%s WR!!!^1]", prefix, name, LANG_PLAYER, "KZ_FINISH_MSG",  imin, isec, ims, LANG_PLAYER, "KZ_BEAT_CUR_WR", szDiffTime)
						show_dhudmessage(0, "%s Beat World Record!!!", name);
					}
					if (gochecknumbers[id] > 0)
					{
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1[^3-%s WR^1] %L: [^3%d^1/^3%d^1]", prefix, name, LANG_PLAYER, "KZ_CP_FINISH_MSG",  imin, isec, ims, szDiffTime, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id])
					}
				}
			}
			else 
			{
				new Float:sDiffTime = zClimbTime - DiffWRTime[0];
				new szDiffTime[16]
				WRTimer(sDiffTime, szDiffTime, sizeof(szDiffTime) - 1, true, false)
				if (wpn_15[id] && !user_has_weapon(id ,CSW_USP) || !user_has_weapon(id, CSW_KNIFE))
				{	
					ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L: [^3%d^1/^3%d^1] %L: ^3%s ^1[^3%d^1]", prefix, name, LANG_PLAYER, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], LANG_PLAYER, "KZ_WEAPON", g_weaponsnames[wpn],floatround( maxspeed, floatround_floor ))
				}
				else
				{
					if (gochecknumbers[id] == 0)
					{	
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L [^3+%s WR^1]", prefix, name, LANG_PLAYER, "KZ_FINISH_MSG",  imin, isec, ims, LANG_PLAYER, "KZ_BEAT_WR_NEED", szDiffTime)
					}
					if (gochecknumbers[id] > 0)
					{
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1[^3+%s WR^1] %L: [^3%d^1/^3%d^1]", prefix, name, LANG_PLAYER, "KZ_CP_FINISH_MSG",  imin, isec, ims, szDiffTime, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id])
					}
				}
			}
			set_task(1.5, "CmdSayWR", id)
		}
		else if (!g_iWorldRecordsNum)
		{
			show_finish_message(id, zClimbTime);
		}
	}
	else
	{
		if (kz_type_wr[id] == 2)
		{
			if (g_iNtRecordsNum > 0) 
			{

				for(new i = 0; i < num; i++)
				{
					new iminp = floatround(Pro_Times[i] / 60.0, floatround_floor)
					new isecp = floatround(Pro_Times[i]  - iminp * 60.0,floatround_floor)
					
					new iminz = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
					new isecz = floatround(Noob_Tiempos[i]  - iminz * 60.0,floatround_floor) 

					new oldminutes60 = (get_user_frags(id)*60)
					new oldtime = oldminutes60+cs_get_user_deaths(id)

					if(equal(Pro_AuthIDS[i], authid) || equal(Noob_AuthIDS[i], authid))
					{
						if (Pro_Times[i] < Noob_Tiempos[i])
						{
							set_user_frags(id, iminp)
							cs_set_user_deaths(id, isecp)
						}
								
						if(Pro_Times[i] > Noob_Tiempos[i])
						{
							set_user_frags(id, iminz)
							cs_set_user_deaths(id, isecz)
						}
					}
					else 	if (oldtime == 0)
					{
						set_user_frags(id, imin)
						cs_set_user_deaths(id, isec)
					}
				}
	
				if (zClimbTime < DiffNTRTime[0]) 
				{
					new Float:sDiffTime = DiffNTRTime[0] - zClimbTime;
					new szDiffTime[16]
					WRTimer(sDiffTime, szDiffTime, sizeof(szDiffTime) - 1, true, false)
					set_dhudmessage(255, 30, 30, -1.0, 0.2, 2, 0.1, 6.0, 0.02, 0.5);
					
					if (wpn_15[id] && !user_has_weapon(id ,CSW_USP) || !user_has_weapon(id, CSW_KNIFE))
					{	
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L: [^3%d^1/^3%d^1] %L: ^3%s ^1[^3%d^1]", prefix, name, LANG_PLAYER, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], LANG_PLAYER, "KZ_WEAPON", g_weaponsnames[wpn],floatround( maxspeed, floatround_floor ))
					}
					else
					{
						if (gochecknumbers[id] == 0)
						{	
							ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L [^3-%s NTR!!!^1]", prefix, name, LANG_PLAYER, "KZ_FINISH_MSG",  imin, isec, ims, LANG_PLAYER, "KZ_BEAT_CUR_NTR", szDiffTime)
							show_dhudmessage(0, "%s Beat NTjump Record!!!", name);
						}
						if (gochecknumbers[id] > 0)
						{
							ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1[^3-%s NTR^1] %L: [^3%d^1/^3%d^1]", prefix, name, LANG_PLAYER, "KZ_CP_FINISH_MSG",  imin, isec, ims, szDiffTime, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id])
						}
					}
				}
				else 
				{
					new Float:sDiffTime = zClimbTime - DiffNTRTime[0];
					new szDiffTime[16]
					WRTimer(sDiffTime, szDiffTime, sizeof(szDiffTime) - 1, true, false)
					if (wpn_15[id] && !user_has_weapon(id ,CSW_USP) || !user_has_weapon(id, CSW_KNIFE))
					{	
						ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L: [^3%d^1/^3%d^1] %L: ^3%s ^1[^3%d^1]", prefix, name, LANG_PLAYER, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], LANG_PLAYER, "KZ_WEAPON", g_weaponsnames[wpn],floatround( maxspeed, floatround_floor ))
					}
					else
					{
						if (gochecknumbers[id] == 0)
						{	
							ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1%L [^3+%s NTR^1].", prefix, name, LANG_PLAYER, "KZ_FINISH_MSG",  imin, isec, ims, LANG_PLAYER, "KZ_BEAT_NTR_NEED", szDiffTime)
						}
						if (gochecknumbers[id] > 0)
						{
							ColorChat(0, GREEN,  "^1%s ^3%s ^1%L ^3%02i:%02i.%02i ^1[^3+%s NTR^1] %L: [^3%d^1/^3%d^1]", prefix, name, LANG_PLAYER, "KZ_CP_FINISH_MSG",  imin, isec, ims, szDiffTime, LANG_PLAYER, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id])
						}
					}
				}
				// set_task(1.5, "CmdSayCR", id)
			}
			else if (!g_iNtRecordsNum)
			{
				show_finish_message(id, zClimbTime);
			}
		}
	}
	return PLUGIN_CONTINUE;
}

stock ExplodeString( p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter )
{
    new nIdx = 0, l = strlen(p_szInput)
    new nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter ))
    while( (nLen < l) && (++nIdx < p_nMax) )
        nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter ))
    return nIdx
}


//===========================================================
//						Use SQL
//===========================================================
#if defined USE_SQL
public Set_QueryHandler(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	new id = cData[0]
	new style = cData[1]
	if( iFailState != TQUERY_SUCCESS )
	{
		log_amx("[KZ] TOP15 SQL: SQL Error #%d - %s", iErrnum, szError)
		ColorChat(0, GREEN,  "%s^x01 %F", prefix, LANG_PLAYER, "KZ_TOP15_SQL_ERROR")
	}
	
	server_print("[KZ] Server Geting Info of SQL Server")
	
	new createinto[1001]
	new x1[16], x2[4], x3[5], x4[5]
	parse(cData[2], x1, 15, x2, 3, x3, 4, x4, 4)

	new dia[64], steam[32], name[32], ip[15], country[3], checkpoints[32], gochecks[32]
	new Float:newtime = str_to_float(x1)
	new iMin, iSec, iMs, server[64]
	get_pcvar_string(kz_sql_name, server, 63)
	get_time("%Y%m%d%H%M%S", dia, sizeof dia - 1) 
	get_user_authid(id, steam, 31)
	get_user_name(id, name, sizeof name - 1)
	get_user_ip (id, ip, sizeof ip - 1, 1)
	geoip_code2_ex( ip, country)
	
	replace_all(name, 31, "\", "")
	replace_all(name, 31, "`", "")
	replace_all(name, 31, "'", "")
	

	if( SQL_NumResults(hQuery) == 0 )
	{
		formatex(checkpoints, 31, ", '%d'", str_to_num(x3))
		formatex(gochecks, 31, ", '%d'", str_to_num(x4))
		formatex( createinto, sizeof createinto - 1, "INSERT INTO `%s` VALUES('%s', '%s','%s','%s','%f','%s','%s','%s'%s%s)", style == PRO_TOP ? "kz_pro15" : "kz_nub15", MapName, steam, country, name, newtime, dia, g_weaponsnames[str_to_num(x2)], server, style == PRO_TOP ? "" : checkpoints, style == PRO_TOP ? "" : gochecks)
		if (!is_user_bot (id))
		SQL_ThreadQuery(g_SqlTuple, "QueryHandle", createinto)
		GetNewRank(id, style)
	}
	else
	{
		new Float:oldtime, Float:thetime
		SQL_ReadResult(hQuery, 0, oldtime)
		
		if(newtime < oldtime)
		{
			thetime = oldtime - newtime
			iMin = floatround(thetime / 60.0, floatround_floor)
			iSec = floatround(thetime - iMin * 60.0,floatround_floor)
			iMs = floatround( ( thetime - ( iMin * 60.0 + iSec ) ) * 100.0, floatround_floor )
			ColorChat(id, GREEN,  "[KZ]^x01 %L^x03 %02i:%02i.%02i^x01 in ^x03%s", id, "KZ_IMPROVE", iMin, iSec, iMs, style == PRO_TOP ? "Pro 15" : "Noob 15")
			formatex(checkpoints, 31, ", checkpoints='%d'", str_to_num(x3))
			formatex(gochecks, 31, ", gocheck='%d'", str_to_num(x4))
			if(equal(steam, "VALVE_ID_LAN") || equal(steam, "STEAM_ID_LAN") || strlen(steam) > 18)
				formatex(createinto, sizeof createinto - 1, "UPDATE `%s` SET time='%f', weapon='%s', date='%s', server='%s'%s%s WHERE name='%s' AND mapname='%s'", style == PRO_TOP ? "kz_pro15" : "kz_nub15", newtime, g_weaponsnames[str_to_num(x2)],  dia, server, style == PRO_TOP ? "" : gochecks, style == PRO_TOP ? "" : checkpoints, name, MapName)
			else
				formatex(createinto, sizeof createinto - 1, "UPDATE `%s` SET time='%f', weapon='%s', date='%s', server='%s'%s%s WHERE authid='%s' AND mapname='%s'", style == PRO_TOP ? "kz_pro15" : "kz_nub15", newtime, g_weaponsnames[str_to_num(x2)],  dia, server, style == PRO_TOP ? "" : gochecks, style == PRO_TOP ? "" : checkpoints, steam, MapName)
	
			SQL_ThreadQuery(g_SqlTuple, "QueryHandle", createinto )
			GetNewRank(id, style)
		}
		else
		{
			thetime = newtime - oldtime
			iMin = floatround(thetime / 60.0, floatround_floor)
			iSec = floatround(thetime - iMin * 60.0,floatround_floor)
			iMs = floatround( ( thetime - ( iMin * 60.0 + iSec ) ) * 100.0, floatround_floor )
			ColorChat(id, GREEN,  "[KZ]^x01 %L^x03 %02i:%02i.%02i ^x01in ^x03%s", id, "KZ_SLOWER", iMin, iSec, iMs, style == PRO_TOP ? "Pro 15" : "Noob 15")
		}
	}
	
	return PLUGIN_CONTINUE
	
}

public GetNewRank_QueryHandler(iFailState, Handle:hQuery, szError[], iErrnum, cData[], iSize, Float:fQueueTime)
{
	new id = cData[0]
	if( iFailState != TQUERY_SUCCESS )
	{
		return log_amx("TOP15 SQL: SQL Error #%d - %s", iErrnum, szError)
	}
	
	new steam[32], authid[32], namez[32], name[32], i = 0
	get_user_authid(id, steam, 31)
	get_user_name(id, namez, 31)
	
	while( SQL_MoreResults(hQuery) )
	{
		i++
		if(equal(steam, "VALVE_ID_LAN") || equal(steam, "STEAM_ID_LAN") || strlen(steam) > 18)
		{
			SQL_ReadResult(hQuery, 0, name, 31)
			if( equal(name, namez) )
			{
				ColorChat(0, GREEN,  "%s^x03 %s^x01 %L ^x03%d^x01 in^x03 %s^x01",prefix, namez, LANG_PLAYER, "KZ_PLACE", i, cData[1] == PRO_TOP ? "Pro 100" : "Noob 100");
				break;
			}
		}
		else
		{
			SQL_ReadResult(hQuery, 0, authid, 31)
			if( equal(authid, steam) )
			{
				ColorChat(0, GREEN,  "%s^x03 %s^x01 %L ^x03%d^x01 in^x03 %s^x01",prefix, namez, LANG_PLAYER, "KZ_PLACE", i, cData[1] == PRO_TOP ? "Pro 100" : "Noob 100");
				break;
			}
		}
		SQL_NextRow(hQuery)
	}
	
	return PLUGIN_CONTINUE	
}

public ProTop_show(id)
{
	client_print(0, print_chat, "SQL ProTop_show");
	kz_showhtml_motd(id, PRO_TOP, MapName)
		
	return PLUGIN_HANDLED
}

public NoobTop_show(id)
{

	kz_showhtml_motd(id, NUB_TOP, MapName)
	
	return PLUGIN_HANDLED
}

public ProRecs_show(id)
{
	new authid[32]
	get_user_authid(id, authid, 31)

	if(equal(authid, "VALVE_ID_LAN") || equal(authid, "STEAM_ID_LAN") || strlen(authid) > 18)
	{
		ColorChat (id, GREEN, "%s^x01 %L", prefix, id, "KZ_NO_STEAM")
		return PLUGIN_HANDLED
	}

	kz_showhtml_motd(id, PRO_RECORDS, MapName)

	return PLUGIN_HANDLED
}

// 显示排行榜html type: 显示的排行榜类型 
stock kz_showhtml_motd(id, type, const map[])
{
	new buffer[1001], namebuffer[64], filepath[96]
	get_pcvar_string(kz_sql_files, filepath, 95)
	new authid[32]
	get_user_authid(id, authid, 31)
	
	switch( type )
	{
		case PRO_TOP:
		{
			formatex(namebuffer, 63, "Pro 15 of %s", equal(map, "") ? "All Maps" : map)
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/pro15.php?map=%s^"></head><body><p>LOADING...</p></body></html>", filepath, map)
		}
		case NUB_TOP:
		{
			formatex(namebuffer, 63, "Noob 15 of %s", equal(map, "") ? "All Maps" : map)
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/nub15.php?map=%s^"></head><body><p>LOADING...</p></body></html>", filepath, map)
		}
		case PRO_RECORDS:
		{
			formatex(namebuffer, 63, "ProRecords and Rank")
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/player.php?authid=%s^"></head><body><p>LOADING...</p></body></html>", filepath, authid)
		}
		case PLAYERS_RANKING:
		{
			formatex(namebuffer, 63, "Players Ranking")
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/players.php^"></head><body><p>LOADING...</p></body></html>", filepath, authid)
		}
		case LAST_PRO10:
		{
			formatex(namebuffer, 63, "Last 10 Pro Entries")
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/lastpro.php^"></head><body><p>LOADING...</p></body></html>", filepath)
		}
		case MAPS_STATISTIC:
		{
			formatex(namebuffer, 63, "Maps Statistic")
			formatex(buffer, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=http://%s/map.php^"></head><body><p>LOADING...</p></body></html>", filepath)
		}
	}
	
	show_motd(id, buffer, namebuffer)
}
#else

//======================================================
//						NONE SQL						
//======================================================

public ProTop_update(id, Float:time)
{
	new authid[32], name[32], thetime[32],ip[32], country[3], Float: slower, Float: faster, Float:protiempo
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d",thetime,31);
	get_user_ip(id, ip, 31);
	geoip_code2_ex(ip, country);
	new bool:Is_in_pro15
	Is_in_pro15 = false

	for(new i = 0; i < num; i++)	//num = 100
	{
		// 通过Name / id 来判断是否在top100上
		if( (equali(Pro_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Pro_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			Is_in_pro15 = true
			slower = time - Pro_Times[i]
			faster = Pro_Times[i] - time
			protiempo = Pro_Times[i]
		}
	}
	
	for (new i = 0; i < num; i++)
	{	
		if( time < Pro_Times[i])	// 玩家新的跳跃成绩比之前自己的成绩快 需要找到其在多少行
		{
			new pos = i
			if ( get_pcvar_num(kz_top15_authid) == 0 )
				while( !equal(Pro_Names[pos], name) && pos < num )
				{
					pos++;
				}
			else if ( get_pcvar_num(kz_top15_authid) == 1)
				while( !equal(Pro_AuthIDS[pos], authid) && pos < num )
				{
					pos++;
				}
			
			for (new j = pos; j > i; j--)
			{
				formatex(Pro_AuthIDS[j], 31, Pro_AuthIDS[j-1]);
				formatex(Pro_Names[j], 31, Pro_Names[j-1]);
				formatex(Pro_Country[j], 3, Pro_Country[j-1])
				formatex(Pro_Date[j], 31, Pro_Date[j-1])
				Pro_Times[j] = Pro_Times[j-1];
			}
			
			formatex(Pro_AuthIDS[i], 31, authid);
			formatex(Pro_Names[i], 31, name);
			formatex(Pro_Country[i], 3, country)
			formatex(Pro_Date[i], 31, thetime)
			Pro_Times[i] = time
			
			save_pro15()
			
			if( Is_in_pro15 )	//完成时 原本就在pro15中
			{
				if (!is_user_bot (id))
					
				if( time < protiempo )
				{
					new min, Float:sec;
					min = floatround(faster, floatround_floor)/60;
					sec = faster - (60*min);
					ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_IMPROVE", min, sec < 10 ? "0" : "", sec);
				
					if( (i + 1) == 1)	// i==0
					{
						if( time < DiffWRTime[0])
						{
							client_cmd(0, "spk misc/mod_godlike");
						}
						else
						{
							client_cmd(0, "spk kzsound/toprec");
						}
						// ################################################
						// # 需要修的BUG: 1 BOT计时每次循环后不清空 2 多次按下计时器时不会重置保存的数据 3 暂停无法暂停状态的记录(√)
						if (REC_AC[id])
						{
							if (g_bestruntime < Pro_Times[id])
							{
								client_print(0, 2, "REC %f UPDATE %f", g_bestruntime, time);
								ClCmd_UpdateReplay(id, time);
							}
						}

						ColorChat(0, RED,  "^x01%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x03Professional^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
					}
					else
					{
						client_cmd(0, "spk buttons/bell1");
						ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x03Pro 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
					}
				}	
			}
			else
			{
				if( (i + 1) == 1) 
				{
					// ##SR
					if (REC_AC[id])
					{
						ClCmd_UpdateReplay(id, time);
					}
					client_cmd(0, "spk kzsound/toprec");
					ColorChat(0, RED,  "^x01%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x03Professional^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
				}
				else // 非SR
				{
					client_cmd(0, "spk buttons/bell1");
					ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Pro 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
				}
			}
			
			return;
		}

		if( (equali(Pro_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Pro_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			if( time > protiempo )
			{
				new min, Float:sec;
				min = floatround(slower, floatround_floor)/60;
				sec = slower - (60*min);
				client_cmd(0, "spk fvox/bell");
				ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_SLOWER", min, sec < 10 ? "0" : "", sec);
				return;
			}
		}
		
	}
}

public save_pro15()
{

	new profile[128]
	formatex(profile, 127, "%s/pro_%s.cfg", Topdir, MapName)
	
	if( file_exists(profile) )
	{
		delete_file(profile)
	}
   
	new Data[256];
	new f = fopen(profile, "at")
	
	for(new i = 0; i < num; i++)
	{
		formatex(Data, 255, "^"%.2f^"   ^"%s^" ^"%s^"   ^"%s^"   ^"%s^"^n", Pro_Times[i],Pro_Country[i], Pro_AuthIDS[i], Pro_Names[i], Pro_Date[i])
		// server_print("%s", Data);
		fputs(f, Data)
	}
	fclose(f);
}

public read_pro15()
{
	new profile[128], prodata[256]
	formatex(profile, 127, "%s/pro_%s.cfg", Topdir, MapName)
	
	new f = fopen(profile, "rt" )
	new i = 0
	while( !feof(f) && i < num + 1)
	{
		fgets(f, prodata, 255)
		new totime[25]
		parse(prodata, totime, 24, Pro_Country[i], 3, Pro_AuthIDS[i], 31, Pro_Names[i], 31, Pro_Date[i], 31)
		Pro_Times[i] = str_to_float(totime)
		i++;
	}
	fclose(f)
}

//==================================================================================================

public NoobTop_update(id, Float:time, checkpoints, gochecks) 
{
	new authid[32], name[32], thetime[32], wpn,ip[32], country[3], Float: slower, Float: faster, Float:noobtiempo
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d",thetime,31);
	get_user_ip(id, ip, 31);
	geoip_code2_ex(ip, country);
	new bool:Is_in_noob15 = false
	
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon(id)
	
	for(new i = 0; i < num; i++)
	{
		if( (equali(Noob_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Noob_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			Is_in_noob15 = true
			slower = time - Noob_Tiempos[i];
			faster = Noob_Tiempos[i] - time;
			noobtiempo = Noob_Tiempos[i]
		}
	}
	
	for (new i = 0; i < num; i++)
	{
		if( time < Noob_Tiempos[i])
		{
			new pos = i
			
			if ( get_pcvar_num(kz_top15_authid) == 0 )
				while( !equal(Noob_Names[pos], name) && pos < num )
				{
					pos++;
				}
			else if ( get_pcvar_num(kz_top15_authid) == 1)
				while( !equal(Noob_AuthIDS[pos], authid) && pos < num )
				{
					pos++;
				}
			
			for (new j = pos; j > i; j--)
			{
				formatex(Noob_AuthIDS[j], 31, Noob_AuthIDS[j-1])
				formatex(Noob_Names[j], 31, Noob_Names[j-1])
				formatex(Noob_Date[j], 31, Noob_Date[j-1])
				formatex(Noob_Weapon[j], 31, Noob_Weapon[j-1])
				formatex(Noob_Country[j], 3, Noob_Country[j-1])
				Noob_Tiempos[j] = Noob_Tiempos[j-1]
				Noob_CheckPoints[j] = Noob_CheckPoints[j-1]
				Noob_GoChecks[j] = Noob_GoChecks[j-1]	
			}
			
			formatex(Noob_AuthIDS[i], 31, authid);
			formatex(Noob_Names[i], 31, name);
			formatex(Noob_Date[i], 31, thetime)
			formatex(Noob_Weapon[i], 31, g_weaponsnames[wpn])
			formatex(Noob_Country[i], 3, country)
			Noob_Tiempos[i] = time
			Noob_CheckPoints[i] = checkpoints
			Noob_GoChecks[i] = gochecks
			
			save_Noob15()
			
			if( Is_in_noob15 )
			{

				if( time < noobtiempo )
				{
					new min, Float:sec;
					min = floatround(faster, floatround_floor)/60;
					sec = faster - (60*min);
					ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_IMPROVE", min, sec < 10 ? "0" : "", sec);
				
					if( (i + 1) == 1)
					{
						if (REC_AC[id])
						{
							if (gc_bestruntime < Noob_Tiempos[id])
							{
								client_print(0, 2, "NUB %f UPDATE %f", gc_bestruntime, time);
								ClCmd_UpdateReplay_c(id, time);
							}
						}
						client_cmd(0, "spk woop");
						ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Noob 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
					}
					else
					{
						client_cmd(0, "spk buttons/bell1");
						ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Noob 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
					}
				}	
			}
			else
			{
				if( (i + 1) == 1)
				{
					if (REC_AC[id])
					{
						ClCmd_UpdateReplay_c(id, time);
					}
					client_cmd(0, "spk woop");
					ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Noob 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
				}
				else
				{
					client_cmd(0, "spk buttons/bell1");
					ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Noob 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
				}
			}
			return;
		}

		if( (equali(Noob_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Noob_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			if( time > noobtiempo )
			{
				
				new min, Float:sec;
				min = floatround(slower, floatround_floor)/60;
				sec = slower - (60*min);
				client_cmd(0, "spk fvox/bell");
				ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_SLOWER", min, sec < 10 ? "0" : "", sec);
				return;
			}
		}
		
	}
}

public save_Noob15()
{
	new profile[128]
	formatex(profile, 127, "%s/Noob_%s.cfg", Topdir, MapName)
	
	if( file_exists(profile) )
	{
		delete_file(profile)
	}
   
	new Data[256];
	new f = fopen(profile, "at")
	
	for(new i = 0; i < num; i++)
	{
		formatex(Data, 255, "^"%.2f^"  ^"%s^"  ^"%s^"   ^"%s^"   ^"%i^"   ^"%i^"   ^"%s^"  ^"%s^" ^n", Noob_Tiempos[i],Noob_Country[i], Noob_AuthIDS[i], Noob_Names[i], Noob_CheckPoints[i], Noob_GoChecks[i],Noob_Date[i],Noob_Weapon[i])
		fputs(f, Data)
	}
	fclose(f);
}

public read_Noob15()
{
	new profile[128], prodata[256]
	formatex(profile, 127, "%s/Noob_%s.cfg", Topdir, MapName)
	
	new f = fopen(profile, "rt" )
	new i = 0
	while( !feof(f) && i < num + 1)
	{
		fgets(f, prodata, 255)
		new totime[25], checks[5], gochecks[5]
		parse(prodata, totime, 24, Noob_Country[i], 3, Noob_AuthIDS[i], 31, Noob_Names[i], 31,  checks, 4, gochecks, 4, Noob_Date[i], 31, Noob_Weapon[i], 31)
		Noob_Tiempos[i] = str_to_float(totime)
		Noob_CheckPoints[i] = str_to_num(checks)
		Noob_GoChecks[i] = str_to_num(gochecks)
		i++;
	}
	fclose(f)
}

public WpnTop_update(id, Float:time, checkpoints, gochecks, maxspeed) 
{
	new authid[32], name[32], thetime[32], wpn, ip[32], country[3], Float: slower, Float: faster, Float:wpntiempo,wpnspeedz
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d",thetime,31);
	get_user_ip(id, ip, 31);
	geoip_code2_ex(ip, country);
	new bool:Is_in_wpn15
	Is_in_wpn15 = false
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon(id)
	
	for(new i = 0; i < num; i++)
	{
		if( (equali(Wpn_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Wpn_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			Is_in_wpn15 = true
			slower = time - Wpn_Timepos[i];
			faster = Wpn_Timepos[i] - time;
			wpntiempo = Wpn_Timepos[i]
			wpnspeedz = Wpn_maxspeed[i]
		}
	}
	
	for (new i = 0; i < num; i++)
	{
		if( maxspeed < Wpn_maxspeed[i])//武器
		{
			new pos = i
			
			if ( get_pcvar_num(kz_top15_authid) == 0 )
				while( !equal(Wpn_Names[pos], name) && pos < num )
				{
					pos++;
				}
			else if ( get_pcvar_num(kz_top15_authid) == 1)
				while( !equal(Wpn_AuthIDS[pos], authid) && pos < num )
				{
					pos++;
				}
			
			for (new j = pos; j > i; j--)
			{
				formatex(Wpn_AuthIDS[j], 31, Wpn_AuthIDS[j-1])
				formatex(Wpn_Names[j], 31, Wpn_Names[j-1])
				formatex(Wpn_Date[j], 31, Wpn_Date[j-1])
				formatex(Wpn_Weapon[j], 31, Wpn_Weapon[j-1])
				formatex(Wpn_Country[j], 3, Wpn_Country[j-1])
				Wpn_maxspeed[j] = Wpn_maxspeed[j-1]
				Wpn_Timepos[j] = Wpn_Timepos[j-1]
				Wpn_CheckPoints[j] = Wpn_CheckPoints[j-1]
				Wpn_GoChecks[j] = Wpn_GoChecks[j-1]	
			}
			
			formatex(Wpn_AuthIDS[i], 31, authid);
			formatex(Wpn_Names[i], 31, name);
			formatex(Wpn_Date[i], 31, thetime)
			formatex(Wpn_Weapon[i], 31, g_weaponsnames[wpn])
			formatex(Wpn_Country[i], 3, country)
			Wpn_maxspeed[i] = maxspeed
			Wpn_Timepos[i] = time
			Wpn_CheckPoints[i] = checkpoints
			Wpn_GoChecks[i] = gochecks
			
			save_Wpn15()
			
			if( Is_in_wpn15 )
			{

				if( maxspeed < wpnspeedz )
				{
					if( (i + 1) == 1)
					{
						client_cmd(0, "spk woop");
						ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
					}
					else
					{
						client_cmd(0, "spk buttons/bell1");
						ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
					}
				}	
			}
			else
			{
				if( (i + 1) == 1)
				{
					client_cmd(0, "spk woop");
					ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
				}
				else
				{
					client_cmd(0, "spk buttons/bell1");
					ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
				}
			}
			return;
		}
		else
		if( maxspeed == Wpn_maxspeed[i])//时间
		{
			if( time < Wpn_Timepos[i])
			{
				new pos = i
			
				if ( get_pcvar_num(kz_top15_authid) == 0 )
					while( !equal(Wpn_Names[pos], name) && pos < num )
					{
						pos++;
					}
				else if ( get_pcvar_num(kz_top15_authid) == 1)
					while( !equal(Wpn_AuthIDS[pos], authid) && pos < num )
					{
						pos++;
					}
			
				for (new j = pos; j > i; j--)
				{
					formatex(Wpn_AuthIDS[j], 31, Wpn_AuthIDS[j-1])
					formatex(Wpn_Names[j], 31, Wpn_Names[j-1])
					formatex(Wpn_Date[j], 31, Wpn_Date[j-1])
					formatex(Wpn_Weapon[j], 31, Wpn_Weapon[j-1])
					formatex(Wpn_Country[j], 3, Wpn_Country[j-1])
					Wpn_maxspeed[j] = Wpn_maxspeed[j-1]
					Wpn_Timepos[j] = Wpn_Timepos[j-1]
					Wpn_CheckPoints[j] = Wpn_CheckPoints[j-1]
					Wpn_GoChecks[j] = Wpn_GoChecks[j-1]	
				}
			
				formatex(Wpn_AuthIDS[i], 31, authid);
				formatex(Wpn_Names[i], 31, name);
				formatex(Wpn_Date[i], 31, thetime)
				formatex(Wpn_Weapon[i], 31, g_weaponsnames[wpn])
				formatex(Wpn_Country[i], 3, country)
				Wpn_maxspeed[i] = maxspeed
				Wpn_Timepos[i] = time
				Wpn_CheckPoints[i] = checkpoints
				Wpn_GoChecks[i] = gochecks
			
				save_Wpn15()
			
				if( Is_in_wpn15 )
				{

					if( time < wpntiempo )
					{
						new min, Float:sec;
						min = floatround(faster, floatround_floor)/60;
						sec = faster - (60*min);
						ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_IMPROVE", min, sec < 10 ? "0" : "", sec);
					
						if( (i + 1) == 1)
						{
							client_cmd(0, "spk woop");
							ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
						}
						else
						{
							client_cmd(0, "spk buttons/bell1");
							ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
						}
					}	
				}
				else
				{
					if( (i + 1) == 1)
					{
						client_cmd(0, "spk woop");
						ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
					}
					else
					{
						client_cmd(0, "spk buttons/bell1");
						ColorChat(0, GREEN,  "%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Weapon 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));
					}
				}
				return;
			}
		}

		if( (equali(Wpn_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Wpn_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			if( maxspeed > wpnspeedz )
			{
				
				new min, Float:sec;
				min = floatround(slower, floatround_floor)/60;
				sec = slower - (60*min);
				client_cmd(0, "spk fvox/bell");
				ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_SLOWER", min, sec < 10 ? "0" : "", sec);
				return;
			}
			else
			if( time > wpntiempo )
			{
				
				new min, Float:sec;
				min = floatround(slower, floatround_floor)/60;
				sec = slower - (60*min);
				client_cmd(0, "spk fvox/bell");
				ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_SLOWER", min, sec < 10 ? "0" : "", sec);
				return;
			}
		}
		
	}
}


public save_Wpn15()
{
	new profile[128]
	formatex(profile, 127, "%s/Wpn_%s.cfg", Topdir, MapName)
	
	if( file_exists(profile) )
	{
		delete_file(profile)
	}
   
	new Data[256];
	new f = fopen(profile, "at")
	
	for(new i = 0; i < num; i++)
	{
		formatex(Data, 255, "^"%.2f^" ^"%i^" ^"%s^" ^"%s^"   ^"%s^"   ^"%i^"   ^"%i^"   ^"%s^"  ^"%s^" ^n", Wpn_Timepos[i], Wpn_maxspeed[i], Wpn_Country[i], Wpn_AuthIDS[i], Wpn_Names[i], Wpn_CheckPoints[i], Wpn_GoChecks[i],Wpn_Date[i],Wpn_Weapon[i])
		fputs(f, Data)
	}
	fclose(f);
}

public read_Wpn15()
{
	new profile[128], prodata[256]
	formatex(profile, 127, "%s/Wpn_%s.cfg", Topdir, MapName)
	
	new f = fopen(profile, "rt" )
	new i = 0
	while( !feof(f) && i < num + 1)
	{
		fgets(f, prodata, 255)
		new totime[25], checks[5], gochecks[5],wpnspeed[11]
		parse(prodata, totime, 24, wpnspeed, 10, Wpn_Country[i], 3, Wpn_AuthIDS[i], 31, Wpn_Names[i], 31,  checks, 4, gochecks, 4, Wpn_Date[i], 31, Wpn_Weapon[i], 31)
		Wpn_Timepos[i] = str_to_float(totime)
		Wpn_CheckPoints[i] = str_to_num(checks)
		Wpn_GoChecks[i] = str_to_num(gochecks)
		Wpn_maxspeed[i] = str_to_num(wpnspeed)
		i++;
	}
	fclose(f)
}

// #MARK: NOSQL ProTop_show	WEB_URL = "addons/amxmodx/configs/kz"
public ProTop_show(id)
{		
	// client_print(0, print_chat, "NoSQL ProTop_show");
	new fh = fopen( PRO_PATH, "w" )
	fprintf( fh, "<meta charset=UTF-8>" )
	fprintf( fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>",WEB_URL )
	// client_print(0, print_chat, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>", WEB_URL);

	fprintf( fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Time <th width=10%%> To WR <th width=10%%> Date ")
	
	new line[501],btime_str[4],ctime_str[65],name[33],imgs[100],Float:difftime,wrdiff[65]//,String:sComm[32];
	new arrow_up[100],arrow_down[100],arrow_multiway[100]
	
	// 每一行 读取top100数据 并动态生成网页内容
	for (new i = 0; i < 100; i++) 
	{		
		name = Pro_Names[i]

		if( Pro_Times[i] > 9999999.0 )
		{
			formatex( line, 125,"%s%s%s%s%s%s%s","","","","","","","","")
			fprintf( fh, line )
		}
		else
		{
			if (Pro_Times[i] < DiffWRTime[0]) 
			{	
				// format(arrow_up, 99, "<img src=%s/images/arrow_up.png>" ,WEB_URL)
				// 因为href设置后默认就在kz文件夹 故不需要WEB_URL 否则
				// 否则file:///D:/Games/Steam/steamapps/common/Half-Life/cstrike/addons/amxmodx/configs/kz/addons/amxmodx/configs/kz/flags/CN.png
				format(arrow_up, 99, "<img src = images/arrow_up.png>")
				imgs = arrow_up;
				difftime = DiffWRTime[0]-Pro_Times[i];
			}
			else if (Pro_Times[i] > DiffWRTime[0]) 
			{
				// format(arrow_down, 99, "<img src=%s/images/arrow_down.png>" ,WEB_URL)
				format(arrow_down, 99, "<img src = images/arrow_down.png>")
				
				imgs = arrow_down;
				difftime = Pro_Times[i]-DiffWRTime[0];
			}
			else if (Pro_Times[i] == DiffWRTime[0]) 
			{
				// format(arrow_multiway, 99, "<img src=%s/images/arrow_multiway.png>" ,WEB_URL)
				format(arrow_multiway, 99, "<img src = images/arrow_multiway.png>")
				
				imgs = arrow_multiway;
				difftime = 0.00;
			}
			
			new imin,isec,ims

			imin = floatround(Pro_Times[i] / 60.0, floatround_floor)
			isec = floatround(Pro_Times[i] - imin * 60.0,floatround_floor)
			ims = floatround( ( Pro_Times[i] - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )
			
			new iMinutes,iSeconds,iMiliSeconds
			
			iMinutes = floatround(difftime / 60, floatround_floor)
			iSeconds = floatround(difftime - (iMinutes * 60), floatround_floor)
			iMiliSeconds = floatround( ( difftime - ( iMinutes * 60 + iSeconds ) ) * 100, floatround_round )

			format( btime_str, 3, "%d",(i+1))	//序号
			format( ctime_str, 64, "%02i:%02i.<font color=#FF0004>%02i</font>",imin, isec, ims)	//记录	#FF0004 红色
			format( wrdiff, 64, "%02d:%02d.<font color=#FF0004>%02d</font>",iMinutes,iSeconds,iMiliSeconds)	//和WR相差
			

			if (g_iWorldRecordsNum > 0)
			{
				// formatex( line, 500,"<tr %s><td>%s<td><img src=%s/flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td>%s<td>%s%s<td>%s",
				// i % 2 ? "bgcolor=#000000" : NULLSTR ,
				// btime_str,
				// WEB_URL,
				// Pro_Country[i],
				// htmlspecialchars(name),
				// ctime_str,
				// wrdiff,
				// imgs,
				// Pro_Date[i]
				// )
				formatex( line, 500,"<tr %s><td>%s<td><img src = flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td>%s<td>%s%s<td>%s",
				i % 2 ? "bgcolor=#000000" : NULLSTR ,
				btime_str,
				Pro_Country[i],
				htmlspecialchars(name),
				ctime_str,
				wrdiff,
				imgs,
				Pro_Date[i]
				)
			}
			else
			{
				// formatex( line, 500,"<tr %s><td>%s<td><img src=%s/flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td>%s<td>**.**.**<td>%s",
				// i % 2 ? "bgcolor=#000000" : NULLSTR ,
				// btime_str,
				// WEB_URL,
				// Pro_Country[i],
				// htmlspecialchars(name),
				// ctime_str,
				// Pro_Date[i]
				// )
				formatex( line, 500,"<tr %s><td>%s<td><img src = flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td>%s<td>**.**.**<td>%s",
				i % 2 ? "bgcolor=#000000" : NULLSTR ,
				btime_str,
				Pro_Country[i],
				htmlspecialchars(name),
				ctime_str,
				Pro_Date[i]
				)
			}
			fprintf( fh, line )		
		}
	}
	 
	new MotdName[128]
	formatex(MotdName,127,"Pro Stats of %s", MapName)
	

	fprintf( fh, "</td></tr><tr id=d><td></td></tr><tr id=a>" )
	fprintf( fh, "<div align=center><f>%s</div>",WRTime)
	fclose( fh )
	new PRO_PATHs[1001]
	formatex(PRO_PATHs, 1000,"<html><head><meta http-equiv=^"Refresh^" content=^"0;url=%s/pro_top.html^"></head><body><p>LOADING...</p></body></html>",WEB_URL)
	client_print(id, 2, "Before show_motd");
	client_print(id, 2, "%s", PRO_PATHs);
	show_motd( id, PRO_PATHs, MotdName )

	return PLUGIN_HANDLED
}

public NoobTop_show(id)
{
	new fh = fopen( NUB_PATH, "w" )
	fprintf( fh, "<meta charset=UTF-8>" )
	fprintf( fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>",WEB_URL )
	fprintf( fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Time <th width=10%%> CPs/TPs <th width=10%%> Date ")
	
	new line[501],btime_str[4],ctime_str[50],name[33]
		
	for (new i = 0; i < 100; i++) 
	{		
		name = Noob_Names[i]
		
		if( Noob_Tiempos[i] > 9999999.0 ) 
		{
			formatex( line, 125,"%s%s%s%s%s%s%s","","","","","","","","")
			fprintf( fh, line )
		}
		else
		{
			new imin,isec,ims

			imin = floatround(Noob_Tiempos[i] / 60.0, floatround_floor)
			isec = floatround(Noob_Tiempos[i] - imin * 60.0,floatround_floor)
			ims = floatround( (Noob_Tiempos[i] - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )
			
			format( btime_str, 3, "%d",(i+1))
			format( ctime_str, 64, "%02i:%02i.<font color=#FF0004>%02i</font>",imin, isec, ims)
			
			formatex( line, 500,"<tr %s><td>%s<td><img src=%s/flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td>%s<td>%d/%d<td>%s",
			i % 2 ? NULLSTR : "bgcolor=#000000",
			btime_str,
			WEB_URL,
			Noob_Country[i],
			htmlspecialchars(name),
			ctime_str,
			Noob_CheckPoints[i],
			Noob_GoChecks[i],
			Noob_Date[i]
			)
			fprintf( fh, line )		
		}
	}
	
	new MotdName[128]
	formatex(MotdName,127,"Nub Stats of %s",MapName)
	

	fprintf( fh, "</td></tr><tr id=d><td></td></tr><tr id=a>" )
	fprintf( fh, "<div align=center><f>%s</div>",WRTime)
	fclose( fh )
	new NUB_PATHs[1001]
	formatex(NUB_PATHs, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=%s/nub_top.html^"></head><body><p>LOADING...</p></body></html>",WEB_URL)
	show_motd( id, NUB_PATHs, MotdName )

	return PLUGIN_HANDLED
}

public WpnTop_show(id)
{
	new fh = fopen( WPN_PATH, "w" )
	fprintf( fh, "<meta charset=UTF-8>" )
	fprintf( fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>",WEB_URL )
	fprintf( fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Wpn/Speed <th width=10%%> Time <th width=10%%> CPs/TPs <th width=10%%> Date ")
	// fprintf( fh, "<tr id=b><td><td><td><td><td><td>" )
	
	new line[501],btime_str[4],ctime_str[50],name[33]
		
	for (new i = 0; i < 100; i++) 
	{		
		name = Wpn_Names[i]
		
		if( Wpn_Timepos[i] > 9999999.0 ) 
		{
			formatex( line, 125,"%s%s%s%s%s%s%s","","","","","","","","","")
			fprintf( fh, line )
		}
		else
		{
			new imin,isec,ims

			imin = floatround(Wpn_Timepos[i] / 60.0, floatround_floor)
			isec = floatround(Wpn_Timepos[i] - imin * 60.0,floatround_floor)
			ims = floatround( (Wpn_Timepos[i] - ( imin * 60.0 + isec ) ) * 100.0, floatround_round )
			
			format( btime_str, 3, "%d",(i+1))
			format( ctime_str, 64, "%02i:%02i.<font color=#FF0004>%02i</font>",imin, isec, ims)
			
			formatex( line, 500,"<tr %s><td>%s<td><img src=%s/flags/%s.png align=absmiddle height=32 width=32> <b>%s</b><td><img src=%s/images/weapon/%s.gif align=absmiddle height=32 width=32>[%d]<td>%s<td>%d/%d<td>%s",
			i % 2 ? NULLSTR : "bgcolor=#000000",
			btime_str,
			WEB_URL,
			Wpn_Country[i],
			htmlspecialchars(name),
			WEB_URL,
			Wpn_Weapon[i],
			Wpn_maxspeed[i],
			ctime_str,
			Wpn_CheckPoints[i],
			Wpn_GoChecks[i],
			Wpn_Date[i]
			)
			fprintf( fh, line )		
		}
	}
	
	new MotdName[128]
	formatex(MotdName,127,"Wpn Stats of %s",MapName)
	

	fprintf( fh, "</td></tr><tr id=d><td></td></tr><tr id=a>" )
	// fprintf( fh, "<td><b>Map</td><td><font color=#585858>%s</font></b></td><td></td><td></td><td></td><td></td><td></td></tr></table>",MapName)
	fprintf( fh, "<div align=center><f>%s</div>",WRTime)
	fclose( fh )
	new WPN_PATHs[1001]
	formatex(WPN_PATHs, 1000, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=%s/wpn_top.html^"></head><body><p>LOADING...</p></body></html>",WEB_URL)
	show_motd( id, WPN_PATHs, MotdName )

	return PLUGIN_HANDLED
}
#endif

stock is_user_localhost(id) 
{
	new szIP[16];
	get_user_ip(id, szIP, sizeof(szIP) - 1, 1);
	
	if(equal(szIP, "loopback") || equal(szIP, "127.0.0.1")) 
	{
		return true;
	}
	return false;
}

// Plugin Start 2.31Ver by nucLeaR
// Last edit by Perfectslife 
// 2021/11/16 edit by Azuki daisuki~