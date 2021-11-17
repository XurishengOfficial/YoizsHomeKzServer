/*
	PRECACHE KIT - Annoying 512 Precache Limit? You have the control now!
		https://forums.alliedmods.net/showthread.php?t=259880
		
- Description:
	. This plugin allows you to check how many files are precached per map and per type (Sounds/Models/Generic)
	You can also check wich files are precached.
	. Another tool that this plugin has is UnPrecache utility, wich allows you to unprecache any file that you want.
	Yet, be careful. If you unprecache one file that is used (for example models/v_knife.mdl), the server will crash.
	
- Requirements:
	. Orpheu -> There isn't any other efficient way to do all of this.
	
- Credits:
	. Hornet -> for orpheu signatures for precache counting and base plugin.
	. Arkshine -> scripting help
	
- Commands:
	. precache_view -> Prints a message to the admin's console with precache information
	
	. precache_viewfull -> Log all the names of precached files at the map
	(You can add this command at amxx.cfg if you want to generate the log at each map start)

- ChangeLogs:
	. v0.0.1 at 14/03/2015 - First Release
	. v0.0.2 at 15/03/2015 - Minor Fixes
*/

#include <amxmodx>
#include <amxmisc>
#include <orpheu>
#include <orpheu_stocks>

new const Version[] = "0.0.2"

enum PrecacheData
{
	Sound,
	Model,
	Generic
}

new g_iPrecacheCount[PrecacheData]

new g_szMapName[32], g_szLogsDir[70]

new Trie:g_tUnPrecache, Trie:g_tSound, Trie:g_tModel, Trie:g_tGeneric

public plugin_init() {
	register_plugin("Precache Kit", Version, "Jhob94")
	
	register_cvar("precache_kit", Version, FCVAR_SPONLY|FCVAR_SERVER)
	set_cvar_string("precache_kit", Version)
	
	get_mapname(g_szMapName, charsmax(g_szMapName))
	get_basedir(g_szLogsDir, charsmax(g_szLogsDir))
	add(g_szLogsDir, charsmax(g_szLogsDir), "/logs/Precache")
	
	register_concmd("precache_view", "View", ADMIN_RCON, ": View the amount of the precached files")
	register_concmd("precache_viewfull", "ViewFull", ADMIN_RCON, ": Log the amount and names of the precached files")
}

public plugin_precache()
{
	g_tUnPrecache = TrieCreate()
	g_tSound = TrieCreate()
	g_tModel = TrieCreate()
	g_tGeneric = TrieCreate()
	
	UnPrecache_Prepare()
	
	OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheSound", "PrecacheSound"), "PrecacheSound")
	OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheModel", "PrecacheModel"), "PrecacheModel")
	OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheGeneric", "PrecacheGeneric"), "PrecacheGeneric")
}

public OrpheuHookReturn:PrecacheSound(const szSound[])
{
	if(TrieKeyExists(g_tUnPrecache, szSound))
		return OrpheuSupercede
		
	g_iPrecacheCount[Sound]++
	
	new szNameTKey[6]
	num_to_str(g_iPrecacheCount[Sound], szNameTKey, charsmax(szNameTKey))
	
	TrieSetString(g_tSound, szNameTKey, szSound)
	return OrpheuIgnored
}

public OrpheuHookReturn:PrecacheModel(const szModel[])
{
	if(TrieKeyExists(g_tUnPrecache, szModel))
		return OrpheuSupercede
		
	g_iPrecacheCount[Model]++
	
	new szNameTKey[6]
	num_to_str(g_iPrecacheCount[Model], szNameTKey, charsmax(szNameTKey))
	
	TrieSetString(g_tModel, szNameTKey, szModel)
	return OrpheuIgnored
}

