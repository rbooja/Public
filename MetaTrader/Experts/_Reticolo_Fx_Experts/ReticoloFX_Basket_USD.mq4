#property copyright "BasketFX Mod M5"
#property link      "http://forum.tradelikeapro.ru"

// ApMSoft Mod M5 07 03 Pub //
string modver = "ApMSoft Mod M5"; //07.03.2013

extern double lot_size = 0.01;
extern double target_profit = 10.0;
extern int    minimum_step = 20;
extern bool   stop_after_close = FALSE;
extern bool   trend_following = TRUE;
extern bool   closeby_enabled = TRUE;
extern bool   on_hold = FALSE;
extern bool   show_next_trades = TRUE;
extern bool   show_open_trades = TRUE;
extern bool   show_alert = FALSE;
extern bool   play_sound = FALSE;
extern string comment = "";

string UseSettings;
int stop_after_global = 0;
int li_TC = 0;
bool gi_firstrun = FALSE;
bool gi_304 = TRUE;
double gd_308 = 3.0;
double gd_352 = 1.0;
int gi_360 = 30;
int gi_368 = 30;
bool gi_372 = TRUE;
int gi_376 = 1;
double gd_380 = 5.0;
double gd_392;
double gd_400;
double g_TotalMaxFloatingPL;
double gd_432;
double gd_440;
double gd_448;
double gd_456;
int gi_480;
int gi_484;
int gi_488;
bool gi_492 = FALSE;
bool gi_496 = FALSE;
string gs_CLOSE;
string gs_MAXDD;
double gd_516 = 0.0;
double gd_524 = 0.0;
int g_Magic;
string gs_540;
bool gi_548 = FALSE;
string gs_552;
string gs_560;
string gsa_536[]; // init rings
int gia_568[]; //1
int gia_572[]; //2
int gi_576 = clrBlack;
string gs_580; //comment string
bool gi_588 = TRUE;
int gi_364 = PERIOD_H4;
int line_redraw_time;

int init() {
   UseSettings = WindowExpertName();
   if (comment == "") comment = UseSettings;
   fInitSettings(UseSettings);
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   Comment("");
   return (0);
}

int start() {
   if (!IsTradeAllowed()) return;
   if (!gi_firstrun) {
      f0_6(UseSettings);
      gi_firstrun = TRUE;
   } else {
   if (GlobalVariableCheck(comment+"_STOP")) stop_after_global = GlobalVariableGet(comment+"_STOP");
   if ((stop_after_global == 0 || stop_after_global == 1) && GlobalVariableGet(gs_CLOSE) == 0) stop_after_close = stop_after_global;
   f0_53(UseSettings, comment);
          }
   return (0);
}

int f0_2(string as_0, int ai_8, double ad_12, double ad_20, int ai_28, double ad_32, double ad_40, string as_48 = "", int ai_56 = 0, int ai_60 = 0, color ai_64 = -1) {
   int li_72 = -2;
   if (TimeCurrent() - li_TC >= 60) {
      li_72 = OrderSend(as_0, ai_8, ad_12, ad_20, ai_28, ad_32, ad_40, as_48, ai_56, ai_60, ai_64);
      li_TC = TimeCurrent();
   }
   return (li_72);
}

int f0_51(string as_0, int ai_8, double ad_12, double ad_20, int ai_28, double ad_32, double ad_40, string as_48 = "", int ai_56 = 0, int ai_60 = 0, int ai_64 = -1) {
   int li_68;
   int li_72;
   while (true) {
      if (IsStopped()) {
         fPrint("orderSendReliable(): Trading is stopped!");
         return (-1);
      }
      RefreshRates();
      if (ai_8 == 0) ad_20 = Ask; else ad_20 = Bid;
      if (!IsTradeContextBusy()) {
         li_68 = f0_2(as_0, ai_8, ad_12, NormalizeDouble(ad_20, MarketInfo(as_0, MODE_DIGITS)), ai_28, NormalizeDouble(ad_32, MarketInfo(as_0, MODE_DIGITS)), NormalizeDouble(ad_40,
            MarketInfo(as_0, MODE_DIGITS)), as_48, ai_56, ai_60, ai_64);
         if (li_68 == -2) return(0); // ApM fix for STUPID Error of original advisor
         fPrint("orderSendReliable(" + as_0 + "," + ai_8 + "," + ad_12 + "," + ad_20 + "," + ai_28 + "," + ad_32 + "," + ad_40 + "," + as_48 + "," + ai_56 + "," + ai_60 + "," + ai_64 + ")");
         if (li_68 > 0) {
            fPrint("orderSendReliable(): Success! Ticket: " + li_68);
            return (li_68);
         }
         li_72 = GetLastError();
         if (fTempErrorz(li_72)) fPrint("orderSendReliable(): Temporary Error: " + li_72 + " " + ErrorDescription(li_72) + ". waiting.");
         else {
            fPrint("orderSendReliable(): Permanent Error: " + li_72 + " " + ErrorDescription(li_72) + ". giving up.");
            return (-1);
         }
      } // else fPrint("orderSendReliable(): Must wait for trade context");
      Sleep(MathRand() / 10);
   }
   return /*(WARN)*/;
}

