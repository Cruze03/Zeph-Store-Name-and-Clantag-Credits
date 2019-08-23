#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <store>
#include <multicolors>

ConVar gc_sTag;
char g_sTag[32];

char DomainName[512];
char ClanTagName[512];

ConVar  g_bEnableNameCredits,
		g_bEnableClanTagCredits,
		g_sDomainName,
		g_sClanTagName,
		g_fIntervalName,
		g_fIntervalTag,
		g_iAmountForName,
		g_iAmountForTag;

bool NameBool, ClantagBool;

public Plugin myinfo =
{
	name = "[Store] Name and ClanTag Credits",
	author = "Cruze",
	description = "Give Extra Credits to those who have X in their name and or Y in their clantag",
	version = "1.1.2",
	url = ""
};
public void OnPluginStart()
{
	g_bEnableNameCredits		=	CreateConVar("sm_nc_enablenamecreds", 		"1", 		"Enable/Disable name credits");
	g_bEnableClanTagCredits		=	CreateConVar("sm_nc_enableclantagcreds", 	"1", 		"Enable/Disable clantag credits");
	g_sDomainName				=	CreateConVar("sm_nc_domainname", 			"♚", 		"Put your domain name here.");
	g_sClanTagName				=	CreateConVar("sm_nc_clantagname", 			"SM", 		"Put your clantag here.");
	g_fIntervalName				=	CreateConVar("sm_nc_intervalname", 			"300.0", 	"Interval between giving credits for name.");
	g_fIntervalTag				=	CreateConVar("sm_nc_intervaltag", 			"600.0", 	"Interval between giving credits for clantag.");
	g_iAmountForName			=	CreateConVar("sm_nc_amountname", 			"100", 		"Amount of credits to give to users having 'yourdomainname' in their name.");
	g_iAmountForTag				=	CreateConVar("sm_nc_amounttag", 			"100", 		"Amount of credits to give to users having 'yourtag' in their name.");
	
	AutoExecConfig(true, "cruze_NameandClantagCredits");
}

public void OnMapStart()
{
	gc_sTag = FindConVar("sm_store_chat_tag");
	gc_sTag.GetString(g_sTag, sizeof(g_sTag));
	
	NameBool = g_bEnableNameCredits.BoolValue;
	ClantagBool = g_bEnableClanTagCredits.BoolValue;
	g_sDomainName.GetString(DomainName, sizeof(DomainName));
	g_sClanTagName.GetString(ClanTagName, sizeof(ClanTagName));
	
	CreateTimer(g_fIntervalName.FloatValue, GiveCreditsForName, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(g_fIntervalTag.FloatValue, GiveCreditsForTag, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action GiveCreditsForName(Handle timer)
{
	if(!NameBool)
		return;

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			char playerName[32];
			GetClientName(client, playerName, 32);
			if(StrContains(playerName, DomainName, false) != -1)
			{
				Store_SetClientCredits(client, Store_GetClientCredits(client) + g_iAmountForName.IntValue);
				CPrintToChat(client, "%s You got {green}%i{default} credits for putting {red}%s{default} in your name! Thank you!", g_sTag, g_iAmountForName.IntValue, DomainName);
			}
			else
			{
				int g_Interval = RoundToZero(GetConVarFloat(g_fIntervalName));
				CPrintToChat(client, "%s Put '{lightred}%s{default}' in your name to get {green}%i{default} credits every %d seconds.", g_sTag, DomainName, g_iAmountForName.IntValue, g_Interval);
			}
		}
	}
}
public Action GiveCreditsForTag(Handle timer)
{
	if(!ClantagBool)
		return;

	for(int client = 1; client <= MaxClients; client++)
	{	
		if(IsValidClient(client))
		{
			char clanTag[16];
			CS_GetClientClanTag(client, clanTag, 16);
			if(StrEqual(clanTag, ClanTagName, false))
			{
				Store_SetClientCredits(client, Store_GetClientCredits(client) + g_iAmountForTag.IntValue);
				CPrintToChat(client, "%s You got {green}%i{default} credits for putting {red}%s{default} as your clantag! Thank you!", g_sTag, g_iAmountForTag.IntValue, ClanTagName);
			}
			else
			{
				int g_Interval = RoundToZero(GetConVarFloat(g_fIntervalTag));
				CPrintToChat(client, "%s Put '{lightred}%s{default}' in your clantag to get {green}%i{default} credits every %d seconds.", g_sTag, ClanTagName, g_iAmountForTag.IntValue, g_Interval);
			}
		}
	}
}
	
stock bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients)
		return false;
	if (!IsClientConnected(client))
		return false;
	if (IsFakeClient(client))
		return false;
	return IsClientInGame(client);
}