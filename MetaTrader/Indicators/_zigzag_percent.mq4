//+------------------------------------------------------------------+
//|                                                       ZigZag.mq4 |
//|                   Copyright 2006-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2006-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
#property version "1.0"
#property description "ZigZag"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrTeal

//---- indicator parameters
extern double percent = 2.0;

//---- indicator buffers
double ZzBuffer[];

//--- globals

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit() {
  //--- 2 additional buffers
  IndicatorBuffers(1);

  //---- indicator buffers
  SetIndexBuffer(0, ZzBuffer);
  SetIndexEmptyValue(0, 0.0);

  //---- drawing settings
  SetIndexStyle(0, DRAW_SECTION);

  //---- indicator short name
  string shortname =
      StringConcatenate(WindowExpertName(), " (", percent, " %)");
  IndicatorShortName(shortname);

  //----
  //----

  //---- initialization done
  return (INIT_SUCCEEDED);
  // return (INIT_FAILED);
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
  static int lasthighpos = 0, lastlowpos = 0;
  static double lasthigh = 0.0, lastlow = 0.0, curzz = 0.0;
  // static double pips = 100.0;
  static double up = 1.0 + (percent / 100.0);
  static double dn = 1.0 - (percent / 100.0);

  //--- initialization of zero
  if (!prev_calculated) {
    ArrayInitialize(ZzBuffer, 0.0);
    lasthigh = lastlow = curzz = high[rates_total - 1] - low[rates_total - 1];
    ZzBuffer[rates_total - 1] = curzz;
    // pips = percent * _Point * pointsPerPip();
  }

  //--- main loop
  for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i;
       i--) {

    bool hi = lastlow * up < high[i] && curzz < high[i];
    bool lo = lasthigh * dn > low[i] && curzz > low[i];
    // bool hi = lastlow  + pips < high[i] && curzz < high[i];
    // bool lo = lasthigh + pips >  low[i] && curzz >  low[i];

    if (lo && hi) {
      lo = (bool)lastlowpos;
      hi = (bool)lasthighpos;
    }

    if (lo && !hi) {
      if (lastlowpos)
        ZzBuffer[lastlowpos] = 0.0;
      lastlowpos = i;
      lasthighpos = 0;
      ZzBuffer[i] = lastlow = curzz = low[i];
    }

    if (!lo && hi) {
      if (lasthighpos)
        ZzBuffer[lasthighpos] = 0.0;
      lasthighpos = i;
      lastlowpos = 0;
      ZzBuffer[i] = lasthigh = curzz = high[i];
    }

    // if (!lo && !hi) ZzBuffer[i] = 0.0;
  }

  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  determine the pip multiplier (1 or 10) depending on how many
//  digits the EURUSD symbol has. This is done by first
//  finding the exact name of this symbol in the symbols.raw
//  file (it could be EURUSDm or EURUSDiam or any other stupid name
//  the broker comes up with only to break other people's code)
//  and then usig MarketInfo() for determining the digits.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int pointsPerPip() {
  int ppp = 1;
  int f = FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
  for (int i = 0, count = (int)(FileSize(f) / 1936); i < count; i++) {
    string symbol = FileReadString(f, 12);
    if (-1 != StringFind(symbol, "EURUSD")) {
      int digits = (int)MarketInfo(symbol, MODE_DIGITS);
      ppp = digits == 5 ? 10 : digits == 6 ? 100 : 1;
      break;
    }
    FileSeek(f, 1924, SEEK_CUR);
  }
  FileClose(f);
  return (ppp);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
