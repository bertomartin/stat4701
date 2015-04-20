optimizeSMA=function(mainVector,returnsVector,smaInit=3,smaEnd=200,long=TRUE){
  
  bestSMA=0
  bestSharpe=0
  
  for( i in smaInit:smaEnd){
    smaVec=SMA(mainVector,i)
    if(long==T){
      
      binVec=lag(ifelse(mainVector>smaVec,1,0),1)
      binVec[is.na(binVec)]=0
      stratRets=binVec*returnsVector #vector of +ve and -ve numbers. (+ve when you longed)
      sharpe=SharpeRatio.annualized(stratRets, scale=252)
      annRetx = Return.annualized(stratRets, scale=252)
      
      #optimize for sharpe ratio
      if(sharpe>bestSharpe){
        bestSMA=i
        bestSharpe=sharpe
      }
      
      #optimize for annualized return
      if (annRetx > bestAnnRet){
        bestSMA = i
        bestAnnualizedRx = annRetx
      }
      
    }else{
      
      binVec=lag(ifelse(mainVector<smaVec,-1,0),1)
      binVec[is.na(binVec)]=0
      stratRets=binVec*returnsVector #vector of +ve and -ve numbers. (+ve when you shorted.)
      sharpe=SharpeRatio.annualized(stratRets, scale=252)
      annRetx = Return.annualized(x, scale=252)
      if(sharpe>bestSharpe){
        bestSMA=i
        bestSharpe=sharpe
      }
    }
  }
  
  print(cbind(bestSMA, bestSharpe))
}