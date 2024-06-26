//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|				programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+

// MemMap.h: ������� ���� ��������� ��� DLL MemMap
//

#pragma once

#ifndef __AFXWIN_H__
	#error "�������� stdafx.h �� ��������� ����� ����� � PCH"
#endif

#include "resource.h"		// �������� �������
#include "MemMapAPI.h"

#define EXT extern "C" __declspec(dllexport)

// CMemMapApp
// ��� ���������� ������� ������ ��. MemMap.cpp
//

class CMemMapApp : public CWinApp
{
public:
	CMemMapApp();

// ���������������
public:
	virtual BOOL InitInstance();

	DECLARE_MESSAGE_MAP()
};
