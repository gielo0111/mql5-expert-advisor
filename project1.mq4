//+------------------------------------------------------------------+
//|                                                     project1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double movingAverage;
double currentPrice;
double lastPrice;

double aepPrice;
double atpPrice;
double aslPrice;

bool tradeEmpty = true;

int order;

double PIPS5 = 0.0005;
double PIPS25 = 0.0015;

double positionSize = 0.01;

int temptickCount = 0;

int OnInit()
  {
//---
   Alert("start");
   Alert("checkSMA: " + checkSMA());
   Alert("checkEMA: " + checkEMA());
   Alert("checkLastFractal: " + checkLastFractal(2));
   Alert("checkHammerOrStar: " + checkHammerOrStar());
   Alert("checkPSLvsPSH: " + checkPSLvsPSH()); 
   Alert("symbol" + Symbol());
   Alert("period" + Period());
   
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
/*
   if(tradeEmpty)
   {
      order = executeBuyTrade(PIPS5, PIPS25);
      tradeEmpty = false;
   }
      temptickCount ++;
   
      if(temptickCount > 20)
      {
         Alert(OrderClose
         (order, positionSize, NormalizeDouble(Bid, 5), 1000, clrBlack) + "123 Error: " + GetLastError());
         Alert("order: "+ order);
            Alert(OrderDelete(order, clrBlack)+ "1 Error: " + GetLastError());
      }
   */
   executeD1H4();
   closeTrades();
   
   
  }
//+------------------------------------------------------------------+


/**/
void closeTrades()
{
   if(!tradeEmpty)
   {
      if(Period() == 1440 && 
         Hour() == 23 && 
         Minute() >= 0 && Minute() <= 40)
      {
         closeDeleteOrder();
         tradeEmpty = true;
      
      }else if(Period() == 240)
      {
         if(Hour() == 7 || Hour() == 11 ||
            Hour() == 15 || Hour() == 19 ||
            Hour() == 23)
         {
            if(Minute() >=0 && Minute() <= 30)
            {
               closeDeleteOrder();
               tradeEmpty = true;
            }
         }
      }
   }
}

void closeDeleteOrder()
{
         Alert(
            OrderClose(
               order, 
               positionSize, 
               NormalizeDouble(Bid, 5), 
               1000, 
               clrBlack)
                + "OrderClose Error: " + GetLastError());
         Alert(
            OrderDelete(
               order, 
               clrBlack)
                + "OrderDelete Error: " + GetLastError());
}


/*check SMA, EMA, LASTFRACTAL, HAMMER/SHOOTINGSTAR, PSH/PSL*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
/* 1 => BUY*/
/* 2 => SELL*/

void executeD1H4(){

/*CHECK IF THERE IS ALREADY EXISTING TRADE*/
   if(tradeEmpty)
   {
   
   /*CHECK IF TIMEFRAME IS D1*/
   if(Period() == 1440 && 
      Hour() == 1 && 
      Minute() >= 30 && Minute() <= 33)
   {
      if(checkBuySellTrendD1H4() == 1)
      {
         order = executeBuyTrade(PIPS5, PIPS25);
         tradeEmpty = false;
      }
      else if(checkBuySellTrendD1H4() == 2)
      {
         order = executeSellTrade(PIPS5, PIPS25);
         tradeEmpty = false;
      }
      
            
      
      
   /*CHECK IF TIMEFRAME IS H4*/
   }else if(Period() == 240)
   {
      if(Hour() == 4 || Hour() == 8 ||
         Hour() == 12 || Hour() == 16 ||
         Hour() == 20)
      {
         if(Minute() >= 0 && Minute() <= 3)
         {
            if(checkBuySellTrendD1H4() == 1)
            {
               order = executeBuyTrade(PIPS5, PIPS25);
               tradeEmpty = false;
            }
            else if(checkBuySellTrendD1H4() == 2)
            {
               order = executeSellTrade(PIPS5, PIPS25);
               tradeEmpty = false;
            }
         }
      }      
   }
   
   }

}

