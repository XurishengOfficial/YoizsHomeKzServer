/*
	Copyleft 2016 @ HamletEagle
	Plugin Theard: https://forums.alliedmods.net/showthread.php?t=250244

	Entities Resources Replacement is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Entities Resources Replacement; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <amxmisc>
#include <orpheu>
#include <fakemeta>
#include <hamsandwich>
#include <sockets>
#include <orpheu_memory>
#include <orpheu_advanced>
#include <celltravtrie>

#if !defined _orpheu_included
	#assert "orpheu.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=116393"
#endif

#if !defined _orpheu_memory_included
	#assert "orpheu_memory.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=116393"
#endif

#if !defined _orpheu_advanced_included
	#assert "orpheu_advanced.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=116393"
#endif

#if !defined _cell_travtrie_included 
	#assert "celltravtrie.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=250244"
#endif 

#define PluginName    "Entities Resources Replacement"
#define PluginVersion "1.4"
#define PluginAuthor  "HamletEagle"

#define IsInvalidTrie(%0)     (%0 == Invalid_Trie)
#define IsInvalidTravTrie(%0) (%0 == Invalid_TravTrie)
#define IsInvalidArray(%0)    (%0 == Invalid_Array)

enum _:CompleteReplacementData
{
	OldString[128],
	NewString[128]
} 

enum _:WeaponModelData
{
	Flag        [34],
	ViewModel   [128],
	PreviewModel[128],
	WeaponModel [128]
}

enum _:PlayerModelData
{
	PlayerModelName[128],
	PlayerModelIndex
}	

enum
{
	WeaponsModelSection = 1,
	PlayersModelSection,
	SoundsSection,
	SpritesSection
}

enum
{
	CompleteReplacement = 1,
	DynamicReplacement,
	BothReplacement
}

enum _:Hooks
{
	OrpheuHook:CBasePlayerWeapon_DefaulDeploy,
	SetClientKeyValue,
	ClientUserInfoChanged,
	SetModel,
	EmitSound,
	EmitAmbientSound,
	PrecacheModel,
	ClCorpse
}

enum
{
	DestroyArray = 1,
	DestroyTrie
}

new const CompleteReplaceFileName[] = "entities_resources_comp_replace"
new const DynamicReplaceFileName  [] = "entities_resources_dyn_replace"
new const ErrorSearchingForFile   [] = "No configuration file found for specified replacement type"
new const NullItem                [] = "Null"
new const ModelKey                [] = "model"
new const MemoryDataName          [] = "ResString"
new const SoundPath               [] = "sound/"

const PrivateDataSafe     = 2
const m_iModelIndex       = 491
const m_pPlayer           = 41
const XoWeapon            = 4
const XoPlayer            = 5
const ClCorpse_PlayerId   = 12
const TaskIndex = 1735

new Array:HandleCompDataArray
new Trie:HandleWeaponModelsTrie
new Trie:HandleSoundsTrie
new Trie:HandleSpritesTrie
new Trie:HandleMemoryAddressesTrie
new TravTrie:HandlePlayerModelsTrie

new GlobalFilePath[150]
new MapFilePath   [150]
new ConfigsDirPath[80]
new MapName       [32]

new CvarReplacementType
new CvarAdminFlagsReadType
new ReplacementType
new CheckFileStatus
new CompDataArraySize 
new LibraryBaseAddress
new SocketVersionChecker
new MaxPlayers
new gmsgClCorpse
new HandleHooks[Hooks]


/*
	│  ┌─────────────────────────┐
	│  │        MAIN FUNCTIONS   │
	│  └─────────────────────────┘
	│     → plugin_precache
	│      	 	┌ InitializeVersionChecker()
	│       	└ InitializeReplacementType()
	│     → plugin_pause
	│	   	 	└ UnregisterForwards()
	│     → plugin_unpause
	│       	└ RegisterForwards()  
	│     →	plugin_end
	│	        ┌ UnpatchMemory()
	│           ├ UnregisterForwards()     
	│           └ Destroy()
	│     → plugin_natives
	│           ┌ OnERR_FindReplacementType()
	│           └ OnERR_FindReplacedString()    
	│     → InitializeVersionChecker
	│           └ Socket_WaitForResponse
	│     → InitializeReplacementType
	│           ┌ ReadConfigurationFile()
	│           └ InitializeReplacementType()
	│     → ReadConfigurationFile
	│           ┌ GetCompleteReplacementData()
	│           └ GetDynamicReplacementData()
	│	  → GetCompleteReplacementData
	│			└ PatchMemory()
	│	  → GetDynamicReplacementData
	│			└ RegisterForwards()
	│	  → Socket_WaitForResponse
*/

