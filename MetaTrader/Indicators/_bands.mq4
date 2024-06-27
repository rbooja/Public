
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 5

#property indicator_color1 C'50,70,90'
#property indicator_color2 C'80,80,80'
#property indicator_color3 C'80,80,80'
#property indicator_color4 C'80,80,80'
#property indicator_color5 C'80,80,80'

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int    period   = 20;
input double multiple = 2.0;

double buffer0[];
double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

   IndicatorBuffers(3);

   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   SetIndexBuffer(2, buffer2);
   SetIndexBuffer(3, buffer3);
   SetIndexBuffer(4, buffer4);

   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexEmptyValue(4, EMPTY_VALUE);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT);
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID);

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
   for (int i = rates_total - (prev_calculated ? prev_calculated : period + 1); 0 <= i; i--) {

      double val = iMA(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);
      double dev = iStdDev(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);

      buffer0[i] = val;
      buffer1[i] = val + dev;
      buffer2[i] = val - dev;
      buffer3[i] = val + dev * multiple;
      buffer4[i] = val - dev * multiple;
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
