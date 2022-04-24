new __dhud_color;
new __dhud_x;
new __dhud_y;
new __dhud_effect;
new __dhud_fxtime;
new __dhud_holdtime;
new __dhud_fadeintime;
new __dhud_fadeouttime;
new __dhud_reliable;
new bool:g_userConnected[33];
new bool:g_alive[33];
new max_players;
new ddnum[33];
new bhop_num[33];
new bool:firstfall_ground[33];
new Float:FallTime[33];
new bool:plrPre[33];
new bool:g_Jumped[33];
new bool:g_reset[33];
new bool:g_pBot[33];
new Float:speed[33];
new bool:ladderjump[33];
new movetype[33];
new bool:is_user_duck[33];
new bool:in_air[33];
new bool:player_admin[33];
new bool:notjump[33];
new Float:duckgainspeed[33];
new Float:prebhopspeed[33];
new Float:preladderspeed[33];
new Float:preduckspeed[33];
new Float:bhopgainspeed[33];
new uq_admins;
new kz_uq_admins;
bool:operator==(Float:,Float:)(Float:oper1, Float:oper2)
{
	return floatcmp(oper1, oper2) == 0;
}

bool:operator!=(Float:,_:)(Float:oper1, oper2)
{
	return floatcmp(oper1, float(oper2)) != 0;
}

bool:operator>(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 < floatcmp(oper1, oper2);
}

bool:operator>(Float:,_:)(Float:oper1, oper2)
{
	return 0 < floatcmp(oper1, float(oper2));
}

bool:operator<(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 > floatcmp(oper1, oper2);
}

public __fatal_ham_error(Ham:id, HamError:err, reason[])
{
	new func = get_func_id("HamFilter", -1);
	new bool:fail = 1;
	new var1;
	if (func != -1 && callfunc_begin_i(func, -1) == 1)
	{
		callfunc_push_int(id);
		callfunc_push_int(err);
		callfunc_push_str(reason, "HamFilter");
		if (callfunc_end() == 1)
		{
			fail = false;
		}
	}
	if (fail)
	{
		set_fail_state(reason);
	}
	return 0;
}

set_dhudmessage(red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime, bool:reliable)
{
	__dhud_color = clamp(red, "HamFilter", 255) << 16 + clamp(green, "HamFilter", 255) << 8 + clamp(blue, "HamFilter", 255);
	__dhud_x = x;
	__dhud_y = y;
	__dhud_effect = effects;
	__dhud_fxtime = fxtime;
	__dhud_holdtime = holdtime;
	__dhud_fadeintime = fadeintime;
	__dhud_fadeouttime = fadeouttime;
	__dhud_reliable = reliable;
	return 1;
}

show_dhudmessage(index, message[])
{
	new buffer[128];
	new numArguments = numargs();
	if (numArguments == 2)
	{
		send_dhudMessage(index, message);
	}
	else
	{
		new var1;
		if (index || numArguments == 3)
		{
			vformat(buffer, 127, message, "");
			send_dhudMessage(index, buffer);
		}
		new playersList[32];
		new numPlayers;
		get_players(playersList, numPlayers, 76, 80);
		if (!numPlayers)
		{
			return 0;
		}
		new Array:handleArrayML = ArrayCreate(1, 32);
		new i = 2;
		new j;
		while (i < numArguments)
		{
			if (getarg(i, "HamFilter") == -1)
			{
				do {
					j++;
				} while ((buffer[j] = getarg(i + 1, j)));
				j = 0;
				if (GetLangTransKey(buffer) != -1)
				{
					i++;
					ArrayPushCell(handleArrayML, i);
				}
			}
			i++;
		}
		new size = ArraySize(handleArrayML);
		if (!size)
		{
			vformat(buffer, 127, message, "");
			send_dhudMessage(index, buffer);
		}
		else
		{
			new i;
			new j;
			while (i < numPlayers)
			{
				index = playersList[i];
				j = 0;
				while (j < size)
				{
					setarg(ArrayGetCell(handleArrayML, j), "HamFilter", index);
					j++;
				}
				vformat(buffer, 127, message, "");
				send_dhudMessage(index, buffer);
				i++;
			}
		}
		ArrayDestroy(handleArrayML);
	}
	return 1;
}