public plugin_precache()
{
	register_plugin
	(
		.plugin_name = PluginName,
		.version     = PluginVersion,
		.author      = PluginAuthor
	)

	CvarReplacementType    = register_cvar("ToggleReplacementType", "3")
	CvarAdminFlagsReadType = register_cvar("AdminFlagsReadType", "0")
	ReplacementType        = get_pcvar_num(CvarReplacementType)

	MaxPlayers = get_maxplayers()

	get_mapname(MapName, charsmax(MapName))
	get_configsdir(ConfigsDirPath, charsmax(ConfigsDirPath))

	InitializeVersionChecker()
	InitializeReplacementType(ReplacementType)
}

/*
	| The logical thing to do here is to do also UnpatchMemory on plugin_pause and PatchMemory in plugin_unpause.
	| That's not suitable, because if someone wants to use an entity with the model you just changed server will crash.
	| This is because when replacing directly in memory old model is not precached by the game, so you get a crash.
	| There are two solutions: also precache the old model when patching memory or just don't run UnpatchMemory when paused.
	| For me, the second way looks better. With first way, we'll loose the point of complete replacement, not increasing precache list. 
	| However, on dynamic replacement, forwards are unregistered/registered correctly.	
	| During plugin_end such scenario can't happen, so it's safe and needed to unpatch.
*/

public plugin_pause()
{
	if
	(
		ReplacementType == DynamicReplacement ||
		ReplacementType == BothReplacement
	)
	{
		UnregisterForwards()
	}
} 

public plugin_unpause()
{
	if
	(
		ReplacementType == DynamicReplacement ||
		ReplacementType == BothReplacement
	)
	{
		RegisterForwards()
	}
}

public plugin_end()
{
	switch(ReplacementType)
	{
		case CompleteReplacement:
		{
			UnpatchMemory()
			Destroy .DestroyType = DestroyArray
			Destroy .DestroyType = DestroyTrie
		}
		case DynamicReplacement:
		{
			UnregisterForwards()
			Destroy .DestroyType = DestroyTrie
		}
		case BothReplacement: 
		{
			UnpatchMemory()
			UnregisterForwards()
			Destroy .DestroyType = DestroyArray
			Destroy .DestroyType = DestroyTrie
		}
	}
}

public plugin_natives()
{
	register_library("err_api")
	register_native("err_find_replace_type"   , "OnERR_FindReplacementType", false)
	register_native("err_find_replaced_string", "OnERR_FindReplacedString" , false)
}

/**
	*  Return replacement type
	*  Check replacement type before using err_find_replaced_string

	*  @return  →  -1 on failure. 
				→  1 for complete replace 
				→  2 for dynamic replace 
				→  3 for both
*/
public OnERR_FindReplacementType(const PluginIndex, const PluginParams)
{
	if(PluginParams)
	{
		log_error(AMX_ERR_NATIVE, "Invalid params number. Expected 0, get: %i", PluginParams)
		return -1
	}
	return ReplacementType
}

/**
	*  This native is for compatibility purpose.
	*  You search for a default string and it will point you to the new one.
	*  Example: →  models/v_ak47.mdl(old string) models/v_m4a1.mdl(new string)
				→ By searching for models/v_ak47.mdl you will get models/v_m4a1.mdl
	*
	*  @param input            The string that you want to search for.
	*  @param output           The buffer in which the found string will be saved.  
	*  @return                 -1 on failure, 1 otherwise
*/
public OnERR_FindReplacedString(const PluginIndex, const PluginParams)
{
	if(PluginParams != 2)
	{
		log_error(AMX_ERR_NATIVE, "Invalid params number. Expected 2, get: %i", PluginParams)
		return -1
	}

	if(ReplacementType == 2)
	{
		log_error(AMX_ERR_NATIVE, "err_find_replaced_string call doesn't allowed in dynamic replacement mode")
		return -1
	}

	new InputString[128], ArrayData[CompleteReplacementData]
	get_string(1, InputString, charsmax(InputString))

	for(new i; i < CompDataArraySize; i++)
	{
		ArrayGetArray(HandleCompDataArray, i, ArrayData)

		if(equal(ArrayData[OldString], InputString))
		{
			set_string(2, ArrayData[NewString], charsmax(ArrayData[NewString]))
			return 1
		}
	}

	return -1
}

InitializeVersionChecker()
{
	new const PageHost[] = "hamletplugins.comyr.com" 
	new SocketError

	do 
	{
		SocketVersionChecker = socket_open(PageHost, 80, SOCKET_TCP, SocketError)
	}
	while(!SocketVersionChecker)

	switch(SocketError) 
	{
		case 0:
		{
			log_amx("Connection was succesfully created")
		}
		case 1: 
		{ 
			log_amx("Socket could not be created") 
			return 
		} 
		case 2: 
		{ 
			log_amx("Failed to connect to the host") 
			return 
		} 
		case 3: 
		{ 
			log_amx("Failed to connect to http port") 
			return 
		} 
	}  

	new Request[528]
	formatex(Request, charsmax(Request), "GET /test.html HTTP/1.1^nHost:%s^r^n^r^n", PageHost)
	socket_send(SocketVersionChecker, Request, charsmax(Request))

	set_task(1.0, "Socket_WaitForResponse", .id = TaskIndex, .flags = "a", .repeat = 25)
}

