
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property version     "1.0"
#property description "Trend Trigger Factor (Modified)"
#property strict

//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 C'50,50,50'
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrLime
#property indicator_color4 clrRed
// #property indicator_level1 0
// #property indicator_levelcolor C'30,30,30'
// #property indicator_levelstyle STYLE_SOLID // STYLE_DOT

//---- input parameters
extern int _fast = 34;
extern int _slow = 89;

//---- buffers
double ttf[];
double lev[];
double up[];
double dn[];

//---- global variables
int    level = 1;
int    windowindex;
string shortname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void)
{
   //---- checking input data
   //---- indicator buffers
   IndicatorBuffers(4);
   SetIndexBuffer(0, lev);
   SetIndexBuffer(1, ttf);
   SetIndexBuffer(2, up);
   SetIndexBuffer(3, dn);

   //---- drawing settings
   // IndicatorDigits(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 158); // 159
   SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3, 158);

   //--- horizontal level
   SetLevelValue(0, 0.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1973790);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, -1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH, -1);

   //---- set short name
   shortname = "ttfm ("+(string)_fast+ ", "+(string)_slow+")";
   IndicatorShortName(shortname);

   //---- set global variables
   windowindex = WindowFind(shortname);

   //----
   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason)
{
   //----
   if (-1 < ObjectFind(shortname)) ObjectDelete(shortname);
   //----
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime &time[],     // Time
                 const double &open[],       // Open
                 const double &high[],       // High
                 const double &low[],        // Low
                 const double &close[],      // Close
                 const long &tick_volume[],  // Tick Volume
                 const long &volume[],       // Real Volume
                 const int &spread[])        // Spread
{
   //---- global variables
   //---- initialization of zero
   if (!prev_calculated)
   {
      for (int i=rates_total-1,j=rates_total-(_slow+1);j<=i;i--)
      {
         lev[i] = ttf[i] = 0;
         up[i] = dn[i] = EMPTY_VALUE;
      }
   }

   //---- the main cycle of indicator calculation
   for (int i = rates_total-(prev_calculated?prev_calculated:_slow+1);0<=i;i--)
   {
      double buypower  = high[iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,_fast,i)] -
                         low[iLowest(NULL,PERIOD_CURRENT,MODE_LOW,_slow,i/*+_slow*/)];

      double sellpower = high[iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,_slow,i/*+_slow*/)] -
                         low[iLowest(NULL,PERIOD_CURRENT,MODE_LOW,_fast,i)];

      ttf[i] = buypower - sellpower;
      if (ttf[i]) ttf[i] /= 0.5 * (buypower + sellpower);

      lev[i] = 0 < ttf[i] ? level : -level;

      up[i] = dn[i] = EMPTY_VALUE;
      if ( level < ttf[i]) up[i] =  level;
      if (-level > ttf[i]) dn[i] = -level;
   }

   ShowValue(shortname, ttf[0], windowindex);

   //----
   return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ShowValue(string object_name, double value, int index = 0)
{
   string text = DoubleToString(value, 2);
   color  clr  = clrGray;

   if (0 < value) clr = C'0,100,0';
   if (0 > value) clr = C'100,0,0';

   if (-1 == ObjectFind(object_name))
   {
      ObjectCreate(object_name, OBJ_LABEL, index, 0, 0, 0, 0);
      ObjectSet(object_name, OBJPROP_CORNER, 1);
      ObjectSet(object_name, OBJPROP_XDISTANCE, 6);
      ObjectSet(object_name, OBJPROP_YDISTANCE, 1);
   }
   ObjectSetText(object_name, text, 8, NULL, clr);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
