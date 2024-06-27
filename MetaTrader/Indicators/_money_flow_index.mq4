
#property strict
#property indicator_separate_window

#property indicator_buffers 2

#property indicator_color1  clrGray
#property indicator_color2  clrTeal

extern int period = 14;
extern int signal = 9;

double buffer0[], buffer1[];

int OnInit(void) {

   IndicatorBuffers(2);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);

   IndicatorDigits(2);

   SetLevelValue(0, 20.0);
   SetLevelValue(1, 50.0);
   SetLevelValue(2, 80.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1973790);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, -1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH, -1);

   return (INIT_SUCCEEDED);
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

   for (int i = rates_total - (prev_calculated ? prev_calculated : period + 2); 0 <= i; i--) {

      double positive = 0.0;
      double negative = 0.0;
      double current  = (high[i] + low[i] + close[i]) / 3.0;

      for (int j = 0; period > j; j++) {
         double previous = (high[i + j + 1] + low[i + j + 1] + close[i + j + 1]) / 3.0;
         if (previous < current) positive += tick_volume[i + j] * current;
         if (previous > current) negative += tick_volume[i + j] * current;
         current = previous;
      }

      if (0.0 != negative)
         buffer1[i] = 100.0 - 100.0 / (1.0 + positive / negative);
      else
         buffer1[i] = 100.0;

      buffer0[i] = SMA(buffer1, signal, i);
   }

   return (rates_total);
}

double SMA(double &array[], int per, int bar) {
   double Sum = 0.;
   for (int i = 0; i < per; i++) Sum += array[bar + i];
   return (Sum / per);
}