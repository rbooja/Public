
#import "_undock.dll"
  int DetachChart2(int, int);
#import

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Script program start function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnStart() {
  if (!IsDllsAllowed()) {
    MessageBox("Please turn on \"Allow DLL imports\" in order to undock charts");
    return;
  }
  DetachChart2(WindowHandle(_Symbol, _Period), 3);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
