//+------------------------------------------------------------------+
//|                                              Sample DLL for MQL4 |
//|                  Copyright ©2004-2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
/*
compile.mingw.bat
g++ -shared -static Client.cpp -lws2_32 -o Client.dll
strip Client.dll
*/
#define _WIN32_WINNT 0x501
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <ws2tcpip.h>

#define EXPORT extern "C"
#define LENGTH 2048
// static const unsigned int LENGTH = 100000;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EXPORT int SocketOpen(const wchar_t* wnode, const wchar_t* wservice)
{
   char node[100];

   if (0 > WideCharToMultiByte(CP_ACP, 0, wnode, -1, node, 100, NULL, NULL))
   {
      return -1;
   }

   char service[100];

   if (0 > WideCharToMultiByte(CP_ACP, 0, wservice, -1, service, 100, NULL, NULL))
   {
      return -1;
   }

   WSADATA wsaData;

   if (0 != WSAStartup(MAKEWORD(2, 2), &wsaData)) return -1;

   struct addrinfo hints, *server = NULL;

   memset(&hints, 0, sizeof(hints));
   hints.ai_family   = AF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_protocol = IPPROTO_TCP;

   if (0 != getaddrinfo(node, service, &hints, &server))
   {
      WSACleanup();
      return -1;
   }

   int sockfd = socket(server -> ai_family, server -> ai_socktype, server -> ai_protocol);

   if (0 > sockfd)
   {
      WSACleanup();
      return -1;
   }

   if (0 > connect(sockfd, server->ai_addr, server->ai_addrlen))
   {
      closesocket(sockfd);
      WSACleanup();
      return -1;
   }

   freeaddrinfo(server);

   return sockfd;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EXPORT int SocketSend(int sockfd, wchar_t* wtext)
{
   if (0 > sockfd) return -1;

   char text[LENGTH];

   int length = WideCharToMultiByte(CP_UTF8, 0, wtext, -1, text, LENGTH, NULL, NULL);

   if (0 > length)
   {
      closesocket(sockfd);
      WSACleanup();
      return -1;
   }

   if (0 > send(sockfd, text, length, 0))
   {
      closesocket(sockfd);
      WSACleanup();
      return -1;
   }

   return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EXPORT wchar_t* SocketReceive(int sockfd)
{
   if (0 > sockfd) return NULL;
 
   char buffer[LENGTH];

   int length = recv(sockfd, buffer, LENGTH, 0);

   if (0 > length)
   {
      closesocket(sockfd);
      WSACleanup();
      return NULL;
   }

   buffer[length] = '\0';

   static wchar_t wbuffer[LENGTH];

   if (0 > MultiByteToWideChar(CP_UTF8, 0, buffer, -1, wbuffer, LENGTH))
   {
      closesocket(sockfd);
      WSACleanup();
      return NULL;
   }

   return wbuffer;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EXPORT int SocketClose(int sockfd)
{
   if (0 > sockfd) return -1;

   if (0 > closesocket(sockfd))
   {
    WSACleanup();
    return -1;
   }

   WSACleanup();

   return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* MBCS(Multi Byte Character System)
*  WBCS(Wide Byte Character System)
*  MBCS문자열은 문자열 중에 영문은 1바이트, 한글등은 2바이트로 저장함
*  WBCS문자열은 모든 문자를 2바이트(Unicode)로 저장함
*  MBCS, WBCS상호 변환가능
*  mbstowcs(wchar_t *dest, const char *src, size_t maxCount)
*  wcstombs(char *dest, const wchar_t *src, size_t maxCount)
wcstombs()/mbstowcs()는 clib 라서, 호환성이 좀 좋아보이는듯 하지만
wchar_t 타입이 윈도는 2바이트이고, 리눅스쪽은 4바이트라서 호환성을 유지하기가 쉽지 않음.
wcstombs()/mbstowcs() 보다는 MultiByteToWideChar()/WideCharToMultiByte()
GNU 에서 만든 문자열 변환 유틸리티(iconv) 및 라이브러리(libiconv)이다. 리눅스에는 glibc 에 포함되어 있으며 윈도는 gnuwin32 에서 받을 수 있다.
https://www.lesstif.com/software-architect/gnu-iconv-character-set-encoding-14090674.html
*/
/*
// https://ccusean.tistory.com/entry/Programming-charset-%EB%B3%80%EA%B2%BD-iconv%ED%95%A8%EC%88%98-%EC%82%AC%EC%9A%A9

// 컴파일시 -liconv

#include <iconv.h>

bool ChangeCharset(char *szSrcCharset, char *szDstCharset, char *szSrc, int nSrcLength, wchar_t *szDst, int nDstLength)
{
   iconv_t it = iconv_open(szDstCharset, szSrcCharset);
   if (it == (iconv_t)(-1)) return false;

   bool result = true;
   size_t nSrcStrLen = nSrcLength;
   size_t nDstStrLen = nDstLength;
   size_t cc = iconv(it, &szSrc, &nSrcStrLen, &szDst, &nDstStrLen);

   if (cc == (size_t)(-1)) result = false;
   if (iconv_close(it) == -1) result = false;

   return result;
}

char szSrc[] = "대한민국";
wchar_t szDst[100];
// utf-8에서 euc-kr로 변경
ChangeCharset("utf-8", "wchar_t", szSrc, strlen(szSrc), szDst, sizeof(szDst));
*/