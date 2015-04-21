#each trading strategy should be a function. It takes market data and relevant parameters.
# it calculates: 1. market returns. 2.signal. 3.trading returns. It returns the trading returns.
TradingStrategy <- function(mktdata, mavga_period, mavgb_period){
  # Define a trading strategy
  # Rules: check moving averages at start of day and use as direction signal. Enter trade at start of day, exit at close.
  
  runName <- paste("MAVGa", mavga_period, ".b", mavgb_period, sep="")
  print(paste("Running Strategy: ", runName))
  
  #calculate the open/close return
  returns <- (Cl(mktdata)/Op(mktdata)) - 1
  
  #calculate the moving averages
  mavga <- SMA(Op(mktdata), n=mavga_period)
  mavgb <- SMA(Op(mktdata), n=mavgb_period)
  
  signal <- mavga / mavgb
  
  #if mavga > mavgb, long
  signal <- apply(
    signal,
    1,
    function(x){
      if(is.na(x)){return (0)}
      else { 
        if (x > 1) {return (1)}
        else { return (-1)}
      }
    }
  )
  
  tradingReturns <- signal * returns
  colnames(tradingReturns) <- runName
  
  return(tradingReturns)
} #end TradingStrategy Function