bool orderCloseReliable(int ai_0, double ad_4, double ad_12, int ai_20, color ai_24 = -1) {
   bool li_28;
   int li_32;
   fPrint("orderCloseReliable(" + ai_0 + ")");
   OrderSelect(ai_0, SELECT_BY_TICKET, MODE_TRADES);
   while (true) {
      if (IsStopped()) {
         fPrint("orderCloseReliable(" + ai_0 + "): Trading is stopped!");
         return (0);
      }
      RefreshRates();
      if (OrderType() == OP_BUY) ad_12 = Bid;
      if (OrderType() == OP_SELL) ad_12 = Ask;
      if (!IsTradeContextBusy()) {
         li_28 = OrderClose(ai_0, ad_4, NormalizeDouble(ad_12, MarketInfo(OrderSymbol(), MODE_DIGITS)), ai_20, ai_24);
         if (li_28) {
            fPrint("orderCloseReliable(" + ai_0 + "): Success!");
            return (1);
         }
         li_32 = GetLastError();
         if (fTempErrorz(li_32)) fPrint("orderCloseReliable(" + ai_0 + "): Temporary Error: " + li_32 + " " + ErrorDescription(li_32) + ". waiting.");
         else {
            fPrint("orderCloseReliable(" + ai_0 + "): Permanent Error: " + li_32 + " " + ErrorDescription(li_32) + ". giving up.");
            return (0);
         }
      } // else fPrint("orderCloseReliable(" + ai_0 + "): Must wait for trade context");
      Sleep(MathRand() / 10);
   }
   return /*(WARN)*/;
}

bool orderCloseByReliable(int ai_0, int ai_4, color ai_8 = CLR_NONE) {
   if (closeby_enabled == false) return(false);
   bool li_12;
   int li_16;
   fPrint("orderCloseByReliable(#" + ai_0 + " by #" + ai_4 +")"); //apm
   while (true) {
      if (IsStopped()) {
         fPrint("orderCloseByReliable(): Trading is stopped!");
         return (0);
      }
      if (!IsTradeContextBusy()) {
         li_12 = OrderCloseBy(ai_0, ai_4, ai_8);
         if (li_12) {
            fPrint("orderCloseByReliable(): Success!");
            return (1);
         }
         li_16 = GetLastError();
         if (fTempErrorz(li_16)) fPrint("orderCloseByReliable(): Temporary Error: " + li_16 + " " + ErrorDescription(li_16) + ". waiting.");
         else {
            /*if (li_16 == 3) { /* Invalid Trade - case of broker don't support CloseBy */
            closeby_enabled = false; Print(UseSettings + " on Symbol " + Symbol() + ": CLOSEBY DISABLED!");//}
            fPrint("orderCloseByReliable(): Permanent Error: " + li_16 + " " + ErrorDescription(li_16) + ". giving up.");
            return (0);
         }
      } // else fPrint("orderCloseByReliable(): Must wait for trade context");
      Sleep(MathRand() / 10);
   }
   return /*(WARN)*/;
}

bool fTempErrorz(int ai_0) {
   return (ai_0 == 0 || ai_0 == 2 || ai_0 == 4 || ai_0 == 6 || ai_0 == 132 || ai_0 == 135 || ai_0 == 129 || ai_0 == 136 || ai_0 == 137 || ai_0 == 138 || ai_0 == 128 ||
      ai_0 == 146);
}

int fGenMagic(string as_0) {
   int li_12;
   int li_16 = 0;
   if (IsTesting()) as_0 = "_" + as_0;
   for (int li_8 = 0; li_8 < StringLen(as_0); li_8++) {
      li_12 = StringGetChar(as_0, li_8);
      li_16 += li_12;
      li_16 = f0_27(li_16, 5);
   }
   for (li_8 = 0; li_8 < StringLen(as_0); li_8++) {
      li_12 = StringGetChar(as_0, li_8);
      li_16 += li_12;
      li_16 = f0_27(li_16, li_12 & 15);
   }
   for (li_8 = StringLen(as_0); li_8 > 0; li_8--) {
      li_12 = StringGetChar(as_0, li_8 - 1);
      li_16 += li_12;
      li_16 = f0_27(li_16, li_16 & 15);
   }
   return (li_16 & EMPTY_VALUE);
}

int f0_27(int ai_0, int ai_4) {
   int li_16 = 1 << ai_4 - 1;
   int li_12 = ai_0 & li_16;
   ai_0 >>= ai_4;
   ai_0 |= li_12 << (32 - ai_4);
   return (ai_0);
}

int fInitSettings(string as_0) {
   f0_6(as_0);
   gi_firstrun = TRUE;
   return (0);
}

