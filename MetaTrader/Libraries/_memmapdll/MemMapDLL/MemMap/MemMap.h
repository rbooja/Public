//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|				programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+

// MemMap.h: главный файл заголовка для DLL MemMap
//

#pragma once

#ifndef __AFXWIN_H__
	#error "включить stdafx.h до включения этого файла в PCH"
#endif

#include "resource.h"		// основные символы
#include "MemMapAPI.h"

#define EXT extern "C" __declspec(dllexport)

// CMemMapApp
// Про реализацию данного класса см. MemMap.cpp
//

class CMemMapApp : public CWinApp
{
public:
	CMemMapApp();

// Переопределение
public:
	virtual BOOL InitInstance();

	DECLARE_MESSAGE_MAP()
};
