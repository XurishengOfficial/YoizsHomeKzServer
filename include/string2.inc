/*
string2 v0.1
Copyright (C) 2006-2007 Ian (Juan) Cammarata

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as  published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; go to http://www.opensource.org/licenses/gpl-license.php
Additional String manipulation
*/

#if defined _string2_included
  #endinput
#endif
#define _string2_included

//Replace HTML Special Characters with Entity References
stock htmlspecialchars(string[]){
	new str2[512]
	format(str2,511,string)
	replace(str2,999,"&","&amp;")
	replace(str2,999,"<","&lt;")
	replace(str2,999,">","&gt;")
	return str2
}