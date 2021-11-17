/* AMXX - amx_lights
*
* Copyright 2004, Written by Rattler
* This file is provided as is (absolutely no warranties)
*
* Change Logs
* v1.3 - Bug Fix - Light levels not constant throughout MapChanges/New Player Connects
* v1.2 - Released - Added Admin Check
* v1.1 - Added [off] or [OFF] commands
* v1.0 - Actually worked
*
* Commands
* ====================
* amx_lights <a through z>		-- Sets the light level
* amx_lights off or OFF			-- Normal light level
*
*
* Requirements
* ====================
* The following modules are required
*
* [amxmodx.inc]
* [engine.inc]
* [amxmisc.inc]
*
*
*/

// Declare Commands
//====================

#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <colorchat>

new lightLevel[][] = {"z", "g", "0", "m"};
new lightLevelZH[][] = {"增强", "减弱", "高亮", "默认"};
new playerLight[33];

// Check/Set Server Light Level when Connecting => change to default light
//====================
public client_putinserver(id)
{
	// new cmdarg[32]
	// get_vaultdata("amx_lights",cmdarg,31)
	// set_lights(cmdarg)
	playerLight[ id ] = 0;
	return PLUGIN_CONTINUE
}

// // Set Map Light Level
// //====================
// public admin_lights(id,level,cid)
// {
// 	if (!cmd_access(id,level,cid,2))
// 		return PLUGIN_HANDLED
	
// 	new cmdarg[32]
// 	read_argv(1,cmdarg,31)
	
// 	if (equal(cmdarg,"off")||equal(cmdarg,"OFF")){
// 		set_lights("#OFF")
// 		set_vaultdata("amx_lights","#OFF")
// 		console_print(id,"[AMXX] Light Returned To Normal.")
// 	}
// 	else{
// 		set_lights(cmdarg)
// 		set_vaultdata("amx_lights",cmdarg)
// 		console_print(id,"[AMXX] Light Change Successful.")
// 	}
// 	return PLUGIN_HANDLED
// }


// Set Player Client Light Level
//====================
public set_player_light(id, const LightStyle[])
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id);
	write_byte(0);
	write_string(LightStyle);
	message_end();
	// console_print(id,"[AMXX] Light Change to %s", LightStyle);
}

public clientLightChange(id) {
	set_player_light(id, lightLevel[ playerLight[id] ]);
// native set_hudmessage(red=200, green=100, blue=0, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2,channel=4);

	set_hudmessage(255, 140, 0, -1.0, 0.90, 0, 7.0, 1.5, 0.01, 0.01, -1);
	ShowSyncHudMsg(id, CreateHudSyncObj(), "地图加亮模式: #%s", lightLevelZH[ playerLight[id] ]);
	++playerLight[id];
	playerLight[id] %= 4;

}
// Declare Commands
//====================
public plugin_init()
{
	register_plugin("Better Nightvision","1.0","Azuki dasuki~")
	// register_concmd("amx_lights","admin_lights",ADMIN_CVAR,"[a-z] - Light level | [off] - Normal Lights")
	register_clcmd("say /n", "clientLightChange");
	// set_task(600.0, "taskPrintInfo", 0, _, _, "b");
}

public taskPrintInfo() {
    ColorChat(0, GREEN,  "[Holo]^x01输入 ^x03/n ^x01可^x03加亮地图^x01,帧数更加稳定!输入 ^x03/rp ^x01进行^x03举报~");
    // client_print(0, print_chat, "如果发现有玩家作弊或者SR异常,输入/rp进行举报,感谢支持!");
}