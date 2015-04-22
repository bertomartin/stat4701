# this will take a metric that we want to measure the performance for.
CalculatePerformanceMetric <- function(returns, metric) {
  #@input -> given some returns in a column, and selected metric
  #@output -> apply the metric to get the metricData
  
  print(paste("Calculating Performance Metric: ", metric))
  
  metricFunction <- match.fun(metric) #lookup function
  metricData <- as.matrix(metricFunction(returns)) #calculate data
  if(nrow(metricData) == 1){
    metricData <- t(metricData)
  }
  colnames(metricData) <- metric
  return(metricData)
}

#calculating different performance metrics
PerformanceTable <- function(returns){
  pMetric <- CalculatePerformanceMetric(returns, "colSums")
  pMetric <- cbind(pMetric, CalculatePerformanceMetric(returns, "SharpeRatio.annualized"))
  pMetric <- cbind(pMetric, CalculatePerformanceMetric(returns, "maxDrawdown"))
  pMetric <- cbind(pMetric, CalculatePerformanceMetric(returns, "sd.annualized"))
  colnames(pMetric) <- c("Profit", "SharpeRatio", "MaxDrawDown", "Standard Deviation")
  
  print("Performance Table")
  print(pMetric)
  return(pMetric)
}

#order by the performance metric of choice, such as SharpeRatio.annualized
OrderPerformanceTable <- function(performanceTable, metric){
  return (performanceTable[order(performanceTable[,metric], decreasing=TRUE),])
}

#select the best n strategies
SelectTopNStrategies <- function(returns, performanceTable, metric,n){
  #select top n strategies based on a particular metric, ordered
  pTab <- OrderPerformanceTable(performanceTable, metric)
  
  if (n > ncol(returns)){
    n <- ncol(returns)
  }
  
  strategyNames <- rownames(pTab)[1:n]
  topNMetrics <- returns[,strategyNames]
  return(topNMetrics)
}

#find best strategy
FindOptimumStrategy <- function(trainingData){
  trainingReturns <- RunIterativeStrategy(trainingData, 50, 200)
  pTab <- PerformanceTable(trainingReturns)
  topTrainingReturns <- SelectTopNStrategies(trainingReturns, pTab, "SharpeRatio", 3)
  charts.PerformanceSummary(topTrainingReturns, main=paste(nameOfStrategy, "- Training"), geometric=FALSE)
  return(pTab)
}