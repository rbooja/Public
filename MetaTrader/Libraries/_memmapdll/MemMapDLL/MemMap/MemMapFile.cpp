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
	if (m_mode==modeCreate) m_hmem=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, m_size+HEAD_MEM, m_path); // создаем объект памяти
	if (m_mode==modeOpen)		m_hmem=OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, m_path); // открываем объект памяти
	if (m_hmem==NULL) return(GetLastError()); // если ошибка создания

	m_buf=(PBYTE)MapViewOfFile(m_hmem, FILE_MAP_ALL_ACCESS, 0, 0, 0); // получили представление файла
	if (m_buf==NULL) { int err=GetLastError(); Close(); return(err); } // если ошибка представления

	if (m_mode==modeCreate) FillMemory(m_buf, m_size, 0); // обнулили память если создаем
	m_pos=0; // начальное положение
	// размер файла
	PBYTE d=(PBYTE)&m_size;
	if (m_mode==modeCreate) for(int i=0; i<sizeof(DWORD); i++) m_buf[i]=d[i];
	if (m_mode==modeOpen) for(int i=0; i<sizeof(DWORD); i++) d[i]=m_buf[i];
	return(0);
}
//------------------------------------------------------------------	Close
void CMemMapFile::Close()
{
	if (m_buf!=NULL) UnmapViewOfFile(m_buf); m_buf=NULL; // закрываем хендл
	if (m_hmem!=NULL) CloseHandle(m_hmem); m_hmem=NULL; // закрываем хендл
}
//------------------------------------------------------------------	Fill
int CMemMapFile::Fill(BYTE b) // заполнить память указанным значением
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
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
	HANDLE hnew=CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, m_size+HEAD_MEM, m_path); // создаем объект памяти
	if (hnew==NULL) return(GetLastError()); // если ошибка создания
	HANDLE h=m_hmem; m_hmem=hnew; hnew=h;
	CloseHandle(h); // закрываем предыдущий
	// записали размер файла
	PBYTE d=(PBYTE)&m_size; for(int i=0; i<sizeof(DWORD); i++) m_buf[i]=d[i];
	return(0);
}
//------------------------------------------------------------------	Seek
int CMemMapFile::Seek(DWORD pos, int seek=SEEK_SET) // установка указателя на блок памяти
{
	if (seek==SEEK_SET) m_pos=pos;
	if (seek==SEEK_CUR) m_pos+=pos;
	if (seek==SEEK_END) m_pos=m_size-pos;
	// отравняли
	m_pos<0?0:m_pos;
	m_pos>m_size?m_size:m_pos;
	return(0);
}
//------------------------------------------------------------------	Write
int CMemMapFile::Write(const void *buf, int sz) // запись в память указанное число байт
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	if (m_pos+sz>m_size) if (Grows(m_pos+sz)!=0) return(-2);
	PBYTE d=(PBYTE)buf; // реальный байт-буфер
	int i=0; for(i=0; i<sz && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i];
	m_pos+=i; // поставили указатель
	return(0);
}
//------------------------------------------------------------------	Read
int CMemMapFile::Read(void *buf, int sz) // чтение из памяти указанное число байт
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	PBYTE d=(PBYTE)buf; // реальный байт-буфер
	*d=0;
	int i=0; for(i=0; i<sz && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM];
	long *l1=(long*)d;
	long *l2=(long*)d;
	m_pos+=i; // поставили указатель
	return(i);
}
//------------------------------------------------------------------	WriteStr
int CMemMapFile::WriteStr(LPCTSTR buf, int sz) // запись в память строки
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	int is=sizeof(int); int ws=sizeof(wchar_t);
	if (m_pos+is+sz*ws>m_size) if (Grows(m_pos+is+sz*ws)!=0) return(-2); // проверили размер памяти
	// пишем размер строки
	PBYTE d=(PBYTE)&sz; // взяли байтбуфер
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i]; // пишем байты
	// пишем саму строку
	m_pos+=is; // подвинулись на первый байт строки
	for (int e=0; e<sz; e++) // прочитали символы
	{
		d=(PBYTE)buf[e]; // байтбуфер на элемент строки
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) m_buf[m_pos+e*ws+i+HEAD_MEM]=d[i]; // пишем байты
	}
	return(0); // вернули ОК
}
//------------------------------------------------------------------	Readstr
int CMemMapFile::ReadStr(LPTSTR buf, int &sz) // чтение из памяти строки
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	int is=sizeof(int); int ws=sizeof(wchar_t);
	// читаем размер строки
	PBYTE d=(PBYTE)&sz; *d=0; // байтбуфер
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM]; // читаем байты
	if (i<is) return(-2); // ошибка чтения размера
	// читаем саму строку
	m_pos+=is; // подвинулись на первый байт строки
	for (int e=0; e<sz; e++) // прочитали символы
	{
		d=(PBYTE)buf[e]; *d=0; // байтбуфер
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) d[i]=m_buf[m_pos+e*ws+i+HEAD_MEM]; // читаем байты
		if (i<ws) return(-2); // ошибка чтения размера
	}
	return(sz); // длина строки
}
//------------------------------------------------------------------	WriteStr
int CMemMapFile::WriteStr(const CString *buf, int len) // запись в память строки
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	int sz=buf->GetLength(); sz=sz>len?len:sz; // учли ограничение
	int is=sizeof(int); int ws=sizeof(wchar_t);
	if (m_pos+is+sz*ws>m_size) if (Grows(m_pos+is+sz*ws)!=0) return(-2); // проверили размер памяти
	// пишем размер строки
	PBYTE d=(PBYTE)&sz; // взяли байтбуфер
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) m_buf[m_pos+i+HEAD_MEM]=d[i]; // пишем байты
	// пишем саму строку
	m_pos+=is; // подвинулись на первый байт строки
	for (int e=0; e<sz; e++) // прочитали символы
	{
		wchar_t ch=buf->GetAt(e);
		d=(PBYTE)&ch; // байтбуфер на элемент строки
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) m_buf[m_pos+e*ws+i+HEAD_MEM]=d[i]; // пишем байты
	}
	return(0); // вернули ОК
}
//------------------------------------------------------------------	Readstr
int CMemMapFile::ReadStr(CString *buf) // чтение из памяти строки
{
	if (m_hmem==NULL || m_buf==NULL) return(-1); // если не открыт
	int is=sizeof(int); int ws=sizeof(wchar_t);
	// читаем размер строки
	int sz=0; PBYTE d=(PBYTE)&sz; *d=0; // байтбуфер
	int i=0; for(i=0; i<is && m_pos+i<m_size; i++) d[i]=m_buf[m_pos+i+HEAD_MEM]; // читаем байты
	if (i<is) return(-2); // ошибка чтения размера
	// читаем саму строку
	m_pos+=is; // подвинулись на первый байт строки
	buf->SetString(_T("")); // обнулили строку
	for (int e=0; e<sz; e++) // прочитали символы
	{
		wchar_t ch=0; 
		d=(PBYTE)&ch; *d=0; // байтбуфер
		for(i=0; i<ws && m_pos+e*ws+i<m_size; i++) d[i]=m_buf[m_pos+e*ws+i+HEAD_MEM]; // читаем байты
		if (i<ws) return(-2); // ошибка чтения размера
		buf->Insert(e, ch); // 
	}
	return(sz); // длина строки
}