// +------------------------------------------------------------------------------------------------------------------+
// |                                                                                                    Auto_Sessions |
// |                                                                                        Copyright © 2010, cameofx |
// |                                                                                                cameofx@gmail.com |
// | Home thread, with latest updates:  https://www.forexfactory.com/showthread.php?t=239188                          |
// |                                                                                                                  |
// | CHANGELOG                                                                                                        |
// | v1.0,  2010-Jun-01  cameofx of forexfactory.com                                                                  |
// | v1.8,  2011-Jul-24  Jani Verho                                                                                   |
// |   - Added GMT shift                                                                                              |
// | v1.9,  2013-Mar-27  Rocky Lin  linlei@gmail.com                                                                  |
// |   - determining server timezone and shift time frame automatically, reboot is needed after switching server in   |
// |     different timezone                                                                                           |
// |   - Simplified some codes on timezone shifting.                                                                  |
// | v2.0, 2016-Dec-20  Big Be  (4X Los Angeles in Meetup.com or 4xlosangeles club)                                   |
// |   - Made "server timezone and shift time frame automatically" work right; eliminated need for LocalTimezone      |
// |     input.                                                                                                       |
// |   - Differentiated global and local variable names                                                               |
// |   - Made some variable names more clear                                                                          |
// | v2.1, 2017-Jun-23  MrPip  (4X Los Angeles in Meetup.com or 4xlosangeles club)                                    |
// |   - Added code to allow turning off of gadSessPips display.                                                      |
// | v2.2, 2017-Jun-23  MrPip  (4X Los Angeles in Meetup.com or 4xlosangeles club)                                    |
// |   - Added code to allow turning off of Session display.                                                          |
// | v2.3, 2017-Nov-18  hanover of forexfactory.com                                                                   |
// |   - updated GMT-offset things, and maybe other (no code or documentation)                                        |
// | v2.4 (called "v1.9" in forum), 2019-Mar-20  MikeDNC of forexfactory.com                                          |
// |   - Fixed the visualization problems that occurred regularly when one or more new candles were downloaded, which |
// |     occurs after terminal startup or reconnection.  There are inputs to adjust its performance.                  |
// |   - Fixed all other known bugs.                                                                                  |
// |   - New input: "Max bars" to go back.                                                                            |
// |   - New input: Whether to remove all sessions upon indicator removal.                                            |
// |   - New inputs: Minimum and maximum timeframes to draw the sessions on.                                          |
// |       This can be handy if you want the chart less cluttered on the H4 timeframe, for example.                   |
// |   - Object names now have a readable date (View in MT4 by pressing Ctrl+B) and are sorted by date.               |
// |   - Cleaned up a lot (but not all) of the existing formatting and variable names.                                |
// |   - "#property strict" now, which further ensures good coding.                                                   |
// |   - Indicator default sessions are now only London and NY, with fine-tuned colors that contrast well (including  |
// |     int the overlap area) with a lot of other colors on other indicators -- making a nice readable screen, at    |
// |     least on a white-ish background (optimized for WhiteSmoke).                                                  |
// |   - Updated the contact link with my email, as the current maintainer and request taker :).                      |
// | v2.5, 2019-Mar-30  MikeDNC of forexfactory.com                                                                   |
// |   - Updated the version number to syncronize with others' releases.                                              |
// |     Note: "2.0" in software is traditionally a major new release (almost a new product), with "0.1's" for        |
// |     updates and "0.01's" for bug fixes.  But historical clarity is more important.                               |
// |   - Can now turn each session on and off: "0/0/0/1/1".                                                           |
// |     Can also turn pips on and off.  (But if a session is off, its pips will automatically be off).               |
// |   - Fixed bug: Now if a "color" is "None", pips will be off.                                                     |
// |   - Option to "Fill boxes" or not.                                                                               |
// |   - Pips precision can be set.                                                                                   |
// |   - Pips will now appear aligned in the expected place in almost any font, of any size, with any number of pips, |
// |     provided that the new "fixed width font" input is set.                                                       |
// |   - Options to set object prefix, tooltip, and whether object appears in list (Ctrl+B).                          |
// |   - Fixed bug:  Custom timeframes ("offline charts") not updating.  {BTW, the best script for using custom       |
// |     timeframes that I have found is "PeriodCon 509 by P4L", located here,                                        |
// |     https://www.forexfactory.com/showthread.php?t=206301                                                         |
// |   - Fixed bug:  "24:00" now displays as expected.  Any hour >=24 is now converted to 0-23.                       |
// |   - Updated all previous code to have descriptive variable names in a uniform format, clear formatting (I hope), |
// |     documentation, simpler loops, and more efficient logic in a couple places.                                   |
// |   - Consolidated "Changelog" from all other versions (that I could find in the forum).                           |
// | v2.6, 2019-Apr-01  MikeDNC of forexfactory.com                                                                   |
// |   - Fixed bug:  The "tall sessions" problem no longer occurs, so the whole "redrawing" thing is no longer        |
// |       necessary!  This was a long-standing bug since the very first version back in 2010.  Woot!                 |
// | v2.61, 2019-Apr-02  MikeDNC of forexfactory.com                                                                  |
// |   - Fixed bug:  The "tall/short sessions" problem still occurs on custom timeframes, so the "redrawing" will be  |
// |       done only on custom timeframes.                                                                            |
// |   - Fixed bug:  If downloading new bars that begin before today's midnight, the earliest day's sessions were     |
// |       sometimes too short.                                                                                       |
// | v2.7, 2019-Aug-10  MikeDNC of forexfactory.com                                                                   |
// |   - New input: Show session name before its pips.  (Thanks to Styngray on FF for the suggestion)                 |
// |   - New input: Show session tooltip.                                                                             |
// |     Removed tooltip from pips since it began *before* the beginning of the session.                              |
// |   - Removed inactive input "RedrawUponConnect", which is set automatically now.                                  |
// |   - Specified "may" for the optional time-checking URL, since it's optional&changeable.                          |
// |   - Increased size of $MAX_SPACES, just in case someone has a lot of text to add.                                |
// |   - Added a version string which shows up in the "About" tab, in case indicator file gets renamed.               |
// | v2.8, 2019-Aug-11  MikeDNC of forexfactory.com                                                                   |
// |   - New input: "ShowBoxes", which allows to show only the Name or Pips, with no Box.                             |
// |       (Tip came courtesy of Styngray on FF)                                                                      |
// |   - Changed the name of the input ""FillSessions" to ""FillBoxes",                                               |
// |       and filled in default values for this and "TimeMethod".                                                    |
// |   - Added "markethours.net" link in the About box.  (Thanks to FXAficionada on FF for the tip)                   |
// | v2.9, 2019-Sep-05  MikeDNC of forexfactory.com                                                                   |
// |   - New input: "PipsWord", which allows to show or hide " pips" after the pips.                                  |
// |       (Thanks to drayzen on FF for the suggestion)                                                               |
// |   - " pips" will be singular, " pip", when the number is <=1 .                                                   |
// | v2.91, 2020-Mar-26  MikeDNC of forexfactory.com                                                                  |
// |   - Removed the unintended comment in the Color4 parameter.                                                      |
// |   - Indicator automatically does not show anymore in the Data Window, since this is always empty anyway.         |
//   v21.169, 2021-169th day (2021-6-18) iDiamond of forexfactory.com
//     - Beautified/Standardized source code using Uncrustify of UniversalIndentGUI
//     - Too many changes to list (hundreds) to modernize for MetaTrader 5 compatibility.
//   v21.173, 2021-day 173 (2021-6-22) iDiamond of forexfactory.com
//     - Added Vertical Fill and Vertical Line options
//     - Added Session Name/Pip Text options for Base Corner and Anchor Point
//     - Descriptive Input Variable names
//     - Rewrote to eliminate the prior redraw delay scheme due to
//       MetaTrader 5 Runtime Messages "indicator is too slow, #### ms. rewrite the indicator, please"
//       Corrected OnCalculate() return values, which was a significant reason for slow performance.
//       Prior comments indicated the prior redraw delay scheme was for Custom Timeframes, File-->Open Offline.
//       After replacing the old scheme, File->Open Offline charts still seem to work. If anyone notices otherwise
//       new code should be established using current MetaTrader standards, rather than the old slow scheme.
//   v21.182, 2021-day 182 (2021-7-1) iDiamond of forexfactory.com
//     - Added Vertical Fill in All Sub-Windows and Horizontal Lines options
//     - Reduced usage of Global variables
//     - Modified Session End times to one second before the prior coded end times.
//       For example, the New York Session End Time was coded as 17:00:00, although that is actually when the
//       New York session is closed. There should never be a price quote for the New York session at 17:00:00.
//       Likewise, Midnight, i.e. HH:MM:SS of 00:00:00, is the start of the trading day and 11:59:59 is the last
//       second of the prior trading day with MetaTrader price quotes.
//       Coding the New York Session End Time as 16:59:59 gives more accurate session price values.
//       Note that MetaTrader 5 has a "Precise time scale" option to position an object at any point between bars.
//     - Reworked OnCalculate() to process Bars starting from the [0] end. 
//       This helps display when loading historical data on newly used symbols.
//   v21.184, 2021-day 184 (2021-7-3) iDiamond of forexfactory.com
//     - Individual Styles for each Session
//   
//   
//   https://www.timeanddate.com/time/   
//   
//       New York, 
//       Eastern Standard Time (EST),              UTC/GMT -5h
//       Eastern Daylight Time (EDT),              UTC/GMT -4h, March 14, 2021 to November 7, 2021
//       
//       Wellington, New Zealand,
//       New Zealand Daylight Time (NZDT),         UTC/GMT +13h
//       New Zealand Standard Time (NZST),         UTC/GMT +12h, April 4, 2021 - September 26, 2021
//
//       Sydney, 
//       Australian Eastern Daylight Time (AEDT),  UTC/GMT +11h
//       Australian Eastern Standard Time (AEST),  UTC/GMT +10h, April 4, 2021 - October 3, 2021
//
//       Tokyo, 
//       JST — Japan Standard Time (JST),          UTC/GMT +9h, All Year
//
//       Frankfurt, 
//       Central European Time (CET),              UTC/GMT +1h
//       Central European Summer Time (CEST),      UTC/GMT +2h, March 28, 2021 - October 31, 2021
//
//       London, 
//       Greenwich Mean Time (GMT),                UTC/GMT +0h
//       British Summer Time (BST),                UTC/GMT +1h, March 28, 2021 - October 31, 2021
//            
//   https://www.babypips.com/learn/forex/forex-trading-sessions
//
// ____________________________________________________________________________________________________________________
// |                                                                                                                  |
// |   - There is a new option to use "Broker Eastern Time offset" instead of the hours strings.  Almost all brokers  |
// |     today maintain a constant Eastern offset; they change their GMT offset when daylight savings happens in NY.  |
// |     This is to maintain a constant market open on the charts -- usually 00:00.                                   |
// |          The Forex market has always opened at 17:00 Eastern *local* time, every day for decades at least.       |
// |     When daylight savings happens in NY, everything else in Forex stays the same (NY always opens 5 hours after  |
// |     London, and all of the sessions remain 9 hours long).  So, other banks around the world sometimes have to    |
// |     to start work an hour earlier to maintain this.                                                              |
// |          The option could instead use a "Sydney open time offset / Forex open time offset / London open time     |
// |     offset / NY open time offset".  I think Eastern offset is easiest to check and be confident of, especially   |
// |     for newer traders (since it requires no knowledge of Forex).                                                 |
// |                                                                                                                  |
// |                                                                                                                  |
// |     So, if the broker's charts look the same all year, (which means that the broker is changing their clock      |
// |     with NY daylight savings), then one may set this "Eastern offset" once and then forget it.                   |
// |          If not (which is uncommon), and it appears that the London, NY, and other sessions are opening an hour  |
// |     earlier during approximately Nov to Mar, then one may adjust the Eastern offset -1 during Eastern daylight   |
// |     savings.                                                                                                     |
// |                                                                                                                  |
// |         -OR- There is a second option to manually set all the hours, which covers any possible situation, or for |
// |              experimenting, etc.                                                                                 |
// |                                                                                                                  |
// |          Note: I have decided _not_ to include an option to adjust a "Broker GMT offset", because:               |
// |            For brokers that do not change their clock all year (if there are any that do this), they do not      |
// |            change their GMT offset.  Instead, all the market sessions open an hour earlier during Eastern        |
// |            daylight savings -- opening earlier on the charts.  As you can see, the broker's "Eastern offset" has |
// |            changed.  And for brokers that keep the same offset from Eastern time all year, it's easiest just to  |
// |            set its Eastern offset.                                                                               |
// | _________________________________________________________________________________________________________________|
// | A very fine Forex market hours tool, that is adjustable for any timezone, and has always been very accurate and  |
// |   up-to-date since at least 2006:                                                                                |
// |   Online:             http://www.forexmarkethours.com/                                                           |
// |                                                                                                                  |
// | Hours with more features:                                                                                        |
// |                       www.markethours.net                                                                        |
// +------------------------------------------------------------------------------------------------------------------+
// #property indicator_buffers 1  // just a dummy buffer, to allow "SetIndexLabel(1, NULL)" to hide the indicator in the Data Window.
//                                                                                                                  