int checkBuySellTrendD1H4()
{
            /*CHECK IF BUY TRENDS*/
            if(checkSMA() == 1 && 
               checkEMA() == 1 && 
               checkLastFractal(2) == 1)
            {
               if(checkHammerOrStar() == 1 || checkPSLvsPSH() == 1)
               {
                  if(checkHammerOrStar() != 2 && checkPSLvsPSH() != 2)
                  {
                     return 1;
                  }
                  
               }
               
            /*CHECK IF SELL TRENDS*/
            }else if(checkSMA() == 2 &&
                     checkEMA() == 2 &&
                     checkLastFractal(2) == 2)
            {
               if(checkHammerOrStar() == 2 || checkPSLvsPSH() == 2)
               {
                  if(checkHammerOrStar() != 1 && checkPSLvsPSH() != 1)
                  {
                     return 2;
                  }
                  
               }
            }
   return 0;
}

int executeSellTrade(double AEP_PIPS, double ATPASL_PIPS)
{

   currentPrice = Close[1];
   aepPrice = currentPrice - AEP_PIPS - (Ask - Bid);
   aepPrice = NormalizeDouble(aepPrice,5 );
   
   atpPrice = aepPrice - ATPASL_PIPS;
   atpPrice = NormalizeDouble(atpPrice,5 );
   
   aslPrice = aepPrice + ATPASL_PIPS;
   aslPrice = NormalizeDouble(aslPrice,5 );
   
   int newOrder = OrderSend(
                        Symbol(),                  //CURRENCY PAIR
                        OP_SELLSTOP,               //TYPE OF TRADE
                        positionSize,              //POSITION SIZE
                        aepPrice,                  //BUYING/SELLING PRICE
                        1000,                      //SLIPPAGE
                        aslPrice,                  //STOP LOSS
                        atpPrice,                  //TAKE PROFIT
                        "This is a sell test",     //COMMENT
                        100,                       //MAGIC NUMBER / IDENTIFIER OF TRADE
                        TimeCurrent() + 661,                         //PENDING ORDER EXPIRATION
                        clrPink);                  //COLOR
                        
   Alert("Order: " + newOrder + " Error: " + GetLastError());
   Alert("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS),
         " Time[0]=",TimeToStr(Time[0],TIME_SECONDS));
   return newOrder;
}

int executeBuyTrade(double AEP_PIPS, double ATPASL_PIPS)
{

   currentPrice = Close[1];
   aepPrice = currentPrice + AEP_PIPS + (Ask - Bid);
   aepPrice = NormalizeDouble(aepPrice,5 );
   
   atpPrice = aepPrice + ATPASL_PIPS;
   atpPrice = NormalizeDouble(atpPrice,5 );
   
   aslPrice = aepPrice - ATPASL_PIPS;
   aslPrice = NormalizeDouble(aslPrice,5 );
   
   int newOrder = OrderSend(
                        Symbol(),                  //CURRENCY PAIR
                        OP_BUYSTOP,               //TYPE OF TRADE
                        positionSize,              //POSITION SIZE
                        aepPrice,                  //BUYING/SELLING PRICE
                        1000,                      //SLIPPAGE
                        aslPrice,                  //STOP LOSS
                        atpPrice,                  //TAKE PROFIT
                        "This is a sell test",     //COMMENT
                        100,                       //MAGIC NUMBER / IDENTIFIER OF TRADE
                        TimeCurrent() + 661,                         //PENDING ORDER EXPIRATION
                        clrGreen);                  //COLOR
   
   Alert("Order: " + newOrder + " Error: " + GetLastError());
   Alert("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS),
         " Time[0]=",TimeToStr(Time[0],TIME_SECONDS));
   
   
   return newOrder;
}