public Socket_WaitForResponse()
{
	static TaskExecCount
	if(socket_change(SocketVersionChecker, ._timeout = 100000))
	{
		static Response[2600], Buffer[2600], Left[2600], Right[2600] 
		new FullVersionKey[20], EndOfChangeLog[20], FinalVersion[10], CurrentPosition, StartPos, EndPos

		socket_recv(SocketVersionChecker, Response, charsmax(Response))

		new const Version[] = "Version"
		if((StartPos = contain(Response, Version)) != -1) 
		{ 
			EndPos = StartPos + strlen(Version) + 1
			for(new i = EndPos; i < EndPos + 5; i++)
			{
				if(isdigit(Response[i]) || Response[i] == '.')
				{
					FinalVersion[CurrentPosition++] = Response[i]
				}
			}

			if(FinalVersion[0] != EOS)
			{
				if(str_to_float(FinalVersion) > str_to_float(PluginVersion))
				{
					log_amx("Your version %s is outdated. Last version is: %s", PluginVersion, FinalVersion)
					formatex(FullVersionKey, charsmax(FullVersionKey), "V %s:", FinalVersion)

					if((StartPos = contain(Response, FullVersionKey)) != -1) 
					{
						copy(Buffer, charsmax(Buffer), Response[StartPos])
						formatex(EndOfChangeLog, charsmax(EndOfChangeLog), "EndOfLog%s", FinalVersion)

						if((EndPos = contain(Buffer, EndOfChangeLog)) != -1)
						{
							Buffer[EndPos] = EOS
							trim(Buffer)

							replace(Buffer, charsmax(Buffer), "</br>"       , "") 
							replace(Buffer, charsmax(Buffer), FullVersionKey, "") 
							replace(Buffer, charsmax(Buffer), EndOfChangeLog, "")

							log_amx("Changelog for %s", FullVersionKey)
							while(Buffer[0] != EOS && strtok(Buffer, Left, charsmax(Left), Right, charsmax(Right), '|'))
							{
								if(Left[0] != EOS)
								{
									log_amx("+%s", Left)
								} 

								copy(Buffer, charsmax(Buffer), Right)
							}

							remove_task(TaskIndex, false)
							socket_close(SocketVersionChecker)
						}
					}
				}
				else
				{
					log_amx("You are running the latest version of this plugin.") 

					remove_task(TaskIndex, false)
					socket_close(SocketVersionChecker)
				}
			}
		}
	}	

	if(++TaskExecCount >= 25)
	{
		log_amx("Something went wrong while getting information about next version")
		socket_close(SocketVersionChecker)
	}
}

InitializeReplacementType(const Type)
{
	switch(Type)
	{
		case CompleteReplacement:
		{
			LibraryBaseAddress = OrpheuGetLibraryAddress("mod")

			formatex(MapFilePath, charsmax(MapFilePath), "%s/%s-%s.ini", ConfigsDirPath, CompleteReplaceFileName, MapName)
			formatex(GlobalFilePath, charsmax(GlobalFilePath), "%s/%s.ini", ConfigsDirPath, CompleteReplaceFileName)
			ReadConfigurationFile(CompleteReplacement)
		}
		case DynamicReplacement:
		{
			formatex(MapFilePath, charsmax(MapFilePath), "%s/%s-%s.ini", ConfigsDirPath, DynamicReplaceFileName, MapName)
			formatex(GlobalFilePath, charsmax(GlobalFilePath), "%s/%s.ini", ConfigsDirPath, DynamicReplaceFileName)
			ReadConfigurationFile(DynamicReplacement)
		}
		case BothReplacement:
		{
			InitializeReplacementType(CompleteReplacement)
			InitializeReplacementType(DynamicReplacement)
		}
	}
}

ReadConfigurationFile(const Type)
{
	new const ReadFlags[] = "rt"
	new FilePointer = fopen(MapFilePath, ReadFlags)
	
	if(!FilePointer)
	{
		FilePointer = fopen(GlobalFilePath, ReadFlags)
		if(!FilePointer)
		{
			if(ReplacementType != BothReplacement)
			{
				log_amx(ErrorSearchingForFile)
				pause("ad")
			}
			else
			{
				CheckFileStatus = CheckFileStatus + 1
				if(CheckFileStatus == 2)
				{
					log_amx(ErrorSearchingForFile)
					pause("ad")
				}

				return	
			}		
		}
	}

	switch(Type)
	{
		case CompleteReplacement:
		{
			GetCompleteReplacementData(FilePointer)
		}
		case DynamicReplacement:
		{
			GetDynamicReplacementData(FilePointer)
		}
	}
}

