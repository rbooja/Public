
#property strict

#import "user32.dll"
  int PostMessageW(int hWnd, int Msg, int wParam, int lParam);
  int RegisterWindowMessageW(string MessageName);
#import

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  script program start function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnStart() {
  int hwnd = WindowHandle(_Symbol, _Period);
  int msg = RegisterWindowMessageW("MetaTrader4_Internal_Message");

  while (!IsStopped()) {
    PostMessageW(hwnd, msg, 2, 1);
    Sleep(1000); // milliseconds (1 seconds = 1000)
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
