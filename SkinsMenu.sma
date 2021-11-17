#include <amxmodx>
#include <cstrike>
#include <fakemeta>

#define PLUGIN "Skins Menu"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

#define MAX_SKINS = 10;

new pm[] = "models/player/azuki/azuki.mdl";
public plugin_precache() {
    precache_model(pm);
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    register_clcmd( "say /myskin",     "Skins_Menu" );
    register_clcmd( "myskin",     "Skins_Menu" );
}


public Skins_Menu( id ) 
{ 
    new menu = menu_create("Select Your Skin", "skin_menu") 
    /*
        menu_additem(menu,const text[],const info[]="",access=0,callback=-1)
    */
    menu_additem( menu, "Azuki", "1", 0 ); 
    menu_additem( menu, "修改视角", "9", 0 ); 
    menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );  
    /*
        menu_display(id, menu, page=0)
        id 玩家索引
        menu 菜单句柄
        page = 0 默认显示第一页
    */
    menu_display( id, menu, 0 ); 
} 

public skin_menu(id, menu, item)
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
   
    if(is_user_alive(id))
    {   
        new key = str_to_num(info)
   
        switch(key)
        {
            case 1:
            {
                cs_set_user_model(id, pm);
                client_print(id, print_chat, "Your model has been changed to mao1");
            }
            // case 3:
            // {
            //     cs_set_user_model(id, "GI_Diona");
            //     client_print(id, print_chat, "Your model has been changed to GI_Diona");
            // }
            case 9:
            {
                client_cmd(id, "amx_view");
            }
            // case 4:
            // {
            //     cs_set_user_model(id, "kisame")
            // }
            // case 5:
            // {
            //     if(!(get_user_flags(id) & ADMIN_IMMUNITY))
            //     {
            //         client_print(id, print_chat, "Only VIP/Admin can use the skin, for use type /vipinfo")
            //         return PLUGIN_HANDLED
            //     }
            //     else
            //     {
            //         cs_set_user_model(id, "Terminator")
            //     }
            // }
            // case 6:
            // {
            //     if(!(get_user_flags(id) & ADMIN_IMMUNITY))
            //     {
            //         client_print(id, print_chat, "Only VIP/Admin can use the skin, for use type /vipinfo")
            //         return PLUGIN_HANDLED        
            //     }
            //     else
            //     {
            //         cs_set_user_model(id, "Joker")
            //     }
            // }
            // case 7:
            // {
            //     if(!(get_user_flags(id) & ADMIN_IMMUNITY))
            //     {
            //         client_print(id, print_chat, "Only VIP/Admin can use the skin, for use type /vipinfo")
            //         return PLUGIN_HANDLED            
            //     }
            //     else
            //     {
            //         cs_set_user_model(id, "MyIchigo")
            //     }
            // }
            // case 8:
            // {
            //         if(!(get_user_flags(id) & ADMIN_IMMUNITY))
            //         {
            //             client_print(id, print_chat, "Only VIP/Admin can use the skin, for use type /vipinfo")
            //             return PLUGIN_HANDLED            
            //         }
            //         else
            //         {
            //             cs_set_user_model(id, "Goku")
            //         }
            // }
        }
        menu_display( id, menu, 0 ); 
    }
    return PLUGIN_CONTINUE;
}
