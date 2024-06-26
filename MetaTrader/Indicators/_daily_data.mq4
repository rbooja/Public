
//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 4

#property indicator_color1 C'178,106,34'
#property indicator_color2 clrGreen
#property indicator_color3 C'178,106,34'
#property indicator_color4 clrGreen

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  1

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

input int BarCount    = 2;
input int CandleShift = 0;

double buffer0[], buffer1[], buffer2[], buffer3[];

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

int OnInit() {

   IndicatorBuffers(4);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);
   SetIndexBuffer(3, buffer3);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);

   if (0 < CandleShift) {
      SetIndexShift(0, CandleShift);
      SetIndexShift(1, CandleShift);
      SetIndexShift(2, CandleShift);
      SetIndexShift(3, CandleShift);
    }

   return (INIT_SUCCEEDED);
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

void OnDeinit(const int reason) {
  //---
  //---
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //---

   double dopen  = iOpen(NULL, PERIOD_D1, 0);
   double dhigh  = iHigh(NULL, PERIOD_D1, 0);
   double dlow   = iLow(NULL, PERIOD_D1, 0);
   double dclose = iClose(NULL, PERIOD_D1, 0);

   setBarIndicator(dopen, dhigh, dlow, dclose);

   if (!prev_calculated || isNewBar(time[0])) {
      for (int i = 1; i < BarCount; i++) {
         dopen  = iOpen(NULL, PERIOD_D1, i);
         dhigh  = iHigh(NULL, PERIOD_D1, i);
         dlow   = iLow(NULL, PERIOD_D1, i);
         dclose = iClose(NULL, PERIOD_D1, i);
         setBarIndicator(dopen, dhigh, dlow, dclose, i);
      }
      for (int i = 0, k = rates_total - BarCount; 4 > i; i++) SetIndexDrawBegin(i, k);
   }

   return (rates_total);
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

void setBarIndicator(double open, double high, double low, double close,
                     int shift = 0) {
   //---
   if (open < close) {
      buffer0[shift] = open;
      buffer1[shift] = close;
      buffer2[shift] = low;
      buffer3[shift] = high;
   }
   else {
      buffer0[shift] = open  + (CompareDoubles(open, close) ? 0.000000001 : 0.0);
      buffer1[shift] = close - (CompareDoubles(open, close) ? 0.000000001 : 0.0);
      buffer2[shift] = high  + (CompareDoubles(high,   low) ? 0.000000001 : 0.0);
      buffer3[shift] = low   - (CompareDoubles(high,   low) ? 0.000000001 : 0.0);
   }
   //---
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+

bool isNewBar(datetime current) {
   static datetime previous;
   if (previous == current) return (false);
   previous = current;
   return (true);
}

//+-----------------------------------------------------------------+
//|                                                                 |
//+-----------------------------------------------------------------+
