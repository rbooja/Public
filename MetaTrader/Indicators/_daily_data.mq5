
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  _daily_data.mq4
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#property indicator_chart_window

#property indicator_buffers 8
#property indicator_plots   4

#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  C'0,100,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  C'0,100,0'
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_type3   DRAW_HISTOGRAM2
#property indicator_color3  C'100,0,0'
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_type4   DRAW_HISTOGRAM2
#property indicator_color4  C'100,0,0'
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

input int CandleShift = 4;
input int BarCount    = 2;

double buffer0[];
double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //---
  SetIndexBuffer(0, buffer0, INDICATOR_DATA);
  SetIndexBuffer(1, buffer1, INDICATOR_DATA);
  SetIndexBuffer(2, buffer2, INDICATOR_DATA);
  SetIndexBuffer(3, buffer3, INDICATOR_DATA);
  SetIndexBuffer(4, buffer4, INDICATOR_DATA);
  SetIndexBuffer(5, buffer5, INDICATOR_DATA);
  SetIndexBuffer(6, buffer6, INDICATOR_DATA);
  SetIndexBuffer(7, buffer7, INDICATOR_DATA);

  //--- setting buffer arrays as timeseries
  ArraySetAsSeries(buffer0, true);
  ArraySetAsSeries(buffer1, true);
  ArraySetAsSeries(buffer2, true);
  ArraySetAsSeries(buffer3, true);
  ArraySetAsSeries(buffer4, true);
  ArraySetAsSeries(buffer5, true);
  ArraySetAsSeries(buffer6, true);
  ArraySetAsSeries(buffer7, true);

  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, 0);
  PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, 0);

  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
  PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);

  PlotIndexSetInteger(0, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(1, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(2, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(3, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(4, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(5, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(6, PLOT_SHIFT, CandleShift);
  PlotIndexSetInteger(7, PLOT_SHIFT, CandleShift);

  //--- initialization done
  return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
  //---
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
  //----
  if (rates_total != prev_calculated) {
    for (int i = 0; i < 8; i++)
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, rates_total - BarCount);
  }

  double O, H, L, C;

  for (int i = 0 ; BarCount > i; i++) {
    O =  iOpen(NULL, PERIOD_D1, i);
    H =  iHigh(NULL, PERIOD_D1, i);
    L =   iLow(NULL, PERIOD_D1, i);
    C = iClose(NULL, PERIOD_D1, i);
    SetBarIndicator(O, H, L, C, i);
  }

  return (rates_total);
  //----
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void SetBarIndicator(double open, double high, double low, double close, int shift) {
  if (open < close) {
    buffer0[shift] = high;
    buffer1[shift] = low;
    buffer2[shift] = open;
    buffer3[shift] = close;
    buffer4[shift] = 0;
    buffer5[shift] = 0;
    buffer6[shift] = 0;
    buffer7[shift] = 0;
  } else {
    buffer0[shift] = 0;
    buffer1[shift] = 0;
    buffer2[shift] = 0;
    buffer3[shift] = 0;
    buffer4[shift] = high;
    buffer5[shift] = low;
    buffer6[shift] = open;
    buffer7[shift] = close;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