int f0_6(string as_0) {
   g_Magic = fGenMagic(as_0);
   string ls_8 = g_Magic;
   GlobalVariableDel(ls_8);
   GlobalVariableDel(ls_8 + "_" + Symbol() + "_ASK");
   GlobalVariableDel(ls_8 + "_" + Symbol() + "_BID");
   gs_CLOSE = ls_8 + "_CLOSE";
   gs_MAXDD = ls_8 + "_MAXDD";
   if (!GlobalVariableCheck(gs_CLOSE)) GlobalVariableSet(gs_CLOSE, 0);
   if (!GlobalVariableCheck(gs_MAXDD)) GlobalVariableSet(gs_MAXDD, 0);
   if (!GlobalVariableCheck(comment+"_STOP")) GlobalVariableSet(comment+"_STOP", 2); // ApM - Ring - Basket - Close Flag
   if (Digits == 3 || Digits == 5) {
      gd_392 = 10.0 * Point;
      gd_400 = 10;
   } else {
      gd_392 = Point;
      gd_400 = 1;
   }
   gs_540 = StringSubstr(Symbol(), 6, 0);
   if (as_0 == "ReticoloFX_Basket_USD") {
      ArrayResize(gsa_536, 7);
      gsa_536[0] = fCon2Strings("AUDUSD", gs_540);
      gsa_536[1] = fCon2Strings("USDCAD", gs_540);
      gsa_536[2] = fCon2Strings("USDCHF", gs_540);
      gsa_536[3] = fCon2Strings("EURUSD", gs_540);
      gsa_536[4] = fCon2Strings("GBPUSD", gs_540);
      gsa_536[5] = fCon2Strings("USDJPY", gs_540);
      gsa_536[6] = fCon2Strings("NZDUSD", gs_540);
   }
   if (as_0 == "ReticoloFX_Basket_JPY") {
      ArrayResize(gsa_536, 7);
      gsa_536[0] = fCon2Strings("AUDJPY", gs_540);
      gsa_536[1] = fCon2Strings("CADJPY", gs_540);
      gsa_536[2] = fCon2Strings("CHFJPY", gs_540);
      gsa_536[3] = fCon2Strings("EURJPY", gs_540);
      gsa_536[4] = fCon2Strings("GBPJPY", gs_540);
      gsa_536[5] = fCon2Strings("USDJPY", gs_540);
      gsa_536[6] = fCon2Strings("NZDJPY", gs_540);
   }
   if (as_0 == "ReticoloFX_Basket_EUR") { // NEW Basket EURO
      ArrayResize(gsa_536, 7);
      gsa_536[0] = fCon2Strings("EURGBP", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("EURAUD", gs_540);
      gsa_536[3] = fCon2Strings("EURCHF", gs_540);
      gsa_536[4] = fCon2Strings("EURNZD", gs_540);
      gsa_536[5] = fCon2Strings("EURCAD", gs_540);
      gsa_536[6] = fCon2Strings("EURJPY", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_XAU-EUR-USD") { // NEW Ring XAU
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("XAUEUR", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("XAUUSD", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_AUD-NZD-USD") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("AUDUSD", gs_540);
      gsa_536[1] = fCon2Strings("AUDNZD", gs_540);
      gsa_536[2] = fCon2Strings("NZDUSD", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_CAD-EUR-USD") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("EURUSD", gs_540);
      gsa_536[1] = fCon2Strings("EURCAD", gs_540);
      gsa_536[2] = fCon2Strings("USDCAD", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_CHF-EUR-USD") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("EURCHF", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("USDCHF", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_CHF-GBP-JPY") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("CHFJPY", gs_540);
      gsa_536[1] = fCon2Strings("GBPCHF", gs_540);
      gsa_536[2] = fCon2Strings("GBPJPY", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_EUR-GBP-USD") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("EURGBP", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("GBPUSD", gs_540);
   }
   if (as_0 == "ReticoloFX_Ring_EUR-JPY-USD") {
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("EURJPY", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("USDJPY", gs_540);
   }
/*   if (as_0 == "ReticoloFX_Ring_EUR-GBP-USD_PUB") { //For testing only
      ArrayResize(gsa_536, 3);
      gsa_536[0] = fCon2Strings("EURGBP", gs_540);
      gsa_536[1] = fCon2Strings("EURUSD", gs_540);
      gsa_536[2] = fCon2Strings("GBPUSD", gs_540);
   }*/
   if (f0_46(as_0) == 0) return (0);
   // ApM chart object remake
   int li_44 = 12;
      for (int li_48 = 0; li_48 < 8; li_48++) {
         for (int li_52 = 0; li_52 < li_44; li_52++) {
            ObjectDelete("background" + li_48 + li_52);
            ObjectDelete("background" + li_48 + ((li_52 + 1)));
            ObjectDelete("background" + li_48 + ((li_52 + 2)));
            ObjectCreate("background" + li_48 + li_52, OBJ_LABEL, 0, 0, 0);
            ObjectSetText("background" + li_48 + li_52, "n", 30, "Wingdings", gi_576);
            ObjectSet("background" + li_48 + li_52, OBJPROP_XDISTANCE, 20 * li_48);
            ObjectSet("background" + li_48 + li_52, OBJPROP_YDISTANCE, 23 * li_52 + 11);
            ObjectSet("background" + li_48 + li_52,  OBJPROP_BACK, FALSE);
         }
      }
   if (show_next_trades) {
      gs_552 = fCon4Strings(as_0, "_", Symbol(), "_NEXT_BUY");
      if (StringLen(gs_552) > 0) {
         ObjectCreate(gs_552, OBJ_HLINE, 0, 0, 0);
         ObjectSet(gs_552, OBJPROP_COLOR, Blue);
         ObjectSet(gs_552, OBJPROP_STYLE, STYLE_DASH);
      }
      gs_560 = fCon4Strings(as_0, "_", Symbol(), "_NEXT_SELL");
      if (StringLen(gs_560) > 0) {
         ObjectCreate(gs_560, OBJ_HLINE, 0, 0, 0);
         ObjectSet(gs_560, OBJPROP_COLOR, Red);
         ObjectSet(gs_560, OBJPROP_STYLE, STYLE_DASH);
      }
   }
   if (gi_304 == FALSE) {
      gi_368 = gd_308;
      if (gi_368 <= 0) gi_368 = minimum_step;
   }
   gs_580 = as_0;
   f0_0(as_0);
   return (0);
}

int f0_46(string as_0) {
   bool li_8 = FALSE;
   for (int li_12 = 0; li_12 < ArraySize(gsa_536); li_12++) {
      if (gsa_536[li_12] == Symbol()) {
         li_8 = TRUE;
 break;
      }
   }
   if (li_8 == FALSE) {
      Comment("\nATTENTION PLEASE!"
      + "\n " + as_0 + " is not made to work on " + Symbol());
      return (0);
   }
   if (gi_304 && Period() != gi_364) {
      Comment("\nATTENTION PLEASE!"
      + "\n " + as_0 + " is made to run on 4H timeframe.");
      return (0);
   }
   if (gi_304 && Bars < gi_360) {
      Comment("\nATTENTION PLEASE!"
      + "\n " + Symbol() + " has not enough historical data to run.");
      return (0);
   }
   return (1);
}

int f0_53(string as_0, string as_8) {
   if (f0_46(as_0) == 0) return (0);
   int li_36;
   string ls_44;
   int li_16 = GlobalVariableGet(gs_CLOSE);
   gi_480 = f0_57(Symbol(), OP_BUY, g_Magic);
   gi_484 = f0_57(Symbol(), OP_SELL, g_Magic);
   if (gi_304) {
      gi_368 = fDivide(fMultiply(iATR(Symbol(), gi_364, gi_360, 0), gd_352), gd_392);
      if (gi_368 < minimum_step) gi_368 = minimum_step;
   }
   if (gi_480 == 0 && gi_484 == 0) {
      gi_548 = stop_after_close;
      if (gd_516 == 0.0 || gd_524 == 0.0 || gi_548) {
         f0_5(fPlus(Ask, fMultiply(gi_368, gd_392)));
         f0_16(fMinus(Bid, fMultiply(gi_368, gd_392)));
      }
      if (li_16 == 0 && gi_492) {
         if (gi_548 == FALSE && on_hold == FALSE) {
               if (f0_51(Symbol(), 0, lot_size, Ask, gd_380, 0, 0, f0_38(as_8, gi_480), g_Magic, 0, 32768) > 0) gi_492 = FALSE;
         }
      }
      if (li_16 == 0 && gi_496) {
         if (gi_548 == FALSE && on_hold == FALSE) {
               if (f0_51(Symbol(), 1, lot_size, Bid, gd_380, 0, 0, f0_38(as_8, gi_484), g_Magic, 0, 255) > 0) gi_496 = FALSE;
         }
      }
   }
   if (gi_480 > 0 && gi_484 == 0) {
      gd_432 = f0_3(g_Magic);
      f0_5(fPlus(gd_432, fMultiply(gi_368, gd_392)));
      gd_448 = f0_58(g_Magic);
      f0_16(fPlus1(gd_448, -(Ask - Bid), -fMultiply2(2, gi_368, gd_392)));
   }
   if (gi_480 == 0 && gi_484 > 0) {
      gd_440 = f0_43(g_Magic);
      f0_16(fMinus(gd_440, fMultiply(gi_368, gd_392)));
      gd_456 = f0_1(g_Magic);
      f0_5(fPlus1(gd_456, Ask - Bid, fMultiply2(2, gi_368, gd_392)));
   }
   if (gi_480 > 0 && gi_484 > 0) {
      gd_432 = f0_3(g_Magic);
      f0_5(fPlus(gd_432, fMultiply(gi_368, gd_392)));
      gd_440 = f0_43(g_Magic);
      f0_16(fMinus(gd_440, fMultiply(gi_368, gd_392)));
   }
   if (li_16 == 0 && Ask >= gd_516) {
      if (gi_548 == FALSE && on_hold == FALSE)
         f0_51(Symbol(), 0, lot_size, Ask, gd_380, 0, 0, f0_38(as_8, gi_480), g_Magic, 0, 32768);
   }
   if (li_16 == 0 && Bid <= gd_524) {
      if (gi_548 == FALSE && on_hold == FALSE)
         f0_51(Symbol(), 1, lot_size, Bid, gd_380, 0, 0, f0_38(as_8, gi_484), g_Magic, 0, 255);
   }
   int li_20 = f0_37(OP_BUY, g_Magic) + f0_37(OP_SELL, g_Magic);
   if (li_20 == 0) GlobalVariableSet(gs_CLOSE, 0);
   double ld_24 = f0_35(g_Magic);
   int li_32 = GlobalVariableGet(gs_CLOSE);
   if (li_32 == 0) gi_488 = f0_25(Symbol(), g_Magic);
   if (ld_24 >= target_profit || li_32 > 0) {
      li_36 = 0;
      if (closeby_enabled) li_36 = fCloseByCycle(Symbol(), g_Magic);
      else {
         li_36 = fCloseCycle(Symbol(), 0, g_Magic);
         li_36 += fCloseCycle(Symbol(), 1, g_Magic);
      }
      if (li_32 == 0) GlobalVariableSet(gs_CLOSE, 1);
      if (play_sound) PlaySound("alert.wav");
      if (show_alert && li_36 > 0) fAlert(as_0 + ": " + li_36 + " orders closed on " + Symbol() + "!");
      if (li_32 == 2) stop_after_close = TRUE;
      if (stop_after_close) gi_548 = TRUE;
      f0_5(0);
      f0_16(0);
      gi_492 = FALSE;
      gi_496 = FALSE;
      if (trend_following) {
         if (gi_488 == 0) gi_492 = TRUE;
         if (gi_488 == 1) gi_496 = TRUE;
      }
      for (int li_40 = 0; li_40 < 100; li_40++) {
         ls_44 = as_0 + fCon4Strings("_", Symbol(), "_TRADE_", li_40);
         ObjectDelete(ls_44);
      }
   }
   g_TotalMaxFloatingPL = GlobalVariableGet(gs_MAXDD);
   if (ld_24 < g_TotalMaxFloatingPL) {
      g_TotalMaxFloatingPL = ld_24;
      GlobalVariableSet(gs_MAXDD, g_TotalMaxFloatingPL);
      //fPrint("Max Floating DD: $", DoubleToStr(g_TotalMaxFloatingPL, 2));
   }
   f0_0(as_0);
   return (0);
}

void f0_0(string as_0) {
   if (IsTesting() && !IsVisualMode()) return;
   string ls_16;
   double ld_8 = f0_35(g_Magic);
   for (int li_32 = 0; li_32 < Seconds() % 40; li_32++) ls_16 = ls_16 + "|";
   string ls_24 = "RUNNING";
   if (stop_after_close) ls_24 = "RUNNING (stop after close)";
   if (on_hold) ls_24 = "RUNNING (on hold)";
   if (gi_548) ls_24 = "STOPPED";
   if (MarketInfo(Symbol(), MODE_TRADEALLOWED) == 0.0) ls_24 = "TRADE_NOT_ALLOWED";
   double ld_36 = f0_52(Symbol(), g_Magic);
   Comment("\n " + gs_580 + " " + "v1.51",
      "\n " + modver,
      "\n ======================",
      "\n ", ls_16,
      "\n ----------------------------------------------------",
      "\n Status: ", ls_24,
      "\n ----------------------------------------------------",
      "\n " + Symbol() + " Spread: ", DoubleToStr((Ask - Bid) / gd_392, 2),
      "\n " + Symbol() + " Step: ", DoubleToStr(gi_368, 2),
      "\n " + Symbol() + " Next BUY @ ", DoubleToStr(gd_516, Digits),
      "\n " + Symbol() + " Next Sell @ ", DoubleToStr(gd_524, Digits),
      "\n ----------------------------------------------------",
      "\n " + Symbol() + " Orders: BUY ", f0_57(Symbol(), OP_BUY, g_Magic), "  \\  SELL ", f0_57(Symbol(), OP_SELL, g_Magic),
      "\n " + Symbol() + " Orders Value: $", DoubleToStr(ld_36, 2),
      "\n " + Symbol() + " Closed Profit: $", DoubleToStr(fSymbolClosedProfit(Symbol(), g_Magic), 2),
      "\n ----------------------------------------------------",
      "\n TOTAL Orders: BUY ", f0_37(OP_BUY, g_Magic), "  \\  SELL ", f0_37(OP_SELL, g_Magic),
      "\n TOTAL Orders Value: $", DoubleToStr(ld_8, 2),
      "\n TOTAL Closed Profit: $", DoubleToStr(fTotalClosedProfit(g_Magic), 2),
      "\n TOTAL Max Floating DD: $", DoubleToStr(g_TotalMaxFloatingPL, 2),
      "\n ----------------------------------------------------",
      "\n Magic Number: ", g_Magic,
   "\n ----------------------------------------------------");
      if (TimeCurrent() - line_redraw_time >= 60 || gi_588) {
         gi_588 = FALSE;
         f0_5(gd_516);
         f0_16(gd_524);
         if (show_open_trades) f0_13(as_0, Symbol(), g_Magic);
         if (show_next_trades) {
            ObjectSet(gs_552, OBJPROP_PRICE1, gd_516);
            ObjectSet(gs_560, OBJPROP_PRICE1, gd_524);
                               }
         line_redraw_time = TimeCurrent();}
}

void f0_5(double ad_0)  { gd_516 = ad_0; }

void f0_16(double ad_0) { gd_524 = ad_0; }

string f0_38(string as_0, int ai_8) {
   if (StringLen(as_0) > 0) return (as_0 + "_" + ((ai_8 + 1)));
   return ("");
}

int f0_44(int &aia_0[], string as_4, int ai_12, int ai_16) {
   ArrayResize(aia_0, 100);
   ArrayInitialize(aia_0,0);
   int li_20 = 0;
   int li_24 = OrdersTotal();
   if (li_24 > 0) {
      for (int li_28 = 0; li_28 < li_24; li_28++) {
        if (!OrderSelect(li_28, SELECT_BY_POS, MODE_TRADES)) continue;
         if (OrderSymbol() == as_4 && OrderType() == ai_12 && OrderMagicNumber() == ai_16) {
            aia_0[li_20] = OrderTicket();
            li_20++;
         }
      }
   }
   ArrayResize(aia_0, li_20);
   return (li_20);
}

int f0_57(string as_0, int ai_8, int ai_12) {
   int li_16 = 0;
   int li_20 = OrdersTotal();
   if (li_20 > 0) {
      for (int li_24 = 0; li_24 < li_20; li_24++) {
         if (OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == as_0 && OrderType() == ai_8 && OrderMagicNumber() == ai_12) li_16++;
      }}
   }
   return (li_16);
}

int f0_13(string as_0, string as_8, int ai_16) {
   string ls_32;
   bool li_20 = FALSE;
   int li_24 = OrdersTotal();
   if (li_24 > 0) {
      for (int li_28 = 0; li_28 < li_24; li_28++) {
         OrderSelect(li_28, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == as_8 && OrderMagicNumber() == ai_16) {
            ls_32 = as_0 + fCon4Strings("_", Symbol(), "_TRADE_", li_28);
            if (ObjectFind(ls_32) == -1) {
               ObjectCreate(ls_32, OBJ_HLINE, 0, 0, 0);
               ObjectSet(ls_32, OBJPROP_COLOR, Yellow);
               ObjectSet(ls_32, OBJPROP_STYLE, STYLE_DASHDOT);
            }
            ObjectSet(ls_32, OBJPROP_PRICE1, OrderOpenPrice());
         }
      }
   }
   return (li_20);
}

int f0_37(int ai_0, int ai_4) {
   int li_8 = 0;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == ai_0 && OrderMagicNumber() == ai_4) li_8++;
      }
   }
   return (li_8);
}

int f0_25(string as_0, int ai_8) {
   int li_12 = -1;
   int li_16 = OrdersTotal();
   if (li_16 > 0) {
      for (int li_20 = 0; li_20 < li_16; li_20++) {
         OrderSelect(li_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == as_0 && OrderMagicNumber() == ai_8) li_12 = OrderType();
      }
   }
   return (li_12);
}

double f0_35(int ai_0) {
   double ld_4 = 0;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == ai_0) ld_4 = fPlus2(ld_4, OrderProfit(), OrderSwap(), OrderCommission());
      }
   }
   return (ld_4);
}

