StrategyData <- function(ticker, trainingStartDate, trainingEndDate, outofSampleStartDate){
  stock <- eval(parse(text = paste("stockData$", ticker, sep="")))
  trainingData <- window(stock, start = trainingStartDate, end = trainingEndDate )
  testData <- window(stock, start = outofSampleStartDate)
  
  return(list("trainingData" = trainingData, "testData" = testData))
}