GetCompleteReplacementData(FilePointer)
{
	new FileData[256]
	new ArrayData[CompleteReplacementData]
	
	while(!feof(FilePointer))
	{
		fgets(FilePointer, FileData, charsmax(FileData))
		trim(FileData)

		if(!FileData[0] || FileData[0] == ';' || FileData[0] == '#' || FileData[0] == '/')
		{
			continue
		}

		parse
		(
			FileData,
			ArrayData[OldString], charsmax(ArrayData[OldString]),
			ArrayData[NewString], charsmax(ArrayData[NewString])
		)

		if(!file_exists(ArrayData[OldString]) || !file_exists(ArrayData[NewString]))
		{
			log_amx("Pair: [ %s ] [ %s ] has missing resources.", ArrayData[OldString], ArrayData[NewString])
			continue
		}

		if(strlen(ArrayData[OldString]) < strlen(ArrayData[NewString]))
		{
			log_amx("[ %s ] is longer than [ %s ]. Rename it to something shorter.", ArrayData[NewString], ArrayData[OldString])
			continue
		}

		if(containi(ArrayData[NewString], ".mp3") != -1)
		{
			log_amx("[ %s ] is an .mp3 file. Only .wav files are allowed", ArrayData[NewString])
			continue
		}

		if(containi(ArrayData[NewString], ".wav") != -1)
		{
			replace(ArrayData[OldString], charsmax(ArrayData[OldString]), SoundPath, "")
			replace(ArrayData[NewString], charsmax(ArrayData[NewString]), SoundPath, "")
		}

		if(IsInvalidTrie(HandleMemoryAddressesTrie))
		{
			HandleMemoryAddressesTrie = TrieCreate()
		}

		if(IsInvalidArray(HandleCompDataArray))
		{
			HandleCompDataArray = ArrayCreate(CompleteReplacementData)
		}

		ArrayPushArray(HandleCompDataArray, ArrayData)
	}

	fclose(FilePointer)

	if(!IsInvalidArray(HandleCompDataArray))
	{
		CompDataArraySize = ArraySize(HandleCompDataArray)
		PatchMemory()
	}
	else
	{
		if(ReplacementType == BothReplacement)
		{
			CheckFileStatus = CheckFileStatus + 1
		}
		else
		{
			log_amx("Current Complete Replacement file is empty.")
			pause("ad")
		}
	}
}

