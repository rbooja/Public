//+------------------------------------------------------------------+
//|                                                   Crosshairs.mqh |
//|                                                      nicholishen |
//|                            http://www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "http://www.reddit.com/u/nicholishenFX"
#property strict

#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsBmpControls.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <Arrays\List.mqh>

#resource "cross-false.bmp"
#resource "cross-true.bmp"

#define  CROSS_MOVE_FIRST  0
#define  CROSS_MOVE_SECOND 1
#define  CROSS_LOCK_ALL    2

enum ENUM_CrosshairStyle
{   Crosshair_HV,            // Horizontal+Vertical
    Crosshair_H,             // Horizontal only
    Crosshair_V,             // Vertical only
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class CCrosshair : public CObject
{
protected:
   datetime          m_Time_1;   
   double            m_Price_1;
   CChartObjectHLine m_h_line_1;
   CChartObjectVLine m_v_line_1;   
   
   datetime          m_Time_2;
   double            m_Price_2;
   CChartObjectHLine m_h_line_2;
   CChartObjectVLine m_v_line_2;
   
   CChartObjectTrend m_trend;
   CChartObjectLabel m_label;  // 
   
   ENUM_CrosshairStyle m_crosshair_style;
   color             m_color;
   ENUM_LINE_STYLE   m_style;
   long              m_chart;
   int               m_mode;
   bool              m_object_in_background;
   bool              m_tooltips;
public:
                     CCrosshair( const long chart,
                                 const ENUM_CrosshairStyle crosshair_style,
                                 const color col=clrWhite,
                                 const ENUM_LINE_STYLE style=STYLE_SOLID,
                                 const bool object_in_background=false,
                                 const bool tooltips=true);
   void              Color(const color col){ m_color = col; }
   void              Mouse(datetime time,double price);
   void              DoubleClick();
protected:
   void              CreateFirst();
   void              CreateSecond();
   void              RemoveAll();
   void              UpdateConnector(datetime time1,double price1,datetime time2,double price2);
   void              CycleMode();
};
//+------------------------------------------------------------------+
CCrosshair::CCrosshair( const long chart,
                        const ENUM_CrosshairStyle crosshair_style,
                        const color col=clrWhite,
                        const ENUM_LINE_STYLE style=STYLE_SOLID,
                        const bool object_in_background=false,
                        const bool tooltips=true
                      ):m_crosshair_style(crosshair_style),
                        m_color(col),
                        m_chart(chart),
                        m_mode(-1),
                        m_style(style),
                        m_object_in_background(object_in_background),
                        m_tooltips(tooltips)
{
   DoubleClick();
}

void CCrosshair::UpdateConnector(datetime time1,double price1,datetime time2,double price2)
{
   bool bResult;
   
   m_trend.SetPoint(0, time1, price1);
   m_trend.SetPoint(1, time2, price2);
    
   int bar2shift = iBarShift(Symbol(),ChartPeriod(m_chart),time2);
   int bars      = iBarShift(Symbol(),ChartPeriod(m_chart),time1) - bar2shift;
   bars = MathAbs(bars);
   int points = int((price2-price1)/_Point); 
   int zoom = (int)ChartGetInteger(m_chart,CHART_SCALE);
   int multiplier=1;
   switch(zoom)
   {
      case 0: multiplier = 20; break;
      case 1: multiplier = 10; break;
      case 2: multiplier = 5;  break;
      case 3: multiplier = 3;  break;
      default: multiplier = 2; break;
   }
   datetime label_time = iTime(Symbol(),ChartPeriod(m_chart),bar2shift-multiplier);
   if(label_time <=0)
   {
      label_time = time2 + PeriodSeconds(ChartPeriod(m_chart))*multiplier;
   }
   bResult = m_label.SetPoint(0, label_time, price2);
   
   string des = StringFormat("%s: %i bars, %i points", DoubleToString(price2,_Digits), bars, points);
   m_label.Description(des);      
   if (m_tooltips) 
        m_trend.Tooltip(des);
   else m_trend.Tooltip("\n");
}


//+------------------------------------------------------------------+
void CCrosshair::DoubleClick(void)
{
   m_mode = m_mode + 1 > 2 ? CROSS_MOVE_FIRST : m_mode+1;
   if(m_mode == CROSS_MOVE_FIRST)
   {
      RemoveAll();
      CreateFirst();
   }
   if(m_mode == CROSS_MOVE_SECOND)
      CreateSecond();
   
}

//+------------------------------------------------------------------+
void CCrosshair::Mouse(datetime time,double price)
{
   datetime t1 = m_Time_1;
   double   p1 = m_Price_1;
   string tool_tip;
   
   if(time<=0 || price<=0)
   {
      time  = 0;
      price = 0;
      t1=0;
      p1=0;
   }
   if(m_mode==CROSS_MOVE_FIRST)
   {
      m_Time_1 = time;
      m_v_line_1.Time(0,m_Time_1);      
      m_Price_1 = price;
      m_h_line_1.Price(0,m_Price_1);
      if (m_tooltips)
           tool_tip = string(time)+"\r\n"+DoubleToString(m_Price_1,_Digits);
      else tool_tip = "\n";
      m_v_line_1.Tooltip(tool_tip);
      m_h_line_1.Tooltip(tool_tip);
   }
   else
   if(m_mode==CROSS_MOVE_SECOND)
   {
      m_Time_2 = time;
      m_v_line_2.Time(0,m_Time_2);
      m_Price_2 = price;
      m_h_line_2.Price(0,m_Price_2);
      if (m_tooltips)
           tool_tip = string(time)+"\r\n"+DoubleToString(m_Price_2,_Digits);
      else tool_tip = "\n";
      m_v_line_2.Tooltip(tool_tip);
      m_h_line_2.Tooltip(tool_tip);
      UpdateConnector(t1,p1,m_Time_2,m_Price_2);
   }
   
   ChartRedraw(m_chart);
}

void CCrosshair::RemoveAll(void)
{   
   m_h_line_1.Delete();
   m_v_line_1.Delete();
   m_h_line_2.Delete();
   m_v_line_2.Delete();
   m_label.Delete();
   m_trend.Delete();
}
//+------------------------------------------------------------------+
void CCrosshair::CreateFirst()
{
    MqlTick last_tick;
   
    m_Time_1 = TimeCurrent();
    if ((m_crosshair_style == Crosshair_HV) || (m_crosshair_style == Crosshair_V))
      {
          m_v_line_1.Create(m_chart,"VLINE"+string(GetTickCount()),0,m_Time_1);   
          m_v_line_1.Color(m_color);
          m_v_line_1.Style(m_style);
          m_v_line_1.Background(m_object_in_background);
          m_v_line_1.Z_Order(2);    
      }         
    SymbolInfoTick(_Symbol,last_tick);   
    m_Price_1 = last_tick.bid;
    if ((m_crosshair_style == Crosshair_HV) || (m_crosshair_style == Crosshair_H))
      {
          m_h_line_1.Create(m_chart,"HLINE"+string(GetTickCount()),0,m_Price_1);
          m_h_line_1.Color(m_color);   
          m_h_line_1.Style(m_style);
          m_h_line_1.Background(m_object_in_background);
          m_h_line_1.Z_Order(2);        
      }
}

void CCrosshair::CreateSecond()
{
   bool bResult;
   MqlTick last_tick;
   
   m_Time_2 = TimeCurrent();
   if ((m_crosshair_style == Crosshair_HV) || (m_crosshair_style == Crosshair_V))
     {
         m_v_line_2.Create(m_chart,"VLINE2"+string(GetTickCount()),0,m_Time_2);
         m_v_line_2.Color(m_color);
         m_v_line_2.Style(m_style);
         m_v_line_2.Background(m_object_in_background);
         m_v_line_2.Z_Order(2);
     }           
   SymbolInfoTick(_Symbol,last_tick);   
   m_Price_2 = last_tick.bid;
   if ((m_crosshair_style == Crosshair_HV) || (m_crosshair_style == Crosshair_H))
     {
         m_h_line_2.Create(m_chart,"HLINE2"+string(GetTickCount()),0,m_Price_2);
         m_h_line_2.Color(m_color);
         m_h_line_2.Style(m_style);
         m_h_line_2.Background(m_object_in_background);
         m_h_line_2.Z_Order(2);
     }
     
   m_trend.Create(m_chart,"Connector"+string(GetTickCount()),0,m_Time_1,m_Price_1,m_Time_2,m_Price_2);
   m_trend.Color(m_color);
   m_trend.RayRight(false);
   m_trend.Style(STYLE_DOT);
   
   bResult = m_label.Create(m_chart,"ConnectorLabel"+string(GetTickCount()),0,m_Time_2,m_Price_2);
   bResult = m_label.Anchor(ANCHOR_LEFT_UPPER);
   bResult = m_label.Color(m_color);
   bResult = m_label.FontSize(8);
}