send_dhudMessage(index, message[])
{
	new var2;
	if (__dhud_reliable)
	{
		new var1;
		if (index)
		{
			var1 = 1;
		}
		else
		{
			var1 = 2;
		}
		var2 = var1;
	}
	else
	{
		if (index)
		{
			var2 = 8;
		}
		var2 = 0;
	}
	message_begin(var2, 51, 84, index);
	write_byte(strlen(message) + 31);
	write_byte(6);
	write_byte(__dhud_effect);
	write_long(__dhud_color);
	write_long(__dhud_x);
	write_long(__dhud_y);
	write_long(__dhud_fadeintime);
	write_long(__dhud_fadeouttime);
	write_long(__dhud_holdtime);
	write_long(__dhud_fxtime);
	write_string(message);
	message_end();
	return 0;
}

public plugin_init()
{
	register_plugin("Prestrafe", "0.1", 3068);
	kz_uq_admins = register_cvar("kz_uq_only_admins", 3148, "HamFilter", "HamFilter");
	register_forward(104, "fwdPreThink", "HamFilter");
	RegisterHam("HamFilter", "player", "FwdPlayerSpawn", 1);
	RegisterHam(11, "player", "FwdPlayerDeath", 1);
	max_players = get_maxplayers() + 1;
	register_clcmd("say /showpre", "tooglePre", -1, 3472, -1);
	return 0;
}

public plugin_cfg()
{
	uq_admins = get_pcvar_num(kz_uq_admins);
	return 0;
}

public tooglePre(id)
{
	new var1;
	if (plrPre[id])
	{
		var1 = 0;
	}
	else
	{
		var1 = 1;
	}
	plrPre[id] = var1;
	set_hudmessage("HamFilter", 100, 255, -1082130432, 1060991140, 2, 1036831949, 1075838976, 1008981770, 1008981770, "");
	if (!plrPre[id])
	{
		show_hudmessage(id, "SHOWPRE: OFF");
	}
	else
	{
		show_hudmessage(id, "SHOWPRE: ON");
	}
	return 0;
}

ClearDHUDMessages(pId, iClear)
{
	new i = 1;
	while (i < max_players)
	{
		new var1;
		if (pId != i && is_user_spectating_player(i, pId))
		{
			new iDHUD;
			while (iDHUD < iClear)
			{
				show_dhudmessage(pId, 3576);
				iDHUD++;
			}
		}
		i++;
	}
	return 0;
}

