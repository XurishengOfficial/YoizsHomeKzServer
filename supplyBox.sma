#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define MAXBOX 64
new Float:g_fFunBoxOrigins[MAXBOX+1][3]
new g_iFunBoxCount
public plugin_init()
{
	register_plugin("supplyBox", "1.0", "Unknown")
	register_forward(FM_Touch, "fw_Touch_Post", 1)

	register_clcmd("test233", "SpawnTheBox")
}
public plugin_precache()
{
	precache_model("models/fun_supplybox2.mdl")
	new file[256], config[256], mapname[256]
	get_mapname(mapname, charsmax(mapname))
	get_localinfo("amxx_configsdir", config, charsmax(config))

	formatex(file, charsmax(file), "%s/supplybox/%s.ini", config, mapname)
	if (file_exists(file)) LoadFunBox(file)
}

public LoadFunBox(files[])
{
	OpenBox(files)
}

public OpenBox(files[])
{
	new linedata[192], szOrigin[3][64]
	new file = fopen(files, "rt")
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';' || linedata[0] == '[')
		continue

		parse(linedata, szOrigin[0], charsmax(szOrigin[]), szOrigin[1], charsmax(szOrigin[]), szOrigin[2], charsmax(szOrigin[]))
		g_fFunBoxOrigins[g_iFunBoxCount][0] = floatstr(szOrigin[0])
		g_fFunBoxOrigins[g_iFunBoxCount][1] = floatstr(szOrigin[1])
		g_fFunBoxOrigins[g_iFunBoxCount][2] = floatstr(szOrigin[2])

		g_iFunBoxCount ++
		if (g_iFunBoxCount > MAXBOX)
		break


	}
	if(file) fclose(file)

}

stock Stock_CreateEntityBase(id, classtype[], mvtyp, mdl[], class[], solid, Float:fNext)
{
	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classtype))
	set_pev(pEntity, pev_movetype, mvtyp);
	set_pev(pEntity, pev_owner, id);
	engfunc(EngFunc_SetModel, pEntity, mdl);
	set_pev(pEntity, pev_classname, class);
	set_pev(pEntity, pev_solid, solid);
	set_pev(pEntity, pev_nextthink, get_gametime() + fNext)
	return pEntity
}
public SpawnTheBox()
{
	SpawnBox()
}
public SpawnBox()
{
	client_print(0, print_center, "强化补给箱已经到达！")
	new iEntity, Float:mins[3], Float:maxs[3]
	while ((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "supplybox")) != 0) 
        engfunc(EngFunc_RemoveEntity, iEntity)
	for (new i = 0; i <= g_iFunBoxCount; i ++)
	{
		new iEntity2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		set_pev(iEntity2, pev_classname, "supplybox")
		engfunc(EngFunc_SetModel, iEntity2, "models/fun_supplybox2.mdl")
		pev(iEntity2, pev_mins, mins)
		pev(iEntity2, pev_maxs, maxs)
		engfunc(EngFunc_SetSize, iEntity2, mins, maxs)

		engfunc(EngFunc_SetOrigin, iEntity2, g_fFunBoxOrigins[i])
		set_pev(iEntity2, pev_solid, SOLID_TRIGGER)

		set_pev(iEntity2, pev_movetype, MOVETYPE_TOSS)
		set_pev(iEntity2, pev_skin,random_num(1,10))
		set_pev(iEntity2, pev_animtime, get_gametime())//这个必须有，不然实体是不会动的
		set_pev(iEntity2, pev_framerate, 1.0)//这个必须有，不然实体是不会动的
		set_pev(iEntity2, pev_nextthink, get_gametime() + 0.1)
		//set_pev(iEntity,pev_iuser1,0)
		drop_to_floor(iEntity2)



	}
}

public fw_Touch_Post(iEntity, id)
{
    if (!pev_valid(iEntity))
    return

    new szClassName[32]
    pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
    if (strcmp(szClassName, "supplybox"))
    return

    if (!is_user_alive(id))
    return

    set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);