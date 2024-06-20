//+------------------------------------------------------------------+
//|                                              Sample DLL for MQL4 |
//|                 Copyright ｩ 2004-2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#define WIN32_LEAN_AND_MEAN  // Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <ddeml.h>
#include <map>
#include <string>

using namespace std;


HDDEDATA CALLBACK MyDdeProc(UINT, UINT, HCONV, HSZ, HSZ,
							HDDEDATA, DWORD, DWORD);
int MyHotDDEStart(void);
int MyEndHotDDE(void);

HSZ hszService, hszTopic, hszItem;
DWORD ddeInst;
char szClassName[] = "DDEMap";        //ウィンドウ名
map<string, string> TopicItems;  
string server = "";

//----
#define MT4_EXPFUNC __declspec(dllexport)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BOOL APIENTRY DllMain(HANDLE hModule,DWORD ul_reason_for_call,LPVOID lpReserved)
{
	//----
	switch(ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		//MessageBox(NULL, "DLL_PROCESS_ATTACH", "DLL_PROCESS_ATTACH", MB_OK);
		break;
	case DLL_THREAD_ATTACH:
		//MessageBox(NULL, "DLL_THREAD_ATTACH", "DLL_THREAD_ATTACH", MB_OK);
		break;
	case DLL_THREAD_DETACH:
		//MessageBox(NULL, "DLL_THREAD_DETACH", "DLL_THREAD_DETACH", MB_OK);
		break;
	case DLL_PROCESS_DETACH:
		MyEndHotDDE();
		break;
	}
	//----
	return(TRUE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MT4_EXPFUNC int __stdcall SendDDE(char *server_c,char *topic_c,char *item_c,char *value_c)
{
	string topic = topic_c;
	string item = item_c;
	string value = value_c;
	string target = server_c;
	if(server != target){
		if(server !=""){
			string err = target + " is not "+server+"(current running) !";
			MessageBox(NULL, err.c_str(), "SendDDE ERROR", MB_OK|MB_ICONSTOP|MB_TOPMOST);
			return(-1);
		}
		server = target;
		MyHotDDEStart();
	}

	map<string, string>::iterator p;
	p=TopicItems.find(topic+item);
	if(p == TopicItems.end()) TopicItems.insert(pair<string, string>(topic+item, value));

	TopicItems[topic+item] = value;
	HSZ hszTopic;
	HSZ hszItem;
	hszTopic = DdeCreateStringHandle(ddeInst,  topic.c_str(), CP_WINANSI);
	hszItem =  DdeCreateStringHandle(ddeInst,  item.c_str(), CP_WINANSI);
	DdePostAdvise(ddeInst, hszTopic, hszItem );
	DdeFreeStringHandle(ddeInst, hszTopic );
	DdeFreeStringHandle(ddeInst, hszItem );
	return(1);
}
int MyHotDDEStart()
{
	UINT uResult;
	HDDEDATA hData;

	uResult = DdeInitialize(&ddeInst, MyDdeProc, APPCLASS_STANDARD| CBF_SKIP_ALLNOTIFICATIONS, 0);
	if (uResult == DMLERR_NO_ERROR)
		1;//MessageBox(NULL, "DdeInitialize成功", "OK", MB_OK);
	else {
		MessageBox(NULL, "DDE DdeInitialize失敗", "Error", MB_OK);
		return -1;
	}
	hszService = DdeCreateStringHandle(ddeInst, server.c_str(), CP_WINANSI);
	hData = DdeNameService(ddeInst, hszService, 0, DNS_REGISTER);
	if (hData == 0) {
		MessageBox(NULL, "DDE DdeNameService失敗", "Error", MB_OK);
		return -2;
	}

	return 0;
}
int MyEndHotDDE()
{
	HDDEDATA hData;
	BOOL bResult1;

	hData = DdeNameService(ddeInst, hszService, 0, DNS_UNREGISTER);
	if (hData != 0){
		//MessageBox(NULL, "ネームサービス解除成功", "OK", MB_OK);
	}else {
		MessageBox(NULL, "DDE ネームサービス解除失敗", "Error", MB_OK);
		return -1;
	}
	bResult1 = DdeFreeStringHandle(ddeInst, hszService);
	if (bResult1){
		//MessageBox(NULL, "ストリングハンドル開放成功", "OK", MB_OK);
	}else {
		MessageBox(NULL, "DDE ストリングハンドル開放失敗", "Error", MB_OK);
		return -2;
	}
	if (DdeUninitialize(ddeInst)) {
		//MessageBox(NULL, "DdeUninitialize成功", "OK", MB_OK);//NG
		return 0;
	} else {
		MessageBox(NULL, "DDE DdeUninitialize失敗", "Error", MB_OK);
		return -3;
	}
}
HDDEDATA CALLBACK MyDdeProc(UINT uType, UINT uFmt, HCONV hcconv, HSZ hszTpc1, HSZ hszTpc2,
							HDDEDATA hdata, DWORD dwData1, DWORD dwData2)
{	//hszTpc2:サービス名 hszTpc1:トピック名
	char szBuffer[256];
	HDDEDATA hData;

	switch (uType) {
case XTYP_CONNECT:
	//MessageBox(NULL, "DDE サーバに接続しました", szClassName, MB_OK);
	return (HDDEDATA)TRUE;
case XTYP_ADVSTART:
	if ( uFmt == CF_TEXT )
	{
		//MessageBox(NULL, "DDE アドバイズループが開始されました。", szClassName, MB_OK);
		return (HDDEDATA)TRUE;
	}else{
		return (HDDEDATA)FALSE;
	}
case XTYP_REQUEST:
case XTYP_ADVREQ:
	{
		DdeQueryString(ddeInst, hszTpc2, szBuffer, sizeof(szBuffer), CP_WINANSI);
		string item = szBuffer;
		DdeQueryString(ddeInst, hszTpc1, szBuffer, sizeof(szBuffer), CP_WINANSI);
		string topic = szBuffer;	

		map<string, string>::iterator p;
		p=TopicItems.find(topic+item); 
		if(p == TopicItems.end()) 
		{
			return (HDDEDATA)FALSE;		
		}
		wsprintf(szBuffer, "%s",  TopicItems[topic+item].c_str());
		hData = DdeCreateDataHandle(ddeInst, (LPBYTE)szBuffer, strlen(szBuffer) + 1, 0,
			hszTpc2, uFmt, 0);
		//MessageBox(NULL, TopicItems[a+b].c_str(), szClassName, MB_OK);
		return hData;
	}
case XTYP_ADVSTOP:
	//MessageBox(NULL, "DDE アドバイズループ終了", szClassName, MB_OK);
	return (HDDEDATA)TRUE;
default:  
	MessageBox(NULL,  "", szClassName, MB_OK);
	}
	return (HDDEDATA)FALSE;
}