double f0_52(string as_0, int ai_8) {
   double ld_12 = 0;
   int li_20 = OrdersTotal();
   if (li_20 > 0) {
      for (int li_24 = 0; li_24 < li_20; li_24++) {
         OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == as_0 && OrderMagicNumber() == ai_8) ld_12 = fPlus2(ld_12, OrderProfit(), OrderSwap(), OrderCommission());
      }
      return (ld_12);
   }
   return (0.0);
}

int f0_55(int aia_0[], int aia_4[]) {
   int counter = 0;
   int SizeBuy = ArraySize(aia_0);
   int SizeSell = ArraySize(aia_4);
   for (int cycle = 0; cycle < MathMax(SizeBuy, SizeSell); cycle++) {
      if (cycle < SizeBuy && cycle < SizeSell && aia_0[cycle] != 0 && aia_4[cycle] != 0) {
         if (orderCloseByReliable(aia_0[cycle], aia_4[cycle], Yellow) == TRUE) counter += 2;
      } else {
         if (cycle < SizeBuy) {
            if (OrderSelect(aia_0[cycle], SELECT_BY_TICKET, MODE_TRADES)) {
              if (orderCloseReliable(OrderTicket(), OrderLots(), Bid, gd_380, Blue)) counter++;}     }
         if (cycle < SizeSell) {
            if (OrderSelect(aia_4[cycle], SELECT_BY_TICKET, MODE_TRADES)) {
               if (orderCloseReliable(OrderTicket(), OrderLots(), Ask, gd_380, Red)) counter++;}     }
      }
   if (!closeby_enabled) return(0);
   Sleep(100);
   }
   return (counter);
}

