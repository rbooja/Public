//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|       programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+

#pragma once

#include "stdafx.h"
#include "MemMapAPI.h"

//------------------------------------------------------------------	CMemMapFile
CMemMapApi::CMemMapApi()
{
}
//------------------------------------------------------------------	~CMemMapFile
CMemMapApi::~CMemMapApi()
{
}

//------------------------------------------------------------------	Open
HANDLE CMemMapApi::Open(LPTSTR path, DWORD size, int mode, DWORD &err)
{
	err=0;
	if (path==_T("")) return(NULL);
	HANDLE hmem=NULL;
	if (mode==modeCreate) hmem=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, size+HEAD_MEM, path); // ������� ������ ������
	if (mode==modeOpen)		hmem=OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, path); // ��������� ������ ������
	if (hmem==NULL) { err=GetLastError(); return(NULL); }// ���� ������ ��������
	if (mode==modeCreate) // ���� ����� ��������, �� ���������� ������
	{
		//Fill(hmem, 0, err); if (err!=0)  { Close(hmem); return(NULL); } // �������� ������ ���� �������
		DWORD r=SetSize(hmem, size, err); if (r!=0 || err!=0) { Close(hmem); return(NULL); }
	}
	return(hmem);
}
//------------------------------------------------------------------	Close
void CMemMapApi::Close(HANDLE hmem)
{
	if (hmem!=NULL) CloseHandle(hmem); hmem=NULL; // ��������� �����
}
//------------------------------------------------------------------	Fill
int CMemMapApi::Fill(HANDLE hmem, BYTE b, DWORD &err) // ��������� ������ ��������� ���������
{
	if (hmem==NULL) return(0);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // ���� �� ������
	DWORD size=GetSize(hmem, err); if (size<=0 || err!=0) return(-2); // �������� ������
	FillMemory(view, size, b);
	return(size);
}
//------------------------------------------------------------------	Grows
HANDLE CMemMapApi::Grows(HANDLE hmem, LPTSTR path, DWORD newsize, DWORD &err)
{
	if (hmem==NULL) { err=-1; return(0); } // ���� ��������� ��������
	DWORD size=GetSize(hmem, err); if (newsize<=size || err!=0) return(hmem); // ��������� ������
	HANDLE hnew=Open(path, newsize, modeCreate, err); if (hnew==NULL || err!=0) { CloseHandle(hnew); return(0); } // ���� ������ ��������
	CloseHandle(hmem); // ��������� ����������
	return(hnew); // ������� �����
}
//------------------------------------------------------------------	GetSize
DWORD CMemMapApi::GetSize(HANDLE hmem, DWORD &err)
{
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // �������� ��������
	DWORD size, i=0, sz=sizeof(DWORD);
	PBYTE d=(PBYTE)&size; // �������� ��������� �� ������
	for (DWORD i=0; i<sz; i++) d[i]=view[i]; // ������ ������
	UnViewFile(view); // ��������� ��������
	return(size); // ���������� ������
}
//------------------------------------------------------------------	SetSize
int CMemMapApi::SetSize(HANDLE hmem, DWORD size, DWORD &err)
{
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // �������� ��������
	DWORD sz=sizeof(DWORD);
	PBYTE d=(PBYTE)&size; // �������� ��������� �� ������
	for (DWORD i=0; i<sz; i++) view[i]=d[i]; // ���������� ������
	UnViewFile(view); // ��������� ��������
	return(0); // ���������� ��
}

//------------------------------------------------------------------	ViewFile
PBYTE	CMemMapApi::ViewFile(HANDLE hmem, DWORD &err) // �������� �����
{
	err=0;
	if (hmem==NULL) { err=-1; return(NULL); }// ���� �� ������
	PBYTE view=(PBYTE)MapViewOfFile(hmem, FILE_MAP_ALL_ACCESS, 0, 0, 0); // �������� ������������� �����
	if (view==NULL) { err=GetLastError(); return(NULL); } // ���� ������ �������������
	return(view); // ���������� ��������� �� �������� ��������
}
//------------------------------------------------------------------	UnViewFile
void CMemMapApi::UnViewFile(PBYTE view) // ��������� �����
{
	if (view!=NULL) UnmapViewOfFile(view); view=NULL; // ��������� �����
}

//------------------------------------------------------------------	Write
int CMemMapApi::Write(HANDLE hmem, const void *buf, DWORD pos, int sz, DWORD &err) // ������ � ������ ��������� ����� ����
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // ���� �� ������
	DWORD size=GetSize(hmem, err); if (pos+sz>size) { UnViewFile(view); return(-2); }; // ���� ������ ������, �� �������
	PBYTE d=(PBYTE)buf; // ����� ���������
	for(int i=0; i<sz; i++) view[pos+i+HEAD_MEM]=d[i]; // �������� � ������
	UnViewFile(view); // ������� ��������
	return(0); // ������� ��
}
//------------------------------------------------------------------	Read
int CMemMapApi::Read(HANDLE hmem, void *buf, DWORD pos, int sz, DWORD &err) // ������ �� ������ ��������� ����� ����
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // ���� �� ������
	DWORD size=GetSize(hmem, err); // �������� ������
	PBYTE d=(PBYTE)buf; // ���������
	*d=0;
	int i=0; for(i=0; i<sz && pos+i<size; i++) d[i]=view[pos+i+HEAD_MEM]; // ������ �����
	UnViewFile(view); // ������� �������� 
	return(i); // ����� ������������� ����
}
//------------------------------------------------------------------	Write
int CMemMapApi::WriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err) // ������ � ������ ��������� ����� ����
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // ���� �� ������
	DWORD size=GetSize(hmem, err); // ������ �����
	int is=sizeof(int); int ws=sizeof(TCHAR);
	// ����� ������ ������
	PBYTE d=(PBYTE)&sz; // ����� ���������
	int i=0; for(i=0; i<is && pos+i<size; i++) view[pos+i+HEAD_MEM]=d[i]; // ����� �����
	if (i<is) { UnViewFile(view); return(-2); } // ������ �������
	// ����� ���� ������
	pos+=is; // ����������� �� ������ ���� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		d=(PBYTE)&buf[e]; // ���������
		for(i=0; i<ws && pos+e*ws+i<size; i++) 
		{
			view[pos+e*ws+i+HEAD_MEM]=d[i]; // ����� �����
		}
		if (i<ws) { UnViewFile(view); return(-2); } // ������ ������ �������
	}
	UnViewFile(view); // ������� ��������
	return(0); // ������� ��
}
//------------------------------------------------------------------	Read
int CMemMapApi::ReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err) // ������ �� ������ ��������� ����� ����
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // ���� �� ������
	DWORD size=GetSize(hmem, err); // �������� ������
	int is=sizeof(int); int ws=sizeof(TCHAR);
	// ������ ������ ������
	PBYTE d=(PBYTE)&sz; *d=0; // ���������
	int i=0; for(i=0; i<is && pos+i<size; i++) d[i]=view[pos+i+HEAD_MEM]; // ������ �����
	if (i<is) { UnViewFile(view); return(-2); } // ������ ������ �������
	// ������ ���� ������
	pos+=is; // ����������� �� ������ ���� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		d=(PBYTE)&buf[e]; *d=0; // ���������
		for(i=0; i<ws && pos+e*ws+i<size; i++) d[i]=view[pos+e*ws+i+HEAD_MEM]; // ������ �����
		if (i<ws) { UnViewFile(view); return(-2); } // ������ ������ �������
	}
	UnViewFile(view); // ������� ��������
	return(sz); // ����� ������
}