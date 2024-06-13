
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots   3

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_ARROW

#property indicator_color1 clrDimGray
#property indicator_color2 clrDimGray
#property indicator_color3 clrRed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 20;
input int signal = 10;

double buffer0[], buffer1[], buffer2[];
int    handle;
int    bars = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit()
  {
    SetIndexBuffer(0, buffer0, INDICATOR_DATA);
    SetIndexBuffer(1, buffer1, INDICATOR_DATA);
    SetIndexBuffer(2, buffer2, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_ARROW, 158);

    handle = iATR(NULL, PERIOD_CURRENT, period);

    if (handle == INVALID_HANDLE)
      {
        PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d", _Symbol, EnumToString(PERIOD_CURRENT), GetLastError());
        return (INIT_FAILED);
      }

    IndicatorSetString(INDICATOR_SHORTNAME, "\0");

    return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
    if (INVALID_HANDLE != handle) IndicatorRelease(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {

    int copy = rates_total - (prev_calculated ? prev_calculated - 1 : 0);
    if (0 > CopyBuffer(handle, 0, 0, copy, buffer0)) return (0);

    for (int i = (prev_calculated ? prev_calculated - 1 : period); rates_total > i; i++)
      {
        buffer1[i] = SMA(buffer0, signal, i);
        buffer2[i] = buffer1[i] < buffer0[i] ? buffer0[i] : EMPTY_VALUE;
      }

    return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double SMA(double& array[], int per, int bar)
  {
    double sum = 0;
    for (int i = 0; per > i; i++) sum += array[bar - i];
    return (sum / per);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
