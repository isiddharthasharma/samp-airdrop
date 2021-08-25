#include <a_samp>
#include <mapandreasNP>
#include <izcmd>
#include <flares>

#define FILTERSCRIPT

#define MAX_AIRDROPS            3

#define MAX_TDN 				        4
#define TDN_MODE_DEFAULT
#include "td-notification.inc"

new Text3D:PickupLabel;
new Text3D:LootedLabel;
new bool:onCheck[MAX_PLAYERS];
forward adcreation();

enum AirdropEnum
{
    a_object,
    a_expire_timer,
    Float:a_pos[3],
    bool:a_exist,
    bool:a_droped
};
new gAirdrop[MAX_AIRDROPS][AirdropEnum];

public adcreation()
{
    CreateAirdrop();
    return 1;
}

public OnFilterScriptInit()
{
    for(new i; i < MAX_AIRDROPS; i++)
    {
        gAirdrop[i][a_exist] = false;
    }
    SetTimer("adcreation", 30 * 60000, true);
    return 1;
}

CreateAirdrop(Float:speed = 5.0, Float:height = 100.0)
{
    for(new i; i < MAX_AIRDROPS; i++)
    {
    	new	Float:pos[2], x=random(4000)-2000, y=random(4000)-2000;
		pos[0] = x, pos[1] = y;
        if(! gAirdrop[i][a_exist])
        {
            new Float:z;
            GetPointZPos(x, y, z);
            z += 7.5;
		    for(new u = 0, j = GetPlayerPoolSize(); u <= j; u++)
		    {
          		SetPlayerWeather(u, 17);
				
				ShowTDN(i, "Due to storm a plane has lost contact with Area 51 and accidentaly dropped an airdrop");
				ShowTDN(i, "The airdrop contains materials useful for government.");
				ShowTDN(i, "You can either steal it and give it to your government or sell it to local scientist.");
			}
            gAirdrop[i][a_object] = CreateObject(18849, x, y, (z + height), 0.0, 0.0, 0.0);
            CreateFlare(x, y, z-10, -90);

            MoveObject(gAirdrop[i][a_object], x, y, z, speed);

            gAirdrop[i][a_pos][0] = x;
            gAirdrop[i][a_pos][1] = y;

            gAirdrop[i][a_pos][2] = (z - (7.5));

            gAirdrop[i][a_exist] = true;
            gAirdrop[i][a_expire_timer] = -1;
            gAirdrop[i][a_droped] = false;

            return i;
        }
    }
    return -1;
}

public OnObjectMoved(objectid)
{
    for(new i; i < MAX_AIRDROPS; i++)
    {
        if(gAirdrop[i][a_exist])
        {
            if(objectid == gAirdrop[i][a_object])
            {
                gAirdrop[i][a_droped] = true;
                DestroyObject(gAirdrop[i][a_object]);
                CreateObject(964, gAirdrop[i][a_pos][0], gAirdrop[i][a_pos][1], gAirdrop[i][a_pos][2], 0.0, 0.0, 0.0); // Object

                PickupLabel = Create3DTextLabel("Military Airdrop\nPress N to pickup", 0x33AA33FF, gAirdrop[i][a_pos][0],gAirdrop[i][a_pos][1],gAirdrop[i][a_pos][2], 30.0, 0, 0);
                gAirdrop[i][a_expire_timer] = SetTimerEx("OnAirdropExpire", (300 * 1000), false, "i", i);
            }
        }
    }
    return 1;
}

CMD:locatead(playerid, params[])
{
    cmd_locateairdrop(playerid, params);
    return 1;
}

CMD:startad(playerid, params[])
{
    cmd_startairdrop(playerid, params);
    return 1;
}

CMD:delad(playerid, params[])
{
    cmd_deleteairdrop(playerid, params);
    return 1;
}

CMD:gotoad(playerid, params[])
{
    cmd_gotoairdrop(playerid, params);
    return 1;
}

CMD:locateairdrop(playerid, params[])
{
    SetPlayerCheckpoint(playerid, gAirdrop[playerid][a_pos][0], gAirdrop[playerid][a_pos][1], gAirdrop[playerid][a_pos][2], 3.0);
    onCheck[playerid] = true;
    SendClientMessage(playerid, -1, "SERVER: Airdrop location marked.");
    return 1;
}

CMD:startairdrop(playerid, params[])
{
	CreateAirdrop(0.0, 0.0);
	SendClientMessage(playerid, -1, "SERVER: You've started airdrop tasks.");
	return 1;
}

CMD:gotoairdrop(playerid, params[])
{
	SetPlayerPos(playerid, gAirdrop[playerid][a_pos][0] +2, gAirdrop[playerid][a_pos][1], gAirdrop[playerid][a_pos][2]);
	SendClientMessage(playerid, -1, "SERVER: You've teleported to airdrop.");
	return 1;
}

