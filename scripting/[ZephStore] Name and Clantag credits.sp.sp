#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <store>
#include <colorvariables>

ConVar gc_sTag;
char g_sTag[32];

char DomainName[512];
char ClanTagName[512];

Handle  nc_EnableNameCredits,
		nc_EnableClanTagCredits,
		nc_DomainName,
		nc_ClanTagName,
		nc_IntervalName,
		nc_IntervalTag;

ConVar nc_AmountForName, nc_AmountForTag;

public Plugin myinfo =
{
	name = "[Store] Name and ClanTag Credits",
	author = "Cruze",
	description = "Give Extra Credits to those who have X in their name",
	version = "1.0",
	url = ""
};
public void OnPluginStart()
{
	nc_EnableNameCredits		=	CreateConVar("nc_enablenamecreds", 		"1", 		"Enable/Disable name credits");
	nc_EnableClanTagCredits	=	CreateConVar("nc_enableclantagcreds", 	"1", 		"Enable/Disable clantag credits");
	nc_DomainName				=	CreateConVar("nc_domainname", 			"♚", 		"Put your domain name here.");
	nc_ClanTagName				=	CreateConVar("nc_clantagname", 			"SM", 		"Put your clantag here.");
	nc_IntervalName				=	CreateConVar("nc_intervalname", 			"300.0", 	"Interval between giving credits for name.");
	nc_IntervalTag				=	CreateConVar("nc_intervaltag", 			"600.0", 	"Interval between giving credits for clantag.");
	nc_AmountForName			=	CreateConVar("nc_amountname", 			"100", 		"Amount of credits to give to users having 'yourdomainname' in their name.");
	nc_AmountForTag				=	CreateConVar("nc_amounttag", 			"100", 		"Amount of credits to give to users having 'yourtag' in their name.");
	
	AutoExecConfig(true, "cruze_NameandClantagCredits");
}

public OnConfigsExecuted()
{
	gc_sTag = FindConVar("sm_store_chat_tag");
	gc_sTag.GetString(g_sTag, sizeof(g_sTag));
	
	CreateTimer(GetConVarFloat(nc_IntervalName), GiveCreditsForName, _, TIMER_REPEAT);
	CreateTimer(GetConVarFloat(nc_IntervalTag), GiveCreditsForTag, _, TIMER_REPEAT);
}

public Action GiveCreditsForName(Handle timer)
{
	if(GetConVarBool(nc_EnableNameCredits))
	{
		GetConVarString(nc_DomainName, DomainName, sizeof(DomainName));
	
		int g_Interval = RoundToZero(GetConVarFloat(nc_IntervalName));

		for(int client = 1; client < MaxClients; client++) if (IsValidClient(client, true, true))
		{
			char playerName[64];
			GetClientName(client, playerName, 64);

			if(StrContains(playerName, DomainName, false) != -1)
			{
				Store_SetClientCredits(client, Store_GetClientCredits(client) + nc_AmountForName.IntValue);
				CPrintToChat(client, "%s You got {green}%i{default} credits for putting {red}%s{default} in your name! Thank you!", g_sTag, nc_AmountForName.IntValue, DomainName);
			}
			else
			{
				CPrintToChat(client, "%s Put '{red}%s{default}' in your name to get {green}%i{default} credits every %d seconds.", g_sTag, DomainName, nc_AmountForName.IntValue, g_Interval);
			}
		}
	}
}
public Action GiveCreditsForTag(Handle timer)
{
	if(GetConVarBool(nc_EnableClanTagCredits))
	{
		GetConVarString(nc_ClanTagName, ClanTagName, sizeof(ClanTagName));
	
		int g_Interval = RoundToZero(GetConVarFloat(nc_IntervalTag));
	
		for(int client = 1; client < MaxClients; client++) if (IsValidClient(client, true, true))
		{
			char clanTag[64];
			CS_GetClientClanTag(client, clanTag, 64);
		
			if(StrContains(clanTag, ClanTagName, false) != -1)
			{
				Store_SetClientCredits(client, Store_GetClientCredits(client) + nc_AmountForTag.IntValue);
				CPrintToChat(client, "%s You got {green}%i{default} credits for putting {red}%s{default} as your clantag! Thank you!", g_sTag, nc_AmountForTag.IntValue, ClanTagName);
			}
			else
			{
				CPrintToChat(client, "%s Put '{red}%s{default}' in your clantag to get {green}%i{default} credits every %d seconds.", g_sTag, ClanTagName, nc_AmountForTag.IntValue, g_Interval);
			}
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