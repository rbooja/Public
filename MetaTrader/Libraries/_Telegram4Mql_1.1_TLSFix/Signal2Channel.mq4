//+------------------------------------------------------------------+
//|                                               Signal2Channel.mq4 |
//|                                                   steven england |
//|                         https://Telegram4MQL.steven-england.info |
//+------------------------------------------------------------------+
#property copyright "steven england"
#property link "https://Telegram4MQL.steven-england.info"
#property version "1.00"

#import "_Telegram4Mql_x86_1.1_TLSFix.dll"
string TelegramSendTextAsync(string ApiKey, string ChatId, string ChatText);
string TelegramSendText(string ApiKey, string ChatId, string ChatText);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit() { sample(); }
void sample() // this entry point is only for testing
{
  // Your config parameters here
  // The api key of your telegram bot:
  string apikey = "<YOUR API KEY>";
  // The chat ID of your channel you want to post to:
  string chatid = "<YOUR CHAT ID>";

  /* Your incredible Expert Advisor logic here
     ...
     Some (not meaningful) example values:
  */
  int cmd = OP_SELL;            // operation
  double volume = 0.1;          // volume
  double price = 0.1;           // price
  int slippage = 1;             // slippage
  double stoploss = 0.1;        // stop loss
  double takeprofit = 0.1;      // take profit
  string comment = "a comment"; // comment
  int magic = 0;                // magic number
  datetime expiration = 0;      // pending order expiration
  color arrow_color = clrRed;   // color

  // Ready to send an order
  string text2send = "";
  int ordersend =
      OrderSend(Symbol(), cmd, volume, price, slippage, stoploss, takeprofit,
                comment, magic, expiration, arrow_color);

  if (ordersend < 0) {
    HandleSendError(
        GetLastError()); // implement this custom functon on your own.
    return;
  }

  // Describe your order for the others
  if (OrderSelect(ordersend, SELECT_BY_TICKET, MODE_TRADES) == true) {
    text2send = "MyIncredibleSignal\n" + "Symbol: " + Symbol() + "\n" +
                "Type: " + OrderType() + "\n" +
                "Open Time: " + OrderOpenTime() + "\n" +
                "Open Price: " + OrderOpenPrice() + "\n";
    //
  } else {
    HandleSelectError(
        GetLastError()); // implement this custom functon on your own.
    return;
  }

  // Send a text message to a channel either blocking or non blocking

  // Non blocking if Expert Advisor must immediatly return -> you cannot say if
  // the message was really sent
  TelegramSendTextAsync(apikey, chatid, text2send);
  // Blocking if your Expert Advisor must not immediatly return -> you can check
  // if sending was successful
  string telegramresult = TelegramSendText(apikey, chatid, text2send);
  if (telegramresult != "0") {
    HandleTelegramError(
        telegramresult); // implement this custom functon on your own.
  }
}