#define PROPERTY_COPYRIGHT     "2021 Modifications by iDiamond"
#define PROPERTY_VERSION       "21.184"                          // Year.Day of Year
#define PROPERTY_LINK          "https://www.forexfactory.com/showthread.php?t=239188"

#define PROPERTY_DESCRIPTION_1 "Highlight Session Trading Periods"
#define PROPERTY_DESCRIPTION_2 " "
#define PROPERTY_DESCRIPTION_3 "Display up to a maximum of 5 different Session periods"
#define PROPERTY_DESCRIPTION_4 " "
#define PROPERTY_DESCRIPTION_5 "Check Eastern local time: www.timeanddate.com/worldclock/usa/new-york"
#define PROPERTY_DESCRIPTION_6 "Reliable Forex hours: www.forexmarkethours.com, www.markethours.net"

#ifdef __MQL4__
#define MQL4(x) x
#else
#define MQL4(x)
#endif

#ifdef __MQL5__
#define MQL5(x) x
#else
#define MQL5(x)
#endif

#define DEBUG 0                // #define DEBUG 1   // Print useful info in the Experts tab.
#define DbugInfo(x) x          // define as x for informational debugging 4

#define INPUTVARDELIMITER      "================================"

#define ONEHOURsecs 3600       // 1 hour in seconds
#define ONEDAYsecs  86400      // 1 day in seconds
#define ONEDAYmins  1440       // 1 day in minutes
#define NAMEPIPDELIMITER " "   // String between Session Name and Session Pips
#define NAMEPIPMARGIN    " "   // Pad the Session Text with this string
#define REASON_USER_INIT 2021  // Custom OnDeinit() reason
#define WINMAXVAL 100.0        // Sufficiently large Window Minimum/Maximum that will ever be visible during whole Timeseries scroll
                               // June 2021 MT5 version didn't display objects when 10000.0 and above 

