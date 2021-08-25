#define MAX_FLARES 200

enum flInfo
{
 	fCreated,
    Float:fX,
    Float:fY,
    Float:fZ,
    fObject
};

new FlareInfo[MAX_FLARES][flInfo];

stock CreateFlare(Float:x,Float:y,Float:z,Float:Angle)
{
    for(new i = 0; i < sizeof(FlareInfo); i++)
  	{
  	    if(FlareInfo[i][fCreated] == 0)
  	    {
            FlareInfo[i][fCreated]=1;
            FlareInfo[i][fX]=x;
            FlareInfo[i][fY]=y;
            FlareInfo[i][fZ]=z-0.5;
            FlareInfo[i][fObject] = CreateObject(18728, x, y, z-2.8, 0, 0, Angle-90);
	        return 1;
  	    }
  	}
  	return 0;
}

stock DeleteAllFlare()
{
    for(new i = 0; i < sizeof(FlareInfo); i++)
  	{
  	    if(FlareInfo[i][fCreated] == 1)
  	    {
  	        FlareInfo[i][fCreated]=0;
            FlareInfo[i][fX]=0.0;
            FlareInfo[i][fY]=0.0;
            FlareInfo[i][fZ]=0.0;
            DestroyObject(FlareInfo[i][fObject]);
  	    }
	}
    return 0;
}

stock DeleteClosestFlare(playerid)
{
    for(new i = 0; i < sizeof(FlareInfo); i++)
  	{
  	    if(IsPlayerInRangeOfPoint(playerid, 15.0, FlareInfo[i][fX], FlareInfo[i][fY], FlareInfo[i][fZ]))
        {
  	        if(FlareInfo[i][fCreated] == 1)
            {
                FlareInfo[i][fCreated]=0;
                FlareInfo[i][fX]=0.0;
                FlareInfo[i][fY]=0.0;
                FlareInfo[i][fZ]=0.0;
                DestroyObject(FlareInfo[i][fObject]);
                return 1;
  	        }
  	    }
  	}
    return 0;
}