GetDynamicReplacementData(FilePointer)
{
	new FileData[256], TrieSoundData[128], TrieSpriteData[128], TrieKey[128], FullModelPath[256]
	new TrieWeaponModelData[WeaponModelData], TriePlayerModelData[PlayerModelData]
	new FileSection

	while(!feof(FilePointer))
	{
		fgets(FilePointer, FileData, charsmax(FileData))
		trim(FileData)

		if(!FileData[0] || FileData[0] == ';' || FileData[0] == '#' || FileData[0] == '/')
		{
			continue
		}

		if(FileData[0] == '[')
		{
			FileSection = FileSection + 1
			continue
		}

		switch(FileSection)
		{
			case WeaponsModelSection:
			{
				parse
				(
					FileData,
					TrieWeaponModelData[Flag]        , charsmax(TrieWeaponModelData[Flag        ]),
					TrieKey                          , charsmax(TrieKey                          ),
					TrieWeaponModelData[ViewModel]   , charsmax(TrieWeaponModelData[ViewModel   ]),
					TrieWeaponModelData[PreviewModel], charsmax(TrieWeaponModelData[PreviewModel]),
					TrieWeaponModelData[WeaponModel] , charsmax(TrieWeaponModelData[WeaponModel ])
				)

				file_exists(TrieWeaponModelData[ViewModel]) && !equal(TrieWeaponModelData[ViewModel], NullItem) ?
					precache_model(TrieWeaponModelData[ViewModel]) :
					copy(TrieWeaponModelData[ViewModel], charsmax(TrieWeaponModelData[ViewModel]), NullItem)

				file_exists(TrieWeaponModelData[PreviewModel]) && !equal(TrieWeaponModelData[PreviewModel], NullItem) ?
					precache_model(TrieWeaponModelData[PreviewModel]) :
					copy(TrieWeaponModelData[PreviewModel], charsmax(TrieWeaponModelData[PreviewModel]), NullItem)

				file_exists(TrieWeaponModelData[WeaponModel]) && !equal(TrieWeaponModelData[WeaponModel], NullItem) ?
					precache_model(TrieWeaponModelData[WeaponModel]) :
					copy(TrieWeaponModelData[WeaponModel], charsmax(TrieWeaponModelData[WeaponModel]), NullItem)

				if(IsInvalidTrie(HandleWeaponModelsTrie))
				{
					HandleWeaponModelsTrie = TrieCreate()
				}

				TrieSetArray(HandleWeaponModelsTrie, TrieKey, TrieWeaponModelData, sizeof TrieWeaponModelData)
			}
			case PlayersModelSection:
			{
				parse
				(
					FileData                                               ,
					TrieKey                             , charsmax(TrieKey),
					TriePlayerModelData[PlayerModelName], charsmax(TriePlayerModelData[PlayerModelName])
				)

				formatex(FullModelPath, charsmax(FullModelPath), "models/player/%s/%s.mdl", TriePlayerModelData[PlayerModelName], TriePlayerModelData[PlayerModelName])

				if(!file_exists(FullModelPath))
				{
					log_amx("[ %s ] model is missing.", FullModelPath)
					continue
				}

				if(IsInvalidTravTrie(HandlePlayerModelsTrie))
				{
					HandlePlayerModelsTrie = TravTrieCreate()	
				}

				TriePlayerModelData[PlayerModelIndex] = precache_model(FullModelPath)
				TravTrieSetArray(HandlePlayerModelsTrie, TrieKey, TriePlayerModelData, sizeof TriePlayerModelData)
			}
			case SoundsSection:
			{
				parse
				(
					FileData                              ,
					TrieKey      , charsmax(TrieKey      ),
					TrieSoundData, charsmax(TrieSoundData)
				)

				if(!file_exists(TrieKey) || !file_exists(TrieSoundData))
				{
					log_amx("Pair: [ %s ] [ %s ] has missing resources.", TrieKey, TrieSoundData)
					continue
				}

				if(containi(TrieSoundData, ".mp3") != -1)
				{
					log_amx("[ %s ] is an .mp3 file. Only .wav files are allowed", TrieSoundData)
					continue
				}

				replace(TrieKey      , charsmax(TrieKey      ), SoundPath, "")
				replace(TrieSoundData, charsmax(TrieSoundData), SoundPath, "")

				if(IsInvalidTrie(HandleSoundsTrie))
				{
					HandleSoundsTrie = TrieCreate()
				}

				precache_sound(TrieSoundData)
				TrieSetString(HandleSoundsTrie, TrieKey, TrieSoundData)
			}
			case SpritesSection:
			{
				parse
				(
					FileData      ,
					TrieKey       , charsmax(TrieKey       ),
					TrieSpriteData, charsmax(TrieSpriteData)
				)

				if(!file_exists(TrieSpriteData))
				{
					log_amx("[ %s ] resource is missing", TrieSpriteData)
					continue
				}

				if(IsInvalidTrie(HandleSpritesTrie))
				{
					HandleSpritesTrie = TrieCreate()
				}

				TrieSetString(HandleSpritesTrie, TrieKey, TrieSpriteData)
			}
		}
	}

	fclose(FilePointer)

	if
	(
		IsInvalidTrie    (HandleWeaponModelsTrie) &&
		IsInvalidTrie    (HandleSoundsTrie      ) && 
		IsInvalidTrie    (HandleSpritesTrie     ) &&
		IsInvalidTravTrie(HandlePlayerModelsTrie)
	)
	{
		if(ReplacementType == BothReplacement)
		{
			CheckFileStatus = CheckFileStatus + 1
			if(CheckFileStatus == 2)
			{
				log_amx("Both Replacement files are empty.")
				pause("ad")
			}
		}
		else
		{
			log_amx("Current Dynamic Replacement file is empty.")
			pause("ad")
		}
	}

	RegisterForwards()
}

RegisterForwards()
{
	if(!IsInvalidTrie(HandleWeaponModelsTrie))
	{
		HandleHooks[CBasePlayerWeapon_DefaulDeploy] = _:OrpheuRegisterHook(OrpheuGetFunction("DefaultDeploy", "CBasePlayerWeapon"), "OnCBasePlayerWpn_DefaultDeploy", OrpheuHookPost)
		HandleHooks[SetModel] = register_forward(FM_SetModel, "PfnSetModel", true)
	}

	if(!IsInvalidTravTrie(HandlePlayerModelsTrie))
	{
		if(!gmsgClCorpse)
		{
			gmsgClCorpse = get_user_msgid("ClCorpse")
		}
		
		HandleHooks[SetClientKeyValue    ] = register_forward(FM_SetClientKeyValue    , "PfnSetClientKeyValue"    )
		HandleHooks[ClientUserInfoChanged] = register_forward(FM_ClientUserInfoChanged, "PfnClientUserInfoChanged")
		HandleHooks[ClCorpse             ] = register_message(gmsgClCorpse            , "OnClCorpse_Message"      )
	}

	if(!IsInvalidTrie(HandleSoundsTrie))
	{
		HandleHooks[EmitSound       ] = register_forward(FM_EmitSound       , "PfnEmitSound"       )
		HandleHooks[EmitAmbientSound] = register_forward(FM_EmitAmbientSound, "PfnEmitAmbientSound")		
	}

	if(!IsInvalidTrie(HandleSpritesTrie))
	{
		HandleHooks[PrecacheModel] = register_forward(FM_PrecacheModel, "PfnPrecacheModel")
	}
}

