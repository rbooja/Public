#property strict

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrTomato
#property indicator_color3 clrRoyalBlue
#property indicator_color4 clrTomato

#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT

//--- input parameters
extern int period = 30;
extern double multiplier = 1.5;

//--- buffers
double dntrend[], uptrend[];
double uparrow[], dnarrow[];
double direction[], up[], dn[];

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //--- checking input data
  //--- indicator buffers
  IndicatorBuffers(7);
  SetIndexBuffer(0, dntrend);
  SetIndexBuffer(1, uptrend);
  SetIndexBuffer(2, uparrow);
  SetIndexBuffer(3, dnarrow);
  SetIndexBuffer(4, direction);
  SetIndexBuffer(5, up);
  SetIndexBuffer(6, dn);
  //--- drawing settings
  IndicatorDigits(_Digits + 1);
  SetIndexStyle(0, DRAW_LINE);
  SetIndexLabel(0, "dn");
  SetIndexStyle(1, DRAW_LINE);
  SetIndexLabel(1, "up");
  SetIndexStyle(2, DRAW_ARROW);
  SetIndexArrow(2, 159);
  SetIndexLabel(2, "start up");
  SetIndexStyle(3, DRAW_ARROW);
  SetIndexArrow(3, 159);
  SetIndexLabel(3, "start dn");
  SetIndexStyle(4, DRAW_NONE);
  SetIndexStyle(5, DRAW_NONE);
  SetIndexStyle(6, DRAW_NONE);
  //--- set short name
  IndicatorShortName(WindowExpertName() + " (" + (string)period + ")");
  //--- set global variables
  return (INIT_SUCCEEDED);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
  //---
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //---
  for (int i = rates_total - (prev_calculated ? prev_calculated : period + 1);
       0 <= i; i--) {
    double atr = iATR(NULL, PERIOD_CURRENT, period, i);
    double median = (high[i] + low[i]) * 0.5;

    up[i] = median + atr * multiplier;
    dn[i] = median - atr * multiplier;

    direction[i] = direction[i + 1];

    if (close[i] > up[i + 1])
      direction[i] = 1;
    if (close[i] < dn[i + 1])
      direction[i] = -1;

    dntrend[i] = EMPTY_VALUE;
    uptrend[i] = EMPTY_VALUE;
    uparrow[i] = EMPTY_VALUE;
    dnarrow[i] = EMPTY_VALUE;

    if (0 < direction[i]) {
      dn[i] = fmax(dn[i], dn[i + 1]);
      dntrend[i] = dn[i];
      if (direction[i] != direction[i + 1])
        uparrow[i] = dntrend[i];
    } else {
      up[i] = fmin(up[i], up[i + 1]);
      uptrend[i] = up[i];
      if (direction[i] != direction[i + 1])
        dnarrow[i] = uptrend[i];
    }
  }

  return (rates_total);
  //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~