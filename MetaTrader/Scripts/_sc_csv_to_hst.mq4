
void OnStart() {
  //---
  int handle = Create("VOID", 1, 0);
  /*
  MqlRates rates;
  rates.time = D'1970.01.01 00:00';
  rates.open  = 1;
  rates.high  = 3;
  rates.low   = 0;
  rates.close = 2;
  rates.tick_volume = 1;
  rates.spread = 0;
  rates.real_volume = 1;
  */
  // FileSeek(handle, 0, SEEK_END);
  // FileWriteStruct(handle, rates);
  FileClose(handle);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#ifdef __MQL4__
int Create(string symbol, int period, int digits = 5) {
  //---
  int handle = FileOpenHistory(symbol + (string)period + ".hst", FILE_BIN | FILE_WRITE);
  FileClose(handle);
  //---
  handle = FileOpenHistory(symbol + (string)period + ".hst", FILE_BIN | FILE_WRITE | FILE_READ | FILE_SHARE_WRITE | FILE_SHARE_READ);
  if (0 > handle) {
    // Print(/*__FUNCTION__,*/ErrorDescription(GetLastError()));
    return (-1);
  }
  // if (FileSize(handle) <= 0)
  // {
  FileSeek(handle, 0, SEEK_SET);
  int unused[13];
  ArrayInitialize(unused, 0);
  FileWriteInteger(handle, 401, LONG_VALUE);
  FileWriteString(handle, "(C)opyright 2003, MetaQuotes Software Corp.", 64);
  FileWriteString(handle, symbol, 12);
  FileWriteInteger(handle, period, LONG_VALUE);
  FileWriteInteger(handle, digits, LONG_VALUE);
  FileWriteInteger(handle, 0, LONG_VALUE);
  FileWriteInteger(handle, 0, LONG_VALUE);
  FileWriteArray(handle, unused, 0, 13);
  // }
  // else // go to end of existing history file
  // {
  FileSeek(handle, 0, SEEK_END);
  // }
  // FileFlush(handle);
  return (handle);
  //---
}
#endif

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
