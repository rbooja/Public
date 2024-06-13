
#property strict
#property indicator_chart_window

#import "user32.dll"
  int SetWindowLongW(int hWnd, int nIndex, int dwNewLong);
  int GetWindowLongW(int hWnd, int nIndex);
  int SetWindowPos(int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);
  int GetParent(int hWnd);
#import

#define GWL_STYLE         -16
#define WS_CAPTION        0x00C00000
#define WS_BORDER         0x00800000
#define WS_SIZEBOX        0x00040000
#define WS_DLGFRAME       0x00400000
#define SWP_NOSIZE        0x0001
#define SWP_NOMOVE        0x0002
#define SWP_NOZORDER      0x0004
#define SWP_NOACTIVATE    0x0010
#define SWP_FRAMECHANGED  0x0020

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
  //---
  ToggleYscale();
  HideBorder(true);
  ButtonCreate(0, "y-scale", 0, 1, 1, 20, 12, CORNER_LEFT_UPPER, "Y");
  ButtonCreate(0, "hide-border", 0, 22, 1, 20, 12, CORNER_LEFT_UPPER, "S");
  return (INIT_SUCCEEDED);
  //---
}

void OnDeinit(const int reason) {
  //---
  ObjectDelete(0, "y-scale");
  ObjectDelete(0, "hide-border");
  //---
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam) {
  //---
  if (id == CHARTEVENT_OBJECT_CLICK) {
    Print(sparam);
    if (sparam == "y-scale") {
      ToggleYscale();
      // ObjectSetInteger(0, "y-scale", OBJPROP_STATE, false);
    }
    if (sparam == "hide-border") {
      string text = ObjectGetString(0, "hide-border", OBJPROP_TEXT);
      if (text == "S") {
        HideBorder(false);
        ObjectSetString(0, "hide-border", OBJPROP_TEXT, "H");
      }
      if (text == "H") {
        HideBorder(true);
        ObjectSetString(0, "hide-border", OBJPROP_TEXT, "S");
      }
      // ObjectSetInteger(0, "hide-border", OBJPROP_STATE, false);
    }
  }
  //---
}

// https://docs.mql4.com/constants/objectconstants/enum_object/obj_button
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+

bool ButtonCreate(const long chart_ID = 0,      // chart's ID
                  const string name = "Button", // button name
                  const int sub_window = 0,     // subwindow index
                  const int x = 0,              // X coordinate
                  const int y = 0,              // Y coordinate
                  const int width = 50,         // button width
                  const int height = 18,        // button height
                  const ENUM_BASE_CORNER corner =
                      CORNER_LEFT_UPPER,        // chart corner for anchoring
                  const string text = "Button", // text
                  const string font = "Tahoma",  // font
                  const int font_size = 8,     // font size
                  const color clr = clrBlack,   // text color
                  const color back_clr = C'70,70,70', // background color
                  const color border_clr = clrNONE,       // border color
                  const bool state = false,               // pressed/released
                  const bool back = false,                // in the background
                  const bool selection = false,           // highlight to move
                  const bool hidden = false, // hidden in the object list
                  const long z_order = 0)   // priority for mouse click
{
  //--- reset the error value
  ResetLastError();
  //--- create the button
  if (!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
    Print(__FUNCTION__,
          ": failed to create the button! Error code = ", GetLastError());
    return (false);
  }
  //--- set button coordinates
  ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
  ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
  //--- set button size
  ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
  ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
  //--- set the chart's corner, relative to which point coordinates are defined
  ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
  //--- set the text
  ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
  //--- set text font
  ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
  //--- set font size
  ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
  //--- set text color
  ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
  //--- set background color
  ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
  //--- set border color
  ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
  //--- display in the foreground (false) or background (true)
  ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
  //--- set button state
  ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
  //--- enable (true) or disable (false) the mode of moving the button by mouse
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
  //--- hide (true) or display (false) graphical object name in the object list
  ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
  //--- set the priority for receiving the event of a mouse click in the chart
  ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
  //--- successful execution
  return (true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ToggleYscale() {
  if (PERIOD_M1 < _Period) {
    ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, 0, !ChartGetInteger(0, CHART_SHOW_PRICE_SCALE));
  }
}

void HideBorder(bool hide = true) {
  int iChartParent = GetParent(WindowHandle(_Symbol, 0));
  int iNewStyle = GetWindowLongW(iChartParent, GWL_STYLE);
  if (hide) {
    iNewStyle = iNewStyle & (~(WS_BORDER | WS_DLGFRAME | WS_SIZEBOX));
  } else {
    iNewStyle = iNewStyle | WS_BORDER | WS_DLGFRAME | WS_SIZEBOX;
  }
  if (0 < iChartParent && 0 < iNewStyle) {
    SetWindowLongW(iChartParent, GWL_STYLE, iNewStyle);
    SetWindowPos(iChartParent, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
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
  //---
  return (rates_total);
  //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
