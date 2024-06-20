//+------------------------------------------------------------------+
//|                                                  DDESender_A.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern string MT4BrokerID = "A";

#import "DDEMap.dll" 
int SendDDE(string server,string topic,string item,string value);
#import

int start()
{
   if (!IsDllsAllowed()) {
      Alert("ERROR: [Allow DLL imports] NOT Checked.");return (0);
   }
   
   SendDDE(MT4BrokerID,"DATA","NAME",AccountName());
   SendDDE(MT4BrokerID,"DATA","NUMBER",AccountNumber());
   SendDDE(MT4BrokerID,"DATA","BALANCE",AccountBalance());
   SendDDE(MT4BrokerID,"DATA","EQUITY",AccountEquity());

   SendDDE(MT4BrokerID,"DATA","FREEMARGIN",AccountFreeMargin());
   SendDDE(MT4BrokerID,"DATA","MARGIN",AccountMargin());
   SendDDE(MT4BrokerID,"DATA","LEVERAGE",AccountLeverage());

   return(0);
}