/*check last 3 candlesticks BEHIND CURRENT CANDLESTICK if valid SMA*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
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

/*checking TREND*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
/* 1 => BUY*/
/* 2 => SELL*/
int checkEMA()
{
   double greenEMA1;
   double greenEMA2;
   double redEMA1;
   double redEMA2;
   double distance1;
   double distance2;
   
   greenEMA1 = iMA(NULL,0,10,1,MODE_EMA, PRICE_CLOSE, 0);
   greenEMA1 = NormalizeDouble(greenEMA1,5 );
   
   redEMA1 = iMA(NULL,0,20,1,MODE_EMA, PRICE_CLOSE, 0);
   redEMA1 = NormalizeDouble(redEMA1,5 );
   
   greenEMA2 = iMA(NULL,0,10,2,MODE_EMA, PRICE_CLOSE, 0);
   greenEMA2 = NormalizeDouble(greenEMA2,5 );
   
   redEMA2 = iMA(NULL,0,20,2,MODE_EMA, PRICE_CLOSE, 0);
   redEMA2 = NormalizeDouble(redEMA2,5 );
   
   /*BUY trend*/
   if(greenEMA1 > redEMA1)
   {
      if(greenEMA2 > redEMA2)
      {
         distance1 = greenEMA1 - redEMA1;
         
         distance2 = greenEMA2 - redEMA2;
         distance2 = distance2 * 1.1;
         
         if(distance2 >= distance1)
         {
            return 1;         
         }
      
      }else if(greenEMA2 == redEMA2)
      {
         return 1;
      }
      
   
   
   /*SELL TREND*/
   } else if(greenEMA1 < redEMA1)
   {
      if(greenEMA2 < redEMA2)
      {
         distance1 = redEMA1 - greenEMA1;
         
         distance2 = redEMA2 - greenEMA2;
         distance2 = distance2 * 1.1;
         
         if(distance2 >= distance1)
         {
            return 2;
         }
      
      } else if(greenEMA2 == redEMA2)
      {
         return 2;
      }
      
   
   /*WHEN GREEN AND RED ARE EQUAL*/
   }else
   {
      if(greenEMA2 > redEMA2)
      {
         return 2;
      }else if(greenEMA2 < redEMA2)
      {
         return 1;
      }
   } 
 
   return 0;
}


/*FIND LAST FRACTAL IF BUY OR SELL OR NOT*/
/* OUTPUT VALUE REPRESENTS*/
/* 0 => DONT BUY/SELL*/
/* 1 => BUY*/
/* 2 => SELL*/
int checkLastFractal(int fractalRange)
{
   /*fractalRange => distance based on last and next n candlesticks*/
   /*ex. 2 => last 2 and next 2 candlesticks*/
   /*IF NULL OR LESS THAN 1 => set to 2*/
   int newFractalRange;
   if(fractalRange == NULL || fractalRange < 1)
   {
      newFractalRange = 2;
   }else
   {
      newFractalRange = fractalRange;
   }
   
   int highIndex = fractalRange;
   int lowIndex = fractalRange;
   bool checkFractalFound = true;
   
   /*find last up fractal*/
   while(checkFractalFound)
   {
      for(int i=1;i<=newFractalRange;i++)
      {
         if(High[highIndex] > High[highIndex - i] && 
            High[highIndex] > High[highIndex + i])
         {
            checkFractalFound = false;
         }
         else
         {
            checkFractalFound = true;
            highIndex = highIndex + 1;
            break;
         }
      }
      /*
      if(
         High[highIndex] > High[highIndex - 1] &&
         High[highIndex] > High[highIndex - 2] &&
         High[highIndex] > High[highIndex + 1] &&
         High[highIndex] > High[highIndex + 2]
         )
      {
         checkFractalFound = false;
      
      } else
      {
         highIndex = highIndex + 1;
      }
      */
   }

   checkFractalFound = true;
   
   while(checkFractalFound)
   {
      for(int i=1;i<=newFractalRange;i++)
      {
         if(Low[lowIndex] < Low[lowIndex - i] && 
            Low[lowIndex] < Low[lowIndex + i])
         {
            checkFractalFound = false;
         }
         else
         {
            checkFractalFound = true;
            lowIndex = lowIndex + 1;
            break;
         }
      }
   
   /*
      if(
         Low[lowIndex] < Low[lowIndex - 1] &&
         Low[lowIndex] < Low[lowIndex - 2] &&
         Low[lowIndex] < Low[lowIndex + 1] &&
         Low[lowIndex] < Low[lowIndex + 2]
         )
      {
         checkFractalFound = false;
      
      } else
      {
         lowIndex = lowIndex + 1;
      }
      */
   }
   
   if(highIndex < lowIndex)
   {
      return 1;
   
   }else if(highIndex > lowIndex)
   {
      return 2;
   }
   else
   {
      return 0;
   }
   
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