UnregisterForwards()
{
	if(!IsInvalidTrie(HandleWeaponModelsTrie))
	{
		OrpheuUnregisterHook(HandleHooks[CBasePlayerWeapon_DefaulDeploy])
		unregister_forward(FM_SetModel, HandleHooks[SetModel], true)
	}

	if(!IsInvalidTravTrie(HandlePlayerModelsTrie))
	{
		unregister_forward(FM_SetClientKeyValue    , HandleHooks[SetClientKeyValue    ])
		unregister_forward(FM_ClientUserInfoChanged, HandleHooks[ClientUserInfoChanged])
		unregister_message(gmsgClCorpse            , HandleHooks[ClCorpse             ])
	}

	if(!IsInvalidTrie(HandleSoundsTrie))
	{
		unregister_forward(FM_EmitSound       , HandleHooks[EmitSound       ])
		unregister_forward(FM_EmitAmbientSound, HandleHooks[EmitAmbientSound])	
	}

	if(!IsInvalidTrie(HandleSpritesTrie))
	{
		unregister_forward(FM_PrecacheModel, HandleHooks[PrecacheModel])
	}
}

PatchMemory()
{
	new ActualAddress, Address = LibraryBaseAddress, Array:HandleTemporaryArray
	new ArrayData[CompleteReplacementData]

	for(new i; i < CompDataArraySize; i++)
	{
		ArrayGetArray(HandleCompDataArray, i, ArrayData)
		HandleTemporaryArray = ArrayCreate()

		while(OrpheuMemoryReplaceAtAddress(Address, MemoryDataName, 1, ArrayData[OldString], ArrayData[NewString], ActualAddress))
		{
			Address = Address + 4
			ArrayPushCell(HandleTemporaryArray, ActualAddress)
		}

		TrieSetCell(HandleMemoryAddressesTrie, ArrayData[OldString], HandleTemporaryArray)
	}
}

UnpatchMemory()
{
	new ArrayData[CompleteReplacementData], Array:HandleTemporaryArray, TemporaryArraySize

	for(new i; i < CompDataArraySize; i++)
	{
		ArrayGetArray(HandleCompDataArray, i, ArrayData)
		TrieGetCell(HandleMemoryAddressesTrie, ArrayData[OldString], HandleTemporaryArray)

		TemporaryArraySize = ArraySize(HandleTemporaryArray)
		for (new i = 0; i < TemporaryArraySize; i++)
		{
			OrpheuMemoryReplaceAtAddress(ArrayGetCell(HandleTemporaryArray, i), MemoryDataName, 1, ArrayData[NewString], ArrayData[OldString])
		}

		ArrayDestroy(HandleTemporaryArray)
	}
}

Destroy(DestroyType)
{
	switch(DestroyType)
	{
		case DestroyArray:
		{
			if(!IsInvalidArray(HandleCompDataArray))
			{
				ArrayDestroy(HandleCompDataArray)
			}
		}
		case DestroyTrie:
		{
			if(!IsInvalidTrie(HandleWeaponModelsTrie))
			{
				TrieDestroy(HandleWeaponModelsTrie)
			}
			if(!IsInvalidTrie(HandleSoundsTrie))
			{
				TrieDestroy(HandleSoundsTrie)
			}
			if(!IsInvalidTrie(HandleMemoryAddressesTrie))
			{
				TrieDestroy(HandleMemoryAddressesTrie)
			}
			if(!IsInvalidTravTrie(HandlePlayerModelsTrie))
			{
				TravTrieDestroy(HandlePlayerModelsTrie)
			}
		}
	}
}

/*
	│  ┌─────────────────────────┐
	│  │  WEAPON MODELS HOOKS    │
	│  └─────────────────────────┘
	│       → OnCBasePlayerWpn_DefaultDeploy
	│           └ ValidateConditions()
	│       → PfnSetModel
	│		→ ValidateConditions
	│			└ CheckEachCondition()
*/

public OnCBasePlayerWpn_DefaultDeploy(const Entity, const EntityViewModel[], const EntityPreviewModel[])
{
	if(pev_valid(Entity) == PrivateDataSafe)
	{
		if(TrieKeyExists(HandleWeaponModelsTrie, EntityViewModel))
		{
			new TrieWeaponModelData[WeaponModelData]
			TrieGetArray(HandleWeaponModelsTrie, EntityViewModel, TrieWeaponModelData, sizeof TrieWeaponModelData)

			new id = get_pdata_cbase(Entity, m_pPlayer, XoWeapon)
			if(ValidateConditions(id, TrieWeaponModelData[Flag], charsmax(TrieWeaponModelData[Flag])))
			{
				if(!equal(TrieWeaponModelData[ViewModel], NullItem))
				{
					set_pev(id, pev_viewmodel2, TrieWeaponModelData[ViewModel])
				}
				if(!equal(TrieWeaponModelData[PreviewModel], NullItem))
				{
					set_pev(id, pev_weaponmodel2, TrieWeaponModelData[PreviewModel])
				}
			}
		}
	}
}