CMD:deleteairdrop(playerid, params[])
{
	SendClientMessage(playerid, -1, "SERVER: You've removed all airdrop tasks.");
	CallRemoteFunction("OnAirdropExpire", "i", playerid);
	return 1;
}

forward OnAirdropExpire(airdropid);
public OnAirdropExpire(airdropid)
{
    gAirdrop[airdropid][a_exist] = false;

    gAirdrop[airdropid][a_expire_timer] = -1;
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
  		SetPlayerWeather(j, 1);
  		ShowTDN(i, "The military acquired the airdrop");
	}
    DestroyObject(gAirdrop[airdropid][a_object]);
    DeleteAllFlare();
    return 1;
}

forward OnPlayerPickupAirdrop(playerid, airdropid);
public OnPlayerPickupAirdrop(playerid, airdropid)
{
    ClearAnimations(playerid);
    //Give reward

    // For example:
    /*
    GivePlayerWeapon(playerid, 31, 100);
    GameTextForPlayer(playerid, "~b~~h~~h~~h~You found a ~w~~h~M4", 3000, 3);
   */
    gAirdrop[airdropid][a_exist] = false;
    gAirdrop[airdropid][a_expire_timer] = -1;

    for(new k = 0, j = GetPlayerPoolSize(); k <= j; k++)
    {
  		ShowTDN(k, "Someone has acquired the airdrop");
  		Delete3DTextLabel(PickupLabel);
  		DeleteClosestFlare(playerid);
    	for(new i; i < MAX_AIRDROPS; i++)
        {
  			LootedLabel = Create3DTextLabel("Military Airdrop\n{db2b42}Looted", 0x33AA33FF, gAirdrop[airdropid][a_pos][0],gAirdrop[i][a_pos][1],gAirdrop[i][a_pos][2], 30.0, 0, 0);
		}
	}
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(killerid != INVALID_PLAYER_ID)
    {
        new Float:pos[3];
        GetPlayerPos(killerid, pos[0], pos[1], pos[2]);

        CreateAirdrop(pos[0], pos[1]);
    }
	new string[250];
    format(string, sizeof(string), "%s(%d) has lost the airdrop", GetName(playerid), playerid);
    for(new k = 0, j = GetPlayerPoolSize(); k <= j; k++)
    {
  		ShowTDN(k, string);
	}
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(onCheck[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        onCheck[playerid] = false;
    }
    return 1;
}

forward OnPlayerTimeUpdate(playerid);
public OnPlayerTimeUpdate(playerid)
{
    if(! IsPlayerInAnyVehicle(playerid))
    {
        for(new i; i < MAX_AIRDROPS; i++)
        {
            if(gAirdrop[i][a_exist])
            {
                if(gAirdrop[i][a_droped])
                {
                    if(IsPlayerInRangeOfPoint(playerid, 5.0, gAirdrop[i][a_pos][0], gAirdrop[i][a_pos][1], gAirdrop[i][a_pos][2]))
                    {
                        GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~g~~h~~h~~h~Press ~h~~k~~CONVERSATION_NO~ ~b~~h~~h~~h~to pick", 1000, 3);
                        break;
                    }
                }
            }
        }
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys == KEY_NO)
    {
        if(! IsPlayerInAnyVehicle(playerid))
        {
            for(new i; i < MAX_AIRDROPS; i++)
            {
                if(gAirdrop[i][a_exist])
                {
                    if(gAirdrop[i][a_droped])
                    {
                        if(IsPlayerInRangeOfPoint(playerid, 5.0, gAirdrop[i][a_pos][0], gAirdrop[i][a_pos][1], gAirdrop[i][a_pos][2]))
                        {
                            ApplyAnimation(playerid, "MISC", "pickup_box", 1.0, 1, 1, 1, 1, 0);
                            GameTextForPlayer(playerid, "~b~~h~~h~~h~Picking...", 2000, 3);

                            KillTimer(gAirdrop[i][a_expire_timer]);
                            gAirdrop[i][a_expire_timer] = SetTimerEx("OnPlayerPickupAirdrop", 2000, false, "ii", playerid, i);
                            gAirdrop[i][a_droped] = false;
                            break;
                        }
                    }
                }
            }
        }
    }
    return 1;
}

GetName(playerid)
{
    new name[24];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(PickupLabel);
	Delete3DTextLabel(LootedLabel);
	DeleteAllFlare();
    for(new i; i < MAX_AIRDROPS; i++)
    {
        gAirdrop[i][a_exist] = false;
        KillTimer(gAirdrop[i][a_expire_timer]);
        if(IsValidObject(gAirdrop[i][a_object]))
        {
            DestroyObject(gAirdrop[i][a_object]);
        }
    }
    return 1;
}