#define MAX_SESSIONS 5  // This should be equal to the number of input colors and >= the number of sessions in $SESS_NAMES_DFAULT
#define SESS_NAMES_DEFAULT "Sydney/Tokyo/Frankfurt/London/NY"   // These should all be unique.

// enum eTimeMethod {Broker_Eastern_offset, Broker_GMT_offset, Manual};
enum ENUM_TimeMethod   { Broker_Eastern_Offset, // Broker Eastern Time Zone Offset
                         Manual                 // Manual Input of Start and End Times 
                       };
enum ENUM_SessionStyle { Rectangle_Fill,            // Filled Rectangle
                         Rectangle_Line,            // Line Bordered Rectangle 
                         Vertical_Fill,             // Filled Vertical
                         Vertical_Lines,            // Vertical Lines, Begin and End
                         Vertical_Line_Begin,       // Vertical Line, Begin
                         Vertical_Line_End,         // Vertical Line, End
                         Vertical_Fill_All,         // Filled Vertical in all Sub-Windows                         
                         Vertical_Lines_All,        // Vertical Lines in all Sub-Windows, Begin and End
                         Vertical_Lines_All_Begin,  // Vertical Lines in all Sub-Windows, Begin
                         Vertical_Lines_All_End,    // Vertical Lines in all Sub-Windows, End
                         Horizontal_Lines,          // Horizontal Lines, High and Low
                         Horizontal_Line_High,      // Horizontal Line, High
                         Horizontal_Line_Low        // Horizontal Line, Low
                       };                  
enum ENUM_LineType     { VLine_Begin, VLine_End, HLine_High, HLine_Low };

sinput string            SessionNames           = SESS_NAMES_DEFAULT;               // Session Names
sinput string            ShowSessions           = "1/0/0/1/1";                      // Show Sessions
sinput string            ShowNames              = "1/0/0/1/1";                      // Show Session Names
sinput string            ShowPips               = "1/0/0/1/1";                      // Show Session Pips
sinput ENUM_TimeMethod   TimeMethod             = Broker_Eastern_Offset;            // Time Method
sinput string            __OffsetNote           = "..exactly *5* sessions above.";  // Note: If Using Eastern Time Zone Offset...
sinput int               BrokerEasternOffset    = 7;                                // Broker Eastern Time Zone Offset
// sinput int               BrokerGMTOffset        = 3;
sinput string            Manual_SessionBegins   = "00:00:00/02:00:00/09:00:00/10:00:00/14:00:00";  // Manual Session Begin Times
sinput string            Manual_SessionEnds     = "08:59:59/10:59:59/17:59:59/18:59:59/23:59:59";  // Manual Session End Times

// Sessions
sinput string Note_SessionSelections            = INPUTVARDELIMITER;                // Individual Session Options
sinput color             Color1                 = clrBlue;                          // Session 1 Color
sinput ENUM_SessionStyle Style1                 = Rectangle_Fill;                   // Session 1 Style
sinput color             Color2                 = clrRed;                           // Session 2 Color
sinput ENUM_SessionStyle Style2                 = Rectangle_Fill;                   // Session 2 Style 
sinput color             Color3                 = clrOrange;                        // Session 3 Color
sinput ENUM_SessionStyle Style3                 = Rectangle_Fill;                   // Session 3 Style
sinput color             Color4                 = clrGreen;                         // Session 4 Color
sinput ENUM_SessionStyle Style4                 = Rectangle_Fill;                   // Session 4 Style
sinput color             Color5                 = clrGray;                          // Session 5 Color
sinput ENUM_SessionStyle Style5                 = Rectangle_Fill;                   // Session 5 Style

// Common Session Variables
sinput string Note_CommonSessionSelections      = INPUTVARDELIMITER;                // Common Session Options
//sinput ENUM_SessionStyle SessionStyle           = Rectangle_Fill;                   // Session Style
sinput int               LineWidth              = 1;                                // Line Width
sinput ENUM_LINE_STYLE   LineStyle              = STYLE_SOLID;                      // Line Style
sinput color             SessionTextColor       = clrGoldenrod;                     // Session Name/Pip Text Colot
sinput string            SessionTextFont        = "Arial Bold";                     // Session Name/Pip Text Font
sinput int               SessionTextFontSize    = 9;                                // Session Name/Pip Text Font Size
sinput ENUM_BASE_CORNER  SessionTextBaseCorner  = CORNER_LEFT_UPPER;                // Session Name/Pip Text Base Corner
sinput ENUM_ANCHOR_POINT SessionTextAnchorPoint = ANCHOR_LEFT_UPPER;                // Session Name/Pip Text Anchor Point
sinput bool              PipsRounded            = true;                             // Round Off Pip Values?
// ^ Round to nearest pip?  If not, display to as many points as the broker gives.
sinput bool              PipsWord               = false;                            // Display " pips" After Pip Value?

// Common Session Variables
sinput string Note_IndicatorSelections          = INPUTVARDELIMITER;                // Indicator Options
sinput ENUM_TIMEFRAMES   MinTimeframe           = PERIOD_M1;                        // Minimum Timeframe to Display Sessions
sinput ENUM_TIMEFRAMES   MaxTimeframe           = PERIOD_H1;                        // Maximum Timeframe to Display Sessions
sinput int               MaxBars                = 1440;                             // Max Bars to Use


const string asEASTERN_BEGINS[MAX_SESSIONS] = {"17:00:00", "19:00:00", "02:00:00", "03:00:00", "08:00:00"};
const string asEASTERN_ENDS  [MAX_SESSIONS] = {"01:59:59", "03:59:59", "10:59:59", "11:59:59", "16:59:59"};
//  const string asGMT_BEGINS[MAX_SESSIONS] = {"21:00", "23:00", "06:00", "07:00", "12:00"};
//  const string asGMT_ENDS  [MAX_SESSIONS] = {"06:00", "08:00", "15:00", "16:00", "21:00"};

string   gsObjectPrefix;              // For unique Object Names with multiple indicators

int               giNSessions;                 // Number of Sessions to Display
string            gasNames         [MAX_SESSIONS];  // Session Name
bool              gabShowSess      [MAX_SESSIONS],  // Show Session?
                  gabShowName      [MAX_SESSIONS],  // Show Session Text with Session Name
                  gabShowPips      [MAX_SESSIONS];  // Show Session Text with Session Pips range value 
color             gaoColors        [MAX_SESSIONS];  // Session Color
ENUM_SessionStyle gaeStyles        [MAX_SESSIONS];  // Session Style  

datetime          galTimeBeginSecs [MAX_SESSIONS],  // Session Begin in seconds, Date portion is 0000.00.00
                  galTimeEndSecs   [MAX_SESSIONS];  // Session End in seconds,   Date portion is 0000.00.00




