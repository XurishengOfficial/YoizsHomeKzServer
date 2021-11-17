#if defined _vs_myfunc
  #endinput
#endif
#define _vs_myfunc

stock show_lang_hudmessage(index, const message[], any:...)
{
    new buffer[128];
    new numArguments = numargs();

    if (numArguments == 2)
    {
        show_hudmessage(index, message);
    }
    else if (index || numArguments == 3)
    {
		vformat(buffer, charsmax(buffer), message, 3);
		replace_all(buffer, 127, "!g", "");
		replace_all(buffer, 127, "!t", "");
		replace_all(buffer, 127, "!y", "");
		replace_all(buffer, 191, "!n", " ");
		show_hudmessage(index, buffer);
    }
}

stock show_lang_dhudmessage(index, const message[], any:...)
{
    new buffer[128];
    new numArguments = numargs();

    if (numArguments == 2)
    {
        show_hudmessage(index, message);
    }
    else if (index || numArguments == 3)
    {
		vformat(buffer, charsmax(buffer), message, 3);
		replace_all(buffer, 127, "!g", "");
		replace_all(buffer, 127, "!t", "");
		replace_all(buffer, 127, "!y", "");
		replace_all(buffer, 191, "!n", " ");
		show_dhudmessage(index, buffer);
    }
}

public justnumzzz(string1[], count)
{
	new newstr[128];
	new j = 0;
	for (new i = 0; i < count; i++)
	{
		if (string1[i] == 0)
			break;
		if ((string1[i] <= '9' && string1[i] >= '0') || (string1[i] <= 'z' && string1[i] >= 'a') || (string1[i] <= 'Z' && string1[i] >= 'A'))
		{
			newstr[j++] = string1[i];
		}
	}

	copy(string1, j + 1, newstr);
}

#if AMXX_VERSION_NUM < 183
stock strncmp(const string1[], const string2[], count, bool:ignorecase = false)
{
	new result = 0;
	for (new i = 0; i < count; i++)
	{
		result = string1[i] - string2[i];
		if (ignorecase && abs(result) == 32)
			continue;
		if (result != 0 || string2[i] == 0)
			break;
	}
	
	return result;
}
#else
stock ColorLangChat(id, type, const message[], any:...)
{
    new buffer[192];
    new numArguments = numargs();

    if (numArguments == 3)
    {
        client_print_color(id, type, message);
    }
    else if (id || numArguments >= 4)
    {
		vformat(buffer, charsmax(buffer), message, 4);
		replace_all(buffer, 191, "!g", "^4");
		replace_all(buffer, 191, "!t", "^3");
		replace_all(buffer, 191, "!y", "^1");
		replace_all(buffer, 191, "!n", " ");
		client_print_color(id, type, buffer);
    }
}
#endif

public findchar(const string[], count, chr)
{
	for (new i = 0; i < count; i++)
		if (string[i] == chr)
			return i;

	return 0;
}

public isnumber(const src[], start, count)
{
	for (new i = start; i < count && src[i]; i++)
		if (src[i] < '0' || src[i] > '9')
			return false;
	return true;
}

public valid_steam(const authid[])
{
	new len = strlen(authid)
	if (len > 18 || len < 16 || !isnumber(authid, 6, 1) || !isnumber(authid, 8, 1))
		return false;

	new steamid[19];
	copy(steamid, 18, authid)
	steamid[6] = '0';
	steamid[8] = '0';
	if (strncmp(steamid, "STEAM_0:0:", 10, false) != 0 || !isnumber(authid, 10, 8))
		return false;
	return true;
}

/*
Param: 目的字符串，源Int数组，目的字符串可用长度。
*/
public Decode(strAddress[], Src[], SrcLen, DestLen)
{
	for (new i = 0, j = 0; i < SrcLen && i * 4 < DestLen; i++)
	{
		//offset += formatex(strAddress[offset], 4, "%c%c%c%c", Src[i] & 0xFF, (Src[i] >> 8) & 0xFF, (Src[i] >> 16) & 0xFF, (Src[i] >> 24) & 0xFF);
		strAddress[j++] = (Src[i] + 1) & 0xFF;
		strAddress[j++] = ((Src[i] >> 8) + 1) & 0xFF;
		strAddress[j++] = ((Src[i] >> 16) + 1) & 0xFF;
		strAddress[j++] = ((Src[i] >> 24) + 1) & 0xFF;
	}
}

/*
Example:
Code:
new szBigString[] = "This is the big string to explode"
new szOutput[64][128]  // 64 strings of 128 length
SplitStr(szOutput, 64, 127, szBigString, ' ') // Explode string by spaces ' '.. 
*/
public SplitStr(p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter)
{
    new nIdx = 0, l = strlen(p_szInput)
    new nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter ))
    while( (nLen < l) && (++nIdx < p_nMax) )
        nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter ))
    return
}

public SqlEncode(strSrc[])
{
	new buffer[64];
	copy(buffer, 63, strSrc);
	replace_all(buffer, 63, "<", "&lt;");
	replace_all(buffer, 63, ">", "&gt;");
	replace_all(buffer, 63, "^"", "&quot;");
	replace_all(buffer, 63, "'", "&#039;");
	copy(strSrc, 63, buffer);
}

public SqlDecode(strSrc[])
{
	replace_all(strSrc, 63, "&lt;", "<");
	replace_all(strSrc, 63, "&gt;", ">");
	replace_all(strSrc, 63, "&quot;", "^"");
	replace_all(strSrc, 63, "&#039;", "'");
	//copy(Dest, 31, strSrc);
}