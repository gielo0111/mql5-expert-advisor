//+------------------------------------------------------------------+
//|                                                     project2.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double movingAverage;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("start");
   Alert("checkSMA: " + checkSMA());
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

/*check last 3 candlesticks BEHIND CURRENT CANDLESTICK if valid SMA*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL -> SIDEWAYS*/ 
/* 1 => BUY*/
/* 2 => SELL*/
int checkSMA()
{
   movingAverage = iMA(NULL,0,20,1,MODE_SMA, PRICE_CLOSE, 0);
   movingAverage = NormalizeDouble(movingAverage,5 );

   if(movingAverage < Low[1])
      {
         movingAverage = iMA(NULL,0,20,2,MODE_SMA, PRICE_CLOSE, 0);
         movingAverage = NormalizeDouble(movingAverage,5 );
         if(movingAverage < Low[2])
         {
            movingAverage = iMA(NULL,0,20,3,MODE_SMA, PRICE_CLOSE, 0);
            movingAverage = NormalizeDouble(movingAverage,5 );
            if(movingAverage < Low[3])
            {
               return 1;
            }
         }
         
      } else if(movingAverage > High[1])
      {
         movingAverage = iMA(NULL,0,20,2,MODE_SMA, PRICE_CLOSE, 0);
         movingAverage = NormalizeDouble(movingAverage,5 );
         if(movingAverage > High[2])
         {
            movingAverage = iMA(NULL,0,20,3,MODE_SMA, PRICE_CLOSE, 0);
            movingAverage = NormalizeDouble(movingAverage,5 );
            if(movingAverage > High[3])
            {
               return 2;
            }
         }
         
      }
      return 0;
}

/*check if previous 2 candlesticks is PSH or PSL*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
/* 1 => BUY*/
/* 2 => SELL*/
int checkPSLvsPSH()
{
   double prevHigh1 = High[1];
   double prevHigh2 = High[2];
   double prevLow1 = Low[1];
   double prevLow2 = Low[2];
   
   /*CHECK IF PSL*/
   if(prevHigh2 > prevHigh1 &&
      prevLow2 > prevLow1)
   {
      return 1;
   
   /*CHECK IF PSH*/
   }else if(prevHigh2 < prevHigh1 &&
            prevLow2 < prevLow1)
   {
      return 2;
   }
   
   return 0;
}

/*check if previous candlestick is HAMMER OR SHOOTING STAR*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
/* 1 => BUY*/
/* 2 => SELL*/
int checkHammerOrStar()
{
   double previousLow = Low[1];
   //previousLow = NormalizeDouble(previousLow,5 );
   
   double previousHigh = High[1];
   //previousHigh = NormalizeDouble(previousHigh,5 );
   
   double previousOpen = Open[1];
   //previousOpen = NormalizeDouble(previousOpen,5 );
   
   double previousClose = Close[1];
   //previousClose = NormalizeDouble(previousClose,5 );
   
   double wickLength = previousHigh - previousLow;
   //wickLength = NormalizeDouble(wickLength,5 );
   
   wickLength = wickLength / 3;
   //wickLength = NormalizeDouble(wickLength,5 );
   
   double thresholdValue;
   
   /*check if hammer*/
   thresholdValue = previousHigh - wickLength;
   if(previousOpen >= thresholdValue &&
      previousClose >= thresholdValue)
   {
      return 1;
   }
   
   /*check if shooting star*/
   thresholdValue = previousLow + wickLength;
   if(previousOpen <= thresholdValue &&
      previousClose <= thresholdValue)
   {
      return 2;
   }
   
   return 0;
}