int f0_28(string as_0, int ai_8, int ai_12) { // Symbol, Type, Magic
   int li_16 = 0;
   if (OrdersTotal() > 0) {
      for (int li_20 = OrdersTotal(); li_20 >= 0; li_20--) {
         OrderSelect(li_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == as_0 && OrderType() == ai_8 && OrderMagicNumber() == ai_12) {
            if (OrderType() == OP_BUY) {
               if (orderCloseReliable(OrderTicket(), OrderLots(), Bid, gd_380, Blue)) li_16++;
            }
            if (OrderType() == OP_SELL) {
               if (orderCloseReliable(OrderTicket(), OrderLots(), Ask, gd_380, Red)) li_16++;
            }
         }
      Sleep(1000);
      }
   }
   return (li_16);
}

int fCloseCycle(string as_0, int ai_8, int ai_12) {
   //Print(UseSettings + " (" + Symbol() + " fCloseCycle)");
   int cnt = 0;
   for (int li_16 = FALSE; f0_57(Symbol(), ai_8, ai_12) > 0; li_16 = fPlus(li_16, f0_28(Symbol(), ai_8, ai_12))) {
      cnt++;
      RefreshRates();
      if (cnt > 100) break;}
   return (li_16);
}

int fCloseByCycle(string as_0, int ai_8) {
   //Print(UseSettings + " (" + Symbol() + " fClose_BY_Cycle)");
   int cnt = 0;
   for (int li_12 = FALSE; f0_44(gia_568, Symbol(), OP_BUY, ai_8) + f0_44(gia_572, Symbol(), OP_SELL, ai_8) > 0; li_12 = fPlus(li_12, f0_55(gia_568, gia_572))) {
      if (!closeby_enabled) return(0);
      cnt++;
      RefreshRates();
      if (cnt > 100) break;
      }
   return (li_12);
}

