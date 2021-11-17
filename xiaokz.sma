new __dhud_color;
new __dhud_x;
new __dhud_y;
new __dhud_effect;
new __dhud_fxtime;
new __dhud_holdtime;
new __dhud_fadeintime;
new __dhud_fadeouttime;
new __dhud_reliable;
new xs__ITaskId = 38;
new xs__ITaskParam[1033] =
{
	38, 0, 38, 97, 109, 112, 59, 0, 60, 0, 38, 108, 116, 59, 0, 62, 0, 38, 103, 116, 59, 0, 16, 16, 52, 60, 0, 84, 69, 82, 82, 79, 82, 73, 83, 84, 0, 67, 84, 0, 83, 80, 69, 67, 84, 65, 84, 79, 82, 0, 0, 0, 0, 83, 97, 121, 84, 101, 120, 116, 0, 0, 0, 84, 101, 97, 109, 73, 110, 102, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 112, 108, 97, 121, 101, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 110, 47, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1007908028, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
new xs__TaskFlags[5] =
{
	38, 0, 38, 97, 109
};
new xs__TaskFunc[48] =
{
	38, 0, 38, 97, 109, 112, 59, 0, 60, 0, 38, 108, 116, 59, 0, 62, 0, 38, 103, 116, 59, 0, 16, 16, 52, 60, 0, 84, 69, 82, 82, 79, 82, 73, 83, 84, 0, 67, 84, 0, 83, 80, 69, 67, 84, 65, 84, 79
};
new xs__TaskId = 38;
new Float:xs__TaskInterval = 38;
new xs__TaskParam[1033] =
{
	38, 0, 38, 97, 109, 112, 59, 0, 60, 0, 38, 108, 116, 59, 0, 62, 0, 38, 103, 116, 59, 0, 16, 16, 52, 60, 0, 84, 69, 82, 82, 79, 82, 73, 83, 84, 0, 67, 84, 0, 83, 80, 69, 67, 84, 65, 84, 79, 82, 0, 0, 0, 0, 83, 97, 121, 84, 101, 120, 116, 0, 0, 0, 84, 101, 97, 109, 73, 110, 102, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 112, 108, 97, 121, 101, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 110, 47, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1007908028, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
new xs__TaskRepeat = 38;
new xs__global_null = 38;
new xs__internalseed = 38;
new xs__logtypenames[6][0] =
{
	{
		2490368, ...
	},
	{
		0, ...
	},
	{
		7602176, ...
	},
	{
		1157627904, ...
	},
	{
		1375731712, ...
	},
	{
		73, ...
	}
};
new xs__maxnum = 38;
new xs__replace_buf[3072] =
{
	38, 0, 38, 97, 109, 112, 59, 0, 60, 0, 38, 108, 116, 59, 0, 62, 0, 38, 103, 116, 59, 0, 16, 16, 52, 60, 0, 84, 69, 82, 82, 79, 82, 73, 83, 84, 0, 67, 84, 0, 83, 80, 69, 67, 84, 65, 84, 79, 82, 0, 0, 0, 0, 83, 97, 121, 84, 101, 120, 116, 0, 0, 0, 84, 101, 97, 109, 73, 110, 102, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 112, 108, 97, 121, 101, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 110, 47, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1007908028, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 110, 47, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
new TeamName[4][0] =
{
	{
		0, ...
	},
	{
		84, ...
	},
	{
		67, ...
	},
	{
		83, ...
	}
};
new savepos_data[500];
new bool:g_bHideMe[33];
new g_iPlayers[32];
new g_iNum;
new String:CLASS_PLAYER[28] = "player";
new g_bitIsPlayerInSphere;
new g_bitIsPlayerAlive;
new g_bitBots;
new bool:REC_AC[33];
new id_spectated[33];
new g_iLastPlayerIndex;
new HamHook:g_iHhPreThink;
new HamHook:g_iHhPreThinkPost;
new g_iFhAddToFullPackPost;
new bool:g_bPreThinkHooked;
new bool:g_bReadPackets;
new bool:g_bClientMessages;

new Array:g_DemoPlaybot[1];
new Array:g_DemoReplay[33];
new Float:g_ReplayBestRunTime;
new Float:g_bestruntime;
new g_ReplayName[32];
new g_bBestTimer[14];
new bool:g_fileRead;
new g_bot_enable;
new g_bot_frame;
new g_bot_id;
new Float:nExttHink = 0.009;
new DATADIR[128];
new g_bot_speed = 1;
new g_authid[32];
new g_date[64];
new g_country[128];

new Array:gc_DemoPlaybot[1];
new Array:gc_DemoReplay[33];
new Float:gc_ReplayBestRunTime;
new Float:gc_bestruntime;
new gc_ReplayName[32];
new gc_bBestTimer[14];
new bool:gc_fileRead;
new gc_bot_enable;
new gc_bot_frame;
new gc_bot_id;
new gc_bot_speed = 1;
new gc_authid[32];
new gc_date[64];
new gc_country[128];

new szGameName[33];
new String:NULLSTR[4];
new WRTime[501];
new WRTimes[501];
new NTTimes[501];
new PRO_PATH[100];
new NUB_PATH[100];
new WPN_PATH[100];
new WEB_URL[64];
new kz_webtop_url;
new num = 100;
new cvar_respawndelay;
new bool:p_lang[33];
new const e_DownloadLinks[3][] = 
{
	"https://xtreme-jumps.eu/demos.txt",	//XJ
	"https://cosy-climbing.net/demoz.txt",	//Cosy
	"http://ntjump.cn/demos.txt"		//NTjump
}

new kz_wr_diff;
new Float:g_flWorldRecordTime[5];
new Float:DiffWRTime[16];
new Float:DiffNTRTime[16];
new norecord;
new g_szWorldRecordPlayer[5][32];
new g_iWorldRecordsNum;
new g_iNtRecordsNum;
new e_UpdatedNR = 1;
new e_LastUpdate[128];
new e_Buffer[25001];
new e_MapName[32];
new e_Records_CC[128];
new e_Records_WR[128];
new e_Records_SU[128];
new e_Records_CR[128];
new cce_CountryText[128];
new cre_CountryText[128];
new counwr[32];
new councr[32];
new rank[32];
new Pro1message[512];
new Nub1message[512];
new Wpn1message[512];
new kz_type_wr[33];
new FL_ONGROUND2 = 34324;
new String:KZ_STARTFILE[40] = "start.ini";
new String:KZ_STARTFILE_TEMP[60] = "temp_start.ini";
new String:KZ_FINISHFILE[44] = "finish.ini";
new String:KZ_FINISHFILE_TEMP[64] = "temp_finish.ini";
new String:g_szDirFile[40] = "kzaxnmaps";
new String:g_szAxnMapFile[52] = "axn_maps.ini";
new Trie:g_tSounds;
new g_szDir[128];
new Float:g_flOldMaxSpeed;
new OrpheuStruct:g_ppmove;
new g_bAxnBhop;
new bool:isFalling[33];
new bool:isMpbhop[33];
new Float:vFallingStart[33][3];
new Float:MpbhopOrigin[33][3];
new Float:vFallingTime[33];
new bool:g_bHideRHA;
new bool:g_bHideTimer;
new bool:g_bHideMoney;
new kz_hiderhr;
new kz_hidetime;
new kz_hidemoney;
new g_msgHideWeapon;
new mp_timelimit;
new addtimemapcount[33];
new bool:wpn_15[33];
new g_playergiveweapon[33];
new g_numerodearma[33];
new Float:Wpn_Timepos[104];
new Wpn_AuthIDS[104][32];
new Wpn_Names[104][32];
new Wpn_Date[104][32];
new Wpn_CheckPoints[104];
new Wpn_GoChecks[104];
new Wpn_Weapon[104][32];
new Wpn_maxspeed[104];
new Float:Pro_Times[104];
new Pro_AuthIDS[104][32];
new Pro_Names[104][32];
new Pro_Date[104][32];
new Float:Noob_Tiempos[104];
new Noob_AuthIDS[104][32];
new Noob_Names[104][32];
new Noob_Date[104][32];
new Noob_CheckPoints[104];
new Noob_GoChecks[104];
new Noob_Weapon[104][32];
new Pro_Country[104][8];
new Noob_Country[104][8];
new Wpn_Country[104][8];
new g_maxplayers;
new max_players;
new Float:gCheckpointAngle[33][3];
new Float:gLastCheckpointAngle[33][3];
new Float:gCheckpointStartAngle[33][3];
new Float:gLastCheckpointStartAngle[33][3];
new Float:CheckpointStarts[33][2][3];
new Float:InPauseCheckpoints[33][2][3];
new Float:antinoclipstart[33];
new Float:antiteleport[33];
new Float:antidiestart[33];
new Float:Checkpoints[33][2][3];
new Float:timer_time[33];
new Float:g_pausetime[33];
new Float:antihookcheat[33];
new g_iHookWallOrigin[33][3];
new Float:SpecLoc[33][3];
new Float:PauseOrigin[33][3];
new Float:SavedStart[33][3];
new Float:SavedStop[33][3];
new hookorigin[33][3];
new Float:DefaultStartPos[3];
new Float:DefaultStopPos[3];
new Float:hp_spec[33];
new Float:SavedTime[33];
new SavedChecks[33];
new SavedGoChecks[33];
new SavedWeapon[33];
new SavedOrigins[33][3];
new SavedVelocity[33][3];
new Float:pausedvelocity[33][3];
new bool:gCheckpoint[33];
new bool:gCheckpointStart[33];
new bool:g_bCpAlternate[33];
new bool:g_bInPauseCpAlternate[33];
new bool:g_bCpAlternateStart[33];
new bool:timer_started[33];
new bool:IsPaused[33];
new bool:WasPlayed[33];
new bool:firstspawn[33];
new bool:canusehook[33];
new bool:ishooked[33];
new bool:GoPosed[33];
new bool:GoPosCp[33];
new bool:GoPosHp[33];
new bool:user_has_scout[33];
new bool:spec_user[33];
new bool:tphook_user[33];
new bool:tptostart[33];
new bool:block_change[33];
new bool:NightVisionUse[33];
new bool:HealsOnMap;
new bool:SlideMap;
new bool:gViewInvisible[33];
new bool:gWaterInvisible[33];
new bool:gWaterEntity[1380];
new bool:gWaterFound;
new bool:DefaultStart;
new bool:DefaultStop;
new bool:GodMap;
new bool:AutoStart[33];
new bool:tpfenabled[33];
new bool:gc1[33];
new Trie:g_tStarts;
new Trie:g_tStops;
new checknumbers[33];
new inpausechecknumbers[33];
new gochecknumbers[33];
new chatorhud[33];
new ShowTime[33];
new MapName[64];
new MapType[32];
new Kzdir[128];
new SavePosDir[128];
new prefix[33];
new Topdir[128];
new kz_admin_check;
new kz_type_wr_num;
new kz_startmoney;
new kz_damage;
new kz_checkpoints;
new kz_spawn_mainmenu;
new kz_show_timer;
new kz_chatorhud;
new kz_hud_color;
new kz_chat_prefix;
new hud_message;
new kz_other_weapons;
new kz_maxspeedmsg;
new kz_drop_weapons;
new kz_remove_drops;
new kz_pick_weapons;
new kz_reload_weapons;
new kz_use_radio;
new kz_hook_sound;
new kz_hook_speed;
new kz_pause;
new kz_noclip_pause;
new kz_nvg;
new kz_nvg_colors;
new kz_vip;
new kz_respawn_ct;
new bool:Autosavepos[33];
new kz_autosavepos;
new kz_save_pos;
new kz_save_autostart;
new kz_top15_authid;
new Sbeam;
new g_msgid_SayText;
new other_weapons[8] =
{
	
};
new other_weapons_name[8][0] =
{

};
new g_weaponconst[31][0] =
{
	
};
new g_weaponsnames[60][0] =
{
	
};
new g_block_commands[8][0] =
{
	
};
Float:operator*(Float:,_:)(Float:oper1, oper2)
{
	return floatmul(oper1, float(oper2));
}

Float:operator/(Float:,_:)(Float:oper1, oper2)
{
	return floatdiv(oper1, float(oper2));
}

Float:operator/(_:,Float:)(oper1, Float:oper2)
{
	return floatdiv(float(oper1), oper2);
}

Float:operator+(Float:,_:)(Float:oper1, oper2)
{
	return floatadd(oper1, float(oper2));
}

Float:operator-(Float:,_:)(Float:oper1, oper2)
{
	return floatsub(oper1, float(oper2));
}

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

bool:operator>(_:,Float:)(oper1, Float:oper2)
{
	return 0 < floatcmp(float(oper1), oper2);
}

bool:operator<(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 > floatcmp(oper1, oper2);
}

bool:operator<(Float:,_:)(Float:oper1, oper2)
{
	return 0 > floatcmp(oper1, float(oper2));
}

bool:operator<=(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 >= floatcmp(oper1, oper2);
}

bool:operator!(Float:)(Float:oper)
{
	return oper & -1 == 0;
}

replace_all(string[], len, what[], with[])
{
	new pos;
	if ((pos = contain(string, what)) == -1)
	{
		return 0;
	}
	new total;
	new with_len = strlen(with);
	new diff = strlen(what) - with_len;
	new total_len = strlen(string);
	new temp_pos;
	while (replace(string[pos], len - pos, what, with))
	{
		pos = with_len + pos;
		total_len -= diff;
		if (!(pos >= total_len))
		{
			temp_pos = contain(string[pos], what);
			if (!(temp_pos == -1))
			{
				pos = temp_pos + pos;
				total++;
			}
			return total;
		}
		return total;
	}
	return total;
}

is_user_admin(id)
{
	new __flags = get_user_flags(id, "amxx_configsdir");
	new var1;
	return __flags > 0 && !__flags & 33554432;
}

get_configsdir(name[], len)
{
	return get_localinfo("amxx_configsdir", name, len);
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
		callfunc_push_str(reason, "amxx_configsdir");
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

get_user_button(id)
{
	return entity_get_int(id, 34);
}

remove_entity_name(eName[])
{
	new iEntity = find_ent_by_class(-1, eName);
	while (0 < iEntity)
	{
		remove_entity(iEntity);
		iEntity = find_ent_by_class(-1, eName);
	}
	return 1;
}

set_entity_flags(ent, flag, onoff)
{
	if (0 < flag & entity_get_int(ent, 27))
	{
		if (onoff == 1)
		{
			return 2;
		}
		entity_set_int(ent, 27, entity_get_int(ent, 27) - flag);
		return 1;
	}
	if (onoff)
	{
		entity_set_int(ent, 27, flag + entity_get_int(ent, 27));
		return 1;
	}
	return 2;
}
// set_dhudmessage(255, 80, 80, -1.0, 0.83, 0, 0.0, 0.0, 0.0, 2.0, false);
set_dhudmessage(red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime, bool:reliable)
{
	__dhud_color = clamp(red, "amxx_configsdir", "") << 16 + clamp(green, "amxx_configsdir", "") << 8 + clamp(blue, "amxx_configsdir", "");
	__dhud_x = x;
	__dhud_y = y;
	__dhud_effect = effects;
	__dhud_fxtime = fxtime;	//0.0
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
		get_players(playersList, numPlayers, "ch", 152);
		if (!numPlayers)
		{
			return 0;
		}
		new Array:handleArrayML = ArrayCreate(1, 32);
		new i = 2;
		new j;
		while (i < numArguments)
		{
			if (getarg(i, "amxx_configsdir") == -1)
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
					setarg(ArrayGetCell(handleArrayML, j), "amxx_configsdir", index);
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
	message_begin(var2, 51, 156, index);
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

htmlspecialchars(string[], _arg1)
{
	new str2[512];
	format(str2, 511, string);
	replace(str2, 999, xs__ITaskId, "&amp;");
	replace(str2, 999, 200, "&lt;");
	replace(str2, 999, 228, "&gt;");
	return str2;
}

ColorChat(id, Color:type, msg[])
{
	new message[1024];
	switch (type)
	{
		case 1:
		{
			message[0] = 1;
		}
		case 2:
		{
			message[0] = 4;
		}
		default:
		{
			message[0] = 3;
		}
	}
	vformat(message[1], 1023, msg, 4);
	message[192] = 0;
	new team;
	new ColorChange;
	new index;
	new MSG_Type;
	if (id)
	{
		MSG_Type = 1;
		index = id;
	}
	else
	{
		index = FindPlayer();
		MSG_Type = 2;
	}
	team = get_user_team(index, {0}, "amxx_configsdir");
	ColorChange = ColorSelection(index, MSG_Type, type);
	ShowColorMessage(index, MSG_Type, message);
	if (ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
	return 0;
}

ShowColorMessage(id, type, message[])
{
	static bool:saytext_used;
	static get_user_msgid_saytext;
	if (!saytext_used)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
		saytext_used = true;
	}
	message_begin(type, get_user_msgid_saytext, 156, id);
	write_byte(id);
	write_string(message);
	message_end();
	return 0;
}

Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if (!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, 156, id);
	write_byte(id);
	write_string(team);
	message_end();
	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch (Type)
	{
		case 4:
		{
			new var1 = TeamName;
			return Team_Info(index, type, var1[0][var1]);
		}
		case 5:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case 6:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		default:
		{
			return 0;
		}
	}
}

FindPlayer()
{
	new i = -1;
	while (get_maxplayers() >= i)
	{
		i++;
		if (is_user_connected(i))
		{
			return i;
		}
	}
	return -1;
}

menu_vadditem(menu, info[], paccess, callback, fmt[])
{
	static buf[128];
	vformat(buf, 127, fmt, 6);
	menu_additem(menu, buf, info, paccess, callback);
	return 0;
}

public plugin_init()
{
	register_plugin("ProKreedz", "2.52", "xiaokz and P");
	g_maxplayers = get_maxplayers();
	mp_timelimit = get_cvar_pointer("mp_timelimit");
	register_menucmd(register_menuid("ServerMenu", "amxx_configsdir"), 1023, "handleServerMenu");
	kz_type_wr_num = register_cvar("kz_type_wr_num", 322848, "amxx_configsdir", "amxx_configsdir");
	kz_hiderhr = register_cvar("kz_hiderhr", 322900, "amxx_configsdir", "amxx_configsdir");
	kz_hidetime = register_cvar("kz_hidetime", 322956, "amxx_configsdir", "amxx_configsdir");
	kz_hidemoney = register_cvar("kz_hidemoney", 323016, "amxx_configsdir", "amxx_configsdir");
	kz_admin_check = register_cvar("kz_admin_check", 323084, "amxx_configsdir", "amxx_configsdir");
	kz_checkpoints = register_cvar("kz_checkpoints", 323152, "amxx_configsdir", "amxx_configsdir");
	kz_spawn_mainmenu = register_cvar("kz_spawn_mainmenu", 323232, "amxx_configsdir", "amxx_configsdir");
	kz_show_timer = register_cvar("kz_show_timer", 323296, "amxx_configsdir", "amxx_configsdir");
	kz_chatorhud = register_cvar("kz_chatorhud", 323356, "amxx_configsdir", "amxx_configsdir");
	kz_startmoney = register_cvar("kz_startmoney", "1337", "amxx_configsdir", "amxx_configsdir");
	kz_chat_prefix = register_cvar("kz_chat_prefix", "[xiaokz]", "amxx_configsdir", "amxx_configsdir");
	kz_hud_color = register_cvar("kz_hud_color", "64 64 64", "amxx_configsdir", "amxx_configsdir");
	kz_other_weapons = register_cvar("kz_other_weapons", 323692, "amxx_configsdir", "amxx_configsdir");
	kz_drop_weapons = register_cvar("kz_drop_weapons", 323764, "amxx_configsdir", "amxx_configsdir");
	kz_remove_drops = register_cvar("kz_remove_drops", 323836, "amxx_configsdir", "amxx_configsdir");
	kz_pick_weapons = register_cvar("kz_pick_weapons", 323908, "amxx_configsdir", "amxx_configsdir");
	kz_reload_weapons = register_cvar("kz_reload_weapons", 323988, "amxx_configsdir", "amxx_configsdir");
	kz_maxspeedmsg = register_cvar("kz_maxspeedmsg", 324056, "amxx_configsdir", "amxx_configsdir");
	kz_hook_sound = register_cvar("kz_hook_sound", 324120, "amxx_configsdir", "amxx_configsdir");
	kz_hook_speed = register_cvar("kz_hook_speed", "300.0", "amxx_configsdir", "amxx_configsdir");
	kz_use_radio = register_cvar("kz_use_radio", 324260, "amxx_configsdir", "amxx_configsdir");
	kz_pause = register_cvar("kz_pause", 324304, "amxx_configsdir", "amxx_configsdir");
	kz_noclip_pause = register_cvar("kz_noclip_pause", 324376, "amxx_configsdir", "amxx_configsdir");
	kz_nvg = register_cvar("kz_nvg", 324412, "amxx_configsdir", "amxx_configsdir");
	kz_nvg_colors = register_cvar("kz_nvg_colors", "64 64 64", "amxx_configsdir", "amxx_configsdir");
	kz_vip = register_cvar("kz_vip", 324540, "amxx_configsdir", "amxx_configsdir");
	kz_respawn_ct = register_cvar("kz_respawn_ct", 324604, "amxx_configsdir", "amxx_configsdir");
	kz_damage = register_cvar("kz_damage", 324652, "amxx_configsdir", "amxx_configsdir");
	kz_save_autostart = register_cvar("kz_save_autostart", 324732, "amxx_configsdir", "amxx_configsdir");
	kz_autosavepos = register_cvar("kz_autosavepos", 324800, "amxx_configsdir", "amxx_configsdir");
	kz_top15_authid = register_cvar("kz_top15_authid", 324872, "amxx_configsdir", "amxx_configsdir");
	kz_save_pos = register_cvar("kz_save_pos", 324928, "amxx_configsdir", "amxx_configsdir");
	max_players = get_maxplayers() + 1;
	kz_webtop_url = register_cvar("kz_webtop_url", "http://localhost:27015", "amxx_configsdir", "amxx_configsdir");
	get_pcvar_string(kz_webtop_url, WEB_URL, "");
	register_clcmd("amx_udwr", "cmdUpdateWRdata", -1, 325184, -1);
	g_msgid_SayText = get_user_msgid("SayText");
	register_clcmd("say", "MsgSay", -1, 325184, -1);
	register_clcmd("say_team", "MsgSay", -1, 325184, -1);
	register_clcmd("say /adminmenu", "KZ_RulesMenu", 8, 325184, -1);
	register_clcmd("say /op", "KZ_RulesMenu", 8, 325184, -1);
	register_clcmd("say /tep", "Teleport", -1, 325184, -1);
	register_clcmd("/cp", "CheckPoint", -1, 325184, -1);
	register_clcmd("/gc", "GoCheck", -1, 325184, -1);
	register_clcmd("/tp", "GoCheck", -1, 325184, -1);
	register_clcmd("/gcf", "GoCheck1", -1, 325184, -1);
	register_clcmd("/gcf", "GoCheck1", -1, 325184, -1);
	register_clcmd("+hook", "hook_on", 8, 325184, -1);
	register_clcmd("-hook", "hook_off", 8, 325184, -1);
	register_clcmd("say /wr", "CmdSayWR", -1, 325184, -1);
	register_clcmd("say /cc", "CmdSayWR", -1, 325184, -1);
	register_clcmd("say /cr", "CmdSayCR", -1, 325184, -1);
	register_clcmd("say /nt", "CmdSayCR", -1, 325184, -1);
	register_clcmd("say /ntr", "CmdSayCR", -1, 325184, -1);
	register_clcmd("/tp", "GoCheck", -1, 325184, -1);
	register_clcmd("say menu", "kz_menu", -1, 325184, -1);
	register_clcmd("addtime", "ExtendTime", 8, 325184, -1);
	register_concmd("drop", "BlockDrop", -1, 326576, -1);
	register_concmd("nightvision", "ToggleNVG", -1, 326576, -1);
	register_concmd("radio1", "BlockRadio", -1, 326576, -1);
	register_concmd("radio2", "BlockRadio", -1, 326576, -1);
	register_concmd("radio3", "BlockRadio", -1, 326576, -1);
	register_concmd("chooseteam", "kz_menu", -1, 326576, -1);
	register_clcmd("chooseteam", "HookCmdChooseTeam", -1, 325184, -1);
	register_clcmd("jointeam", "HookCmdChooseTeam", -1, 325184, -1);
	kz_register_saycmd("duel", "DuelMenu", 0);
	kz_register_saycmd("wrtype", "WRDIFF_Type_Menu", 0);
	kz_register_saycmd("cs", "CheckPointStart", 0);
	kz_register_saycmd("ss", "CheckPointStart", 0);
	kz_register_saycmd("set", "CheckPointStart", 0);
	kz_register_saycmd("cp", "CheckPoint", 0);
	kz_register_saycmd("CheckPoint", "CheckPoint", 0);
	kz_register_saycmd("chatorhud", "ChatHud", 0);
	kz_register_saycmd("ct", "ct", 0);
	kz_register_saycmd("gc", "GoCheck", 0);
	kz_register_saycmd("gocheck", "GoCheck", 0);
	kz_register_saycmd("god", "GodMode", 0);
	kz_register_saycmd("godmode", "GodMode", 0);
	kz_register_saycmd("invis", "InvisMenu", 0);
	kz_register_saycmd("kz", "kz_menu", 0);
	kz_register_saycmd("kreedz", "kz_menu", 0);
	kz_register_saycmd("menu", "kz_menu", 0);
	kz_register_saycmd("kzdemo", "kz_menu", 0);
	kz_register_saycmd("kzcnmenu", "kz_menu", 0);
	kz_register_saycmd("kzcn", "kz_menu", 0);
	kz_register_saycmd("nt", "kz_menu", 0);
	kz_register_saycmd("nc", "noclip", 0);
	kz_register_saycmd("noclip", "noclip", 0);
	kz_register_saycmd("noob10", "NoobTop_show", 0);
	kz_register_saycmd("noob15", "NoobTop_show", 0);
	kz_register_saycmd("nub10", "NoobTop_show", 0);
	kz_register_saycmd("nub15", "NoobTop_show", 0);
	kz_register_saycmd("pause", "Pause", 0);
	kz_register_saycmd(328928, "Pause", 0);
	kz_register_saycmd("pinvis", "cmdInvisible", 0);
	kz_register_saycmd("showtimer", "ShowTimer_Menu", 0);
	kz_register_saycmd("pro10", "ProTop_show", 0);
	kz_register_saycmd("pro15", "ProTop_show", 0);
	kz_register_saycmd("wpn10", "WpnTop_show", 0);
	kz_register_saycmd("wpn15", "WpnTop_show", 0);
	kz_register_saycmd("showpos", "Origin", 8);
	kz_register_saycmd("help", "cmd_help", 0);
	kz_register_saycmd("reset", "reset_checkpoints1", 0);
	kz_register_saycmd("rs", "reset_checkpoints1", 0);
	kz_register_saycmd("respawn", "goStartPos", 0);
	kz_register_saycmd("scout", "cmdScout", 0);
	kz_register_saycmd("setstart", "setStart", 8);
	kz_register_saycmd("setfinish", "setStop", 8);
	kz_register_saycmd("setfs", "setStop", 8);
	kz_register_saycmd("spec", "ct", 0);
	kz_register_saycmd("start", "goStartPos", 0);
	kz_register_saycmd("stuck", "Stuck", 0);
	kz_register_saycmd("ungocheck", "Stuck", 0);
	kz_register_saycmd("teleport", "GoCheck", 0);
	kz_register_saycmd("top15", "top15menu", 0);
	kz_register_saycmd("top10", "top15menu", 0);
	kz_register_saycmd("top", "top15menu", 0);
	kz_register_saycmd("top100", "top15menu", 0);
	kz_register_saycmd("tp", "GoCheck", 0);
	kz_register_saycmd("usp", "cmdUsp", 0);
	kz_register_saycmd("version", "Version", 0);
	kz_register_saycmd("weapons", "weapons", 0);
	kz_register_saycmd("guns", "weapons", 0);
	kz_register_saycmd("winvis", "cmdWaterInvisible", 0);
	set_task(1056964608, "show_Top1msg", "amxx_configsdir", 331020, "amxx_configsdir", 331024, "amxx_configsdir");
	g_msgHideWeapon = get_user_msgid("HideWeapon");
	register_event("ResetHUD", "onResetHUD", 331156, 331164);
	register_message(g_msgHideWeapon, "msgHideWeapon");
	register_event("CurWeapon", "curweapon", "be", "1=1");
	register_event("StatusValue", "Ham_CBasePlayer_PreThink_Post", 331500, "1>0", "2>0");
	register_message(get_user_msgid("StatusIcon"), "Msg_StatusIcon");
	register_forward(28, "FM_PlayerEmitSound", "amxx_configsdir");
	register_forward(__dhud_holdtime, "FM_client_AddToFullPack_Post", 1);
	// #MARK
	register_forward(__dhud_color, "fwdPlayerPreThink", "amxx_configsdir");
	register_forward(109, "fnGetGameDescription", "amxx_configsdir");
	fnUpdateGameName();
	register_forward(FM_CmdStart, "OnCmdStart", "amxx_configsdir");
	new var3 = RegisterHam(57, CLASS_PLAYER, "OnCBasePlayer_PreThink", "amxx_configsdir");
	g_iHhPreThink = var3;
	DisableHamForward(var3);
	new var4 = RegisterHam(57, CLASS_PLAYER, "OnCBasePlayer_PreThink_P", 1);
	g_iHhPreThinkPost = var4;
	DisableHamForward(var4);
	register_forward(123, "OnUpdateClientData_P", 1);
	RegisterHam(43, "func_button", "fwdUse", "amxx_configsdir");
	RegisterHam(11, "player", "Ham_CBasePlayer_Killed_Pre", "amxx_configsdir");
	RegisterHam(11, "player", "Ham_CBasePlayer_Killed_Post", 1);
	RegisterHam(42, "weaponbox", "FwdSpawnWeaponbox", "amxx_configsdir");
	RegisterHam("amxx_configsdir", "player", "FwdHamPlayerSpawn", 1);
	RegisterHam(42, "weaponbox", "GroundWeapon_Touch", "amxx_configsdir");
	RegisterHam(9, "player", "eventHamPlayerDamage", "amxx_configsdir");
	RegisterHam(8, "player", "fw_TraceAttack", "amxx_configsdir");
	RegisterHam(42, "worldspawn", "Ham_HookTouch", "amxx_configsdir");
	RegisterHam(42, "func_wall", "Ham_HookTouch", "amxx_configsdir");
	RegisterHam(42, "func_breakable", "Ham_HookTouch", "amxx_configsdir");
	RegisterHam(42, "player", "Ham_HookTouch", "amxx_configsdir");
	register_message(get_user_msgid("ShowMenu"), "message_show_menu");
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu");
	register_message(get_user_msgid("ScoreAttrib"), "MessageScoreAttrib");
	register_dictionary("prokreedz.txt");
	get_pcvar_string(kz_chat_prefix, prefix, 31);
	get_mapname(MapName, 31);
	register_event("DeathMsg", "event_deathmsg", 334080, 331164);
	cvar_respawndelay = register_cvar("amx_respawndelay", "3.0", "amxx_configsdir", "amxx_configsdir");
	g_bAxnBhop = ReadMaps();
	OrpheuRegisterHook(OrpheuGetFunction("PM_Move", 334204), "OR_PMMove", "amxx_configsdir");
	new OrpheuFunction:orPMJump = OrpheuGetFunction("PM_Jump", 334204);
	OrpheuRegisterHook(orPMJump, "OR_PMJump", "amxx_configsdir");
	OrpheuRegisterHook(orPMJump, "OR_PMJump_P", 1);
	kz_wr_diff = register_cvar("kz_wr_diff", 334412, "amxx_configsdir", "amxx_configsdir");
	get_mapname(e_MapName, 31);
	strtolower(e_MapName);
	new e_Temp[128];
	get_localinfo("amxx_datadir", e_Temp, 127);
	format(e_Temp, 127, "%s/records", e_Temp);
	if (!dir_exists(e_Temp))
	{
		mkdir(e_Temp);
	}
	format(e_Records_WR, 127, "%s/xj.txt", e_Temp);
	format(e_Records_CC, 127, "%s/cc.txt", e_Temp);
	format(e_Records_SU, 127, "%s/su.txt", e_Temp);
	format(e_Records_CR, 127, "%s/nt.txt", e_Temp);
	format(e_LastUpdate, 127, "%s/demos_last_update.ini", e_Temp);
	set_msg_block(get_user_msgid("ClCorpse"), 2);
	register_forward(92, "kz_TimerEntity", "amxx_configsdir");
	new iEnt = engfunc(21, engfunc(43, "info_target"));
	set_pev(iEnt, 1, "kz_time_think");
	set_pev(iEnt, 33, floatadd(1065353216, get_gametime()));
	new kreedz_cfg[128];
	new ConfigDir[64];
	get_configsdir(ConfigDir, 64);
	formatex(Kzdir, __dhud_fadeintime, "%s/kz", ConfigDir);
	if (!dir_exists(Kzdir))
	{
		mkdir(Kzdir);
	}
	formatex(Topdir, __dhud_fadeintime, "%s/top15", Kzdir);
	if (!dir_exists(Topdir))
	{
		mkdir(Topdir);
	}
	formatex(NUB_PATH, 99, "%s/nub_top.html", Kzdir);
	formatex(PRO_PATH, 99, "%s/pro_top.html", Kzdir);
	formatex(WPN_PATH, 99, "%s/Wpn_top.html", Kzdir);
	formatex(SavePosDir, __dhud_fadeintime, "%s/savepos", Kzdir);
	if (!dir_exists(SavePosDir))
	{
		mkdir(SavePosDir);
	}
	formatex(kreedz_cfg, __dhud_fadeintime, "%s/kreedz.cfg", Kzdir);
	if (file_exists(kreedz_cfg))
	{
		server_exec();
		server_cmd("exec %s", kreedz_cfg);
	}
	new i;
	while (i < 8)
	{
		register_clcmd(g_block_commands[i], "BlockBuy", -1, 325184, -1);
		i++;
	}
	g_tStarts = TrieCreate();
	g_tStops = TrieCreate();
	new const szStarts[ ][ ] =
	{
		"counter_start", "clockstartbutton", "firsttimerelay", "but_start", "counter_start_button",
		"multi_start", "timer_startbutton", "start_timer_emi", "gogogo"
	}
	new const szStops[ ][ ]  =
	{
		"counter_off", "clockstopbutton", "clockstop", "but_stop", "counter_stop_button",
		"multi_stop", "stop_counter", "m_counter_end_emi"
	}
	new GodMapsFile[128];
	new MapData[128];
	formatex(GodMapsFile, 127, "%s/GodMaps.ini", Kzdir);
	new f = fopen(GodMapsFile, "rt");
	while (!feof(f) && !GodMap)
	{
		fgets(f, MapData, 127);
		GodMap = equali(MapData, MapName);
	}
	while (i < 9)
	{
		TrieSetCell(g_tStarts, szStarts[i], 1);
		i++;
	}
	while (i < 8)
	{
		TrieSetCell(g_tStops, szStops[i], 1);
		i++;
	}
	register_clcmd("kz_recbotmenu", "ClCmd_ReplayMenu", -1, 325184, -1);
	register_clcmd("kz_nubbotmenu", "ClCmd_ReplayMenu_c", -1, 325184, -1);
	RegisterHam(57, "player", "Ham_PlayerPreThink", "amxx_configsdir");
	// #MARK
	register_forward(92, "fwd_Think", 1);	//FM_Think,
	register_forward(92, "fwd_Think_c", 1);
	new Ent = engfunc(21, engfunc(43, "info_target"));
	set_pev(Ent, 1, "bot_record");	// pev_classname
	set_pev(Ent, 33, 1008981770);	// pev_nextthink 1008981770 -> 0.01 内存中保存的形式
	new i;
	while (i < 33)
	{
		g_DemoReplay[i] = ArrayCreate(9, 1);
		i++;
	}
	g_DemoPlaybot[0] = ArrayCreate(9, 1);
	new i;
	while (i < 33)
	{
		gc_DemoReplay[i] = ArrayCreate(9, 1);
		i++;
	}
	gc_DemoPlaybot[0] = ArrayCreate(9, 1);
	get_localinfo("amxx_datadir", DATADIR, 126);
	ReadBestRunFile();
	ReadBestRunFile_c();

	new szModel[2];
	new iMaxEntities = get_global_int(17);
	g_maxplayers += 1;
	while (g_maxplayers <= iMaxEntities)
	{
		if (is_valid_ent(g_maxplayers) && entity_get_int(g_maxplayers, 32) == 3)
		{
			entity_get_string(g_maxplayers, 2, szModel, 1);
			if (szModel[0] == 42)
			{
				entity_set_int(g_maxplayers, 32, "amxx_configsdir");
			}
		}
	}
	HudApplyCVars();
	return 0;
}

public plugin_precache()
{
	g_tSounds = TrieCreate();
	new szStupidSounds[23][] = {
		new szStupidSounds[][] = {
		"doors/doorstop1.wav", "doors/doorstop2.wav", "doors/doorstop3.wav",
		"player/pl_pain2.wav", "player/pl_pain3.wav","player/pl_pain4.wav",
		"player/pl_pain5.wav", "player/pl_pain6.wav", "player/pl_pain7.wav",
		"player/bhit_kevlar-1.wav", "player/bhit_flesh-1.wav", "player/bhit_flesh-2.wav",
		"player/bhit_flesh-3.wav","player/pl_swim1.wav", "player/pl_swim2.wav",
		"player/pl_swim3.wav", "player/pl_swim4.wav", "player/waterrun.wav", 
		"weapons/knife_hit1.wav", "weapons/knife_hit2.wav", "weapons/knife_hit3.wav",
		"weapons/knife_hit4.wav", "weapons/knife_stab.wav" // "weapons/knife_deploy1.wav", 
		// "items/gunpickup2.wav"
	};
	new i;
	while (i < 23)
	{
		TrieSetCell(g_tSounds, szStupidSounds[i], i);
		i++;
	}
	hud_message = CreateHudSyncObj("amxx_configsdir");
	RegisterHam( Ham_Spawn, "func_door", "FwdHamDoorSpawn", 1 )
	precache_sound("weapons/xbow_hit2.wav");
	precache_sound("kzsound/toprec.wav");
	Sbeam = precache_model("sprites/laserbeam.spr");
	return 0;
}

public plugin_cfg()
{
	new i;
	while (i < num)
	{
		Pro_Times[i] = 1315859240;
		Noob_Tiempos[i] = 1315859240;
		Wpn_Timepos[i] = 1315859240;
		Wpn_maxspeed[i] = 999999999;
		i++;
	}
	read_pro15();
	read_Noob15();
	read_Wpn15();
	new startcheck[100];
	new data[256];
	new map[64];
	new x[13];
	new y[13];
	new z[13];
	formatex(startcheck, 99, "%s/%s", Kzdir, KZ_STARTFILE);
	new f = fopen(startcheck, "rt");
	while (!feof(f))
	{
		fgets( f, data, sizeof data - 1 )
		parse(data, map, 63, x, 12, y, 12, z, 12);
		if (equali(map, MapName))
		{
			DefaultStartPos[0] = str_to_float(x);
			DefaultStartPos[1] = str_to_float(y);
			DefaultStartPos[2] = str_to_float(z);
			DefaultStart = true;
			fclose(f);
			new stopcheck[100];
			new data1[1024];
			new map1[64];
			new x1[13];
			new y1[13];
			new z1[13];
			formatex(stopcheck, 99, "%s/%s", Kzdir, KZ_FINISHFILE);
			new ff = fopen(stopcheck, "rt");
			while (!feof(ff))
			{
				fgets(ff, data1, 1023);
				parse(data1, map1, 63, x1, 12, y1, 12, z1, 12);
				if (equali(map1, MapName, "amxx_configsdir"))
				{
					DefaultStopPos[0] = str_to_float(x1);
					DefaultStopPos[1] = str_to_float(y1);
					DefaultStopPos[2] = str_to_float(z1);
					DefaultStop = true;
					fclose(ff);
					new ent = -1;
					while ((ent = engfunc(12, ent, "classname", "func_water")))
					{
						if (!gWaterFound)
						{
							gWaterFound = true;
						}
						if (ent > -1)
						{
							gWaterEntity[ent] = 1;
						}
					}
					ent = -1;
					while ((ent = engfunc(12, ent, "classname", "func_illusionary")))
					{
						if (pev(ent, 71) == -3)
						{
							if (!gWaterFound)
							{
								gWaterFound = true;
							}
							if (ent > -1)
							{
								gWaterEntity[ent] = 1;
							}
						}
					}
					ent = -1;
					while ((ent = engfunc(12, ent, "classname", "func_conveyor")))
					{
						if (pev(ent, 83) == 3)
						{
							if (!gWaterFound)
							{
								gWaterFound = true;
							}
							if (ent > -1)
							{
								gWaterEntity[ent] = 1;
							}
						}
					}
					if (!(containi(MapName, "slide") != -1))
					{
						new var1;
						if (!(containi(MapName, "climb") == -1 && containi(MapName, "block") == -1))
						{
							if (!(containi(MapName, "bhop") != -1))
							{
								if (!(containi(MapName, "surf") != -1))
								{
									if (containi(MapName, "axn") != -1)
									{
									}
								}
							}
						}
					}
					new var2;
					if (containi(MapName, "cs_") == -1 && containi(MapName, "de_") == -1 && containi(MapName, "ae_strafers_heaven") == -1 && containi(MapName, "esc_dust2_b03") == -1)
					{
						return 0;
					}
					remove_entity_name("player_weaponstrip");
					remove_entity_name("armoury_entity");
					remove_entity_name("info_player_deathmatch");
					remove_entity_name("game_player_equip");
					new Float:tmpflt = 0.0;
					ent = find_ent_by_class(-1, "func_breakable");
					while (0 < ent)
					{
						tmpflt = entity_get_float(ent, 13);
						if (tmpflt < 1.4012E-41)
						{
							remove_entity(ent);
						}
						ent = find_ent_by_class(ent, "func_breakable");
					}
					return 0;
				}
			}
			fclose(ff);
			new ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_water")))
			{
				if (!gWaterFound)
				{
					gWaterFound = true;
				}
				if (ent > -1)
				{
					gWaterEntity[ent] = 1;
				}
			}
			ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_illusionary")))
			{
				if (pev(ent, 71) == -3)
				{
					if (!gWaterFound)
					{
						gWaterFound = true;
					}
					if (ent > -1)
					{
						gWaterEntity[ent] = 1;
					}
				}
			}
			ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_conveyor")))
			{
				if (pev(ent, 83) == 3)
				{
					if (!gWaterFound)
					{
						gWaterFound = true;
					}
					if (ent > -1)
					{
						gWaterEntity[ent] = 1;
					}
				}
			}
			if (!(containi(MapName, "slide") != -1))
			{
				new var1;
				if (!(containi(MapName, "climb") == -1 && containi(MapName, "block") == -1))
				{
					if (!(containi(MapName, "bhop") != -1))
					{
						if (!(containi(MapName, "surf") != -1))
						{
							if (containi(MapName, "axn") != -1)
							{
							}
						}
					}
				}
			}
			new var2;
			if (containi(MapName, "cs_") == -1 && containi(MapName, "de_") == -1 && containi(MapName, "ae_strafers_heaven") == -1 && containi(MapName, "esc_dust2_b03") == -1)
			{
				return 0;
			}
			remove_entity_name("player_weaponstrip");
			remove_entity_name("armoury_entity");
			remove_entity_name("info_player_deathmatch");
			remove_entity_name("game_player_equip");
			new Float:tmpflt = 0.0;
			ent = find_ent_by_class(-1, "func_breakable");
			while (0 < ent)
			{
				tmpflt = entity_get_float(ent, 13);
				if (tmpflt < 1.4012E-41)
				{
					remove_entity(ent);
				}
				ent = find_ent_by_class(ent, "func_breakable");
			}
			return 0;
		}
	}
	fclose(f);
	new stopcheck[100];
	new data1[1024];
	new map1[64];
	new x1[13];
	new y1[13];
	new z1[13];
	formatex(stopcheck, 99, "%s/%s", Kzdir, KZ_FINISHFILE);
	new ff = fopen(stopcheck, "rt");
	while (!feof(ff))
	{
		fgets(ff, data1, 1023);
		parse(data1, map1, 63, x1, 12, y1, 12, z1, 12);
		if (equali(map1, MapName, "amxx_configsdir"))
		{
			DefaultStopPos[0] = str_to_float(x1);
			DefaultStopPos[1] = str_to_float(y1);
			DefaultStopPos[2] = str_to_float(z1);
			DefaultStop = true;
			fclose(ff);
			new ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_water")))
			{
				if (!gWaterFound)
				{
					gWaterFound = true;
				}
				if (ent > -1)
				{
					gWaterEntity[ent] = 1;
				}
			}
			ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_illusionary")))
			{
				if (pev(ent, 71) == -3)
				{
					if (!gWaterFound)
					{
						gWaterFound = true;
					}
					if (ent > -1)
					{
						gWaterEntity[ent] = 1;
					}
				}
			}
			ent = -1;
			while ((ent = engfunc(12, ent, "classname", "func_conveyor")))
			{
				if (pev(ent, 83) == 3)
				{
					if (!gWaterFound)
					{
						gWaterFound = true;
					}
					if (ent > -1)
					{
						gWaterEntity[ent] = 1;
					}
				}
			}
			if (!(containi(MapName, "slide") != -1))
			{
				new var1;
				if (!(containi(MapName, "climb") == -1 && containi(MapName, "block") == -1))
				{
					if (!(containi(MapName, "bhop") != -1))
					{
						if (!(containi(MapName, "surf") != -1))
						{
							if (containi(MapName, "axn") != -1)
							{
							}
						}
					}
				}
			}
			new var2;
			if (containi(MapName, "cs_") == -1 && containi(MapName, "de_") == -1 && containi(MapName, "ae_strafers_heaven") == -1 && containi(MapName, "esc_dust2_b03") == -1)
			{
				return 0;
			}
			remove_entity_name("player_weaponstrip");
			remove_entity_name("armoury_entity");
			remove_entity_name("info_player_deathmatch");
			remove_entity_name("game_player_equip");
			new Float:tmpflt = 0.0;
			ent = find_ent_by_class(-1, "func_breakable");
			while (0 < ent)
			{
				tmpflt = entity_get_float(ent, 13);
				if (tmpflt < 1.4012E-41)
				{
					remove_entity(ent);
				}
				ent = find_ent_by_class(ent, "func_breakable");
			}
			return 0;
		}
	}
	fclose(ff);
	new ent = -1;
	while ((ent = engfunc(12, ent, "classname", "func_water")))
	{
		if (!gWaterFound)
		{
			gWaterFound = true;
		}
		if (ent > -1)
		{
			gWaterEntity[ent] = 1;
		}
	}
	ent = -1;
	while ((ent = engfunc(12, ent, "classname", "func_illusionary")))
	{
		if (pev(ent, 71) == -3)
		{
			if (!gWaterFound)
			{
				gWaterFound = true;
			}
			if (ent > -1)
			{
				gWaterEntity[ent] = 1;
			}
		}
	}
	ent = -1;
	while ((ent = engfunc(12, ent, "classname", "func_conveyor")))
	{
		if (pev(ent, 83) == 3)
		{
			if (!gWaterFound)
			{
				gWaterFound = true;
			}
			if (ent > -1)
			{
				gWaterEntity[ent] = 1;
			}
		}
	}
	if (!(containi(MapName, "slide") != -1))
	{
		new var1;
		if (!(containi(MapName, "climb") == -1 && containi(MapName, "block") == -1))
		{
			if (!(containi(MapName, "bhop") != -1))
			{
				if (!(containi(MapName, "surf") != -1))
				{
					if (containi(MapName, "axn") != -1)
					{
					}
				}
			}
		}
	}
	new var2;
	if (containi(MapName, "cs_") == -1 && containi(MapName, "de_") == -1 && containi(MapName, "ae_strafers_heaven") == -1 && containi(MapName, "esc_dust2_b03") == -1)
	{
		return 0;
	}
	remove_entity_name("player_weaponstrip");
	remove_entity_name("armoury_entity");
	remove_entity_name("info_player_deathmatch");
	remove_entity_name("game_player_equip");
	new Float:tmpflt = 0.0;
	ent = find_ent_by_class(-1, "func_breakable");
	while (0 < ent)
	{
		tmpflt = entity_get_float(ent, 13);
		if (tmpflt < 1.4012E-41)
		{
			remove_entity(ent);
		}
		ent = find_ent_by_class(ent, "func_breakable");
	}
	return 0;
}

ReadBestRunFile_c()
{
	new ArrayData[9];
	new szFile[128];
	new len;
	format(szFile, 127, "%s/records/Nub", DATADIR);
	if (!dir_exists(szFile))
	{
		mkdir(szFile);
	}
	format(szFile, 127, "%s/%s.txt", szFile, MapName);
	if (file_exists(szFile))
	{
		gc_fileRead = true;
		read_file(szFile, 1, gc_ReplayName, "", len);
		read_file(szFile, 2, gc_authid, "", len);
		read_file(szFile, "", gc_date, "", len);
		read_file(szFile, 4, gc_country, "", len);
		new hFile = fopen(szFile, 340812);
		new szData[1024];
		new szBotAngle[2][40], szBotPos[3][60], szBotVel[3][60], szBotButtons[12];
		new line;
		while (!feof(hFile))
		{
			fgets(hFile, szData, 1023);
			new var1;
			if(!szData[0] || szData[0] == '^n')
			{
				if (!line)
				{
					gc_ReplayBestRunTime = str_to_float(szData);
					gc_bestruntime = str_to_float(szData);
					line++;
				}
				strtok(szData, szBotAngle[0][szBotAngle], 39, szData, 1023, 32, 1);
				strtok(szData, szBotAngle[1], 39, szData, 1023, 32, 1);
				strtok(szData, szBotPos[0][szBotPos], 59, szData, 1023, 32, 1);
				strtok(szData, szBotPos[1], 59, szData, 1023, 32, 1);
				strtok(szData, szBotPos[2], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[0][szBotVel], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[1], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[2], 59, szData, 1023, 32, 1);
				strtok(szData, szBotButtons, 11, szData, 1023, 32, 1);
				ArrayData[0] = str_to_float(szBotAngle[0][szBotAngle]);
				ArrayData[1] = str_to_float(szBotAngle[1]);
				ArrayData[2] = str_to_float(szBotPos[0][szBotPos]);
				ArrayData[3] = str_to_float(szBotPos[1]);
				ArrayData[4] = str_to_float(szBotPos[2]);
				ArrayData[5] = str_to_float(szBotVel[0][szBotVel]);
				ArrayData[6] = str_to_float(szBotVel[1]);
				ArrayData[7] = str_to_float(szBotVel[2]);
				ArrayData[8] = str_to_num(szBotButtons);
				ArrayPushArray(gc_DemoPlaybot[0], ArrayData);
				line++;
			}
		}
		fclose(hFile);
		set_task(1077936128, 340852, "amxx_configsdir", 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		return 1;
	}
	return 1;
}

public ClCmd_UpdateReplay_c(id, Float:timer)
{
	new szName[32];
	new authid[32];
	new thetime[64];
	new ip[32];
	new country[128];
	get_user_ip(id, ip, 31, 1);
	ipseeker(ip, "amxx_configsdir", country, 127, 1);
	get_user_name(id, szName, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d - %H:%M:%S", thetime, "");
	gc_ReplayBestRunTime = timer;
	new szFile[128];
	new szData[128];
	format(szFile, 127, "%s/records/Nub/%s.txt", DATADIR, MapName);
	delete_file(szFile);
	new hFile = fopen(szFile, "wt");
	ArrayClear(gc_DemoPlaybot[0]);
	new str[25];
	new nick[64];
	new stm[25];
	new date[64];
	new cty[128];
	formatex(str, 24, "%f\n", gc_ReplayBestRunTime);
	formatex(nick, "", "%s\n", szName);
	formatex(stm, 24, "%s\n", authid);
	formatex(date, "", "%s\n", thetime);
	formatex(cty, 127, "%s\n", country);
	fputs(hFile, str);
	fputs(hFile, nick);
	fputs(hFile, stm);
	fputs(hFile, date);
	fputs(hFile, cty);
	new ArrayData[9];
	new ArrayData2[9];
	new i;
	while (ArraySize(gc_DemoReplay[id]) > i)
	{
		ArrayGetArray(gc_DemoReplay[id], i, ArrayData);
		ArrayData2[0] = ArrayData[0];
		ArrayData2[1] = ArrayData[1];
		ArrayData2[5] = ArrayData[5];
		ArrayData2[6] = ArrayData[6];
		ArrayData2[7] = ArrayData[7];
		ArrayData2[2] = ArrayData[2];
		ArrayData2[3] = ArrayData[3];
		ArrayData2[4] = ArrayData[4];
		ArrayData2[8] = ArrayData[8];
		if (ArraySize(gc_DemoReplay[id]) <= i)
		{
			ArrayPushArray(gc_DemoReplay[id], ArrayData2);
		}
		else
		{
			ArraySetArray(gc_DemoReplay[id], i, ArrayData2);
		}
		formatex(szData, 127, "%f %f %f %f %f %f %f %f %d\n", ArrayData2, ArrayData2[1], ArrayData2[2], ArrayData2[3], ArrayData2[4], ArrayData2[5], ArrayData2[6], ArrayData2[7], ArrayData2[8]);
		fputs(hFile, szData);
		i++;
	}
	fclose(hFile);
	ArrayClear(gc_DemoReplay[id]);
	set_task(1077936128, "bot_overwriting_c", "amxx_configsdir", 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public bot_restart_c()
{
	if (gc_fileRead)
	{
		if (!gc_bot_id)
		{
			gc_bot_id = Create_Bot_c();
		}
		Start_Bot_c();
	}
	return 0;
}

public fwd_Think_c(Ent)
{
	if (!pev_valid(Ent))
	{
		return 1;
	}
	static className[32];
	pev(Ent, 1, className, 31);
	if (equal(className, "bot_record", "amxx_configsdir"))
	{
		BotThink_c(gc_bot_id);
		set_pev(Ent, 33, floatadd(get_gametime(), nExttHink));
	}
	return 1;
}

public BotThink_c(id)
{
	static Float:last_check, Float:game_time, nFrame;
	game_time = get_gametime();
	if( game_time - last_check > 1.0 ) //?帧数时差补偿？
	{
		if (nFrame < 100)
			nExttHink = nExttHink - 0.0001
		else if (nFrame > 100)
			nExttHink = nExttHink + 0.0001

		nFrame = 0;
		last_check = game_time;
	}
	if (gc_bot_enable == 1 && gc_bot_id)
	{
		new i;
		while (i < gc_bot_speed)
		{
			gc_bot_frame += 1;
			i++;
		}
		if (ArraySize(gc_DemoPlaybot[0]) > gc_bot_frame)
		{
			new ArrayData[9];
			new Float:ViewAngles[3];
			ArrayGetArray(gc_DemoPlaybot[0], gc_bot_frame, ArrayData);
			ViewAngles[0] = ArrayData[0];
			ViewAngles[1] = ArrayData[1];
			ViewAngles[2] = 0.0;
			if (ArrayData[8] & 16384)
			{
				ArrayData[8] |= 2;
			}
			if (ArrayData[8] & 4096)
			{
				ArrayData[8] |= 4;
			}
			if (ArrayData[8] & 256)
			{
				engclient_cmd(id, "weapon_knife", 341596, 341600);
				ArrayData[8] &= -257;
			}
			if (ArrayData[8] & 128)
			{
				engclient_cmd(id, "weapon_usp", 341596, 341600);
				ArrayData[8] &= -129;
			}
			engfunc(54, id, ViewAngles, ArrayData[5], ArrayData[6], 0, ArrayData[8], 0, 10);
			set_pev(id, 126, ViewAngles);
			ViewAngles[0] = floatdiv(ViewAngles[0], -1069547520);
			set_pev(id, __dhud_fxtime, ArrayData[5]);
			set_pev(id, __dhud_holdtime, ViewAngles);
			set_pev(id, 118, ArrayData[2]);
			set_pev(id, 81, ArrayData[8]);
			set_pev(id, 41, 1120403456);
			new var2;
			if (pev(id, 76) == 4 && ~pev(id, 84) & 512)
			{
				set_pev(id, 76, 6);
			}
			if (ArraySize(gc_DemoPlaybot[0]) - 1 == nFrame)
			{
				Start_Bot_c();
			}
		}
		else
		{
			start_climb_bot_c(gc_bot_id);
			gc_bot_frame = 0;
		}
	}
	nFrame += 1;
	return 0;
}

public ClCmd_ReplayMenu_c(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		return 1;
	}
	new gc_bot_speedmsg[32];
	if (gc_bot_speed == 4)
	{
		formatex(gc_bot_speedmsg, 31, "PLAY SPEED - \d[\rX4\d]\n");
	}
	else
	{
		if (gc_bot_speed == 1)
		{
			formatex(gc_bot_speedmsg, 31, "PLAY SPEED - \d[\rOFF\d]\n");
		}
		if (gc_bot_speed == 2)
		{
			formatex(gc_bot_speedmsg, 31, "PLAY SPEED - \d[\rX2\d]\n");
		}
	}
	new title[512];
	new szTimer[14];
	StringTimer(gc_ReplayBestRunTime, szTimer, 13, 1);
	formatex(title, 500, "\dSERVER [\yNUB\d] RECORD BOT \rMenu\n\dCode Create by \rPerfectslife\n\n\dMap \y%s \dType \y%s\n\d[\yNUB\d] Time \y%s\n\d[\yNUB\d] by \y%s\n%s", MapName, MapType, szTimer, gc_ReplayName, gc_authid);
	new menu = menu_create(title, "ReplayMenu_Handler_c", "amxx_configsdir");
	menu_additem(menu, "RESTART", 342620, "amxx_configsdir", -1);
	if (gc_bot_enable == 1)
	{
		menu_additem(menu, "PAUSE\n", 342656, "amxx_configsdir", -1);
	}
	else
	{
		menu_additem(menu, "PLAY\n", 342688, "amxx_configsdir", -1);
	}
	menu_additem(menu, gc_bot_speedmsg, 342696, "amxx_configsdir", -1);
	menu_additem(menu, "KICK BOT \d[\rNUB\d]\n\n", 342796, "amxx_configsdir", -1);
	menu_additem(menu, "GO \r[PRO] BOT Menu", 342884, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public ReplayMenu_Handler_c(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			if (!gc_bot_id)
			{
				gc_bot_id = Create_Bot_c();
				ReadBestRunFile_c();
			}
			else
			{
				Start_Bot_c();
			}
			ClCmd_ReplayMenu_c(id);
		}
		case 1:
		{
			if (gc_bot_enable == 1)
			{
				Pause_bot_c(gc_bot_id);
				gc_bot_enable = 2;
			}
			else
			{
				Pause_bot_c(gc_bot_id);
				gc_bot_enable = 1;
			}
			ClCmd_ReplayMenu_c(id);
		}
		case 2:
		{
			if (gc_bot_speed == 1)
			{
				gc_bot_speed = 2;
			}
			else
			{
				if (gc_bot_speed == 2)
				{
					gc_bot_speed = 4;
				}
				if (gc_bot_speed == 4)
				{
					gc_bot_speed = 1;
				}
			}
			ClCmd_ReplayMenu_c(id);
		}
		case 3:
		{
			Remove_Bot_c();
			ClCmd_ReplayMenu_c(id);
		}
		case 4:
		{
			ClCmd_ReplayMenu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public bot_overwriting_c()
{
	ArrayClear(gc_DemoPlaybot[0]);
	ReadBestRunFile_c();
	if (gc_bot_id)
	{
		new txt[64];
		StringTimer(gc_ReplayBestRunTime, gc_bBestTimer, 13, 1);
		formatex(txt, "", "[NUB] %s %s", gc_ReplayName, gc_bBestTimer);
		set_user_info(gc_bot_id, "name", txt);
	}
	return 0;
}

Create_Bot_c()
{
	new txt[64];
	StringTimer(gc_ReplayBestRunTime, gc_bBestTimer, 13, 1);
	formatex(txt, "", "[NUB] %s %s", gc_ReplayName, gc_bBestTimer);
	new id = engfunc(53, txt);
	if (pev_valid(id))
	{
		set_user_info(id, "rate", "10000");
		set_user_info(id, "cl_updaterate", "60");
		set_user_info(id, "cl_cmdrate", "60");
		set_user_info(id, "cl_lw", 343200);
		set_user_info(id, "cl_lc", 343232);
		set_user_info(id, "cl_dlmax", "128");
		set_user_info(id, "cl_righthand", 343344);
		set_user_info(id, "_vgui_menus", 343400);
		set_user_info(id, "_ah", 343424);
		set_user_info(id, "dm", 343444);
		set_user_info(id, "tracker", 343484);
		set_user_info(id, "friends", 343524);
		set_user_info(id, "*bot", 343552);
		set_pev(id, 84, pev(id, 84) | 8192);
		set_pev(id, 85, id);
		dllfunc(8, id, "BOT DEMO2", "127.0.0.1");
		dllfunc(11, id);
		if (!is_user_alive(id))
		{
			dllfunc(1, id);
		}
		set_pev(id, 43, 0);
		cs_set_user_team(id, 1, "amxx_configsdir"); //amxx_configsdir => int 0
		cs_set_user_model(id, "leet");
		give_item(id, "weapon_knife");
		give_item(id, "weapon_usp");
		gc_bot_enable = 1;
		return id;
	}
	return 0;
}

Remove_Bot_c()
{
	server_cmd("kick #%d", get_user_userid(gc_bot_id));
	gc_bot_id = 0;
	gc_bot_enable = 0;
	gc_bot_frame = 0;
	ArrayClear(gc_DemoPlaybot[0]);
	return 0;
}

Start_Bot_c()
{
	gc_bot_frame = 0;
	start_climb_bot_c(gc_bot_id);
	return 0;
}

// 读取Pro Bot
ReadBestRunFile()
{
	new ArrayData[9];
	new szFile[128];
	new len;
	format(szFile, 127, "%s/records/Pro", DATADIR);
	if (!dir_exists(szFile))
	{
		mkdir(szFile);
	}
	format(szFile, 127, "%s/%s.txt", szFile, MapName);
	if (file_exists(szFile))
	{
		g_fileRead = true;
		read_file(szFile, 1, g_ReplayName, "", len);
		read_file(szFile, 2, g_authid, "", len);
		read_file(szFile, "", g_date, "", len);
		read_file(szFile, 4, g_country, "", len);
		// fopen(const file[],const flags[])
		new hFile = fopen(szFile, 343892);
		new szData[1024];
		new szData[1024];
		new szBotAngle[2][40], szBotPos[3][60], szBotVel[3][60], szBotButtons[12];
		new line;
		while (!feof(hFile))
		{
			fgets(hFile, szData, 1023);
			new var1;
			if (!(!szData[0] || szData[0] == '^n'))
			{
				if (!line)
				{
					g_ReplayBestRunTime = str_to_float(szData);
					g_bestruntime = str_to_float(szData);
					line++;
				}
				// 字符串分割
				// strtok(const sSrc[], strL[], lenL, strR[], lenR,ch=' ',trimSpaces = 0)
				strtok(szData, szBotAngle[0][szBotAngle], 39, szData, 1023, 32, 1);
				strtok(szData, szBotAngle[1], 39, szData, 1023, 32, 1);
				strtok(szData, szBotPos[0][szBotPos], 59, szData, 1023, 32, 1);
				strtok(szData, szBotPos[1], 59, szData, 1023, 32, 1);
				strtok(szData, szBotPos[2], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[0][szBotVel], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[1], 59, szData, 1023, 32, 1);
				strtok(szData, szBotVel[2], 59, szData, 1023, 32, 1);
				strtok(szData, szBotButtons, 11, szData, 1023, 32, 1);
				ArrayData[0] = str_to_float(szBotAngle[0][szBotAngle]);
				ArrayData[1] = str_to_float(szBotAngle[1]);
				ArrayData[2] = str_to_float(szBotPos[0][szBotPos]);
				ArrayData[3] = str_to_float(szBotPos[1]);
				ArrayData[4] = str_to_float(szBotPos[2]);
				ArrayData[5] = str_to_float(szBotVel[0][szBotVel]);
				ArrayData[6] = str_to_float(szBotVel[1]);
				ArrayData[7] = str_to_float(szBotVel[2]);
				ArrayData[8] = str_to_num(szBotButtons);
				ArrayPushArray(g_DemoPlaybot[0], ArrayData);
				line++;
			}
		}
		fclose(hFile);
		bot_restart();
		return 1;
	}
	return 1;
}
// #MARK:PRO 保存pro记录 _c是保存存点记录
public ClCmd_UpdateReplay(id, Float:timer)
{
	new szName[32];
	new authid[32];
	new thetime[32];
	new ip[32];
	new country[128];
	get_user_name(id, szName, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d - %H:%M:%S", thetime, "");
	get_user_ip(id, ip, 31, 1);
	ipseeker(ip, "amxx_configsdir", country, 127, 1);
	g_ReplayBestRunTime = timer;
	new szFile[128];
	new szData[128];
	format(szFile, 127, "%s/records/Pro/%s.txt", DATADIR, MapName);
	delete_file(szFile);

	new hFile = fopen(szFile, "wt");
	ArrayClear(g_DemoPlaybot[0]);
	new str[25];
	new nick[64];
	new stm[32];
	new date[32];
	new cty[128];
	formatex(str, 24, "%f\n", g_ReplayBestRunTime);
	formatex(nick, "", "%s\n", szName);
	formatex(stm, 31, "%s\n", authid);
	formatex(date, 31, "%s\n", thetime);
	formatex(cty, 127, "%s\n", country);
	fputs(hFile, str);
	fputs(hFile, nick);
	fputs(hFile, stm);
	fputs(hFile, date);
	fputs(hFile, cty);
	new ArrayData[9];
	new ArrayData2[9];
	new i;// 0
	// g_DemoReplay 33 * 9
	while (ArraySize(g_DemoReplay[id]) > i)
	{
		// 将数据从g_DemoReplay[id] => ArrayData2
		ArrayGetArray(g_DemoReplay[id], i, ArrayData);
		ArrayData2[0] = ArrayData[0];
		ArrayData2[1] = ArrayData[1];
		ArrayData2[5] = ArrayData[5];
		ArrayData2[6] = ArrayData[6];
		ArrayData2[7] = ArrayData[7];
		ArrayData2[2] = ArrayData[2];
		ArrayData2[3] = ArrayData[3];
		ArrayData2[4] = ArrayData[4];
		ArrayData2[8] = ArrayData[8];
		if (ArraySize(g_DemoReplay[id]) <= i)
		{
			ArrayPushArray(g_DemoReplay[id], ArrayData2);
		}
		else
		{
			ArraySetArray(g_DemoReplay[id], i, ArrayData2);
		}
		formatex(szData, 127, "%f %f %f %f %f %f %f %f %d\n", ArrayData2, ArrayData2[1], ArrayData2[2], ArrayData2[3], ArrayData2[4], ArrayData2[5], ArrayData2[6], ArrayData2[7], ArrayData2[8]);
		fputs(hFile, szData);
		i++;
	}
	fclose(hFile);
	ArrayClear(g_DemoReplay[id]);
	set_task(1077936128, "bot_overwriting", "amxx_configsdir", 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public bot_restart()
{
	if (g_fileRead)
	{
		if (!g_bot_id)
		{
			g_bot_id = Create_Bot();
		}
		Start_Bot();
	}
	return 0;
}

// Bot的think相关
public fwd_Think(Ent)
{
	if (!pev_valid(Ent))
	{
		return 1;
	}
	static className[32];
	pev(Ent, 1, className, 31);
	if (equal(className, "bot_record", "amxx_configsdir"))
	{
		BotThink(g_bot_id);
		set_pev(Ent, 33, floatadd(get_gametime(), nExttHink));
	}
	return 1;
}

public BotThink(id)
{
	static nFrame;
	static Float:game_time;
	static Float:last_check;
	game_time = get_gametime();
	if (floatsub(game_time, last_check) > 1065353216)
	{
		if (nFrame < 100)
		{
			nExttHink = floatsub(nExttHink, 953267991);
		}
		else
		{
			if (nFrame > 100)
			{
				nExttHink = floatadd(953267991, nExttHink);
			}
		}
		nFrame = 0;
		last_check = game_time;
	}
	if (g_bot_enable == 1 && g_bot_id)
	{
		new i;
		while (i < g_bot_speed)
		{
			g_bot_frame += 1;
			i++;
		}
		if (ArraySize(g_DemoPlaybot[0]) > g_bot_frame)
		{
			new ArrayData[9];
			new Float:ViewAngles[3] = 0.0;
			ArrayGetArray(g_DemoPlaybot[0], g_bot_frame, ArrayData);
			ViewAngles[0] = ArrayData[0];
			ViewAngles[1] = ArrayData[1];
			ViewAngles[2] = 0.0;
			if (ArrayData[8] & 16384)
			{
				ArrayData[8] |= 2;
			}
			if (ArrayData[8] & 4096)
			{
				ArrayData[8] |= 4;
			}
			if (ArrayData[8] & 256)
			{
				engclient_cmd(id, "weapon_knife", 341596, 341600);
				ArrayData[8] &= -257;
			}
			if (ArrayData[8] & 128)
			{
				engclient_cmd(id, "weapon_usp", 341596, 341600);
				ArrayData[8] &= -129;
			}
			engfunc(54, id, ViewAngles, ArrayData[5], ArrayData[6], 0, ArrayData[8], 0, 10);
			set_pev(id, 126, ViewAngles);
			ViewAngles[0] = floatdiv(ViewAngles[0], -1069547520);
			set_pev(id, __dhud_fxtime, ArrayData[5]);
			set_pev(id, __dhud_holdtime, ViewAngles);
			set_pev(id, 118, ArrayData[2]);
			set_pev(id, 81, ArrayData[8]);
			set_pev(id, 41, 1120403456);
			new var2;
			if (pev(id, 76) == 4 && ~pev(id, 84) & 512)
			{
				set_pev(id, 76, 6);
			}
			if (ArraySize(g_DemoPlaybot[0]) - 1 == nFrame)
			{
				Start_Bot();
			}
		}
		else
		{
			start_climb_bot(g_bot_id);
			g_bot_frame = 0;
		}
	}
	nFrame += 1;
	return 0;
}

// #MARK: 通过preThink获取当前玩家各种状态 包括按键等 用于后续构造bot
public Ham_PlayerPreThink(id)
{
	if (is_user_alive(id))
	{
		if (timer_started[id] && gochecknumbers[id])
		{
			if (!IsPaused[id])
			{
				new ArrayData[9];
				pev(id, 118, ArrayData[2]);	//pev(id, pev_origin, angle) 2 3 4对应xyz
				new Float:angle[3] = 0.0;
				pev(id, 126, angle); // pev(id, pev_v_angle, angle)
				pev(id, __dhud_fxtime, ArrayData[5]);	// pev_velocity
				ArrayData[0] = angle[0];
				ArrayData[1] = angle[1];
				ArrayData[8] = get_user_button(id);	// entity_get_int(id, 34); EV_INT_button
				ArrayPushArray(g_DemoReplay[id], ArrayData);	// g_DemoReplay[id]本身是一个二维数组 用于保存玩家时刻的状态
				/*
					ArrayData
						0~1 pev_v_angle
						2~4 pev_origin
						5~7 pev_velocity
						8	button
				*/
			}
		}
		if (timer_started[id])
		{
			if (!IsPaused[id])
			{
				new ArrayData[9];
				pev(id, 118, ArrayData[2]);
				new Float:angle[3] = 0.0;
				pev(id, 126, angle);
				pev(id, __dhud_fxtime, ArrayData[5]);
				ArrayData[0] = angle[0];
				ArrayData[1] = angle[1];
				ArrayData[8] = get_user_button(id);
				ArrayPushArray(gc_DemoReplay[id], ArrayData);
			}
		}
	}
	return 0;
}

// PRO Bot控制播放菜单
public ClCmd_ReplayMenu(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		return 1;
	}
	new g_bot_speedmsg[32];
	if (g_bot_speed == 4)
	{
		formatex(g_bot_speedmsg, 31, "PLAY SPEED - \d[\rX4\d]\n");
	}
	else
	{
		if (g_bot_speed == 1)
		{
			formatex(g_bot_speedmsg, 31, "PLAY SPEED - \d[\rOFF\d]\n");
		}
		if (g_bot_speed == 2)
		{
			formatex(g_bot_speedmsg, 31, "PLAY SPEED - \d[\rX2\d]\n");
		}
	}
	new title[512];
	new szTimer[14];
	StringTimer(g_ReplayBestRunTime, szTimer, 13, 1);
	formatex(title, 500, "\dSERVER [\yPRO\d] RECORD BOT \rMenu\n\dCode Create by \rPerfectslife\n\n\dMap \y%s \dType \y%s\n\d[\yPRO\d] Time \y%s\n\d[\yPRO\d] by \y%s", MapName, MapType, szTimer, g_ReplayName);
	new menu = menu_create(title, "ReplayMenu_Handler", "amxx_configsdir");
	menu_additem(menu, "RESTART", 345648, "amxx_configsdir", -1);
	if (g_bot_enable == 1)
	{
		menu_additem(menu, "PAUSE\n", 345684, "amxx_configsdir", -1);
	}
	else
	{
		menu_additem(menu, "PLAY\n", 345716, "amxx_configsdir", -1);
	}
	menu_additem(menu, g_bot_speedmsg, 345724, "amxx_configsdir", -1);
	menu_additem(menu, "KICK BOT \d[\rPRO\d]\n\n", 345824, "amxx_configsdir", -1);
	menu_additem(menu, "GO \r[NUB] BOT Menu", 345912, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public ReplayMenu_Handler(id, menu, item)
{
	switch (item)
	{
		case 0:	//RESTART
		{
			if (!g_bot_id)
			{
				g_bot_id = Create_Bot();
				ReadBestRunFile();
			}
			else
			{
				Start_Bot();
			}
			ClCmd_ReplayMenu(id);
		}
		case 1:	//PLAY
		{
			if (g_bot_enable == 1)
			{
				Pause_bot(g_bot_id);
				g_bot_enable = 2;
			}
			else
			{
				Pause_bot(g_bot_id);
				g_bot_enable = 1;
			}
			ClCmd_ReplayMenu(id);
		}
		case 2:	// PLAY SPEED
		{
			if (g_bot_speed == 1)
			{
				g_bot_speed = 2;
			}
			else
			{
				if (g_bot_speed == 2)
				{
					g_bot_speed = 4;
				}
				if (g_bot_speed == 4)
				{
					g_bot_speed = 1;
				}
			}
			ClCmd_ReplayMenu(id);
		}
		case 3:	//KICK BOT
		{
			Remove_Bot();
			ClCmd_ReplayMenu(id);
		}
		case 4:	//GO [NUB]BOT MENU
		{
			ClCmd_ReplayMenu_c(id);
		}
		default:
		{
		}
	}
	return 1;
}

// #MARK: PROBOT 覆盖
public bot_overwriting()
{
	// 将Pro 和 Nub bot的数据读取都并保存在g_DemoPlaybot[0]中
	ArrayClear(g_DemoPlaybot[0]);
	ReadBestRunFile();
	if (g_bot_id)
	{
		new txt[64];
		StringTimer(g_ReplayBestRunTime, g_bBestTimer, 13, 1);
		formatex(txt, "", "[PRO] %s %s", g_ReplayName, g_bBestTimer);
		set_user_info(g_bot_id, "name", txt);
	}
	return 0;
}

Create_Bot()
{
	new txt[64];
	StringTimer(g_ReplayBestRunTime, g_bBestTimer, 13, 1);
	formatex(txt, "", "[PRO] %s %s", g_ReplayName, g_bBestTimer);
	new id = engfunc(53, txt);
	if (pev_valid(id))
	{
		set_user_info(id, "rate", "10000");
		set_user_info(id, "cl_updaterate", "60");
		set_user_info(id, "cl_cmdrate", "60");
		set_user_info(id, "cl_lw", 346228);
		set_user_info(id, "cl_lc", 346260);
		set_user_info(id, "cl_dlmax", "128");
		set_user_info(id, "cl_righthand", 346372);
		set_user_info(id, "_vgui_menus", 346428);
		set_user_info(id, "_ah", 346452);
		set_user_info(id, "dm", 346472);
		set_user_info(id, "tracker", 346512);
		set_user_info(id, "friends", 346552);
		set_user_info(id, "*bot", 346580);
		set_pev(id, 84, pev(id, 84) | 8192);
		set_pev(id, 85, id);
		dllfunc(8, id, "BOT DEMO", "127.0.0.1");
		dllfunc(11, id);
		if (!is_user_alive(id))
		{
			dllfunc(1, id);
		}
		set_pev(id, 43, 0);
		cs_set_user_team(id, 1, "amxx_configsdir");
		cs_set_user_model(id, "leet");
		give_item(id, "weapon_knife");
		give_item(id, "weapon_usp");
		g_bot_enable = 1;
		return id;
	}
	return 0;
}

Remove_Bot()
{
	server_cmd("kick #%d", get_user_userid(g_bot_id));
	g_bot_id = 0;
	g_bot_enable = 0;
	g_bot_frame = 0;
	ArrayClear(g_DemoPlaybot[0]);
	return 0;
}

Start_Bot()
{
	g_bot_frame = 0;
	start_climb_bot(g_bot_id);
	return 0;
}

StringTimer(Float:flRealTime, szOutPut[], iSizeOutPut, bMiliSeconds)
{
	static iSeconds;
	static iMinutes;
	static Float:flTime;
	flTime = flRealTime;
	if (flTime < 0.0)
	{
		flTime = 0.0;
	}
	iMinutes = floatround(flTime / 60, 1);
	iSeconds = floatround(flTime - iMinutes * 60, 1);
	formatex(szOutPut, iSizeOutPut, "%02d:%02d", iMinutes, iSeconds);
	if (bMiliSeconds)
	{
		static iMiliSeconds;
		iMiliSeconds = floatround(flTime - iSeconds + iMinutes * 60 * 100, "amxx_configsdir");
		format(szOutPut, iSizeOutPut, "%s.%02d", szOutPut, iMiliSeconds);
	}
	return 0;
}

public fnUpdateGameName()
{
	static num;
	static id;
	id += 1;
	num = 0;
	switch (id)
	{
		case 2:
		{
			new i = 1;
			while (i <= max_players)
			{
				if (is_user_connected(i))
				{
					if (is_user_admin(i))
					{
						num += 1;
					}
				}
				i++;
			}
			format(szGameName, 32, "Admins Online(%i / %i)", num, max_players);
		}
		case 3:
		{
			format(szGameName, 32, "MapType: %s", MapType);
		}
		case 4:
		{
			format(szGameName, 32, "#KZ Server");
			id = 1;
		}
		default:
		{
		}
	}
	set_task(1086324736, "fnUpdateGameName", "amxx_configsdir", 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public fnGetGameDescription()
{
	forward_return(1, szGameName);
	return 4;
}

public onResetHUD(id, level, cid)
{
	HudApplyCVars();
	new iHideFlags = GetHudHideFlags();
	if (iHideFlags)
	{
		message_begin(1, g_msgHideWeapon, 156, id);
		write_byte(iHideFlags);
		message_end();
	}
	return 0;
}

GetHudHideFlags()
{
	new iFlags;
	if (g_bHideRHA)
	{
		iFlags |= 8;
	}
	if (g_bHideTimer)
	{
		iFlags |= 16;
	}
	if (g_bHideMoney)
	{
		iFlags |= 32;
	}
	return iFlags;
}

public msgHideWeapon()
{
	new iHideFlags = GetHudHideFlags();
	if (iHideFlags)
	{
		set_msg_arg_int(1, 1, iHideFlags | get_msg_arg_int(1));
	}
	return 0;
}

HudApplyCVars()
{
	g_bHideRHA = get_pcvar_num(kz_hiderhr);
	g_bHideTimer = get_pcvar_num(kz_hidetime);
	g_bHideMoney = get_pcvar_num(kz_hidemoney);
	return 0;
}

public cmdUpdateWRdata(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		return 1;
	}
	ColorChat(id, Color:2, "[xiaokz] WR记录更新中,以www.csxiaokz.com网站上显示时间为准,如更新记录与当前不符,请联系管理员更新网站数据!");
	UpdateRecords();
	return 1;
}

public HookCmdChooseTeam(id)
{
	return 1;
}

public message_show_menu(msgid, dest, id)
{
	if (block_change[id])
	{
		return 1;
	}
	message_begin(8, get_user_msgid("ScreenFade"), 347780, id);
	write_short(12288);
	write_short(512);
	write_short("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("");
	message_end();
	static String:team_select[52] = "#Team_Select";
	static menu_text_code[13];
	get_msg_arg_string(4, menu_text_code, 12);
	if (!equal(menu_text_code, team_select, "amxx_configsdir"))
	{
		return 0;
	}
	set_force_team_join_task(id, msgid);
	block_change[id] = 1;
	return 1;
}

public message_vgui_menu(msgid, dest, id)
{
	if (block_change[id])
	{
		return 1;
	}
	message_begin(8, get_user_msgid("ScreenFade"), 347940, id);
	write_short(12288);
	write_short(512);
	write_short("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("");
	message_end();
	if (get_msg_arg_int(1) != 2)
	{
		return 0;
	}
	set_force_team_join_task(id, msgid);
	block_change[id] = 1;
	return 1;
}

set_force_team_join_task(id, menu_msgid)
{
	static param_menu_msgid[2];
	param_menu_msgid[0] = menu_msgid;
	set_task(1036831949, "task_force_team_join", id, param_menu_msgid, 2, 340912, "amxx_configsdir");
	return 0;
}

public task_force_team_join(menu_msgid[], id)
{
	if (get_user_team(id, {0}, "amxx_configsdir"))
	{
		return 0;
	}
	force_team_join(id, menu_msgid[0]);
	return 0;
}

force_team_join(id, menu_msgid)
{
	static String:jointeam[36] = "jointeam";
	static joinclass[10] =
	{
		106, 111, 105, 110, 99, 108, 97, 115, 115, 0
	};
	static msg_block;
	msg_block = get_msg_block(menu_msgid);
	set_msg_block(menu_msgid, 2);
	engclient_cmd(id, jointeam, 348124, 341600);
	engclient_cmd(id, joinclass, 348132, 341600);
	set_msg_block(menu_msgid, msg_block);
	return 0;
}

public ExtendTime(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		return 1;
	}
	new arg[32];
	read_argv(1, arg, 31);
	new curlimit = get_pcvar_num(mp_timelimit);
	new newlimit = str_to_num(arg) + curlimit;
	new name[32];
	get_user_name(id, name, 31);
	if (10 > addtimemapcount[id])
	{
		if (30 > str_to_num(arg))
		{
			set_pcvar_num(mp_timelimit, newlimit);
			new tl = get_timeleft();
			ColorChat(0, Color:2, "%s \x01ADMIN: \x03%s \x01%L\x03 %d \x01Min, TiMe Left: (\x03%d:%02d\x01)", prefix, name, -1, "KZ_ETIME_ADDTIME", str_to_num(arg), tl / 60, tl % 60);
		}
		else
		{
			ColorChat(id, Color:2, "%s \x01%L", prefix, id, "KZ_ETIME_ADDNB");
		}
	}
	else
	{
		ColorChat(id, Color:2, "%s \x01%L", prefix, id, "KZ_ETIME_LOSTIME");
	}
	addtimemapcount[id]++;
	return 1;
}

public client_command(id)
{
	new sArg[13];
	if (11 < read_argv("amxx_configsdir", sArg, 12))
	{
		return 0;
	}
	new i;
	while (i < 60)
	{
		if (equali(g_weaponsnames[i], sArg, "amxx_configsdir"))
		{
			return 1;
		}
		i++;
	}
	return 0;
}

public iRank(_arg0)
{
	if (!(equali(counwr, "err", "amxx_configsdir")))
	{
		if (!(equali(counwr, "AE", "amxx_configsdir")))
		{
			if (!(equali(counwr, "SA", "amxx_configsdir")))
			{
				if (!(equali(counwr, "AR", "amxx_configsdir")))
				{
					if (!(equali(counwr, "AM", "amxx_configsdir")))
					{
						if (!(equali(counwr, "AU", "amxx_configsdir")))
						{
							if (!(equali(counwr, "AT", "amxx_configsdir")))
							{
								if (!(equali(counwr, "AZ", "amxx_configsdir")))
								{
									if (!(equali(counwr, "BD", "amxx_configsdir")))
									{
										if (!(equali(counwr, "BE", "amxx_configsdir")))
										{
											if (!(equali(counwr, "BZ", "amxx_configsdir")))
											{
												if (!(equali(counwr, "BY", "amxx_configsdir")))
												{
													if (!(equali(counwr, "BO", "amxx_configsdir")))
													{
														if (!(equali(counwr, "BA", "amxx_configsdir")))
														{
															if (!(equali(counwr, "BR", "amxx_configsdir")))
															{
																if (!(equali(counwr, "BG", "amxx_configsdir")))
																{
																	if (!(equali(counwr, "CL", "amxx_configsdir")))
																	{
																		if (!(equali(counwr, "CN", "amxx_configsdir")))
																		{
																			if (!(equali(counwr, "HR", "amxx_configsdir")))
																			{
																				if (!(equali(counwr, "CY", "amxx_configsdir")))
																				{
																					if (!(equali(counwr, "TD", "amxx_configsdir")))
																					{
																						if (!(equali(counwr, "ME", "amxx_configsdir")))
																						{
																							if (!(equali(counwr, "CZ", "amxx_configsdir")))
																							{
																								if (!(equali(counwr, "DK", "amxx_configsdir")))
																								{
																									if (!(equali(counwr, "DM", "amxx_configsdir")))
																									{
																										if (!(equali(counwr, "DO", "amxx_configsdir")))
																										{
																											if (!(equali(counwr, "EG", "amxx_configsdir")))
																											{
																												if (!(equali(counwr, "EE", "amxx_configsdir")))
																												{
																													if (!(equali(counwr, "PH", "amxx_configsdir")))
																													{
																														if (!(equali(counwr, "FI", "amxx_configsdir")))
																														{
																															if (!(equali(counwr, "FR", "amxx_configsdir")))
																															{
																																if (!(equali(counwr, "TF", "amxx_configsdir")))
																																{
																																	if (!(equali(counwr, "GH", "amxx_configsdir")))
																																	{
																																		if (!(equali(counwr, "GR", "amxx_configsdir")))
																																		{
																																			if (!(equali(counwr, "GD", "amxx_configsdir")))
																																			{
																																				if (!(equali(counwr, "GL", "amxx_configsdir")))
																																				{
																																					if (!(equali(counwr, "GE", "amxx_configsdir")))
																																					{
																																						if (!(equali(counwr, "GU", "amxx_configsdir")))
																																						{
																																							if (!(equali(counwr, "GF", "amxx_configsdir")))
																																							{
																																								if (!(equali(counwr, "GY", "amxx_configsdir")))
																																								{
																																									if (!(equali(counwr, "ES", "amxx_configsdir")))
																																									{
																																										if (!(equali(counwr, "NL", "amxx_configsdir")))
																																										{
																																											if (!(equali(counwr, "HK", "amxx_configsdir")))
																																											{
																																												if (!(equali(counwr, "IN", "amxx_configsdir")))
																																												{
																																													if (!(equali(counwr, "ID", "amxx_configsdir")))
																																													{
																																														if (!(equali(counwr, "IQ", "amxx_configsdir")))
																																														{
																																															if (!(equali(counwr, "IR", "amxx_configsdir")))
																																															{
																																																if (!(equali(counwr, "IE", "amxx_configsdir")))
																																																{
																																																	if (!(equali(counwr, "IS", "amxx_configsdir")))
																																																	{
																																																		if (!(equali(counwr, "IL", "amxx_configsdir")))
																																																		{
																																																			if (!(equali(counwr, "JM", "amxx_configsdir")))
																																																			{
																																																				if (!(equali(counwr, "JP", "amxx_configsdir")))
																																																				{
																																																					if (!(equali(counwr, "YE", "amxx_configsdir")))
																																																					{
																																																						if (!(equali(counwr, "JE", "amxx_configsdir")))
																																																						{
																																																							if (!(equali(counwr, "JO", "amxx_configsdir")))
																																																							{
																																																								if (!(equali(counwr, "KH", "amxx_configsdir")))
																																																								{
																																																									if (!(equali(counwr, "CA", "amxx_configsdir")))
																																																									{
																																																										if (!(equali(counwr, "QA", "amxx_configsdir")))
																																																										{
																																																											if (!(equali(counwr, "KZ", "amxx_configsdir")))
																																																											{
																																																												if (!(equali(counwr, "KG", "amxx_configsdir")))
																																																												{
																																																													if (!(equali(counwr, "CO", "amxx_configsdir")))
																																																													{
																																																														if (!(equali(counwr, "KR", "amxx_configsdir")))
																																																														{
																																																															if (!(equali(counwr, "KP", "amxx_configsdir")))
																																																															{
																																																																if (!(equali(counwr, "CU", "amxx_configsdir")))
																																																																{
																																																																	if (!(equali(counwr, "KW", "amxx_configsdir")))
																																																																	{
																																																																		if (!(equali(counwr, "LA", "amxx_configsdir")))
																																																																		{
																																																																			if (!(equali(counwr, "LB", "amxx_configsdir")))
																																																																			{
																																																																				if (!(equali(counwr, "LY", "amxx_configsdir")))
																																																																				{
																																																																					if (!(equali(counwr, "LT", "amxx_configsdir")))
																																																																					{
																																																																						if (!(equali(counwr, "LU", "amxx_configsdir")))
																																																																						{
																																																																							if (!(equali(counwr, "LV", "amxx_configsdir")))
																																																																							{
																																																																								if (!(equali(counwr, "MK", "amxx_configsdir")))
																																																																								{
																																																																									if (!(equali(counwr, "MO", "amxx_configsdir")))
																																																																									{
																																																																										if (!(equali(counwr, "MY", "amxx_configsdir")))
																																																																										{
																																																																											if (!(equali(counwr, "MA", "amxx_configsdir")))
																																																																											{
																																																																												if (!(equali(counwr, "MU", "amxx_configsdir")))
																																																																												{
																																																																													if (!(equali(counwr, "MX", "amxx_configsdir")))
																																																																													{
																																																																														if (!(equali(counwr, "MC", "amxx_configsdir")))
																																																																														{
																																																																															if (!(equali(counwr, "MN", "amxx_configsdir")))
																																																																															{
																																																																																if (!(equali(counwr, "NP", "amxx_configsdir")))
																																																																																{
																																																																																	if (!(equali(counwr, "DE", "amxx_configsdir")))
																																																																																	{
																																																																																		if (!(equali(counwr, "NO", "amxx_configsdir")))
																																																																																		{
																																																																																			if (!(equali(counwr, "NZ", "amxx_configsdir")))
																																																																																			{
																																																																																				if (!(equali(counwr, "PK", "amxx_configsdir")))
																																																																																				{
																																																																																					if (!(equali(counwr, "PS", "amxx_configsdir")))
																																																																																					{
																																																																																						if (!(equali(counwr, "PA", "amxx_configsdir")))
																																																																																						{
																																																																																							if (!(equali(counwr, "PE", "amxx_configsdir")))
																																																																																							{
																																																																																								if (!(equali(counwr, "PF", "amxx_configsdir")))
																																																																																								{
																																																																																									if (!(equali(counwr, "PL", "amxx_configsdir")))
																																																																																									{
																																																																																										if (!(equali(counwr, "PT", "amxx_configsdir")))
																																																																																										{
																																																																																											if (!(equali(counwr, "TW", "amxx_configsdir")))
																																																																																											{
																																																																																												if (!(equali(counwr, "ZA", "amxx_configsdir")))
																																																																																												{
																																																																																													if (!(equali(counwr, "CF", "amxx_configsdir")))
																																																																																													{
																																																																																														if (!(equali(counwr, "RU", "amxx_configsdir")))
																																																																																														{
																																																																																															if (!(equali(counwr, "RO", "amxx_configsdir")))
																																																																																															{
																																																																																																if (!(equali(counwr, "EH", "amxx_configsdir")))
																																																																																																{
																																																																																																	if (!(equali(counwr, "MF", "amxx_configsdir")))
																																																																																																	{
																																																																																																		if (!(equali(counwr, "RS", "amxx_configsdir")))
																																																																																																		{
																																																																																																			if (!(equali(counwr, "SG", "amxx_configsdir")))
																																																																																																			{
																																																																																																				if (!(equali(counwr, "SK", "amxx_configsdir")))
																																																																																																				{
																																																																																																					if (!(equali(counwr, "SI", "amxx_configsdir")))
																																																																																																					{
																																																																																																						if (!(equali(counwr, "LK", "amxx_configsdir")))
																																																																																																						{
																																																																																																							if (!(equali(counwr, "US", "amxx_configsdir")))
																																																																																																							{
																																																																																																								if (!(equali(counwr, "SD", "amxx_configsdir")))
																																																																																																								{
																																																																																																									if (!(equali(counwr, "SY", "amxx_configsdir")))
																																																																																																									{
																																																																																																										if (!(equali(counwr, "CH", "amxx_configsdir")))
																																																																																																										{
																																																																																																											if (!(equali(counwr, "SE", "amxx_configsdir")))
																																																																																																											{
																																																																																																												if (!(equali(counwr, "TJ", "amxx_configsdir")))
																																																																																																												{
																																																																																																													if (!(equali(counwr, "TH", "amxx_configsdir")))
																																																																																																													{
																																																																																																														if (!(equali(counwr, "TZ", "amxx_configsdir")))
																																																																																																														{
																																																																																																															if (!(equali(counwr, "TN", "amxx_configsdir")))
																																																																																																															{
																																																																																																																if (!(equali(counwr, "TR", "amxx_configsdir")))
																																																																																																																{
																																																																																																																	if (!(equali(counwr, "TM", "amxx_configsdir")))
																																																																																																																	{
																																																																																																																		if (!(equali(counwr, "UA", "amxx_configsdir")))
																																																																																																																		{
																																																																																																																			if (!(equali(counwr, "UY", "amxx_configsdir")))
																																																																																																																			{
																																																																																																																				if (!(equali(counwr, "UZ", "amxx_configsdir")))
																																																																																																																				{
																																																																																																																					if (!(equali(counwr, "VE", "amxx_configsdir")))
																																																																																																																					{
																																																																																																																						if (!(equali(counwr, "HU", "amxx_configsdir")))
																																																																																																																						{
																																																																																																																							if (!(equali(counwr, "GB", "amxx_configsdir")))
																																																																																																																							{
																																																																																																																								if (!(equali(counwr, "VN", "amxx_configsdir")))
																																																																																																																								{
																																																																																																																									if (!(equali(counwr, "IT", "amxx_configsdir")))
																																																																																																																									{
																																																																																																																										if (equali(counwr, "CK", "amxx_configsdir"))
																																																																																																																										{
																																																																																																																										}
																																																																																																																									}
																																																																																																																								}
																																																																																																																							}
																																																																																																																						}
																																																																																																																					}
																																																																																																																				}
																																																																																																																			}
																																																																																																																		}
																																																																																																																	}
																																																																																																																}
																																																																																																															}
																																																																																																														}
																																																																																																													}
																																																																																																												}
																																																																																																											}
																																																																																																										}
																																																																																																									}
																																																																																																								}
																																																																																																							}
																																																																																																						}
																																																																																																					}
																																																																																																				}
																																																																																																			}
																																																																																																		}
																																																																																																	}
																																																																																																}
																																																																																															}
																																																																																														}
																																																																																													}
																																																																																												}
																																																																																											}
																																																																																										}
																																																																																									}
																																																																																								}
																																																																																							}
																																																																																						}
																																																																																					}
																																																																																				}
																																																																																			}
																																																																																		}
																																																																																	}
																																																																																}
																																																																															}
																																																																														}
																																																																													}
																																																																												}
																																																																											}
																																																																										}
																																																																									}
																																																																								}
																																																																							}
																																																																						}
																																																																					}
																																																																				}
																																																																			}
																																																																		}
																																																																	}
																																																																}
																																																															}
																																																														}
																																																													}
																																																												}
																																																											}
																																																										}
																																																									}
																																																								}
																																																							}
																																																						}
																																																					}
																																																				}
																																																			}
																																																		}
																																																	}
																																																}
																																															}
																																														}
																																													}
																																												}
																																											}
																																										}
																																									}
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		}
																																	}
																																}
																															}
																														}
																													}
																												}
																											}
																										}
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return 119132;
}

public iRankcr(_arg0)
{
	if (!(equali(councr, "err", "amxx_configsdir")))
	{
		if (!(equali(councr, "CN", "amxx_configsdir")))
		{
			if (!(equali(councr, "HK", "amxx_configsdir")))
			{
				if (!(equali(councr, "MO", "amxx_configsdir")))
				{
					if (equali(councr, "TW", "amxx_configsdir"))
					{
					}
				}
			}
		}
	}
	return 119132;
}

public show_Top1msg(id)
{
	new Pro1name[32];
	new Nub1name[32];
	new authid[32];
	new Wpn1name[32];
	get_user_authid(id, authid, 31);
	new i;
	if (i < num)
	{
		new var1 = Pro_Names[i];
		Pro1name = var1;
		new imin;
		new isec;
		new ims;
		imin = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
		isec = floatround(floatsub(Pro_Times[i], 1114636288 * imin), 1);
		ims = floatround(floatmul(1120403456, floatsub(Pro_Times[i], 1114636288 * imin + isec)), "amxx_configsdir");
		if (Pro_Times[i] > 9999999.0)
		{
			format(Pro1message, 127, "ProTop  [#1] No Record");
		}
		else
		{
			format(Pro1message, 511, "ProTop  [#1] %02i:%02i.%02i by %s", imin, isec, ims, Pro1name);
		}
		new imin1;
		new isec1;
		new ims1;
		imin1 = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
		isec1 = floatround(floatsub(Noob_Tiempos[i], 1114636288 * imin1), 1);
		ims1 = floatround(floatmul(1120403456, floatsub(Noob_Tiempos[i], 1114636288 * imin1 + isec1)), "amxx_configsdir");
		new var2 = Noob_Names[i];
		Nub1name = var2;
		if (Noob_Tiempos[i] > 9999999.0)
		{
			format(Nub1message, 127, "NubTop [#1] No Record");
		}
		else
		{
			format(Nub1message, 511, "NubTop [#1] %02i:%02i.%02i by %s", imin1, isec1, ims1, Nub1name);
		}
		new Wpn1Weapon[32];
		new var3 = Wpn_Weapon[i];
		Wpn1Weapon = var3;
		new var4 = Wpn_Names[i];
		Wpn1name = var4;
		new imin2;
		new isec2;
		new ims2;
		imin2 = floatround(floatdiv(Wpn_Timepos[i], 1114636288), 1);
		isec2 = floatround(floatsub(Wpn_Timepos[i], 1114636288 * imin2), 1);
		ims2 = floatround(floatmul(1120403456, floatsub(Wpn_Timepos[i], 1114636288 * imin2 + isec2)), "amxx_configsdir");
		if (Wpn_Timepos[i] > 9999999.0)
		{
			format(Wpn1message, 127, "WpnTop [#1] No Record");
		}
		else
		{
			format(Wpn1message, 511, "WpnTop [#1] %02i:%02i.%02i by %s", imin2, isec2, ims2, Wpn1name);
		}
		return 1;
	}
	return 1;
}

public CmdSayWR(id)
{
	new e_Message[401];
	new e_Author[6][32] = {
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 24, 148, 272, 396, 520, 644, 24, 56, 88, 120, 152, 184, 24, 52
		},
		{
			80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 24, 148, 272, 396, 520, 644, 24, 56, 88, 120, 152, 184, 24, 52, 80, 108, 136, 164, 24, 52, 80, 108
		},
		{
			136, 164, 91, 88, 74, 93, 0, 91, 67, 111, 115, 121, 93, 0, 91, 83, 85, 82, 70, 93, 0, 77, 97, 112, 32, 78, 97, 109, 101, 58, 32, 37
		},
		{
			115, 10, 10, 37, 115, 10, 37, 115, 10, 37, 115, 10, 0, 91, 37, 115, 93, 0, 37, 115, 0, 91, 82, 111, 117, 116, 105, 110, 101, 93, 0, 60
		},
		{
			102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35, 69, 69, 69, 69, 69, 48, 62, 77, 97, 112, 32, 60, 47, 102, 111, 110, 116, 62, 60, 98
		},
		{
			62, 37, 115, 60, 47, 98, 62, 60, 112, 62, 32, 60, 102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35, 69, 69, 69, 69, 69, 48, 62, 32
		}
	};
	new e_Time[6][9] = {
		{
			24, 52, 80, 108, 136, 164, 24, 52, 80
		},
		{
			108, 136, 164, 24, 148, 272, 396, 520, 644
		},
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80
		},
		{
			108, 136, 164, 24, 52, 80, 108, 136, 164
		},
		{
			24, 148, 272, 396, 520, 644, 24, 56, 88
		},
		{
			120, 152, 184, 24, 52, 80, 108, 136, 164
		}
	};
	new e_cnt[6][8] = {
		{
			24, 52, 80, 108, 136, 164, 24, 148
		},
		{
			272, 396, 520, 644, 24, 56, 88, 120
		},
		{
			152, 184, 24, 52, 80, 108, 136, 164
		},
		{
			24, 52, 80, 108, 136, 164, 24, 148
		},
		{
			272, 396, 520, 644, 24, 56, 88, 120
		},
		{
			152, 184, 24, 52, 80, 108, 136, 164
		}
	};
	new e_Extension[6][8] = {
		{
			24, 148, 272, 396, 520, 644, 24, 56
		},
		{
			88, 120, 152, 184, 24, 52, 80, 108
		},
		{
			136, 164, 24, 52, 80, 108, 136, 164
		},
		{
			24, 148, 272, 396, 520, 644, 24, 56
		},
		{
			88, 120, 152, 184, 24, 52, 80, 108
		},
		{
			136, 164, 24, 52, 80, 108, 136, 164
		}
	};
	new iLen;
	new iFounds;
	new cce_Author[6][32] = {
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 24, 148, 272, 396, 520, 644, 24, 56, 88, 120, 152, 184, 24, 52
		},
		{
			80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 91, 88, 74, 93, 0, 91, 67, 111, 115, 121, 93, 0, 91, 83, 85, 82, 70, 93, 0, 77, 97, 112
		},
		{
			32, 78, 97, 109, 101, 58, 32, 37, 115, 10, 10, 37, 115, 10, 37, 115, 10, 37, 115, 10, 0, 91, 37, 115, 93, 0, 37, 115, 0, 91, 82, 111
		},
		{
			117, 116, 105, 110, 101, 93, 0, 60, 102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35, 69, 69, 69, 69, 69, 48, 62, 77, 97, 112, 32, 60
		},
		{
			47, 102, 111, 110, 116, 62, 60, 98, 62, 37, 115, 60, 47, 98, 62, 60, 112, 62, 32, 60, 102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35
		},
		{
			69, 69, 69, 69, 69, 48, 62, 32, 87, 82, 32, 60, 47, 102, 111, 110, 116, 62, 32, 60, 102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35
		}
	};
	new cce_Time[6][9] = {
		{
			24, 52, 80, 108, 136, 164, 24, 52, 80
		},
		{
			108, 136, 164, 24, 148, 272, 396, 520, 644
		},
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80
		},
		{
			108, 136, 164, 24, 52, 80, 108, 136, 164
		},
		{
			91, 88, 74, 93, 0, 91, 67, 111, 115
		},
		{
			121, 93, 0, 91, 83, 85, 82, 70, 93
		}
	};
	new cce_cnt[6][8] = {
		{
			24, 52, 80, 108, 136, 164, 24, 148
		},
		{
			272, 396, 520, 644, 24, 56, 88, 120
		},
		{
			152, 184, 24, 52, 80, 108, 136, 164
		},
		{
			24, 52, 80, 108, 136, 164, 91, 88
		},
		{
			74, 93, 0, 91, 67, 111, 115, 121
		},
		{
			93, 0, 91, 83, 85, 82, 70, 93
		}
	};
	new cce_Extension[6][8] = {
		{
			24, 148, 272, 396, 520, 644, 24, 56
		},
		{
			88, 120, 152, 184, 24, 52, 80, 108
		},
		{
			136, 164, 24, 52, 80, 108, 136, 164
		},
		{
			91, 88, 74, 93, 0, 91, 67, 111
		},
		{
			115, 121, 93, 0, 91, 83, 85, 82
		},
		{
			70, 93, 0, 77, 97, 112, 32, 78
		}
	};
	new cciFounds;
	new sue_Author[6][32] = {
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 91, 88, 74, 93, 0, 91, 67, 111, 115, 121, 93, 0, 91, 83
		},
		{
			85, 82, 70, 93, 0, 77, 97, 112, 32, 78, 97, 109, 101, 58, 32, 37, 115, 10, 10, 37, 115, 10, 37, 115, 10, 37, 115, 10, 0, 91, 37, 115
		},
		{
			93, 0, 37, 115, 0, 91, 82, 111, 117, 116, 105, 110, 101, 93, 0, 60, 102, 111, 110, 116, 32, 99, 111, 108, 111, 114, 61, 35, 69, 69, 69, 69
		},
		{
			69, 48, 62, 77, 97, 112, 32, 60, 47, 102, 111, 110, 116, 62, 60, 98, 62, 37, 115, 60, 47, 98, 62, 60, 112, 62, 32, 60, 102, 111, 110, 116
		},
		{
			32, 99, 111, 108, 111, 114, 61, 35, 69, 69, 69, 69, 69, 48, 62, 32, 87, 82, 32, 60, 47, 102, 111, 110, 116, 62, 32, 60, 102, 111, 110, 116
		},
		{
			32, 99, 111, 108, 111, 114, 61, 35, 70, 70, 48, 48, 48, 52, 62, 60, 98, 62, 42, 42, 58, 42, 42, 46, 42, 42, 60, 47, 98, 62, 60, 47
		}
	};
	new sue_Time[6][9] = {
		{
			24, 52, 80, 108, 136, 164, 24, 52, 80
		},
		{
			108, 136, 164, 91, 88, 74, 93, 0, 91
		},
		{
			67, 111, 115, 121, 93, 0, 91, 83, 85
		},
		{
			82, 70, 93, 0, 77, 97, 112, 32, 78
		},
		{
			97, 109, 101, 58, 32, 37, 115, 10, 10
		},
		{
			37, 115, 10, 37, 115, 10, 37, 115, 10
		}
	};
	new sue_cnt[6][8] = {
		{
			24, 52, 80, 108, 136, 164, 91, 88
		},
		{
			74, 93, 0, 91, 67, 111, 115, 121
		},
		{
			93, 0, 91, 83, 85, 82, 70, 93
		},
		{
			0, 77, 97, 112, 32, 78, 97, 109
		},
		{
			101, 58, 32, 37, 115, 10, 10, 37
		},
		{
			115, 10, 37, 115, 10, 37, 115, 10
		}
	};
	new sue_Extension[6][8] = {
		{
			91, 88, 74, 93, 0, 91, 67, 111
		},
		{
			115, 121, 93, 0, 91, 83, 85, 82
		},
		{
			70, 93, 0, 77, 97, 112, 32, 78
		},
		{
			97, 109, 101, 58, 32, 37, 115, 10
		},
		{
			10, 37, 115, 10, 37, 115, 10, 37
		},
		{
			115, 10, 0, 91, 37, 115, 93, 0
		}
	};
	new suiFounds;
	new e_Whatmap[32];
	new e_WhatFile[128] = e_Records_WR;
	new cce_WhatFile[128] = e_Records_CC;
	new sue_WhatFile[128] = e_Records_SU;
	if (!e_Whatmap[0])
	{
		e_Whatmap = e_MapName;
	}
	iFounds = GetRecordData(e_Whatmap, e_Author, e_Time, e_cnt, e_Extension, e_WhatFile);
	cciFounds = ccGetRecordData(e_Whatmap, cce_Author, cce_Time, cce_cnt, cce_Extension, cce_WhatFile);
	suiFounds = suGetRecordData(e_Whatmap, sue_Author, sue_Time, sue_cnt, sue_Extension, sue_WhatFile);
	if (!(0 < iFounds))
	{
	}
	if (!(0 < cciFounds))
	{
	}
	if (!(0 < suiFounds))
	{
	}
	iLen = formatex(e_Message, 400, "Map Name: %s\n\n%s\n%s\n%s\n", e_Whatmap, Pro1message, Nub1message, Wpn1message);
	if (0 < iFounds)
	{
		new i;
		while (i < iFounds)
		{
			if (e_Author[i][0])
			{
				new XJExtension[21];
				if (e_Extension[i][0])
				{
					format(XJExtension, 20, "[%s]", e_Extension[i]);
				}
				else
				{
					format(XJExtension, 20, "%s", "[Routine]");
				}
				if (e_Time[i][0] == 42)
				{
					format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>**:**.**</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/err.png> <b>n/a </b><p><font color=#EEEEE0>Map of Website</font> Xtreme-Jumpst.eu", MapName, WEB_URL);
					format(WRTimes, 400, "\dWR - **:**.** by n/a");
					iLen = formatex(e_Message[iLen], 400 - iLen, "WR(XJ): **:**.** by n/a") + iLen;
				}
				else
				{
					format(WRTime, 400, "<font color=#EEEEE0>Map </font><b>%s</b><p> <font color=#EEEEE0> WR </font> <font color=#FF0004><b>%s</b></font> <font color=#EEEEE0>by</font> <img src=%s/flags/%s.png align=absmiddle height=32 width=32 /> <b>%s </b><p><font color=#EEEEE0>Record of Website</font> Xtreme-Jumpst.eu", MapName, e_Time[i], WEB_URL, e_cnt[i], e_Author[i]);
					format(WRTimes, 400, "\dWR - \y%s \dby \y%s", e_Time[i], e_Author[i]);
					format(counwr, 31, "%s", e_cnt[i]);
					iRank();

/* ERROR! Can't print expression: Heap */
 function "CmdSayWR" (number 76)
public CmdSayCR(id)
{
	new cre_Message[401];
	new cre_Author[6][32] = {
		{
			24, 56, 88, 120, 152, 184, 24, 52, 80, 108, 136, 164, 24, 52, 80, 108, 136, 164, 91, 78, 84, 74, 85, 77, 80, 93, 0, 77, 97, 112, 32, 78
		},
		{
			97, 109, 101, 58, 32, 37, 115, 10, 10, 0, 91, 37, 115, 93, 0, 37, 115, 0, 91, 82, 111, 117, 116, 105, 110, 101, 93, 0, 92, 100, 78, 84
		},
		{
			32, 45, 32, 42, 42, 58, 42, 42, 58, 42, 42, 32, 98, 121, 32, 110, 47, 97, 0, 91, 78, 84, 106, 117, 109, 112, 93, 58, 32, 42, 42, 58
		},
		{
			42, 42, 58, 42, 42, 32, 98, 121, 32, 110, 47, 97, 0, 37, 115, 0, 92, 100, 78, 84, 32, 45, 32, 92, 121, 37, 115, 32, 92, 100, 98, 121
		},
		{
			32, 92, 121, 37, 115, 0, 10, 37, 115, 37, 115, 32, 37, 115, 32, 98, 121, 32, 37, 115, 32, 91, 37, 115, 93, 10, 10, 0, 91, 78, 84, 106
		},
		{
			117, 109, 112, 93, 32, 78, 111, 32, 77, 97, 112, 0, 92, 100, 78, 84, 32, 45, 32, 87, 101, 98, 115, 105, 116, 101, 32, 85, 110, 107, 110, 111
		}
	};
	new cre_Time[6][9] = {
		{
			24, 52, 80, 108, 136, 164, 24, 52, 80
		},
		{
			108, 136, 164, 91, 78, 84, 74, 85, 77
		},
		{
			80, 93, 0, 77, 97, 112, 32, 78, 97
		},
		{
			109, 101, 58, 32, 37, 115, 10, 10, 0
		},
		{
			91, 37, 115, 93, 0, 37, 115, 0, 91
		},
		{
			82, 111, 117, 116, 105, 110, 101, 93, 0
		}
	};
	new cre_cnt[6][8] = {
		{
			24, 52, 80, 108, 136, 164, 91, 78
		},
		{
			84, 74, 85, 77, 80, 93, 0, 77
		},
		{
			97, 112, 32, 78, 97, 109, 101, 58
		},
		{
			32, 37, 115, 10, 10, 0, 91, 37
		},
		{
			115, 93, 0, 37, 115, 0, 91, 82
		},
		{
			111, 117, 116, 105, 110, 101, 93, 0
		}
	};
	new cre_Extension[6][8] = {
		{
			91, 78, 84, 74, 85, 77, 80, 93
		},
		{
			0, 77, 97, 112, 32, 78, 97, 109
		},
		{
			101, 58, 32, 37, 115, 10, 10, 0
		},
		{
			91, 37, 115, 93, 0, 37, 115, 0
		},
		{
			91, 82, 111, 117, 116, 105, 110, 101
		},
		{
			93, 0, 92, 100, 78, 84, 32, 45
		}
	};
	new criLen;
	new criFounds;
	new e_Whatmap[32];
	new cre_WhatFile[128] = e_Records_CR;
	if (!e_Whatmap[0])
	{
		e_Whatmap = e_MapName;
	}
	criFounds = crGetRecordData(e_Whatmap, cre_Author, cre_Time, cre_cnt, cre_Extension, cre_WhatFile);
	criLen = formatex(cre_Message, 400, "Map Name: %s\n\n", e_Whatmap);
	if (0 < criFounds)
	{
		new i;
		while (i < criFounds)
		{
			if (cre_Author[i][0])
			{
				new CRExtension[21];
				if (cre_Extension[i][0])
				{
					format(CRExtension, 20, "[%s]", cre_Extension[i]);
				}
				else
				{
					format(CRExtension, 20, "%s", "[Routine]");
				}
				if (cre_Time[i][0] == 42)
				{
					format(NTTimes, 400, "\dNT - **:**:** by n/a");
					criLen = formatex(cre_Message[criLen], 400 - criLen, "[NTjump]: **:**:** by n/a") + criLen;
				}
				else
				{
					format(councr, 31, "%s", cre_cnt[i]);
					format(NTTimes, 400, "\dNT - \y%s \dby \y%s", cre_Time[i], cre_Author[i]);
					iRankcr();

/* ERROR! Can't print expression: Heap */
 function "CmdSayCR" (number 77)
ClimbtimeToString(Float:flClimbTime, szOutPut[], iLen)
{
	if (!flClimbTime)
	{
		copy(szOutPut, iLen, "**:**.**");
		return 0;
	}
	new iMinutes = floatround(floatdiv(flClimbTime, 1114636288), 1);
	new iSeconds = floatround(flClimbTime - iMinutes * 60, 1);
	new iMiliSeconds = floatround(flClimbTime - iSeconds + iMinutes * 60 * 100, "amxx_configsdir");
	formatex(szOutPut, iLen, "%02i:%02i.%02i", iMinutes, iSeconds, iMiliSeconds);
	return 0;
}

GetRecordData(Map[32], Jumper[6][32], Time[6][9], cnt[6][8], Extension[6][8], e_WhatFile[128])
{
	new szData[64];
	new szMap[32];
	new szTime[9];
	new iFounds;
	new iLen;
	new iMapLen = strlen(Map);
	new RecFile[128];
	new var8 = e_WhatFile;
	RecFile = var8;
	new iFile = fopen(RecFile, "rt");
	if (!iFile)
	{
		return 0;
	}
	while (!feof(iFile))
	{
		fgets(iFile, szData, "");
		trim(szData);
		new var1;
		if (!(!szData[0] || !equali(szData, Map, iMapLen)))
		{
			iLen = copyc(szMap, 31, szData, 32) + 1;
			new var2;
			if (!(szMap[iMapLen] != 91 && strlen(szMap) != iMapLen))
			{
				iLen = copyc(szTime, 8, szData[iLen], 32) + 1 + iLen;
				iLen = copyc(Jumper[iFounds], 32, szData[iLen], 32) + 1 + iLen;
				copyc(cnt[iFounds], 2, szData[iLen], 32);
				new var4;
				if (szTime[0] == 42 || (equal(Jumper[iFounds], "n/a", "amxx_configsdir") && 0 == str_to_float(szTime)))
				{
					norecord = 1;
				}
				else
				{
					new var5;
					if (equali(Map, MapName, "amxx_configsdir") && iFounds < 5)
					{
						g_flWorldRecordTime[iFounds] = FloatTimer(szTime);
						DiffWRTime[iFounds] = FloatTimer(szTime);
						new var6;
						if (DiffWRTime[iFounds] < DiffWRTime[0] && iFounds > 0)
						{
							DiffWRTime[0] = DiffWRTime[iFounds];
						}
						copy(g_szWorldRecordPlayer[iFounds], 31, Jumper[iFounds]);
					}
				}
				ClimbtimeToString(str_to_float(szTime), szTime, 8);
				copy(Time[iFounds], 8, szTime);
				if (szMap[iMapLen] == 91)
				{
					copyc(Extension[iFounds], 8, szMap[iMapLen + 1], 93);
				}
				iFounds++;
				new var7;
				if (equali(Map, MapName, "amxx_configsdir") && !g_iWorldRecordsNum && iFounds && norecord != 1)
				{
					g_iWorldRecordsNum = iFounds;
					if (g_iWorldRecordsNum > 5)
					{
						g_iWorldRecordsNum = 5;
					}
				}
			}
		}
	}
	fclose(iFile);
	return iFounds;
}

ccGetRecordData(ccMap[32], ccJumper[6][32], ccTime[6][9], cccnt[6][8], ccExtension[6][8], cce_WhatFile[128])
{
	new ccszData[64];
	new ccszMap[32];
	new ccszTime[9];
	new cciFounds;
	new cciLen;
	new cciMapLen = strlen(ccMap);
	new ccRecFile[128];
	new var8 = cce_WhatFile;
	ccRecFile = var8;
	new cciFile = fopen(ccRecFile, "rt");
	if (!cciFile)
	{
		return 0;
	}
	while (!feof(cciFile))
	{
		fgets(cciFile, ccszData, "");
		trim(ccszData);
		new var1;
		if (!(!ccszData[0] || !equali(ccszData, ccMap, cciMapLen)))
		{
			cciLen = copyc(ccszMap, 31, ccszData, 32) + 1;
			new var2;
			if (!(ccszMap[cciMapLen] != 91 && strlen(ccszMap) != cciMapLen))
			{
				cciLen = copyc(ccszTime, 8, ccszData[cciLen], 32) + 1 + cciLen;
				cciLen = copyc(ccJumper[cciFounds], 32, ccszData[cciLen], 32) + 1 + cciLen;
				copyc(cccnt[cciFounds], 2, ccszData[cciLen], 32);
				new var4;
				if (ccszTime[0] == 42 || (equal(ccJumper[cciFounds], "n/a", "amxx_configsdir") && 0 == str_to_float(ccszTime)))
				{
					norecord = 1;
				}
				else
				{
					new var5;
					if (equali(ccMap, MapName, "amxx_configsdir") && cciFounds < 5)
					{
						g_flWorldRecordTime[cciFounds] = FloatTimer(ccszTime);
						DiffWRTime[cciFounds] = FloatTimer(ccszTime);
						new var6;
						if (DiffWRTime[cciFounds] < DiffWRTime[0] && cciFounds > 0)
						{
							DiffWRTime[0] = DiffWRTime[cciFounds];
						}
						copy(g_szWorldRecordPlayer[cciFounds], 31, ccJumper[cciFounds]);
					}
				}
				ClimbtimeToString(str_to_float(ccszTime), ccszTime, 8);
				copy(ccTime[cciFounds], 8, ccszTime);
				if (ccszMap[cciMapLen] == 91)
				{
					copyc(ccExtension[cciFounds], 8, ccszMap[cciMapLen + 1], 93);
				}
				cciFounds++;
				new var7;
				if (equali(ccMap, MapName, "amxx_configsdir") && !g_iWorldRecordsNum && cciFounds && norecord != 1)
				{
					g_iWorldRecordsNum = cciFounds;
					if (g_iWorldRecordsNum > 5)
					{
						g_iWorldRecordsNum = 5;
					}
				}
			}
		}
	}
	fclose(cciFile);
	return cciFounds;
}

suGetRecordData(suMap[32], suJumper[6][32], suTime[6][9], sucnt[6][8], suExtension[6][8], sue_WhatFile[128])
{
	new suszData[64];
	new suszMap[32];
	new suszTime[9];
	new suiFounds;
	new suiLen;
	new suiMapLen = strlen(suMap);
	new suRecFile[128];
	new var5 = sue_WhatFile;
	suRecFile = var5;
	new suiFile = fopen(suRecFile, "rt");
	if (!suiFile)
	{
		return 0;
	}
	while (!feof(suiFile))
	{
		fgets(suiFile, suszData, "");
		trim(suszData);
		new var1;
		if (!(!suszData[0] || !equali(suszData, suMap, suiMapLen)))
		{
			suiLen = copyc(suszMap, 31, suszData, 32) + 1;
			new var2;
			if (!(suszMap[suiMapLen] != 91 && strlen(suszMap) != suiMapLen))
			{
				suiLen = copyc(suszTime, 8, suszData[suiLen], 32) + 1 + suiLen;
				suiLen = copyc(suJumper[suiFounds], 32, suszData[suiLen], 32) + 1 + suiLen;
				copyc(sucnt[suiFounds], 2, suszData[suiLen], 32);
				new var3;
				if (equali(suMap, MapName, "amxx_configsdir") && suiFounds < 5)
				{
					g_flWorldRecordTime[suiFounds] = FloatTimer(suszTime);
					DiffWRTime[suiFounds] = FloatTimer(suszTime);
					new var4;
					if (DiffWRTime[suiFounds] < DiffWRTime[0] && suiFounds > 0)
					{
						DiffWRTime[0] = DiffWRTime[suiFounds];
					}
					copy(g_szWorldRecordPlayer[suiFounds], 31, suJumper[suiFounds]);
				}
				ClimbtimeToString(str_to_float(suszTime), suszTime, 8);
				copy(suTime[suiFounds], 8, suszTime);
				if (suszMap[suiMapLen] == 91)
				{
					copyc(suExtension[suiFounds], 8, suszMap[suiMapLen + 1], 93);
				}
				suiFounds++;
				g_iWorldRecordsNum = suiFounds;
			}
		}
	}
	fclose(suiFile);
	return suiFounds;
}

crGetRecordData(crMap[32], crJumper[6][32], crTime[6][9], crcnt[6][8], crExtension[6][8], cre_WhatFile[128])
{
	new crszData[64];
	new crszMap[32];
	new crszTime[9];
	new criFounds;
	new criLen;
	new criMapLen = strlen(crMap);
	new crRecFile[128];
	new var8 = cre_WhatFile;
	crRecFile = var8;
	new criFile = fopen(crRecFile, "rt");
	if (!criFile)
	{
		return 0;
	}
	while (!feof(criFile))
	{
		fgets(criFile, crszData, "");
		trim(crszData);
		new var1;
		if (!(!crszData[0] || !equali(crszData, crMap, criMapLen)))
		{
			criLen = copyc(crszMap, 31, crszData, 32) + 1;
			new var2;
			if (!(crszMap[criMapLen] != 91 && strlen(crszMap) != criMapLen))
			{
				criLen = copyc(crszTime, 8, crszData[criLen], 32) + 1 + criLen;
				criLen = copyc(crJumper[criFounds], 32, crszData[criLen], 32) + 1 + criLen;
				copyc(crcnt[criFounds], 2, crszData[criLen], 32);
				new var4;
				if (crszTime[0] == 42 || (equal(crJumper[criFounds], "n/a", "amxx_configsdir") && 0 == str_to_float(crszTime)))
				{
					norecord = 1;
				}
				else
				{
					new var5;
					if (equali(crMap, MapName, "amxx_configsdir") && criFounds < 5)
					{
						g_flWorldRecordTime[criFounds] = FloatTimer(crszTime);
						DiffNTRTime[criFounds] = FloatTimer(crszTime);
						new var6;
						if (DiffNTRTime[criFounds] < DiffNTRTime[0] && criFounds > 0)
						{
							DiffNTRTime[0] = DiffNTRTime[criFounds];
						}
						copy(g_szWorldRecordPlayer[criFounds], 31, crJumper[criFounds]);
					}
				}
				ClimbtimeToString(str_to_float(crszTime), crszTime, 8);
				copy(crTime[criFounds], 8, crszTime);
				if (crszMap[criMapLen] == 91)
				{
					copyc(crExtension[criFounds], 8, crszMap[criMapLen + 1], 93);
				}
				criFounds++;
				new var7;
				if (equali(crMap, MapName, "amxx_configsdir") && !g_iNtRecordsNum && criFounds && norecord != 1)
				{
					g_iNtRecordsNum = criFounds;
					if (g_iNtRecordsNum > 5)
					{
						g_iNtRecordsNum = 5;
					}
				}
			}
		}
	}
	fclose(criFile);
	return criFounds;
}

public ReadWeb(iSocket)
{
	new RecFile[128];
	if (e_UpdatedNR == 1)
	{
		RecFile = e_Records_WR;
	}
	if (e_UpdatedNR == 2)
	{
		RecFile = e_Records_CC;
	}
	if (e_UpdatedNR == 3)
	{
		RecFile = e_Records_CR;
	}
	e_UpdatedNR += 1;
	e_Buffer[0] = 0;
	new iFile = fopen(RecFile, "at");
	while (socket_recv(iSocket, e_Buffer, 25000))
	{
		if (e_Buffer[0])
		{
			new var1;
			if (e_Buffer[0] == 72 && e_Buffer[1] == 84)
			{
				new iPos = contain(e_Buffer, "\r\n\r\n") + 4;
				iPos = contain(e_Buffer[iPos], 363176) + 1 + iPos;
				formatex(e_Buffer, 25000, e_Buffer[iPos]);
			}
			fputs(iFile, e_Buffer);
		}
	}
	fclose(iFile);
	socket_close(iSocket);
	return 0;
}

public UpdateRecords()
{
	if (file_exists(e_Records_WR))
	{
		delete_file(e_Records_WR);
	}
	if (file_exists(e_Records_CC))
	{
		delete_file(e_Records_CC);
	}
	if (file_exists(e_Records_CR))
	{
		delete_file(e_Records_CR);
	}
	if (file_exists(e_LastUpdate))
	{
		delete_file(e_LastUpdate);
	}
	new iYear;
	new iMonth;
	new iDay;
	new szTemp[255];
	date(iYear, iMonth, iDay);
	new iFile = fopen(e_LastUpdate, "wt");
	formatex(szTemp, 254, "%04i/%02i/%02i", iYear, iMonth, iDay);
	fputs(iFile, szTemp);
	fclose(iFile);
	new e_Host[96];
	new e_Url[96];
	new e_Socket[256];
	new iPos;
	new iSocket;
	new i;
	while (i < 3)
	{
		copy(e_Host, 95, e_DownloadLinks[i][7]);
		iPos = contain(e_Host, 363256);
		if (iPos != -1)
		{
			copy(e_Url, 95, e_Host[iPos + 1]);
			e_Host[iPos] = 0;
		}
		iSocket = socket_open(e_Host, 80, 1, iPos);
		if (0 < iPos)
		{
			switch (iPos)
			{
				case 1:
				{
					log_amx("Socket错误(%d) 无法建立 Socket", iPos);
				}
				case 2:
				{
					log_amx("Socket错误(%d) 无法解析 %s", iPos, e_Host);
				}
				case 3:
				{
					log_amx("Socket错误(%d) 无法连接 %s:80", iPos, e_Host);
				}
				default:
				{
				}
			}
		}
		else
		{
			formatex(e_Socket, "", "GET /%s HTTP/1.1\r\nHost: %s\r\nUser-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\r\nConnection: close\r\n\r\n", e_Url, e_Host);
			socket_send(iSocket, e_Socket, "");
			set_task(1050253722, "ReadWeb", iSocket, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
		i++;
	}
	return 0;
}

Float:FloatTimer(szInPut[])
{
	new Float:flTime = 0.0;
	new var1;
	if (szInPut[2] == 58 && szInPut[5] == 46)
	{
		flTime = floatadd(flTime, floatadd(1142292480 * szInPut[0] - 48, 1114636288 * szInPut[1] - 48));
		flTime = floatadd(flTime, 1092616192 * szInPut[3] - 48 + szInPut[4] - 48);
		flTime = floatadd(flTime, floatadd(szInPut[6] - 48 / 1092616192, szInPut[7] - 48 / 1120403456));
	}
	else
	{
		flTime = str_to_float(szInPut);
	}
	return flTime;
}

WRTimer(Float:flRealTime, szOutPut[], iSizeOutPut, bMiliSeconds, gametime)
{
	static iSeconds;
	static iMinutes;
	static Float:flTime;
	if (gametime)
	{
		flTime = floatsub(get_gametime(), flRealTime);
	}
	else
	{
		flTime = flRealTime;
	}
	if (flTime < 0.0)
	{
		flTime = 0.0;
	}
	iMinutes = floatround(flTime / 60, 1);
	iSeconds = floatround(flTime - iMinutes * 60, 1);
	formatex(szOutPut, iSizeOutPut, "%02d:%02d", iMinutes, iSeconds);
	if (bMiliSeconds)
	{
		static iMiliSeconds;
		iMiliSeconds = floatround(flTime - iSeconds + iMinutes * 60 * 100, "amxx_configsdir");
		format(szOutPut, iSizeOutPut, "%s.%02d", szOutPut, iMiliSeconds);
	}
	return 0;
}

public MsgSay(id)
{
	if (!is_user_connected(id))
	{
		return 1;
	}
	new message[192];
	read_argv("amxx_configsdir", message, 5);
	read_args(message, 191);
	remove_quotes(message);
	trim(message);
	new var1;
	if (strlen(message) > 190 || strlen(message))
	{
		return 1;
	}
	static CONTACT[1];
	if (get_pcvar_num(kz_admin_check) == 1)
	{
		register_cvar("amx_contactinfo", CONTACT, 4, "amxx_configsdir");
		new var2;
		if (equal(message, "admin", 5) || equal(message, "/admin", 6))
		{
			set_task(1036831949, "print_adminlist", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
			return 0;
		}
	}
	return 0;
}

public print_adminlist(user)
{
	new adminnames[33][32] = {
		{
			4, 91, 75, 90, 93, 1, 32, 65, 100, 109, 105, 110, 115, 32, 79, 110, 108, 105, 110, 101, 58, 32, 0, 3, 37, 115, 37, 115, 32, 0, 44, 32
		},
		{
			0, 0, 1, 32, 0, 1, 78, 111, 32, 65, 100, 109, 105, 110, 115, 32, 79, 110, 108, 105, 110, 101, 46, 0, 97, 109, 120, 95, 99, 111, 110, 116
		},
		{
			97, 99, 116, 105, 110, 102, 111, 0, 4, 91, 75, 90, 93, 32, 28, 111, 110, 116, 97, 99, 116, 58, 32, 3, 37, 115, 0, 0, 0, 0, 0, 0
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		},
		{
			0, ...
		}
	};
	new message[256];
	new contactinfo[256];
	new contact[112];
	new id;
	new count;
	new x;
	new len;
	id = 1;
	while (id <= g_maxplayers)
	{
		if (is_user_connected(id))
		{
			if (get_user_flags(id, "amxx_configsdir") & 8)
			{
				count++;
				get_user_name(id, adminnames[count], 31);
			}
		}
		id++;
	}
	len = format(message, "", 364660);
	if (0 < count)
	{
		x = 0;
		while (x < count)
		{
			new var1;
			if (x < count + -1)
			{
				var1 = 364780;
			}
			else
			{
				var1 = 364792;
			}
			len = format(message[len], 255 - len, "\x03%s%s ", adminnames[x], var1) + len;
			if (len > 96)
			{
				print_message(user, message);
				len = format(message, "", "\x01 ");
			}
			x++;
		}
		print_message(user, message);
	}
	else
	{
		len = format(message[len], 255 - len, "\x01No Admins Online.") + len;
		print_message(user, message);
	}
	get_cvar_string("amx_contactinfo", contact, "");
	if (contact[0])
	{
		format(contactinfo, 111, "\x04[KZ] ontact: \x03%s", contact);
		print_message(user, contactinfo);
	}
	return 0;
}

print_message(id, msg[])
{
	message_begin(1, g_msgid_SayText, 365024, id);
	write_byte(id);
	write_string(msg);
	message_end();
	return 0;
}

public cmd_help(id)
{
	static Pos;
	static MLTITEL[24];
	static MOTD[2048];
	formatex(MLTITEL, 23, "Server help", id);
	Pos = formatex(MOTD, 2047, "<meta charset=UTF-8><style type=\"text/css\">.h1 { color:#ffffff;font-weight:bold;} .h2 { color:#8b8b7a; font-weight:bold; font-family: Times New Roman}</style><body bgcolor=\"#000000\"><table width=\"100%%\" border=\"0\">");
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Main Menu:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /menu") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Scout:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /scout") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Usp/knife +USP ammunition:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /usp") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Server Top:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /top15") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Vote map:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say rtv") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Change Server:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /server") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Checkpoint:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /cp Recommended bind &quotF4&quot console input: bind &quotf4&quot &quotsay /cp&quot") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* GoCheck:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /gc Recommended bind &quotF5&quot console input: bind &quotf5&quot &quotsay /gc&quot") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Stuck:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /stuck") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* GoStart:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /start Recommended bind &quotF2&quot console input: bind &quotf2&quot &quotsay /start&quot") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /respawn") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Restarttime:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /reset") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Go SPEC/CT:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /spec") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Check WR:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /wr") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* Custom start point:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /ss") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /set") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /cs") + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h1>* 1V1 Duel:", id) + Pos;
	Pos = formatex(MOTD[Pos], 2047 - Pos, "<tr><td class=h2>say /duel") + Pos;
	show_motd(id, MOTD, MLTITEL);
	return 0;
}

public fwdPlayerPreThink(id)
{
	new entname[33];
	pev(pev(id, 19), 1, entname, 32);
	new var1;
	if (!is_user_alive(id) || is_user_bot(id))
	{
		return 1;
	}
	new var2;
	if (!pev(id, 84) & 512 && !pev(id, 84) & 16 && !isFalling[id] && timer_started[id] && !IsPaused[id] && !equal(entname, "func_door", "amxx_configsdir"))
	{
		pev(id, 118, vFallingStart[id]);
		vFallingTime[id] = floatsub(get_gametime(), timer_time[id]);
		isFalling[id] = 1;
	}
	new var3;
	if (pev(id, 84) & 512 && isFalling[id] && timer_started[id] && !IsPaused[id] && !is_user_bot(id) && !equal(entname, "func_door", "amxx_configsdir"))
	{
		isFalling[id] = 0;
	}
	return 1;
}

public Pause(id)
{
	if (get_pcvar_num(kz_pause))
	{
		if (!is_user_alive(id))
		{
			kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
			return 1;
		}
		if (!timer_started[id])
		{
			kz_chat(id, "%L", id, "KZ_PAUSE_NOT_STARTED");
			return 1;
		}
		static Float:hpp[33];
		new entname[33];
		pev(pev(id, 19), 1, entname, 32);
		new name[32];
		get_user_name(id, name, 31);
		if (!IsPaused[id])
		{
			new var1;
			if (((!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5) || (equal(entname, "func_door", "amxx_configsdir") && !pev(id, 69) == 5)) && (timer_started[id] && !tptostart[id]))
			{
				kz_chat(id, "%L", id, "KZ_GROUND_PAUSE");
				return 1;
			}
			tphook_user[id] = 1;
			g_pausetime[id] = floatsub(get_gametime(), timer_time[id]);
			timer_time[id] = 0;
			static Float:v_angle[33][3];
			static Float:velocityy[33][3];
			pev(id, 41, hpp[id]);
			pev(id, __dhud_fxtime, velocityy[id]);
			pev(id, __dhud_fxtime, pausedvelocity[id]);
			pev(id, 118, PauseOrigin[id]);
			pev(id, 126, v_angle[id]);
			new var5;
			if (isFalling[id] && tptostart[id])
			{
				isMpbhop[id] = 1;
			}
			IsPaused[id] = 1;
		}
		else
		{
			new var6;
			if ((!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5) || (equal(entname, "func_door", "amxx_configsdir") && !pev(id, 69) == 5))
			{
				kz_chat(id, "%L", id, "KZ_GROUND_UNPAUSE");
				return 1;
			}
			if (ishooked[id])
			{
				remove_hook(id);
			}
			if (get_user_noclip(id))
			{
				set_user_noclip(id, "amxx_configsdir");
			}
			if (timer_started[id])
			{
				client_print(id, 4, 380776);
				timer_time[id] = floatsub(get_gametime(), g_pausetime[id]);
			}
			IsPaused[id] = 0;
			set_pev(id, __dhud_holdtime, v_angle[id]);
			new var9;
			if (isMpbhop[id] && !GoPosed[id])
			{
				if (callfunc_begin("setprokreedzorigin", "mpbhop.amxx") == 1)
				{
					callfunc_push_int(id);
					callfunc_push_float(MpbhopOrigin[id][0]);
					callfunc_push_float(MpbhopOrigin[id][1]);
					callfunc_push_float(MpbhopOrigin[id][2]);
					callfunc_end();
				}
				isMpbhop[id] = 0;
				set_pev(id, 65, 1);
			}
			tptostart[id] = 0;
			set_pev(id, 118, PauseOrigin[id]);
			set_pev(id, __dhud_fxtime, velocityy[id]);
			set_pev(id, 84, pev(id, 84) | 16384);
			new var10;
			if (!GoPosHp[id] && !HealsOnMap)
			{
				set_pev(id, 41, hpp[id]);
			}
			tphook_user[id] = 0;
			inpausechecknumbers[id] = 0;
			message_begin(1, get_user_msgid("ScreenFade"), 380952, id);
			write_short(1024);
			write_short(1024);
			write_short("amxx_configsdir");
			write_byte("");
			write_byte(192);
			write_byte(203);
			write_byte(65);
			message_end();
		}
		return 1;
	}
	kz_chat(id, "%L", id, "KZ_PAUSE_DISABLED");
	return 1;
}

public Pause_bot(id)
{
	if (!IsPaused[g_bot_id])
	{
		if (!timer_started[g_bot_id])
		{
			return 1;
		}
		g_pausetime[g_bot_id] = floatsub(get_gametime(), timer_time[g_bot_id]);
		timer_time[g_bot_id] = 0;
		IsPaused[g_bot_id] = 1;
		set_pev(g_bot_id, 84, pev(g_bot_id, 84) | 4096);
		pev(g_bot_id, 118, PauseOrigin[g_bot_id]);
	}
	else
	{
		if (timer_started[gc_bot_id])
		{
			timer_time[g_bot_id] = floatsub(get_gametime(), g_pausetime[g_bot_id]);
		}
		IsPaused[g_bot_id] = 0;
		set_pev(g_bot_id, 84, pev(g_bot_id, 84) & -4097);
	}
	return 1;
}

public Pause_bot_c(id)
{
	if (!IsPaused[gc_bot_id])
	{
		if (!timer_started[gc_bot_id])
		{
			return 1;
		}
		g_pausetime[gc_bot_id] = floatsub(get_gametime(), timer_time[gc_bot_id]);
		timer_time[gc_bot_id] = 0;
		IsPaused[gc_bot_id] = 1;
		set_pev(gc_bot_id, 84, pev(gc_bot_id, 84) | 4096);
		pev(gc_bot_id, 118, PauseOrigin[gc_bot_id]);
	}
	else
	{
		if (timer_started[gc_bot_id])
		{
			timer_time[g_bot_id] = floatsub(get_gametime(), g_pausetime[g_bot_id]);
		}
		IsPaused[g_bot_id] = 0;
		set_pev(g_bot_id, 84, pev(g_bot_id, 84) & -4097);
	}
	return 1;
}

public Teleport(id)
{
	new var1;
	if ((get_playersnum("amxx_configsdir") > 1 && is_user_alive(id)) || DefaultStop)
	{
		static buffer[1];
		static name[32];
		static player;
		static menuid;
		menuid = menu_create("\rTeleport Menu", "TeleportHandle", "amxx_configsdir");
		if (DefaultStop)
		{
			menu_vadditem(menuid, 381228, 0, -1, "%L", id, "KZ_TELEPORT_MENU1");
		}
		player = 1;
		while (player <= g_maxplayers)
		{
			new var3;
			if (!is_user_alive(player) || id != player)
			{
			}
			else
			{
				get_user_name(player, name, 31);
				if (DefaultStop)
				{
					buffer[0] = player + 1;
				}
				else
				{
					buffer[0] = player;
				}
				menu_additem(menuid, name, buffer, "amxx_configsdir", -1);
			}
			player += 1;
		}
		menu_display(id, menuid, "amxx_configsdir");
		return 1;
	}
	kz_chat(id, "%L", id, "KZ_TELEPORT_ISDISABLED");
	kz_menu(id);
	return 1;
}

public TeleportHandle(id, menuid, item)
{
	if (item == -3)
	{
		kz_menu(id);
		return 1;
	}
	static player;
	static dummy;
	static String:buffer[4];
	menu_item_getinfo(menuid, item, dummy, buffer, 1, {0}, "amxx_configsdir", dummy);
	if (DefaultStop)
	{
		player = buffer[0] - 1;
	}
	else
	{
		player = buffer[0];
	}
	new szPlayerName[32];
	new szName[32];
	get_user_name(id, szName, 32);
	get_user_name(player, szPlayerName, 32);
	new entname[33];
	pev(pev(id, 19), 1, entname, 32);
	new var1;
	if (((!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5) || (equal(entname, "func_door", "amxx_configsdir") && !pev(id, 69) == 5)) && (timer_started[id] && !IsPaused[id]))
	{
		kz_chat(id, "%L", id, "KZ_GROUND_DISABLED");
		Teleport(id);
		return 1;
	}
	new var5;
	if (timer_started[id] && !IsPaused[id])
	{
		tphook_user[id] = 1;
		Pause(id);
	}
	else
	{
		new var6;
		if (timer_started[id] && IsPaused[id])
		{
			set_pev(id, 84, pev(id, 84) & -4097);
			tphook_user[id] = 1;
		}
	}
	new var7;
	if (item && DefaultStop)
	{
		set_pev(id, __dhud_fxtime, 381568);
		set_pev(id, 118, DefaultStopPos);
		delay_duck(id);
		Teleport(id);
		return 1;
	}
	new var8;
	if (!is_user_alive(player) || id != player)
	{
		menu_destroy(menuid);
		return 1;
	}
	if (floatsub(get_gametime(), antiteleport[id]) < 1077936128)
	{
		ColorChat(id, Color:2, "%s\x01 等待3秒冷却时间!", prefix);
		Teleport(id);
		return 1;
	}
	static Float:pos[3];
	entity_get_vector(player, "amxx_configsdir", pos);
	entity_set_origin(id, pos);
	delay_duck(id);
	Teleport(id);
	antiteleport[id] = get_gametime();
	menu_destroy(menuid);
	return 1;
}

public delay_duck(id)
{
	new ida[1];
	ida[0] = id;
	// 1008981770 -> 0.01
	set_task(1008981770, "force_duck", "amxx_configsdir", ida, 1, 340912, "amxx_configsdir");
	set_entity_flags(ida[0], 16384, 1);
	return 0;
}

public force_duck(ida[1])
{
	set_entity_flags(ida[0], 16384, 1);
	return 0;
}

public kz_TimerEntity(iEnt)
{
	if (pev_valid(iEnt))
	{
		static ClassName[32];
		pev(iEnt, 1, ClassName, 31);
		if (equal(ClassName, "kz_time_think", "amxx_configsdir"))
		{
			timer_task();
			set_pev(iEnt, 33, floatadd(get_gametime(), random_float(1025758986, 1017370378)));
		}
	}
	return 0;
}

public timer_task()
{
	if (0 < get_pcvar_num(kz_show_timer))
	{
		new Alive[32];
		new Dead[32];
		new alivePlayers;
		new deadPlayers;
		get_players(Alive, alivePlayers, "ach", 152);
		get_players(Dead, deadPlayers, "bch", 152);
		new i;
		while (i < alivePlayers)
		{
			new output[128];
			new Float:kreedztime = 0.0;
			new imin;
			new Float:isec = 0.0;
			new var1;
			if (IsPaused[Alive[i]])
			{
				var1 = floatsub(get_gametime(), g_pausetime[Alive[i]]);
			}
			else
			{
				var1 = timer_time[Alive[i]];
			}
			kreedztime = floatsub(get_gametime(), var1);
			imin = floatround(kreedztime, 1) / 60;
			isec = floatadd(1017370378, kreedztime - imin * 60);
			new Float:velocity[3] = 0.0;
			pev(Alive[i], __dhud_fxtime, velocity);
			if (velocity[2] != 0.0)
			{
				new var22 = velocity[2];
				var22 = floatsub(var22, velocity[2]);
			}
			new Float:speedy = vector_length(velocity);
			if (timer_started[Alive[i]])
			{
				if (ShowTime[Alive[i]] == 1)
				{
					if (HealsOnMap)
					{
						new var2;
						if (IsPaused[Alive[i]])
						{
							var2 = 382188;
						}
						else
						{
							var2 = 382236;
						}
						new var3;
						if (isec < 1.4E-44)
						{
							var3 = 382176;
						}
						else
						{
							var3 = 382184;
						}
						format(output, 127, "[ %02d:%s%.2f | %d/%d | Speed: %d | HP: Godmode %s ]", imin, var3, isec, checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), var2);
					}
					else
					{
						new var4;
						if (IsPaused[Alive[i]])
						{
							var4 = 382440;
						}
						else
						{
							var4 = 382488;
						}
						new var5;
						if (isec < 1.4E-44)
						{
							var5 = 382428;
						}
						else
						{
							var5 = 382436;
						}
						format(output, 127, "[ %02d:%s%.2f | %d/%d | Speed: %d | HP: %d %s]", imin, var5, isec, checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), get_user_health(Alive[i]), var4);
					}
				}
				else
				{
					if (ShowTime[Alive[i]] == 2)
					{
						if (IsPaused[Alive[i]])
						{
							set_hudmessage(200, "", "amxx_configsdir", 1008981770, 1063843267, "amxx_configsdir", "amxx_configsdir", 1045220557, "amxx_configsdir", "amxx_configsdir", "");
						}
						else
						{
							set_hudmessage(12, 122, 221, -1082130432, "amxx_configsdir", "amxx_configsdir", "amxx_configsdir", 1065353216, 1000593162, 1000593162, 1);
						}
						if (HealsOnMap)
						{
							new var6;
							if (IsPaused[Alive[i]])
							{
								var6 = 382736;
							}
							else
							{
								var6 = 382784;
							}
							new var7;
							if (isec < 1.4E-44)
							{
								var7 = 382724;
							}
							else
							{
								var7 = 382732;
							}
							show_hudmessage(Alive[i], "[ %02d:%s%.2f | CP:%dTP:%d | Speed: %d | HP: Godmode %s ]", imin, var7, isec, checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), var6);
						}
						new var8;
						if (IsPaused[Alive[i]])
						{
							var8 = 383012;
						}
						else
						{
							var8 = 383060;
						}
						new var9;
						if (isec < 1.4E-44)
						{
							var9 = 383000;
						}
						else
						{
							var9 = 383008;
						}
						show_hudmessage(Alive[i], "[ %02d:%s%.2f | CP:%dTP:%d | Speed: %d | HP: %d %s ]", imin, var9, isec, checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), get_user_health(Alive[i]), var8);
					}
				}
				if (IsPaused[Alive[i]])
				{
					client_print(Alive[i], 4, "%L", Alive[i], "KZ_ALIVE_ISPAUSE");
				}
			}
			else
			{
				if (ShowTime[Alive[i]] == 1)
				{
					if (HealsOnMap)
					{
						format(output, 127, "[ OFF | %d/%d | Speed: %d | HP: Godmode]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1));
					}
					else
					{
						format(output, 127, "[ OFF | %d/%d | Speed: %d | HP: %d ]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), get_user_health(Alive[i]));
					}
				}
				if (ShowTime[Alive[i]] == 2)
				{
					set_hudmessage(12, 122, 221, 1008981770, 1063843267, "amxx_configsdir", "amxx_configsdir", 1045220557, "amxx_configsdir", "amxx_configsdir", "");
					if (HealsOnMap)
					{
						show_hudmessage(Alive[i], "[ OFF | %d/%d | Speed: %d | HP: Godmode]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1));
					}
					show_hudmessage(Alive[i], "[ OFF | %d/%d | Speed: %d | HP: %d ]", checknumbers[Alive[i]], gochecknumbers[Alive[i]], floatround(speedy, 1), get_user_health(Alive[i]));
				}
			}
			message_begin(1, get_user_msgid("StatusText"), 156, Alive[i]);
			write_byte("amxx_configsdir");
			write_string(output);
			message_end();
			i++;
		}
		new i;
		while (i < deadPlayers)
		{
			new Float:kreedztime = 0.0;
			new imin;
			new Float:isec = 0.0;
			new specmode = pev(Dead[i], 100);
			new var10;
			if (specmode == 2 || specmode == 4)
			{
				new target = pev(Dead[i], 101);
				if (Dead[i] != target)
				{
					new var11;
					if (is_user_alive(target) && timer_started[target])
					{
						new Float:velocity[3] = 0.0;
						pev(target, __dhud_fxtime, velocity);
						if (velocity[2] != 0.0)
						{
							new var23 = velocity[2];
							var23 = floatsub(var23, velocity[2]);
						}
						new Float:speedy = vector_length(velocity);
						new name[32];
						get_user_name(target, name, 31);
						new var12;
						if (IsPaused[target])
						{
							var12 = floatsub(get_gametime(), g_pausetime[target]);
						}
						else
						{
							var12 = timer_time[target];
						}
						kreedztime = floatsub(get_gametime(), var12);
						imin = floatround(kreedztime, 1) / 60;
						isec = floatadd(1017370378, kreedztime - imin * 60);
						if (ShowTime[target] == 1)
						{
							if (is_user_bot(target))
							{
								new var13;
								if (isec < 1.4E-44)
								{
									var13 = 383924;
								}
								else
								{
									var13 = 383932;
								}
								client_print(Dead[i], 4, "[ %02d:%s%.2f | Speed: %d ]", imin, var13, isec, floatround(speedy, 1));
							}
							else
							{
								if (HealsOnMap)
								{
									new var14;
									if (IsPaused[target])
									{
										var14 = 384100;
									}
									else
									{
										var14 = 384148;
									}
									new var15;
									if (isec < 1.4E-44)
									{
										var15 = 384088;
									}
									else
									{
										var15 = 384096;
									}
									client_print(Dead[i], 4, "[ %02d:%s%.2f | %d/%d | Speed: %d %s]", imin, var15, isec, checknumbers[target], gochecknumbers[target], floatround(speedy, 1), var14);
								}
								new var16;
								if (IsPaused[target])
								{
									var16 = 384352;
								}
								else
								{
									var16 = 384400;
								}
								new var17;
								if (isec < 1.4E-44)
								{
									var17 = 384340;
								}
								else
								{
									var17 = 384348;
								}
								client_print(Dead[i], 4, "[ %02d:%s%.2f | %d/%d | Speed: %d | HP: %d %s]", imin, var17, isec, checknumbers[target], gochecknumbers[target], floatround(speedy, 1), get_user_health(target), var16);
							}
						}
						else
						{
							if (ShowTime[target] == 2)
							{
								if (IsPaused[target])
								{
									set_hudmessage(200, "", "amxx_configsdir", -1082130432, 1045220557, "amxx_configsdir", "amxx_configsdir", 1045220557, "amxx_configsdir", "amxx_configsdir", "");
								}
								else
								{
									set_hudmessage(12, 122, 221, -1082130432, 1045220557, "amxx_configsdir", "amxx_configsdir", 1045220557, "amxx_configsdir", "amxx_configsdir", "");
								}
								if (HealsOnMap)
								{
									new var18;
									if (IsPaused[target])
									{
										var18 = 384568;
									}
									else
									{
										var18 = 384616;
									}
									new var19;
									if (isec < 1.4E-44)
									{
										var19 = 384556;
									}
									else
									{
										var19 = 384564;
									}
									show_hudmessage(Dead[i], "[ %02d:%s%.2f | %d/%d | Speed: %d %s]", imin, var19, isec, checknumbers[target], gochecknumbers[target], floatround(speedy, 1), var18);
								}
								new var20;
								if (IsPaused[target])
								{
									var20 = 384820;
								}
								else
								{
									var20 = 384868;
								}
								new var21;
								if (isec < 1.4E-44)
								{
									var21 = 384808;
								}
								else
								{
									var21 = 384816;
								}
								show_hudmessage(Dead[i], "[ %02d:%s%.2f | %d/%d | Speed: %d | HP: %d %s]", imin, var21, isec, checknumbers[target], gochecknumbers[target], floatround(speedy, 1), get_user_health(target), var20);
							}
						}
					}
				}
			}
			i++;
		}
	}
	return 0;
}

public BlockRadio(id)
{
	if (get_pcvar_num(kz_use_radio) == 1)
	{
		return 0;
	}
	return 1;
}

public BlockDrop(id)
{
	if (get_pcvar_num(kz_drop_weapons) == 1)
	{
		return 0;
	}
	return 1;
}

public BlockBuy(id)
{
	return 1;
}

public CmdRespawn(id)
{
	if (get_user_team(id, {0}, "amxx_configsdir") == 3)
	{
		return 1;
	}
	ExecuteHamB(98, id);
	return 1;
}

public Version(id)
{
	ColorChat(id, Color:2, "%s\x01 Server use Public KZ(plugin) \x03%s \x01, Last Edit \x03%s \x01by \x03Perfectslife.", prefix, "2.52", "2019/01/01");
	return 0;
}

public ChatHud(id)
{
	if (get_pcvar_num(kz_chatorhud))
	{
		if (chatorhud[id] == -1)
		{
			chatorhud[id]++;
		}
		chatorhud[id]++;
		if (chatorhud[id] == 3)
		{
			chatorhud[id] = 0;
		}
		else
		{
			new var1;
			if (chatorhud[id] == 1)
			{
				var1 = 385388;
			}
			else
			{
				var1 = 385408;
			}
			kz_chat(id, "%L", id, "KZ_CHATORHUD", var1);
		}
		return 1;
	}
	ColorChat(id, Color:2, "%s\x01 %L", prefix, id, "KZ_CHATORHUD_OFF");
	return 1;
}

public post_player_die(id)
{
	if (timer_started[id])
	{
		if (0 < checknumbers[id])
		{
			set_pev(id, __dhud_fxtime, 385424);
			set_pev(id, 118, Checkpoints[id][g_bCpAlternate[id]]);
			gochecknumbers[id]++;
		}
		else
		{
			set_pev(id, __dhud_fxtime, 385436);
			set_pev(id, 118, SavedStart[id]);
		}
		set_task(1045220557, "givedieweapons", id + 2000, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	}
	else
	{
		give_uspknife(id, 0);
	}
	new var1;
	if (cs_get_user_team(id, 0) == 1 || is_user_bot(id))
	{
		set_pev(id, __dhud_fxtime, 385508);
		set_pev(id, 118, DefaultStartPos);
	}
	return 0;
}

public post_player_spec(id)
{
	set_task(1045220557, "givedieweapons", id + 2000, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public ct(id)
{
	if (floatsub(get_gametime(), antidiestart[id]) < 1056964608)
	{
		kz_chat(id, "Can't use this command now");
		return 1;
	}
	if (is_user_alive(id))
	{
		if (pev(id, 69) == 8)
		{
			kz_chat(id, "%L", id, "KZ_NCMOD_DISABLED");
			return 1;
		}
	}
	new CsTeams:team = cs_get_user_team(id, 0);
	new var1;
	if (team == CsTeams:2 || team == CsTeams:1)
	{
		static entname[33];
		pev(pev(id, 19), 1, entname, 32);
		pev(id, 41, hp_spec[id]);
		new var2;
		if (((!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5) || (equal(entname, "func_door", "amxx_configsdir") && !pev(id, 69) == 5)) && (timer_started[id] && !IsPaused[id]))
		{
			kz_chat(id, "%L", id, "KZ_GROUND_DISABLED");
			return 1;
		}
		pev(id, 118, SpecLoc[id]);
		if (timer_started[id])
		{
			if (!IsPaused[id])
			{
				g_pausetime[id] = floatsub(get_gametime(), timer_time[id]);
				timer_time[id] = 0;
			}
			kz_chat(id, "%L", id, "KZ_PAUSE_ON");
		}
		spec_user[id] = 1;
		cs_set_user_team(id, "", "amxx_configsdir");
		set_pev(id, 70, 0);
		set_pev(id, 69, 5);
		set_pev(id, 73, 128);
		set_pev(id, 80, 2);
	}
	else
	{
		if (get_user_flags(id, "amxx_configsdir") & 1)
		{
			cs_set_user_team(id, 1, "amxx_configsdir");
		}
		else
		{
			cs_set_user_team(id, 2, "amxx_configsdir");
		}
		set_pev(id, 73, 0);
		set_pev(id, 69, 3);
		set_pev(id, 80, 0);
		set_pev(id, 43, 1073741824);
		CmdRespawn(id);
		spec_user[id] = 0;
		if (!HealsOnMap)
		{
			set_pev(id, 41, hp_spec[id]);	//pev_health 191+41
		}
		set_pev(id, 118, SpecLoc[id]);
		set_pev(id, 84, pev(id, 84) | 16384);
		if (timer_started[id])
		{
			if (!IsPaused[id])
			{
				timer_time[id] = floatadd(floatsub(get_gametime(), g_pausetime[id]), timer_time[id]);
			}
			timer_time[id] = g_pausetime[id];
		}
		set_task(1045220557, "post_player_spec", id + 3000, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	}
	return 1;
}

public curweapon(id)
{
	static last_weapon[33];
	static weapon_num;
	static weapon_active;
	weapon_active = read_data(1);
	weapon_num = read_data(2);
	new var1;
	if (last_weapon[id] != weapon_num && weapon_active && get_pcvar_num(kz_maxspeedmsg) == 1)
	{
		last_weapon[id] = weapon_num;
		static Float:maxspeed;
		pev(id, 56, maxspeed);
		if (maxspeed <= 1.0)
		{
			maxspeed = 250.0;
		}
		kz_hud_message(id, "%L", id, "KZ_WEAPONS_SPEED", floatround(maxspeed, 1));
	}
	return 1;
}

public weapons(id)
{
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	if (get_pcvar_num(kz_other_weapons))
	{
		if (timer_started[id])
		{
			kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN");
			return 1;
		}
		static wpncmdent;
		if (is_user_alive(id))
		{
			if (!timer_started[id])
			{
				new i;
				while (i < 8)
				{
					if (!user_has_weapon(id, other_weapons[i], -1))
					{
						wpncmdent = give_item(id, other_weapons_name[i]);
						cs_set_weapon_ammo(wpncmdent, 10);
					}
					i++;
				}
				if (!user_has_weapon(id, 16, -1))
				{
					cmdUsp(id);
				}
			}
			give_uspknife(id, 0);
		}
		ColorChat(id, Color:2, "%s\x01 %L", prefix, id, "KZ_WEAPONS_START");
		return 1;
	}
	kz_chat(id, "%L", id, "KZ_OTHER_WEAPONS_ZERO");
	return 1;
}

public cmdScout(id)
{
	if (timer_started[id])
	{
		user_has_scout[id] = 1;
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN");
		return 1;
	}
	new var1;
	if (wpn_15[id] && timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_WEAPONS_IN_RUN");
		return 1;
	}
	strip_user_weapons(id);
	if (!user_has_weapon(id, "", -1))
	{
		give_item(id, "weapon_scout");
	}
	return 1;
}

public cmdUsp(id)
{
	if (is_user_bot(id))
	{
		return 1;
	}
	give_item(id, g_weaponconst[16]);
	cs_set_user_bpammo(id, 16, __dhud_fadeouttime);
	give_item(id, g_weaponconst[29]);
	return 1;
}

give_uspknife(id, toknife)
{
	if (is_user_bot(id))
	{
		return 0;
	}
	if (!user_has_weapon(id, 16, -1))
	{
		give_item(id, g_weaponconst[16]);
		set_pdata_int(id, 382, 24, 5);
	}
	if (!user_has_weapon(id, 29, -1))
	{
		give_item(id, g_weaponconst[29]);
	}
	if (toknife == 29)
	{
		engclient_cmd(id, g_weaponconst[29], 341596, 341600);
	}
	return 0;
}

public give_scout(id, armita)
{
	new ent = give_item(id, g_weaponconst[armita]);
	cs_set_weapon_ammo(ent, 2);
	return 0;
}

public givedieweapons(id)
{
	strip_user_weapons(id);
	if (!wpn_15[id])
	{
		give_uspknife(id, 0);
	}
	else
	{
		give_scout(id, g_numerodearma[id]);
	}
	return 0;
}

public goStartPos(id)
{
	if (floatsub(get_gametime(), antidiestart[id]) < 1056964608)
	{
		kz_chat(id, "wait a moment......");
		return 1;
	}
	if (!is_user_alive(id))
	{
		if (!timer_started[id])
		{
			if (get_user_flags(id, "amxx_configsdir") & 1)
			{
				cs_set_user_team(id, 1, "amxx_configsdir");
			}
			else
			{
				cs_set_user_team(id, 2, "amxx_configsdir");
			}
			if (!HealsOnMap)
			{
				set_pev(id, 41, hp_spec[id]);
			}
			set_pev(id, 73, 0);	//pev_effects
			set_pev(id, 69, 3);
			set_pev(id, 80, 0);
			set_pev(id, 43, 1073741824);
			CmdRespawn(id);
			strip_user_weapons(id);
			cmdUsp(id);
			if (gCheckpointStart[id])
			{
				set_pev(id, __dhud_holdtime, gCheckpointStartAngle[id]);
				set_pev(id, 65, 1);
				set_pev(id, __dhud_fxtime, 387032);
				set_pev(id, 135, 387044);
				set_pev(id, 84, pev(id, 84) | 16384);
				set_pev(id, 60, 0);
				engfunc(5, id, 387056, 387068);
				set_pev(id, 118, CheckpointStarts[id][!g_bCpAlternateStart[id]]);
			}
			else
			{
				if (AutoStart[id])
				{
					set_pev(id, __dhud_fxtime, 387080);
					set_pev(id, 84, pev(id, 84) | 16384);
					set_pev(id, 118, SavedStart[id]);
				}
				set_pev(id, __dhud_fxtime, 387092);
				set_pev(id, 118, DefaultStartPos);
			}
		}
		else
		{
			ct(id);
		}
		return 1;
	}
	new var1;
	if (get_pcvar_num(kz_save_autostart) == 1 && AutoStart[id])
	{
		tptostart[id] = 1;
		if (gCheckpointStart[id])
		{
			new var2;
			if (timer_started[id] && !IsPaused[id])
			{
				tphook_user[id] = 1;
				Pause(id);
			}
			set_pev(id, __dhud_holdtime, gCheckpointStartAngle[id]);
			set_pev(id, 65, 1);
			set_pev(id, __dhud_fxtime, 387104);
			set_pev(id, 135, 387116);
			set_pev(id, 84, pev(id, 84) | 16384);
			set_pev(id, 60, 0);
			engfunc(5, id, 387128, 387140);
			set_pev(id, 118, CheckpointStarts[id][!g_bCpAlternateStart[id]]);
		}
		else
		{
			new var3;
			if (timer_started[id] && !IsPaused[id])
			{
				tphook_user[id] = 1;
				Pause(id);
			}
			set_pev(id, __dhud_fxtime, 387152);
			set_pev(id, 84, pev(id, 84) | 16384);
			set_pev(id, 118, SavedStart[id]);
		}
		return 1;
	}
	if (DefaultStart)
	{
		tptostart[id] = 1;
		if (gCheckpointStart[id])
		{
			new var4;
			if (timer_started[id] && !IsPaused[id])
			{
				tphook_user[id] = 1;
				Pause(id);
			}
			set_pev(id, __dhud_holdtime, gCheckpointStartAngle[id]);
			set_pev(id, 65, 1);
			set_pev(id, __dhud_fxtime, 387164);
			set_pev(id, 135, 387176);
			set_pev(id, 84, pev(id, 84) | 16384);
			set_pev(id, 60, 0);
			engfunc(5, id, 387188, 387200);
			set_pev(id, 118, CheckpointStarts[id][!g_bCpAlternateStart[id]]);
		}
		else
		{
			new var5;
			if (timer_started[id] && !IsPaused[id])
			{
				tphook_user[id] = 1;
				Pause(id);
			}
			set_pev(id, __dhud_fxtime, 387212);
			set_pev(id, 118, DefaultStartPos);
		}
		return 1;
	}
	kz_chat(id, "%L", id, "KZ_NO_START");
	CmdRespawn(id);
	return 1;
}

public setStart(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS");
		return 1;
	}
	new Float:origin[3] = 0.0;
	pev(id, 118, origin);
	kz_set_start(MapName, origin);
	AutoStart[id] = 0;
	ColorChat(id, Color:2, "%s\x01 %L.", prefix, id, "KZ_SET_START");
	return 1;
}

public setStop(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS");
		return 1;
	}
	new Float:origin[3] = 0.0;
	pev(id, 118, origin);
	kz_set_stop(MapName, origin);
	ColorChat(id, Color:2, "%s\x01 Finish position set for this map", prefix);
	return 1;
}

public Origin(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		kz_chat(id, "%L", id, "KZ_NO_ACCESS");
		return 1;
	}
	new Float:sporigin[3] = 0.0;
	pev(id, 118, sporigin);
	ColorChat(id, Color:2, "%s\x01 %d,%d,%d", prefix, sporigin, sporigin[1], sporigin[2]);
	return 1;
}

public Ham_CBasePlayer_Killed_Pre(id)
{
	antidiestart[id] = get_gametime();
	return 0;
}

public Ham_CBasePlayer_Killed_Post(id)
{
	if (!is_user_alive(id))
	{
		entity_set_int(id, 2, "amxx_configsdir");
	}
	if (get_pcvar_num(kz_respawn_ct) == 1)
	{
		new var1;
		if (cs_get_user_team(id, 0) == 2 || cs_get_user_team(id, 0) == 1)
		{
			set_pev(id, 80, 3);
			cs_set_user_deaths(id, "amxx_configsdir");
			set_user_frags(id, "amxx_configsdir");
			set_task(1045220557, "post_player_die", id + 4000, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
	}
	return 0;
}

public ToggleNVG(id)
{
	if (get_pcvar_num(kz_nvg))
	{
		if (NightVisionUse[id])
		{
			StopNVG(id);
		}
		else
		{
			StartNVG(id);
		}
		return 1;
	}
	return 0;
}

public StartNVG(id)
{
	if (is_user_alive(id))
	{
		emit_sound(id, "", "items/nvg_on.wav", 1065353216, 1061997773, "amxx_configsdir", 100);
	}
	else
	{
		client_cmd(id, "spk items/nvg_on.wav");
	}
	set_task(1036831949, "RunNVG", id + 111111, 340908, "amxx_configsdir", 388004, "amxx_configsdir");
	NightVisionUse[id] = 1;
	return 1;
}

public StopNVG(id)
{
	if (is_user_alive(id))
	{
		emit_sound(id, "", "items/nvg_off.wav", 1065353216, 1061997773, "amxx_configsdir", 100);
	}
	else
	{
		client_cmd(id, "spk items/nvg_off.wav");
	}
	remove_task(id + 111111, "amxx_configsdir");
	NightVisionUse[id] = 0;
	return 1;
}

public RunNVG(taskid)
{
	new id = taskid + -111111;
	new origin[3];
	get_user_origin(id, origin, "");
	new color[17];
	get_pcvar_string(kz_nvg_colors, color, 16);
	new iRed[5];
	new iGreen[7];
	new iBlue[5];
	parse(color, iRed, 4, iGreen, 6, iBlue, 4);
	new i = 1;
	while (i < max_players)
	{
		new var1;
		if (id != i && is_user_spectating_player(i, id))
		{
			message_begin(8, 23, 156, i);
			write_byte(27);
			write_coord(origin[0]);
			write_coord(origin[1]);
			write_coord(origin[2]);
			write_byte(80);
			write_byte(str_to_num(iRed));
			write_byte(str_to_num(iGreen));
			write_byte(str_to_num(iBlue));
			write_byte(2);
			write_byte("amxx_configsdir");
			message_end();
		}
		i++;
	}
	return 0;
}

public Ham_HookTouch(ent, id)
{
	new var1;
	if (is_user_alive(id) && !1 <= ent <= get_maxplayers())
	{
		pev(id, 118, g_iHookWallOrigin[id]);
		if (is_user_alive(ent))
		{
			pev(ent, 118, hookorigin[id]);
		}
	}
	return 0;
}

public hook_on(id)
{
	new var1;
	if ((!canusehook[id] && !get_user_flags(id, "amxx_configsdir") & 8) || !is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	if (get_user_noclip(id))
	{
		set_user_noclip(id, "amxx_configsdir");
	}
	if (!timer_started[id])
	{
		antihook(id);
		return 1;
	}
	static entname[33];
	pev(pev(id, 19), 1, entname, 32);
	new var3;
	if (equal(entname, "func_door", "amxx_configsdir") && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_TIME_START_HOOK");
		return 1;
	}
	new var4;
	if (!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5 && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_TIME_START_HOOK");
		return 1;
	}
	new var5;
	if (timer_started[id] && IsPaused[id])
	{
		antihook(id);
		return 1;
	}
	new var6;
	if (timer_started[id] && !IsPaused[id])
	{
		Pause(id);
		antihook(id);
		return 1;
	}
	return 1;
}

public antihook(id)
{
	get_user_origin(id, hookorigin[id], "");
	if (get_pcvar_num(kz_hook_sound) == 1)
	{
		emit_sound(id, 6, "weapons/xbow_hit2.wav", 1065353216, 1061997773, "amxx_configsdir", 100);
	}
	ishooked[id] = 1;
	set_task(1036831949, "hook_task", id, 388712, "amxx_configsdir", "ab", "amxx_configsdir");
	hook_task(id);
	return 0;
}

public hook_off(id)
{
	remove_hook(id);
	return 1;
}

public hook_task(id)
{
	if (!is_user_alive(id))
	{
		remove_hook(id);
		return 0;
	}
	message_begin("amxx_configsdir", 23, 156, "amxx_configsdir");
	write_byte(99);
	write_short(id);
	message_end();
	message_begin("amxx_configsdir", 23, 156, "amxx_configsdir");
	write_byte(1);
	write_short(id);
	write_coord(hookorigin[id][0]);
	write_coord(hookorigin[id][1]);
	write_coord(hookorigin[id][2]);
	write_short(Sbeam);
	write_byte(1);
	write_byte(1);
	write_byte(2);
	write_byte(18);
	write_byte("amxx_configsdir");
	write_byte(random_num(1, ""));
	write_byte(random_num(1, ""));
	write_byte(random_num(1, ""));
	write_byte(200);
	write_byte("amxx_configsdir");
	message_end();
	static i;
	static distance;
	static Float:velocity[3];
	static origin[3];
	get_user_origin(id, origin, "amxx_configsdir");
	distance = get_distance(hookorigin[id], origin);
	set_pev(id, 76, 6);
	antihookcheat[id] = get_gametime();
	if (distance > 50)
	{
		if (vector_length(g_iHookWallOrigin[id]))
		{
			arrayset(g_iHookWallOrigin[id], "amxx_configsdir", "");
		}
		i = 0;
		while (i < 3)
		{
			velocity[i] = floatmul(1069547520, float(get_pcvar_num(kz_hook_speed))) / distance * hookorigin[id][i] - origin[i];
			i += 1;
		}
	}
	else
	{
		if (distance > 10)
		{
			if (vector_length(g_iHookWallOrigin[id]))
			{
				arrayset(g_iHookWallOrigin[id], "amxx_configsdir", "");
			}
			i = 0;
			while (i < 3)
			{
				velocity[i] = float(get_pcvar_num(kz_hook_speed) / 2) / distance + 20 * hookorigin[id][i] - origin[i];
				i += 1;
			}
		}
		if (vector_length(g_iHookWallOrigin[id]))
		{
			set_pev(id, 118, g_iHookWallOrigin[id]);
		}
	}
	set_pev(id, __dhud_fxtime, velocity);
	return 0;
}

public remove_hook(id)
{
	if (task_exists(id, "amxx_configsdir"))
	{
		remove_task(id, "amxx_configsdir");
	}
	remove_beam(id);
	ishooked[id] = 0;
	return 0;
}

public remove_beam(id)
{
	message_begin("amxx_configsdir", 23, 156, "amxx_configsdir");
	write_byte(99);
	write_short(id);
	message_end();
	return 0;
}

public MessageScoreAttrib(iMsgID, iDest, iReceiver)
{
	if (get_pcvar_num(kz_vip))
	{
		new iPlayer = get_msg_arg_int(1);
		new var1;
		if (is_user_alive(iPlayer) && get_user_flags(iPlayer, "amxx_configsdir") & 8)
		{
			set_msg_arg_int(2, 1, 4);
		}
	}
	return 0;
}

public CheckPoint(id)
{
	new var1;
	if (GoPosCp[id] && is_user_alive(id))
	{
		new var2;
		if (g_bCpAlternate[id])
		{
			var2 = 1;
		}
		else
		{
			var2 = 0;
		}
		pev(id, 118, Checkpoints[id][var2]);
		g_bCpAlternate[id] = !g_bCpAlternate[id];
		new var3;
		if (g_bCpAlternate[id])
		{
			var3 = 1;
		}
		else
		{
			var3 = 0;
		}
		pev(id, 118, Checkpoints[id][var3]);
		g_bCpAlternate[id] = !g_bCpAlternate[id];
		GoPosCp[id] = 0;
		return 1;
	}
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	if (get_pcvar_num(kz_checkpoints))
	{
		static entname[33];
		pev(pev(id, 19), 1, entname, 32);
		new var4;
		if (equal(entname, "func_door", "amxx_configsdir") && !SlideMap && !pev(id, 69) == 5)
		{
			kz_chat(id, "%L", id, "KZ_CBBLOCK_DISABLED");
			return 1;
		}
		new var5;
		if (!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5 && timer_started[id] && !IsPaused[id])
		{
			kz_chat(id, "%L", id, "KZ_CHECKPOINT_AIR");
			return 1;
		}
		if (gCheckpoint[id])
		{
			gLastCheckpointAngle[id][0] = gCheckpointAngle[id][0];
			gLastCheckpointAngle[id][1] = gCheckpointAngle[id][1];
			gLastCheckpointAngle[id][2] = gCheckpointAngle[id][2];
		}
		pev(id, 126, gCheckpointAngle[id]);
		gCheckpoint[id] = 1;
		if (IsPaused[id])
		{
			kz_chat(id, "%L", id, "KZ_CHECKPOINT_INPAUSE");
			new var6;
			if (g_bInPauseCpAlternate[id])
			{
				var6 = 1;
			}
			else
			{
				var6 = 0;
			}
			pev(id, 118, InPauseCheckpoints[id][var6]);
			g_bInPauseCpAlternate[id] = !g_bInPauseCpAlternate[id];
			inpausechecknumbers[id]++;
			return 1;
		}
		new var7;
		if (g_bCpAlternate[id])
		{
			var7 = 1;
		}
		else
		{
			var7 = 0;
		}
		pev(id, 118, Checkpoints[id][var7]);
		g_bCpAlternate[id] = !g_bCpAlternate[id];
		checknumbers[id]++;
		return 1;
	}
	kz_chat(id, "%L", id, "KZ_CHECKPOINT_OFF");
	return 1;
}

public CheckPointStart(id)
{
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	static entname[33];
	pev(pev(id, 19), 1, entname, 32);
	new var1;
	if ((!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5) || (equal(entname, "func_door", "amxx_configsdir") && !pev(id, 69) == 5))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ON_GROUND");
		return 1;
	}
	if (gCheckpointStart[id])
	{
		gLastCheckpointStartAngle[id][0] = gCheckpointStartAngle[id][0];
		gLastCheckpointStartAngle[id][1] = gCheckpointStartAngle[id][1];
		gLastCheckpointStartAngle[id][2] = gCheckpointStartAngle[id][2];
	}
	pev(id, 126, gCheckpointStartAngle[id]);
	gCheckpointStart[id] = 1;
	new var4;
	if (g_bCpAlternateStart[id])
	{
		var4 = 1;
	}
	else
	{
		var4 = 0;
	}
	pev(id, 118, CheckpointStarts[id][var4]);
	g_bCpAlternateStart[id] = !g_bCpAlternateStart[id];
	kz_chat(id, "%L", id, "KZ_SAVE_START");
	return 1;
}

public GoCheck(id)
{
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	new var1;
	if (checknumbers[id] && inpausechecknumbers[id])
	{
		kz_chat(id, "%L", id, "KZ_NOT_ENOUGH_CHECKPOINTS");
		return 1;
	}
	new var2;
	if (tpfenabled[id] || gc1[id])
	{
		set_pev(id, __dhud_holdtime, gCheckpointAngle[id]);
		set_pev(id, 65, 1);
		gc1[id] = 0;
	}
	new var3;
	if (IsPaused[id] && inpausechecknumbers[id] > 0)
	{
		kz_chat(id, "%L", id, "KZ_TELEPORT_INPAUSE");
		set_pev(id, __dhud_fxtime, 390024);
		set_pev(id, 135, 390036);
		set_pev(id, 84, pev(id, 84) | 16384);
		set_pev(id, 60, 0);
		set_pev(id, 34, 1065353216);
		engfunc(5, id, 390048, 390060);
		set_pev(id, 118, InPauseCheckpoints[id][!g_bInPauseCpAlternate[id]]);
		return 1;
	}
	set_pev(id, __dhud_fxtime, 390072);
	set_pev(id, 135, 390084);
	set_pev(id, 84, pev(id, 84) | 16384);
	set_pev(id, 60, 0);
	set_pev(id, 34, 1065353216);
	engfunc(5, id, 390096, 390108);
	set_pev(id, 118, Checkpoints[id][!g_bCpAlternate[id]]);
	new var4;
	if (timer_started[id] && !IsPaused[id])
	{
		new var5;
		if (!WasPlayed[id] && !GoPosed[id])
		{
			client_cmd(id, "spk fvox/blip");
			WasPlayed[id] = 1;
		}
	}
	gochecknumbers[id]++;
	return 1;
}

public GoCheck1(id)
{
	gc1[id] = 1;
	GoCheck(id);
	return 1;
}

public Stuck(id)
{
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	new var1;
	if (IsPaused[id] && inpausechecknumbers[id] > 1)
	{
		set_pev(id, __dhud_fxtime, 390240);
		set_pev(id, 135, 390252);
		set_pev(id, 84, pev(id, 84) | 16384);
		set_pev(id, 60, 0);
		engfunc(5, id, 390264, 390276);
		set_pev(id, 118, InPauseCheckpoints[id][g_bInPauseCpAlternate[id]]);
		g_bInPauseCpAlternate[id] = !g_bInPauseCpAlternate[id];
		return 1;
	}
	if (2 > checknumbers[id])
	{
		kz_chat(id, "%L", id, "KZ_NOT_ENOUGH_STUCK_CHECKPOINTS");
		return 1;
	}
	set_pev(id, __dhud_fxtime, 390428);
	set_pev(id, 135, 390440);
	set_pev(id, 84, pev(id, 84) | 16384);
	set_pev(id, 60, 0);
	engfunc(5, id, 390452, 390464);
	set_pev(id, 118, Checkpoints[id][g_bCpAlternate[id]]);
	g_bCpAlternate[id] = !g_bCpAlternate[id];
	new var2;
	if (timer_started[id] && !IsPaused[id])
	{
		new var3;
		if (!WasPlayed[id] && !GoPosed[id])
		{
			client_cmd(id, "spk fvox/blip");
			WasPlayed[id] = 1;
		}
		gochecknumbers[id]++;
	}
	return 1;
}

public reset_checkpoints(id)
{
	checknumbers[id] = 0;
	gochecknumbers[id] = 0;
	inpausechecknumbers[id] = 0;
	timer_started[id] = 0;
	timer_time[id] = 0;
	user_has_scout[id] = 0;
	IsPaused[id] = 0;
	WasPlayed[id] = 0;
	message_begin(1, get_user_msgid("ScreenFade"), 390576, id);
	write_short(1024);
	write_short(1024);
	write_short("amxx_configsdir");
	write_byte("");
	write_byte(192);
	write_byte(203);
	write_byte(65);
	message_end();
	if (timer_started[id])
	{
		if (IsPaused[id])
		{
			return 1;
		}
	}
	return 1;
}

public reset_checkpoints1(id)
{
	checknumbers[id] = 0;
	inpausechecknumbers[id] = 0;
	gochecknumbers[id] = 0;
	timer_started[id] = 0;
	timer_time[id] = 0;
	user_has_scout[id] = 0;
	IsPaused[id] = 0;
	WasPlayed[id] = 0;
	if (timer_started[id])
	{
		if (IsPaused[id])
		{
			message_begin(1, get_user_msgid("ScreenFade"), 390632, id);
			write_short(1024);
			write_short(1024);
			write_short("amxx_configsdir");
			write_byte("amxx_configsdir");
			write_byte("amxx_configsdir");
			write_byte("amxx_configsdir");
			write_byte("amxx_configsdir");
			message_end();
			return 1;
		}
	}
	message_begin(1, get_user_msgid("ScreenFade"), 390632, id);
	write_short(1024);
	write_short(1024);
	write_short("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	write_byte("amxx_configsdir");
	message_end();
	return 1;
}

public cmdInvisible(id)
{
	gViewInvisible[id] = !gViewInvisible[id];
	if (gViewInvisible[id])
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_PLAYERS_ON");
	}
	else
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_PLAYERS_OFF");
	}
	InvisMenu(id);
	return 1;
}

public cmdWaterInvisible(id)
{
	if (!gWaterFound)
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_NOWATER");
		InvisMenu(id);
		return 1;
	}
	gWaterInvisible[id] = !gWaterInvisible[id];
	if (gWaterInvisible[id])
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_WATER_ON");
	}
	else
	{
		kz_chat(id, "%L", id, "KZ_INVISIBLE_WATER_OFF");
	}
	InvisMenu(id);
	return 1;
}

public FM_client_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet)
{
	if (player)
	{
		new Players[32];
		new Count;
		get_players(Players, Count, "ah", 152);
		new var1;
		if (gViewInvisible[host] && is_user_alive(ent) && Count > 1 && !is_user_bot(host))
		{
			UpdateSpectator();
			new var2;
			if (is_user_alive(host) || id_spectated[host] == ent)
			{
				kz_set_es(es);
			}
		}
	}
	else
	{
		new var3;
		if (gWaterInvisible[host] && gWaterEntity[ent] && !is_user_bot(host))
		{
			set_es(es, 12, get_es(es, 12) | 128);
		}
	}
	return 1;
}

public OnCmdStart(id)
{
	if (!g_bReadPackets)
	{
		g_bReadPackets = true;
		static plr;
		get_players(g_iPlayers, g_iNum, 391180, 152);
		g_iNum -= 1;
		while (0 <= g_iNum)
		{
			plr = g_iPlayers[g_iNum];
			entity_set_int(plr, 2, 1 << plr & 31);
			g_iNum -= 1;
		}
		g_iLastPlayerIndex = 0;
	}
	new var1;
	if (g_iLastPlayerIndex && is_user_alive(g_iLastPlayerIndex))
	{
		entity_set_int(g_iLastPlayerIndex, 2, 1 << g_iLastPlayerIndex & 31);
	}
	if (is_user_alive(id))
	{
		entity_set_int(id, 2, 1 << id & 31);
		new var2;
		if (!1 << id & 31 & g_bitBots && !gViewInvisible[id])
		{
			if (!g_bPreThinkHooked)
			{
				EnableHamForward(g_iHhPreThink);
				EnableHamForward(g_iHhPreThinkPost);
				g_bPreThinkHooked = true;
			}
		}
		else
		{
			if (g_bPreThinkHooked)
			{
				DisableHamForward(g_iHhPreThink);
				DisableHamForward(g_iHhPreThinkPost);
				g_bPreThinkHooked = false;
			}
		}
	}
	else
	{
		entity_set_int(id, 2, "amxx_configsdir");
		g_iLastPlayerIndex = id;
		if (g_bPreThinkHooked)
		{
			DisableHamForward(g_iHhPreThink);
			DisableHamForward(g_iHhPreThinkPost);
			g_bPreThinkHooked = false;
		}
	}
	return 0;
}

public OnCBasePlayer_PreThink(id)
{
	entity_set_int(id, 2, "amxx_configsdir");
	return 0;
}

public OnCBasePlayer_PreThink_P(id)
{
	entity_set_int(id, 2, 1 << id & 31);
	return 0;
}

public server_frame()
{
	g_iLastPlayerIndex = 0;
	g_bReadPackets = false;
	g_bClientMessages = false;
	static id;
	get_players(g_iPlayers, g_iNum, 391192, 152);
	g_iNum -= 1;
	while (0 <= g_iNum)
	{
		id = g_iPlayers[g_iNum];
		entity_set_int(id, 2, 1 << id & 31);
		g_iNum -= 1;
	}
	return 0;
}

public OnUpdateClientData_P(id, sendweapons, cd)
{
	if (1 << id & 31 & g_bitBots)
	{
		return 0;
	}
	if (!g_bClientMessages)
	{
		g_bClientMessages = true;
		g_bitIsPlayerAlive = 0;
		get_players(g_iPlayers, g_iNum, 391200, 152);
		static player;
		g_iNum -= 1;
		while (0 <= g_iNum)
		{
			player = g_iPlayers[g_iNum];
			g_bitIsPlayerAlive = 1 << player & 31 | g_bitIsPlayerAlive;
			entity_set_int(player, 2, 1);
			g_iNum -= 1;
		}
	}
	if (1 << id & 31 & g_bitIsPlayerAlive)
	{
		if (g_iLastPlayerIndex)
		{
			entity_set_int(g_iLastPlayerIndex, 2, 1);
			g_iLastPlayerIndex = 0;
		}
		static group;
		if (!gViewInvisible[id])
		{
			group = 1;
			g_bitIsPlayerInSphere = 0;
			g_iNum = find_sphere_class(id, CLASS_PLAYER, 1145569280, g_iPlayers, g_maxplayers, 391216);
			static player;
			g_iNum -= 1;
			while (0 <= g_iNum)
			{
				player = g_iPlayers[g_iNum];
				if (id != player)
				{
					g_bitIsPlayerInSphere = 1 << player & 31 | g_bitIsPlayerInSphere;
				}
				g_iNum -= 1;
			}
			if (g_bitIsPlayerInSphere)
			{
				if (!g_iFhAddToFullPackPost)
				{
					g_iFhAddToFullPackPost = register_forward(__dhud_holdtime, "OnAddToFullPack_P", 1);
				}
			}
			else
			{
				if (g_iFhAddToFullPackPost)
				{
					unregister_forward(__dhud_holdtime, g_iFhAddToFullPackPost, 1);
					g_iFhAddToFullPackPost = 0;
				}
			}
		}
		else
		{
			group = 2;
			g_iLastPlayerIndex = id;
			if (g_iFhAddToFullPackPost)
			{
				unregister_forward(__dhud_holdtime, g_iFhAddToFullPackPost, 1);
				g_iFhAddToFullPackPost = 0;
			}
		}
		entity_set_int(id, 2, group);
	}
	return 0;
}

public OnAddToFullPack_P(es, e, ent, id, hostflags, player, pSet)
{
	if (player)
	{
		new var1;
		if (1 << ent & 31 & g_bitIsPlayerAlive && 1 << ent & 31 & g_bitIsPlayerInSphere)
		{
			set_es(es, 11, 0);
			set_es(es, 15, 5);
			set_es(es, 16, floatround(floatdiv(floatmul(1132396544, entity_range(id, ent)), 1145569280), 1));
		}
	}
	else
	{
		unregister_forward(__dhud_holdtime, g_iFhAddToFullPackPost, 1);
		g_iFhAddToFullPackPost = 0;
	}
	return 0;
}

public UpdateSpectator()
{
	new i = 1;
	while (i <= g_maxplayers)
	{
		new var1;
		if (!is_user_connected(i) || is_user_alive(i))
		{
		}
		else
		{
			id_spectated[i] = pev(i, 101);
		}
		i++;
	}
	return 0;
}

kz_set_es(es)
{
	set_es(es, 18, 19);
	set_es(es, 17, 0, 0, 0);
	set_es(es, 15, 4);
	set_es(es, 16, 0);
	set_es(es, 4, 391304);
	return 0;
}

// 显示玩家鼠标指向玩家的相关信息 [pro:xxx] [vip:xxx]
public Ham_CBasePlayer_PreThink_Post(id)
{
	if (!is_user_alive(id))
	{
		return 0;
	}
	new Target;
	new aux;
	get_user_aiming(id, Target, aux, 9999);
	if (is_user_alive(Target))
	{
		decl Float:kreedztime;
		new var1;
		if (IsPaused[Target])
		{
			var1 = floatsub(get_gametime(), g_pausetime[Target]);
		}
		else
		{
			var1 = timer_time[Target];
		}
		kreedztime = floatsub(get_gametime(), var1);
		new imin = floatround(floatdiv(kreedztime, 1114636288), 1);
		new isec = floatround(floatsub(kreedztime, 1114636288 * imin), 1);
		new ims = floatround(floatmul(1120403456, floatsub(kreedztime, 1114636288 * imin + isec)), 1);
		new name[32];
		new authid[32];
		new uflags = get_user_flags(Target, "amxx_configsdir");
		get_user_name(Target, name, 31);
		get_user_authid(Target, authid, 31);
		set_hudmessage(__dhud_holdtime, 252, "amxx_configsdir", -1082130432, -1082130432, "amxx_configsdir", "amxx_configsdir", 1045220557, "amxx_configsdir", "amxx_configsdir", 4);
		if (timer_started[Target])
		{
			new var2;
			if (is_user_bot(Target) && equali(name, "[PRO]", 5))
			{
				show_hudmessage(id, "[PRO] %s", g_ReplayName);
			}
			else
			{
				new var3;
				if (is_user_bot(Target) && equali(name, "[NUB]", 5))
				{
					show_hudmessage(id, "[NUB] %s", gc_ReplayName);
				}
				if (uflags & 16384)
				{
					new var4;
					if (IsPaused[Target])
					{
						var4 = 391572;
					}
					else
					{
						var4 = 391616;
					}
					show_hudmessage(id, "VIP: %s\n[%02i:%02i:%0i | %d/%d%s]", name, imin, isec, ims, checknumbers[Target], gochecknumbers[Target], var4);
				}
				if (uflags & 1)
				{
					new var5;
					if (IsPaused[Target])
					{
						var5 = 391768;
					}
					else
					{
						var5 = 391812;
					}
					show_hudmessage(id, "ADMIN: %s\n[%02i:%02i:%02i | %d/%d%s]", name, imin, isec, ims, checknumbers[Target], gochecknumbers[Target], var5);
				}
				new var6;
				if (IsPaused[Target])
				{
					var6 = 391936;
				}
				else
				{
					var6 = 391980;
				}
				show_hudmessage(id, "%s\n[%02i:%02i:%02i | %d/%d%s]", name, imin, isec, ims, checknumbers[Target], gochecknumbers[Target], var6);
			}
		}
		else
		{
			new var7;
			if (is_user_bot(Target) && equali(name, "[PRO]", 5))
			{
				show_hudmessage(id, "[PRO] %s", g_ReplayName);
			}
			new var8;
			if (is_user_bot(Target) && equali(name, "[NUB]", 5))
			{
				show_hudmessage(id, "[NUB] %s", gc_ReplayName);
			}
			if (uflags & 16384)
			{
				show_hudmessage(id, "VIP: %s\n[OFF | %d/%d]", name, checknumbers[Target], gochecknumbers[Target]);
			}
			if (uflags & 1)
			{
				show_hudmessage(id, "ADMIN: %s\n[OFF | %d/%d]", name, checknumbers[Target], gochecknumbers[Target]);
			}
			show_hudmessage(id, "%s\n[OFF | %d/%d]", name, checknumbers[Target], gochecknumbers[Target]);
		}
	}
	return 0;
}

public FM_PlayerEmitSound(id, channel, sound[])
{
	if (TrieKeyExists(g_tSounds, sound))
	{
		return 4;
	}
	return 1;
}

public noclip(id)
{
	decl noclip;
	noclip = !get_user_noclip(id);
	static entname[33];
	pev(pev(id, 19), 1, entname, 32);
	new var1;
	if (equal(entname, "func_door", "amxx_configsdir") && timer_started[id] && !IsPaused[id])
	{
		kz_chat(id, "%L", id, "KZ_NBBLOCK_DISABLED");
		return 1;
	}
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	new var2;
	if (!FL_ONGROUND2 & pev(id, 84) && !pev(id, 69) == 5 && timer_started[id] && !IsPaused[id])
	{
		return 1;
	}
	set_user_noclip(id, noclip);
	new var3;
	if (!IsPaused[id] && noclip && timer_started[id])
	{
		Pause(id);
	}
	new var4;
	if (IsPaused[id] && get_pcvar_num(kz_noclip_pause) == 1)
	{
		if (noclip)
		{
			tphook_user[id] = 1;
		}
		set_pev(id, 84, pev(id, 84) | 16384);
	}
	new var5;
	if (noclip)
	{
		var5 = 392736;
	}
	else
	{
		var5 = 392748;
	}
	kz_chat(id, "%L", id, "KZ_NOCLIP", var5);
	antinoclipstart[id] = get_gametime();
	return 1;
}

public GodMode(id)
{
	if (!is_user_alive(id))
	{
		kz_chat(id, "%L", id, "KZ_NOT_ALIVE");
		return 1;
	}
	if (timer_started[id])
	{
		kz_chat(id, "%L", id, "KZ_INSTARTTIME");
		return 1;
	}
	decl godmode;
	godmode = !get_user_godmode(id);
	set_user_godmode(id, godmode);
	set_user_noclip(id, "amxx_configsdir");
	new var1;
	if (godmode)
	{
		var1 = 392956;
	}
	else
	{
		var1 = 392968;
	}
	kz_chat(id, "%L", id, "KZ_GODMODE", var1);
	return 1;
}

kz_set_start(map[], Float:origin[3])
{
	new realfile[128];
	new tempfile[128];
	new formatorigin[50];
	formatex(realfile, 127, "%s/%s", Kzdir, KZ_STARTFILE);
	formatex(tempfile, 127, "%s/%s", Kzdir, KZ_STARTFILE_TEMP);
	formatex(formatorigin, 49, "%f %f %f", origin, origin[1], origin[2]);
	DefaultStart = true;
	new file = fopen(tempfile, "wt");
	new vault = fopen(realfile, "rt");
	new data[128];
	new key[64];
	new bool:replaced;
	while (!feof(vault))
	{
		fgets(vault, data, 127);
		parse(data, key, 63);
		new var1;
		if (equal(key, map, "amxx_configsdir") && !replaced)
		{
			fprintf(file, "%s %s\n", map, formatorigin);
			replaced = true;
		}
		else
		{
			fputs(file, data);
		}
	}
	if (!replaced)
	{
		fprintf(file, "%s %s\n", map, formatorigin);
	}
	fclose(file);
	fclose(vault);
	delete_file(realfile);
	do {
	} while (!rename_file(tempfile, realfile, 1));
	return 0;
}

kz_set_stop(map[], Float:origin[3])
{
	new realfile[128];
	new tempfile[128];
	new formatorigin[50];
	formatex(realfile, 127, "%s/%s", Kzdir, KZ_FINISHFILE);
	formatex(tempfile, 127, "%s/%s", Kzdir, KZ_FINISHFILE_TEMP);
	formatex(formatorigin, 49, "%f %f %f", origin, origin[1], origin[2]);
	DefaultStop = true;
	new file = fopen(tempfile, "wt");
	new vault = fopen(realfile, "rt");
	new data[128];
	new key[64];
	new bool:replaced;
	while (!feof(vault))
	{
		fgets(vault, data, 127);
		parse(data, key, 63);
		new var1;
		if (equal(key, map, "amxx_configsdir") && !replaced)
		{
			fprintf(file, "%s %s\n", map, formatorigin);
			replaced = true;
		}
		else
		{
			fputs(file, data);
		}
	}
	if (!replaced)
	{
		fprintf(file, "%s %s\n", map, formatorigin);
	}
	fclose(file);
	fclose(vault);
	delete_file(realfile);
	do {
	} while (!rename_file(tempfile, realfile, 1));
	return 0;
}

ReadMaps()
{
	get_localinfo("amxx_datadir", g_szDir, 127);
	format(g_szDir, 127, "%s/%s", g_szDir, g_szDirFile);
	if (!dir_exists(g_szDir))
	{
		mkdir(g_szDir);
	}
	new szFile[128];
	format(szFile, 127, "%s/%s", g_szDir, g_szAxnMapFile);
	if (!file_exists(szFile))
	{
		new hFile = fopen(szFile, "wt");
		fputs(hFile, ";bbs.simen.com\n\n");
		fclose(hFile);
	}
	new szMapName[32];
	get_mapname(szMapName, 31);
	new hFile = fopen(szFile, 393492);
	new szData[512];
	while (!feof(hFile))
	{
		fgets(hFile, szData, 511);
		trim(szData);
		new var1;
		if (!(!szData[0] || szData[0] == 10 || szData[0] == 59))
		{
			if (equali(szData, szMapName, "amxx_configsdir"))
			{
				return 1;
			}
		}
	}
	fclose(hFile);
	return 0;
}

kz_chat(id, message[])
{
	new cvar = get_pcvar_num(kz_chatorhud);
	if (cvar)
	{
		new msg[200];
		new final[198];
		new var1;
		if ((cvar == 1 && chatorhud[id] == -1) || chatorhud[id] == 1)
		{
			vformat(msg, 199, message, "");
			formatex(final, 197, "%s\x01 %s", prefix, msg);
			kz_remplace_colors(final, 191);
			ColorChat(id, Color:2, "%s", final);
		}
		else
		{
			new var3;
			if ((cvar == 2 && chatorhud[id] == -1) || chatorhud[id] == 2)
			{
				vformat(msg, 199, message, "");
				replace_all(msg, 197, 393540, 393548);
				replace_all(msg, 197, 393552, 393560);
				replace_all(msg, 197, 393564, 393572);
				replace_all(msg, 197, 393576, 393584);
				kz_hud_message(id, "%s", msg);
			}
		}
		return 1;
	}
	return 1;
}

kz_remplace_colors(message[], len)
{
	replace_all(message, len, "!g", 393612);
	replace_all(message, len, "!t", 393632);
	replace_all(message, len, "!y", 393652);
	return 0;
}

kz_hud_message(id, message[])
{
	static b[4];
	static g[4];
	static r[4];
	static colors[12];
	static msg[192];
	vformat(msg, 191, message, "");
	get_pcvar_string(kz_hud_color, colors, 11);
	parse(colors, r, 3, g, 3, b, 4);
	set_hudmessage(str_to_num(r), str_to_num(g), str_to_num(b), -1082130432, 1063675494, 2, 1065353216, 1075838976, 1008981770, 1045220557, -1);
	ShowSyncHudMsg(id, hud_message, msg);
	return 0;
}

kz_register_saycmd(saycommand[], function[], flags)
{
	new temp[64];
	formatex(temp, "", "say /%s", saycommand);
	register_clcmd(temp, function, flags, 325184, -1);
	formatex(temp, "", "say .%s", saycommand);
	register_clcmd(temp, function, flags, 325184, -1);
	formatex(temp, "", "say_team /%s", saycommand);
	register_clcmd(temp, function, flags, 325184, -1);
	formatex(temp, "", "say_team .%s", saycommand);
	register_clcmd(temp, function, flags, 325184, -1);
	return 0;
}

public FwdSpawnWeaponbox(iEntity)
{
	if (get_pcvar_num(kz_remove_drops) == 1)
	{
		set_pev(iEntity, 84, 1073741824);
		dllfunc(2, iEntity);
	}
	return 1;
}

public FwdHamDoorSpawn(iEntity)
{
	static szNull[16] =
	{
		99, 111, 109, 109, 111, 110, 47, 110, 117, 108, 108, 46, 119, 97, 118, 0
	};
	new Float:flDamage = 0.0;
	pev(iEntity, 50, flDamage);
	if (flDamage < -999.0)
	{
		set_pev(iEntity, 9, szNull);
		set_pev(iEntity, 10, szNull);
		set_pev(iEntity, 11, szNull);
		if (!HealsOnMap)
		{
			HealsOnMap = true;
		}
	}
	return 0;
}

public eventHamPlayerDamage(id, weapon, attacker, Float:damage, damagebits)
{
	if (get_pcvar_num(kz_damage) == 1)
	{
		new var1;
		if (!1 <= id <= get_maxplayers() || attacker || weapon)
		{
			damage = 0.0;
			return 4;
		}
		return 1;
	}
	new i = 1;
	while (i < max_players)
	{
		new var2;
		if (id != i && is_user_spectating_player(i, id))
		{
			ClearDHUDMessages(i, 8);
			new var3;
			if (!weapon && !HealsOnMap)
			{
				set_dhudmessage(255, 80, 80, -1.0, 0.83, 0, 0.0, 0.0, 0.0, 2.0, false);
				new var4;
				if (damage > 0.0)
				{
					var4 = 394788;
				}
				else
				{
					var4 = 394792;
				}
				show_dhudmessage(i, "%s%d HP", var4, floatround(damage * -1, "amxx_configsdir"));
			}
		}
		i++;
	}
	set_task(1056964608, "tsk_heal", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 1;
}

public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tr, damage_type)
{
	new var1;
	if (is_user_alive(attacker) && is_user_alive(victim) && get_pcvar_num(kz_damage) == 1)
	{
		return 4;
	}
	return 1;
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
				show_dhudmessage(pId, 394836);
				iDHUD++;
			}
		}
		i++;
	}
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

public tsk_heal(id)
{
	if (HealsOnMap)
	{
		set_pev(id, 41, 1240736632);
	}
	return 1;
}

public FwdHamPlayerSpawn(id)
{
	if (get_pcvar_num(kz_autosavepos))
	{
		Autosavepos[id] = 1;
	}
	else
	{
		Autosavepos[id] = 0;
	}
	if (!is_user_alive(id))
	{
		return 0;
	}
	new var1;
	if (firstspawn[id] && !is_user_bot(id))
	{
		new i;
		while (i < num)
		{
			new imin = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
			new isec = floatround(floatsub(Pro_Times[i], 1114636288 * imin), 1);
			new iminz = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
			new isecz = floatround(floatsub(Noob_Tiempos[i], 1114636288 * iminz), 1);
			new iminw = floatround(floatdiv(Wpn_Timepos[i], 1114636288), 1);
			new isecw = floatround(floatsub(Wpn_Timepos[i], 1114636288 * iminw), 1);
			new authid[32];
			get_user_authid(id, authid, 31);
			new var2;
			if (equal(Pro_AuthIDS[i], authid, "amxx_configsdir") || equal(Noob_AuthIDS[i], authid, "amxx_configsdir"))
			{
				if (Pro_Times[i] < Noob_Tiempos[i])
				{
					set_user_frags(id, imin);
					cs_set_user_deaths(id, isec);
				}
				if (Pro_Times[i] > Noob_Tiempos[i])
				{
					set_user_frags(id, iminz);
					cs_set_user_deaths(id, isecz);
				}
			}
			else
			{
				if (equal(Wpn_AuthIDS[i], authid, "amxx_configsdir"))
				{
					set_user_frags(id, iminw);
					cs_set_user_deaths(id, isecw);
				}
			}
			i++;
		}
		if (user_has_weapon(id, 29, -1))
		{
			engclient_cmd(id, "weapon_knife", 341596, 341600);
		}
		new var3;
		if (Verif(id, 1) && get_pcvar_num(kz_save_pos) == 1)
		{
			Savepos_menu(id);
		}
		else
		{
			if (get_pcvar_num(kz_spawn_mainmenu) == 1)
			{
				kz_menu(id);
			}
		}
		cs_set_user_money(id, 1336, 1);
		set_task(1065353216, "CmdSayWR", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		set_task(1092616192, "HelpInfo", id + 12222, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		if (DefaultStart)
		{
			set_pev(id, __dhud_fxtime, 394968);
			set_pev(id, 118, DefaultStartPos);
		}
		if (!(get_pcvar_num(kz_checkpoints)))
		{
			ColorChat(id, Color:2, "%s\x01 %L", id, "KZ_CHECKPOINT_OFF", prefix);
		}
		if (GodMap)
		{
			GodMode(id);
		}
		if (get_user_flags(id, "amxx_configsdir") & 1)
		{
			set_task(1045220557, "AdminTeam", id + 13333, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
	}
	firstspawn[id] = 0;
	new var4;
	if (containi(MapName, "slide") == -1 && containi(MapName, "surf_") == -1)
	{
		HealsOnMap = true;
		SlideMap = true;
	}
	if (HealsOnMap)
	{
		set_user_health(id, 1999994);
	}
	if (IsPaused[id])
	{
		set_pev(id, 118, PauseOrigin[id]);
	}
	if (!(get_pcvar_num(kz_use_radio)))
	{
		set_pdata_int(id, 192, "amxx_configsdir", 5);
	}
	return 0;
}

public AdminTeam(id)
{
	cs_set_user_team(id, 1, "amxx_configsdir");
	return 0;
}

public GroundWeapon_Touch(iWeapon, id)
{
	new var1;
	if (is_user_alive(id) && timer_started[id] && get_pcvar_num(kz_pick_weapons))
	{
		return 4;
	}
	return 1;
}

public GoPos(id)
{
	remove_hook(id);
	set_user_noclip(id, "amxx_configsdir");
	if (Verif(id, 0))
	{
		set_pev(id, __dhud_fxtime, SavedVelocity[id]);
		set_pev(id, 84, pev(id, 84) | 16384);
		set_pev(id, 118, SavedOrigins[id]);
		MpbhopOrigin[id][0] = str_to_float(SavedOrigins[id]);
		MpbhopOrigin[id][1] = str_to_float(SavedOrigins[id][1]);
		MpbhopOrigin[id][2] = str_to_float(SavedOrigins[id][2]);
		isMpbhop[id] = 1;
		GoPosCp[id] = 1;
		GoPosHp[id] = 1;
		CheckPoint(id);
	}
	new var1;
	if (HealsOnMap || SlideMap)
	{
		set_user_health(id, 1999983);
	}
	checknumbers[id] = SavedChecks[id];
	gochecknumbers[id] = SavedGoChecks[id];
	cs_set_user_money(id, get_pcvar_num(kz_startmoney), 1);
	if (0 < gochecknumbers[id])
	{
		GoPosed[id] = 1;
	}
	strip_user_weapons(id);
	if (!SavedWeapon[id])
	{
		cmdUsp(id);
	}
	if (SavedWeapon[id] == 1)
	{
		give_item(id, "weapon_scout");
	}
	if (SavedWeapon[id] == 2)
	{
		give_item(id, "weapon_p90");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 3)
	{
		give_item(id, "weapon_famas");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 4)
	{
		give_item(id, "weapon_sg552");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 5)
	{
		give_item(id, "weapon_m4a1");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 6)
	{
		give_item(id, "weapon_m249");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 7)
	{
		give_item(id, "weapon_ak47");
		wpn_15[id] = 1;
	}
	if (SavedWeapon[id] == 8)
	{
		give_item(id, "weapon_awp");
		wpn_15[id] = 1;
	}
	timer_time[id] = floatsub(get_gametime(), SavedTime[id]);
	timer_started[id] = 1;
	static Float:v_angle[33][3];
	static Float:velocityy[33][3];
	pev(id, __dhud_fxtime, velocityy[id]);
	pev(id, __dhud_fxtime, pausedvelocity[id]);
	pev(id, 118, PauseOrigin[id]);
	pev(id, 126, v_angle[id]);
	ColorChat(id, Color:2, "[KZ] \x03%L", id, "KZ_GOPOSINFO");
	return 0;
}

public Verif(id, action)
{
	new realfile[128];
	new tempfile[128];
	new authid[32];
	new bool:exist;
	new Stime[32];
	get_time("%Y/%m/%d - %H:%M:%S", Stime, 32);
	get_user_authid(id, authid, 31);
	formatex(realfile, 127, "%s/%s.ini", SavePosDir, MapName);
	formatex(tempfile, 127, "%s/temp.ini", SavePosDir);
	if (!file_exists(realfile))
	{
		return 0;
	}
	new file = fopen(tempfile, "wt");
	new vault = fopen(realfile, "rt");
	new data[256];
	new sid[32];
	new time[25];
	new checks[5];
	new gochecks[5];
	new x[25];
	new y[25];
	new z[25];
	new weapon[5];
	new xs[25];
	new ys[25];
	new zs[25];
	while (!feof(vault))
	{
		fgets(vault, data, "");
		parse(data, sid, 31, time, 24, checks, 4, gochecks, 4, x, 24, y, 24, z, 24, weapon, 4, xs, 24, ys, 24, zs, 24);
		new var1;
		if (equal(sid, authid, "amxx_configsdir") && !exist)
		{
			if (action == 1)
			{
				fputs(file, data);
			}
			exist = true;
			SavedChecks[id] = str_to_num(checks);
			SavedGoChecks[id] = str_to_num(gochecks);
			SavedTime[id] = str_to_float(time);
			SavedOrigins[id][0] = str_to_num(x);
			SavedOrigins[id][1] = str_to_num(y);
			SavedOrigins[id][2] = str_to_num(z);
			SavedWeapon[id] = str_to_num(weapon);
			SavedVelocity[id][0] = str_to_num(xs);
			SavedVelocity[id][1] = str_to_num(ys);
			SavedVelocity[id][2] = str_to_num(zs);
		}
		else
		{
			fputs(file, data);
		}
	}
	fclose(file);
	fclose(vault);
	delete_file(realfile);
	if (file_size(tempfile, "amxx_configsdir"))
	{
		do {
		} while (!rename_file(tempfile, realfile, 1));
	}
	else
	{
		delete_file(tempfile);
	}
	if (!exist)
	{
		return 0;
	}
	return 1;
}

public kz_savepos(id, Float:time, checkpoints, gochecks, Float:origin[3], weapon, Float:spvelocity[3])
{
	new realfile[128];
	new formatorigin[128];
	new authid[32];
	get_user_authid(id, authid, 31);
	new Stime[32];
	get_time("%Y/%m/%d - %H:%M:%S", Stime, 32);
	formatex(realfile, 127, "%s/%s.ini", SavePosDir, MapName);
	formatex(formatorigin, 127, "%s %f %d %d %d %d %d %d %d %d %d %s", authid, time, checkpoints, gochecks, origin, origin[1], origin[2], weapon, spvelocity, spvelocity[1], spvelocity[2], Stime);
	new vault = fopen(realfile, "rt+");
	write_file(realfile, formatorigin, -1);
	fclose(vault);
	if (Verif(id, 1))
	{
		new imin;
		new isec;
		new ims;
		imin = floatround(floatdiv(time, 1114636288), 1);
		isec = floatround(floatsub(time, 1114636288 * imin), 1);
		ims = floatround(floatmul(1120403456, floatsub(time, 1114636288 * imin + isec)), "amxx_configsdir");
		format(savepos_data, 400, "\dSaveDate: \y%s\n\dRunningTime: \y%02i:%02i.%02i\n\dCPs/TPs: \y%d/%d\n\dWeapon: \yCSW_USP", Stime, imin, isec, ims, checkpoints, gochecks);
	}
	return 0;
}

public saveposition(id)
{
	new Float:origin[3] = 0.0;
	new weapon;
	new Float:spvelocity[3] = 0.0;
	pev(id, __dhud_fxtime, spvelocity);
	new Float:Time = 0.0;
	new check;
	new gocheck;
	new var1;
	if (spec_user[id] && IsPaused[id])
	{
	}
	new var2;
	if (timer_started[id] && is_user_alive(id) && !is_user_bot(id) && tphook_user[id])
	{
		new var8 = PauseOrigin[id];
		origin = var8;
		Time = g_pausetime[id];
		new var9 = pausedvelocity[id];
		spvelocity = var9;
		if (isFalling[id])
		{
			new var10 = vFallingStart[id];
			origin = var10;
			Time = vFallingTime[id];
		}
		check = checknumbers[id];
		gocheck = gochecknumbers[id];
		if (user_has_weapon(id, "", -1))
		{
			weapon = 1;
		}
		else
		{
			if (user_has_weapon(id, 30, -1))
			{
				weapon = 2;
			}
			if (user_has_weapon(id, 15, -1))
			{
				weapon = 3;
			}
			if (user_has_weapon(id, 27, -1))
			{
				weapon = 4;
			}
			if (user_has_weapon(id, 22, -1))
			{
				weapon = 5;
			}
			if (user_has_weapon(id, 20, -1))
			{
				weapon = 6;
			}
			if (user_has_weapon(id, 28, -1))
			{
				weapon = 7;
			}
			if (user_has_weapon(id, 18, -1))
			{
				weapon = 8;
			}
			new var3;
			if (user_has_weapon(id, 16, -1) || user_has_weapon(id, 29, -1))
			{
				weapon = 0;
			}
		}
		kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity);
	}
	else
	{
		new var4;
		if (timer_started[id] && !is_user_alive(id) && !is_user_bot(id) && spec_user[id])
		{
			new var11 = SpecLoc[id];
			origin = var11;
			Time = g_pausetime[id];
			check = checknumbers[id];
			gocheck = gochecknumbers[id];
			if (user_has_weapon(id, "", -1))
			{
				weapon = 1;
			}
			else
			{
				if (user_has_weapon(id, 30, -1))
				{
					weapon = 2;
				}
				if (user_has_weapon(id, 15, -1))
				{
					weapon = 3;
				}
				if (user_has_weapon(id, 27, -1))
				{
					weapon = 4;
				}
				if (user_has_weapon(id, 22, -1))
				{
					weapon = 5;
				}
				if (user_has_weapon(id, 20, -1))
				{
					weapon = 6;
				}
				if (user_has_weapon(id, 28, -1))
				{
					weapon = 7;
				}
				if (user_has_weapon(id, 18, -1))
				{
					weapon = 8;
				}
				new var5;
				if (user_has_weapon(id, 16, -1) || user_has_weapon(id, 29, -1))
				{
					weapon = 0;
				}
			}
			kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity);
		}
		new var6;
		if (timer_started[id] && is_user_alive(id) && !is_user_bot(id))
		{
			pev(id, 118, origin);
			Time = floatsub(get_gametime(), timer_time[id]);
			if (isFalling[id])
			{
				new var12 = vFallingStart[id];
				origin = var12;
				Time = vFallingTime[id];
				spvelocity[0] = 0.0;
				spvelocity[1] = 0.0;
				spvelocity[2] = 0.0;
			}
			check = checknumbers[id];
			gocheck = gochecknumbers[id];
			if (user_has_weapon(id, "", -1))
			{
				weapon = 1;
			}
			else
			{
				if (user_has_weapon(id, 30, -1))
				{
					weapon = 2;
				}
				if (user_has_weapon(id, 15, -1))
				{
					weapon = 3;
				}
				if (user_has_weapon(id, 27, -1))
				{
					weapon = 4;
				}
				if (user_has_weapon(id, 22, -1))
				{
					weapon = 5;
				}
				if (user_has_weapon(id, 20, -1))
				{
					weapon = 6;
				}
				if (user_has_weapon(id, 28, -1))
				{
					weapon = 7;
				}
				if (user_has_weapon(id, 18, -1))
				{
					weapon = 8;
				}
				new var7;
				if (user_has_weapon(id, 16, -1) || user_has_weapon(id, 29, -1))
				{
					weapon = 0;
				}
			}
			kz_savepos(id, Time, check, gocheck, origin, weapon, spvelocity);
		}
		checknumbers[id] = 0;
		gochecknumbers[id] = 0;
		user_has_scout[id] = 0;
	}
	return 0;
}

public client_disconnect(id)
{
	if (Autosavepos[id] && !is_user_bot(id)) 
	{
		saveposition(id)
	}

	if(task_exists(id))
		remove_task(id)
	
	if(task_exists(id + TASK_ADMINTEAM))
		remove_task(id + TASK_ADMINTEAM )	
	if(task_exists(id + TASK_HELPINFO))
		remove_task(id + TASK_HELPINFO )	

	checknumbers[id] = 0;
	gochecknumbers[id] = 0;
	antihookcheat[id] = 0;
	antinoclipstart[id] = 0;
	antiteleport[id] = 0;
	antidiestart[id] = 0;
	chatorhud[id] = -1;
	timer_started[id] = 0;
	ShowTime[id] = get_pcvar_num(kz_show_timer);
	kz_type_wr[id] = get_pcvar_num(kz_type_wr_num);
	firstspawn[id] = 1;
	NightVisionUse[id] = 0;
	IsPaused[id] = 0;
	gCheckpointStart[id] = 0;
	spec_user[id] = 0;
	tpfenabled[id] = 0;
	tphook_user[id] = 0;
	GoPosed[id] = 0;
	GoPosCp[id] = 0;
	GoPosHp[id] = 0;
	gc1[id] = 0;
	user_has_scout[id] = 0;
	remove_hook(id);
	tptostart[id] = 0;
	isFalling[id] = 0;
	isMpbhop[id] = 0;
	block_change[id] = 0;
	if (get_user_flags(id) & KZ_LEVEL)
		g_bHideMe[id] = true;
	else
		g_bHideMe[id] = false;
	if (is_user_connected(id))
	{
		ArrayClear(g_DemoReplay[id]);
		ArrayClear(gc_DemoReplay[id]);
	}
	p_lang[id] = 1;
	return 0;
}

public client_putinserver(id)
{
	checknumbers[id] = 0;
	inpausechecknumbers[id] = 0;
	gochecknumbers[id] = 0;
	antihookcheat[id] = 0;
	antinoclipstart[id] = 0;
	antiteleport[id] = 0;
	antidiestart[id] = 0;
	chatorhud[id] = get_pcvar_num(kz_chatorhud);
	timer_started[id] = 0;
	ShowTime[id] = get_pcvar_num(kz_show_timer);
	kz_type_wr[id] = get_pcvar_num(kz_type_wr_num);
	firstspawn[id] = 1;
	NightVisionUse[id] = 0;
	IsPaused[id] = 0;
	user_has_scout[id] = 0;
	remove_hook(id);
	canusehook[id] = 1;
	GoPosed[id] = 0;
	GoPosCp[id] = 0;
	GoPosHp[id] = 0;
	gc1[id] = 0;
	tptostart[id] = 0;
	tphook_user[id] = 0;
	spec_user[id] = 0;
	tpfenabled[id] = 0;
	wpn_15[id] = 0;
	g_playergiveweapon[id] = 1;
	g_numerodearma[id] = 16;
	isMpbhop[id] = 0;
	// set_task(1074161254, "ServerInfo_Console", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	arrayset(g_iHookWallOrigin[id], 0, sizeof(g_iHookWallOrigin[]));

	block_change[id] = 0;
	set_task(0.5, "plspawn", id)
	set_task(0.1, "UpdateStats", id)
	g_bHideMe[id] = 0;
	new steam[33];
	get_user_authid(id, steam, 32);
	new var1;
	if (equali(steam, "STEAM_ID_LAN", "amxx_configsdir") || equali(steam, "STEAM_ID_PENDING", "amxx_configsdir") || equali(steam, "VALVE_ID_LAN", "amxx_configsdir") || equali(steam, "VALVE_ID_PENDING", "amxx_configsdir") || equali(steam, "STEAM_666:88:666", "amxx_configsdir") || strlen(steam) > 18)
	{
		set_task(1056964608, "client_bind", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	}
	REC_AC[id] = 0;
	p_lang[id] = 1;
	if (is_user_bot(id))
	{
		g_bitBots = 1 << id & 31 | g_bitBots;
	}
	else
	{
		g_bitBots = ~1 << id & 31 & g_bitBots;
	}
	return 0;
}

public HelpInfo(id)
{
	if (get_user_flags(id, "amxx_configsdir") & 8)
	{
		ColorChat(id, Color:5, 398036);
		ColorChat(id, Color:5, "\x04%s \x03Hello! \x01尊敬的管理员 输入\x03/op\x01打开管理菜单 请勿滥用职权哦!", prefix);
	}
	else
	{
		ColorChat(id, Color:5, 398384);
		ColorChat(id, Color:5, "\x04%s \x01欢迎小主回家, 查看在线管理 \x03/admin \x01下载\x03 4870+\x01地图包请加玩家群\x03 719383105.", prefix);
	}
	return 0;
}

public plspawn(id)
{
	if (!is_user_alive(id))
	{
		cs_user_spawn(id);
	}
	return 0;
}

public event_deathmsg()
{
	set_task(get_pcvar_float(cvar_respawndelay), "respawn_player", read_data(2), 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public respawn_player(id)
{
	new var1;
	if (!is_user_connected(id) || is_user_alive(id) || cs_get_user_team(id, 0) == 3)
	{
		return 0;
	}
	set_pev(id, 80, 3);
	dllfunc(2, id);
	new var2;
	if (is_user_bot(id) && pev(id, 80) == 3)
	{
		dllfunc(1, id);
	}
	return 0;
}

public UpdateStats(id)
{
	new authid[32];
	new name[32];
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	client_cmd(id, "hud_centerid 0");
	new i;
	while (i < num)
	{
		if( (!equali(Pro_Names[i], name) && (equali(Pro_AuthIDS[i], authid))))
		{
			
			formatex(Pro_Names[i], 31, name);
			save_pro15()
		}		
		
		if( (!equali(Noob_Names[i], name) && (equali(Noob_AuthIDS[i], authid))))
		{
			formatex(Noob_Names[i], 31, name);
			save_Noob15()
		}		
		
		if( (!equali(Wpn_Names[i], name) && (equali(Wpn_AuthIDS[i], authid))))
		{
			formatex(Wpn_Names[i], 31, name);
			save_Wpn15()
		}
		i++;
	}
	return 0;
}

public client_infochanged(id)
{
	new newname[32];
	new oldname[32];
	new authid[32];
	get_user_info(id, "name", newname, 31);
	get_user_name(id, oldname, 31);
	get_user_authid(id, authid, 31);
	new i;
	while (i < num)
	{
		new var6;
		if (!equal(oldname, newname, "amxx_configsdir") && (!equali(Pro_Names[i], newname, "amxx_configsdir") && (equali(Pro_AuthIDS[i], authid, "amxx_configsdir") || ((!equali(Noob_Names[i], newname, "amxx_configsdir") && equali(Noob_AuthIDS[i], authid, "amxx_configsdir")) || (!equali(Wpn_Names[i], newname, "amxx_configsdir") && equali(Wpn_AuthIDS[i], authid, "amxx_configsdir"))))))
		{
			formatex(Pro_Names[i], 31, newname);
			save_pro15();
			formatex(Noob_Names[i], 31, newname);
			save_Noob15();
			formatex(Wpn_Names[i], 31, newname);
			save_Wpn15();
		}
		i++;
	}
	return 0;
}


// #MARK:MAIN_MENU
public kz_menu(id)
{
	if (!is_user_connected(id))
	{
		return 1;
	}
	new title[256];
	new thetime[64];
	get_time("%Y/%m/%d - %H:%M:%S", thetime, "");
	new tl = get_timeleft();
	new msgcheck[64];
	new msggocheck[64];
	new msgpause[64];
	formatex(title, 285, "\d[xiaokz] \r#KZ Server \dVisit \ywww.csxiaokz.com \n\rQQ群:719383105\n\dBeiJing time \y%s\n\dMap \y%s\d & Timeleft \y%d:%02d\n\dType map \y%s", thetime, MapName, tl / 60, tl % 60, MapType);
	new menu = menu_create(title, "MenuHandler", "amxx_configsdir");
	new msgctspec[64];
	new msglang[64];
	formatex(msgcheck, "", "%L - [\r#%i\w]", id, "KZ_CHECK_IS", checknumbers[id]);
	formatex(msggocheck, "", "%L - [\r#%i\w]", id, "KZ_GOCHECK_IS", gochecknumbers[id]);
	new var1;
	if (IsPaused[id])
	{
		var1 = 399940;
	}
	else
	{
		var1 = 399960;
	}
	formatex(msgpause, "", "%L - [%s\w]", id, "KZ_PAUSE", var1);
	new var2;
	if (cs_get_user_team(id, 0) == 2 || cs_get_user_team(id, 0) == 1)
	{
		var3 = 399996;
	}
	else
	{
		var3 = 400048;
	}
	formatex(msgctspec, "", "%L", id, var3);
	new var4;
	if (p_lang[id])
	{
		var4 = 400084;
	}
	else
	{
		var4 = 400172;
	}
	formatex(msglang, "", "%L", id, var4);

	menu_vadditem(menu, 400260, 0, -1, "%L", id, "KZ_MAINMENG_MENU1");
	menu_additem(menu, msgpause, 400352, "amxx_configsdir", -1);
	menu_additem(menu, msgcheck, 400360, "amxx_configsdir", -1);
	menu_additem(menu, msggocheck, 400368, "amxx_configsdir", -1);
	menu_additem(menu, msglang, 400376, "amxx_configsdir", -1);
	menu_vadditem(menu, 400384, 0, -1, "%L", id, "KZ_CFGF_MENU5");
	menu_vadditem(menu, 400460, 0, -1, "%L", id, "KZ_MAINMENG_MENU4");
	menu_vadditem(menu, 400552, 0, -1, "%L", id, "KZ_MAINMENG_MENU5");
	menu_additem(menu, msgctspec, 400644, "amxx_configsdir", -1);
	menu_vadditem(menu, "10", 0, -1, "%L", id, "KZ_MAINMENG_MENU7");
	menu_vadditem(menu, "11", 0, -1, "%L", id, "KZ_MAINMENG_MENU8");
	menu_vadditem(menu, "12", 0, -1, "%L", id, "KZ_MAINMENG_MENU9");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public MenuHandler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			goStartPos(id);
		}
		case 1:
		{
			Pause(id);
			kz_menu(id);
		}
		case 2:
		{
			CheckPoint(id);
			kz_menu(id);
		}
		case 3:
		{
			GoCheck(id);
			kz_menu(id);
		}
		case 4:
		{
			langmenu(id);
		}
		case 5:
		{
			weapons(id);
		}
		case 6:
		{
			ConfigFunctionMenu(id);
		}
		case 7:
		{
			Teleport(id);
		}
		case 8:
		{
			ct(id);
		}
		case 9:
		{
			if (callfunc_begin("cmdMeasure", "measure.amxx") == 1)
			{
				callfunc_push_int(id);
				callfunc_end();
			}
		}
		case 10:
		{
			ClCmd_ReplayMenu(id);
		}
		case 11:
		{
			ClCmd_ReplayMenu_c(id);
		}
		default:
		{
		}
	}
	return 1;
}

public DuelMenu(id)
{
	new menu = menu_create("\r错误: 数据库连接失败,请联系服务器管理员!\n\n\rSQL Connection failed, You now can't duel sorry!", "DuelMenuHandler", "amxx_configsdir");
	menu_vadditem(menu, 401552, 0, -1, "\y%L\n", id, "KZ_DUELMENG_MENU1");
	menu_vadditem(menu, 401656, 0, -1, "\w%L", id, "KZ_DUELMENG_MENU2");
	menu_vadditem(menu, 401756, 0, -1, "\w%L\n", id, "KZ_DUELMENG_MENU3");
	menu_vadditem(menu, 401860, 0, -1, "\y%L", id, "KZ_DUELMENG_MENU4");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public DuelMenuHandler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			DuelMenu(id);
		}
		case 1:
		{
			DuelMenu(id);
		}
		case 2:
		{
			DuelMenu(id);
		}
		case 3:
		{
			kz_menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public ConfigFunctionMenu(id)
{
	new menu = menu_create("\yConfigFunction Menu\n\n", "ConfigFunctionMenuHandler", "amxx_configsdir");
	menu_vadditem(menu, 402160, 0, -1, "%L", id, "KZ_CFGF_MENU1");
	menu_vadditem(menu, 402236, 0, -1, "%L", id, "KZ_CFGF_MENU2");
	menu_vadditem(menu, 402312, 0, -1, "%L\n", id, "KZ_CFGF_MENU3");
	menu_vadditem(menu, 402392, 0, -1, "%L", id, "KZ_CFGF_MENU4");
	menu_vadditem(menu, 402468, 0, -1, "%L", id, "KZ_CFGF_MENU5");
	menu_vadditem(menu, 402544, 0, -1, "%L", id, "KZ_CFGF_MENU6");
	menu_vadditem(menu, 402620, 0, -1, "%L", id, "KZ_CFGF_MENU7");
	if (get_user_flags(id, "amxx_configsdir") & 8)
	{
		menu_vadditem(menu, 402696, 0, -1, "%L", id, "KZ_CFGF_MENU8");
	}
	else
	{
		menu_vadditem(menu, 402772, 0, -1, "\d%L", id, "KZ_CFGF_MENU8");
	}
	menu_vadditem(menu, 402856, 0, -1, "%L", id, "KZ_CFGF_MENU9");
	menu_vadditem(menu, "10", 0, -1, "%L", id, "KZ_CFGF_MENU10");
	menu_vadditem(menu, "11", 0, -1, "%L", id, "KZ_CFGF_MENU11");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public ConfigFunctionMenuHandler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			reset_checkpoints1(id);
			ConfigFunctionMenu(id);
		}
		case 1:
		{
			InvisMenu(id);
		}
		case 2:
		{
			cmdScout(id);
			ConfigFunctionMenu(id);
		}
		case 3:
		{
			client_cmd(id, "say rtv");
			ConfigFunctionMenu(id);
		}
		case 4:
		{
			weapons(id);
		}
		case 5:
		{
			client_cmd(id, "say /mute");
		}
		case 6:
		{
			langmenu(id);
		}
		case 7:
		{
			if (!get_user_flags(id, "amxx_configsdir") & 8)
			{
				return 1;
			}
			KZ_RulesMenu(id);
		}
		case 8:
		{
			cmd_help(id);
			ConfigFunctionMenu(id);
		}
		case 9:
		{
			ShowTimer_Menu(id);
		}
		case 10:
		{
			WRDIFF_Type_Menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public langmenu(id)
{
	new menu = menu_create("\r双语言切换(Language switching)", "lang_menu_handler", "amxx_configsdir");
	menu_vadditem(menu, 403396, 0, -1, "%L", id, "KZ_LANG_MENU1");
	menu_vadditem(menu, 403472, 0, -1, "%L", id, "KZ_LANG_MENU2");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public lang_menu_handler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			client_cmd(id, "setinfo lang cn");
			set_task(1050253722, "kz_menu", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
		case 1:
		{
			client_cmd(id, "setinfo lang en");
			set_task(1050253722, "kz_menu", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
		default:
		{
		}
	}
	menu_destroy(menu);
	return 1;
}

public Savepos_menu(id)
{
	new title[128];
	formatex(title, 127, "%s", savepos_data);
	new menu = menu_create(title, "Savepos_menu_handler", "amxx_configsdir");
	menu_vadditem(menu, 403836, 0, -1, "%L\n", id, "KZ_SAVEPOS_MENU1");
	menu_vadditem(menu, 403928, 0, -1, "%L\n", id, "KZ_SAVEPOS_MENU2");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public Savepos_menu_handler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			if (is_user_alive(id))
			{
				GoPos(id);
			}
			else
			{
				kz_chat(id, "您必须或者才能使用此功能");
				Savepos_menu(id);
			}
		}
		case 1:
		{
			goStartPos(id);
			Verif(id, 0);
		}
		default:
		{
		}
	}
	menu_destroy(menu);
	return 1;
}

public JumpMenu(id)
{
	new title[256];
	formatex(title, "", "\rClimb Menu");
	new menu = menu_create(title, "JumpMenuHandler", "amxx_configsdir");
	new msgcheck[64];
	new msggocheck[64];
	new msgpause[64];
	formatex(msgcheck, "", "%L - [\r#%i\w]", id, "KZ_CHECK_IS", checknumbers[id]);
	formatex(msggocheck, "", "%L - [\r#%i\w]", id, "KZ_GOCHECK_IS", gochecknumbers[id]);
	new var1;
	if (IsPaused[id])
	{
		var1 = 404596;
	}
	else
	{
		var1 = 404616;
	}
	formatex(msgpause, "", "%L - [%s\w]\n", id, "KZ_PAUSE", var1);
	menu_additem(menu, msgcheck, 404640, "amxx_configsdir", -1);
	menu_additem(menu, msggocheck, 404648, "amxx_configsdir", -1);
	menu_vadditem(menu, 404656, 0, -1, "%L\n", id, "KZ_JUMPMENU_MENU5");
	menu_additem(menu, msgpause, 404752, "amxx_configsdir", -1);
	menu_vadditem(menu, 404760, 0, -1, "%L", id, "KZ_JUMPMENU_MENU1");
	menu_vadditem(menu, 404852, 0, -1, "%L\n", id, "KZ_JUMPMENU_MENU7");
	menu_additem(menu, "Usp/Knife", 404988, "amxx_configsdir", -1);
	menu_vadditem(menu, 404996, 0, -1, "%L", id, "KZ_JUMPMENU_MENU8");
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public JumpMenuHandler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			CheckPoint(id);
			JumpMenu(id);
		}
		case 1:
		{
			GoCheck(id);
			JumpMenu(id);
		}
		case 2:
		{
			Stuck(id);
			JumpMenu(id);
		}
		case 3:
		{
			Pause(id);
			JumpMenu(id);
		}
		case 4:
		{
			goStartPos(id);
			JumpMenu(id);
		}
		case 5:
		{
			CheckPointStart(id);
			JumpMenu(id);
		}
		case 6:
		{
			cmdUsp(id);
		}
		case 7:
		{
			reset_checkpoints1(id);
			JumpMenu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public KZ_RulesMenu(id)
{
	new menu = menu_create("\dKZ Server Rules Menu \n\rby Perfectslife", "RulesHandler", "amxx_configsdir");
	new hidespec[64];
	new var1;
	if (g_bHideMe[id])
	{
		var1 = 405496;
	}
	else
	{
		var1 = 405516;
	}
	formatex(hidespec, "", "隐藏观察者列表中的自己 - \w[\r%s\w]", var1);
	menu_additem(menu, "踢出玩家", 405592, "amxx_configsdir", -1);
	menu_additem(menu, "封禁玩家\n", 405656, "amxx_configsdir", -1);
	menu_additem(menu, "\y发起投票换图", 405748, "amxx_configsdir", -1);
	menu_additem(menu, "\y直接更换地图\n", 405844, "amxx_configsdir", -1);
	menu_additem(menu, hidespec, 405852, "amxx_configsdir", -1);
	menu_additem(menu, "Bhop Block设定 \d(鼠标准星标记设定柱子)\n", 406072, "amxx_configsdir", -1);
	menu_additem(menu, "Server \d[\yRECORDS\d] \wBOT Menu \r*New*\n", 406252, "amxx_configsdir", -1);
	menu_additem(menu, "\r读取权限", 406320, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public RulesHandler(id, menu, item)
{
	switch (item)
	{
		case 0:
		{
			console_cmd(id, "amx_kickmenu");
		}
		case 1:
		{
			console_cmd(id, "amx_banmenu");
		}
		case 2:
		{
			console_cmd(id, "startvote");
		}
		case 3:
		{
			client_cmd(id, "messagemode amx_map");
			ColorChat(id, Color:5, "\x04%s \x01请输入\x03地图名...", prefix);
			ColorChat(id, Color:5, "\x04%s \x01请输入\x03地图名...", prefix);
			ColorChat(id, Color:5, "\x04%s \x01请输入\x03地图名...", prefix);
		}
		case 4:
		{
			if (callfunc_begin("cmdHideme", "speclist&clientinfo_src.amxx") == 1)
			{
				callfunc_push_int(id);
				callfunc_end();
			}
			hideme(id);
			KZ_RulesMenu(id);
		}
		case 5:
		{
			if (callfunc_begin("ClCmd_BhopMenu", "mpbhop.amxx") == 1)
			{
				callfunc_push_int(id);
				callfunc_end();
			}
		}
		case 6:
		{
			ClCmd_ReplayMenu(id);
		}
		case 7:
		{
			console_cmd(id, "amx_reloadadmins");
		}
		default:
		{
		}
	}
	return 1;
}

public hideme(id)
{
	if (!get_user_flags(id, "amxx_configsdir") & 8)
	{
		return 1;
	}
	g_bHideMe[id] = !g_bHideMe[id];
	return 1;
}

public client_lang(id)
{
	p_lang[id] = !p_lang[id];
	if (p_lang[id])
	{
		p_lang[id] = 1;
		client_cmd(id, "setinfo lang cn");
		set_task(1050253722, "kz_menu", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	}
	else
	{
		p_lang[id] = 0;
		client_cmd(id, "setinfo lang en");
		set_task(1050253722, "kz_menu", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
	}
	return 0;
}

public client_kill(id)
{
	client_print(id, 2, "%L", id, "KZ_CLIENTKILL_INFO");
	return 1;
}

public cmdServerMenu(id)
{
	new IP[42];
	new Port[6];
	get_user_ip("amxx_configsdir", IP, 41, "amxx_configsdir");
	new pos = containi(IP, 407496);
	formatex(Port, 5, IP[pos + 1]);
	new szMenu[1024];
	if (equali(Port, "27015", "amxx_configsdir"))
	{
		formatex(szMenu, 1023, "\rServer \yMenu\n\n\r1. \d5# KreedZ Rank Server \y[NTjump Rank]\n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]\n\r3. \d10# KreedZ Xtreme Server  \y[Steam User]\n\r4. \w9# KreedZ Test Server \y[All Maps]\n\n\n\n\n\r9. \wBack\n\r0. \wExit");
		show_menu(id, 782, szMenu, -1, "ServerMenu");
	}
	else
	{
		if (equali(Port, "27016", "amxx_configsdir"))
		{
			formatex(szMenu, 1023, "\rServer \yMenu\n\n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]\n\r2. \d3# KreedZ Bhop Server \y[Bhop Easy]\n\r3. \d10# KreedZ Xtreme Server \y[Steam User]\n\r4. \w9# KreedZ Test Server \y[All Maps]\n\n\n\n\n\r9. \wBack\n\r0. \wExit");
			show_menu(id, 781, szMenu, -1, "ServerMenu");
		}
		if (equali(Port, "27019", "amxx_configsdir"))
		{
			formatex(szMenu, 1023, "\rServer \yMenu\n\n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]\n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]\n\r3. \d10# KreedZ Xtreme Server \y[Steam User]\n\r4. \w9# KreedZ Test Server \y[All Maps]\n\n\n\n\n\r9. \wBack\n\r0. \wExit");
			show_menu(id, 779, szMenu, -1, "ServerMenu");
		}
		if (equali(Port, "27021", "amxx_configsdir"))
		{
			formatex(szMenu, 1023, "\rServer \yMenu\n\n\r1. \w5# KreedZ Rank Server \y[NTjump Rank]\n\r2. \w3# KreedZ Bhop Server \y[Bhop Easy]\n\r3. \d10# KreedZ Xtreme Server \y[Steam User]\n\r4. \d9# KreedZ Test Server \y[All Maps]\n\n\n\n\n\r9. \wBack\n\r0. \wExit");
			show_menu(id, 775, szMenu, -1, "ServerMenu");
		}
	}
	return 1;
}

public handleServerMenu(id, item)
{
	new name[32];
	get_user_name(id, name, 31);
	switch (item)
	{
		case 0:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;\"connect\" 61.153.110.99:27015");
			ColorChat(0, Color:5, "\x04%s \x03%s \x01has been redirected to\x03 5# KreedZ Rank Server\x01. Say /server to switch between servers ...", prefix, name);
		}
		case 1:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;\"connect\" 61.153.110.99:27016");
			ColorChat(0, Color:5, "\x04%s \x03%s \x01has been redirected to\x03 3# KreedZ Bhop Server\x01. Say /server \x01to switch between servers ...", prefix, name);
		}
		case 2:
		{
			cmdServerMenu(id);
		}
		case 3:
		{
			client_cmd(id, "wait;wait;wait;wait;wait;\"connect\" 61.153.110.99:27021");
			ColorChat(0, Color:5, "\x04%s \x03%s \x01has been redirected to\x03 9# KreedZ Test Server\x01. Say /server \x01to switch between servers ...", prefix, name);
		}
		case 8:
		{
			kz_menu(id);
			return 1;
		}
		case 9:
		{
			return 1;
		}
		default:
		{
		}
	}
	cmdServerMenu(id);
	return 1;
}

public Msg_StatusIcon(msgid, msgdest, id)
{
	static szMsg[8];
	get_msg_arg_string(2, szMsg, 7);
	new var1;
	if (equal(szMsg, "buyzone", "amxx_configsdir") && get_msg_arg_int(1))
	{
		set_pdata_int(id, "", get_pdata_int(id, "", 5) & -2, 5);
		return 1;
	}
	return 0;
}

public OR_PMMove(OrpheuStruct:pmove, server)
{
	if (g_bAxnBhop)
	{
		g_ppmove = pmove;
	}
	return 0;
}

public OR_PMJump()
{
	if (g_bAxnBhop)
	{
		g_flOldMaxSpeed = OrpheuGetStructMember(g_ppmove, "maxspeed");
		OrpheuSetStructMember(g_ppmove, "maxspeed", 0);
	}
	return 0;
}

public OR_PMJump_P()
{
	if (g_bAxnBhop)
	{
		OrpheuSetStructMember(g_ppmove, "fuser2", 0);
		OrpheuSetStructMember(g_ppmove, "maxspeed", g_flOldMaxSpeed);
	}
	return 0;
}

public ServerInfo_Console(id)
{
	new name[32];
	new authid[32];
	new ip[32];
	new hostname[64];
	new thetime[32];
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_user_ip(id, ip, 31, "amxx_configsdir");
	get_cvar_string("hostname", hostname, "");
	get_time("%Y/%m/%d - %H:%M:%S", thetime, 31);
	client_cmd(id, "echo \" \"");
	client_cmd(id, "echo \" \"");
	client_cmd(id, "echo \" \"");
	client_cmd(id, "echo \"=========================================\"");
	client_cmd(id, "echo \"Welcome: %s \"", hostname);
	client_cmd(id, "echo \"Beijing Time: %s\"", thetime);
	client_cmd(id, "echo \"MapName: %s Type: %s\"", MapName, MapType);
	client_cmd(id, "echo \"-----------------------------------------\"");
	client_cmd(id, "echo \"Your Message: \"");
	client_cmd(id, "echo \"-----------------------------------------\"");
	client_cmd(id, "echo \"Name: %s\"", name);
	client_cmd(id, "echo \"SteamID: %s\"", authid);
	client_cmd(id, "echo \"IP: %s\"", ip);
	client_cmd(id, "echo \"-----------------------------------------\"");
	client_cmd(id, "echo \"Plugin by Perfectslife\"");
	client_cmd(id, "echo \"-----------------------------------------\"");
	client_cmd(id, "echo \"WeChat: xtreme233 \"");
	client_cmd(id, "echo \"E-Mail: 375904504@qq.com \"");
	client_cmd(id, "echo \"=========================================\"");
	return 0;
}

public client_bind(id)
{
	new ids[2];
	ids[0] = id;
	set_task(1036831949, "bind_keys", id, 415756, "amxx_configsdir", 340912, "amxx_configsdir");
	return 0;
}

public bind_keys(id)
{
	if (is_user_connected(id))
	{
		client_cmd(id, "bind \"F1\" \"say /menu\"");
		client_cmd(id, "bind \"F2\" \"say /start\"");
		client_cmd(id, "bind \"F4\" \"say /cp\"");
		client_cmd(id, "bind \"F5\" \"say /gc\"");
		client_cmd(id, "bind \"F7\" \"say /spec\"");
		client_cmd(id, "bind \"F8\" \"say /stuck\"");
		client_cmd(id, "bind \"=\" \"+hook\"");
	}
	return 1;
}

public InvisMenu(id)
{
	new menu = menu_create("\yInvis Menu\w", "InvisMenuHandler", "amxx_configsdir");
	new msginvis[64];
	new msgwaterinvis[64];
	new var1;
	if (gViewInvisible[id])
	{
		var1 = 416576;
	}
	else
	{
		var1 = 416596;
	}
	formatex(msginvis, "", "%L - [%s\w]", id, "INVIS_PLAYER", var1);
	new var2;
	if (gWaterInvisible[id])
	{
		var2 = 416724;
	}
	else
	{
		var2 = 416744;
	}
	formatex(msgwaterinvis, "", "%L - [%s\w]\n\n", id, "INVIS_WATER", var2);
	menu_additem(menu, msginvis, 416768, "amxx_configsdir", -1);
	menu_additem(menu, msgwaterinvis, 416776, "amxx_configsdir", -1);
	menu_additem(menu, "Main Menu", 416824, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public InvisMenuHandler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			cmdInvisible(id);
			InvisMenu(id);
		}
		case 1:
		{
			cmdWaterInvisible(id);
			InvisMenu(id);
		}
		case 2:
		{
			kz_menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public ShowTimer_Menu(id)
{
	new menu = menu_create("\yTimer Menu\w", "TimerHandler", "amxx_configsdir");
	new TXTtimer[64];
	new hudtimer[64];
	new var1;
	if (ShowTime[id] == 1)
	{
		var1 = 417020;
	}
	else
	{
		var1 = 417040;
	}
	formatex(TXTtimer, "", "TXT Timer - [%s\w]", var1);
	new var2;
	if (ShowTime[id] == 2)
	{
		var2 = 417144;
	}
	else
	{
		var2 = 417164;
	}
	formatex(hudtimer, "", "HUD Timer - [%s\w]\n", var2);
	menu_additem(menu, TXTtimer, 417188, "amxx_configsdir", -1);
	menu_additem(menu, hudtimer, 417196, "amxx_configsdir", -1);
	menu_additem(menu, "Main Menu", 417244, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public TimerHandler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			ShowTime[id] = 1;
			ShowTimer_Menu(id);
		}
		case 1:
		{
			ShowTime[id] = 2;
			ShowTimer_Menu(id);
		}
		case 2:
		{
			kz_menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public WRDIFF_Type_Menu(id)
{
	new menu = menu_create("\yKZ Record Difference Menu\n\n\rWR? NTR? ...\w", "WRDIFF_Type_Handler", "amxx_configsdir");
	new WREtimer[64];
	new NTRtimer[64];
	new var1;
	if (kz_type_wr[id] == 1)
	{
		var1 = 417636;
	}
	else
	{
		var1 = 417656;
	}
	formatex(WREtimer, "", "Official \dXJ+CC   \w- [%s\w]", var1);
	new var2;
	if (kz_type_wr[id] == 2)
	{
		var2 = 417788;
	}
	else
	{
		var2 = 417808;
	}
	formatex(NTRtimer, "", "China \dNTjump \w- [%s\w]\n", var2);
	menu_additem(menu, WREtimer, 417832, "amxx_configsdir", -1);
	menu_additem(menu, NTRtimer, 417840, "amxx_configsdir", -1);
	menu_additem(menu, "Main Menu", 417888, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public WRDIFF_Type_Handler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			kz_type_wr[id] = 1;
			WRDIFF_Type_Menu(id);
		}
		case 1:
		{
			kz_type_wr[id] = 2;
			WRDIFF_Type_Menu(id);
		}
		case 2:
		{
			kz_menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public top15menu(id)
{
	new top15msg[1024];
	formatex(top15msg, 1023, "\dKreedz Server Top100\n\dMap \r%s\n\n%s\n%s", MapName, WRTimes, NTTimes);
	new menu = menu_create(top15msg, "top15handler", "amxx_configsdir");
	menu_additem(menu, "\wPro Stats", 418160, "amxx_configsdir", -1);
	menu_additem(menu, "\wNub Stats", 418216, "amxx_configsdir", -1);
	menu_additem(menu, "\wWpn Stats [\rWPNSPEED\w]\n\n", 418340, "amxx_configsdir", -1);
	menu_additem(menu, "\wMain Menu", 418396, "amxx_configsdir", -1);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public top15handler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	switch (item)
	{
		case 0:
		{
			ProTop_show(id);
			top15menu(id);
		}
		case 1:
		{
			NoobTop_show(id);
			top15menu(id);
		}
		case 2:
		{
			WpnTop_show(id);
			top15menu(id);
		}
		case 3:
		{
			kz_menu(id);
		}
		default:
		{
		}
	}
	return 1;
}

public fwdUse(ent, id)
{
	new name[32];
	get_user_name(id, name, 31);
	new var1;
	if (!ent || id > 32)
	{
		return 1;
	}
	new var2;
	if (is_user_bot(id) && !equali(name, "[PRO]", 5) && !equali(name, "[NUB]", 5))
	{
		return 1;
	}
	if (!is_user_alive(id))
	{
		return 1;
	}
	new szTarget[32];
	pev(ent, 4, szTarget, 31);
	if (TrieKeyExists(g_tStarts, szTarget))
	{
		new var3;
		if ((!get_user_noclip(id) && floatsub(get_gametime(), antinoclipstart[id]) < 1077936128) || get_user_noclip(id))
		{
			kz_chat(id, "%L", id, "KZ_TNC_LATER");
			return 1;
		}
		if (floatsub(get_gametime(), antihookcheat[id]) < 1077936128)
		{
			kz_hud_message(id, "%L", id, "KZ_HOOK_PROTECTION");
			return 1;
		}
		if (Verif(id, 1))
		{
			kz_chat(id, "%L", id, "KZ_START_SAVEPOSINFO");
			Savepos_menu(id);
			return 1;
		}
		new var5;
		if (reset_checkpoints(id) && !timer_started[id])
		{
			ArrayClear(g_DemoReplay[id]);
			ArrayClear(gc_DemoReplay[id]);
			start_climb(id);
			if (100 > get_user_health(id))
			{
				set_user_health(id, 100);
			}
			pev(id, 118, SavedStart[id]);
			if (get_pcvar_num(kz_save_autostart) == 1)
			{
				AutoStart[id] = 1;
			}
			if (!DefaultStart)
			{
				kz_set_start(MapName, SavedStart[id]);
				ColorChat(id, Color:2, "\x01%s\x03 %L", prefix, id, "KZ_SET_START");
			}
			remove_hook(id);
		}
	}
	if (TrieKeyExists(g_tStops, szTarget))
	{
		new var6;
		if (tphook_user[id] || IsPaused[id])
		{
			kz_hud_message(id, "%L", id, "KZ_TIME_ISPAUSE");
			return 1;
		}
		new var7;
		if (timer_started[id] && !is_user_bot(id) && !equali(name, "[PRO]", 5) && !equali(name, "[NUB]", 5))
		{
			if (get_user_noclip(id))
			{
				return 1;
			}
			pev(id, 118, SavedStop[id]);
			if (!DefaultStop)
			{
				kz_set_stop(MapName, SavedStop[id]);
			}
			finish_climb(id);
		}
		kz_hud_message(id, "%L", id, "KZ_TIMER_NOT_STARTED");
	}
	return 1;
}

public start_climb(id)
{
	cs_set_user_money(id, get_pcvar_num(kz_startmoney), 1);
	if (get_pcvar_num(kz_reload_weapons) == 1)
	{
		checkweapons(id);
		if (!task_exists(id + 1000, "amxx_configsdir"))
		{
			set_task(1056964608, "dararmitaon", id + 1000, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
		if (user_has_weapon(id, 17, -1))
		{
			strip_user_weapons(id);
			cmdUsp(id);
		}
	}
	if (!GodMap)
	{
		set_user_godmode(id, 0)

	}
	set_pev(id, pev_gravity, 1.0);
	set_pev(id, pev_movetype, MOVETYPE_WALK)
	reset_checkpoints1(id)
	IsPaused[id] = 0;
	timer_started[id] = 1;
	timer_time[id] = get_gametime();
	tphook_user[id] = 0;
	WasPlayed[id] = 0;
	GoPosCp[id] = 0;
	GoPosed[id] = 0;
	GoPosHp[id] = 0;
	tptostart[id] = 0;
	REC_AC[id] = 1;
	return 0;
}

public start_climb_bot(id)
{
	set_pev(g_bot_id, 34, 1065353216);
	set_pev(g_bot_id, 69, 3);
	reset_checkpoints(g_bot_id);
	IsPaused[g_bot_id] = 0;
	timer_started[g_bot_id] = 1;
	timer_time[g_bot_id] = get_gametime();
	return 0;
}

public start_climb_bot_c(id)
{
	set_pev(gc_bot_id, 34, 1065353216);
	set_pev(gc_bot_id, 69, 3);
	reset_checkpoints(gc_bot_id);
	IsPaused[gc_bot_id] = 0;
	timer_started[gc_bot_id] = 1;
	timer_time[gc_bot_id] = get_gametime();
	return 0;
}

public dararmitaon(id)
{
	remove_task(id + 1000, "amxx_configsdir");
	g_playergiveweapon[id] = 1;
	return 0;
}

public checkweapons(id)
{
	if (is_user_bot(id))
	{
		return 0;
	}
	if (!g_playergiveweapon[id])
	{
		return 0;
	}
	g_playergiveweapon[id] = 0;
	new armita = get_user_weapon(id, 0, 0);
	g_numerodearma[id] = armita;
	strip_user_weapons(id);
	switch (armita)
	{
		case 15, 18, 20, 22, 27, 28, 30:
		{
			give_scout(id, armita);
			wpn_15[id] = 1;
		}
		case 16, 29:
		{
			give_uspknife(id, g_numerodearma[id]);
			cs_set_user_bpammo(id, 16, __dhud_fadeouttime);
			wpn_15[id] = 0;
		}
		default:
		{
			give_scout(id, armita);
			wpn_15[id] = 0;
		}
	}
	return 0;
}

public finish_climb(id)
{
	if (!is_user_alive(id))
	{
		return 0;
	}
	new var1;
	if (get_pcvar_num(kz_top15_authid) > 1 || get_pcvar_num(kz_top15_authid) < 0)
	{
		ColorChat(id, Color:2, "\x01%s\x03 %L.", prefix, id, "KZ_TOP15_DISABLED");
		return 0;
	}
	new Float:time = 0.0;
	new authid[32];
	new maxspeeds = pev(id, 56);
	time = floatsub(get_gametime(), timer_time[id]);
	get_user_authid(id, authid, 31);
	if (get_pcvar_num(kz_wr_diff) == 1)
	{
		WrDiffShow(id);
	}
	else
	{
		show_finish_message(id, time);
	}
	timer_started[id] = 0;
	new var2;
	if (wpn_15[id] && !user_has_weapon(id, "", -1))
	{
		WpnTop_update(id, time, checknumbers[id], gochecknumbers[id], maxspeeds);
	}
	else
	{
		new var3;
		if (gochecknumbers[id] && !user_has_weapon(id, "", -1) && !wpn_15[id])
		{
			ProTop_update(id, time);
		}
		new var4;
		if (gochecknumbers[id] > 0 && !user_has_weapon(id, "", -1) && !wpn_15[id])
		{
			NoobTop_update(id, time, checknumbers[id], gochecknumbers[id]);
		}
	}
	user_has_scout[id] = 0;
	return 0;
}

public show_finish_message(id, Float:kreedztime)
{
	static Float:maxspeed;
	pev(id, 56, maxspeed);
	if (maxspeed <= 1.0)
	{
		maxspeed = 250.0;
	}
	new name[32];
	new authid[32];
	new imin;
	new isec;
	new ims;
	new wpn;
	if (user_has_scout[id])
	{
		wpn = 3;
	}
	else
	{
		wpn = get_user_weapon(id, 0, 0);
	}
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	imin = floatround(floatdiv(kreedztime, 1114636288), 1);
	isec = floatround(floatsub(kreedztime, 1114636288 * imin), 1);
	ims = floatround(floatmul(1120403456, floatsub(kreedztime, 1114636288 * imin + isec)), "amxx_configsdir");
	new i;
	while (i < num)
	{
		new iminp = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
		new isecp = floatround(floatsub(Pro_Times[i], 1114636288 * iminp), 1);
		new iminz = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
		new isecz = floatround(floatsub(Noob_Tiempos[i], 1114636288 * iminz), 1);
		new oldminutes60 = get_user_frags(id) * 60;
		new oldtime = cs_get_user_deaths(id) + oldminutes60;
		new var1;
		if (equal(Pro_AuthIDS[i], authid, "amxx_configsdir") || equal(Noob_AuthIDS[i], authid, "amxx_configsdir"))
		{
			if (Pro_Times[i] < Noob_Tiempos[i])
			{
				set_user_frags(id, iminp);
				cs_set_user_deaths(id, isecp);
			}
			if (Pro_Times[i] > Noob_Tiempos[i])
			{
				set_user_frags(id, iminz);
				cs_set_user_deaths(id, isecz);
			}
		}
		else
		{
			if (oldtime)
			{
				if (oldtime > kreedztime)
				{
					set_user_frags(id, imin);
					cs_set_user_deaths(id, isec);
				}
			}
			set_user_frags(id, imin);
			cs_set_user_deaths(id, isec);
		}
		i++;
	}
	ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L: [\x03%d\x01/\x03%d\x01] %L: \x03%s \x01[\x03%d\x01]", prefix, name, -1, "KZ_NOWRNUM_FINISH_MSG", imin, isec, ims, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], -1, "KZ_WEAPON", g_weaponsnames[wpn], floatround(maxspeed, 1));
	return 0;
}

public WrDiffShow(id)
{
	new Float:zClimbTime = floatsub(get_gametime(), timer_time[id]);
	new name[32];
	new authid[32];
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	new imin;
	new isec;
	new ims;
	imin = floatround(floatdiv(zClimbTime, 1114636288), 1);
	isec = floatround(floatsub(zClimbTime, 1114636288 * imin), 1);
	ims = floatround(floatmul(1120403456, floatsub(zClimbTime, 1114636288 * imin + isec)), "amxx_configsdir");
	new wpn;
	if (user_has_scout[id])
	{
		wpn = 3;
	}
	else
	{
		wpn = get_user_weapon(id, 0, 0);
	}
	static Float:maxspeed;
	pev(id, 56, maxspeed);
	if (maxspeed <= 1.0)
	{
		maxspeed = 250.0;
	}
	if (kz_type_wr[id] == 1)
	{
		if (0 < g_iWorldRecordsNum)
		{
			new i;
			while (i < num)
			{
				new iminp = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
				new isecp = floatround(floatsub(Pro_Times[i], 1114636288 * iminp), 1);
				new iminz = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
				new isecz = floatround(floatsub(Noob_Tiempos[i], 1114636288 * iminz), 1);
				new oldminutes60 = get_user_frags(id) * 60;
				new oldtime = cs_get_user_deaths(id) + oldminutes60;
				new var1;
				if (equal(Pro_AuthIDS[i], authid, "amxx_configsdir") || equal(Noob_AuthIDS[i], authid, "amxx_configsdir"))
				{
					new var2;
					if (zClimbTime < Pro_Times[i] || zClimbTime < Noob_Tiempos[i])
					{
						set_user_frags(id, imin);
						cs_set_user_deaths(id, isec);
					}
					else
					{
						if (Pro_Times[i] < Noob_Tiempos[i])
						{
							set_user_frags(id, iminp);
							cs_set_user_deaths(id, isecp);
						}
						if (Pro_Times[i] > Noob_Tiempos[i])
						{
							set_user_frags(id, iminz);
							cs_set_user_deaths(id, isecz);
						}
					}
				}
				else
				{
					if (!oldtime)
					{
						set_user_frags(id, imin);
						cs_set_user_deaths(id, isec);
					}
				}
				i++;
			}
			if (zClimbTime < DiffWRTime[0])
			{
				new Float:sDiffTime = floatsub(DiffWRTime[0], zClimbTime);
				new szDiffTime[16];
				WRTimer(sDiffTime, szDiffTime, 15, 1, 0);
				set_dhudmessage(255, 30, 30, -1.0, 0.2, 2, 0.1, 6.0, 0.02, 0.5, false);
				new var3;
				if ((wpn_15[id] && !user_has_weapon(id, 16, -1)) || !user_has_weapon(id, 29, -1))
				{
					ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L: [\x03%d\x01/\x03%d\x01] %L: \x03%s \x01[\x03%d\x01]", prefix, name, -1, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], -1, "KZ_WEAPON", g_weaponsnames[wpn], floatround(maxspeed, 1));
				}
				else
				{
					if (!gochecknumbers[id])
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L [\x03-%s WR!!!\x01]", prefix, name, -1, "KZ_FINISH_MSG", imin, isec, ims, -1, "KZ_BEAT_CUR_WR", szDiffTime);
						show_dhudmessage(0, "%s Beat World Record!!!", name);
					}
					if (0 < gochecknumbers[id])
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01[\x03-%s WR\x01] %L: [\x03%d\x01/\x03%d\x01]", prefix, name, -1, "KZ_CP_FINISH_MSG", imin, isec, ims, szDiffTime, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id]);
					}
				}
			}
			else
			{
				new Float:sDiffTime = floatsub(zClimbTime, DiffWRTime[0]);
				new szDiffTime[16];
				WRTimer(sDiffTime, szDiffTime, 15, 1, 0);
				new var5;
				if ((wpn_15[id] && !user_has_weapon(id, 16, -1)) || !user_has_weapon(id, 29, -1))
				{
					ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L: [\x03%d\x01/\x03%d\x01] %L: \x03%s \x01[\x03%d\x01]", prefix, name, -1, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], -1, "KZ_WEAPON", g_weaponsnames[wpn], floatround(maxspeed, 1));
				}
				else
				{
					if (!gochecknumbers[id])
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L [\x03+%s WR\x01]", prefix, name, -1, "KZ_FINISH_MSG", imin, isec, ims, -1, "KZ_BEAT_WR_NEED", szDiffTime);
					}
					if (0 < gochecknumbers[id])
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01[\x03+%s WR\x01] %L: [\x03%d\x01/\x03%d\x01]", prefix, name, -1, "KZ_CP_FINISH_MSG", imin, isec, ims, szDiffTime, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id]);
					}
				}
			}
			set_task(1069547520, "CmdSayWR", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
		}
		else
		{
			if (!g_iWorldRecordsNum)
			{
				show_finish_message(id, zClimbTime);
			}
		}
	}
	else
	{
		if (kz_type_wr[id] == 2)
		{
			if (0 < g_iNtRecordsNum)
			{
				new i;
				while (i < num)
				{
					new iminp = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
					new isecp = floatround(floatsub(Pro_Times[i], 1114636288 * iminp), 1);
					new iminz = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
					new isecz = floatround(floatsub(Noob_Tiempos[i], 1114636288 * iminz), 1);
					new oldminutes60 = get_user_frags(id) * 60;
					new oldtime = cs_get_user_deaths(id) + oldminutes60;
					new var7;
					if (equal(Pro_AuthIDS[i], authid, "amxx_configsdir") || equal(Noob_AuthIDS[i], authid, "amxx_configsdir"))
					{
						if (Pro_Times[i] < Noob_Tiempos[i])
						{
							set_user_frags(id, iminp);
							cs_set_user_deaths(id, isecp);
						}
						if (Pro_Times[i] > Noob_Tiempos[i])
						{
							set_user_frags(id, iminz);
							cs_set_user_deaths(id, isecz);
						}
					}
					else
					{
						if (!oldtime)
						{
							set_user_frags(id, imin);
							cs_set_user_deaths(id, isec);
						}
					}
					i++;
				}
				if (zClimbTime < DiffNTRTime[0])
				{
					new Float:sDiffTime = floatsub(DiffNTRTime[0], zClimbTime);
					new szDiffTime[16];
					WRTimer(sDiffTime, szDiffTime, 15, 1, 0);
					set_dhudmessage(255, 30, 30, -1.0, 0.2, 2, 0.1, 6.0, 0.02, 0.5, false);
					new var8;
					if ((wpn_15[id] && !user_has_weapon(id, 16, -1)) || !user_has_weapon(id, 29, -1))
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L: [\x03%d\x01/\x03%d\x01] %L: \x03%s \x01[\x03%d\x01]", prefix, name, -1, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], -1, "KZ_WEAPON", g_weaponsnames[wpn], floatround(maxspeed, 1));
					}
					else
					{
						if (!gochecknumbers[id])
						{
							ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L [\x03-%s NTR!!!\x01]", prefix, name, -1, "KZ_FINISH_MSG", imin, isec, ims, -1, "KZ_BEAT_CUR_NTR", szDiffTime);
							show_dhudmessage(0, "%s Beat NTjump Record!!!", name);
						}
						if (0 < gochecknumbers[id])
						{
							ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01[\x03-%s NTR\x01] %L: [\x03%d\x01/\x03%d\x01]", prefix, name, -1, "KZ_CP_FINISH_MSG", imin, isec, ims, szDiffTime, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id]);
						}
					}
				}
				else
				{
					new Float:sDiffTime = floatsub(zClimbTime, DiffNTRTime[0]);
					new szDiffTime[16];
					WRTimer(sDiffTime, szDiffTime, 15, 1, 0);
					new var10;
					if ((wpn_15[id] && !user_has_weapon(id, 16, -1)) || !user_has_weapon(id, 29, -1))
					{
						ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L: [\x03%d\x01/\x03%d\x01] %L: \x03%s \x01[\x03%d\x01]", prefix, name, -1, "KZ_WEAPON_FINISH_MSG", imin, isec, ims, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id], -1, "KZ_WEAPON", g_weaponsnames[wpn], floatround(maxspeed, 1));
					}
					else
					{
						if (!gochecknumbers[id])
						{
							ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01%L [\x03+%s NTR\x01].", prefix, name, -1, "KZ_FINISH_MSG", imin, isec, ims, -1, "KZ_BEAT_NTR_NEED", szDiffTime);
						}
						if (0 < gochecknumbers[id])
						{
							ColorChat(0, Color:2, "\x01%s \x03%s \x01%L \x03%02i:%02i.%02i \x01[\x03+%s NTR\x01] %L: [\x03%d\x01/\x03%d\x01]", prefix, name, -1, "KZ_CP_FINISH_MSG", imin, isec, ims, szDiffTime, -1, "KZ_CPS_TPS", checknumbers[id], gochecknumbers[id]);
						}
					}
				}
				set_task(1069547520, "CmdSayCR", id, 340908, "amxx_configsdir", 340912, "amxx_configsdir");
			}
			if (!g_iNtRecordsNum)
			{
				show_finish_message(id, zClimbTime);
			}
		}
	}
	return 0;
}

public ProTop_update(id, Float:time)
{
	new authid[32];
	new name[32];
	new thetime[32];
	new ip[32];
	new country[3];
	new Float:slower = 0.0;
	new Float:faster = 0.0;
	new Float:protiempo = 0.0;
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d", thetime, 31);
	get_user_ip(id, ip, 31);
	geoip_code2(ip, country);
	new bool:Is_in_pro15 = false;
	new i;
	while (i < num)
	{
		if( (equali(Pro_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Pro_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			Is_in_pro15 = true
			slower = time - Pro_Times[i]
			faster = Pro_Times[i] - time
			protiempo = Pro_Times[i]
		}
		i++;
	}
	while (i < num)
	{
		if (time < Pro_Times[i])
		{
			new pos = i;
			if (get_pcvar_num(kz_top15_authid))
			{
				if (get_pcvar_num(kz_top15_authid) == 1)
				{
					while( !equal(Pro_Names[pos], name) && pos < num )
					{
						pos++;
					}
				}
			}
			new j = pos;
			while (j > i)
			{
				formatex(Pro_AuthIDS[j], 31, Pro_AuthIDS[j + -1]);
				formatex(Pro_Names[j], 31, Pro_Names[j + -1]);
				formatex(Pro_Country[j], "", Pro_Country[j + -1]);
				formatex(Pro_Date[j], 31, Pro_Date[j + -1]);
				Pro_Times[j] = Pro_Times[j + -1];
				j--;
			}
			formatex(Pro_AuthIDS[i], 31, authid);
			formatex(Pro_Names[i], 31, name);
			formatex(Pro_Country[i], "", country);
			formatex(Pro_Date[i], 31, thetime);
			Pro_Times[i] = time;
			save_pro15();
			if (Is_in_pro15)
			{
				if (time < protiempo)
				{
					new min;
						new Float:sec;
						min = floatround(faster, floatround_floor)/60;
						sec = faster - (60*min);
						ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_IMPROVE", min, sec < 10 ? "0" : "", sec);

					if (i + 1 == 1)
					{
						if (time < DiffWRTime[0])
						{
							client_cmd(0, "spk misc/mod_godlike");
						}
						else
						{
							client_cmd(0, "spk kzsound/toprec");
						}
						// #MARK: ADDED BOT HERE;
						if (REC_AC[id])
						{
							if (g_bestruntime < Pro_Times[id])
							{
								client_print("amxx_configsdir", 2, "REC %f UPDATE %f", g_bestruntime, time);
								ClCmd_UpdateReplay(id, time);
							}
						}
						ColorChat(0, Color:5, "\x01%s\x01\x03 %s\x01 %L\x03 1\x01 in \x03Professional\x01", prefix, name, -1, "KZ_PLACE");
					}
					else
					{
						client_cmd(0, "spk buttons/bell1");
						ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x03Pro 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
					}
				}
			}
			else
			{
				if (i + 1 == 1)
				{
					if (REC_AC[id])
					{
						ClCmd_UpdateReplay(id, time);
					}
					client_cmd(0, "spk kzsound/toprec");
					ColorChat(0, RED,  "^x01%s^x01^x03 %s^x01 %L^x03 1^x01 in ^x03Professional^x01", prefix, name, LANG_PLAYER, "KZ_PLACE");
					// ColorChat(0, Color:5, "\x01%s\x01\x03 %s\x01 %L\x03 1\x01 in \x03Professional\x01", prefix, name, -1, "KZ_PLACE");
				}
				client_cmd(0, "spk buttons/bell1");
				ColorChat(0, GREEN,  "^x01%s^x01^x03 %s^x01 %L^x03 %d^x01 in ^x04Pro 100^x01", prefix, name, LANG_PLAYER, "KZ_PLACE", (i+1));

				// ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Pro 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
			}
			return 0;
		}
		// if ((equali(Pro_Names[i], name, "amxx_configsdir") && get_pcvar_num(kz_top15_authid)) || (equali(Pro_AuthIDS[i], authid, "amxx_configsdir") && get_pcvar_num(kz_top15_authid) == 1))
		if( (equali(Pro_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Pro_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			if( time > protiempo )
			{
				new min, Float:sec;
				min = floatround(slower, floatround_floor)/60;
				sec = slower - (60*min);
				client_cmd(0, "spk fvox/bell");
				ColorChat(id, GREEN,  "%s^x01 %L ^x03%02d:%s%.2f^x01", prefix, id, "KZ_SLOWER", min, sec < 10 ? "0" : "", sec);
				return;
			}
		}
		i++;
	}
	return 0;
}

public save_pro15()
{
	new profile[128];
	formatex(profile, 127, "%s/pro_%s.cfg", Topdir, MapName);
	if (file_exists(profile))
	{
		delete_file(profile);
	}
	new Data[256];
	new f = fopen(profile, "at");
	new i;
	while (i < num)
	{
		// formatex(Data, "", "\"%.2f\"   \"%s\" \"%s\"   \"%s\"   \"%s\"\n", Pro_Times[i], Pro_Country[i], Pro_AuthIDS[i], Pro_Names[i], Pro_Date[i]);
		formatex(Data, 255, "^"%.2f^"   ^"%s^" ^"%s^"   ^"%s^"   ^"%s^"^n", Pro_Times[i],Pro_Country[i], Pro_AuthIDS[i], Pro_Names[i], Pro_Date[i])
		
		fputs(f, Data);
		i++;
	}
	fclose(f);
	return 0;
}

public read_pro15()
{
	new profile[128], prodata[256]
	formatex(profile, 127, "%s/pro_%s.cfg", Topdir, MapName)
	
	new f = fopen(profile, "rt" )
	new i = 0
	while( !feof(f) && i < num + 1)
	{
		fgets(f, prodata, 255)
		new totime[25]
		parse(prodata, totime, 24, Pro_Country[i], 3, Pro_AuthIDS[i], 31, Pro_Names[i], 31, Pro_Date[i], 31)
		Pro_Times[i] = str_to_float(totime)
		i++;
	}
	fclose(f);
	return 0;
}

public NoobTop_update(id, Float:time, checkpoints, gochecks)
{
	new authid[32];
	new name[32];
	new thetime[32];
	new wpn;
	new ip[32];
	new country[3];
	new Float:slower = 0.0;
	new Float:faster = 0.0;
	new Float:noobtiempo = 0.0;
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d", thetime, 31);
	get_user_ip(id, ip, 31, "amxx_configsdir");
	geoip_code2(ip, country);
	new bool:Is_in_noob15 = false;
	if(user_has_scout[id])
		wpn=CSW_SCOUT
	else
		wpn=get_user_weapon(id)
	new i;
	while (i < num)
	{
		if( (equali(Noob_Names[i], name) && (get_pcvar_num(kz_top15_authid) == 0)) || (equali(Noob_AuthIDS[i], authid) && (get_pcvar_num(kz_top15_authid) == 1)) )
		{
			Is_in_noob15 = true
			slower = time - Noob_Tiempos[i];
			faster = Noob_Tiempos[i] - time;
			noobtiempo = Noob_Tiempos[i]
		}
		i++;
	}
	new i;
	while (i < num)
	{
		if (time < Noob_Tiempos[i])
		{
			new pos = i;
			if (get_pcvar_num(kz_top15_authid))
			{
				if (get_pcvar_num(kz_top15_authid) == 1)
				{
					while (!equal(Noob_AuthIDS[pos], authid, "amxx_configsdir") && pos < num)
					{
						pos++;
					}
				}
			}
			new j = pos;
			while (j > i)
			{
				formatex(Noob_AuthIDS[j], 31, Noob_AuthIDS[j + -1]);
				formatex(Noob_Names[j], 31, Noob_Names[j + -1]);
				formatex(Noob_Date[j], 31, Noob_Date[j + -1]);
				formatex(Noob_Weapon[j], 31, Noob_Weapon[j + -1]);
				formatex(Noob_Country[j], "", Noob_Country[j + -1]);
				Noob_Tiempos[j] = Noob_Tiempos[j + -1];
				Noob_CheckPoints[j] = Noob_CheckPoints[j + -1];
				Noob_GoChecks[j] = Noob_GoChecks[j + -1];
				j--;
			}
			formatex(Noob_AuthIDS[i], 31, authid);
			formatex(Noob_Names[i], 31, name);
			formatex(Noob_Date[i], 31, thetime);
			formatex(Noob_Weapon[i], 31, g_weaponsnames[wpn]);
			formatex(Noob_Country[i], "", country);
			Noob_Tiempos[i] = time;
			Noob_CheckPoints[i] = checkpoints;
			Noob_GoChecks[i] = gochecks;
			save_Noob15();
			if (Is_in_noob15)
			{
				if (time < noobtiempo)
				{
					new min;
					new Float:sec = 0.0;
					min = floatround(faster, 1) / 60;
					sec = faster - min * 60;
					new var6;
					if (sec < 1.4E-44)
					{
						var6 = 425988;
					}
					else
					{
						var6 = 425996;
					}
					ColorChat(id, Color:2, "%s\x01 %L \x03%02d:%s%.2f\x01", prefix, id, "KZ_IMPROVE", min, var6, sec);
					if (i + 1 == 1)
					{
						if (REC_AC[id])
						{
							if (gc_bestruntime < Noob_Tiempos[id])
							{
								client_print("amxx_configsdir", 2, "NUB %f UPDATE %f", gc_bestruntime, time);
								ClCmd_UpdateReplay_c(id, time);
							}
						}
						client_cmd("amxx_configsdir", "spk woop");
						ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Noob 100\x01", prefix, name, -1, "KZ_PLACE");
					}
					else
					{
						client_cmd("amxx_configsdir", "spk buttons/bell1");
						ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Noob 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
					}
				}
			}
			else
			{
				if (i + 1 == 1)
				{
					if (REC_AC[id])
					{
						ClCmd_UpdateReplay_c(id, time);
					}
					client_cmd("amxx_configsdir", "spk woop");
					ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Noob 100\x01", prefix, name, -1, "KZ_PLACE");
				}
				client_cmd("amxx_configsdir", "spk buttons/bell1");
				ColorChat(0, Color:2, "\x01%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Noob 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
			}
			return 0;
		}
		new var7;
		if ((equali(Noob_Names[i], name, "amxx_configsdir") && get_pcvar_num(kz_top15_authid)) || (equali(Noob_AuthIDS[i], authid, "amxx_configsdir") && get_pcvar_num(kz_top15_authid) == 1))
		{
			if (time > noobtiempo)
			{
				new min;
				new Float:sec = 0.0;
				min = floatround(slower, 1) / 60;
				sec = slower - min * 60;
				client_cmd("amxx_configsdir", "spk fvox/bell");
				new var10;
				if (sec < 1.4E-44)
				{
					var10 = 427112;
				}
				else
				{
					var10 = 427120;
				}
				ColorChat(id, Color:2, "%s\x01 %L \x03%02d:%s%.2f\x01", prefix, id, "KZ_SLOWER", min, var10, sec);
				return 0;
			}
		}
		i++;
	}
	return 0;
}

public save_Noob15()
{
	new profile[128];
	formatex(profile, 127, "%s/Noob_%s.cfg", Topdir, MapName);
	if (file_exists(profile))
	{
		delete_file(profile);
	}
	new Data[256];
	new f = fopen(profile, "at");
	new i;
	while (i < num)
	{
		formatex(Data, "", "\"%.2f\"  \"%s\"  \"%s\"   \"%s\"   \"%i\"   \"%i\"   \"%s\"  \"%s\" \n", Noob_Tiempos[i], Noob_Country[i], Noob_AuthIDS[i], Noob_Names[i], Noob_CheckPoints[i], Noob_GoChecks[i], Noob_Date[i], Noob_Weapon[i]);
		fputs(f, Data);
		i++;
	}
	fclose(f);
	return 0;
}

public read_Noob15()
{
	new profile[128];
	new prodata[256];
	formatex(profile, 127, "%s/Noob_%s.cfg", Topdir, MapName);
	new f = fopen(profile, "rt");
	new i;
	while (!feof(f) && i < num + 1)
	{
		fgets(f, prodata, "");
		new totime[25];
		new checks[5];
		new gochecks[5];
		parse(prodata, totime, 24, Noob_Country[i], 3, Noob_AuthIDS[i], 31, Noob_Names[i], 31, checks, 4, gochecks, 4, Noob_Date[i], 31, Noob_Weapon[i], 31);
		Noob_Tiempos[i] = str_to_float(totime);
		Noob_CheckPoints[i] = str_to_num(checks);
		Noob_GoChecks[i] = str_to_num(gochecks);
		i++;
	}
	fclose(f);
	return 0;
}

public WpnTop_update(id, Float:time, checkpoints, gochecks, maxspeed)
{
	new authid[32];
	new name[32];
	new thetime[32];
	new wpn;
	new ip[32];
	new country[3];
	new Float:slower = 0.0;
	new Float:faster = 0.0;
	new Float:wpntiempo = 0.0;
	new wpnspeedz;
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_time("%Y/%m/%d", thetime, 31);
	get_user_ip(id, ip, 31, "amxx_configsdir");
	geoip_code2(ip, country);
	new bool:Is_in_wpn15 = false;
	if (user_has_scout[id])
	{
		wpn = 3;
	}
	else
	{
		wpn = get_user_weapon(id, 0, 0);
	}
	new i;
	while (i < num)
	{
		new var1;
		if ((equali(Wpn_Names[i], name, "amxx_configsdir") && get_pcvar_num(kz_top15_authid)) || (equali(Wpn_AuthIDS[i], authid, "amxx_configsdir") && get_pcvar_num(kz_top15_authid) == 1))
		{
			Is_in_wpn15 = true;
			slower = floatsub(time, Wpn_Timepos[i]);
			faster = floatsub(Wpn_Timepos[i], time);
			wpntiempo = Wpn_Timepos[i];
			wpnspeedz = Wpn_maxspeed[i];
		}
		i++;
	}
	new i;
	while (i < num)
	{
		if (Wpn_maxspeed[i] > maxspeed)
		{
			new pos = i;
			if (get_pcvar_num(kz_top15_authid))
			{
				if (get_pcvar_num(kz_top15_authid) == 1)
				{
					while (!equal(Wpn_AuthIDS[pos], authid, "amxx_configsdir") && pos < num)
					{
						pos++;
					}
				}
			}
			new j = pos;
			while (j > i)
			{
				formatex(Wpn_AuthIDS[j], 31, Wpn_AuthIDS[j + -1]);
				formatex(Wpn_Names[j], 31, Wpn_Names[j + -1]);
				formatex(Wpn_Date[j], 31, Wpn_Date[j + -1]);
				formatex(Wpn_Weapon[j], 31, Wpn_Weapon[j + -1]);
				formatex(Wpn_Country[j], "", Wpn_Country[j + -1]);
				Wpn_maxspeed[j] = Wpn_maxspeed[j + -1];
				Wpn_Timepos[j] = Wpn_Timepos[j + -1];
				Wpn_CheckPoints[j] = Wpn_CheckPoints[j + -1];
				Wpn_GoChecks[j] = Wpn_GoChecks[j + -1];
				j--;
			}
			formatex(Wpn_AuthIDS[i], 31, authid);
			formatex(Wpn_Names[i], 31, name);
			formatex(Wpn_Date[i], 31, thetime);
			formatex(Wpn_Weapon[i], 31, g_weaponsnames[wpn]);
			formatex(Wpn_Country[i], "", country);
			Wpn_maxspeed[i] = maxspeed;
			Wpn_Timepos[i] = time;
			Wpn_CheckPoints[i] = checkpoints;
			Wpn_GoChecks[i] = gochecks;
			save_Wpn15();
			if (Is_in_wpn15)
			{
				if (maxspeed < wpnspeedz)
				{
					if (i + 1 == 1)
					{
						client_cmd("amxx_configsdir", "spk woop");
						ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE");
					}
					client_cmd("amxx_configsdir", "spk buttons/bell1");
					ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
				}
			}
			else
			{
				if (i + 1 == 1)
				{
					client_cmd("amxx_configsdir", "spk woop");
					ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE");
				}
				client_cmd("amxx_configsdir", "spk buttons/bell1");
				ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
			}
			return 0;
		}
		if (Wpn_maxspeed[i] == maxspeed)
		{
			if (time < Wpn_Timepos[i])
			{
				new pos = i;
				if (get_pcvar_num(kz_top15_authid))
				{
					if (get_pcvar_num(kz_top15_authid) == 1)
					{
						while (!equal(Wpn_AuthIDS[pos], authid, "amxx_configsdir") && pos < num)
						{
							pos++;
						}
					}
				}
				new j = pos;
				while (j > i)
				{
					formatex(Wpn_AuthIDS[j], 31, Wpn_AuthIDS[j + -1]);
					formatex(Wpn_Names[j], 31, Wpn_Names[j + -1]);
					formatex(Wpn_Date[j], 31, Wpn_Date[j + -1]);
					formatex(Wpn_Weapon[j], 31, Wpn_Weapon[j + -1]);
					formatex(Wpn_Country[j], "", Wpn_Country[j + -1]);
					Wpn_maxspeed[j] = Wpn_maxspeed[j + -1];
					Wpn_Timepos[j] = Wpn_Timepos[j + -1];
					Wpn_CheckPoints[j] = Wpn_CheckPoints[j + -1];
					Wpn_GoChecks[j] = Wpn_GoChecks[j + -1];
					j--;
				}
				formatex(Wpn_AuthIDS[i], 31, authid);
				formatex(Wpn_Names[i], 31, name);
				formatex(Wpn_Date[i], 31, thetime);
				formatex(Wpn_Weapon[i], 31, g_weaponsnames[wpn]);
				formatex(Wpn_Country[i], "", country);
				Wpn_maxspeed[i] = maxspeed;
				Wpn_Timepos[i] = time;
				Wpn_CheckPoints[i] = checkpoints;
				Wpn_GoChecks[i] = gochecks;
				save_Wpn15();
				if (Is_in_wpn15)
				{
					if (time < wpntiempo)
					{
						new min;
						new Float:sec = 0.0;
						min = floatround(faster, 1) / 60;
						sec = faster - min * 60;
						new var8;
						if (sec < 1.4E-44)
						{
							var8 = 428532;
						}
						else
						{
							var8 = 428540;
						}
						ColorChat(id, Color:2, "%s\x01 %L \x03%02d:%s%.2f\x01", prefix, id, "KZ_IMPROVE", min, var8, sec);
						if (i + 1 == 1)
						{
							client_cmd("amxx_configsdir", "spk woop");
							ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE");
						}
						else
						{
							client_cmd("amxx_configsdir", "spk buttons/bell1");
							ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
						}
					}
				}
				else
				{
					if (i + 1 == 1)
					{
						client_cmd("amxx_configsdir", "spk woop");
						ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 1\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE");
					}
					client_cmd("amxx_configsdir", "spk buttons/bell1");
					ColorChat(0, Color:2, "%s\x01\x03 %s\x01 %L\x03 %d\x01 in \x04Weapon 100\x01", prefix, name, -1, "KZ_PLACE", i + 1);
				}
				return 0;
			}
		}
		new var9;
		if ((equali(Wpn_Names[i], name, "amxx_configsdir") && get_pcvar_num(kz_top15_authid)) || (equali(Wpn_AuthIDS[i], authid, "amxx_configsdir") && get_pcvar_num(kz_top15_authid) == 1))
		{
			if (maxspeed > wpnspeedz)
			{
				new min;
				new Float:sec = 0.0;
				min = floatround(slower, 1) / 60;
				sec = slower - min * 60;
				client_cmd("amxx_configsdir", "spk fvox/bell");
				new var12;
				if (sec < 1.4E-44)
				{
					var12 = 429604;
				}
				else
				{
					var12 = 429612;
				}
				ColorChat(id, Color:2, "%s\x01 %L \x03%02d:%s%.2f\x01", prefix, id, "KZ_SLOWER", min, var12, sec);
				return 0;
			}
			if (time > wpntiempo)
			{
				new min;
				new Float:sec = 0.0;
				min = floatround(slower, 1) / 60;
				sec = slower - min * 60;
				client_cmd("amxx_configsdir", "spk fvox/bell");
				new var13;
				if (sec < 1.4E-44)
				{
					var13 = 429796;
				}
				else
				{
					var13 = 429804;
				}
				ColorChat(id, Color:2, "%s\x01 %L \x03%02d:%s%.2f\x01", prefix, id, "KZ_SLOWER", min, var13, sec);
				return 0;
			}
		}
		i++;
	}
	return 0;
}

public save_Wpn15()
{
	new profile[128];
	formatex(profile, 127, "%s/Wpn_%s.cfg", Topdir, MapName);
	if (file_exists(profile))
	{
		delete_file(profile);
	}
	new Data[256];
	new f = fopen(profile, "at");
	new i;
	while (i < num)
	{
		formatex(Data, "", "\"%.2f\" \"%i\" \"%s\" \"%s\"   \"%s\"   \"%i\"   \"%i\"   \"%s\"  \"%s\" \n", Wpn_Timepos[i], Wpn_maxspeed[i], Wpn_Country[i], Wpn_AuthIDS[i], Wpn_Names[i], Wpn_CheckPoints[i], Wpn_GoChecks[i], Wpn_Date[i], Wpn_Weapon[i]);
		fputs(f, Data);
		i++;
	}
	fclose(f);
	return 0;
}

public read_Wpn15()
{
	new profile[128];
	new prodata[256];
	formatex(profile, 127, "%s/Wpn_%s.cfg", Topdir, MapName);
	new f = fopen(profile, "rt");
	new i;
	while (!feof(f) && i < num + 1)
	{
		fgets(f, prodata, "");
		new totime[25];
		new checks[5];
		new gochecks[5];
		new wpnspeed[11];
		parse(prodata, totime, 24, wpnspeed, 10, Wpn_Country[i], 3, Wpn_AuthIDS[i], 31, Wpn_Names[i], 31, checks, 4, gochecks, 4, Wpn_Date[i], 31, Wpn_Weapon[i], 31);
		Wpn_Timepos[i] = str_to_float(totime);
		Wpn_CheckPoints[i] = str_to_num(checks);
		Wpn_GoChecks[i] = str_to_num(gochecks);
		Wpn_maxspeed[i] = str_to_num(wpnspeed);
		i++;
	}
	fclose(f);
	return 0;
}

public ProTop_show(id)
{
	new fh = fopen(PRO_PATH, 430176);
	fprintf(fh, "<meta charset=UTF-8>");
	fprintf(fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>", WEB_URL);
	fprintf(fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Time <th width=10%%> To WR <th width=10%%> Date ");
	new line[501];
	new btime_str[4];
	new ctime_str[65];
	new name[33];
	new imgs[100];
	new Float:difftime = 0.0;
	new wrdiff[65];
	new arrow_up[100];
	new arrow_down[100];
	new arrow_multiway[100];
	new i;
	while (i < num)
	{
		new var3 = Pro_Names[i];
		name = var3;
		if (Pro_Times[i] > 9999999.0)
		{
			formatex(line, 125, "%s%s%s%s%s%s%s", 430980, 430984, 430988, 430992, 430996, 431000, 431004, 431008);
			fprintf(fh, line);
		}
		else
		{
			if (Pro_Times[i] < DiffWRTime[0])
			{
				format(arrow_up, 99, "<img src=%s/images/arrow_up.png>", WEB_URL);
				imgs = arrow_up;
				difftime = floatsub(DiffWRTime[0], Pro_Times[i]);
			}
			else
			{
				if (Pro_Times[i] > DiffWRTime[0])
				{
					format(arrow_down, 99, "<img src=%s/images/arrow_down.png>", WEB_URL);
					imgs = arrow_down;
					difftime = floatsub(Pro_Times[i], DiffWRTime[0]);
				}
				if (Pro_Times[i] == DiffWRTime[0])
				{
					format(arrow_multiway, 99, "<img src=%s/images/arrow_multiway.png>", WEB_URL);
					imgs = arrow_multiway;
					difftime = 0.0;
				}
			}
			new imin;
			new isec;
			new ims;
			imin = floatround(floatdiv(Pro_Times[i], 1114636288), 1);
			isec = floatround(floatsub(Pro_Times[i], 1114636288 * imin), 1);
			ims = floatround(floatmul(1120403456, floatsub(Pro_Times[i], 1114636288 * imin + isec)), "amxx_configsdir");
			new iMinutes;
			new iSeconds;
			new iMiliSeconds;
			iMinutes = floatround(difftime / 60, 1);
			iSeconds = floatround(difftime - iMinutes * 60, 1);
			iMiliSeconds = floatround(difftime - iSeconds + iMinutes * 60 * 100, "amxx_configsdir");
			format(btime_str, "", "%d", i + 1);
			format(ctime_str, "HamFilter", "%02i:%02i.<font color=#FF0004>%02i</font>", imin, isec, ims);
			format(wrdiff, "HamFilter", "%02d:%02d.<font color=#FF0004>%02d</font>", iMinutes, iSeconds, iMiliSeconds);
			if (0 < g_iWorldRecordsNum)
			{
				htmlspecialchars(name);
				new var1;
				if (i % 2)
				{
					var1 = 432448;
				}
				else
				{
					var1 = 6188;
				}

/* ERROR! Can't print expression: Heap */
 function "ProTop_show" (number 238)
public NoobTop_show(id)
{
	new fh = fopen(NUB_PATH, 434072);
	fprintf(fh, "<meta charset=UTF-8>");
	fprintf(fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>", WEB_URL);
	fprintf(fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Time <th width=10%%> CPs/TPs <th width=10%%> Date ");
	new line[501];
	new btime_str[4];
	new ctime_str[50];
	new name[33];
	new i;
	while (i < num)
	{
		new var2 = Noob_Names[i];
		name = var2;
		if (Noob_Tiempos[i] > 9999999.0)
		{
			formatex(line, 125, "%s%s%s%s%s%s%s", 434884, 434888, 434892, 434896, 434900, 434904, 434908, 434912);
			fprintf(fh, line);
		}
		else
		{
			new imin;
			new isec;
			new ims;
			imin = floatround(floatdiv(Noob_Tiempos[i], 1114636288), 1);
			isec = floatround(floatsub(Noob_Tiempos[i], 1114636288 * imin), 1);
			ims = floatround(floatmul(1120403456, floatsub(Noob_Tiempos[i], 1114636288 * imin + isec)), "amxx_configsdir");
			format(btime_str, "", "%d", i + 1);
			format(ctime_str, "HamFilter", "%02i:%02i.<font color=#FF0004>%02i</font>", imin, isec, ims);
			htmlspecialchars(name);
			new var1;
			if (i % 2)
			{
				var1 = 6188;
			}
			else
			{
				var1 = 435760;
			}

/* ERROR! Can't print expression: Heap */
 function "NoobTop_show" (number 239)
public WpnTop_show(id)
{
	new fh = fopen(WPN_PATH, 436644);
	fprintf(fh, "<meta charset=UTF-8>");
	fprintf(fh, "<link rel=stylesheet href=%s/topcss/sb.css><table><tr id=a>", WEB_URL);
	fprintf(fh, "<th width=1%%> # <th width=15%%> Name <th width=10%%> Wpn/Speed <th width=10%%> Time <th width=10%%> CPs/TPs <th width=10%%> Date ");
	new line[501];
	new btime_str[4];
	new ctime_str[50];
	new name[33];
	new i;
	while (i < num)
	{
		new var2 = Wpn_Names[i];
		name = var2;
		if (Wpn_Timepos[i] > 9999999.0)
		{
			formatex(line, 125, "%s%s%s%s%s%s%s", 437560, 437564, 437568, 437572, 437576, 437580, 437584, 437588, 437592);
			fprintf(fh, line);
		}
		else
		{
			new imin;
			new isec;
			new ims;
			imin = floatround(floatdiv(Wpn_Timepos[i], 1114636288), 1);
			isec = floatround(floatsub(Wpn_Timepos[i], 1114636288 * imin), 1);
			ims = floatround(floatmul(1120403456, floatsub(Wpn_Timepos[i], 1114636288 * imin + isec)), "amxx_configsdir");
			format(btime_str, "", "%d", i + 1);
			format(ctime_str, "HamFilter", "%02i:%02i.<font color=#FF0004>%02i</font>", imin, isec, ims);
			htmlspecialchars(name);
			new var1;
			if (i % 2)
			{
				var1 = 6188;
			}
			else
			{
				var1 = 438516;
			}

/* ERROR! Can't print expression: Heap */
 function "WpnTop_show" (number 240)
public plugin_end()
{
	TrieDestroy(g_tSounds);
	new i = 1;
	while (i < max_players)
	{
		new var1;
		if (Autosavepos[i] && !is_user_bot(i))
		{
			saveposition(i);
		}
		i++;
	}
	return 0;
}