public fwdPreThink(id)
{
	new var1;
	if (g_userConnected[id] == true && g_pBot[id])
	{
		new var2;
		if (uq_admins == 1 && !player_admin[id])
		{
			return 1;
		}
		new tmpTeam[33];
		new dead_flag;
		get_user_team(id, tmpTeam, 32);
		dead_flag = pev(id, 80);
		new var3;
		if (equali(tmpTeam, "SPECTATOR", "HamFilter") && g_alive[id])
		{
			g_alive[id] = 0;
		}
		else
		{
			new var4;
			if (equali(tmpTeam, "TERRORIST", "HamFilter") || equali(tmpTeam, "CT", "HamFilter"))
			{
				new var5;
				if (dead_flag == 2 && g_alive[id])
				{
					g_alive[id] = 0;
				}
				new var6;
				if (dead_flag && g_alive[id])
				{
					g_alive[id] = 1;
				}
			}
		}
		if (g_alive[id])
		{
			if (g_reset[id] == true)
			{
				g_reset[id] = 0;
				g_Jumped[id] = 0;
				in_air[id] = 0;
				is_user_duck[id] = 0;
				notjump[id] = 0;
				ladderjump[id] = 0;
			}
			static flags;
			static oldbuttons;
			static button;
			button = pev(id, 81);
			flags = pev(id, 84);
			oldbuttons = pev(id, 98);
			new Float:velocity[3] = 0.0;
			pev(id, 120, velocity);
			movetype[id] = pev(id, 69);
			new var7;
			if (flags & 512 && flags & 16)
			{
				velocity[2] = 0.0;
			}
			if (velocity[2] != 0.0)
			{
				new var25 = velocity[2];
				var25 = floatsub(var25, velocity[2]);
			}
			speed[id] = vector_length(velocity);
			new is_spec_user[33];
			new i = 1;
			while (i < max_players)
			{
				is_spec_user[i] = is_user_spectating_player(i, id);
				i++;
			}
			if (notjump[id])
			{
				notjump[id] = 0;
			}
			if (flags & 512)
			{
				notjump[id] = 1;
			}
			new var9;
			if (movetype[id] == 5 && (button & 8 || button & 16 || button & 128 || button & 256))
			{
				ladderjump[id] = 1;
			}
			new var10;
			if (movetype[id] == 5 && button & 2)
			{
				ladderjump[id] = 0;
				in_air[id] = 0;
				notjump[id] = 1;
			}
			new var11;
			if (movetype[id] != 5 && ladderjump[id] == true)
			{
				notjump[id] = 1;
				ladderjump[id] = 0;
				static i;
				in_air[id] = 1;
				g_Jumped[id] = 1;
				prebhopspeed[id] = 0;
				preduckspeed[id] = 0;
				i = 1;
				while (i < max_players)
				{
					new var12;
					if (id != i && is_spec_user[i])
					{
						if (plrPre[i])
						{
							preladderspeed[id] = speed[id];
							ClearDHUDMessages(i, 8);
							set_dhudmessage(0, 100, 255, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
							show_dhudmessage(i, "%d", floatround(speed[id], "HamFilter"));
						}
					}
					i += 1;
				}
			}
			new var13;
			if (button & 4 && !oldbuttons & 4 && flags & 512)
			{
				if (speed[id] > 1.54E-43)
				{
					ddnum[id]++;
				}
				ddnum[id] = 0;
			}
			new var14;
			if (button & 2 && !oldbuttons & 2 && flags & 512)
			{
				bhop_num[id]++;
				notjump[id] = 0;
				ddnum[id] = 0;
				pev(id, 120, velocity);
				static i;
				in_air[id] = 1;
				g_Jumped[id] = 1;
				i = 1;
				while (i < max_players)
				{
					new var15;
					if (id != i && is_spec_user[i])
					{
						if (plrPre[i])
						{
							if (0 < bhop_num[id])
							{
								preduckspeed[id] = speed[id];
								if (20 < floatround(preladderspeed[id], "HamFilter"))
								{
									bhopgainspeed[id] = preladderspeed[id];
									preladderspeed[id] = 0;
								}
								else
								{
									if (100 < floatround(prebhopspeed[id], "HamFilter"))
									{
										bhopgainspeed[id] = prebhopspeed[id];
										prebhopspeed[id] = 0;
									}
								}
								if (bhopgainspeed[id] > speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(255, 0, 0, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d(-%d)", floatround(speed[id], "HamFilter"), floatround(floatsub(bhopgainspeed[id], speed[id]), "HamFilter"));
								}
								new var16;
								if (0.0 == bhopgainspeed[id] || bhopgainspeed[id] == speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(0, 100, 255, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d", floatround(speed[id], "HamFilter"));
								}
								if (bhopgainspeed[id] < speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(0, 255, 0, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d(+%d)", floatround(speed[id], "HamFilter"), floatround(floatsub(speed[id], bhopgainspeed[id]), "HamFilter"));
								}
							}
						}
					}
					i += 1;
				}
				bhopgainspeed[id] = speed[id];
			}
			else
			{
				new var17;
				if (flags & 512 && in_air[id])
				{
					g_reset[id] = 1;
				}
			}
			new var18;
			// 小跳地速
			if (button & 4 && !oldbuttons & 4 && flags & 512 && !is_user_duck[id])
			{
				new i = 1;
				while (i < max_players)
				{
					new var19;
					if (id != i && is_spec_user[i])
					{
						if (plrPre[i])
						{
							if (0 < ddnum[id])
							{
								prebhopspeed[id] = speed[id];
								if (20 < floatround(preladderspeed[id], "HamFilter"))
								{
									bhopgainspeed[id] = preladderspeed[id];
									preladderspeed[id] = 0;
								}
								else
								{
									if (100 < floatround(preduckspeed[id], "HamFilter"))
									{
										duckgainspeed[id] = preduckspeed[id];
										preduckspeed[id] = 0;
									}
								}
								if (duckgainspeed[id] > speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(255, 0, 0, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d(-%d)", floatround(speed[id], "HamFilter"), floatround(floatsub(duckgainspeed[id], speed[id]), "HamFilter"));
								}
								new var20;
								if (0.0 == duckgainspeed[id] || duckgainspeed[id] == speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(0, 100, 255, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d", floatround(speed[id], "HamFilter"));
								}
								if (duckgainspeed[id] < speed[id])
								{
									ClearDHUDMessages(i, 8);
									set_dhudmessage(0, 255, 0, -1.0, 0.665, 0, 0.0, 3.0, 0.01, 0.0, false);
									show_dhudmessage(i, "%d(+%d)", floatround(speed[id], "HamFilter"), floatround(floatsub(speed[id], duckgainspeed[id]), "HamFilter"));
								}
							}
						}
					}
					i++;
				}
				duckgainspeed[id] = speed[id];
				is_user_duck[id] = 1;
			}
			else
			{
				new var21;
				if (!in_air[id] && oldbuttons & 4 && flags & 512)
				{
					if (!is_user_duckk(id))
					{
						is_user_duck[id] = 0;
					}
				}
			}
			new var22;
			if (flags & 512 && firstfall_ground[id] == true && floatsub(get_gametime(), FallTime[id]) > 1056964608)
			{
				ddnum[id] = 0;
				bhop_num[id] = 0;
				firstfall_ground[id] = 0;
				duckgainspeed[id] = 0;
				prebhopspeed[id] = 0;
				preduckspeed[id] = 0;
				bhopgainspeed[id] = 0;
				preladderspeed[id] = 0;
			}
			new var23;
			if (flags & 512 && firstfall_ground[id])
			{
				FallTime[id] = get_gametime();
				firstfall_ground[id] = 1;
			}
			else
			{
				new var24;
				if (!flags & 512 && firstfall_ground[id] == true)
				{
					firstfall_ground[id] = 0;
				}
			}
		}
	}
	return 1;
}

public FwdPlayerSpawn(id)
{
	new var1;
	if (is_user_alive(id) && !is_user_bot(id) && !is_user_hltv(id))
	{
		g_alive[id] = 1;
	}
	return 0;
}

public FwdPlayerDeath(id)
{
	g_alive[id] = 0;
	return 0;
}

bool:is_user_duckk(id)
{
	if (!pev_valid(id))
	{
		return false;
	}
	new Float:abs_min[3] = 0.0;
	new Float:abs_max[3] = 0.0;
	pev(id, 129, abs_min);
	pev(id, 130, abs_max);
	new var1 = abs_min[2];
	var1 = floatadd(1115684864, var1);
	if (abs_min[2] < abs_max[2])
	{
		return false;
	}
	return true;
}

public client_connect(plr)
{
	g_userConnected[plr] = 1;
	g_pBot[plr] = 0;
	plrPre[plr] = 1;
	ddnum[plr] = 0;
	bhopgainspeed[plr] = 0;
	duckgainspeed[plr] = 0;
	prebhopspeed[plr] = 0;
	preduckspeed[plr] = 0;
	preladderspeed[plr] = 0;
	if (is_user_bot(plr))
	{
		g_pBot[plr] = 1;
	}
	return 0;
}

public client_disconnect(id)
{
	player_admin[id] = 0;
	g_pBot[id] = 0;
	g_userConnected[id] = 0;
	g_alive[id] = 0;
	return 0;
}

is_user_spectating_player(spectator, player)
{
	new var1;
	if (!pev_valid(spectator) || !pev_valid(player))
	{
		return 0;
	}
	new var2;
	if (!is_user_connected(spectator) || !is_user_connected(player))
	{
		return 0;
	}
	new var3;
	if (is_user_alive(spectator) || !is_user_alive(player))
	{
		return 0;
	}
	if (pev(spectator, 80) != 2)
	{
		return 0;
	}
	static specmode;
	specmode = pev(spectator, 100);
	new var4;
	if (specmode == 1 || specmode == 2 || specmode == 4)
	{
		return 0;
	}
	if (player == pev(spectator, 101))
	{
		return 1;
	}
	return 0;
}

