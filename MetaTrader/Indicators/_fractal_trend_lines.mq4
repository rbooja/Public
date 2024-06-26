//+------------------------------------------------------------------+
//|                                               For MT4.mq4 article|
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
input color Resistance_Color=Red;
input ENUM_LINE_STYLE Resistance_Style;
input int Resistance_Width=1;
input color Support_Color=Red;
input ENUM_LINE_STYLE Support_Style;
input int Support_Width=1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"TL_Resistance");
   ObjectDelete(0,"TL_Support");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
//---declaration of variables
   int n,UpperFractal_1,UpperFractal_2,LowerFractal_1,LowerFractal_2;
//--- the first nearest upper fractal bar index
   for(n=0; n<(Bars-1);n++)
     {
      if(iFractals(NULL,1440,MODE_UPPER,n)!=NULL)
         break;
      UpperFractal_1=n+1;
     }
//--- the second nearest upper fractal bar index
   for(n=UpperFractal_1+1; n<(Bars-1);n++)
     {
      if(iFractals(NULL,1440,MODE_UPPER,n)!=NULL)
         break;
      UpperFractal_2=n+1;
     }
//--- the first nearest lower fractal bar index
   for(n=0; n<(Bars-1);n++)
     {
      if(iFractals(NULL,1440,MODE_LOWER,n)!=NULL)
         break;
      LowerFractal_1=n+1;
     }
//--- the second nearest lower fractal bar index
   for(n=LowerFractal_1+1; n<(Bars-1);n++)
     {
      if(iFractals(NULL,1440,MODE_LOWER,n)!=NULL)
         break;
      LowerFractal_2=n+1;
     }

//--- Step 1. Determining extremum time value on a higher timeframe:
//--- determining fractal time
   datetime UpFractalTime_1=iTime(NULL, 1440,UpperFractal_1);
   datetime UpFractalTime_2=iTime(NULL, 1440,UpperFractal_2);
   datetime LowFractalTime_1=iTime(NULL, 1440,LowerFractal_1);
   datetime LowFractalTime_2=iTime(NULL, 1440,LowerFractal_2);

//--- Step 2.  Finding the extremum bar index on a lower timeframe:
//--- finding fractal index on m15
   int UpperFractal_1_m15=iBarShift(NULL, 15, UpFractalTime_1,true);
   int UpperFractal_2_m15=iBarShift(NULL, 15, UpFractalTime_2,true);
   int LowerFractal_1_m15=iBarShift(NULL, 15, LowFractalTime_1,true);
   int LowerFractal_2_m15=iBarShift(NULL, 15, LowFractalTime_2,true);

//--- Step 3. Usage of arrays to find corrected extremums on M15:
//--- usage of arrays to find corrected extremums
//--- introduce variable i to use it in for loop statement
   int i;
//--- 1. First find lower extremums
//--- 3.1 Search for the first lower extremum
//--- declaration of an array to store values of bar indexes
   int Lower_1_m15[96];
//--- declaration of an array to store price values
   double LowerPrice_1_m15[96];
//--- start for loop:
   for(i=0;i<=95;i++)
     {
      //--- fill the array with data of bar indexes
      Lower_1_m15[i]=LowerFractal_1_m15-i;
      //--- fill the array with price data
      LowerPrice_1_m15[i]=iLow(NULL,15,LowerFractal_1_m15-i);
     }
//--- determining the minimum price value in the specified array
   int LowestPrice_1_m15=ArrayMinimum(LowerPrice_1_m15,WHOLE_ARRAY,0);
//--- determining a bar where the price is the lowest one within the specified array
   int LowestBar_1_m15=Lower_1_m15[LowestPrice_1_m15];
//--- determining time of a bar where the price is the lowest one
   datetime LowestBarTime_1_m15=iTime(NULL,15,Lower_1_m15[LowestPrice_1_m15]);

//--- 3.2 Search for the second lower extremum
   int Lower_2_m15[96];
   double LowerPrice_2_m15[96];
   for(i=0;i<=95;i++)
     {
      //--- fill the array with data of bar indexes
      Lower_2_m15[i]=LowerFractal_2_m15-i;
      //--- fill the array with price data
      LowerPrice_2_m15[i]=iLow(NULL,15,LowerFractal_2_m15-i);
     }
//--- determining the minimum price value in the specified array
   int LowestPrice_2_m15=ArrayMinimum(LowerPrice_2_m15,WHOLE_ARRAY,0);
//--- determining a bar where the price is the lowest one within the specified array
   int LowestBar_2_m15=Lower_2_m15[LowestPrice_2_m15];
//--- determining time of a bar where the price is the lowest one
   datetime LowestBarTime_2_m15=iTime(NULL,15,Lower_2_m15[LowestPrice_2_m15]);

//--- 3.3 Search for the first upper extremum
   int Upper_1_m15[96];
   double UpperPrice_1_m15[96];
   for(i=0;i<=95;i++)
     {
      //--- fill the array with data of bar indexes
      Upper_1_m15[i]=UpperFractal_1_m15-i;
      //--- fill the array with price data
      UpperPrice_1_m15[i]=iHigh(NULL,15,UpperFractal_1_m15-i);
     }
//--- determining the maximum price value in the specified array
   int HighestPrice_1_m15=ArrayMaximum(UpperPrice_1_m15,WHOLE_ARRAY,0);
