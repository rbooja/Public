//+------------------------------------------------------------------+
//|                                        PriceTrancemitter[sc].mq4 |
//|                           Copyright (c) 2010, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2010, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#import "MemMap.dll"
string SetMemString(string tag,string msg);
string GetMemString(string tag);
#import
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   while(!IsStopped()){
      SetMemString("FxPro_"+Symbol(),DoubleToStr(MarketInfo(Symbol(),MODE_BID),MarketInfo(Symbol(),MODE_DIGITS)));
      Sleep(100);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+