double fTotalClosedProfit(int magic) {
   static double ld_4 = 0;
   if (TimeCurrent() - line_redraw_time < 60 ) return (ld_4);
   int li_12 = OrdersHistoryTotal();
   if (li_12 > 0) {
      ld_4 = 0;
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_HISTORY);
         if (OrderMagicNumber() == magic) ld_4 = fPlus2(ld_4, OrderProfit(), OrderSwap(), OrderCommission());
      }
      return (ld_4);
   }
   return (0.0);
}

double fSymbolClosedProfit(string as_0, int ai_8) {
   static double ld_12 = 0;
   if (TimeCurrent() - line_redraw_time < 60 ) return (ld_12);
   int li_20 = OrdersHistoryTotal();
   if (li_20 > 0) {
      ld_12 = 0;
      for (int li_24 = 0; li_24 < li_20; li_24++) {
         OrderSelect(li_24, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == as_0 && OrderMagicNumber() == ai_8) ld_12 = fPlus2(ld_12, OrderProfit(), OrderSwap(), OrderCommission());
      }
      return (ld_12);
   }
   return (0.0);
}

double f0_3(int ai_0) {
   double ld_4 = 0;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY || OrderType() == OP_BUYSTOP && OrderMagicNumber() == ai_0)
            if (OrderOpenPrice() > ld_4) ld_4 = OrderOpenPrice();
      }
      return (ld_4);
   }
   return (0.0);
}

