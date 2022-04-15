/* 
注意使用此插件需关掉uq_jumpstats里的地速显示,否则信息会重叠.

修复一些小bug,地速与uq_jumpstatus不匹配问题.
修复自身最大速度超速提示.自身MAX速度 * 1.2 =超速提示
*/
#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Simple Prestrafe"
#define VERSION "1.3"
#define AUTHOR "Destroman & Perfectslife"

new bool:g_userConnected[33],bool:g_alive[33];
new max_players;											///////////////////////////////////////
new ddnum[33];
new bhop_num[33];
new bool:firstfall_ground[33],Float:FallTime[33];
new bool:plrPre[33];												/////////////////////////////////
new bool:g_Jumped[33],bool:g_reset[33];
new Float:speed[33];
new bool:ladderjump[33];
new movetype[33];
static bool:is_user_duck[33], bool:in_air[33];
new bool:notjump[33];
new Float:duckgainspeed[33];
new Float:prebhopspeed[33];
new Float:preladderspeed[33];
new Float:preduckspeed[33];
new Float:bhopgainspeed[33];

new g_iFramesOnGround[33];
new Float:g_flSpeed[33];
// new Float:g_flSpeedPrev[33];
new Float:g_flGroundTouchSpeed[33];

new pre_hud_channel = 3;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward( FM_PlayerPreThink,	"fwdPreThink",	0 );
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1);
	max_players=get_maxplayers()+1;			
	register_clcmd("say /pres", "tooglePre")
	register_clcmd("say /showpre", "tooglePre")
}


public tooglePre(id)
{
	plrPre[id] = plrPre[id] ? false : true
	set_hudmessage(0, 100, 255, -1.0, 0.74, 2, 0.1, 1.8, 0.01, 0.01, -1);
	if(!plrPre[id]) {
		show_hudmessage( id, "SHOWPRE: OFF" );
	} else {
		show_hudmessage( id, "SHOWPRE: ON" );
	}
}



