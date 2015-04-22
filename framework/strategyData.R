StrategyData <- function(ticker, trainingStartDate, trainingEndDate, outofSampleStartDate, outofSampleEndDate){
  stock <- eval(parse(text = paste("stockData$", ticker, sep="")))
  trainingData <- window(stock, start = trainingStartDate, end = trainingEndDate )
  testData <- window(stock, start = outofSampleStartDate, end = outofSampleEndDate)
  
  return(list("trainingData" = trainingData, "testData" = testData))
}