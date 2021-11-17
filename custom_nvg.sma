/*
	Custom NightVision Color
   
	Version : 0.3
	Author : SAMURAI
	
	
	Plugin Details:
 With this plugin enabled on your server, you will have posibility to change the Nightvision color.
Sure, that you will be choose by a cvar

	Cvars:
	
- custom_nvg - Enable/Disable the plugin
1 = Enabled (default)
2 = Disabled 

- custom_nvg_rgb - Set the color of Nightvision, in RGB format
Default : "255 0 255"

- custom_nvg_decay - Set the decay rate of light
Default = 10

- custom_nvg_radius - Set the radius of light from Nightvision
Default = 125

- custom_nvg_life - Set the life of the light
Default = 1




	Required Modules:
- Cstrike


	Credits:
- regalis for a suggestion to make plugin in another way because light doesen't worked perfect
- Alka for an example to check if an user have alearly an NVG 
	
	Changelog:
 0.1 -> 0.2
 - Fixed bug when start round it's start NVG Toggle
 - Changed the type of message from TE_DLIGHT 

 0.2 - 0.3
 - Added a new cvar: "custom_nvg_life" for change the life of light
 - Fixed a little bug on user origin
 - Fixed a bug on client disconnect
 
 
Have a nice day now
*/


#include <amxmodx>
#include <cstrike>


new const g_PLUGIN[] = "Custom NVG Color"
new const g_VERSION[] = "0.3"
new const g_AUTHOR[] = "SAMURAI"

#define g_ALPHA 150

new bool:NightVisionUse[33]
new gmsgFade 

new pnable, pcolor, pnumdecay, pnumradius, pnumlife;

public plugin_init() 
{
	register_plugin(g_PLUGIN,g_VERSION,g_AUTHOR);
	
	register_concmd("nightvisions","ToggleNVG")
	
	pnable = register_cvar("custom_nvg","1");
	pcolor = register_cvar("custom_nvg_rgb","255 0 255");
	pnumdecay = register_cvar("custom_nvg_decay","10");
	pnumradius = register_cvar("custom_nvg_radius","125");
	pnumlife = register_cvar("custom_nvg_life","1");
	
	register_event("ResetHUD","ev_new_round","be");
	gmsgFade = get_user_msgid("ScreenFade");
}

public client_putinserver(id)
{
	NightVisionUse[id] = false;
}


public client_disconnect(id)
{
	if (!id) return PLUGIN_CONTINUE;
	
	if (NightVisionUse[id]) StopNVG(id) 

	return PLUGIN_CONTINUE;
}


public ToggleNVG(id) 
{ 
	
   if(get_pcvar_num(pnable) == 0)
   return PLUGIN_CONTINUE;
   // client_print(id, print_chat, "NightVisionUse is %d, cs_get_user_nvg is %d", NightVisionUse[id], cs_get_user_nvg(id));
   if ( (NightVisionUse[id])) StopNVG(id) 
   else StartNVG(id) 
   return PLUGIN_HANDLED; 
} 

public StartNVG(id) 
{ 
   client_print(id, print_chat, "StartNVG");
   emit_sound(id,CHAN_ITEM,"items/nvg_on.wav",1.0,ATTN_NORM,0,PITCH_NORM) 

   set_task(0.1,"RunNVG",id+111111,_,_,"b") 
   set_task(0.1,"RunNVG2",id+222222,_,_,"b") 

   NightVisionUse[id] = true; 

   return PLUGIN_HANDLED;
} 


public StopNVG(id) 
{ 
   client_print(id, print_chat, "StopNVG");
   emit_sound(id,CHAN_ITEM,"items/nvg_off.wav",1.0,ATTN_NORM,0,PITCH_NORM) 

   remove_task(id+111111) 
   remove_task(id+222222) 
   
   NightVisionUse[id] = false; 

   return PLUGIN_HANDLED;
} 


public RunNVG(taskid) 
{ 
   new id = taskid - 111111
  
   if (!is_user_alive(id)) return
   
   new origin[3] 
   get_user_origin(id,origin,3)
   
   new color[17];
   get_pcvar_string(pcolor,color,16);
   
   new iRed[5], iGreen[7], iBlue[5]
   parse(color,iRed,4,iGreen,6,iBlue,4)
   
   // start the message
   message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},id) 

   write_byte(TE_DLIGHT) // 27

   write_coord(origin[0]) 
   write_coord(origin[1]) 
   write_coord(origin[2]) 

   write_byte(get_pcvar_num(pnumradius)) // radius

   write_byte(str_to_num(iRed))    // r
   write_byte(str_to_num(iGreen))  // g
   write_byte(str_to_num(iBlue))   // b

   write_byte(get_pcvar_num(pnumlife)) // life in 10's
   write_byte(get_pcvar_num(pnumdecay))  // decay rate in 10's

   message_end() 
  
   
} 

public RunNVG2(taskid) 
{ 
   new id = taskid - 222222

   if (!is_user_alive(id)) return
   
   new color[17];
   get_pcvar_string(pcolor,color,16);
   
   new iRed[5], iGreen[7], iBlue[5]
   parse(color,iRed,4,iGreen,6,iBlue,4)
   
   message_begin(MSG_ONE_UNRELIABLE,gmsgFade,{0,0,0},id) 

   write_short(1000) 
   write_short(1000) 
   write_short(1<<12) 

   write_byte(str_to_num(iRed))
   write_byte(str_to_num(iGreen))
   write_byte(str_to_num(iBlue)) 

   write_byte(g_ALPHA) 

   message_end() 
} 

public ev_new_round(id)
{
				
	StopNVG(id)
	NightVisionUse[id] = false;	
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
