
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 6
#property indicator_plots   3

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_NONE
#property indicator_type5 DRAW_NONE
#property indicator_type6 DRAW_NONE

#property indicator_color1 clrTeal
#property indicator_color2 clrDimGray
#property indicator_color3 clrDimGray

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double buffer0[], buffer1[], buffer2[], buffer3[], buffer4[], buffer5[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);
   SetIndexBuffer(3, buffer3);
   SetIndexBuffer(4, buffer4);
   SetIndexBuffer(5, buffer5);

#ifdef __MQL5__
   ArraySetAsSeries(buffer0, true);
   ArraySetAsSeries(buffer1, true);
   ArraySetAsSeries(buffer2, true);
   ArraySetAsSeries(buffer3, true);
   ArraySetAsSeries(buffer4, true);
   ArraySetAsSeries(buffer5, true);
#endif

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
   //---
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
#ifdef __MQL5__
   ArraySetAsSeries( time, true);
   ArraySetAsSeries( high, true);
   ArraySetAsSeries(  low, true);
   ArraySetAsSeries(close, true);
#endif

   if (!prev_calculated) {
      int    i   = rates_total - 1;
      double vol = (double)fmax(tick_volume[i], 1);

      buffer3[i] = ((high[i] + low[i] + close[i]) / 3.0) * vol;
      buffer4[i] = vol;
      buffer5[i] = 1;

      buffer0[i] = buffer3[i] / buffer4[i];
      buffer1[i] = buffer0[i];
      buffer2[i] = buffer0[i];
      // for (int i = rates_total - 1, k = rates_total - 13; k <= i; i--) {}
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= i; i--) {
      double vol = (double)fmax(tick_volume[i], 1);

      if (TimeDay(time[i + 1]) != TimeDay(time[i])) {
         buffer3[i] = ((high[i] + low[i] + close[i]) / 3.0) * vol;
         buffer4[i] = vol;
         buffer5[i] = 1;
/*
#ifdef __MQL4__
         SetIndexDrawBegin(0, rates_total - (i + 1));
         SetIndexDrawBegin(1, rates_total - (i + 1));
         SetIndexDrawBegin(2, rates_total - (i + 1));
#else
         PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - (i + 1));
         PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, rates_total - (i + 1));
         PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, rates_total - (i + 1));
#endif
*/
      }
      else {
         buffer3[i] = buffer3[i + 1] + (((high[i] + low[i] + close[i]) / 3.0) * vol);
         buffer4[i] = buffer4[i + 1] + vol;
         buffer5[i] = buffer5[i + 1] + 1;
      }

      buffer0[i] = buffer3[i] / buffer4[i];

      //--- standard deviation
      double dev = 0.0;
      for (int k = 0; buffer5[i] > k; k++) dev += pow(close[i + k] - buffer0[i], 2);
      dev = sqrt(dev / buffer5[i]);

      buffer1[i] = buffer0[i] + dev;
      buffer2[i] = buffer0[i] - dev;
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#ifdef __MQL5__
int TimeDay(datetime dt) {
   MqlDateTime dt_struct;
   TimeToStruct(dt, dt_struct);
   return (dt_struct.day);
}
#endif

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
