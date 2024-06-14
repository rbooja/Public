
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnStart()
  {
    MqlCalendarValue values[];
    MqlCalendarEvent event;

    datetime date_from = TimeTradeServer() - PeriodSeconds(PERIOD_MN1);
    datetime date_to   = TimeTradeServer() + PeriodSeconds(PERIOD_MN1);
    int      count     = CalendarValueHistory(values, date_from, date_to, "US", "USD");
    string   out;

    Print("History ", count);

    for (int i = 0; count > i; i++)
      {
        CalendarEventById(values[i].event_id, event);

        StringConcatenate(out, values[i].time, ",", event.name, ",", event.event_code, ",", values[i].HasActualValue(), ",", values[i].HasPreviousValue());

        ErrorLog(out);

        datetime before = values[i].time - PeriodSeconds(PERIOD_M1);

        if (before < TimeTradeServer() && values[i].time >= TimeTradeServer())
          {
            Print(values[i].GetActualValue());
          }
      }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ErrorLog(string text)
  {
    int handle = FileOpen(MQLInfoString(MQL_PROGRAM_NAME) + ".log", FILE_TXT | FILE_ANSI | FILE_WRITE | FILE_READ | FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_COMMON);
    if (0 < handle)
      {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, text);
        FileClose(handle);
      }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
