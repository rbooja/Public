//+------------------------------------------------------------------+
//|                                            PriceReceiver[sc].mq4 |
//|                           Copyright (c) 2010, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2010, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"

#import "MemMap.dll"
string SetMemString(string tag,string msg);
string GetMemString(string tag);
#import

extern string prefix = "FxPro";

string objname = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   objname = "PriceReceive_"+Symbol();
   return(0);
  }
int deinit()
  {
   ObjectDelete(objname);
   return(0);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   while(!IsStopped()){
      string b = GetMemString(prefix+"_"+Symbol());
      Comment("b=",b);
      if(ObjectFind(objname)!=0)
         ObjectCreate(objname,OBJ_HLINE,0,0,0);
      ObjectSet(objname,OBJPROP_PRICE1,StrToDouble(b));
      ObjectSet(objname,OBJPROP_COLOR,SkyBlue);
      Sleep(100);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+