public PfnSetModel(const Entity, const EntityWeaponModel[])
{
	if(pev_valid(Entity))
	{
		new TrieKey[128]
		formatex(TrieKey, charsmax(TrieKey), "models/v_%s", EntityWeaponModel[9])

		if(TrieKeyExists(HandleWeaponModelsTrie, TrieKey))
		{      
			new TrieWeaponModelData[WeaponModelData]
			TrieGetArray(HandleWeaponModelsTrie, TrieKey, TrieWeaponModelData, sizeof TrieWeaponModelData)

			if(!equal(TrieWeaponModelData[WeaponModel], NullItem))
			{
				engfunc(EngFunc_SetModel, Entity, TrieWeaponModelData[WeaponModel])
			}
		}  
	}    
}

/*
	│  ┌─────────────────────────┐
	│  │  PLAYER MODELS HOOKS    │
	│  └─────────────────────────┘
	│       → PfnSetClientKeyValue
	│           └ RetrieveKeyFromPlayer()
	│       → PfnClientUserInfoChanged
	│           └ RetrieveKeyFromPlayer()
	│       → OnClCorpse_Message
	│           └ RetrieveKeyFromPlayer()
	│		→ RetrieveKeyFromPlayer
	│			└ ValidateConditions()
	│		→ ValidateConditions
	│			└ CheckEachCondition()
*/

