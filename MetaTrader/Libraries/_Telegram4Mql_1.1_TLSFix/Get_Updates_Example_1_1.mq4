//+------------------------------------------------------------------+
//|                                      get_updates_example_1_1.mq4 |
//|                                                   steven england |
//|                         https://Telegram4MQL.steven-england.info |
//+------------------------------------------------------------------+

#property copyright "steven england"
#property link "https://Telegram4MQL.steven-england.info"
#property version "1.00"

#import "_Telegram4Mql_x86_1.1_TLSFix.dll"
string TelegramGetUpdates(string apiKey, string validUsers,
                          bool confirmUpdates);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit() { Sample(); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sample() // this entry point is only for testing
{
  // Your config parameters here
  // The api key of your telegram bot:
  string apikey = "<YOUR API KEY>";
  // The chat ID that shall be able to remote control your Expert Advisor (can
  // be more than one, see the doc for more information).
  string chatid = "<YOUR CHAT ID>";

  /*

     Now let us assume that you queried Telegram with the following command:

        string sampleUpdateString = TelegramGetUpdates(apikey, chatid, true);

     What might have returned the following string with these meanings:

         0 = No error occured during update call
         4 = The number of messages received. MUST NOT be of the same count like
     the following commands, because only commands from valid users were
     received. command list: Texts separated by semicolon, each starting with
     slash followed by command and maybe further arguments. It is completely up
     to you to define commands and values/arguments, Telegram4MQL only passes
     these texts you sent from your phone to your Telegram Bot through to
     Metatrader. The only requirement is, that the command MUST start with a
     slash.
  */

  string sampleUpdateString =
      "0|4|/stopTrades arg1,arg2,arg3;/doTrade arg1,arg2";

  string sepFields = "|"; // A separator as a character
  ushort u_sepFields;     // The code of the separator character
  string fields[];        // An array to get strings
                          // Get the separator code
  u_sepFields = StringGetCharacter(sepFields, 0);

  // Split the string to substrings
  int j = StringSplit(sampleUpdateString, u_sepFields, fields);

  if (fields[0] != "0") {
    HandleError(fields[0]);
  }

  string sepCommands = ";";
  ushort u_sepCommands;
  string commands[];

  u_sepCommands = StringGetCharacter(sepCommands, 0);

  int k = StringSplit(fields[2], u_sepCommands, commands);

  PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d", k,
              sepCommands, u_sepCommands);

  // Now do something with the commands
  if (k > 0) {
    for (int i = 0; i < k; i++) {
      CommandRouter(commands[i]);
    }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommandRouter(string commandLine) {

  int commandEndPos = StringFind(commandLine, " ");

  string command = StringSubstr(commandLine, 0, commandEndPos);
  string argumentLine = StringSubstr(commandLine, commandEndPos + 1);

  string sep = ",";
  ushort u_sep;
  string arguments[];

  u_sep = StringGetCharacter(sep, 0);

  int k = StringSplit(argumentLine, u_sep, arguments);

  Print("Processing command ", command);

  if (command == "/stopTrades")
    StopAllTrades(arguments);
  if (command == "/doTrade")
    DoTrade(arguments);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StopAllTrades(string arguments[]) {
  // here you might implement a routine that stops all trades
  Print("Will now stop all trades with these arguments!");
  for (int i = 0; i < ArraySize(arguments); i++) {
    Print(arguments[i]);
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoTrade(string arguments[]) {
  // here you might implement a routine that executes a trade
  Print("Will now execute a trade with these arguments!");
  for (int i = 0; i < ArraySize(arguments); i++) {
    Print(arguments[i]);
  }
}
//+------------------------------------------------------------------+
void HandleError(string errorNumber) { Print("Handling an error ... "); }
//+------------------------------------------------------------------+