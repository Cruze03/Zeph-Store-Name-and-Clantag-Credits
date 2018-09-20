#pragma semicolon 1

#include <sourcemod>
#include <store>
#include <colorvariables>

ConVar gc_sTag;
char g_sTag[32];
char DomainName[512];

Handle nc_DomainName;
Handle nc_Interval;
ConVar nc_Amount;

public Plugin myinfo =
{
	name = "[Store] Name Credits",
	author = "Cruze",
	description = "Give Extra Credits to those who have X in their name",
	version = "1.0",
	url = ""
};
public void OnPluginStart()
{
	nc_DomainName	=	CreateConVar("nc_domainname", "♚", "Your domain name here");
	nc_Interval	=	CreateConVar("nc_interval", "300.0", "Interval between giving credits.");
	nc_Amount	=	CreateConVar("nc_amount", "100", "Amount of credits to give to users having 'yourdomainname' in their name");
	
	AutoExecConfig(true, "cruze_NameCredits");
}

public OnConfigsExecuted()
{
	gc_sTag = FindConVar("sm_store_chat_tag");
	gc_sTag.GetString(g_sTag, sizeof(g_sTag));
	
	CreateTimer(GetConVarFloat(nc_Interval), GiveCredits, _, TIMER_REPEAT);
}

public Action GiveCredits(Handle timer)
{
	GetConVarString(nc_DomainName, DomainName, sizeof(DomainName));
	int g_Interval = RoundToZero(GetConVarFloat(nc_Interval));

	for(int client = 1; client < MaxClients; client++) if (IsValidClient(client, true, true))
	{
		char playerName[64];
		GetClientName(client, playerName, 64);
		if(StrContains(playerName, DomainName, false) != -1)
		{
			Store_SetClientCredits(client, Store_GetClientCredits(client) + nc_Amount.IntValue);
			CPrintToChat(client, "%s You got {green}%i{default} credits for putting {red}%s{default} in your name! Thank you!", g_sTag, nc_Amount.IntValue, DomainName);
		}
		else
		{
			CPrintToChat(client, "%s Put '{red}%s{default}' in your name to get {green}%i{default} credits every %d seconds.", g_sTag, DomainName, nc_Amount.IntValue, g_Interval);
		}
	}
}
bool IsValidClient(client, bool bAllowBots = true, bool bAllowDead = true)
{
    if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
    {
        return false;
    }
    return true;
}