public fwdPreThink( id )
{
	if(is_user_bot(id))
		return FMRES_IGNORED;

	if(g_userConnected[id]==true)
	{	
		new tmpTeam[33],dead_flag;	
		get_user_team(id,tmpTeam,32);
		dead_flag=pev(id, pev_deadflag);
		
		if(equali(tmpTeam,"SPECTATOR") && g_alive[id])
		{
			g_alive[id]=false;
		}
		else if(equali(tmpTeam,"TERRORIST") || equali(tmpTeam,"CT"))
		{
			if(dead_flag==2 && g_alive[id])
			{
				g_alive[id]=false;
			}
			else if(dead_flag==0 && g_alive[id]==false)
			{
				g_alive[id]=true;
			}
		}
		
		if( g_alive[id])
		{
			if( g_reset[id] ==true)
			{
				g_reset[id]	= false;
				g_Jumped[id]= false;
				in_air[id]	= false;
				is_user_duck[id]	= false;
				notjump[id]	= false;
				ladderjump[id] = false;
			}
			
			static button, oldbuttons, flags;
			button = pev(id, pev_button );
			flags = pev(id, pev_flags );
			oldbuttons = pev(id, pev_oldbuttons );
			
			new Float:velocity[3], Pmaxspeed;

			Pmaxspeed = pev(id, pev_maxspeed);
			pev(id, pev_velocity, velocity);
			movetype[id] = pev(id, pev_movetype);
			g_flSpeed[id] = floatsqroot(floatadd(floatmul(velocity[0], velocity[0]), floatmul(velocity[1], velocity[1])));  // 开根号 x*x+y*y
			// new Float:maxPrestrafe = 1.2 * Pmaxspeed;
	
			if( flags&FL_ONGROUND && flags&FL_INWATER )  velocity[2] = 0.0;
			speed[id] = vector_length(velocity);	
			
			new is_spec_user[33];
			for( new i = 1; i < max_players; i++ )
			{
				is_spec_user[i]=is_user_spectating_player(i, id);
			}
			
			if(notjump[id])
			{
				notjump[id]=false;
			}
			
			if( flags & FL_ONGROUND )
			{
				notjump[id]=true;
				g_iFramesOnGround[id]++;	// 在地面上的帧数
			}
			else g_iFramesOnGround[id] = 0;	// 不在地面上 FOG置零
			if (g_iFramesOnGround[id] == 1) g_flGroundTouchSpeed[id] = g_flSpeed[id];	// 1帧 记录玩家落地速度

			new FOGTYPE[ 33 ], preHudRGB[ 3 ];
			switch(g_iFramesOnGround[id])
			{
				case 0:
				{
					// nothing to do
				}
				case 1:
				{
					format(FOGTYPE, 32, "Perfect");
					preHudRGB[ 0 ] = 0;
					preHudRGB[ 1 ] = 255;
					preHudRGB[ 2 ] = 0;
				}
				case 2:
				{
					format(FOGTYPE, 32, "Good");
					preHudRGB[ 0 ] = 255;
					preHudRGB[ 1 ] = 255;
					preHudRGB[ 2 ] = 0;
				}
				case 3:
				{
					format(FOGTYPE, 32, "Bad");
					preHudRGB[ 0 ] = 255;
					preHudRGB[ 1 ] = 0;
					preHudRGB[ 2 ] = 0;
				}
				default:
				{
					format(FOGTYPE, 32, "Very Bad");
					preHudRGB[ 0 ] = 220;
					preHudRGB[ 1 ] = 20;
					preHudRGB[ 2 ] = 60;
				}
			}

			if( (movetype[id] == MOVETYPE_FLY) &&  (button&IN_FORWARD || button&IN_BACK || button&IN_LEFT || button&IN_RIGHT ) )
			{
				ladderjump[id]=true;
			}
			
			if( (movetype[id] == MOVETYPE_FLY) &&  button&IN_JUMP )
			{
				ladderjump[id]=false;
				in_air[id]=false;
				notjump[id]=true;
			}
			
			// ladder pre
			if( movetype[id] != MOVETYPE_FLY && ladderjump[id]==true)
			{
				notjump[id]=true;
				ladderjump[id]=false;	

				static i;
				in_air[id]	= true;
				g_Jumped[id]	= true;
				prebhopspeed[id] = 0.0;
				preduckspeed[id] = 0.0;
				for( i = 1; i < max_players; i++ )
				{
					if( (i == id || is_spec_user[i]))
					{
						if(plrPre[i])
						{
							preladderspeed[id] = speed[id]
							new szMessage[ 32 ];
							formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id] );
							send_hudmessage(i,szMessage, -1.0 ,0.65,  0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0)
						}
					}
				}
			}
			
			// dd count
			if( button & IN_DUCK && !(oldbuttons &IN_DUCK) && flags & FL_ONGROUND)
			{
				if (speed[id] > 110) {
					ddnum[id]++;
				} else {
					ddnum[id] = 0;
				}
			}

			// bj sbj duckbhop
			if( button & IN_JUMP && !( oldbuttons & IN_JUMP ) && flags & FL_ONGROUND )
			{	
				bhop_num[id]++;
				notjump[id] = false;

				ddnum[id] = 0;
				pev(id, pev_velocity, velocity);
				static i;
				in_air[id] = true;
				g_Jumped[id] = true;

				for( i = 1; i < max_players; i++ )
				{
					if( (i == id || is_spec_user[i]))
					{
						if(plrPre[i])
						{
							if(bhop_num[id] > 0) 
							{
								preduckspeed[id] = speed[id];
								if ( floatround(preladderspeed[id]) > 20) 
								{
									bhopgainspeed[id] = preladderspeed[id];
									preladderspeed[id] = 0.0;
								}
								else if ( floatround(prebhopspeed[id]) > 100) 
								{
									bhopgainspeed[id] = prebhopspeed[id];
									prebhopspeed[id] = 0.0;
								}
								if(Pmaxspeed * 1.2 > speed[id])	// 未超速
								{
									
									if ( bhopgainspeed[id] > speed[id] ) // 起跳后减速
									{
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])	// FOG过高 过滤
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "%s %.2f(-%.1f)^nFOG:%i (%.2f)", FOGTYPE, speed[id], bhopgainspeed[id] - speed[id], g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										
									}
									else if ( bhopgainspeed[id] == 0.0 || bhopgainspeed[id] == speed[id]) // 本次弹跳不加也不减 或者原地蹦跶
									{ 
										new szMessage[ 64 ];
										formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id] );
										send_hudmessage(i,szMessage, -1.0 ,0.65,  0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0)
									}
									else if ( bhopgainspeed[id] < speed[id] ) // 起跳后加速
									{	
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "%s %.2f(+%.1f)^nFOG:%i (%.2f)", FOGTYPE, speed[id], speed[id] - bhopgainspeed[id], g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}	
									}
								}
								else	//超速
								{	
									if ( bhopgainspeed[id] > speed[id] )	//超速减速
									{
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "Your Prestrafe %.2f(-%.1f) is too high(%.01f)^nFOG:%i (%.2f)", speed[id], bhopgainspeed[id] - speed[id], 1.2 * Pmaxspeed, g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
									}
									else if ( bhopgainspeed[id] < speed[id] )	// 超速加速
									{
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "Your Prestrafe %.2f(+%.1f) is too high(%.01f)^nFOG:%i (%.2f)", speed[id], speed[id] - bhopgainspeed[id], 1.2 * Pmaxspeed, g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
									}
								}
							}
						}
					}
				}
				bhopgainspeed[id] = speed[id];
			}
			else if( flags & FL_ONGROUND && in_air[id])
			{	
				g_reset[id] = true;
			}
			
			// 多次小跳显示地速
			if( button & IN_DUCK && !(oldbuttons & IN_DUCK) && flags & FL_ONGROUND  && !is_user_duck[id] )
			{	
				for( new i = 1; i < max_players; i++ )
				{
					if( (i == id || is_spec_user[i]))	//#MARK 可能需要改
					{
						if(plrPre[i])
						{
							if(ddnum[id] > 0) 
							{
								prebhopspeed[id] = speed[id]
								if ( floatround(preladderspeed[id]) > 20) 
								{
									bhopgainspeed[id] = preladderspeed[id];										
									preladderspeed[id] = 0.0;
								}
								else if ( floatround(preduckspeed[id]) > 100) 
								{
									duckgainspeed[id] = preduckspeed[id];										
									preduckspeed[id] = 0.0;
								}
								if(Pmaxspeed * 1.2 > speed[id]) 
								{
									if ( duckgainspeed[id] > speed[id] ) 
									{
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])	// FOG太高
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "%s %.2f(-%.1f)^nFOG:%i (%.2f)", FOGTYPE, speed[id], duckgainspeed[id] - speed[id], g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
									}
									else if ( duckgainspeed[id] == 0.0 || duckgainspeed[id] == speed[id]) 
									{
										new szMessage[ 64 ];
										formatex( szMessage, charsmax( szMessage ),  "%.2f", speed[id] );
										send_hudmessage(i,	szMessage, -1.0 ,0.65,  0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0)

									}
									else if ( duckgainspeed[id] < speed[id] ) 
									{
										new szMessage[ 64 ];
										if (8 <= g_iFramesOnGround[id])	// FOG太高
										{
											formatex( szMessage, charsmax( szMessage ), "%.2f", speed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, 0, 100, 255, 255 , 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
										else
										{
											formatex( szMessage, charsmax( szMessage ), "%s %.2f(+%.1f)^nFOG:%i (%.2f)", FOGTYPE, speed[id], speed[id] - duckgainspeed[id], g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
											send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
										}
									}
								}
								else
								{
									if ( bhopgainspeed[id] > speed[id] ) // 超速减速
									{
										new szMessage[ 64 ];
										formatex( szMessage, charsmax( szMessage ), "Your Prestrafe %.2f(-%.1f) is too high(%.01f)^nFOG:%i (%.2f)", speed[id], bhopgainspeed[id] - speed[id], 1.2 * Pmaxspeed, g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
										send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
									}
									else if ( bhopgainspeed[id] < speed[id] ) 
									{	// 超速加速
										new szMessage[ 64 ];
										formatex( szMessage, charsmax( szMessage ), "Your Prestrafe %.2f(+%.1f) is too high(%.01f)^nFOG:%i (%.2f)", speed[id], speed[id] - bhopgainspeed[id], 1.2 * Pmaxspeed, g_iFramesOnGround[id], g_flGroundTouchSpeed[id]);
										send_hudmessage(i, szMessage, -1.0 ,0.65, preHudRGB[0], preHudRGB[1], preHudRGB[2], 255, 1.8, 0.01, 0.0, pre_hud_channel , 0, 0, 0, 0, 255, 0.0);
									}
								}
							}
						}
					}
				}
				duckgainspeed[id] = speed[id];
				is_user_duck[id] = true;
			}
			else if( !in_air[id] && oldbuttons & IN_DUCK && flags & FL_ONGROUND )
			{
				if( !is_user_duckk( id ) )
				{	
					is_user_duck[id] = false;
				}
			}
			
			
			if(flags&FL_ONGROUND && firstfall_ground[id]==true && get_gametime()-FallTime[id]>0.5)
			{
				ddnum[id]=0;
				bhop_num[id]=0;
				firstfall_ground[id] = false;
				duckgainspeed[id] = 0.0;
				prebhopspeed[id] = 0.0;
				preduckspeed[id] = 0.0;
				bhopgainspeed[id] = 0.0;
				preladderspeed[id] = 0.0;
			}
			
			if(flags&FL_ONGROUND && firstfall_ground[id]==false)
			{
				FallTime[id]=get_gametime();
				firstfall_ground[id]=true;
			}
			else if(!(flags&FL_ONGROUND) && firstfall_ground[id]==true)
			{
				firstfall_ground[id]=false;
			}	

				
		}
	}
	return FMRES_IGNORED;
}


