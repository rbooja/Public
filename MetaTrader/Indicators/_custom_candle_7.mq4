#property strict

//---- indicator settings
#property indicator_chart_window

//---- input parameters
extern ENUM_TIMEFRAMES timeframe = PERIOD_M15;
extern color plus = clrCornflowerBlue;
extern color minus = clrRed;
extern color equal = clrCornflowerBlue;
extern int width = 1;
extern bool background = false;
extern bool comments = false;
extern bool movewidth = false;
//---- buffers
//---- global variables
int count = 0;
string sBar = "bar M" + (string)timeframe + "-";
string sHigh = "high M" + (string)timeframe + "-";
string sLow = "low M" + (string)timeframe + "-";

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit(void) {
  string shortname =
      "custom candle (" + (string)timeframe + ", " + (string)_Period + ")";
  IndicatorShortName(shortname);

  //----
  return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason) {
  for (int i = 1; i <= count; i++) {
    ObjectDelete(sBar + (string)i);
    ObjectDelete(sHigh + (string)i);
    ObjectDelete(sLow + (string)i);
  }
  if (comments)
    Comment("");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  custom indicator iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  //----
  if (PERIOD_D1 < timeframe) {
    if (comments)
      Comment("\n", " timeframe more than D1 is not supporting!!!");
    return (0);
  }

  // if (PERIOD_H4 < _Period)
  if (PERIOD_H12 < _Period) {
    if (comments)
      Comment("\n", " Period more than H4 is not supporting!!!");
    return (0);
  }

  if (timeframe <= _Period || fmod(timeframe, _Period)) {
    if (comments)
      Comment("\n", " timeframe should be more or divisible by M", _Period);
    return (0);
  }

  //----
  static datetime optime, cltime, wicks;
  static double opvalue;

  bool newbar;
  double hi, lo;
  int shift;
  string object_name;

  if (!prev_calculated) {
    optime = time[rates_total - 1];
    opvalue = open[rates_total - 1];
  }

  //----
  for (int i = rates_total - (prev_calculated ? prev_calculated : 1); 0 <= i;
       i--) {
    newbar = NewBar(timeframe, time[i]);
    if (!newbar && i)
      continue;

    //----
    if (newbar) {
      shift = iBarShift(NULL, PERIOD_CURRENT, optime, true);

      object_name = sBar + (string)count;

      if (!ObjectFind(object_name)) {
        ObjectMove(object_name, 0, optime, opvalue);
        ObjectMove(object_name, 1, time[i + 1], close[i + 1]);
        PropBar(opvalue, close[i + 1], object_name);
        if (shift == i + 1)
          ObjectSet(object_name, OBJPROP_WIDTH, 3 * width);
      }

      object_name = sHigh + (string)count;
      wicks =
          movewidth ? time[i + 1] : time[shift - (int)round((shift - i) / 2)];

      if (!ObjectFind(object_name)) {
        hi = high[iHighest(NULL, 0, MODE_HIGH, shift - i, i + 1)];
        lo = fmax(opvalue, close[i + 1]);

        if (hi == lo)
          ObjectDelete(object_name);
        else {
          ObjectMove(object_name, 0, wicks, lo);
          ObjectMove(object_name, 1, wicks, hi);
          ColorShadow(opvalue, close[i + 1], object_name);
          ObjectSetText(object_name, DoubleToString(hi, _Digits), 7, "Tahoma");
        }
      }

      object_name = sLow + (string)count;

      if (!ObjectFind(object_name)) {
        hi = fmin(opvalue, close[i + 1]);
        lo = low[iLowest(NULL, 0, MODE_LOW, shift - i, i + 1)];

        if (hi == lo)
          ObjectDelete(object_name);
        else {
          ObjectMove(object_name, 0, wicks, hi);
          ObjectMove(object_name, 1, wicks, lo);
          ColorShadow(opvalue, close[i + 1], object_name);
          ObjectSetText(object_name, DoubleToString(lo, _Digits), 7, "Tahoma");
        }
      }

      //----
      opvalue = open[i];
      optime = time[i];
      cltime = time[i] + (timeframe - _Period) * 60;
      wicks = movewidth ? time[i]
                        : time[i] + (int)round(timeframe / _Period / 2) *
                                        _Period * 60;
      count++;
    }

    shift = iBarShift(NULL, PERIOD_CURRENT, optime, true);

    //----
    object_name = sBar + (string)count;

    if (ObjectFind(object_name)) {
      ObjectCreate(object_name, OBJ_RECTANGLE, 0, optime, opvalue, cltime,
                   close[i]);
      ObjectSet(object_name, OBJPROP_STYLE, STYLE_SOLID);
      PropBar(opvalue, close[i], object_name);
    } else {
      ObjectMove(object_name, 1, cltime, close[i]);
      PropBar(opvalue, close[i], object_name);
    }

    object_name = sHigh + (string)count;

    if (ObjectFind(object_name)) {
      ObjectCreate(object_name, OBJ_TREND, 0, wicks, fmax(opvalue, close[i]),
                   wicks, high[i]);
      ObjectSet(object_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(object_name, OBJPROP_WIDTH, width);
      ObjectSet(object_name, OBJPROP_RAY, false);
      ColorShadow(opvalue, close[i], object_name);
    } else {
      hi = high[iHighest(NULL, 0, MODE_HIGH, shift + 1, i)];
      ObjectMove(object_name, 0, wicks, fmax(opvalue, close[i]));
      ObjectMove(object_name, 1, wicks, hi);
      ColorShadow(opvalue, close[i], object_name);
    }

    object_name = sLow + (string)count;

    if (ObjectFind(object_name)) {
      ObjectCreate(object_name, OBJ_TREND, 0, wicks, fmin(opvalue, close[i]),
                   wicks, low[i]);
      ObjectSet(object_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(object_name, OBJPROP_WIDTH, width);
      ObjectSet(object_name, OBJPROP_RAY, false);
      ColorShadow(opvalue, close[i], object_name);
    } else {
      lo = low[iLowest(NULL, 0, MODE_LOW, shift + 1, i)];
      ObjectMove(object_name, 0, wicks, fmin(opvalue, close[i]));
      ObjectMove(object_name, 1, wicks, lo);
      ColorShadow(opvalue, close[i], object_name);
    }
  }

  //----
  if (comments) {
    Comment("O:", opvalue, ", H:", hi, ", L:", lo, ", C:", close[0]);
  }

  //----
  return (rates_total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool NewBar(int tf, datetime time) {
  static int previous = 0;
  int current = iBarShift(NULL, tf, time, true);
  if (!previous) {
    previous = current;
    return (false);
  }
  if (previous == current)
    return (false);
  previous = current;
  return (true);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void PropBar(double open, double close, string object_name) {
  string text =
      DoubleToString(open, _Digits) + ", " + DoubleToString(close, _Digits);
  color clr = (open < close ? plus : open > close ? minus : equal);

  ObjectSetText(object_name, text, 7, "Tahoma");
  ObjectSet(object_name, OBJPROP_COLOR, clr);
  ObjectSet(object_name, OBJPROP_WIDTH, width);
  ObjectSet(object_name, OBJPROP_BACK, background);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ColorShadow(double open, double close, string object_name) {
  color clr = (open < close ? plus : open > close ? minus : equal);
  ObjectSet(object_name, OBJPROP_COLOR, clr);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~