public OrpheuHookReturn:PrecacheGeneric(const szGeneric[])
{
	if(TrieKeyExists(g_tUnPrecache, szGeneric))
		return OrpheuSupercede
		
	g_iPrecacheCount[Generic]++
	
	new szNameTKey[6]
	num_to_str(g_iPrecacheCount[Generic], szNameTKey, charsmax(szNameTKey))
	
	TrieSetString(g_tGeneric, szNameTKey, szGeneric)
	return OrpheuIgnored
}

public View(id, lvl, cid)
{
	if(!cmd_access(id, lvl, cid, 1))
		return PLUGIN_HANDLED
	
	console_print(id, "*Current Map: %s ^n*Total Precached: %i ^n*Sounds Precached: %i ^n*Models Precached: %i ^n*Generic Precached: %i",
		g_szMapName, g_iPrecacheCount[Sound] + g_iPrecacheCount[Model] + g_iPrecacheCount[Generic],
			g_iPrecacheCount[Sound], g_iPrecacheCount[Model], g_iPrecacheCount[Generic])
	
	return PLUGIN_HANDLED
}

public ViewFull(id, lvl, cid)
{
	if(!cmd_access(id, lvl, cid, 1))
		return PLUGIN_HANDLED
		
	new szNameTKey[6], szSound[101], szModel[101], szGeneric[101]
	DevotionLog("***** INITIALIZING VIEWFULL AT: %s *****", g_szMapName)
	
	DevotionLog("* SOUND PRECACHE ( %i Files ) *", g_iPrecacheCount[Sound])
	for(new i=1; i<=g_iPrecacheCount[Sound]; i++)
	{
		num_to_str(i, szNameTKey, charsmax(szNameTKey))
		
		if(TrieGetString(g_tSound, szNameTKey, szSound, charsmax(szSound)))
			DevotionLog("%s", szSound)
	}
	
	DevotionLog("* MODEL PRECACHE ( %i Files ) *", g_iPrecacheCount[Model])
	for(new i=1; i<=g_iPrecacheCount[Model]; i++)
	{
		num_to_str(i, szNameTKey, charsmax(szNameTKey))
		
		if(TrieGetString(g_tModel, szNameTKey, szModel, charsmax(szModel)))
			DevotionLog("%s", szModel)
	}
		
	DevotionLog("* GENERIC PRECACHE ( %i Files ) *", g_iPrecacheCount[Generic])
	for(new i=1; i<=g_iPrecacheCount[Generic]; i++)
	{
		num_to_str(i, szNameTKey, charsmax(szNameTKey))
		
		if(TrieGetString(g_tGeneric, szNameTKey, szGeneric, charsmax(szGeneric)))
			DevotionLog("%s", szGeneric)
	}
	
	console_print(id, "[ Precache Kit ] Precache logs has been created.")
	return PLUGIN_HANDLED
}

UnPrecache_Prepare()
{
	new szFile[70]
	get_configsdir(szFile, charsmax(szFile))
	format(szFile, charsmax(szFile), "%s/unprecacher.ini", szFile)
	
	new File = fopen(szFile, "rt")
		
	if(File)
	{
		new Data[70]
		
		while(!feof(File))
		{
			fgets(File, Data, charsmax(Data))
			trim(Data)
			
			if(!Data[0] || Data[0] == ';')
				continue
		
			if(!file_exists(Data))
			{
				log_amx("[ PRECACHE KIT ] %s NOT FOUND", Data)
				continue
			}
		
			if(containi(Data, ".wav") != -1)
				replace(Data, charsmax(Data), "sound/", "")
			
			TrieSetCell(g_tUnPrecache, Data, 1)
		}
		
		fclose(File)
	}
}

DevotionLog(const MessageToLog[], any:...)
{
	new Message[101], File[96]
	vformat(Message, charsmax(Message), MessageToLog, 2)
	format(File, charsmax(File), "%s/%s.log", g_szLogsDir, g_szMapName)
	// server_print("precache_viewfull log path is %s", File);
	log_to_file(File, "%s", Message)
}