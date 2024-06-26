
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 clrTeal

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double buffer0[], buffer1[], buffer2[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit() {

   IndicatorBuffers(3);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);

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
   //---
   if (!prev_calculated) {
      int i = rates_total - 1;
      buffer1[i] = ((high[i] + low[i] + close[i]) / 3.0) * tick_volume[i];
      buffer2[i] = (double)tick_volume[i];
      buffer0[i] = buffer1[i] / buffer2[i];
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= i; i--) {

      double value = (high[i] + low[i] + close[i]) / 3.0;

      if (TimeDay(time[i + 1]) != TimeDay(time[i])) {
         buffer1[i] = value * tick_volume[i];
         buffer2[i] = (double)tick_volume[i];
         // SetIndexDrawBegin(0, rates_total - (i + 1));
      }
      else {
         buffer1[i] = buffer1[i + 1] + value * tick_volume[i];
         buffer2[i] = buffer2[i + 1] + (double)tick_volume[i];
      }

      buffer0[i] = buffer1[i] / buffer2[i];
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
