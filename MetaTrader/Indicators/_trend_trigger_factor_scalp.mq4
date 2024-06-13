
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property version     "1.0"
#property description "Trend Trigger Factor (Scalp)"
#property strict

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 C'50,50,50'
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrRed

//--- input parameters
extern int  period          = 0;
extern int  smooth          = 0;
       bool alertsOn        = false;
       bool alertsOnCurrent = false;

//--- buffers
double ttf[];
double lev[];
double up[];
double dn[];

//--- global variables
int    level = 1;
int    windowindex;
string shortname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void)
{
   //--- checking input data
   if (!period) period = GetPeriod(_Period);
   if (!smooth) smooth = 3;

   //--- indicator buffers
   IndicatorBuffers(4);
   SetIndexBuffer(0, lev);
   SetIndexBuffer(1, ttf);
   SetIndexBuffer(2, up);
   SetIndexBuffer(3, dn);

   //--- drawing settings
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

   //--- set short name
   double multiplier = 1.0;
   if ("KP200" == _Symbol) multiplier = 3.0;
   if ("KQ150" == _Symbol) multiplier = 3.43;

   shortname = StringConcatenate(WindowExpertName(), " (");
   if (_Period < PERIOD_D1)
      shortname += StringConcatenate(DoubleToString((double)period / ((double)PERIOD_D1 / (double)_Period) * multiplier, 1), ", ");
   // shortname += StringConcatenate(Dec2Hex(period));
   shortname += StringConcatenate(period);
   if (0 < smooth) shortname += StringConcatenate(", ", smooth);
   shortname += ")";
   IndicatorShortName(shortname);

   //--- set global variables
   windowindex = WindowFind(shortname);

   //--- initialization done
   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason)
{
   //---
   if (-1 < ObjectFind(shortname)) ObjectDelete(shortname);
   //---
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
   //--- global variables
   //--- initialization of zero
   if (!prev_calculated)
   {
      for (int i=rates_total-1,j=rates_total-(period+2);j<=i;i--)
      {
         lev[i] = ttf[i] = up[i] = dn[i] = EMPTY_VALUE;
      }
   }

   //--- the main cycle of indicator calculation
   for (int i=rates_total-(prev_calculated?prev_calculated:period+2);0<=i;i--)
   {
      double buypower  = high[i] - low[iLowest(NULL,PERIOD_CURRENT,MODE_LOW,period,i/*+1*/)];
      double sellpower = high[iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,period,i/*+1*/)] - low[i];

      ttf[i] = buypower - sellpower;
      if (ttf[i]) ttf[i] /= 0.5 * (buypower + sellpower);
      if (0 < smooth) ttf[i] = iT3.main(ttf[i], smooth, rates_total, i, 0.618);
      lev[i] = 0. < ttf[i] ? level : -level;

      up[i] = dn[i] = EMPTY_VALUE;
      if ( level < ttf[i]) up[i] =  level;
      if (-level > ttf[i]) dn[i] = -level;
   }

   //---
   ShowValue(ttf[0], shortname, windowindex);
   if (alertsOn) ManageAlerts((int)alertsOnCurrent);

   return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  T3 Moving Average (Standard) 2.5
//  the origin T3 (Tim Tillson) way or faster (Fulks/Matulich) way
//  ratio : Fulks/Matulich length = 2*Tillson length -1
//     or : Tillson length        = (Fulks/Matulich length+1)/2
//  0.146 0.236, 0.382, 0.528, 0.618, 0.764, 0.854
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class classT3
{
   private:
      struct t3bufer { double e1, e2, e3, e4, e5, e6; } buf[];
      bool   initsializatsiya;
      double c1, c2, c3, c4, alpha;
      void   init (int length, double a, bool origin)
      {
         c1    = -a*a*a;
         c2    = 3.0*a*a+3.0*a*a*a;
         c3    = -6.0*a*a-3.0*a-3.0*a*a*a;
         c4    = 1.0+3.0*a+a*a*a+3.0*a*a;
         alpha = 2.0/(origin?1.0+length:2.0+(length-1.0)/2.0);
         initsializatsiya = false;
      }
   public:
      classT3() : initsializatsiya (true) {}
      double main (double value, int length, int rates_total, int i, double volume_factor = 0.382, bool origin = false)
      {
         if (ArraySize(buf) < rates_total+1)
         {
            ArraySetAsSeries(buf, false);
            ArrayResize(buf, rates_total+1);
            ArraySetAsSeries(buf, true);
         }
         int p = i+1;
         if (initsializatsiya)
         {
            init (length, volume_factor, origin);
            buf[p].e1 = value;
            buf[p].e2 = value;
            buf[p].e3 = value;
            buf[p].e4 = value;
            buf[p].e5 = value;
            buf[p].e6 = value;
         }
         buf[i].e1 = buf[p].e1 + alpha * (    value - buf[p].e1);
         buf[i].e2 = buf[p].e2 + alpha * (buf[i].e1 - buf[p].e2);
         buf[i].e3 = buf[p].e3 + alpha * (buf[i].e2 - buf[p].e3);
         buf[i].e4 = buf[p].e4 + alpha * (buf[i].e3 - buf[p].e4);
         buf[i].e5 = buf[p].e5 + alpha * (buf[i].e4 - buf[p].e5);
         buf[i].e6 = buf[p].e6 + alpha * (buf[i].e5 - buf[p].e6);
         return (c1 * buf[i].e6 + c2 * buf[i].e5 + c3 * buf[i].e4 + c4 * buf[i].e3);
      }
} iT3;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ShowValue(double value, string object_name, int index = 0, double compare = 0.0, color plus = C'0,100,0', color minus = C'100,0,0', int digits = 2)
{
   string text = DoubleToString(value, digits);
   color  clr  = clrGray;

   if (compare < value) clr = plus;
   if (compare > value) clr = minus;

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

void ManageAlerts(int i)
{
   static datetime previous = 0;

   i = i ? 0 : 1;

   if (previous != Time[0] && (up[i+1] != up[i] || dn[i+1] != dn[i]))
   {
      PlaySound("alert2.wav");
      previous = Time[0];
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int GetPeriod(int length = PERIOD_CURRENT)
{
   //---
   int result = 0;
   switch(length)
   {
      case PERIOD_H4  : result = 30; break;
      case PERIOD_D1  :
      case PERIOD_W1  :
      case PERIOD_MN1 : result = 13; break;
      default         : result = 34;
   }
   return (result);
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
