//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|				programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#pragma once

#include "stdafx.h"
#include "MemMapAPI.h"

//------------------------------------------------------------------	CMemMapFile
CMemMapFile::CMemMapFile()
{
	m_path=_T(""); m_hmem=NULL; m_size=0; m_pos=0; m_mode=-1;
}
//------------------------------------------------------------------	~CMemMapFile
CMemMapFile::~CMemMapFile()
{
	Close();
}

//------------------------------------------------------------------	Create
int CMemMapFile::Open(LPTSTR path, DWORD size, int mode=modeOpen)
{
	m_size=size; m_path=path; m_mode=mode;
	if (m_path==_T("")) return(-1);
	if (m_mode==modeCreate) m_hmem=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, m_size+HEAD_MEM, m_path); // ������� ������ ������
	if (m_mode==modeOpen)		m_hmem=OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, m_path); // ��������� ������ ������
	if (m_hmem==NULL) return(GetLastError()); // ���� ������ ��������

	m_buf=(PBYTE)MapViewOfFile(m_hmem, FILE_MAP_ALL_ACCESS, 0, 0, 0); // �������� ������������� �����
	if (m_buf==NULL) { int err=GetLastError(); Close(); return(err); } // ���� ������ �������������

	if (m_mode==modeCreate) FillMemory(m_buf, m_size, 0); // �������� ������ ���� �������
	m_pos=0; // ��������� ���������
	// ������ �����
	PBYTE d=(PBYTE)&m_size;
	if (m_mode==modeCreate) for(int i=0; i<sizeof(DWORD); i++) m_buf[i]=d[i];
	if (m_mode==modeOpen) for(int i=0; i<sizeof(DWORD); i++) d[i]=m_buf[i];
	return(0);
}
//------------------------------------------------------------------	Close
void CMemMapFile::Close()
{
	if (m_buf!=NULL) UnmapViewOfFile(m_buf); m_buf=NULL; // ��������� �����
	if (m_hmem!=NULL) CloseHandle(m_hmem); m_hmem=NULL; // ��������� �����
}
//------------------------------------------------------------------	Fill
int CMemMapFile::Fill(BYTE b) // ��������� ������ ��������� ���������
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	FillMemory(m_buf, m_size, b);
	return(m_size);
}
//------------------------------------------------------------------	Grows
int CMemMapFile::Grows(DWORD size)
{
	if (m_hmem==NULL) return(-1);
	if (m_path==_T("") || size<=0) return(-1);
	if (size<=m_size) return(0);
	m_size=size;
	HANDLE hnew=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, m_size+HEAD_MEM, m_path); // ������� ������ ������
	if (hnew==NULL) return(GetLastError()); // ���� ������ ��������
	HANDLE h=m_hmem; m_hmem=hnew; hnew=h;
	CloseHandle(h); // ��������� ����������
	// �������� ������ �����
	PBYTE d=(PBYTE)&m_size; for(int i=0; i<sizeof(DWORD); i++) m_buf[i]=d[i];
	return(0);
}
//------------------------------------------------------------------	Seek
int CMemMapFile::Seek(DWORD pos, int seek=SEEK_SET) // ��������� ��������� �� ���� ������
{
	if (seek==SEEK_SET) m_pos=pos;
	if (seek==SEEK_CUR) m_pos+=pos;
	if (seek==SEEK_END) m_pos=m_size-pos;
	// ���������
	m_pos<0?0:m_pos;
	m_pos>m_size?m_size:m_pos;
	return(0);
}
//------------------------------------------------------------------	Write
int CMemMapFile::Write(const void *buf, int sz) // ������ � ������ ��������� ����� ����
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	if (m_pos+sz>m_size) if (Grows(m_pos+sz)!=0) return(-2);
	PBYTE d=(PBYTE)buf; // �������� ����-�����
	int i=0; for(i=0; i<sz && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i];
	m_pos+=i; // ��������� ���������
	return(0);
}
//------------------------------------------------------------------	Read
int CMemMapFile::Read(void *buf, int sz) // ������ �� ������ ��������� ����� ����
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	PBYTE d=(PBYTE)buf; // �������� ����-�����
	*d=0;
	int i=0; for(i=0; i<sz && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM];
	long *l1=(long*)d;
	long *l2=(long*)d;
	m_pos+=i; // ��������� ���������
	return(i);
}
//------------------------------------------------------------------	WriteStr
int CMemMapFile::WriteStr(LPCTSTR buf, int sz) // ������ � ������ ������
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	int is=sizeof(int); int ws=sizeof(wchar_t);
	if (m_pos+is+sz*ws>m_size) if (Grows(m_pos+is+sz*ws)!=0) return(-2); // ��������� ������ ������
	// ����� ������ ������
	PBYTE d=(PBYTE)&sz; // ����� ���������
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i]; // ����� �����
	// ����� ���� ������
	m_pos+=is; // ����������� �� ������ ���� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		d=(PBYTE)buf[e]; // ��������� �� ������� ������
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) m_buf[m_pos+e*ws+i+HEAD_MEM]=d[i]; // ����� �����
	}
	return(0); // ������� ��
}
//------------------------------------------------------------------	Readstr
int CMemMapFile::ReadStr(LPTSTR buf, int &sz) // ������ �� ������ ������
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	int is=sizeof(int); int ws=sizeof(wchar_t);
	// ������ ������ ������
	PBYTE d=(PBYTE)&sz; *d=0; // ���������
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM]; // ������ �����
	if (i<is) return(-2); // ������ ������ �������
	// ������ ���� ������
	m_pos+=is; // ����������� �� ������ ���� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		d=(PBYTE)buf[e]; *d=0; // ���������
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) d[i]=m_buf[m_pos+e*ws+i+HEAD_MEM]; // ������ �����
		if (i<ws) return(-2); // ������ ������ �������
	}
	return(sz); // ����� ������
}
//------------------------------------------------------------------	WriteStr
int CMemMapFile::WriteStr(const CString *buf, int len) // ������ � ������ ������
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	int sz=buf->GetLength(); sz=sz>len?len:sz; // ���� �����������
	int is=sizeof(int); int ws=sizeof(wchar_t);
	if (m_pos+is+sz*ws>m_size) if (Grows(m_pos+is+sz*ws)!=0) return(-2); // ��������� ������ ������
	// ����� ������ ������
	PBYTE d=(PBYTE)&sz; // ����� ���������
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i]; // ����� �����
	// ����� ���� ������
	m_pos+=is; // ����������� �� ������ ���� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		wchar_t ch=buf->GetAt(e);
		d=(PBYTE)&ch; // ��������� �� ������� ������
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) m_buf[m_pos+e*ws+i+HEAD_MEM]=d[i]; // ����� �����
	}
	return(0); // ������� ��
}
//------------------------------------------------------------------	Readstr
int CMemMapFile::ReadStr(CString *buf) // ������ �� ������ ������
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // ���� �� ������
	int is=sizeof(int); int ws=sizeof(wchar_t);
	// ������ ������ ������
	int sz=0; PBYTE d=(PBYTE)&sz; *d=0; // ���������
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM]; // ������ �����
	if (i<is) return(-2); // ������ ������ �������
	// ������ ���� ������
	m_pos+=is; // ����������� �� ������ ���� ������
	buf->SetString(_T("")); // �������� ������
	for (int e=0; e<sz; e++) // ��������� �������
	{
		wchar_t ch=0; 
		d=(PBYTE)&ch; *d=0; // ���������
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) d[i]=m_buf[m_pos+e*ws+i+HEAD_MEM]; // ������ �����
		if (i<ws) return(-2); // ������ ������ �������
		buf->Insert(e, ch); // 
	}
	return(sz); // ����� ������
}