public FwdPlayerSpawn(id)
{
	if( is_user_alive(id) && !is_user_hltv(id))
	{
		g_alive[id] = true;
	}
}

public FwdPlayerDeath(id)
{
	g_alive[id] = false;
}

bool:is_user_duckk( id )
{
	if( !pev_valid( id )  )
		return false
	
	new Float:abs_min[3], Float:abs_max[3]
	
	pev( id, pev_absmin, abs_min )
	pev( id, pev_absmax, abs_max )
	
	abs_min[2] += 64.0
	
	if( abs_min[2] < abs_max[2] )
		return false
	
	return true
}

public client_connect( plr )
{

	
	g_userConnected[plr]=true;
	plrPre[plr]=true;

	ddnum[plr]=0;
	bhopgainspeed[plr] = 0.0
	duckgainspeed[plr] = 0.0
	prebhopspeed[plr] = 0.0
	preduckspeed[plr] = 0.0
	preladderspeed[plr] = 0.0;
}

public client_disconnect(id) {
	
	g_userConnected[id]=false;
	g_alive[id]=false;

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
// send_hudmessage(i,szMessage, -1.0 ,0.65,  0, 255, 0, 255 , 1.8, 0.01, 0.0, 3 , 0, 0, 0, 0, 255, 0.0)
// 使用channel 3
stock send_hudmessage(id,text[],Float:X,Float:Y,R,G,B,A=255,Float:holdtime=5.0,Float:fadeintime=0.1,Float:fadeouttime=0.1,channel=-1,effect=0,effect_R=0,effect_G=0,effect_B=0,effect_A=255,Float:effecttime=0.0) {
    
    if ( id )
        message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, {0,0,0}, id);
    else
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_TEXTMESSAGE)
    write_byte(channel)
    write_short(coord_to_hudmsgshort(X))
    write_short(coord_to_hudmsgshort(Y))
    write_byte(effect)
    write_byte(R)   
    write_byte(G)
    write_byte(B)
    write_byte(A)
    write_byte(effect_R)
    write_byte(effect_G)
    write_byte(effect_B)
    write_byte(effect_A)
    write_short(seconds_to_hudmsgshort(fadeintime))
    write_short(seconds_to_hudmsgshort(fadeouttime))
    write_short(seconds_to_hudmsgshort(holdtime))
    if ( effect == 2 )
        write_short(seconds_to_hudmsgshort(effecttime));
    write_string(text)
    message_end()
}

stock seconds_to_hudmsgshort(Float:sec) {
    new output = floatround(sec * 256);
    return output < 0 ? 0 : output > 65535 ? 65535 : output;
}

stock coord_to_hudmsgshort(Float:coord) {
    new output = floatround(coord * 8192);
    return output < -32768 ? -32768 : output > 32767 ? 32767 : output;
}