//
int OnInit(void)
{
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " { "); )
    long  lChartWinHandl;
    string sExeName;


    sExeName = MQLInfoString(MQL_PROGRAM_NAME);
    ChartGetInteger(0, CHART_WINDOW_HANDLE, 0, lChartWinHandl);
    gsObjectPrefix = StringFormat("%s %lld", sExeName, lChartWinHandl);

    // Check to display on this timframe. Return SUCCEEDED now, can be switched to an allowed range later  
    if ((PeriodSeconds(PERIOD_CURRENT) < PeriodSeconds(MinTimeframe))  ||  (PeriodSeconds(PERIOD_CURRENT) > PeriodSeconds(MaxTimeframe)))
      {
          // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " return(INIT_PARAMETERS_INCORRECT) "); )
          return(INIT_SUCCEEDED);  // Return SUCCEEDED now, can be switched to an allowed range later 
      }
    
    giNSessions = StringSplitMax(SessionNames, '/', gasNames, MAX_SESSIONS);  // Get sessions info.
    if ( !StringsUnique(gasNames, giNSessions) ) // Ensure no duplicate session names, for the object names, otherwise use defaults
        giNSessions = StringSplitMax(SESS_NAMES_DEFAULT, '/', gasNames, MAX_SESSIONS);        
    if (DEBUG) Print("giNSessions=", giNSessions);
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " giNSessions= ", giNSessions); )

    ArrayInitialize(gabShowSess,  true);
    StringSplitMaxBool(ShowSessions, '/', gabShowSess, giNSessions);

    ArrayInitialize(gabShowName, true);
    StringSplitMaxBool(ShowNames,    '/', gabShowName, giNSessions);

    ArrayInitialize(gabShowPips, true);
    StringSplitMaxBool(ShowPips,     '/', gabShowPips, giNSessions);

    BuildSessionTimes();

    gaoColors[0] = Color1;
    gaoColors[1] = Color2;
    gaoColors[2] = Color3;
    gaoColors[3] = Color4;
    gaoColors[4] = Color5;
    
    gaeStyles[0] = Style1;
    gaeStyles[1] = Style2;
    gaeStyles[2] = Style3;
    gaeStyles[3] = Style4;
    gaeStyles[4] = Style5;

    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " } "); )
    return(INIT_SUCCEEDED);
} // OnInit()


//
int OnCalculate(const int       rates_total,      // size of input time series
                const int       prev_calculated,  // bars handled in previous call
                const datetime& time[],           // Time
                const double&   open[],           // Open
                const double&   high[],           // High
                const double&   low[],            // Low
                const double&   close[],          // Close
                const long&     tick_volume[],    // Tick Volume
                const long&     volume[],         // Real Volume
                const int&      spread[])         // Spread
{
    bool bResult;
    int giS, iBr, iStartCalcAt, iLimit, iBarSessionBegin, iBarSessionEnd;
    datetime dtOldest = 0, dtNewest = 0, dtCalled = TimeLocal(), dtExit, dtSessionBegin, dtSessionEnd;
    double dHighest, dLowest;

    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", TimeToString(dtCalled, TIME_SECONDS), 
    //                 ", rates_total=", rate s_total, ", prev_calculated=", prev_calculated); )
    
    if ((PeriodSeconds(PERIOD_CURRENT) < PeriodSeconds(MinTimeframe))  ||  (PeriodSeconds(PERIOD_CURRENT) > PeriodSeconds(MaxTimeframe)))
        return(rates_total);  // Inactive Timeframe now (Can be switched to an allowed Timeframe later)

    bResult = ArraySetAsSeries(time, true);
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySetAsSeries(time) ", bResult); )
    bResult = ArraySetAsSeries(high, true);
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySetAsSeries(high) ", bResult); )
    bResult = ArraySetAsSeries(low, true);
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySetAsSeries(low)  ", bResult); )

    /* int iSize = ArraySize(time);
    DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySize(time) = ", iSize, " vs ", rates_total); )
    iSize = ArraySize(high);
    DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySize(high) = ", iSize, " vs ", rates_total); )
    iSize = ArraySize(low);
    DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ArraySize(low)  = ", iSize, " vs ", rates_total); ) */

    if (rates_total > 0)
      {
          dtOldest = time[(rates_total > 0) ? (rates_total - 1) : 0];
          dtNewest = time[0];
      }

    // Set iStartCalcAt to the first (oldest) spot of the bars available, while respecting the MaxBars setting
    iStartCalcAt = rates_total - prev_calculated;
    if (iStartCalcAt > MaxBars)
        iStartCalcAt = MaxBars;
    if (iStartCalcAt > 0)  // Subtract one as array index, but process at least the [0] bar otherwise
      iStartCalcAt--; 

    for (giS = 0; giS < giNSessions; giS++)
      {
          if (! gabShowSess[giS])  // Skip unselected Sessions 
              continue;

          // Set iLimit to the first (oldest) spot of the bars available, or picking up at the last spot processed for the Session.
          iLimit = iStartCalcAt;
          
          // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", gasNames[giS], " Session ",
          //                 TimeToString(galTimeBeginSecs[giS], TIME_MINUTES), " - ",
          //                 TimeToString(galTimeEndSecs  [giS], TIME_MINUTES) ); )
          
          for (iBr = 0; iBr <= iLimit; iBr++) // Process newest to oldest, assuming most recent bars are most likely visible    
            {
                if ( ((dtSessionBegin = GetSessionBegin(galTimeBeginSecs[giS], galTimeEndSecs[giS], time[iBr])) < 0) ||
                     ((dtSessionEnd   = GetSessionEnd  (galTimeBeginSecs[giS], galTimeEndSecs[giS], time[iBr])) < 0) )
                  {
                      /* DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", gasNames[giS], " Skip (", iBr, ") ",
                                      TimeToString(time[iBr], TIME_DATE|TIME_MINUTES), " ! ",
                                      TimeToString(galTimeBeginSecs[giS], TIME_SECONDS), " - ", 
                                      TimeToString(galTimeEndSecs  [giS], TIME_SECONDS)); ) */
                      continue;
                  }
                  
                iBarSessionBegin = GetBeginBar(dtSessionBegin, dtSessionEnd, iBr, time, (rates_total > 0) ? (rates_total - 1) : 0);
                iBarSessionEnd   = GetEndBar  (dtSessionBegin, dtSessionEnd, iBr, time, 0);

                dHighest = HighestPrice(high, iBarSessionBegin, iBarSessionEnd);
                dLowest  = LowestPrice (low,  iBarSessionBegin, iBarSessionEnd);
                            
                /* DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", gasNames[giS], 
                                " Draw (", iBr, ",", iBarSessionBegin, ",", iBarSessionEnd, ") ", 
                                TimeToString(time[iBr], TIME_DATE|TIME_MINUTES), ",  (",
                                time[iBarSessionBegin], " - ", time[iBarSessionEnd], ", highest= ", 
                                DoubleToString(dHighest, _Digits), ", lowest= ", DoubleToString(dLowest, _Digits), ")"); ) */
                DrawSession(gasNames[giS], gaoColors[giS], gaeStyles[giS], gabShowName[giS], gabShowPips[giS], 
                            time[iBarSessionBegin], time[iBarSessionEnd], dHighest, dLowest);

                iBr = iBarSessionBegin;
            }
      } 
      
    ChartRedraw();  // Per ChartRedraw() documentation, Usually it is used after changing the object properties.
   
    dtExit = TimeLocal();
    /* DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, 
                    " rates_total= ",  rates_total, " (",  TimeToString(dtOldest, TIME_DATE|TIME_SECONDS), ")", 
                    ", prev_calculated= " , prev_calculated, " (", TimeToString(dtNewest, TIME_DATE|TIME_SECONDS), ")  <",
                    TimeToString(dtCalled, TIME_SECONDS), "-", TimeToString(dtExit, TIME_SECONDS), "> Elapsed= ", 
                    TimeToString(dtExit - dtCalled, TIME_SECONDS)); ) */
    return(rates_total); 
} // OnCalculate()


