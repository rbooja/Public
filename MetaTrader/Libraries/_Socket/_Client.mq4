#import "_Client.dll"
   int SocketOpen(string, string);
   int SocketSend(int, string);
   string SocketReceive(int);
   int SocketClose(int);
#import

//const string HOST = "127.0.0.1";
const string HOST = "localhost";
const string PORT = "1024";
int Socket;

int OnInit() {
  Socket = SocketOpen(HOST, PORT);
  if (Socket < 0) return(INIT_FAILED);
  return(INIT_SUCCEEDED);
}

void OnTick() {
  if (Socket < 0) return;
  SocketSend(Socket, "MinGW라는 이름은 Minimalist GNU for Windows의 줄임말이다. MinGW는 Mingw32라고 말할 수도 있는데 Win32 API용 헤더를 제공하기 때문이다.");
  Print(SocketReceive(Socket));
}

void OnDeinit(const int reason) {
  if (Socket < 0) return;
  SocketClose(Socket);
}