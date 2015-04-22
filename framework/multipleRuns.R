#parameter optimization
RunIterativeStrategy <- function(mktdata, a_period, b_period){
  #runs the trading strategy a number of times, iterating over a given set of input variables.
  firstRun <- TRUE
  for (a in 9:a_period){
    for (b in 20:b_period){
      
      runResult <- TradingStrategy(mktdata, a, b)
      
      if(firstRun){
        firstRun <- FALSE
        results <- runResult
      } else {
        results <- cbind(results, runResult)
      }
    }
  }
  
  return(results)
}