/*
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    switch (id)
      {
          case CHARTEVENT_KEYDOWN:
               break;
          case CHARTEVENT_MOUSE_MOVE:
          case CHARTEVENT_MOUSE_WHEEL:
               break;
          case CHARTEVENT_CLICK:         // Mouse click on a chart
               break;
          case CHARTEVENT_OBJECT_CLICK:  // lparam = X coordinate, dparam = Y coordinate, sparam = Name of the graphical object
          case CHARTEVENT_OBJECT_DRAG:
               break;
          case CHARTEVENT_OBJECT_ENDEDIT:
               break;                                                  
          case CHARTEVENT_OBJECT_CREATE: 
          case CHARTEVENT_OBJECT_CHANGE:
          case CHARTEVENT_OBJECT_DELETE:
               break;
          case CHARTEVENT_CHART_CHANGE:
               break;
          case CHARTEVENT_CUSTOM:
          case CHARTEVENT_CUSTOM_LAST:
               break;
          default:
               break;
      }
}
*/ 


// REASON_PROGRAM     0 Expert Advisor terminated its operation by calling the ExpertRemove() function
// REASON_REMOVE      1 Program has been deleted from the chart
// REASON_RECOMPILE   2 Program has been recompiled
// REASON_CHARTCHANGE 3 Symbol or chart period has been changed
// REASON_CHARTCLOSE  4 Chart has been closed
// REASON_PARAMETERS  5 Input parameters have been changed by a user
// REASON_ACCOUNT     6 Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings
// REASON_TEMPLATE    7 A new template has been applied
// REASON_INITFAILED  8 This value means that OnInit() handler has returned a nonzero value
// REASON_CLOSE       9 Terminal has been closed
void OnDeinit(const int reason)
{
    int iResult;

    iResult = ObjectsDeleteAll(0, gsObjectPrefix);    
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " reason= ", reason, ", ObjectsDeleteAll()=", iResult); )
}


