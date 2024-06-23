
#property copyright   "ReticoloFX Mod M5"
#property link        "http://forum.tradelikeapro.ru"
#property version     "1.51"
#property description "ApMSoft Mod M5 07.03.2013"
#property strict

#include <stdlib.mqh>

#import "_Telegram4Mql.dll"
   string TelegramSendTextAsync(string apiKey, string chatId, string chatText);
#import

// ApMSoft Mod M5 07 03 Pub //
string mod_ver = "ApMSoft Mod M5"; // 07.03.2013

input  double lot_size         = 0.01;
input  double target_profit    = 10.0;
input  double minimum_step     = 20.0;; // pips
input  bool   average_true_range = false;
input  ENUM_TIMEFRAMES atr_timeframe = PERIOD_H4;
input  int    atr_period       = 30;
input  double atr_multiple     = 1.0;
input  bool   trend_following  = true;
extern bool   closeby_enabled  = true;
input  bool   show_next_trades = true;
input  uint   advisor_instance = 0; // instance (single 0-999, basket 1000-)

double maxlots   = 100.0; // maximum number of lots (auto only)
double balance   = 500.0; // balance to minimum lots (auto only)

color    clrbg   = clrBlack;
color    clrbuy  = clrRoyalBlue;
color    clrby   = clrGold; // clrYellow
color    clrsell = clrFireBrick;
double   atrvalue = 0.0;
double   minimum  = 20.0; // 3.0
double   nextbuy  = 0.0;
double   nextsell = 0.0;
double   pips = 0.0;
double   step = 20.0;
int      RepeatN  = 3;
int      magicnumber = 0;
int      slippage = 3;
string   comments = "";
string   magic_close;
string   magic_hold;
string   magic_maxdd;
string   magic_stopd;
string   objectbuy;
string   objectsell;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expert initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit()
{
   //---
   nextbuy  = 0.0;
   nextsell = 0.0;
   InitSettings();
   Print("tick value = ", DoubleToString(MarketInfo(_Symbol, MODE_TICKVALUE), 2));
   ShowDisplay();
   //---
   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void InitSettings()
{
   magicnumber = iMakeExpertId(_Symbol, advisor_instance);

   comments = _Symbol;
   if (1000 <= advisor_instance) comments = "BASKET";
   comments = StringConcatenate(comments, "_", advisor_instance);

   magic_close = StringConcatenate(comments, "_CLOSE");
   magic_stopd = StringConcatenate(comments, "_STOP_AFTER_CLOSE");
   magic_hold  = StringConcatenate(comments, "_HOLD");
   magic_maxdd = StringConcatenate(magicnumber, "_maxdd");

   if (!GlobalVariableCheck(magic_close)) GlobalVariableSet(magic_close, 0);
   if (!GlobalVariableCheck(magic_maxdd)) GlobalVariableSet(magic_maxdd, 0);
   // ApM - Ring - Basket - Close Flag
   if (!GlobalVariableCheck(magic_stopd)) GlobalVariableSet(magic_stopd, 0);
   if (!GlobalVariableCheck(magic_hold))  GlobalVariableSet(magic_hold, 0);

   // pips = _Point;
   // if (_Digits == 3 || _Digits == 5) pips *= 10.0;
   pips = PointsPerPip() * _Point;

   //---
   // if (average_true_range && !CheckChart()) return;

   // ApM chart object remake
   if (show_next_trades)
   {
      objectbuy = StringConcatenate(magicnumber, "_NEXT_BUY");
      if (0 < StringLen(objectbuy))
      {
         ObjectCreate(objectbuy, OBJ_HLINE, 0, 0, 0);
         ObjectSet(objectbuy, OBJPROP_COLOR, clrbuy);
         ObjectSet(objectbuy, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(objectbuy, OBJPROP_BACK, false);
      }
      objectsell = StringConcatenate(magicnumber, "_NEXT_SELL");
      if (0 < StringLen(objectsell))
      {
         ObjectCreate(objectsell, OBJ_HLINE, 0, 0, 0);
         ObjectSet(objectsell, OBJPROP_COLOR, clrsell);
         ObjectSet(objectsell, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(objectsell, OBJPROP_BACK, false);
      }
   }

   int line = 12;
   for (int i = 0; i < 8; i++)
   {
      for (int k = 0; k < line; k++)
      {
         ObjectDelete(StringConcatenate("bg", i, k));
         ObjectDelete(StringConcatenate("bg", i, k + 1));
         ObjectDelete(StringConcatenate("bg", i, k + 2));
         ObjectCreate(StringConcatenate("bg", i, k), OBJ_LABEL, 0, 0, 0);
         ObjectSetText(StringConcatenate("bg",i, k), "n", 30, "Wingdings", clrbg);
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_XDISTANCE, 20 * i);
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_YDISTANCE, 23 * k + 11);
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_BACK, false);
      }
   }

   if (!average_true_range)
   {
      step = minimum_step;
      // if (step <= 0) step = minimum;
      if (step <= 0) step = MarketInfo(_Symbol, MODE_STOPLEVEL) * _Point;

      double tickvalue = MarketInfo(_Symbol, MODE_TICKVALUE);
      if (0.5 <= tickvalue && 2 > tickvalue)
      {
         step *= 1.0 + (1.0 - tickvalue);
      }
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expert deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason)
{
   //---
   int line = 12;
   for (int i = 0; i < 8; i++)
   {
      for (int k = 0; k < line; k++)
      {
         ObjectDelete(StringConcatenate("bg", i, k));
         ObjectDelete(StringConcatenate("bg", i, k + 1));
         ObjectDelete(StringConcatenate("bg", i, k + 2));
      }
   }
   ObjectDelete(StringConcatenate(magicnumber, "_NEXT_BUY"));
   ObjectDelete(StringConcatenate(magicnumber, "_NEXT_SELL"));
   Comment("");
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expert iteration function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnTick()
{
   //---
   if (!IsTradeAllowed()) return;
   Main();
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void Main()
{
   //---
   static bool followbuy  = false;
   static bool followsell = false;

   int    total  = 0;
   int    cmd    = -1;
   double profit = 0.0;

   TotalOrders(total, profit, cmd);

   int closed = (int)GlobalVariableGet(magic_close);

   if (target_profit <= profit || 0 < closed)
   {
      if (0 == closed)
      {
         closed = 1;
         GlobalVariableSet(magic_close, 1);
      }

      int cnt = 0;

      if (closeby_enabled)
         cnt = CloseByCycle();
      else
      {
         cnt  = CloseCycle(OP_BUY);
         cnt += CloseCycle(OP_SELL);
      }

      if (0 < cnt)
      {
         string message = StringConcatenate(cnt, " orders closed");
         Print(message);
         MessageSend(message, (int)GetTickCount());
      }

      nextbuy  = 0.0;
      nextsell = 0.0;
      followbuy  = false;
      followsell = false;

      if (trend_following)
      {
         if (cmd == OP_BUY)  followbuy  = true;
         if (cmd == OP_SELL) followsell = true;
      }

      CountOrders(total);
   }

   if (closed && 2 > closed && 0 == total)
   {
      closed = 0;
      GlobalVariableSet(magic_close, 0);
   }

   //---

   atrvalue = (iATR(_Symbol, atr_timeframe, atr_period, 0) * atr_multiple) / pips;

   if (average_true_range)
   {
      // if (!CheckChart()) return;
      step = atrvalue;
      if (step < minimum_step) step = minimum_step;
   }

   //---

   bool   stop_after_close = (int)GlobalVariableGet(magic_stopd);
   bool   on_hold          = (int)GlobalVariableGet(magic_hold);
   int    buycnt  = 0;
   int    sellcnt = 0;
   double buymax  = 0.0;
   double buymin  = 0.0;
   double sellmax = 0.0;
   double sellmin = 0.0;

   ScanOrders(buycnt, sellcnt, buymax, buymin, sellmax, sellmin);

   if (!closed && !stop_after_close && 0 == buycnt + sellcnt)
   {
      if (CompareDoubles(0.0, nextbuy) || CompareDoubles(0.0, nextsell) || (average_true_range && isNewBar(_Symbol, atr_timeframe)))
      {
         nextbuy  = Ask + (step * pips);
         nextsell = Bid - (step * pips);
      }
      if (followbuy)
      {
         if (0 < fOrderSend(_Symbol, OP_BUY, lot_size, Ask, slippage, 0, 0, fComment(comments, buycnt), magicnumber, 0, clrbuy)) followbuy = false;
      }
      if (followsell)
      {
         if (0 < fOrderSend(_Symbol, OP_SELL, lot_size, Bid, slippage, 0, 0, fComment(comments, sellcnt), magicnumber, 0, clrsell)) followsell = false;
      }
   }
   if (0 < buycnt && 0 == sellcnt)
   {
      nextbuy  = buymax + (step * pips);
      nextsell = buymin - (2.0 * step * pips + (Ask - Bid));
   }
   if (0 == buycnt && 0 < sellcnt)
   {
      nextbuy  = sellmax + (2.0 * step * pips + (Ask - Bid));
      nextsell = sellmin - (step * pips);
   }
   if (0 < buycnt && 0 < sellcnt)
   {
      nextbuy  = buymax  + (step * pips);
      nextsell = sellmin - (step * pips);
   }
   if (!closed && !on_hold)
   {
      if (nextbuy <= Ask && !CompareDoubles(0.0, nextbuy))
      {
         fOrderSend(_Symbol, OP_BUY, lot_size, Ask, slippage, 0, 0, fComment(comments, buycnt), magicnumber, 0, clrbuy);
      }
      if (Bid <= nextsell && !CompareDoubles(0.0, nextsell))
      {
         fOrderSend(_Symbol, OP_SELL, lot_size, Bid, slippage, 0, 0, fComment(comments, sellcnt), magicnumber, 0, clrsell);
      }
   }
   //---
   ShowDisplay(closed, stop_after_close, on_hold);
   return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderSend(string symbol, int cmd, double lots, double price, int slip = 3, double stoploss = 0.0, double takeprofit = 0.0, string comment = NULL, int magic = 0, datetime expiration = 0, int arrow_color = clrNONE)
{
   // static datetime time = 0;
   // if (60 > TimeCurrent() - time) return (-1);

   int ticket = -1;
   for (int i = 0; i < RepeatN; i++)
   {
      RefreshRates();
      if (cmd == OP_BUY)  price = MarketInfo(symbol, MODE_ASK);
      if (cmd == OP_SELL) price = MarketInfo(symbol, MODE_BID);
      lots = fmin(fmax(lots, MarketInfo(symbol, MODE_MINLOT)), MarketInfo(symbol, MODE_MAXLOT));

      ticket = OrderSend(symbol, cmd, lots, price, slip, stoploss, takeprofit, comment, magic, expiration, arrow_color);

      if (0 < ticket && OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
      {
         // time = TimeCurrent();
         break;
      }
      else
      {
         int e = GetLastError();
         string message = StringConcatenate("OrderSend Error: ", e, " ", ErrorDescription(e));
         Print(message);
         MessageSend(message, e);
         Sleep(1000);
      }
   }
   return (ticket);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool fOrderClose(int ticket, double lots, double price, int slip = 3, color arrow_color = clrNONE)
{
   bool ret = false;
   for (int i = 0; i < RepeatN; i++)
   {
      RefreshRates();
      if (OrderType() == OP_BUY)  price = MarketInfo(OrderSymbol(), MODE_BID);
      if (OrderType() == OP_SELL) price = MarketInfo(OrderSymbol(), MODE_ASK);

      ret = OrderClose(ticket, lots, price, slip, arrow_color);

      if (ret) break;
      else
      {
         int e = GetLastError();
         string message = StringConcatenate("OrderClose Error: ", e, " ", ErrorDescription(e));
         Print(message);
         MessageSend(message, e);
         Sleep(1000);
      }
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int CloseCycle(int cmd)
{
   int ret = 0;
   for (int i = 0; 100 > i; i++)
   {
      RefreshRates();
      if (0 < SymbolOrdersCount(cmd)) ret += OrderCloseCycle(cmd);
      else break;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OrderCloseCycle(int cmd)
{
   int ret = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() != cmd) continue;
      if (OrderType() == OP_BUY)
      {
         if (fOrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrbuy)) ret++;
         Sleep(1000);
      }
      if (OrderType() == OP_SELL)
      {
         if (fOrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrsell)) ret++;
         Sleep(1000);
      }
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int CloseByCycle()
{
   if (!closeby_enabled) return (0);
   int buy[];
   int sell[];
   int ret = 0;
   for (int i = 0; 100 > i; i++)
   {
      RefreshRates();
      if (0 < OrderTicketCount(buy, sell)) ret += fOrderCloseByCycle(buy, sell);
      else break;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OrderTicketCount(int &buy[], int &sell[])
{
   ArrayResize(buy,  100);
   ArrayResize(sell, 100);
   ArrayInitialize(buy,  0);
   ArrayInitialize(sell, 0);

   int buycnt = 0, sellcnt = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() == OP_BUY)
      {
         buy[buycnt] = OrderTicket();
         buycnt++;
      }
      if (OrderType() == OP_SELL)
      {
         sell[sellcnt] = OrderTicket();
         sellcnt++;
      }
   }

   ArrayResize(buy, buycnt);
   ArrayResize(sell, sellcnt);

   return (buycnt + sellcnt);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderCloseByCycle(int &buy[], int &sell[])
{
   int ret  = 0;
   int buysize  = ArraySize(buy);
   int sellsize = ArraySize(sell);

   for (int i = 0; i < fmax(buysize, sellsize); i++)
   {
      if (i < buysize && i < sellsize && buy[i] != 0 && sell[i] != 0)
      {
         if (fOrderCloseBy(fmin(buy[i], sell[i]), fmax(buy[i], sell[i]), clrby)) ret += 2;
      }
      else
      {
         if (i < buysize)
         {
            if (OrderSelect(buy[i], SELECT_BY_TICKET, MODE_TRADES))
            {
              if (fOrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrbuy)) ret++;
            }
         }
         if (i < sellsize)
         {
            if (OrderSelect(sell[i], SELECT_BY_TICKET, MODE_TRADES))
            {
               if (fOrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrsell)) ret++;
            }
         }
      }
      if (!closeby_enabled) return (0);
      Sleep(1000);
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool fOrderCloseBy(int ticket, int opposite, color arrow_color = clrNONE)
{
   if (!closeby_enabled) return (false);
   bool ret = false;
   for (int i = 0; i < RepeatN; i++)
   {
      RefreshRates();
      ret = OrderCloseBy(ticket, opposite, arrow_color);
      if (ret) break;
      else
      {
         int e = GetLastError();
         string message = StringConcatenate("OrderCloseBy Error: ", e, " ", ErrorDescription(e));
         Print(message);
         MessageSend(message, e);
         if (3 == e) /* Invalid Trade - case of broker don't support CloseBy */
         {
            closeby_enabled = false;
            message = StringConcatenate(comments, " on Symbol ", _Symbol, ": CLOSEBY DISABLED!");
            Print(message);
            MessageSend(message, -1);
         }
         Sleep(1000);
      }
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderType()
{
   int ret = -1;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      ret = OrderType();
      break;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int SymbolOrdersCount(int cmd)
{
   int ret = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() == cmd) ret++;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void TotalOrders(int &count, double &total, int &cmd)
{
   count = 0;
   cmd   = -1;
   total = 0.0;
   int    ticket = -1;
   double value  = 0.0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() <= OP_SELL) count++;
      value = OrderProfit() + OrderSwap() + OrderCommission();
      total += value;
      if (OrderSymbol() == _Symbol)
      {
         if (ticket < OrderTicket() && 0.0 < value)
         {
            cmd    = OrderType();
            ticket = OrderTicket();
         }
      }
   }
}

void CountOrders(int &count)
{
   count = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() <= OP_SELL) count++;
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ScanOrders(int &buycnt, int &sellcnt, double &buymax, double &buymin, double &sellmax, double &sellmin)
{
   buycnt  = 0;
   sellcnt = 0;
   buymax  = 0.0;
   buymin  = 0.0;
   sellmax = 0.0;
   sellmin = 0.0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != _Symbol) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() == OP_BUY)
      {
         buycnt++;
         buymax = fmax(buymax, OrderOpenPrice());
         buymin = CompareDoubles(0.0, buymin) ? OrderOpenPrice() : fmin(buymin, OrderOpenPrice());
      }
      if (OrderType() == OP_SELL)
      {
         sellcnt++;
         sellmax = fmax(sellmax, OrderOpenPrice());
         sellmin = CompareDoubles(0.0, sellmin) ? OrderOpenPrice() : fmin(sellmin, OrderOpenPrice());
      }
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double AutoLots(double lots = 0)
{
   double max = MarketInfo(_Symbol, MODE_MAXLOT);
   double min = MarketInfo(_Symbol, MODE_MINLOT);
   double ret = 0 < lots ? lots : floor(AccountEquity() / balance) * min;
   ret = fmin(fmin(fmax(ret, min), max), maxlots);
   // if (min == 1.0)  ret = NormalizeDouble(ret, 0);
   // if (min == 0.1)  ret = NormalizeDouble(ret, 1);
   // if (min == 0.01) ret = NormalizeDouble(ret, 2);
   ret = NormalizeDouble(ret, 2);
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string fComment(string comment, int count)
{
   string ret = "";
   if (0 < StringLen(comment)) ret = StringConcatenate(comment, "_", count + 1);
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
bool CheckChart()
{
   if (_Period != atr_timeframe)
   {
      Comment("\nATTENTION PLEASE!\n ", _Symbol, " is made to run on 4H timeframe.");
      return (false);
   }

   if (Bars < atr_period)
   {
      Comment("\nATTENTION PLEASE!\n ", _Symbol, " has not enough historical data to run.");
      return (false);
   }
   return (true);
}
*/
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void ShowDisplay(bool closed = false, bool stop_after_close = false, bool on_hold = false)
{
   if (IsTesting() && !IsVisualMode()) return;

   string verticalbar = "";
   for (int i = 0; i < Seconds() % 40; i++) verticalbar += "|";

   string status = "RUNNING";
   if (stop_after_close) status = "RUNNING (stop after close)";
   if (on_hold)          status = "RUNNING (on hold)";
   if (closed)           status = "STOPPED";
   if (0 == (int)MarketInfo(_Symbol, MODE_TRADEALLOWED)) status = "TRADE_NOT_ALLOWED";

   int buy1 = 0, sell1 = 0, total1 = 0, buy2 = 0, sell2 = 0, total2 = 0;
   double value1 = 0.0, value2 = 0.0;
   OrdersCount(buy1, sell1, total1, value1, buy2, sell2, total2, value2);

   static int total = -1;
   static double closedprofit = 0.0, totalclosedprofit = 0.0;
   if (total != buy2 + sell2)
   {
      HistoryProfit(totalclosedprofit, closedprofit);
      total = buy2 + sell2;
   }

   double totalmaxfloating = GlobalVariableGet(magic_maxdd);
   if (totalmaxfloating > value2)
   {
      totalmaxfloating = value2;
      GlobalVariableSet(magic_maxdd, totalmaxfloating);
   }

   // Comment("\n ReticoloFX v1.51", "\n " + mod_ver,
   Comment("\n ", DrawDown(total2),
      "\n ======================",
      "\n ", verticalbar,
      "\n ----------------------------------------------------",
      "\n Status  ", status,
      "\n ----------------------------------------------------",
      "\n ", _Symbol, " Spread  ", DoubleToString((Ask - Bid) / pips, 2),
      "\n ", _Symbol, " Step  ", DoubleToString(step, 2), "  /  ", DoubleToString(atrvalue, 2),
      "\n ", _Symbol, " Next Buy  ", DoubleToString(nextbuy, _Digits),
      "\n ", _Symbol, " Next Sell  ", DoubleToString(nextsell, _Digits),
      "\n ----------------------------------------------------",
      "\n ", _Symbol, " Orders  BUY  ", buy1, "  /  SELL  ", sell1,
      "\n ", _Symbol, " Orders Value  ", DoubleToString(value1, 2),
      "\n ", _Symbol, " Closed Profit  ", DoubleToString(closedprofit, 2),
      "\n ----------------------------------------------------",
      "\n TOTAL Orders  BUY  ", buy2, "  /  SELL  ", sell2,
      "\n TOTAL Orders Value  ", DoubleToString(value2, 2),
      "\n TOTAL Closed Profit  ", DoubleToString(totalclosedprofit, 2),
      "\n TOTAL Max Floating DD  ", DoubleToString(totalmaxfloating, 2),
      "\n ----------------------------------------------------",
      "\n Instance  ", advisor_instance, "  /  Magic  ", magicnumber,
      "\n ----------------------------------------------------");

   if (show_next_trades)
   {
      static double pre = 0.0;
      if (pre != nextbuy + nextsell)
      {
         if (!ObjectSet(objectbuy,  OBJPROP_PRICE1, nextbuy) ||
             !ObjectSet(objectsell, OBJPROP_PRICE1, nextsell))
         {
            if (0 > ObjectFind(objectbuy))
            {
               ObjectCreate(objectbuy, OBJ_HLINE, 0, 0, 0);
               ObjectSet(objectbuy, OBJPROP_COLOR, clrbuy);
               ObjectSet(objectbuy, OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(objectbuy, OBJPROP_BACK, false);
            }
            if (0 > ObjectFind(objectsell))
            {
               ObjectCreate(objectsell, OBJ_HLINE, 0, 0, 0);
               ObjectSet(objectsell, OBJPROP_COLOR, clrsell);
               ObjectSet(objectsell, OBJPROP_STYLE, STYLE_DOT);
               ObjectSet(objectsell, OBJPROP_BACK, false);
            }
         }
         pre = nextbuy + nextsell;
      }
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OrdersCount(int &buy1, int &sell1, int &total1, double &value1, int &buy2, int &sell2, int &total2, double &value2)
{
   buy1 = 0;
   buy2 = 0;
   sell1 = 0;
   sell2 = 0;
   value1 = 0.0;
   value2 = 0.0;
   double value = 0.0;

   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      value = OrderProfit() + OrderSwap() + OrderCommission();
      if (OrderSymbol() == _Symbol)
      {
         if (OrderType() == OP_BUY)  buy1++;
         if (OrderType() == OP_SELL) sell1++;
         value1 += value;
      }
      if (OrderType() == OP_BUY)  buy2++;
      if (OrderType() == OP_SELL) sell2++;
      value2 += value;
   }

   total1 = buy1 + sell1;
   total2 = buy2 + sell2;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void HistoryProfit(double &total, double &profit)
{
   profit = 0.0;
   total  = 0.0;
   double value = 0.0;

   for (int i = OrdersHistoryTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      value = OrderProfit() + OrderSwap() + OrderCommission();
      if (OrderSymbol() == _Symbol) profit += value;
      total += value;
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string DrawDown(int b)
{
   //---
   // static string space = "                               | ";
   static string s3 = StringConcatenate(magicnumber, "_orders_total");
   static string s1 = StringConcatenate(magicnumber, "_draw_down");
   static string s2 = StringConcatenate(magicnumber, "_percent");

   int    a = (int)GlobalVariableGet(s3);
   double c = GlobalVariableGet(s1);
   double e = GlobalVariableGet(s2);

   double d = AccountBalance() - AccountEquity();
   double f = d * 100.0 / AccountBalance();

   GlobalVariableSet(s3, fmax(a, b));
   GlobalVariableSet(s1, fmax(c, d));
   GlobalVariableSet(s2, fmax(e, f));

   string ret = StringConcatenate("OrdersTotal  ", a, " / ", b,
      "\n DD  ", DoubleToString(c, 2)," (", DoubleToString(e, 2), "%) / ", DoubleToString(d, 2)," (", DoubleToString(f, 2), "%)");
   //---
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int iMakeExpertId(string symbol = "", int instance = 0)
{
  if (1000 <= instance) symbol = "BASKET";
  return(iMakeHash(symbol, (string)instance));
}

// iMakeExpertId()
//
//
//
//+------------------------------------------------------------------+
//
int iMakeHash (string s1, string s2 = "EMPTYSTRING", string s3 = "EMPTYSTRING", string s4 = "EMPTYSTRING", string s5 = "EMPTYSTRING", string s6 = "EMPTYSTRING", string s7 = "EMPTYSTRING", string s8 = "EMPTYSTRING", string s9 = "EMPTYSTRING", string s10 = "EMPTYSTRING")
{
   /*
   Produce 32bit int hash code from  a string composed of up to TEN concatenated input strings.
   WebRef: http://www.cse.yorku.ca/~oz/hash.html
   KeyWrd: "djb2"
   FirstParaOnPage:
   "  Hash Functions
   A comprehensive collection of hash functions, a hash visualiser and some test results [see Mckenzie
   et al. Selecting a Hashing Algorithm, SP&E 20(2):209-224, Feb 1990] will be available someday. If
   you just want to have a good hash function, and cannot wait, djb2 is one of the best string hash
   functions i know. it has excellent distribution and speed on many different sets of keys and table
   sizes. you are not likely to do better with one of the "well known" functions such as PJW, K&R[1],
   etc. Also see tpop pp. 126 for graphing hash functions.
   "

   NOTES:
   0. WARNING - mql4 strings maxlen=255 so... unless code changed to deal with up to 10 string parameters the total length of contactenated string must be <=255
   1. C source uses "unsigned [char|long]", not in MQL4 syntax
   2. When you hash a value, you cannot 'unhash' it. Hashing is a one-way process.
      Using traditional symetric encryption techniques (such as Triple-DES) provide the reversible encryption behaviour you require.
      Ref:http://forums.asp.net/t/886426.aspx subj:Unhash password when using NT Security poster:Participant
   //
   Downside?
   original code uses UNSIGNED - MQL4 not support this, presume could use type double and then cast back to type int.
   */
   string s = StringConcatenate(s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
   int iHash = 5381;
   int iLast = StringLen(s)-1;
   int iPos=0;

   while(iPos <= iLast) // while (c = *str++) [consume str bytes until EOS hit {myWord! isn't C concise! Pity MQL4 is"!"}]
   {
      // original C code: hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
      iHash = ((iHash << 5) + iHash) + StringGetChar(s, iPos); // StringGetChar() returns int
      iPos++;
   }
   return(fabs(iHash));
}
//iMakeHash()

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// isNewBar 1.1
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool isNewBar(string symbol_name, int time_frame, int instance = 0, bool start = false)
{
   static datetime previous[];
          datetime current = (datetime)SeriesInfoInteger(symbol_name, time_frame, SERIES_LASTBAR_DATE);
   if (ArrayRange(previous, 0) < instance + 1)
   {
      ArrayResize(previous, instance + 1);
      previous[instance] = current;
      return (start);
   }
   if (previous[instance] == current) return (false);
   previous[instance] = current;
   return (true);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  PointsPerPip 1.1
//
//  determine the pip multiplier (1 or 10) depending on how many
//  digits the EURUSD symbol has. This is done by first
//  finding the exact name of this symbol in the symbols.raw
//  file (it could be EURUSDm or EURUSDiam or any other stupid name
//  the broker comes up with only to break other people's code)
//  and then usig MarketInfo() for determining the digits.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

double PointsPerPip()
{
   double ppp = 10.0;
   int f = FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
   for (int i = 0, count = (int)(FileSize(f) / 1936); count > i; i++)
   {
      string symbol = FileReadString(f, 12);
      if (StringFind(symbol, "EURUSD") != -1)
      {
         int digits = (int)MarketInfo(symbol, MODE_DIGITS);
         ppp = (5 == digits ? 10.0 : 6 == digits ? 100.0 : 1.0);
         break;
      }
      FileSeek(f, 1924, SEEK_CUR);
   }
   FileClose(f);
   return (ppp);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void MessageSend(string message, int error) //--- MessageSend 1.1
{
   if (IsDemo()) return;

   string apikey = "";
   string chatid = "";
   int    keep   = 0;

   if (keep == error) return;
   keep = error;

   message = StringConcatenate(AccountNumber(), "_", comments, "\n", message);
   TelegramSendTextAsync(apikey, chatid, message);
   SendNotification(message);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