double f0_43(int ai_0) {
   double ld_4 = 999999999;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL || OrderType() == OP_SELLSTOP && OrderMagicNumber() == ai_0)
            if (OrderOpenPrice() < ld_4) ld_4 = OrderOpenPrice();
      }
      return (ld_4);
   }
   return (0.0);
}

double f0_58(int ai_0) {
   double ld_4 = 999999999;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY || OrderType() == OP_BUYSTOP && OrderMagicNumber() == ai_0)
            if (OrderOpenPrice() < ld_4) ld_4 = OrderOpenPrice();
      }
      return (ld_4);
   }
   return (0.0);
}

double f0_1(int ai_0) {
   double ld_4 = 0;
   int li_12 = OrdersTotal();
   if (li_12 > 0) {
      for (int li_16 = 0; li_16 < li_12; li_16++) {
         OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL || OrderType() == OP_SELLSTOP && OrderMagicNumber() == ai_0)
            if (OrderOpenPrice() > ld_4) ld_4 = OrderOpenPrice();
      }
      return (ld_4);
   }
   return (0.0);
}

double fPlus(double ad_0, double ad_8) {return (ad_0 + ad_8);}
double fPlus1(double ad_0, double ad_8, double ad_16) {return (ad_0 + ad_8 + ad_16);}
double fPlus2(double ad_0, double ad_8, double ad_16, double ad_24) {return (ad_0 + ad_8 + ad_16 + ad_24);}
double fMinus(double ad_0, double ad_8) {return (ad_0 - ad_8);}
double fMultiply(double ad_0, double ad_8) {return (ad_0 * ad_8);}
double fMultiply2(double ad_0, double ad_8, double ad_16) {return (ad_0 * ad_8 * ad_16);}
double fDivide(double ad_0, double ad_8) {return (ad_0 / ad_8);}
string fCon2Strings(string as_0, string as_8) {return (as_0 + as_8);}
string fCon4Strings(string as_0, string as_8, string as_16, string as_24) {return (as_0 + as_8 + as_16 + as_24);}
void fAlert(string msg) { Alert(msg); }
void fPrint(string msg) { Print(msg); }

