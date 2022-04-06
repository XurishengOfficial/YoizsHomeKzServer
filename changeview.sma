/*
	Change View Type created by OneEyed.
	Last edited by Azuki daisuki~
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

new view[32]
//Precache of rpgrocket.mdl is NEEDED, for some odd reason.
public plugin_precache()
	precache_model("models/rpgrocket.mdl")	

public plugin_init() {
	register_plugin("Change View", "v1.0", "OneEyed & Azuki daisuki~")
	register_concmd("amx_view", "changeView", _, "Cycles through 4 different view types.")
	register_forward(FM_AddToFullPack, "FM_client_AddToFullPack_Post", 1) 
}

public client_disconnect(id) {
	view[id] = 0;
}

public client_connect(id) {
	view[id] = 0;
}

public changeView(id,level,cid) {
	view[id]++;
	new viewtype[32]
	if(view[id] > 3)
		view[id] = 0
	switch(view[id])
	{
		case 0: format(viewtype, 31, "Normal")
		case 1: format(viewtype, 31, "3rd Person")
		case 2: format(viewtype, 31, "3rd Person (Up Left)")
		case 3:	format(viewtype, 31, "3rd Person (Top Down)")
	}
	client_print(id, print_chat, "Changing View to %s", viewtype)
	set_view(id, view[id]);	//set view会自动将玩家设置为透明 故需要手动修改
	return PLUGIN_HANDLED;
}

public FM_client_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet) {
	// 如果该实体是玩家
	if( player )	
	{
		if (view[host] != 0)	// 视角是第三视角
		{
			if ( host == ent && get_orig_retval() && is_user_alive(host) ) 
    		{ 
				// set_es(es, ES_Solid, SOLID_NOT);	//是否碰撞体积
				// set_es(es, ES_RenderMode, kRenderTransAdd); //设置渲染为亮度逐渐增加?
				set_es(es, ES_RenderMode, 0);	// 设置玩家不透明	0不透明 1半透明
				// set_es(es, ES_RenderAmt, floatround(entity_range(host, ent) * 700.0 / 400, floatround_floor)); // 设置渲染模式为距离越近越透明
				// set_es(es, ES_RenderAmt, get_pcvar_num(kz_semiclip_transparency));
			} 
		}
	}
}
