//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|       programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+

// MemMap.cpp: определ€ет процедуры инициализации дл€ DLL.
//

#include "stdafx.h"
#include "MemMap.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//		extern "C" BOOL PASCAL EXPORT ExportedFunction()
//		{
//			AFX_MANAGE_STATE(AfxGetStaticModuleState());
//			// тело нормальной функции
//		}
			
// CMemMapApp
//------------------------------------------------------------------	BEGIN_MESSAGE_MAP
BEGIN_MESSAGE_MAP(CMemMapApp, CWinApp)
END_MESSAGE_MAP()

// создание CMemMapApp
//------------------------------------------------------------------	CMemMapApp
CMemMapApp::CMemMapApp()
{
	// TODO: добавьте код создани€,
	// –азмещает весь важный код инициализации в InitInstance
}

CMemMapApp theApp; // ≈динственный объект CMemMapApp

// инициализаци€ CMemMapApp
//------------------------------------------------------------------	InitInstance
BOOL CMemMapApp::InitInstance()
{
	CWinApp::InitInstance();
	return TRUE;
}

CMemMapApi mem; // API дл€ работы с пам€тью

//------------------------------------------------------------------	MemOpen
EXT HANDLE __stdcall MemOpen(LPTSTR path, DWORD size, int mode, DWORD &err) // открытие/создание пам€ти
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Open(path, size, mode, err));
}
//------------------------------------------------------------------	MemClose
EXT void __stdcall MemClose(HANDLE hmem) // закрытие и сброс хендлов пам€ти
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	mem.Close(hmem);
}
//------------------------------------------------------------------	MemGrows
EXT HANDLE __stdcall MemGrows(HANDLE hmem, LPTSTR path, DWORD size, DWORD &err) // увеличить выделенный размер пам€ти
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Grows(hmem, path, size, err));
}
//------------------------------------------------------------------	MemGetSize
EXT DWORD __stdcall MemGetSize(HANDLE hmem, DWORD &err) // размер
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.GetSize(hmem, err));
}
//------------------------------------------------------------------	MemSetSize
EXT int __stdcall MemSetSize(HANDLE hmem, DWORD size, DWORD &err) // размер
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.SetSize(hmem, size, err));
}

//------------------------------------------------------------------	MemWrite
EXT int __stdcall MemWrite(HANDLE hmem, const void *v, DWORD pos, int sz, DWORD &err) // запись в пам€ть указанное число байт
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Write(hmem, v, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemRead
EXT int __stdcall MemRead(HANDLE hmem, void *v, DWORD pos, int sz, DWORD &err) // чтение из пам€ти указанное число байт
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Read(hmem, v, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemWriteStr
EXT int __stdcall MemWriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err) // запись данных в пам€ть с указаной позиции на указанное число байт
{	
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.WriteStr(hmem, buf, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemReadStr
EXT int __stdcall MemReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err) // чтение данных из пам€ти с указаной позиции на указанное число байт
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.ReadStr(hmem, buf, pos, sz, err)); // 
}