string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error"; break;
      case 2:   error_string="common error"; break;
      case 3:   error_string="invalid trade parameters"; break;
      case 4:   error_string="trade server is busy"; break;
      case 5:   error_string="old version of the client terminal"; break;
      case 6:   error_string="no connection with trade server"; break;
      case 7:   error_string="not enough rights"; break;
      case 8:   error_string="too frequent requests"; break;
      case 9:   error_string="malfunctional trade operation (never returned error)"; break;
      case 64:  error_string="account disabled"; break;
      case 65:  error_string="invalid account"; break;
      case 128: error_string="trade timeout"; break;
      case 129: error_string="invalid price"; break;
      case 130: error_string="invalid stops"; break;
      case 131: error_string="invalid trade volume"; break;
      case 132: error_string="market is closed"; break;
      case 133: error_string="trade is disabled"; break;
      case 134: error_string="not enough money"; break;
      case 135: error_string="price changed"; break;
      case 136: error_string="off quotes"; break;
      case 137: error_string="broker is busy (never returned error)"; break;
      case 138: error_string="requote"; break;
      case 139: error_string="order is locked"; break;
      case 140: error_string="long positions only allowed"; break;
      case 141: error_string="too many requests"; break;
      case 145: error_string="modification denied because order too close to market"; break;
      case 146: error_string="trade context is busy"; break;
      case 147: error_string="expirations are denied by broker"; break;
      case 148: error_string="amount of open and pending orders has reached the limit"; break;
      case 149: error_string="hedging is prohibited"; break;
      case 150: error_string="prohibited by FIFO rules"; break;
      //---- mql4 errors
      case 4000: error_string="no error (never generated code)"; break;
      case 4001: error_string="wrong function pointer"; break;
      case 4002: error_string="array index is out of range"; break;
      case 4003: error_string="no memory for function call stack"; break;
      case 4004: error_string="recursive stack overflow"; break;
      case 4005: error_string="not enough stack for parameter"; break;
      case 4006: error_string="no memory for parameter string"; break;
      case 4007: error_string="no memory for temp string"; break;
      case 4008: error_string="not initialized string"; break;
      case 4009: error_string="not initialized string in array"; break;
      case 4010: error_string="no memory for array\' string"; break;
      case 4011: error_string="too long string"; break;
      case 4012: error_string="remainder from zero divide"; break;
      case 4013: error_string="zero divide"; break;
      case 4014: error_string="unknown command"; break;
      case 4015: error_string="wrong jump (never generated error)"; break;
      case 4016: error_string="not initialized array"; break;
      case 4017: error_string="dll calls are not allowed"; break;
      case 4018: error_string="cannot load library"; break;
      case 4019: error_string="cannot call function"; break;
      case 4020: error_string="expert function calls are not allowed"; break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)"; break;
      case 4050: error_string="invalid function parameters count"; break;
      case 4051: error_string="invalid function parameter value"; break;
      case 4052: error_string="string function internal error"; break;
      case 4053: error_string="some array error"; break;
      case 4054: error_string="incorrect series array using"; break;
      case 4055: error_string="custom indicator error"; break;
      case 4056: error_string="arrays are incompatible"; break;
      case 4057: error_string="global variables processing error"; break;
      case 4058: error_string="global variable not found"; break;
      case 4059: error_string="function is not allowed in testing mode"; break;
      case 4060: error_string="function is not confirmed"; break;
      case 4061: error_string="send mail error"; break;
      case 4062: error_string="string parameter expected"; break;
      case 4063: error_string="integer parameter expected"; break;
      case 4064: error_string="double parameter expected"; break;
      case 4065: error_string="array as parameter expected"; break;
      case 4066: error_string="requested history data in update state"; break;
      case 4099: error_string="end of file"; break;
      case 4100: error_string="some file error"; break;
      case 4101: error_string="wrong file name"; break;
      case 4102: error_string="too many opened files"; break;
      case 4103: error_string="cannot open file"; break;
      case 4104: error_string="incompatible access to a file"; break;
      case 4105: error_string="no order selected"; break;
      case 4106: error_string="unknown symbol"; break;
      case 4107: error_string="invalid price parameter for trade function"; break;
      case 4108: error_string="invalid ticket"; break;
      case 4109: error_string="trade is not allowed in the expert properties"; break;
      case 4110: error_string="longs are not allowed in the expert properties"; break;
      case 4111: error_string="shorts are not allowed in the expert properties"; break;
      case 4200: error_string="object is already exist"; break;
      case 4201: error_string="unknown object property"; break;
      case 4202: error_string="object is not exist"; break;
      case 4203: error_string="unknown object type"; break;
      case 4204: error_string="no object name"; break;
      case 4205: error_string="object coordinates error"; break;
      case 4206: error_string="no specified subwindow"; break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
}//*/