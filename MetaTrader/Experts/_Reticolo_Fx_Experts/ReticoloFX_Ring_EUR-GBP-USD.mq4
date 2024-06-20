
#property copyright   "ReticoloFX Mod M5"
#property link        "http://forum.tradelikeapro.ru"
#property version     "1.51"
#property description "ApMSoft Mod M5 07.03.2013"
#property strict

#include <stdlib.mqh>

// ApMSoft Mod M5 07 03 Pub //
string mod_ver = "ApMSoft Mod M5"; // 07.03.2013

input  double lot_size         = 0.01;
input  double target_profit    = 10.0;
input  double minimum_step     = 20.0;;  // pips
extern bool   stop_after_close = false;
input  bool   trend_following  = true;
extern bool   closeby_enabled  = true;
input  bool   on_hold          = false;
input  bool   show_next_trades = true;
extern string commentary       = "";

bool   average_true_range = false;
ENUM_TIMEFRAMES atr_timeframe = PERIOD_H4;
int    atr_period       = 30;
double atr_multiple     = 1.0;

bool     BUY  = false;
bool     SELL = false;
bool     stopped = false;
datetime LineRedrawTime = 0;
double   minimum = 20.0; // 3.0
double   nextbuy  = 0.0;
double   nextsell = 0.0;
double   pips = 0.0;
double   step = 20.0; // 30.0
int      magicnumber = 0;
int      repeat = 3;
int      Slippage = 3;
int      buytickets[];
int      selltickets[];
string   currencypair[]; // init rings
string   magic_close;
string   magic_maxdd;
string   objectbuy;
string   objectsell;
string   settings = "";

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expert initialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int OnInit()
{
   //---
   settings = WindowExpertName();
   if (commentary == "")
   {
      commentary = settings;
      int replaced = StringReplace(commentary, "ReticoloFX_", "");
   }
   fInitSettings(settings);
   Print(_Symbol, " TickValue = ", DoubleToString(MarketInfo(_Symbol, MODE_TICKVALUE), 2));
   //---
   // Comment(StringConcatenate("\nWaiting for tick update on ", _Symbol, " ..."));
   return (INIT_SUCCEEDED);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void fInitSettings(string expertname)
{
   magicnumber  = fGenMagic(expertname);
   string magic = (string)magicnumber;

   magic_close = magic + "_CLOSE";
   magic_maxdd = magic + "_MAXDD";

   if (!GlobalVariableCheck(magic_close)) GlobalVariableSet(magic_close, 0);
   if (!GlobalVariableCheck(magic_maxdd)) GlobalVariableSet(magic_maxdd, 0);
   if (!GlobalVariableCheck(commentary + "_STOP"))
      GlobalVariableSet(commentary + "_STOP", 2); // ApM - Ring - Basket - Close Flag

   pips = _Point;
   if (_Digits == 3 || _Digits == 5) pips *= 10.0;

   string subfix = StringSubstr(_Symbol, 6, 0);

   if (expertname == "ReticoloFX_Basket_USD")
   {
      ArrayResize(currencypair, 7);
      currencypair[0] = StringConcatenate("AUDUSD", subfix);
      currencypair[1] = StringConcatenate("USDCAD", subfix);
      currencypair[2] = StringConcatenate("USDCHF", subfix);
      currencypair[3] = StringConcatenate("EURUSD", subfix);
      currencypair[4] = StringConcatenate("GBPUSD", subfix);
      currencypair[5] = StringConcatenate("USDJPY", subfix);
      currencypair[6] = StringConcatenate("NZDUSD", subfix);
   }
   if (expertname == "ReticoloFX_Basket_JPY")
   {
      ArrayResize(currencypair, 7);
      currencypair[0] = StringConcatenate("AUDJPY", subfix);
      currencypair[1] = StringConcatenate("CADJPY", subfix);
      currencypair[2] = StringConcatenate("CHFJPY", subfix);
      currencypair[3] = StringConcatenate("EURJPY", subfix);
      currencypair[4] = StringConcatenate("GBPJPY", subfix);
      currencypair[5] = StringConcatenate("USDJPY", subfix);
      currencypair[6] = StringConcatenate("NZDJPY", subfix);
   }
   if (expertname == "ReticoloFX_Basket_EUR") // NEW Basket EURO
   {
      ArrayResize(currencypair, 7);
      currencypair[0] = StringConcatenate("EURGBP", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("EURAUD", subfix);
      currencypair[3] = StringConcatenate("EURCHF", subfix);
      currencypair[4] = StringConcatenate("EURNZD", subfix);
      currencypair[5] = StringConcatenate("EURCAD", subfix);
      currencypair[6] = StringConcatenate("EURJPY", subfix);
   }
   if (expertname == "ReticoloFX_Ring_XAU-EUR-USD") // NEW Ring XAU
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("XAUEUR", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("XAUUSD", subfix);
   }
   if (expertname == "ReticoloFX_Ring_AUD-NZD-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("AUDUSD", subfix);
      currencypair[1] = StringConcatenate("AUDNZD", subfix);
      currencypair[2] = StringConcatenate("NZDUSD", subfix);
   }
   if (expertname == "ReticoloFX_Ring_CAD-EUR-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURUSD", subfix);
      currencypair[1] = StringConcatenate("EURCAD", subfix);
      currencypair[2] = StringConcatenate("USDCAD", subfix);
   }
   if (expertname == "ReticoloFX_Ring_CHF-EUR-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURCHF", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("USDCHF", subfix);
   }
   if (expertname == "ReticoloFX_Ring_CHF-GBP-JPY")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("CHFJPY", subfix);
      currencypair[1] = StringConcatenate("GBPCHF", subfix);
      currencypair[2] = StringConcatenate("GBPJPY", subfix);
   }
   if (expertname == "ReticoloFX_Ring_EUR-GBP-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURGBP", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("GBPUSD", subfix);
   }
   if (expertname == "ReticoloFX_Ring_EUR-JPY-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURJPY", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("USDJPY", subfix);
   }
   //--- ADD
   if (expertname == "ReticoloFX_Basket_USD-EPY")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURUSD", subfix);
      currencypair[1] = StringConcatenate("GBPUSD", subfix);
      currencypair[2] = StringConcatenate("USDJPY", subfix);
   }
   if (expertname == "ReticoloFX_Ring_GBP-JPY-USD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("GBPJPY", subfix);
      currencypair[1] = StringConcatenate("GBPUSD", subfix);
      currencypair[2] = StringConcatenate("USDJPY", subfix);
   }
   if (expertname == "ReticoloFX_Ring_EUR-USD-GOLD")
   {
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("GOLD", subfix);
      currencypair[1] = StringConcatenate("GOLDEURO", subfix);
      currencypair[2] = StringConcatenate("EURUSD", subfix);
   }
   if (expertname == "ReticoloFX_Ring_EUR-GBP-USD-JPY")
   {
      ArrayResize(currencypair, 6);
      currencypair[0] = StringConcatenate("EURUSD", subfix);
      currencypair[1] = StringConcatenate("GBPUSD", subfix);
      currencypair[2] = StringConcatenate("EURGBP", subfix);
      currencypair[3] = StringConcatenate("EURJPY", subfix);
      currencypair[4] = StringConcatenate("GBPJPY", subfix);
      currencypair[5] = StringConcatenate("USDJPY", subfix);
   }
   //--- END
   if (expertname == "ReticoloFX_Ring_EUR-GBP-USD_PUB")
   { // For testing only
      ArrayResize(currencypair, 3);
      currencypair[0] = StringConcatenate("EURGBP", subfix);
      currencypair[1] = StringConcatenate("EURUSD", subfix);
      currencypair[2] = StringConcatenate("GBPUSD", subfix);
   }
   if (!fCheckChart(expertname)) return;

   // ApM chart object remake

   int line = 12;
   for (int i = 0; i < 8; i++)
   {
      for (int k = 0; k < line; k++)
      {
         ObjectDelete(StringConcatenate("bg", i, k));
         ObjectDelete(StringConcatenate("bg", i, k + 1));
         ObjectDelete(StringConcatenate("bg", i, k + 2));
         ObjectCreate(StringConcatenate("bg", i, k), OBJ_LABEL, 0, 0, 0);
         ObjectSetText(StringConcatenate("bg",i, k), "n", 30, "Wingdings", clrBlack); // clrSteelBlue
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_XDISTANCE, 20 * i);
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_YDISTANCE, 23 * k + 11);
         ObjectSet(StringConcatenate("bg", i, k), OBJPROP_BACK, false);
      }
   }

   if (show_next_trades)
   {
      objectbuy = StringConcatenate(expertname, "_", _Symbol, "_NEXT_BUY");
      if (StringLen(objectbuy) > 0)
      {
         ObjectCreate(objectbuy, OBJ_HLINE, 0, 0, 0);
         ObjectSet(objectbuy, OBJPROP_COLOR, clrBlue);
         ObjectSet(objectbuy, OBJPROP_STYLE, STYLE_DOT);
      }
      objectsell = StringConcatenate(expertname, "_", _Symbol, "_NEXT_SELL");
      if (StringLen(objectsell) > 0)
      {
         ObjectCreate(objectsell, OBJ_HLINE, 0, 0, 0);
         ObjectSet(objectsell, OBJPROP_COLOR, clrRed);
         ObjectSet(objectsell, OBJPROP_STYLE, STYLE_DOT);
      }
   }

   step = minimum_step;
   if (!average_true_range)
   {
      // step = minimum_step;
      if (step <= 0) step = minimum;

      double tickvalue = 1.0 + (1.0 - MarketInfo(_Symbol, MODE_TICKVALUE));
      step *= tickvalue;
   }

   fShowDisplay(expertname);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expert deinitialization function
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void OnDeinit(const int reason)
{
   //---
   ObjectsDeleteAll();
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

   int stop = 0;

   if (GlobalVariableCheck(commentary + "_STOP"))
   {
      stop = (int)GlobalVariableGet(commentary + "_STOP");
   }

   // GlobalVariableGet(commentary + "_STOP")
   // 0 (중지하지 않음) 1 (중지)
   // 1 이상으로 설정하면 "stop_after_close"옵션 작동
   if (0 == stop || 1 == stop)
   {
      // GlobalVariableGet(magic_close)
      // 1 모든 트랜잭션을 즉시 닫음
      // 2 모든 트랜잭션을 즉시 닫고 stop_after_close 모드로 이동
      if (0 == (int)GlobalVariableGet(magic_close))
      {
         stop_after_close = (bool)stop;
      }
   }

   fMain(settings, commentary);
   //---
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void fMain(string expertname, string comment)
{
   if (!fCheckChart(expertname)) return;
   int closed = (int)GlobalVariableGet(magic_close);

   if (average_true_range)
   {
      step = (iATR(_Symbol, atr_timeframe, atr_period, 0) * atr_multiple) / pips;
      if (step < minimum_step) step = minimum_step;
   }

   //---

   int buycnt  = 0;
   int sellcnt = 0;
   double buymax  = 0.0;
   double buymin  = 0.0;
   double sellmax = 0.0;
   double sellmin = 0.0;

   fScanOrders(buycnt, sellcnt, buymax, buymin, sellmax, sellmin);

   if (0 == buycnt && 0 == sellcnt)
   {
      stopped = stop_after_close;

      if (0.0 == nextbuy || 0.0 == nextsell || stopped)
      {
         nextbuy  = Ask + (step * pips);
         nextsell = Bid - (step * pips);
      }
      if (0 == closed && BUY)
      {
         if (!stopped && !on_hold)
         {
            if (0 < fOrderSend(_Symbol, OP_BUY, lot_size, Ask, Slippage, 0, 0, fComment(comment, buycnt), magicnumber, 0, 32768)) BUY = false;
         }
      }
      if (0 == closed && SELL)
      {
         if (!stopped && !on_hold)
         {
            if (0 < fOrderSend(_Symbol, OP_SELL, lot_size, Bid, Slippage, 0, 0, fComment(comment, sellcnt), magicnumber, 0, 255)) SELL = false;
         }
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

   //---

   if (0 == closed && nextbuy <= Ask)
   {
      if (!stopped && !on_hold)
         fOrderSend(_Symbol, OP_BUY, lot_size, Ask, Slippage, 0, 0, fComment(comment, buycnt), magicnumber, 0, 32768);
   }

   if (0 == closed && Bid <= nextsell)
   {
      if (!stopped && !on_hold)
         fOrderSend(_Symbol, OP_SELL, lot_size, Bid, Slippage, 0, 0, fComment(comment, sellcnt), magicnumber, 0, 255);
   }

   //---

   int    total  = 0;
   double profit = 0.0;
   fTotalOrders(total, profit);

   if (0 == total) GlobalVariableSet(magic_close, 0);
   closed = (int)GlobalVariableGet(magic_close);
   int cmd = -1;
   if (0 == closed) cmd = fOrderType();

   if (target_profit <= profit || 0 < closed)
   {
      int cnt = 0;
      if (closeby_enabled)
         cnt = fCloseByCycle();
      else
      {
         cnt  = fCloseCycle(OP_BUY);
         cnt += fCloseCycle(OP_SELL);
      }
      /*
      if (0 < cnt)
         Print(StringConcatenate(expertname, ": ", cnt, " orders closed on ", _Symbol, "!"));
      */
      if (0 == closed) GlobalVariableSet(magic_close, 1);
      if (2 == closed) stop_after_close = true;
      if (stop_after_close) stopped = true;

      nextbuy  = 0.0;
      nextsell = 0.0;
      BUY  = false;
      SELL = false;

      if (trend_following)
      {
         if (cmd == OP_BUY)  BUY  = true;
         if (cmd == OP_SELL) SELL = true;
      }
   }
   //---
   fShowDisplay(expertname);
   return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  subroutines and functions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderSend(string symbol, int cmd, double lots, double price, int slippage = 3, double stoploss = 0.0, double takeprofit = 0.0, string comment = NULL, int magic = 0, datetime expiration = 0, int arrow_color = clrNONE)
{
   static datetime time = 0;
   if (60 > TimeCurrent() - time) return (-1);

   int ticket = -1;
   for (int i = 0; i < repeat; i++)
   {
      RefreshRates();
      if (cmd == OP_BUY)  price = MarketInfo(symbol, MODE_ASK);
      if (cmd == OP_SELL) price = MarketInfo(symbol, MODE_BID);

      ticket = OrderSend(symbol, cmd, lots, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);

      if (0 < ticket && OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
      {
         time = TimeCurrent();
         break;
      }
      else
      {
         int e = GetLastError();
         Print("OrderSend Error: ", e, " ", ErrorDescription(e));
         Sleep(10);
      }
   }
   return (ticket);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool fOrderClose(int ticket, double lots, double price, int slippage = 3, color arrow_color = clrNONE)
{
   bool ret = false;
   for (int i = 0; i < repeat; i++)
   {
      RefreshRates();
      if (OrderType() == OP_BUY)  price = MarketInfo(OrderSymbol(), MODE_BID);
      if (OrderType() == OP_SELL) price = MarketInfo(OrderSymbol(), MODE_ASK);

      ret = OrderClose(ticket, lots, price, slippage, arrow_color);

      if (ret) break;
      else
      {
         int e = GetLastError();
         Print("OrderClose Error: ", e, " ", ErrorDescription(e));
         Sleep(10);
      }
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fCloseCycle(int cmd)
{
   int ret = 0;
   for (int i = 0; 100 > i; i++)
   {
      RefreshRates();
      if (0 < SymbolOrdersCount(cmd)) ret += fOrderCloseCycle(cmd);
      else break;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderCloseCycle(int cmd)
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
         if (fOrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrBlue)) ret++;
         Sleep(1000);
      }
      if (OrderType() == OP_SELL)
      {
         if (fOrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrRed)) ret++;
         Sleep(1000);
      }
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fCloseByCycle()
{
   if (!closeby_enabled) return (0);

   int ret = 0;
   for (int i = 0; 100 > i; i++)
   {
      RefreshRates();
      if (0 < fOrderTicketCount(buytickets, selltickets))
         ret += fOrderCloseByCycle(buytickets, selltickets);
      else
         break;
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fOrderTicketCount(int &buy[], int &sell[])
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
         if (fOrderCloseBy(buy[i], sell[i], clrYellow)) ret += 2;
      }
      else
      {
         if (i < buysize)
         {
            if (OrderSelect(buy[i], SELECT_BY_TICKET, MODE_TRADES))
            {
              if (fOrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrBlue)) ret++;
            }
         }
         if (i < sellsize)
         {
            if (OrderSelect(sell[i], SELECT_BY_TICKET, MODE_TRADES))
            {
               if (fOrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrRed)) ret++;
            }
         }
      }
      if (!closeby_enabled) return (0);
      Sleep(100);
   }
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool fOrderCloseBy(int ticket, int opposite, color arrow_color = clrNONE)
{
   if (!closeby_enabled) return (false);

   bool ret = false;
   for (int i = 0; i < repeat; i++)
   {
      RefreshRates();
      ret = OrderCloseBy(ticket, opposite, arrow_color);

      if (ret) break;
      else
      {
         int e = GetLastError();
         Print("OrderCloseBy Error: ", e, " ", ErrorDescription(e));
         if (3 == e) /* Invalid Trade - case of broker don't support CloseBy */
         {
            closeby_enabled = false;
            Print(settings, " on Symbol ", _Symbol, ": CLOSEBY DISABLED!");
         }
         Sleep(10);
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

void fTotalOrders(int &count, double &value)
{
   count = 0;
   value = 0.0;
   for (int i = OrdersTotal()-1; 0 <= i; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != magicnumber) continue;
      if (OrderType() <= OP_SELL) count++;
      value += OrderProfit() + OrderSwap() + OrderCommission();
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void fScanOrders(int &buycnt, int &sellcnt, double &buymax, double &buymin, double &sellmax, double &sellmin)
{
   buycnt  = 0;
   sellcnt = 0;
   buymax = 0.0;
   buymin = 0.0;
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
         buymin = 0.0 < buymin ? fmin(buymin, OrderOpenPrice()) : OrderOpenPrice();
      }
      if (OrderType() == OP_SELL)
      {
         sellcnt++;
         sellmax = fmax(sellmax, OrderOpenPrice());
         sellmin = 0.0 < sellmin ? fmin(sellmin, OrderOpenPrice()) : OrderOpenPrice();
      }
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string fComment(string comment, int count)
{
   string ret = "";
   if (0 < StringLen(comment)) ret = StringConcatenate(comment, "_", count + 1);
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool fCheckChart(string expertname)
{
   bool symbol = false;
   for (int i = 0; i < ArraySize(currencypair); i++)
   {
      if (currencypair[i] == _Symbol)
      {
         symbol = true;
         break;
      }
   }
   if (!symbol)
   {
      Comment("\nATTENTION PLEASE!\n ", expertname, " is not made to work on ", _Symbol);
      return (false);
   }
   if (average_true_range)
   {
      if (_Period != atr_timeframe)
      {
         Comment("\nATTENTION PLEASE!\n ", expertname, " is made to run on 4H timeframe.");
         return (false);
      }

      if (Bars < atr_period)
      {
         Comment("\nATTENTION PLEASE!\n ", _Symbol, " has not enough historical data to run.");
         return (false);
      }
   }
   return (true);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int fGenMagic(string text)
{
   int a = 0, b = 0;
   if (IsTesting()) text = "_" + text;
   for (int i = 0; i < StringLen(text); i++)
   {
      a = StringGetChar(text, i);
      b += a;
      b = fBitShiftCalculator(b, 5);
   }
   for (int i = 0; i < StringLen(text); i++)
   {
      a = StringGetChar(text, i);
      b += a;
      b = fBitShiftCalculator(b, a & 15);
   }
   for (int i = StringLen(text); i > 0; i--)
   {
      a = StringGetChar(text, i - 1);
      b += a;
      b = fBitShiftCalculator(b, b & 15);
   }
   return (b & EMPTY_VALUE);
}

int fBitShiftCalculator(int a, int b)
{
   int c = (1 << b) - 1;
   int d = a & c;
   a >>= b;
   a |= d << (32 - b);
   return (a);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void fShowDisplay(string expertname)
{
   if (IsTesting() && !IsVisualMode()) return;

   string verticalbar = "";
   for (int i = 0; i < Seconds() % 40; i++) verticalbar += "|";

   string status = "RUNNING";
   if (stop_after_close) status = "RUNNING (stop after close)";
   if (on_hold)          status = "RUNNING (on hold)";
   if (stopped)          status = "STOPPED";
   if (0 == (int)MarketInfo(_Symbol, MODE_TRADEALLOWED)) status = "TRADE_NOT_ALLOWED";

   int buy1 = 0, sell1 = 0, total1 = 0, buy2 = 0, sell2 = 0, total2 = 0;
   double value1 = 0.0, value2 = 0.0;
   fOrdersCount(buy1, sell1, total1, value1, buy2, sell2, total2, value2);

   static double closedprofit = 0.0, totalclosedprofit = 0.0;
   fHistoryProfit(totalclosedprofit, closedprofit);

   double totalmaxfloating = GlobalVariableGet(magic_maxdd);
   if (totalmaxfloating > value2)
   {
      totalmaxfloating = value2;
      GlobalVariableSet(magic_maxdd, totalmaxfloating);
   }

   // Comment("\n " + expertname + " " + "v1.51",
   //    "\n " + mod_ver,
   Comment("\n " + fDrawDown(total2),
      "\n ======================",
      "\n ", verticalbar,
      "\n ----------------------------------------------------",
      "\n Status  ", status,
      "\n ----------------------------------------------------",
      "\n " + _Symbol + " Spread  ", DoubleToString((Ask - Bid) / pips, 2),
      "\n " + _Symbol + " Step  ", DoubleToString(step, 2),
      "\n " + _Symbol + " Next Buy  ", DoubleToString(nextbuy, _Digits),
      "\n " + _Symbol + " Next Sell  ", DoubleToString(nextsell, _Digits),
      "\n ----------------------------------------------------",
      "\n " + _Symbol + " Orders  BUY ", buy1, "  /  SELL ", sell1,
      "\n " + _Symbol + " Orders Value  ", DoubleToString(value1, 2),
      "\n " + _Symbol + " Closed Profit  ", DoubleToString(closedprofit, 2),
      "\n ----------------------------------------------------",
      "\n TOTAL Orders  BUY ", buy2, "  /  SELL ", sell2,
      "\n TOTAL Orders Value  ", DoubleToString(value2, 2),
      "\n TOTAL Closed Profit  ", DoubleToString(totalclosedprofit, 2),
      "\n TOTAL Max Floating DD  ", DoubleToString(totalmaxfloating, 2),
      "\n ----------------------------------------------------",
      "\n Magic Number  ", magicnumber,
      "\n ----------------------------------------------------");

   if (60 <= TimeCurrent() - LineRedrawTime || 0 == LineRedrawTime)
   {
      if (show_next_trades)
      {
         static double nbuy = 0.0, nsell = 0.0;
         if (nbuy != nextbuy)
         {
            nbuy = nextbuy;
            ObjectSet(objectbuy, OBJPROP_PRICE1, nextbuy);
         }
         if (nsell != nextsell)
         {
            nsell = nextsell;
            ObjectSet(objectsell, OBJPROP_PRICE1, nextsell);
         }
      }
      LineRedrawTime = TimeCurrent();
   }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void fOrdersCount(int &buy1, int &sell1, int &total1, double &value1, int &buy2, int &sell2, int &total2, double &value2)
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

void fHistoryProfit(double &profit, double &total)
{
   if (60 > TimeCurrent() - LineRedrawTime) return;
   if (!OrdersHistoryTotal()) return;

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

string fDrawDown(int total)
{
   //---
   // static string space = "                               | ";
   static string s1 = StringConcatenate(WindowExpertName(), "_DrawDown");
   static string s2 = StringConcatenate(WindowExpertName(), "_DrawDownPR");
   static string s3 = StringConcatenate(WindowExpertName(), "_OrdersTotal");

   double dd = AccountBalance() - AccountEquity();
   double dp = dd * 100.0 / AccountBalance();
   double gdd = GlobalVariableGet(s1);
   double gdp = GlobalVariableGet(s2);
   int    gtt = (int)GlobalVariableGet(s3);
   string ret = StringConcatenate("OrdersTotal  ", gtt, " / ", total, "\n ", "DD  ", DoubleToString(gdd, 2)," (", DoubleToString(gdp, 2), "%)", " / ", DoubleToString(dd, 2)," (", DoubleToString(dp, 2), "%)");

   GlobalVariableSet(s1, NormalizeDouble(fmax(gdd, dd), 2));
   GlobalVariableSet(s2, NormalizeDouble(fmax(gdp, dp), 2));
   GlobalVariableSet(s3, fmax(gtt, total));
   //---
   return (ret);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
