#property copyright "2005-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
#property version "1.0"
#property description "Parabolic Stop-And-Reversal system"
#property strict

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrOlive

//---- input parameters
input double step = 0.02;; // 0.025
input double maximum = 0.2;; // 0.5

//---- buffers
double buffer[];

//---- global variables

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  //---- checking input data
  //---- indicator buffers
  IndicatorBuffers(1);
  SetIndexBuffer(0, buffer);
  SetIndexLabel(0, "parabolic");

  //---- drawing settings
  IndicatorDigits(_Digits);
  SetIndexStyle(0, DRAW_ARROW);
  SetIndexArrow(0, 159);

  //---- set short name
  string shortname =
      StringConcatenate(WindowExpertName(), " (", DoubleToString(step, 2),
                        DoubleToString(maximum, 2), ")");
  IndicatorShortName(shortname);

  //---- set global variables
  //----
  return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
  //----
  //----
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //---- initialization of zero
  //---- the main cycle of indicator calculation
  for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i;
       i--) {
    buffer[i] = iSAR(NULL, PERIOD_CURRENT, step, maximum, i);
  }

  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~