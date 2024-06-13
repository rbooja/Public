//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  DDE_Sender_Sample.mq4
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#property strict
#property indicator_chart_window

#import "DDEMap.dll"
  int SendDDE(uchar &[], uchar &[], uchar &[], uchar &[]);
#import

input string Server = "MetaTrader4";

uchar server[], topic[], item[], value[];

int OnInit() {
  //---
  StringToCharArray(Server, server);
  StringToCharArray("Topic", topic);
  StringToCharArray("Item", item);
  return (INIT_SUCCEEDED);
  //---
}

void OnDeinit(const int reason) {
  //---
  //---
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //---
  StringToCharArray(DoubleToString(Bid), value);
  SendDDE(server, topic, item, value);
  Print("Server: ", CharArrayToString(server), ", Topic: ", CharArrayToString(topic), ", Item: ", CharArrayToString(item), ", Value: ", CharArrayToString(value));
  return (rates_total);
  //---
}