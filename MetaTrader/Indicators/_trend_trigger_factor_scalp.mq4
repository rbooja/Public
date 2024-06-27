
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#property strict
#property indicator_separate_window

#property indicator_buffers 4

#property indicator_color1 C'50,50,50'
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrRed

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern int  period          = 20;
       bool alertsOn        = false;
       bool alertsOnCurrent = false;

double ttf[];
double lev[];
double up[];
double dn[];

int level = 1;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {

   IndicatorBuffers(4);

   SetIndexBuffer(0, lev);
   SetIndexBuffer(1, ttf);
   SetIndexBuffer(2, up);
   SetIndexBuffer(3, dn);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 158); // 159
   SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3, 158);

   SetLevelValue(0, 0.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1973790);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, -1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH, -1);

   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
   //---
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime &time[],     // Time
                 const double &open[],       // Open
                 const double &high[],       // High
                 const double &low[],        // Low
                 const double &close[],      // Close
                 const long &tick_volume[],  // Tick Volume
                 const long &volume[],       // Real Volume
                 const int &spread[])        // Spread {

   if (!prev_calculated) {
      for (int i=rates_total-1,j=rates_total-(period+2);j<=i;i--) {
         lev[i] = ttf[i] = up[i] = dn[i] = EMPTY_VALUE;
      }
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : period + 2); 0 <= i; i--) {
      double buypower  = high[i] - low[iLowest(NULL,PERIOD_CURRENT,MODE_LOW,period,i/*+1*/)];
      double sellpower = high[iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,period,i/*+1*/)] - low[i];

      ttf[i] = buypower - sellpower;
      if (ttf[i]) ttf[i] /= 0.5 * (buypower + sellpower);
      lev[i] = 0. < ttf[i] ? level : -level;

      up[i] = dn[i] = EMPTY_VALUE;
      if ( level < ttf[i]) up[i] =  level;
      if (-level > ttf[i]) dn[i] = -level;
   }

   if (alertsOn) ManageAlerts((int)alertsOnCurrent);

   return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
