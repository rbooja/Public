
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#property indicator_buffers 6
#property indicator_plots   2

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_NONE
#property indicator_type4 DRAW_NONE
#property indicator_type5 DRAW_NONE
#property indicator_type6 DRAW_NONE

#property indicator_color1 clrGreen
#property indicator_color2 C'178,106,34'

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 30;

double pluschange[], minuschange[], pluscf[], minuscf[], plustcf[], minustcf[];
string gname;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

  SetIndexBuffer(0, plustcf);  SetIndexLabel(0, "plus");
  SetIndexBuffer(1, minustcf); SetIndexLabel(1, "minus");
  SetIndexBuffer(2, pluschange);
  SetIndexBuffer(3, minuschange);
  SetIndexBuffer(4, pluscf);
  SetIndexBuffer(5, minuscf);

#ifdef __MQL5__
  // true == ¿ª¼ø ...0
  ArraySetAsSeries(plustcf, true);
  ArraySetAsSeries(minustcf, true);
  ArraySetAsSeries(pluschange, true);
  ArraySetAsSeries(minuschange, true);
  ArraySetAsSeries(pluscf, true);
  ArraySetAsSeries(minuscf, true);
#endif

  string shortname = MQLInfoString(MQL_PROGRAM_NAME) + " (" + (string)period + ")";

  IndicatorSetString(INDICATOR_SHORTNAME, shortname);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);

  gname = _Symbol + "_" + (string)_Period + "_" +
          (string)WindowHandle(_Symbol, 0) + shortname;
  GlobalVariableSet(gname, 0);

  SetHLine(gname + "+0", 0.0, C'30,30,30');

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {

  if (GlobalVariableCheck(gname)) GlobalVariableDel(gname);

  for (int i = ObjectsTotal((long)0); 0 <= i; i--) {
    string name = ObjectName(0, i);
    if (-1 != StringFind(name, gname)) ObjectDelete(0, name);
  }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

#ifdef __MQL5__
  ArraySetAsSeries( high, true);
  ArraySetAsSeries(  low, true);
  ArraySetAsSeries(close, true);
#endif

  if (!prev_calculated) {
    for (int i = rates_total - 2, j = rates_total - (period + 2); j <= i; i--) {
      pluschange[i] = minuschange[i] = pluscf[i] = minuscf[i] = high[i] - low[i];
      plustcf[i] = minustcf[i] = EMPTY_VALUE;
    }
  }

  for (int i = rates_total - (prev_calculated ? prev_calculated : period + 2); 0 <= i; i--) {

    double change = close[i] - close[i + 1];

    pluschange[i] = minuschange[i] = pluscf[i] = minuscf[i] = 0.0;

    if (0 < change) {
      pluschange[i] = change;
      pluscf[i] = pluschange[i] + pluscf[i + 1];
    }

    if (0 > change) {
      minuschange[i] = -change;
      minuscf[i] = minuschange[i] + minuscf[i + 1];
    }

    plustcf[i] = minustcf[i] = 0.0;

    for (int k = 0; k < period; k++) {
      plustcf[i]  += pluschange[i + k]  - minuscf[i + k];
      minustcf[i] += minuschange[i + k] - pluscf[i + k];
    }

  }

  return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SetHLine(string name, double value, color clr) {

  ObjectDelete(0, name);
  ObjectCreate(0, name, OBJ_HLINE, ChartWindowFind(), 0, value);
  ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  ObjectSetInteger(0, name, OBJPROP_BACK, true);
  // ObjectMove(0, name, 0, time, 100);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
