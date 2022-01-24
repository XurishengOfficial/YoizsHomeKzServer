/* 本插件由 AMXX-Studio 中文版自动生成 */
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <fakemeta_util>


new sudu[33];
new k1[33];
new k2[33];
new k3[33];
new k4[33];
new k5[33];
new k6[33];
new k7[33];
new k8[33];
public plugin_init()
{
	register_clcmd("say /dj", "ExtraMenu");
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink", 0);
	return 0;
}

public ExtraMenu(id)
{
	if (!is_user_alive(id))
	{
		client_print(id, print_chat, "【注意：】本功能仅对活着的玩家开放！");
		return 1;
	}
	// new menu = menu_create("\r购买特殊道具", "menu_handler", "HamFilter");
	new menu = menu_create("\r购买特殊道具", "menu_handler");
	menu_additem(menu, "\y 狂赌一把 （悲喜随机） ￥1000", "1");
	menu_additem(menu, "\y 黄金圣衣 （护甲+150） ￥1500", "2");
	menu_additem(menu, "\y 天山雪莲 （血值+150） ￥3000", "3");
	menu_additem(menu, "\w 轻功技能 （跳得更高） ￥5000", "4");
	menu_additem(menu, "\w 刘翔跑鞋 （跑得更快） ￥6000", "5");
	menu_additem(menu, "\r 手雷礼包 （20个手雷） ￥7000", "6");
	menu_additem(menu, "\r 英雄武器 （akm4 awp） ￥8000", "7");
	menu_additem(menu, "\r 回血魔法 （回血1/1s） ￥10000", "8");
	menu_setprop(menu, 6, 1);
	menu_display(id, menu);
	return 1;
}

public menu_handler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	new data[6];
	new iName[64];
	new access;
	new callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	new key = str_to_num(data);
	switch (key)
	{
		case 1:
		{
			if (k1[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (1000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 1000, 1);
			new name[32];
			get_user_name(id, name, 31);
			new a = random_num(1, 4);
			if (a == 1)
			{
				set_user_health(id, 1);
				client_print(0, print_chat, "【恭喜】玩家『%s』赌博输得只剩1滴血了！", name);
			}
			else
			{
				if (a == 2)
				{
					geishouleibao(id);
					client_print(0, print_chat, "【恭喜】玩家『%s』赌博赢到手雷礼包！", name);
				}
				if (a == 3)
				{
					set_user_health(id, get_user_health(id) + 150);
					client_print(0, print_chat, "【恭喜】玩家『%s』赌博赢了个天山雪莲HP+150！", name);
				}
				geiwuqi(id);
				client_print(0, print_chat, "【恭喜】玩家『%s』赌博赢得英雄武器！", name);
			}
			k1[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 2:
		{
			if (k2[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (1500 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 1500, 1);
			new name[32];
			get_user_name(id, name, 31);
			set_user_armor(id, get_user_armor(id) + 150);
			client_print(0, print_chat, "【恭喜】玩家『%s』穿上了黄金圣衣，护甲+150！", name);
			k2[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 3:
		{
			if (k3[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (3000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 3000, 1);
			new name[32];
			get_user_name(id, name, 31);
			set_user_health(id, get_user_health(id) + 150);
			client_print(0, print_chat, "【恭喜】玩家『%s』吃了颗天山雪莲HP+150！", name);
			k3[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 4:
		{
			if (k4[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (5000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 5000, 1);
			new name[32];
			get_user_name(id, name, 31);
			// set_user_gravity(id, 1050253722);
			set_user_gravity(id, 0.8);
			client_print(0, print_chat, "【恭喜】玩家『%s』学会了 轻功技能！", name);
			k4[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 5:
		{
			if (k5[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (6000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 6000, 1);
			new name[32];
			get_user_name(id, name, 31);
			sudu[id] = 1;
			// set_user_maxspeed(id, 1145569280);
			set_user_maxspeed(id, 1.5);
			client_print(0, print_chat, "【恭喜】玩家『%s』穿上了刘翔的跑鞋，那速度-神了！", name);
			k5[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 6:
		{
			if (k6[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (7000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 7000, 1);
			new name[32];
			get_user_name(id, name, 31);
			geishouleibao(id);
			client_print(0, print_chat, "【恭喜】玩家『%s』购买了手雷大礼包，大家小心啦！", name);
			k6[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 7:
		{
			if (k7[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (8000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 8000, 1);
			new name[32];
			get_user_name(id, name, 31);
			geiwuqi(id);
			client_print(0, print_chat, "【恭喜】玩家『%s』取得英雄武器套装，大家快点歼灭他！", name);
			k7[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		case 8:
		{
			if (k8[id] == 1)
			{
				client_print(id, print_chat, "【注意：】每种物品一回合只能购买一次");
				menu_destroy(menu);
				return 1;
			}
			if (10000 > cs_get_user_money(id))
			{
				client_print(id, print_chat, "【注意：】小子！没钱不要乱点！！！！");
				menu_destroy(menu);
				return 1;
			}
			cs_set_user_money(id, cs_get_user_money(id) - 10000, 1);
			new name[32];
			get_user_name(id, name, 31);
			set_task(0.5, "huixue", id + 555461, _, 0, "b", 0);
			client_print(0, print_chat, "【恭喜】玩家『%s』学会了自我医疗术，大家何不快点解决他呢！", name);
			k8[id] = 1;
			menu_destroy(menu);
			return 1;
		}
		default:
		{
			menu_destroy(menu);
			return 1;
		}
	}
	return 1;
}

public event_round_start()
{
	client_print(0, print_chat, "本插件使用CS1.6爱好者群主开发的菜单生成器制成，按y输入 /dj打开菜单或者在控制台输入say /dj打开菜单");
	static i;
	i = 1;
	while (get_maxplayers() > i)
	{
		sudu[i] = 0;
		k1[i] = 0;
		k2[i] = 0;
		k3[i] = 0;
		k4[i] = 0;
		k5[i] = 0;
		k6[i] = 0;
		k7[i] = 0;
		k8[i] = 0;
		if (task_exists(i + 555461, 0))
		{
			remove_task(i + 555461, 0);
		}
		i += 1;
	}
	return 0;
}

public fw_PlayerPreThink(id)
{
	if (sudu[id] == 1 && is_user_alive(id) && is_user_connected(id))
	{
		set_user_maxspeed(id, 1.5);
	}
	return 0;
}

public geishouleibao(id)
{
	give_item(id, "weapon_hegrenade");
	cs_set_user_bpammo(id, 4, 10);
	give_item(id, "weapon_smokegrenade");
	cs_set_user_bpammo(id, 9, 5);
	give_item(id, "weapon_flashbang");
	cs_set_user_bpammo(id, 25, 5);
	return 0;
}

public geiwuqi(id)
{
	give_item(id, "weapon_awp");
	cs_set_user_bpammo(id, 18, 50);
	give_item(id, "weapon_ak47");
	cs_set_user_bpammo(id, 28, 150);
	give_item(id, "weapon_m4a1");
	cs_set_user_bpammo(id, 22, 150);
	return 0;
}

public huixue(id)
{
	if (get_user_health(id) < 200 && is_user_alive(id) && is_user_connected(id))
	{
		set_user_health(id, get_user_health(id) + 1);
	}
	return 0;
}
