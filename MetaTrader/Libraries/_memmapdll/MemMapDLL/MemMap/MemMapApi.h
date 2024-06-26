//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|				programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#pragma once

#include "stdafx.h"

#define HEAD_MEM		4 // ������ ��������� �����, ��� �������� ��� �����

//------------------------------------------------------------------	class CMemMapAPI
class CMemMapApi
{
public:
	enum OpenFlags { modeOpen=(int) 0x00000, modeCreate=(int)0x00001 }; // Flag values

public:
	CMemMapApi();
	~CMemMapApi();

public:
	HANDLE Open(LPTSTR path, DWORD size, int mode, DWORD &err); // ��������
	void Close(HANDLE hmem); // ��������
	int Fill(HANDLE h, BYTE b, DWORD &err); // ��������� ������ ��������� ���������
	HANDLE Grows(HANDLE hmem, LPTSTR path, DWORD size, DWORD &err); // �������� ������
	PBYTE	ViewFile(HANDLE hmem, DWORD &err); // �������� �����
	void UnViewFile(PBYTE buf); // ��������� �����
	DWORD GetSize(HANDLE hmem, DWORD &err); // �������� ������
	int SetSize(HANDLE hmem, DWORD size, DWORD &err); // ������������� ������
	int Write(HANDLE hmem, const void *buf, DWORD pos, int sz, DWORD &err); // ������ ������ � ������ � �������� ������� �� ��������� ����� ����
	int Read(HANDLE hmem, void *buf, DWORD pos, int sz, DWORD &err); // ������ ������ �� ������ � �������� ������� �� ��������� ����� ����
	int WriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err); // ������ ������ � ������ � �������� ������� �� ��������� ����� ����
	int ReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err); // ������ ������ �� ������ � �������� ������� �� ��������� ����� ����
};

//------------------------------------------------------------------	class CMemMapFile
class CMemMapFile
{
public:
	enum OpenFlags { modeOpen=(int) 0x00000, modeCreate=(int)0x00001 }; // Flag values

	HANDLE m_hmem; // ����������
	LPTSTR m_path; // ��� � �����
	DWORD m_size; // ����� �����
	DWORD m_pos; // ������� ������� ���������
	int m_mode; // ����� ��������
	PBYTE m_buf; // ��������� �� ����� ������

public:
	CMemMapFile();
	~CMemMapFile();

public:
	int Open(LPTSTR path, DWORD size, int mode); // ��������
	void Close(); // �������� � ����� �������
	int Fill(BYTE b); // ��������� ������ ��������� ���������
	int Seek(DWORD pos, int orig); // ��������� ��������� �� ���� ������
	int Grows(DWORD size); // �������� ������
	int IsEOF() { if (m_pos>=m_size) return(1); return(0); }; // ���������
	DWORD Tell() { return(m_pos); }; // ���������

	int Write(const void *buf, int sz); // ������ � ������ ��������� ����� ����
	int Read(void *buf, int sz); // ������ �� ������ ��������� ����� ����
	int WriteStr(LPCTSTR buf, int sz); // ������ � ������ ������ ��������� ����� ����
	int ReadStr(LPTSTR buf, int &sz); // ������ �� ������ ������ �� ��������� ����� ����
	int WriteStr(const CString *buf, int len); // ������ � ������ ������
	int ReadStr(CString *buf); // ������ �� ������ ������
};