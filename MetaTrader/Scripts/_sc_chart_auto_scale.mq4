//+------------------------------------------------------------------+
//|                                         CHART_AUTO_SCALE_SCR.mq4 |
//|                                  Copyright 2014, Khalil Abokwaik |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Khalil Abokwaik"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
//--- input parameters
input int      DISTANCE_PIPS=100;
bool OP=FALSE;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   OP=ChartSetInteger(0,CHART_SCALEFIX,TRUE);
   OP=ChartSetDouble(0,CHART_FIXED_MAX,Bid+(DISTANCE_PIPS*Point));
   OP=ChartSetDouble(0,CHART_FIXED_MIN,Bid-(DISTANCE_PIPS*Point));   

  }
//+------------------------------------------------------------------+
