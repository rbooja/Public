
#property indicator_chart_window

#import "_DDEMap.dll"
   int SendDDE(string server, string topic, string item, string value);
#import

//---- input parameters
extern string service = "service";
extern string topic   = "topic";
extern string item    = "item";

int start()
{
   if (!IsDllsAllowed())
   {
      Alert("ERROR: [Allow DLL imports] NOT Checked.");
      return (0);
   }

   int ret = SendDDE(service, topic, item, DoubleToString(Close[0], _Digits));

   return (0);
}
