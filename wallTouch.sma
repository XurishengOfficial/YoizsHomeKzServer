#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <colorChat>

#define VERSION "1.0"
#define Author "Azuki daisuki~"

new g_msgDamage;
new const FL_ONGROUND2 = ( FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER |  FL_CONVEYOR | FL_FLOAT )
new g_bWTEnabled[33];

public plugin_init() {
    register_plugin( "WallTouch", VERSION, Author );
    register_clcmd("say /wt", "cmdWallTouchHelper");
    RegisterHam(Ham_Touch, "player", "FwdPlayerTouch");
    g_msgDamage = get_user_msgid("Damage");
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
        ColorChat(id, BLUE, "^x04[KZ]^x01Wall Touch Helper^x03 enabled!");
    else
        ColorChat(id, RED, "^x04[KZ]^x01Wall Touch Helper^x03 disabled!");
    return PLUGIN_HANDLED;
}

stock showDmgHud(id, const Float:wallOrigin[3], const Float:playerOrigin[3])
{
    new float: offset = 0.1;
    new float: origin[3];
    if(wallOrigin[0] < playerOrigin[0]) origin[0] = playerOrigin[0] - offset;
    if(wallOrigin[0] > playerOrigin[0]) origin[0] = playerOrigin[0] + offset;
    if(wallOrigin[1] < playerOrigin[1]) origin[1] = playerOrigin[1] - offset;
    if(wallOrigin[1] > playerOrigin[1]) origin[1] = playerOrigin[1] + offset;
    message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
    write_byte(0) // damage save
    write_byte(1) // damage take
    write_long(DMG_GENERIC) // damage type - DMG_BULLET hlsdk_const
    write_coord(origin[0]) // x
    write_coord(origin[1]) // y
    write_coord(origin[2]) // z
    message_end()
}
public FwdPlayerTouch(id, ent)
{
    if(!g_bWTEnabled[id]) return;
    new Float:origin[3];
    if(pev(id, pev_flags) & FL_ONGROUND2) return;
    entity_get_vector(id, EV_VEC_origin, origin)
    
    new hull = (get_entity_flags(id) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN // 蹲下时使用ducking的hitbox
    new Float:temp_origin[3]
    for(new i = 0; i < 4; i++)  // 遍历前后左右是否有障碍物
    {
        temp_origin = origin
        temp_origin[i / 2] += ((i % 2) ? -1.0 : 1.0)
        
        if(trace_hull(temp_origin, hull, id, 1)) // 按照某个半径检测碰撞?
        {
            showDmgHud(id, temp_origin, origin);
            // if(temp_origin[0] < origin[0]) client_print(id, print_chat, "x-");
            // if(temp_origin[0] > origin[0]) client_print(id, print_chat, "x+");
            // if(temp_origin[1] < origin[1]) client_print(id, print_chat, "y-");
            // if(temp_origin[1] > origin[1]) client_print(id, print_chat, "y+");
            // return;
        }
    }
}