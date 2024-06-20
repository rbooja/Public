//+------------------------------------------------------------------+
//|                                                 Telegram4MQL.mq5 |
//|                                                   steven england |
//|           mailto:                                                |
//|         homepage: telegram4mql.steven-england.de                 |
//+------------------------------------------------------------------+
#property copyright "steven england"
#property link "mailto:"
#property version "1.00"
//--- input parameters
// input int      testparam;

#import "Telegram4Mql.dll"
string TelegramSendTextAsync(string apiKey, string chatId, string chatText);
string TelegramSendText(string apiKey, string chatId, string chatText);
string TelegramSendScreenAsync(string apiKey, string chatId,
                               string caption = "");
string TelegramSendScreen(string apiKey, string chatId, string caption = "");
string TelegramGetUpdates(string apiKey, string validUsers,
                          bool confirmUpdates);
string TelegramSendPhoto(string apiKey, string chatId, string filePath,
                         string caption = "");
string TelegramSendPhotoAsync(string apiKey, string chatId, string filePath,
                              string caption = "");
string TelegramSendDocument(string apiKey, string chatId, string filePath,
                            string caption = "");
string TelegramSendDocumentAsync(string apiKey, string chatId, string filePath,
                                 string caption = "");
#import

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnInit() {
  string apiKey = "112...:...J8";
  string chatId = "141...";
  int i = 1;
  //---
  Print(TelegramSendTextAsync(apiKey, chatId, "test async text") +
        " async text");
  Print("async text sent");
  Sleep(2000);
  Print(TelegramSendScreenAsync(apiKey, chatId, "test async screen") +
        " async screen");
  Print("async screen sent");
  Sleep(2000);
  Print(TelegramSendPhotoAsync(apiKey, chatId, "F:\\Files\\GBPUSDH1.png",
                               "test async photo") +
        " async photo");
  Print("async photo sent");
  Sleep(2000);
  Print(TelegramSendDocumentAsync(apiKey, chatId, "F:\\Files\\log.txt",
                                  "test async doc") +
        " async doc");
  Print("async doc sent");
  Sleep(2000);
  Print(TelegramSendText(apiKey, chatId, "test text") + " text");
  Print("text sent");
  Print(TelegramSendScreen(apiKey, chatId, "test screen") + " screen");
  Print("screen sent");
   Print(TelegramSendPhoto(apiKey, chatId, ""F:\\Files\\GBPUSDH1.png", "test photo") + " photo");
   Print("photo sent");
   Print(TelegramSendDocument(apiKey, chatId, ""F:\\Files\\log.txt", "test doc") + " doc");
   Print("doc sent");
   Print(TelegramGetUpdates(apiKey, chatId, false));
   Print(TelegramGetUpdates(apiKey, chatId, true));
   Print(TelegramGetUpdates(apiKey, chatId, true));
}
//+------------------------------------------------------------------+