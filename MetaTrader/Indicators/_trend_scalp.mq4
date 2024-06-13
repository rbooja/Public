//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DimGray
#property indicator_color2 Gray
#property indicator_color3 DeepSkyBlue
#property indicator_color4 PaleVioletRed
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_style1 STYLE_DOT
#property indicator_level1 0

//
//
//
//
//

extern int TTFbars = 15;
extern int topLine = 100;
extern int bottomLine = -100;
extern double t3Period = 3;
extern double t3Hot = 0.7;
extern bool t3Original = false;
extern bool showTopBottomLevels = true;
extern bool showSignals = true;
extern bool alertsOn = true;
extern bool alertsOnCurrent = true;
extern bool alertsMessage = true;
extern bool alertsSound = false;
extern bool alertsEmail = false;

//
//
//
//
//

double ttf[];
double lev[];
double sigu[];
double sigd[];
double trend[];
double trends[];
double alpha;
double c1, c2, c3, c4;

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int init() {
  IndicatorBuffers(6);
  SetIndexBuffer(0, lev);
  SetIndexBuffer(1, ttf);
  SetIndexBuffer(2, sigu);
  SetIndexStyle(2, DRAW_ARROW);
  SetIndexArrow(2, 159);
  SetIndexBuffer(3, sigd);
  SetIndexStyle(3, DRAW_ARROW);
  SetIndexArrow(3, 159);
  SetIndexBuffer(4, trend);
  SetIndexBuffer(5, trends);

  //
  //
  //
  //
  //

  double a = t3Hot;
  c1 = -a * a * a;
  c2 = 3 * a * a + 3 * a * a * a;
  c3 = -6 * a * a - 3 * a - 3 * a * a * a;
  c4 = 1 + 3 * a + a * a * a + 3 * a * a;
  t3Period = MathMax(1, t3Period);
  if (t3Original)
    alpha = 2.0 / (1.0 + t3Period);
  else
    alpha = 2.0 / (2.0 + (t3Period - 1.0) / 2.0);
  return (0);
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int start() {
  int limit, counted_bars = IndicatorCounted();
  if (counted_bars < 0)
    return (-1);
  if (counted_bars > 0)
    counted_bars--;
  limit = MathMin(Bars - counted_bars, Bars - 1);

  //
  //
  //
  //
  //

  for (int i = limit; i >= 0; i--) {
    double HighestHighRecent = High[i];
    double HighestHighOlder =
        High[iHighest(NULL, 0, MODE_HIGH, TTFbars, i + 1)];
    double LowestLowRecent = Low[i];
    double LowestLowOlder = Low[iLowest(NULL, 0, MODE_LOW, TTFbars, i + 1)];

    double BuyPower = HighestHighRecent - LowestLowOlder;
    double SellPower = HighestHighOlder - LowestLowRecent;
    ttf[i] =
        iT3((BuyPower - SellPower) / (0.5 * (BuyPower + SellPower)) * 100.0, i);

    //
    //
    //
    //
    //

    trend[i] = trend[i + 1];
    if (ttf[i] > 0)
      trend[i] = 1;
    if (ttf[i] < 0)
      trend[i] = -1;
    if (showTopBottomLevels) {
      if (trend[i] == 1)
        lev[i] = topLine;
      if (trend[i] == -1)
        lev[i] = bottomLine;
    }

    if (showSignals) {
      sigu[i] = EMPTY_VALUE;
      sigd[i] = EMPTY_VALUE;
      trends[i] = 0;
      if (ttf[i] > topLine)
        trends[i] = 1;
      if (ttf[i] < bottomLine)
        trends[i] = -1;
      if (trends[i] == 1)
        sigu[i] = topLine;
      if (trends[i] == -1)
        sigd[i] = bottomLine;
    }
  }
  manageAlerts();
  return (0);
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

double workT3[][6];
double iT3(double price, int shift, int forInstance = 0) {
  if (ArrayRange(workT3, 0) != Bars)
    ArrayResize(workT3, Bars);

  //
  //
  //
  //
  //

  int buffer = forInstance * 6;
  int i = Bars - shift - 1;
  if (i < 1) {
    workT3[i][0 + buffer] = price;
    workT3[i][1 + buffer] = price;
    workT3[i][2 + buffer] = price;
    workT3[i][3 + buffer] = price;
    workT3[i][4 + buffer] = price;
    workT3[i][5 + buffer] = price;
  } else {
    workT3[i][0 + buffer] =
        workT3[i - 1][0 + buffer] + alpha * (price - workT3[i - 1][0 + buffer]);
    workT3[i][1 + buffer] =
        workT3[i - 1][1 + buffer] +
        alpha * (workT3[i][0 + buffer] - workT3[i - 1][1 + buffer]);
    workT3[i][2 + buffer] =
        workT3[i - 1][2 + buffer] +
        alpha * (workT3[i][1 + buffer] - workT3[i - 1][2 + buffer]);
    workT3[i][3 + buffer] =
        workT3[i - 1][3 + buffer] +
        alpha * (workT3[i][2 + buffer] - workT3[i - 1][3 + buffer]);
    workT3[i][4 + buffer] =
        workT3[i - 1][4 + buffer] +
        alpha * (workT3[i][3 + buffer] - workT3[i - 1][4 + buffer]);
    workT3[i][5 + buffer] =
        workT3[i - 1][5 + buffer] +
        alpha * (workT3[i][4 + buffer] - workT3[i - 1][5 + buffer]);
  }
  return (c1 * workT3[i][5 + buffer] + c2 * workT3[i][4 + buffer] +
          c3 * workT3[i][3 + buffer] + c4 * workT3[i][2 + buffer]);
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts() {
  if (alertsOn) {
    if (alertsOnCurrent)
      int whichBar = 0;
    else
      whichBar = 1;
    if (trend[whichBar] != trend[whichBar + 1]) {
      if (trend[whichBar] == 1)
        doAlert(whichBar, "up");
      if (trend[whichBar] == -1)
        doAlert(whichBar, "down");
    }
  }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat) {
  static string previousAlert = "nothing";
  static datetime previousTime;
  string message;

  if (previousAlert != doWhat || previousTime != Time[forBar]) {
    previousAlert = doWhat;
    previousTime = Time[forBar];

    //
    //
    //
    //
    //

    message = StringConcatenate(Symbol(), " at ",
                                TimeToStr(TimeLocal(), TIME_SECONDS), " ",
                                " trend scalp trend changed to ", doWhat);
    if (alertsMessage)
      Alert(message);
    if (alertsEmail)
      SendMail(StringConcatenate(Symbol(), "trend scalp "), message);
    if (alertsSound)
      PlaySound("alert2.wav");
  }
}