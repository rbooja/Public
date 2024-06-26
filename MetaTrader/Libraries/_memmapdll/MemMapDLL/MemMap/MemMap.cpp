//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|       programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+

// MemMap.cpp: ���������� ��������� ������������� ��� DLL.
//

#include "stdafx.h"
#include "MemMap.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//		extern "C" BOOL PASCAL EXPORT ExportedFunction()
//		{
//			AFX_MANAGE_STATE(AfxGetStaticModuleState());
//			// ���� ���������� �������
//		}
			
// CMemMapApp
//------------------------------------------------------------------	BEGIN_MESSAGE_MAP
BEGIN_MESSAGE_MAP(CMemMapApp, CWinApp)
END_MESSAGE_MAP()

// �������� CMemMapApp
//------------------------------------------------------------------	CMemMapApp
CMemMapApp::CMemMapApp()
{
	// TODO: �������� ��� ��������,
	// ��������� ���� ������ ��� ������������� � InitInstance
}

CMemMapApp theApp; // ������������ ������ CMemMapApp

// ������������� CMemMapApp
//------------------------------------------------------------------	InitInstance
BOOL CMemMapApp::InitInstance()
{
	CWinApp::InitInstance();
	return TRUE;
}

CMemMapApi mem; // API ��� ������ � �������

//------------------------------------------------------------------	MemOpen
EXT HANDLE __stdcall MemOpen(LPTSTR path, DWORD size, int mode, DWORD &err) // ��������/�������� ������
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Open(path, size, mode, err));
}
//------------------------------------------------------------------	MemClose
EXT void __stdcall MemClose(HANDLE hmem) // �������� � ����� ������� ������
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	mem.Close(hmem);
}
//------------------------------------------------------------------	MemGrows
EXT HANDLE __stdcall MemGrows(HANDLE hmem, LPTSTR path, DWORD size, DWORD &err) // ��������� ���������� ������ ������
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Grows(hmem, path, size, err));
}
//------------------------------------------------------------------	MemGetSize
EXT DWORD __stdcall MemGetSize(HANDLE hmem, DWORD &err) // ������
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.GetSize(hmem, err));
}
//------------------------------------------------------------------	MemSetSize
EXT int __stdcall MemSetSize(HANDLE hmem, DWORD size, DWORD &err) // ������
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.SetSize(hmem, size, err));
}

//------------------------------------------------------------------	MemWrite
EXT int __stdcall MemWrite(HANDLE hmem, const void *v, DWORD pos, int sz, DWORD &err) // ������ � ������ ��������� ����� ����
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Write(hmem, v, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemRead
EXT int __stdcall MemRead(HANDLE hmem, void *v, DWORD pos, int sz, DWORD &err) // ������ �� ������ ��������� ����� ����
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.Read(hmem, v, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemWriteStr
EXT int __stdcall MemWriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err) // ������ ������ � ������ � �������� ������� �� ��������� ����� ����
{	
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.WriteStr(hmem, buf, pos, sz, err)); // 
}
//------------------------------------------------------------------	MemReadStr
EXT int __stdcall MemReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err) // ������ ������ �� ������ � �������� ������� �� ��������� ����� ����
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	return(mem.ReadStr(hmem, buf, pos, sz, err)); // 
}
