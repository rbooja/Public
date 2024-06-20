//+------------------------------------------------------------------+
//|                                              Sample DLL for MQL4 |
//|                 Copyright © 2004-2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#define WIN32_LEAN_AND_MEAN  // Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <queue>
#include <map>
using namespace std;
queue<HANDLE> q;
map<string, string> itms;
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
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		while(!q.empty()){
			HANDLE hMap;
			hMap = q.front();
			CloseHandle(hMap);
			q.pop();
		}
		break;
	}
	//----
	return(TRUE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MT4_EXPFUNC const char* __stdcall GetMemString(char *tag)
{
	/*static*/ string ret = "";
	HANDLE  hMap = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, tag);
	if (!hMap) { return(ret.c_str());}
	LPSTR lpMapAddress2 = (LPSTR)MapViewOfFile(hMap,
		FILE_MAP_ALL_ACCESS, 0, 0, 0);
	ret = lpMapAddress2;
	UnmapViewOfFile(lpMapAddress2);
	CloseHandle(hMap);
	string key = tag;
	itms[key] = ret;
	return(itms[key].c_str());
}
MT4_EXPFUNC const char* __stdcall SetMemString(char *tag,char *msg)
{
	/*static*/ string ret = "";
	bool create = false;
	HANDLE hMap = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, tag);
	if (!hMap) {	
		hMap= CreateFileMapping((HANDLE)0xFFFFFFFF , NULL ,
			PAGE_READWRITE , 0 , 1024 , tag);
		q.push(hMap);
		create = true;
	}
	LPSTR strAllCmd =(LPSTR)MapViewOfFile(hMap , FILE_MAP_WRITE , 0 , 0 , 0);
	lstrcpy(strAllCmd , msg);
	FlushViewOfFile(strAllCmd,0);
	UnmapViewOfFile(strAllCmd);
	if(!create) CloseHandle(hMap);
	return(ret.c_str());
}