// Draw Session Style and Text
//
// In general, set all object backgrounds to true, with some exception.
// OBJPROP_FILL appears to be new in MQL5. OBJPROP_BACK is like OBJPROP_FILL in MQL4, so set them the same in MQL4
//
inline void DrawSession(const string sName, color clrSession, ENUM_SessionStyle SessionStyle, bool bShowName, bool bShowPips, 
                        datetime dtSessionBegin, datetime dtSessionEnd, double dHighest, double dLowest)
{
    bool bResult, bResult1, bResult2, bResult3, bResult4, bResult5, bResult6, bResult7, bResult8, bResult9, 
         bBack = true, bFill, bAllWins;
    int iTotalWindows, iSubWin, iResult1, iResult2;
    datetime dtMidnight, dtSessionTextDatetime;
    double dTextPrice;
    string sObjName, sText = "";


    iResult1 = iResult2 = 0;
    bResult = bResult1 = bResult2 = bResult3 = bResult4 = bResult5 = bResult6 = bResult7 = bResult8 = bResult9 = true;

    dtMidnight = DateFloorMidnight(dtSessionBegin);

    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", sName, " dtRange= ", 
    //                 TimeToString(dtSessionBegin, TIME_DATE|TIME_MINUTES), " - ", TimeToString(dtSessionEnd, TIME_DATE|TIME_MINUTES),
    //                 ", dPrices= ", DoubleToString(dHighest, _Digits), ", ", DoubleToString(dLowest, _Digits)); )

    // Draw Session Style
    switch (SessionStyle)
      {
          case Vertical_Lines:
          case Vertical_Line_Begin:
          case Vertical_Line_End:
          case Vertical_Lines_All:
          case Vertical_Lines_All_Begin:
          case Vertical_Lines_All_End:
               if ( (SessionStyle == Vertical_Lines_All)       || 
                    (SessionStyle == Vertical_Lines_All_Begin) || (SessionStyle == Vertical_Lines_All_End) )
                   bAllWins = true;
               else
                   bAllWins = false;
                   
               if ( (SessionStyle == Vertical_Lines)     || (SessionStyle == Vertical_Line_Begin) ||
                    (SessionStyle == Vertical_Lines_All) || (SessionStyle == Vertical_Lines_All_Begin) )
                 {
                   sObjName = FormSessionObjName(0, dtMidnight, sName, "Begin");
                   if ( (iResult1 = ObjectFind(0, sText)) < 0 )
                     {   // If object doesn't exist..
                         bResult  = ObjectCreate    (0, sObjName, OBJ_VLINE, 0,   dtSessionBegin, 0.0);                
                         bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR,  clrSession);
                         bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,   true);                      
                         bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE,  LineStyle);
                         bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH,  LineWidth);
                         bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,   true);
                         // bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_ZORDER, -1);                                           
                         bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_RAY,    bAllWins);
                     }
                   bResult8 = ObjectSetInteger(0, sObjName, OBJPROP_TIME, dtSessionBegin);                   
                 } 
                 
               if ( (SessionStyle == Vertical_Lines)     || (SessionStyle == Vertical_Line_End) ||
                    (SessionStyle == Vertical_Lines_All) || (SessionStyle == Vertical_Lines_All_End) )
                 {
                   sObjName = FormSessionObjName(0, dtMidnight, sName, "End");
                   if ( (iResult2 = ObjectFind(0, sObjName)) < 0 )
                     {   // If object doesn't exist..
                         bResult  = ObjectCreate    (0, sObjName, OBJ_VLINE, 0,  dtSessionEnd,   0.0);                
                         bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);  
                         bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  true);                         
                         bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                         bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);
                         bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  true);  
                         // bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_ZORDER, -1);                                         
                         bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_RAY,   bAllWins);                                            
                     }
                   bResult8 = ObjectSetInteger(0, sObjName, OBJPROP_TIME, dtSessionEnd);
                 }
               break;                

          case Horizontal_Lines:
          case Horizontal_Line_High:
          case Horizontal_Line_Low:
               MQL4( bBack = false; )
               if ( (SessionStyle == Horizontal_Lines) || (SessionStyle == Horizontal_Line_High) )
                 {
                   sObjName = FormSessionObjName(0, dtMidnight, sName, "High");
                   if ( (iResult1 = ObjectFind(0, sObjName)) < 0 )
                     {   // If object doesn't exist..
                         bResult  = ObjectCreate    (0, sObjName, OBJ_RECTANGLE, 0, dtSessionBegin, 0.0, dtSessionEnd, 0.0);                
                         bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);
                         bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  false);  // must be false to show same high and low
                         bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                         bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);
                         bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  bBack);  // MT4 OBJPROP_BACK is like OBJPROP_FILL                   
                     }
                   bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,     dtSessionBegin);  
                   bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,  1, dtSessionEnd);                                                 
                   bResult8 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE,    dHighest);
                  bResult9 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE, 1, dHighest);
                 }

               if ( (SessionStyle == Horizontal_Lines) || (SessionStyle == Horizontal_Line_Low) )
                 {
                   sObjName = FormSessionObjName(0, dtMidnight, sName, "Low");
                   if ( (iResult2 = ObjectFind(0, sObjName)) < 0 )
                     {   // If object doesn't exist..
                         bResult  = ObjectCreate    (0, sObjName, OBJ_RECTANGLE, 0, dtSessionBegin, 0.0, dtSessionEnd, 0.0);                
                         bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);
                         bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  false);  // must be false to show same high and low
                         bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                         bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);
                         bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  bBack);  // MT4 OBJPROP_BACK is like OBJPROP_FILL                    
                     }
                   bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,     dtSessionBegin);  
                   bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,  1, dtSessionEnd);                                                 
                   bResult8 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE,    dLowest);
                   bResult9 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE, 1, dLowest);
                 }
               break;

          case Vertical_Fill:
               sObjName = FormSessionObjName(0, dtMidnight, sName);
               if ( (iResult1 = ObjectFind(0, sObjName)) < 0 )
                 {   // If object doesn't exist..
                     bResult  = ObjectCreate    (0, sObjName, OBJ_RECTANGLE, 0, dtSessionBegin, 0.0, dtSessionEnd, 0.0);                
                     bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);
                     bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  true);
                     bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                     bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);                
                     bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  true); 
                 }
               bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,     dtSessionBegin);  
               bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,  1, dtSessionEnd);                                                 
               bResult8 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE,    dHighest * WINMAXVAL);
               bResult9 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE, 1, 0.0);
               break;

          case Vertical_Fill_All:
               iTotalWindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL); 
               for (iSubWin = 0; iSubWin < iTotalWindows; iSubWin++)
                 {
                   sObjName = FormSessionObjName(iSubWin, dtMidnight, sName);
                   if ( (iResult1 = ObjectFind(0, sObjName)) < 0 )
                     {   // If object doesn't exist..
                       bResult  = ObjectCreate     (0, sObjName, OBJ_RECTANGLE, iSubWin, dtSessionBegin, 0.0, dtSessionEnd, 0.0);                
                       bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);
                       bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  true);
                       bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                       bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);                
                       bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  true); 
                     }
                   bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,     dtSessionBegin);  
                   bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_TIME, 1,  dtSessionEnd);                                                 
                     
                   bResult8 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE,    dHighest * WINMAXVAL);
                   if (iSubWin == 0)
                       bResult9 = ObjectSetDouble(0, sObjName, OBJPROP_PRICE, 1, 0.0);
                   else
                       bResult9 = ObjectSetDouble(0, sObjName, OBJPROP_PRICE, 1, MathAbs(dLowest) * -WINMAXVAL);                    
                 }
               break;

          default: // Rectangle_Fill, Rectangle_Line
               bFill = (SessionStyle == Rectangle_Fill);
               MQL4( bBack = bFill; )
               
               sObjName = FormSessionObjName(0, dtMidnight, sName);
               if ( (iResult1 = ObjectFind(0, sObjName)) < 0 )
                 {   // If object doesn't exist..
                     bResult  = ObjectCreate    (0, sObjName, OBJ_RECTANGLE, 0, dtSessionBegin, 0.0, dtSessionEnd, 0.0);                
                     bResult1 = ObjectSetInteger(0, sObjName, OBJPROP_COLOR, clrSession);
                     bResult2 = ObjectSetInteger(0, sObjName, OBJPROP_FILL,  bFill);
                     bResult3 = ObjectSetInteger(0, sObjName, OBJPROP_STYLE, LineStyle);
                     bResult4 = ObjectSetInteger(0, sObjName, OBJPROP_WIDTH, LineWidth);                
                     bResult5 = ObjectSetInteger(0, sObjName, OBJPROP_BACK,  bBack); // MT4 OBJPROP_BACK is like OBJPROP_FILL
                 }
               bResult6 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,     dtSessionBegin);  
               bResult7 = ObjectSetInteger(0, sObjName, OBJPROP_TIME,  1, dtSessionEnd);                                                 
               bResult8 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE,    dHighest);
               bResult9 = ObjectSetDouble (0, sObjName, OBJPROP_PRICE, 1, dLowest);
               /* DbugInfo( if (!(bResult1 || bResult2 || bResult3 || bResult4 || bResult5 || bResult6 || bResult7 || bResult8))
                           Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " ", SessionStyle, ", ", sName, ", Results= ", 
                                 bResult,  " ", bResult1, " ", bResult2, " ", bResult3, " ", bResult4, " ", 
                                 bResult5, " ", bResult6, " ", bResult7, " ", bResult8, " ", bResult9); ) */
               break;
      }


    // Draw Session Text
    if ( !bShowName && !bShowPips )
        return;     

    if (bShowName)
        sText = sName;
    if (bShowPips)
        sText += NAMEPIPDELIMITER + GetPipsStr(dHighest - dLowest);
    sText  = NAMEPIPMARGIN + sText + NAMEPIPMARGIN;
    
    if ( (SessionTextBaseCorner == CORNER_RIGHT_UPPER) || (SessionTextBaseCorner == CORNER_RIGHT_LOWER) )
         dtSessionTextDatetime = dtSessionEnd;
    else dtSessionTextDatetime = dtSessionBegin;
    if ( (SessionTextBaseCorner == CORNER_LEFT_LOWER)  || (SessionTextBaseCorner == CORNER_RIGHT_LOWER) )
         dTextPrice = dLowest;
    else dTextPrice = dHighest;

    sObjName = FormSessionObjName(0, dtMidnight, sName, "Text");
    if ( (iResult1 = ObjectFind(0, sObjName)) < 0 )
      {   // If object doesn't exist..          
          ObjectCreate(0,     sObjName, OBJ_TEXT, 0,      0, 0.0);
          ObjectSetString (0, sObjName, OBJPROP_FONT,     SessionTextFont);
          ObjectSetInteger(0, sObjName, OBJPROP_FONTSIZE, SessionTextFontSize);
          ObjectSetInteger(0, sObjName, OBJPROP_COLOR,    SessionTextColor);
          ObjectSetInteger(0, sObjName, OBJPROP_ANCHOR,   SessionTextAnchorPoint);
          ObjectSetInteger(0, sObjName, OBJPROP_BACK,     true);
      }
    ObjectSetInteger(0, sObjName, OBJPROP_TIME,  dtSessionTextDatetime);
    ObjectSetDouble (0, sObjName, OBJPROP_PRICE, dTextPrice);
    ObjectSetString (0, sObjName, OBJPROP_TEXT,  sText);
    
    // ChartRedraw();  // Per ChartRedraw() documentation, Usually it is used after changing the object properties.
}  // DrawSession()


//
inline string FormSessionObjName(int iWindow, datetime lCurBarDate, string SessionName, string sPostfix = "")
{
    string sObjName = gsObjectPrefix + "-" + IntegerToString(iWindow) + ", " + TimeToString(lCurBarDate, TIME_DATE) + " " + SessionName;
                      
                      
    if (StringLen(sPostfix) > 0)
        sObjName += " " + sPostfix;

    return( sObjName );
}


