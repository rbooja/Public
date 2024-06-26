//+------------------------------------------------------------------+
//|                      Copyright 2006-2012, http://www.FXmaster.de |
//|				programming & support - Alex Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#pragma once

#include "stdafx.h"

#define HEAD_MEM		4 // размер заголовка файла, для хранения его длины

//------------------------------------------------------------------	class CMemMapAPI
class CMemMapApi
{
public:
	enum OpenFlags { modeOpen=(int) 0x00000, modeCreate=(int)0x00001 }; // Flag values

public:
	CMemMapApi();
	~CMemMapApi();

public:
	HANDLE Open(LPTSTR path, DWORD size, int mode, DWORD &err); // создание
	void Close(HANDLE hmem); // закрытие
	int Fill(HANDLE h, BYTE b, DWORD &err); // заполнить память указанным значением
	HANDLE Grows(HANDLE hmem, LPTSTR path, DWORD size, DWORD &err); // увеличит размер
	PBYTE	ViewFile(HANDLE hmem, DWORD &err); // получаем буфер
	void UnViewFile(PBYTE buf); // закрываем буфер
	DWORD GetSize(HANDLE hmem, DWORD &err); // получаем размер
	int SetSize(HANDLE hmem, DWORD size, DWORD &err); // устанавливаем размер
	int Write(HANDLE hmem, const void *buf, DWORD pos, int sz, DWORD &err); // запись данных в память с указаной позиции на указанное число байт
	int Read(HANDLE hmem, void *buf, DWORD pos, int sz, DWORD &err); // чтение данных из памяти с указаной позиции на указанное число байт
	int WriteStr(HANDLE hmem, LPCTSTR buf, DWORD pos, int sz, DWORD &err); // запись строки в память с указаной позиции на указанное число байт
	int ReadStr(HANDLE hmem, LPTSTR buf, DWORD pos, int &sz, DWORD &err); // чтение строки из памяти с указаной позиции на указанное число байт
};

//------------------------------------------------------------------	class CMemMapFile
class CMemMapFile
{
public:
	enum OpenFlags { modeOpen=(int) 0x00000, modeCreate=(int)0x00001 }; // Flag values

	HANDLE m_hmem; // дескриптор
	LPTSTR m_path; // имя к файлу
	DWORD m_size; // длина файла
	DWORD m_pos; // текущая позиция указателя
	int m_mode; // режим открытия
	PBYTE m_buf; // указатель на буфер данных

public:
	CMemMapFile();
	~CMemMapFile();

public:
	int Open(LPTSTR path, DWORD size, int mode); // создание
	void Close(); // закрытие и сброс хендлов
	int Fill(BYTE b); // заполнить память указанным значением
	int Seek(DWORD pos, int orig); // установка указателя на блок памяти
	int Grows(DWORD size); // увеличит размер
	int IsEOF() { if (m_pos>=m_size) return(1); return(0); }; // положение
	DWORD Tell() { return(m_pos); }; // положение

	int Write(const void *buf, int sz); // запись в память указанное число байт
	int Read(void *buf, int sz); // чтение из памяти указанное число байт
	int WriteStr(LPCTSTR buf, int sz); // запись в память строки указанное число байт
	int ReadStr(LPTSTR buf, int &sz); // чтение из памяти строки на указанное число байт
	int WriteStr(const CString *buf, int len); // запись в память строки
	int ReadStr(CString *buf); // чтение из памяти строки
};