public PfnSetClientKeyValue(const id, const Buffer[], const Key[], const OldModel[])
{
	if(equal(Key, ModelKey))
	{      
		new TrieKey[34]
		RetrieveKeyFromPlayer(id, TrieKey, charsmax(TrieKey), OldModel)

		if(TrieKey[0] != EOS)
		{
			new TriePlayerModelData[PlayerModelData]
			TravTrieGetArray(HandlePlayerModelsTrie, TrieKey, TriePlayerModelData, sizeof TriePlayerModelData)

			if(!equal(OldModel, TriePlayerModelData[PlayerModelName]))
			{
				set_user_info(id, ModelKey, TriePlayerModelData[PlayerModelName])
				set_pdata_int(id, m_iModelIndex, TriePlayerModelData[PlayerModelIndex], XoPlayer)
			}
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}      

public PfnClientUserInfoChanged(const id)
{
	if(!is_user_alive(id))
	{
		return FMRES_IGNORED
	}

	new OldModel[128]
	get_user_info(id, ModelKey, OldModel, charsmax(OldModel))

	new TrieKey[34]
	RetrieveKeyFromPlayer(id, TrieKey, charsmax(TrieKey), OldModel)

	if(TrieKey[0] != EOS)
	{
		new TriePlayerModelData[PlayerModelData]
		TravTrieGetArray(HandlePlayerModelsTrie, TrieKey, TriePlayerModelData, sizeof TriePlayerModelData)

		if(!equal(OldModel, TriePlayerModelData[PlayerModelName]))
		{
			set_user_info(id, ModelKey, TriePlayerModelData[PlayerModelName])
			set_pdata_int(id, m_iModelIndex, TriePlayerModelData[PlayerModelIndex], XoPlayer)
		}
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

public OnClCorpse_Message()
{
	new id = get_msg_arg_int(ClCorpse_PlayerId)
	if(!is_user_connected(id))
	{
		return
	}

	new OldModel[128]
	get_user_info(id, ModelKey, OldModel, charsmax(OldModel))

	new TrieKey[34]
	RetrieveKeyFromPlayer(id, TrieKey, charsmax(TrieKey), OldModel)

	if(TrieKey[0] != EOS)
	{      
		new TriePlayerModelData[PlayerModelData]
		TravTrieGetArray(HandlePlayerModelsTrie, TrieKey, TriePlayerModelData, sizeof TriePlayerModelData)

		set_msg_arg_string(1, TriePlayerModelData[PlayerModelName])
	}
}

bool:RetrieveKeyFromPlayer(const id, TrieKey[], const KeySize, const OldModel[] = "")
{
	new TriePlayerModelData[PlayerModelData], Key[34], BackUpKey[34]
	new travTrieIter:TrieIterator = GetTravTrieIterator(HandlePlayerModelsTrie)

	while(MoreTravTrie(TrieIterator)) 
	{
		ReadTravTrieKey(TrieIterator, Key, charsmax(Key))

		if(equal(Key, OldModel))
		{
			copy(TrieKey, KeySize, Key)
			break
		}
		else 
		{
			copy(BackUpKey, charsmax(BackUpKey), Key)
			if(ValidateConditions(id, Key, charsmax(Key)))
			{	
				copy(TrieKey, KeySize, BackUpKey)
				break
			}
		}  

		/*
			| Since ReadTravTrieKey() does not increment the iterator, we need to do this manually.
			| Calling ReadTravTrieArray() is just a hack so we'll reach our goal. 
			| I don't like much this way but it doesn't seem like TravTrie provides a better alternative.
		*/
		ReadTravTrieArray(TrieIterator, TriePlayerModelData, sizeof TriePlayerModelData)
	}                       

	DestroyTravTrieIterator(TrieIterator)
}

/*
	│  ┌─────────────────────────┐
	│  │  SOUND HOOKS            │
	│  └─────────────────────────┘
	│       → PfnEmitSound
	│       → PfnEmitAmbientSound
*/

public PfnEmitSound(const Entity, const Channel, const Sound[], const Float:Volume, const Float:Attenuation, const Flags, const Pitch)
{
	if(pev_valid(Entity))
	{
		if(TrieKeyExists(HandleSoundsTrie, Sound))
		{
			new NewSound[128]
			TrieGetString(HandleSoundsTrie, Sound, NewSound, charsmax(NewSound))

			engfunc(EngFunc_EmitSound, Entity, Channel, NewSound, Volume, Attenuation, Flags, Pitch)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public PfnEmitAmbientSound(const Entity, const Float:Origin[3], const Sound[], const Float:Volume, const Float:Attenuation, const Flags, const Pitch)
{
	if(pev_valid(Entity))
	{
		if(TrieKeyExists(HandleSoundsTrie, Sound))
		{
			new NewSound[128]
			TrieGetString(HandleSoundsTrie, Sound, NewSound, charsmax(NewSound))
			
			engfunc(EngFunc_EmitAmbientSound, Entity, Origin, NewSound, Volume, Attenuation, Flags, Pitch)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

/*
	│  ┌─────────────────────────┐
	│  │  SPRITE HOOKS           │
	│  └─────────────────────────┘
	│       → PfnPrecacheModel
*/

public PfnPrecacheModel(const Model[])
{
	if(TrieKeyExists(HandleSpritesTrie, Model))
	{
		new NewSprite[128]
		TrieGetString(HandleSpritesTrie, Model, NewSprite, charsmax(NewSprite))

		forward_return(FMV_CELL, engfunc(EngFunc_PrecacheModel, NewSprite))
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

bool:ValidateConditions(const id, TrieKey[], const KeySize)
{
	if(contain(TrieKey, "+") != -1)
	{
		new ValidConditions, TotalConditions
		new Left[34], Right[34]

		while(TrieKey[0] != EOS && strtok(TrieKey, Left, charsmax(Left), Right, charsmax(Right), '+'))
		{
			if(equal(Left, "ALL"))
			{
				continue
			}	

			if(CheckEachCondition(id, Left, charsmax(Left)))
			{
				ValidConditions = ValidConditions + 1
			}

			copy(TrieKey, KeySize, Right)
			TotalConditions = TotalConditions + 1
		}

		if(ValidConditions == TotalConditions)
		{   
			return true
		}
	}
	else 
	{
		return CheckEachCondition(id, TrieKey, KeySize)
	}

	return false
}

bool:CheckEachCondition(const id, TrieKey[], const KeySize)
{
	switch(TrieKey[0])
	{
		case 'S':
		{
			if(1 <= id <= MaxPlayers)
			{
				new PlayerAuthId[34]
				get_user_authid(id, PlayerAuthId, charsmax(PlayerAuthId))

				if(equal(PlayerAuthId, TrieKey))
				{
					return true
				}
			}
		}
		case 'F':
		{
			/*
				| Function is called from ClientUserInfoChanged() pre, so before admin.amxx updates admin state.
				| This means that if admin access is received/lost during a round, model won't be immediately updated.
				| A solution is to always use steamid for your admins instead of name.
			
			*/
			new const FlagString[] = "Flag_"

			if(contain(TrieKey, FlagString) != -1)
			{
				replace(TrieKey, KeySize, FlagString, "")

				switch(get_pcvar_num(CvarAdminFlagsReadType))
				{
					case 0:
					{
						if(get_user_flags(id) & read_flags(TrieKey))
						{
							return true
						}
					}
					case 1:
					{
						if(get_user_flags(id)  == read_flags(TrieKey))
						{	
							return true
						}
					}
				}
			}					
		}
		case 'T':
		{
			new UserTeam = get_user_team(id)
			switch(TrieKey[5])
			{
				case 'T':
				{
					if(UserTeam == 1)
					{
						return true
					}
				}
				case 'C':
				{
					if(UserTeam == 2)
					{
						return true
					}
				}
			}
		}
		case 'A':
		{
			return true
		}
	}
	return false 
}