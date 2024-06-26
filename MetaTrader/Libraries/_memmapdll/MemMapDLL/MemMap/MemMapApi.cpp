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
	if (mode==modeCreate) hmem=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, size+HEAD_MEM, path); // создаем объект памяти
	if (mode==modeOpen)		hmem=OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, path); // открываем объект памяти
	if (hmem==NULL) { err=GetLastError(); return(NULL); }// если ошибка создания
	if (mode==modeCreate) // если режим создания, то записываем размер
	{
		//Fill(hmem, 0, err); if (err!=0)  { Close(hmem); return(NULL); } // обнулили память если создаем
		DWORD r=SetSize(hmem, size, err); if (r!=0 || err!=0) { Close(hmem); return(NULL); }
	}
	return(hmem);
}
//------------------------------------------------------------------	Close
void CMemMapApi::Close(HANDLE hmem)
{
	if (hmem!=NULL) CloseHandle(hmem); hmem=NULL; // закрываем хендл
}
//------------------------------------------------------------------	Fill
int CMemMapApi::Fill(HANDLE hmem, BYTE b, DWORD &err) // заполнить память указанным значением
{
	if (hmem==NULL) return(0);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // если не открыт
	DWORD size=GetSize(hmem, err); if (size<=0 || err!=0) return(-2); // получили размер
	FillMemory(view, size, b);
	return(size);
}
//------------------------------------------------------------------	Grows
HANDLE CMemMapApi::Grows(HANDLE hmem, LPTSTR path, DWORD newsize, DWORD &err)
{
	if (hmem==NULL) { err=-1; return(0); } // если указатель неверный
	DWORD size=GetSize(hmem, err); if (newsize<=size || err!=0) return(hmem); // проверили размер
	HANDLE hnew=Open(path, newsize, modeCreate, err); if (hnew==NULL || err!=0) { CloseHandle(hnew); return(0); } // если ошибка создания
	CloseHandle(hmem); // закрываем предыдущий
	return(hnew); // вернули новый
}
//------------------------------------------------------------------	GetSize
DWORD CMemMapApi::GetSize(HANDLE hmem, DWORD &err)
{
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // получаем просмотр
	DWORD size, i=0, sz=sizeof(DWORD);
	PBYTE d=(PBYTE)&size; // байтовый указатель на размер
	for (DWORD i=0; i<sz; i++) d[i]=view[i]; // читаем размер
	UnViewFile(view); // закрываем просмотр
	return(size); // возвращаем размер
}
//------------------------------------------------------------------	SetSize
int CMemMapApi::SetSize(HANDLE hmem, DWORD size, DWORD &err)
{
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // получаем просмотр
	DWORD sz=sizeof(DWORD);
	PBYTE d=(PBYTE)&size; // байтовый указатель на размер
	for (DWORD i=0; i<sz; i++) view[i]=d[i]; // записываем размер
	UnViewFile(view); // закрываем просмотр
	return(0); // возвращаем ОК
}

//------------------------------------------------------------------	ViewFile
PBYTE	CMemMapApi::ViewFile(HANDLE hmem, DWORD &err) // получаем буфер
{
	err=0;
	if (hmem==NULL) { err=-1; return(NULL); }// если не открыт
	PBYTE view=(PBYTE)MapViewOfFile(hmem, FILE_MAP_ALL_ACCESS, 0, 0, 0); // получили представление файла
	if (view==NULL) { err=GetLastError(); return(NULL); } // если ошибка представления
	return(view); // возвращаем указатель на байтовый просмотр
}
//------------------------------------------------------------------	UnViewFile
void CMemMapApi::UnViewFile(PBYTE view) // закрываем буфер
{
	if (view!=NULL) UnmapViewOfFile(view); view=NULL; // закрываем хендл
}

//------------------------------------------------------------------	Write
int CMemMapApi::Write(HANDLE hmem, const void *buf, DWORD pos, int sz, DWORD &err) // запись в память указанное число байт
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // если не открыт
	DWORD size=GetSize(hmem, err); if (pos+sz>size) { UnViewFile(view); return(-2); }; // если размер меньше, то выходим
	PBYTE d=(PBYTE)buf; // взяли байтбуфер
	for(int i=0; i<sz; i++) view[pos+i+HEAD_MEM]=d[i]; // записали в память
	UnViewFile(view); // закрыли просмотр
	return(0); // вернули ОК
}
//------------------------------------------------------------------	Read
int CMemMapApi::Read(HANDLE hmem, void *buf, DWORD pos, int sz, DWORD &err) // чтение из памяти указанное число байт
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // если не открыт
	DWORD size=GetSize(hmem, err); // получили размер
	PBYTE d=(PBYTE)buf; // байтбуфер
	*d=0;
	int i=0; for(i=0; i<sz && pos+i<size; i++) d[i]=view[pos+i+HEAD_MEM]; // читаем байты
	UnViewFile(view); // закрыли просмотр 
	return(i); // число скопированных байт
}
//------------------------------------------------------------------	Write
int CMemMapApi::WriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err) // запись в память указанное число байт
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // если не открыт
	DWORD size=GetSize(hmem, err); // размер файла
	int is=sizeof(int); int ws=sizeof(TCHAR);
	// пишем размер строки
	PBYTE d=(PBYTE)&sz; // взяли байтбуфер
	int i=0; for(i=0; i<is && pos+i<size; i++) view[pos+i+HEAD_MEM]=d[i]; // пишем байты
	if (i<is) { UnViewFile(view); return(-2); } // ошибка размера
	// пишем саму строку
	pos+=is; // подвинулись на первый байт строки
	for (int e=0; e<sz; e++) // прочитали символы
	{
		d=(PBYTE)&buf[e]; // байтбуфер
		for(i=0; i<ws && pos+e*ws+i<size; i++) 
		{
			view[pos+e*ws+i+HEAD_MEM]=d[i]; // пишем байты
		}
		if (i<ws) { UnViewFile(view); return(-2); } // ошибка чтения размера
	}
	UnViewFile(view); // закрыли просмотр
	return(0); // вернули ОК
}
//------------------------------------------------------------------	Read
int CMemMapApi::ReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err) // чтение из памяти указанное число байт
{
	if (hmem==NULL) return(-1);
	PBYTE view=ViewFile(hmem, err); if (view==0 || err!=0) return(-1); // если не открыт
	DWORD size=GetSize(hmem, err); // получили размер
	int is=sizeof(int); int ws=sizeof(TCHAR);
	// читаем размер строки
	PBYTE d=(PBYTE)&sz; *d=0; // байтбуфер
	int i=0; for(i=0; i<is && pos+i<size; i++) d[i]=view[pos+i+HEAD_MEM]; // читаем байты
	if (i<is) { UnViewFile(view); return(-2); } // ошибка чтения размера
	// читаем саму строку
	pos+=is; // подвинулись на первый байт строки
	for (int e=0; e<sz; e++) // прочитали символы
	{
		d=(PBYTE)&buf[e]; *d=0; // байтбуфер
		for(i=0; i<ws && pos+e*ws+i<size; i++) d[i]=view[pos+e*ws+i+HEAD_MEM]; // читаем байты
		if (i<ws) { UnViewFile(view); return(-2); } // ошибка чтения размера
	}
	UnViewFile(view); // закрыли просмотр
	return(sz); // длина строки
}