//--- determining a bar where the price is the highest one within the specified array
   int HighestBar_1_m15=Upper_1_m15[HighestPrice_1_m15];
//--- determining time of a bar where the price is the highest one
   datetime HighestBarTime_1_m15=iTime(NULL,15,Upper_1_m15[HighestPrice_1_m15]);

//--- 3.4 Search for the second upper extremum
   int Upper_2_m15[96];
   double UpperPrice_2_m15[96];
   for(i=0;i<=95;i++)
     {
      //--- fill the array with data of bar indexes
      Upper_2_m15[i]=UpperFractal_2_m15-i;
      //--- fill the array with price data
      UpperPrice_2_m15[i]=iHigh(NULL,15,UpperFractal_2_m15-i);
     }
//--- determining the maximum price value in the specified array
   int HighestPrice_2_m15=ArrayMaximum(UpperPrice_2_m15,WHOLE_ARRAY,0);
//--- determining a bar where the price is the highest one within the specified array
   int HighestBar_2_m15=Upper_2_m15[HighestPrice_2_m15];
//--- determining time of a bar where the price is the highest one
   datetime HighestBarTime_2_m15=iTime(NULL,15,Upper_2_m15[HighestPrice_2_m15]);
//--- create support line
   ObjectCreate(0,"TL_Support",OBJ_TREND,0,LowestBarTime_2_m15,LowerPrice_2_m15[LowestPrice_2_m15],
                LowestBarTime_1_m15,LowerPrice_1_m15[LowestPrice_1_m15]);
   ObjectSet("TL_Support",OBJPROP_COLOR,Support_Color);
   ObjectSet("TL_Support",OBJPROP_STYLE,Support_Style);
   ObjectSet("TL_Support",OBJPROP_WIDTH,Support_Width);
//--- create resistance line
   ObjectCreate(0,"TL_Resistance",OBJ_TREND,0,HighestBarTime_2_m15,UpperPrice_2_m15[HighestPrice_2_m15],
                HighestBarTime_1_m15,UpperPrice_1_m15[HighestPrice_1_m15]);
   ObjectSet("TL_Resistance",OBJPROP_COLOR,Resistance_Color);
   ObjectSet("TL_Resistance",OBJPROP_STYLE,Resistance_Style);
   ObjectSet("TL_Resistance",OBJPROP_WIDTH,Resistance_Width);
//--- redraw support line
//--- write values of support line time coordinates to variables
   datetime TL_TimeLow2=ObjectGet("TL_Support",OBJPROP_TIME2);
   datetime TL_TimeLow1=ObjectGet("TL_Support",OBJPROP_TIME1);
//---if line coordinates do not coincide with current coordinates
   if(TL_TimeLow2!=LowestBarTime_1_m15 && TL_TimeLow1!=LowestBarTime_2_m15)
     {
      //---remove the line
      ObjectDelete(0,"TL_Support");
     }
//--- redraw resistance line
//--- write values of resistance line time coordinates to variables
   datetime TL_TimeUp2=ObjectGet("TL_Resistance",OBJPROP_TIME2);
   datetime TL_TimeUp1=ObjectGet("TL_Resistance",OBJPROP_TIME1);
//--- if line coordinates do not coincide with current coordinates
   if(TL_TimeUp2!=HighestBarTime_1_m15 && TL_TimeUp1!=HighestBarTime_2_m15)
     {
      //--- remove the line
      ObjectDelete(0,"TL_Resistance");
     }
//--- control of bar load in history
//--- if M15 does not have even one bar
   if(UpperFractal_1_m15==-1 || UpperFractal_2_m15==-1
      || LowerFractal_1_m15==-1 || LowerFractal_2_m15==-1)
     {
      Alert("Not enough history for proper operation!");
     }

//--- getting trend line price parameters
//--- determining closing price of the bar with index 1
   double Price_Close_H4=iClose(NULL,240,1);
//--- determining bar time with index 1
   datetime Time_Close_H4=iTime(NULL,240,1);
//--- determining bar index on H4
   int Bar_Close_H4=iBarShift(NULL,240,Time_Close_H4);
//--- determining line price on H4
   double Price_Resistance_H4=ObjectGetValueByShift("TL_Resistance",Bar_Close_H4);
//--- determining line price on H4
   double Price_Support_H4=ObjectGetValueByShift("TL_Support",Bar_Close_H4);

//--- conditions for trend line breakthrough
//--- for support breakthrough
   bool breakdown=(Price_Close_H4<Price_Support_H4);
//--- for resistance breakthrough
   bool breakup=(Price_Close_H4>Price_Resistance_H4);

//--- sending push notification
   if(breakdown==true)
     {
      //--- send no more than once in every 4 hours
      int SleepMinutes=240;
      static int LastTime=0;
      if(TimeCurrent()>LastTime+SleepMinutes*60)
        {
         LastTime=TimeCurrent();
         SendNotification(Symbol()+"Support line breakthrough");
        }
     }
   if(breakup==true)
     {
      //--- send no more than once in every 4 hours
      SleepMinutes=240;
      LastTime=0;
      if(TimeCurrent()>LastTime+SleepMinutes*60)
        {
         LastTime=TimeCurrent();
         SendNotification(Symbol()+"Resistance line breakthrough");
        }
     }
     return (rates_total);
  }
//+------------------------------------------------------------------+

