
//+------------------------------------------------------------------+
//|                                                           MemMap |
//|               Copyright © 2006-2013, FINEXWARE Technologies GmbH |
//|                                                www.FINEXWARE.com |
//|      programming & development - Alexey Sergeev, Boris Gershanov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2013, FINEXWARE Technologies GmbH"
#property link      "www.FINEXWARE.com"
#property version   "1.00"

#include <_memmaplib.mqh>

//------------------------------------------------------------------ OnStart

void OnStart() {
  CMemMapFile hmem;
  long err=hmem.Open("Local\\test",111,modeCreate);

  uchar data[];
  StringToCharArray("Hello from MQL5!",data);
  err=hmem.Write(data,ArraySize(data));

  ArrayInitialize(data,0);
  hmem.Seek(0,SEEK_SET);
  err=hmem.Read(data,ArraySize(data));
  Print(CharArrayToString(data));

  hmem.Close();
}