//
// Load the beginning and end times for the sessions.
//
void BuildSessionTimes(void)
{
    bool labMidnightCross [MAX_SESSIONS];  // Do any of the start to end times cross midnight
    int giS;
    string asManualBegins[MAX_SESSIONS],
           asManualEnds  [MAX_SESSIONS];


    if (TimeMethod == Broker_Eastern_Offset) 
      {
          if (DEBUG) Print("Using Eastern offset.");
          for (giS = 0; giS < giNSessions; giS++) 
            {
                if ( ! gabShowSess[giS] )
                  continue;
                  
                galTimeBeginSecs[giS] = StringToSeconds(asEASTERN_BEGINS[giS]) + (BrokerEasternOffset * ONEHOURsecs);
                if (galTimeBeginSecs[giS] >= ONEDAYsecs)
                    galTimeBeginSecs[giS] = galTimeBeginSecs[giS] % ONEDAYsecs;  // remainder of seconds under one day           

                galTimeEndSecs[giS]   = StringToSeconds(asEASTERN_ENDS[giS])   + (BrokerEasternOffset * ONEHOURsecs);
                if (galTimeEndSecs[giS]   >= ONEDAYsecs)
                    galTimeEndSecs[giS]   = galTimeEndSecs[giS]   % ONEDAYsecs;  // remainder of seconds under one day

                if (galTimeBeginSecs[giS] > galTimeEndSecs[giS]) 
                  {
                      galTimeEndSecs[giS]  += ONEDAYsecs;
                      labMidnightCross[giS] = true;
                  }
                else
                      labMidnightCross[giS] = false;
                if (DEBUG) Print("Session ", giS, " is from ", TimeToString(galTimeBeginSecs[giS] | TIME_MINUTES), " to ",
                                TimeToString(galTimeEndSecs[giS] | TIME_MINUTES), ". Midnight Cross ", labMidnightCross[giS], ".");
                /* DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " Broker= ", gasNames[giS], 
                                " galTimeBeginSecs[", giS, "]=", TimeToString(galTimeBeginSecs[giS], TIME_SECONDS), 
                                ", galTimeEndSecs[giS]=", TimeToString(galTimeEndSecs[giS], TIME_SECONDS), 
                                ", labMidnightCross[giS]=", labMidnightCross[giS]); ) */
            }
          
          return;  
      }
      
    /*if (TimeMethod == Broker_GMT_Offset) 
      {
          if (DEBUG) Print("Using GMT offset.");
          for (g = 0;  g < giNSessions; g++)
            {
                if ( ! gabShowSess[g] )
                  continue;
                  
                glTimeBegin[g]  =  TimeHHMMtoMin(asGMT_BEGINS[g]) * 60  +  GMTOffset * ONEHOURsecs;
                if (glTimeBegin[g] >= ONEDAYsecs)
                    glTimeBegin[g] = glTimeBegin[g] % ONEDAYsecs;
      
                glTimeEnd[g]  =  TimeHHMMtoMin(asGMT_ENDS[g]) * 60  +  GMTOffset * ONEHOURsecs;
                if (glTimeEnd[g] >= ONEDAYsecs)
                    glTimeEnd[g] = glTimeEnd[g] % ONEDAYsecs;
      
                if (glTimeBegin[g] > glTimeEnd[g]) 
                  {
                      glTimeEnd[g] += ONEDAYsecs;
                      labMidnightCross[g] = true;
                  }
                else
                      labMidnightCross[g] = false;
                if (DEBUG) Print("Session ", g, " is from ", TimeToStr(glTimeBegin[g]), " to ", TimeToStr(glTimeEnd[g]),
                                 ". Midnight Cross ", labMidnightCross[g], ".");
                
            }
          
          return;
      }*/

    // Manual; load from the strings.
    if (DEBUG) Print("Using Manual session times.");
    // Only load these two strings if using Manual time mode:
    // Let the function shrink $giNSessions if there are not enough strings.
    giNSessions = StringSplitMax(Manual_SessionBegins, '/', asManualBegins, MAX_SESSIONS);
    giNSessions = StringSplitMax(Manual_SessionEnds,   '/', asManualEnds,   giNSessions);

    for (giS = 0; giS < giNSessions; giS++) 
      {
          if ( ! gabShowSess[giS] )
            continue;
                  
          galTimeBeginSecs[giS] = StringToSeconds(asManualBegins[giS]);
          if (galTimeBeginSecs[giS] >= ONEDAYsecs)
              galTimeBeginSecs[giS] = galTimeBeginSecs[giS] % ONEDAYsecs;  // remainder of seconds under one day

          galTimeEndSecs[giS] = StringToSeconds(asManualEnds[giS]);
          if (galTimeEndSecs[giS]   >= ONEDAYsecs)
              galTimeEndSecs[giS]   = galTimeEndSecs[giS]   % ONEDAYsecs;  // remainder of seconds under one day

          if (galTimeBeginSecs[giS] > galTimeEndSecs[giS]) 
            {
                  galTimeEndSecs[giS]  += ONEDAYsecs;
                  labMidnightCross[giS] = true;
            }
          else
                  labMidnightCross[giS] = false;
          if (DEBUG) Print("Session ", giS, " is from ", TimeToString(galTimeBeginSecs[giS] | TIME_MINUTES), " to ",
                           TimeToString(galTimeEndSecs[giS] | TIME_MINUTES), ". Midnight Cross ", labMidnightCross[giS], ".");
          /* DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " Manual= ", gasNames[giS], " galTimeBeginSecs[", giS, "]=", 
                          TimeToString(galTimeBeginSecs[giS], TIME_SECONDS), 
                          ", galTimeEndSecs[giS]=", TimeToString(galTimeEndSecs[giS], TIME_SECONDS), 
                          ", labMidnightCross[giS]=", labMidnightCross[giS]); ) */
      }
}  //  BuildSessionTimes()


//  Example: "1989.06.22 10:33:45" becomes "1989.06.22 00:00:00"
inline datetime DateFloorMidnight(datetime lTime)
{
    datetime dtResult = (lTime - (datetime) MathMod(lTime, ONEDAYsecs));
    
    
    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " lTime=", lTime, ", dtResult=", dtResult ); )
    return(dtResult);             
}


// Return true if dtTest is within the Session range
bool WithinSession(datetime dtTimeBeginSecs, datetime dtTimeEndSecs, datetime dtTest)
{
    datetime dtSecondsOnly = dtTest % ONEDAYsecs; // Remainder
    
    
    if ( (dtTimeBeginSecs <= dtTimeEndSecs) && ( (dtTimeBeginSecs <= dtSecondsOnly) && (dtSecondsOnly <= dtTimeEndSecs) ) )
        return(true);
        
    // if the Begin to End datetime's cross Midnight    
    if ( (dtTimeBeginSecs >  dtTimeEndSecs) && ( (dtTimeBeginSecs <= dtSecondsOnly) || (dtSecondsOnly <= dtTimeEndSecs) ) )
        return(true);
    
    return(false); 
}


