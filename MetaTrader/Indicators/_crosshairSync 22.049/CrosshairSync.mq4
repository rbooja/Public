//+------------------------------------------------------------------+
//|                                             nn_CrosshairSync.mq4 |
//|                                                      nicholishen |
//|                            http://www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "http://www.reddit.com/u/nicholishenFX"
//#property version   "2.13"
#property version   "22.049"
#property strict

#property description "2022 Modifications by iDiamond@ForexFactory.com"
#property description "MetaTrader 5 compatibility and new user specified Input options"

//#define Dbug(x)

#property indicator_chart_window
#include "CrosshairManager.mqh"
#property icon "cross.ico"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input string            hot_key        = "t";                //Hot-key to toggle crosshairs
sinput ENUM_CrosshairStyle CrosshairStyle = Crosshair_HV;    // Crosshair style
input color             cross_col      = clrGold;            //Crosshair color
input ENUM_BASE_CORNER  button_corner  = CORNER_LEFT_LOWER;  //Corner for toggle button
sinput int              MarginX        = 0;                  //X Margin
sinput int              MarginY        = 0;                  //Y Margin
input ENUM_LINE_STYLE   line_style     = STYLE_SOLID;        //Line style
input bool              show_all_charts= true;               //Show verical line on all symbol charts
sinput bool             CrosshairInBackground = false;       // Crosshair in the background
sinput bool             show_tooltips  = true;               //Show Tooltips

CCrossManager cross_mgr(CrosshairStyle,cross_col,button_corner,MarginX,MarginY,line_style,hot_key,show_all_charts,CrosshairInBackground,show_tooltips);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   cross_mgr.OnChartEvent(id,lparam,dparam,sparam);
}
//+------------------------------------------------------------------+
void OnTimer()
{
  cross_mgr.OnTimer();
}
