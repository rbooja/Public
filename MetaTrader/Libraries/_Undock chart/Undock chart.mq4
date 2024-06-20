
#property copyright "(c) MT4i.com"
#property link      ""

#import "undock.dll"
   int DetachChart2(int a0, int a1);
#import

void start() {
   if (!IsDllsAllowed()) {
      MessageBox("Please turn on \"Allow DLL imports\" in order to undock charts");
      return;
   }
   DetachChart2(WindowHandle(Symbol(), Period()), 3);
}