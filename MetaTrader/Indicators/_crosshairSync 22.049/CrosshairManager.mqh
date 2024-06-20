//+------------------------------------------------------------------+
//|                                             CrosshairManager.mqh |
//|                                                      nicholishen |
//|                            http://www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "http://www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property strict
#include "Crosshairs.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCrossManager : public CList
{
protected:
   ENUM_CrosshairStyle m_crosshair_style;
   color             m_color;
   ENUM_LINE_STYLE   m_style;
   bool              m_locked;
   CChartObjectBmpLabel    m_button;
   ENUM_BASE_CORNER  m_corner;
   int               m_MarginX;
   int               m_MarginY;
   int               m_clicks;
   string            m_hotkey;
   bool              m_all_charts;
   bool              m_object_in_background;
   bool              m_tooltips;
   bool              m_elapsed_time;
public:
                     CCrossManager( ENUM_CrosshairStyle crosshair_style,
                                    const color col,
                                    ENUM_BASE_CORNER corner,
                                    int MarginVertical,
                                    int MarginHorizontal,
                                    ENUM_LINE_STYLE style= STYLE_SOLID,
                                    string hotkey="t",
                                    bool all_charts=false,
                                    bool object_in_background=false,
                                    bool tooltips=true,                                    
                                    bool show_elapsed_time=true);
   void              Show(const bool mode);
   void              Mouse(const long lparam,const double dparam);
   void              DoubleClick();
   void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam);
   void OnTimer(){ EventKillTimer();m_clicks=0;}
protected:
};

CCrossManager::CCrossManager( ENUM_CrosshairStyle crosshair_style,
                              const color       col,
                              ENUM_BASE_CORNER  corner,
                              int               MarginVertical,
                              int               MarginHorizontal,
                              ENUM_LINE_STYLE   style = STYLE_SOLID,
                              string            hotkey="t",
                              bool              all_charts=false,
                              bool              object_in_background=false,
                              bool              tooltips=true,
                              bool              show_elapsed_time=true)
                                                :m_crosshair_style(crosshair_style),
                                                 m_color(col),
                                                 m_style(style),
                                                 m_locked(false),
                                                 m_corner(corner),
                                                 m_MarginX(MarginVertical),
                                                 m_MarginY(MarginHorizontal),
                                                 m_clicks(0),
                                                 m_hotkey(hotkey),
                                                 m_all_charts(all_charts),
                                                 m_object_in_background(object_in_background),
                                                 m_tooltips(tooltips),
                                                 m_elapsed_time(show_elapsed_time)
   {
   ObjectDelete(0,"__button_crosshair__");
  
   m_button.Create(0,"__button_crosshair__",0,0,0);
   m_button.BmpFileOff("::cross-false.bmp");
   m_button.BmpFileOn("::cross-true.bmp");
   m_button.Z_Order(50);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,true);
   switch(corner)
   {
      case CORNER_RIGHT_LOWER:
         m_button.Corner(CORNER_RIGHT_LOWER);
         m_button.SetInteger(OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
         break;
      case CORNER_LEFT_LOWER:
         m_button.Corner(CORNER_LEFT_LOWER);
         m_button.SetInteger(OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         break;
      case CORNER_RIGHT_UPPER:
         m_button.Corner(CORNER_RIGHT_UPPER);
         m_button.SetInteger(OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
         break;
      default:
         m_button.Corner(CORNER_LEFT_UPPER);
         m_button.SetInteger(OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
         break;
   }
   m_button.X_Distance(m_MarginX);
   m_button.Y_Distance(m_MarginY);
}

void CCrossManager::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
    string key = CharToString((char)TranslateKey(char(lparam)));
   //Print(id," ",lparam," ",dparam," ",sparam," ");
   //Print(CharToString((char)TranslateKey(char(lparam))));
   if(sparam=="__button_crosshair__" || (id==CHARTEVENT_KEYDOWN && key==m_hotkey))
   {
      if(key==m_hotkey)
         m_button.State(!m_button.State());
      if(m_button.State())
      {
         Show(true);
      }  
      else
      {  
         Show(false);
      }
   }
   if(id==CHARTEVENT_MOUSE_MOVE)
   {
      if(m_button.State() )
      {
         Mouse(lparam,dparam);
      }
   }
   if(id==CHARTEVENT_CLICK)
   {
      m_clicks++;
      if(m_button.State() && m_clicks >= 2)
      { 
         DoubleClick();
      }    
      EventSetMillisecondTimer(200);
   }
}
//+------------------------------------------------------------------+
void CCrossManager::DoubleClick(void)
{
   for(CCrosshair *cross = GetFirstNode(); cross != NULL; cross = cross.Next())
   {
      cross.DoubleClick();
   }
}
void CCrossManager::Show(const bool mode)
{
   if(mode)
   {
      for(long ch=ChartFirst();ch > 0;ch = ChartNext(ch))
      {
         if((ChartSymbol(ch)==Symbol()) || m_all_charts)
         {
            CCrosshair *cross = new CCrosshair(ch,m_crosshair_style,m_color,m_style,m_object_in_background,m_tooltips);
            this.Add(cross);
            ChartRedraw(ch);
         }
      }
   }
   else
   {
      Clear();
      for(long ch=ChartFirst();ch > 0;ch = ChartNext(ch))
         ChartRedraw(ch);  
   }
}
//+------------------------------------------------------------------+
void CCrossManager::Mouse(const long lparam,const double dparam)
{
   datetime time;
   double price;
   int sub=0;
   ChartXYToTimePrice(0,(int)lparam,(int)dparam,sub,time,price);
   for(CCrosshair *cross = GetFirstNode(); cross != NULL; cross = cross.Next())
   {
      cross.Mouse(time,price);
   }
}
