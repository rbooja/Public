
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_buffers 3

#property indicator_color1 clrDimGray
#property indicator_color2 clrDimGray
#property indicator_color3 clrRed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int fast   = 20;
input int slow   = 50;
input int signal = 10;

//--- buffers
double buffer0[], buffer1[], buffer2[];
double buffer3[], buffer4[], buffer5[], buffer6[], buffer7[], buffer8[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

   IndicatorBuffers(9);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);
   SetIndexBuffer(3, buffer3);
   SetIndexBuffer(4, buffer4);
   SetIndexBuffer(5, buffer5);
   SetIndexBuffer(6, buffer6);
   SetIndexBuffer(7, buffer7);
   SetIndexBuffer(8, buffer8);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 158);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexStyle(8, DRAW_NONE);

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
      buffer3[i] = open[i] - close[i];
      buffer4[i] = fabs(buffer3[i]);
      buffer5[i] = buffer3[i];
      buffer6[i] = buffer4[i];
      buffer7[i] = buffer5[i];
      buffer8[i] = buffer6[i];
      buffer0[i] = (buffer8[i] ? buffer7[i] / buffer8[i] : 0);
      buffer1[i] = buffer0[i];
      buffer2[i] = EMPTY_VALUE;
   }

   for (int i = rates_total - (prev_calculated ? prev_calculated : 2); 0 <= i; i--) {
      buffer3[i] = close[i] - close[i + 1];
      buffer4[i] = fabs(buffer3[i]);

      buffer5[i] = iMAOnArray(buffer3, 0, fast, 0, MODE_EMA, i);
      buffer6[i] = iMAOnArray(buffer4, 0, fast, 0, MODE_EMA, i);

      buffer7[i] = iMAOnArray(buffer5, 0, slow, 0, MODE_EMA, i);
      buffer8[i] = iMAOnArray(buffer6, 0, slow, 0, MODE_EMA, i);

      buffer0[i] = (buffer8[i] ? buffer7[i] / buffer8[i] : 0);
      buffer1[i] = iMAOnArray(buffer0, 0, signal, 0, MODE_SMA, i);

      buffer2[i] = 0 < buffer0[i] && buffer1[i] < buffer0[i] && buffer0[i + 1] < buffer0[i] ? buffer0[i] : 0 > buffer0[i] && buffer1[i] > buffer0[i] && buffer0[i + 1] > buffer0[i] ? buffer0[i] : EMPTY_VALUE;
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
