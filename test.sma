#include <amxmodx>
// #include <colorchat>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#define PLUGIN "Test"
#define VERSION "1.0"
#define AUTHOR "Sapphire's fan"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)    
    register_clcmd( "test2", "testHandler" );
}

public testHandler(id) {
    new arr = ArrayCreate(32);
    new str[32];
    for(new i = 1 ; i < 4; ++i) {
        num_to_str(i, str, charsmax(str));
        ArrayPushString(arr, str);
    }

    new str2[32];
    for(new i = 0 ; i < 3; ++i) {
        ArrayGetString(arr, i, str2, 32);
        client_print(id, print_center, "\w#KZ Server \dby Perfectslife ^n^n\dPresent time %s^nMap \y%s\d & Timeleft \y%s:%02d^n\dType map \y%s",str2, str2, str2, str2, str2);
    }
    ArrayDestroy(arr);
    set_hudmessage( 200, 100, 0, -1.0, 0.35, 0, 6.0, 12.0, 0.1, 0.2, 4 );
    show_hudmessage (id, "=====================================================hello567");
    new str3[32] = "Tommy,Jimmy,Rose,come here",substr[16],i=1
    while(str3[0] && strtok(str3, substr, 16, str3,31 , ',')){
    //一般情况下我们希望去除两头的空格,如果不需要,去掉下面的两行
    trim(str3)
    trim(substr)

    //作为示例,直接在服务器控制台输出吧
    server_print("Arg%d: %s",i++, substr)
    }
}

