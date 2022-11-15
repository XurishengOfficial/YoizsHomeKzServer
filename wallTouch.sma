#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <colorChat>
#include <float>
#include <dhudmessage>

#define VERSION "1.0"
#define Author "Azuki daisuki~"

new g_msgDamage;
new const FL_ONGROUND2 = ( FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER |  FL_CONVEYOR | FL_FLOAT )
new g_bWTEnabled[33];
new Float: offset_d = 10.0;

public plugin_init() {
    register_plugin( "WallTouch", VERSION, Author );
    register_clcmd("say /wt", "cmdWallTouchHelper");
    RegisterHam(Ham_Touch, "player", "FwdPlayerTouch");
    g_msgDamage = get_user_msgid("Damage");
    set_task(650.0, "taskShowWTHelpInfo", _, _, _, "b", _);
}

// public Touch(id, ent) {
//     if( get_entity_flags( id ) & FL_ONGROUND )
//         client_print(id, print_chat, "Not Touching");

//     else
//         client_print(id, print_chat, "Touching");
// }

/* native trace_hull(const Float:origin[3],     // start point
                    hull,                       // Hull type (站着or蹲着的hitbox) hlsdk_const.inc  HULL_* constants
                    ignoredent = 0,             // 需要忽略的实体id
                    ignoremonsters = 0,         // Entity ignore type
                    const Float:end[3] = NULL_VECTOR    // end point
                    );

*/
// stock showDmgHud(id, const Float:wallOrigin[3], const Float:playerOrigin[3])

public doDmg(id, const Float:dmgOrigin[3])
{
    message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
    write_byte(0) // damage save
    write_byte(1) // damage take
    write_long(DMG_BULLET) // damage type - DMG_BULLET hlsdk_const
    write_coord(dmgOrigin[0]) // x
    write_coord(dmgOrigin[1]) // y
    write_coord(dmgOrigin[2]) // z
    message_end()
}

public showRightTouchHud(id)
{
    set_dhudmessage(255, 20, 20, -0.45, -1.0, 0, 0.0, 0.1, 0.0, 0.0);//right >>>
    show_dhudmessage(id, ">>|");
}

public showLeftTouchHud(id)
{
    set_dhudmessage(255, 20, 20, -0.55, -1.0, 0, 0.0, 0.1, 0.0, 0.0);//left <<<
    show_dhudmessage(id, "|<<");
}

public client_putinserver(id)
{
    g_bWTEnabled[id] = false;
}

public client_disconnect(id)
{
    g_bWTEnabled[id] = false;
}

// ^x01 normal ^x03 type ^x04 green 
public cmdWallTouchHelper(id)
{
    g_bWTEnabled[id] = !g_bWTEnabled[id];
    // ColorChat(id, GREEN,  "%s ^x01Only VIP can addtime!", prefix)
    if(g_bWTEnabled[id])
        ColorChat(id, BLUE, "^x04[KZ]^x01Wall Touch Helper^x03 enabled^x01!");
    else
        ColorChat(id, RED, "^x04[KZ]^x01Wall Touch Helper^x03 disabled^x01!");
    return PLUGIN_HANDLED;
}

stock showDmgHud(id, const Float:wallOrigin[3], const Float:playerOrigin[3])
{
    new float: offset = 0.1;
    new float: origin[3];
    // if(wallOrigin[0] < playerOrigin[0]) origin[0] = playerOrigin[0] - offset;
    // if(wallOrigin[0] > playerOrigin[0]) origin[0] = playerOrigin[0] + offset;
    // if(wallOrigin[1] < playerOrigin[1]) origin[1] = playerOrigin[1] - offset;
    // if(wallOrigin[1] > playerOrigin[1]) origin[1] = playerOrigin[1] + offset;
    // if(wallOrigin[2] > playerOrigin[2]) origin[2] = playerOrigin[1] + 70;
    message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
    write_byte(0) // damage save
    write_byte(1) // damage take
    write_long(DMG_GENERIC) // damage type - DMG_BULLET hlsdk_const
    write_coord(wallOrigin[0]) // x
    write_coord(wallOrigin[1]) // y
    write_coord(wallOrigin[2]) // z
    message_end()
}


