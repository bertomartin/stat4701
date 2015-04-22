library(quantmod)
library(PerformanceAnalytics)

#load my functions
if(!exists("StrategyData", mode="function")) source("strategyData.R") #get strategy data
if(!exists("TradingStrategy", mode="function")) source("TradingStrategy.R") #define strategy
if(!exists("RunIterativeStrategy", mode="function")) source("RunIterativeStrategy.R") #optimization code
if(!exists("CalculatePerformanceMetric", mode="function")) source("strategyMetrics.R") #calculate performance
if(!exists("PerformanceTable", mode="function")) source("strategyMetrics.R") #generate table of performance (1 row per strategy)
if(!exists("OrderPerformanceTable", mode="function")) source("strategyMetrics.R") #order performance (best at top)
if(!exists("SelectTopNStrategies", mode="function")) source("strategyMetrics.R") #select the best n performing strateies
if(!exists("FindOptimumStrategy", mode="function")) source("strategyMetrics.R") #plot top strategies against each other and print performance table


nameOfStrategy <- "AAPL Moving Average Strategy"

#specify dates
trainingStartDate <- as.Date("2007-01-01")
trainingEndDate <- as.Date("2013-06-19")
outofSampleStartDate <- as.Date("2013-06-20")

#1. Get Data
trainingData = StrategyData("AAPL", trainingStartDate, trainingEndDate, outofSampleStartDate)$trainingData
testData <- StrategyData("AAPL", trainingStartDate, trainingEndDate, outofSampleStartDate)$testData

#index returns
indexReturns <- Delt(Cl(window(stockData$GSPC, start = outofSampleStartDate))) #calculate returns for out of sample
colnames(indexReturns) <- "GSPC Buy & Hold"

pTab <- FindOptimumStrategy(trainingData) #performance table of each strategy

#test: TODO select top strategy and test against benchmark
dev.new() #doesn't work in rstudio
#manually specify a strategy
outofSampleReturns <- TradingStrategy(testData, mavga_period=2, mavgb_period=5)
finalReturns <- cbind(outofSampleReturns, indexReturns)
charts.PerformanceSummary(finalReturns, main=paste(nameOfStrategy, "- Out of Sample"), geometric=FALSE)
