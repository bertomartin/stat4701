library(quantmod)
library(PerformanceAnalytics)

#load my functions
if(!exists("TradingStrategy", mode="function")) source("TradingStrategy.R") #strategy
if(!exists("RunIterativeStrategy", mode="function")) source("RunIterativeStrategy.R") #strategy
if(!exists("CalculatePerformanceMetric", mode="function")) source("strategyMetrics.R") #strategy
if(!exists("PerformanceTable", mode="function")) source("strategyMetrics.R") #strategy
if(!exists("OrderPerformanceTable", mode="function")) source("strategyMetrics.R") #strategy
if(!exists("SelectTopNStrategies", mode="function")) source("strategyMetrics.R") #strategy
if(!exists("FindOptimumStrategy", mode="function")) source("strategyMetrics.R") #strategy
if(!exists("StrategyData", mode="function")) source("strategyData.R") #strategy


nameOfStrategy <- "GSPC Moving Average Strategy"

#specify dates
trainingStartDate <- as.Date("2000-01-01")
trainingEndDate <- as.Date("2010-01-01")
outofSampleStartDate <- as.Date("2010-01-02")

#1. Get Data
trainingData = StrategyData("GSPC", trainingStartDate, trainingEndDate, outofSampleStartDate)$trainingData
testData <- StrategyData("GSPC", trainingStartDate, trainingEndDate, outofSampleStartDate)$testData

#index returns
indexReturns <- Delt(Cl(window(stockData$GSPC, start = outofSampleStartDate))) #calculate returns for out of sample
colnames(indexReturns) <- "GSPC Buy & Hold"

pTab <- FindOptimumStrategy(trainingData) #performance table of each strategy

#test: TODO select top strategy and test against benchmark
dev.new()
#manually specify a strategy
outofSampleReturns <- TradingStrategy(testData, mavga_period=9, mavgb_period=6)
finalReturns <- cbind(outofSampleReturns, indexReturns)
charts.PerformanceSummary(finalReturns, main=paste(nameOfStrategy, "- Out of Sample"), geometric=FALSE)