// Return the Full Date and Time of the Session Begin, Return -1 if not within Session 
inline datetime GetSessionBegin(datetime dtTimeBeginSecs, datetime dtTimeEndSecs, datetime dtTest)
{
    datetime dtSecondsOnly = dtTest % ONEDAYsecs; // Remainder

    
    if ( (dtTimeBeginSecs <= dtTimeEndSecs) && ( (dtTimeBeginSecs <= dtSecondsOnly) && (dtSecondsOnly <= dtTimeEndSecs) ) )
        return( DateFloorMidnight(dtTest) + dtTimeBeginSecs );
        
    // If the Begin to End datetime's cross Midnight    
    if (dtTimeBeginSecs >  dtTimeEndSecs)
      { 
          if (dtTimeBeginSecs <= dtSecondsOnly)
              return( DateFloorMidnight(dtTest) + dtTimeBeginSecs );
          if (dtSecondsOnly <= dtTimeEndSecs)
              return( DateFloorMidnight(dtTest - ONEDAYsecs) + dtTimeBeginSecs );
      }
    
    return( -1 ); 
}


// Return the Full Date and Time of the Session End, Return -1 if not within Session
inline datetime GetSessionEnd(datetime dtTimeBeginSecs, datetime dtTimeEndSecs, datetime dtTest)
{
    datetime dtSecondsOnly = dtTest % ONEDAYsecs; // Remainder
    
    
    if ( (dtTimeBeginSecs <= dtTimeEndSecs) && ( (dtTimeBeginSecs <= dtSecondsOnly) && (dtSecondsOnly <= dtTimeEndSecs) ) )
        return( DateFloorMidnight(dtTest) + dtTimeEndSecs );
        
    // if the Begin to End datetime's cross Midnight    
    if (dtTimeBeginSecs >  dtTimeEndSecs)
      {
          if (dtTimeBeginSecs <= dtSecondsOnly)
              return( DateFloorMidnight(dtTest) + dtTimeEndSecs );
          if (dtSecondsOnly <= dtTimeEndSecs)
              return( DateFloorMidnight(dtTest - ONEDAYsecs) + dtTimeBeginSecs );
      }
    
    return( -1 );
}


// Return the Session Begin Bar for this Bar. Return -1 if not within Session
inline int GetBeginBar(datetime dtSessionBegin, datetime dtSessionEnd, int iBr, const datetime& timeSeries[], int iLimit)
{
    int iBegin = iBr, Indx;

    
    if ( ! ((dtSessionBegin <= timeSeries[iBr]) && (timeSeries[iBr] <= dtSessionEnd)) ) 
        return(-1);
    for (Indx = iBr + 1; Indx <= iLimit; Indx++, iBegin++)
      {
          if ( ! ((dtSessionBegin <= timeSeries[Indx]) && (timeSeries[Indx] <= dtSessionEnd)) )               
              break;
      }
    
    return(iBegin); 
}


// Return the Session End Bar for this Bar. Return -1 if not withing Session
inline int GetEndBar(datetime dtSessionBegin, datetime dtSessionEnd, int iBr, const datetime& timeSeries[], int iLimit)
{
    int iEnd = iBr, Indx;

    
    if ( ! ((dtSessionBegin <= timeSeries[iBr]) && (timeSeries[iBr] <= dtSessionEnd)) )  
        return(-1);
    for (Indx = iBr - 1; Indx >= iLimit; Indx--, iEnd--)
      {
          if ( ! ((dtSessionBegin <= timeSeries[Indx]) && (timeSeries[Indx] <= dtSessionEnd)) ) 
              break;
      }
    
    return(iEnd); 
}


// Highest Price of range
double HighestPrice(const double& high[], int iUpper, int iLower)
{
    int Indx;
    double dHighest;


    dHighest = high[iUpper];
    for (Indx = iUpper - 1; Indx >= iLower; Indx--)
      {
          if (dHighest < high[Indx])
              dHighest = high[Indx];
      }

    return( dHighest );
}


// Lowest Price of range
double LowestPrice(const double& low[], int iUpper, int iLower)
{
    int Indx;
    double dLowest;


    dLowest = low[iUpper];
    for (Indx = iUpper - 1; Indx >= iLower; Indx--) 
      {
          if (dLowest > low[Indx])
              dLowest = low[Indx];
      }

    return( dLowest );
}


// Returns "X.Y[ pips]", where $X.Y is a double equal to the number of pips (using $gdPip and rounded to
//   $giPipsPrecision places) and where " pips" will only be appended if $PipsWord is true and will instead be " pip"
//   (singular) when the number is <=1.
inline string GetPipsStr(double dDelta)
{
    int    iPipsPrecision;
    double dPip, dPips;    
    string sPipsValue;


    // Deal with fractional pips.
    if (_Digits == 3 || _Digits == 5) {
          dPip          = _Point * 10;  }
    else if (_Digits > 5) {
          dPip          = 0.0001;                        //  = Point * MathPow(10, Digits - 4);
      }
    else {
          dPip          = _Point; }

    if (PipsRounded)
        iPipsPrecision = 0;
    else {
          if (_Digits == 3 || _Digits == 5)
              iPipsPrecision = 1;
          else if (_Digits > 5)
              iPipsPrecision = _Digits - 4;
          else
              iPipsPrecision = 0;
         }

    dPips  = NormalizeDouble( dDelta / dPip, iPipsPrecision );
    
    sPipsValue = DoubleToString(dPips, iPipsPrecision);
    if (PipsWord) 
      {
          if (MathAbs(dPips) > 1.0)
              return( sPipsValue + " pips");

          return( sPipsValue + " pip");
      }

    return( sPipsValue );
} // GetPipsStr()


//  StringSplit up to iMax items
int StringSplitMax(string sSrc, ushort usSeparator, string & asDest[], int iMax)
{
    int iSubStr, iResult;
    string sResult[];


    iResult = StringSplit(sSrc, usSeparator, sResult);
    if (iResult < 0)
      return(iResult);
      
    for (iSubStr = 0; ((iSubStr < iResult) && (iSubStr < iMax)); iSubStr++) 
      { 
          asDest[iSubStr] = sResult[iSubStr];             
          // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " sResult[", iBools, "]=", sResult[iBools]); )
      } 

    return( iSubStr );
}


//  StringSplit up to iMax items
int StringSplitMaxBool(string sSrc, ushort usSeparator, bool & abDest[], int iMax)
{
    int iSubStr, iResult;
    string sResult[];


    iResult = StringSplit(sSrc, usSeparator, sResult);
    if (iResult < 0)
      return(iResult);
      
    for (iSubStr = 0; ((iSubStr < iResult) && (iSubStr < iMax)); iSubStr++) 
      { 
          abDest[iSubStr] = true;
          if (StringCompare(sResult[iSubStr], "0") == 0) 
              abDest[iSubStr] = false;                  
          // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " sResult[", iSubStr, "]=", sResult[iSubStr]); )
      } 

    return( iSubStr );
}


//
bool StringsUnique(string& asSrc[], int iNumStr)
{
    for (int i = 0; i < iNumStr - 1; i++) {
          for (int j = i + 1; j < iNumStr; j++) {
                if (asSrc[i] == asSrc[j])
                    return false;
            }
      }
    return true;
}


// 
int StringToSeconds(string sTimeStr)
{
    bool bResult;    
    datetime dtTime;
    MqlDateTime dtStruct;
    

    dtTime = StringToTime(sTimeStr);
    bResult = TimeToStruct(dtTime, dtStruct);

    // DbugInfo( Print(__FILE__, " ", __FUNCTION__, "@", __LINE__, " sTimeStr= ", sTimeStr, ", dtTime= ", dtTime, ", .hour=", dtStruct.hour, ", .min=" dtStruct.min); )
    return ( (dtStruct.hour * ONEHOURsecs) + (dtStruct.min * 60) + dtStruct.sec );
}

//
//