IsSliding(id)
{
	if (!is_user_alive(id)) return 0;

	new flags = entity_get_int(id, EV_INT_flags);
	if (flags & FL_ONGROUND)	return 0; // Ground

	new Float:origin[3] = 0.0;
	new Float:dest[3] = 0.0;
	pev(id, pev_origin, origin);
	dest[0] = origin[0];
	dest[1] = origin[1];
	dest[2] = origin[2];	// 1
	new ptr = create_tr2();
	new var1;
	if (flags & FL_DUCKING)	// DUCKING
		var1 = 3;
	else
		var1 = 1;
	engfunc(EngFunc_TraceHull, origin, dest, 0, var1, id, ptr);
	new Float:flFraction = 0.0;
	get_tr2(ptr, 4, flFraction);
	if (flFraction >= 1.0)
	{
		free_tr2(ptr);
		return 0;
	}
	get_tr2(ptr, 7, dest);
	free_tr2(ptr);
	return dest[2] <= 0.7;
}

public FwdPlayerTouch(id, ent)
{
    if(!g_bWTEnabled[id]) return;
    new Float:origin[3];
    if( (pev(id, pev_flags) & FL_ONGROUND2) ) return;
    entity_get_vector(id, EV_VEC_origin, origin)
    
    new hull = (get_entity_flags(id) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN // 蹲下时使用ducking的hitbox
    new Float:temp_origin[3];
    new Float:view_angle[3];
    pev(id, pev_v_angle, view_angle);
    new Float: angle = view_angle[1];

    if(angle >= 0.0 && angle < 90.0)
    {
        // left
        temp_origin[0] = origin[0] - floatsin(angle, 1);
        temp_origin[1] = origin[1] + floatcos(angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Left Touching 0~90");
            showLeftTouchHud(id);
            return;
        }
        // right
        temp_origin[0] = origin[0] + floatsin(angle, 1);
        temp_origin[1] = origin[1] - floatcos(angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Right Touching 0~90");
            showRightTouchHud(id)
            return;
        }
    }
    else if(angle >= 90.0 < angle < 180.0)
    {
        // left
        temp_origin[0] = origin[0] - floatsin(180.0 - angle, 1);
        temp_origin[1] = origin[1] - floatcos(180.0 - angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Left Touching 90~180");
            showLeftTouchHud(id);
            return;
        }
        // right
        temp_origin[0] = origin[0] + floatsin(180.0 - angle, 1);
        temp_origin[1] = origin[1] + floatcos(180.0 - angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Right Touching 90~180");
            showRightTouchHud(id)
            return;
        }
    }
    else if(angle >= -90.0 && angle < 0.0)
    {
        // left
        temp_origin[0] = origin[0] - floatsin(angle, 1);
        temp_origin[1] = origin[1] + floatcos(angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Left Touching -90~0");
            showLeftTouchHud(id);
            return;
        }
        // right
        temp_origin[0] = origin[0] + floatsin(angle, 1);
        temp_origin[1] = origin[1] - floatcos(angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Right Touching -90~0");
            showRightTouchHud(id)
            return;
        }
    }
    else if(angle >= -180.0 && angle < -90.0)
    {
        // left
        temp_origin[0] = origin[0] + floatsin(180.0 + angle, 1);
        temp_origin[1] = origin[1] - floatcos(180.0 + angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Left Touching -180~-90");
            showLeftTouchHud(id);
            return;
        }
        // right
        temp_origin[0] = origin[0] - floatsin(180.0 + angle, 1);
        temp_origin[1] = origin[1] + floatcos(180.0 + angle, 1);
        temp_origin[2] = origin[2];
        if(trace_hull(temp_origin, hull, id, 1))
        {
            showDmgHud(id, temp_origin, origin);
            // client_print(id, print_chat, "Right Touching -180~-90");
            showRightTouchHud(id)
            return;
        }
    }
    // for(new i = 0; i < 6; i++)  // 遍历前后左右头和脚是否有障碍物
    // {
    //     temp_origin = origin
    //     temp_origin[i / 2] += ((i % 2) ? -1.0 : 1.0)
        
    //     if(trace_hull(temp_origin, hull, id, 1)) // 按照某个半径检测碰撞?
    //     {
    //         showDmgHud(id, temp_origin, origin);
    //         // if(temp_origin[0] < origin[0]) client_print(id, print_chat, "x-");
    //         // if(temp_origin[0] > origin[0]) client_print(id, print_chat, "x+");
    //         // if(temp_origin[1] < origin[1]) client_print(id, print_chat, "y-");
    //         // if(temp_origin[1] > origin[1]) client_print(id, print_chat, "y+");
    //         // return;
    //         client_print(id, print_chat, "Touching");
    //     }
    // }
}

public taskShowWTHelpInfo()
{
    ColorChat(0, TEAM_COLOR, "^x04[KZ] ^x01输入指令^x03 /wt ^x01开启^x03撞墙提示 ^x01[2022/11/15新版上线 欢迎使用和反馈]");
}