
#import "_Client.dll"
   int    SocketOpen(string, string);
   int    SocketSend(int, string);
   string SocketReceive(int);
   int    SocketClose(int);
#import

//const string HOST = "127.0.0.1";
const string HOST = "localhost";
const string PORT = "1024";
int Socket = -1;

int OnInit()
{
   Socket = SocketOpen(HOST, PORT);
   if (Socket < 0) return(INIT_FAILED);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
  if (Socket < 0) return;
  SocketSend(Socket, "한글 테스트");
  Print(SocketReceive(Socket));
}

void OnDeinit(const int reason)
{
  if (Socket < 0) return;
  SocketClose(Socket);
}