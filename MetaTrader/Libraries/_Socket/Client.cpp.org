#define _WIN32_WINNT 0x501
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <ws2tcpip.h>

#define EXPORT extern "C"

static const unsigned int LENGTH = 100000;

EXPORT int clientDllOpen(const wchar_t* wnode, const wchar_t* wservice) {
  char node[100];

  if (WideCharToMultiByte(CP_ACP, 0, wnode, -1, node, 100, NULL, NULL) < 0) {
    //MessageBox(0, L"Error in WideCharToMultiByte", L"", MB_OK);
    return -1;
  }

  char service[100];

  if (WideCharToMultiByte(CP_ACP, 0, wservice, -1, service, 100, NULL, NULL) < 0) {
    //MessageBox(0, L"Error in WideCharToMultiByte", L"", MB_OK);
    return -1;
  }

  WSADATA wsaData;

  if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
    //MessageBox(0, L"Error in WSAStartup", L"", MB_OK);
    return -1;
  }

  struct addrinfo hints, *server = NULL;

  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;

  if (getaddrinfo(node, service, &hints, &server) != 0) {
    //MessageBox(0, L"Error in getaddrinfo", L"", MB_OK);
    WSACleanup();
    return -1;
  }

  int sockfd = socket(server->ai_family, server->ai_socktype, server->ai_protocol);

  if (sockfd < 0) {
    //MessageBox(0, L"Error in socket", L"", MB_OK);
    WSACleanup();
    return -1;
  }

  if (connect(sockfd, server->ai_addr, server->ai_addrlen) < 0) {
    //MessageBox(0, L"Error in connect", L"", MB_OK);
    closesocket(sockfd);
    WSACleanup();
    return -1;
  }

  freeaddrinfo(server);

  return sockfd;
}

EXPORT int clientDllSend(int sockfd, wchar_t* wtext) {
  if (sockfd < 0) {
    //MessageBox(0, L"Error in sockfd", L"", MB_OK);
    return -1;
  }

  char text[LENGTH];

  int length = WideCharToMultiByte(CP_UTF8, 0, wtext, -1, text, LENGTH, NULL, NULL);

  if (length < 0) {
    //MessageBox(0, L"Error in WideCharToMultiByte", L"", MB_OK);
    closesocket(sockfd);
    WSACleanup();
    return -1;
  }

  if (send(sockfd, text, length, 0) < 0) {
    //MessageBox(0, L"Error in send", L"", MB_OK);
    closesocket(sockfd);
    WSACleanup();
    return -1;
  }

  return 0;
}

EXPORT wchar_t* clientDllReceive(int sockfd) {
  if (sockfd < 0) {
    //MessageBox(0, L"Error in sockfd", L"", MB_OK);
    return NULL;
  }

  char buffer[LENGTH];

  int length = recv(sockfd, buffer, LENGTH, 0);

  if (length < 0) {
    //MessageBox(0, L"Error in recv", L"", MB_OK);
    closesocket(sockfd);
    WSACleanup();
    return NULL;
  }

  buffer[length] = '\0';

  static wchar_t wbuffer[LENGTH];

  if (MultiByteToWideChar(CP_UTF8, 0, buffer, -1, wbuffer, LENGTH) < 0) {
    //MessageBox(0, L"Error in MultiByteToWideChar", L"", MB_OK);
    closesocket(sockfd);
    WSACleanup();
    return NULL;
  }

  return wbuffer;
}

EXPORT int clientDllClose(int sockfd) {
  if (sockfd < 0) {
    //MessageBox(0, L"Error in sockfd", L"", MB_OK);
    return -1;
  }

  if (closesocket(sockfd) < 0) {
    //MessageBox(0, L"Error in closesocket", L"", MB_OK);
    WSACleanup();
    return -1;
  }

  WSACleanup();

  return 0;
}