---
layout: post
title: Technical Strategies & Analytical Framework
---

<div class="message">
  Below, we test some basic technical strategies using our developed back
  testing framework.
</div>

# Technical Analysis

Technical strategies are derived from technical analysis (TA). Tehnical
analysis usually comes down to using past price to predict the future price
actions of a stock. 

* One major benefit of using technical analysis is that it
  can be applied to securites of any type, whether that is currencies,
  commodities, futures, or equities. 
* The major drawback is that it is a lagging
  indicator, and you will usually be late to the party (but in many cases, you
  can still enjoy it).

There are a lot of technical analysis indicators. A list of them can be seen
here:
[wikipedia link](http://en.wikipedia.org/wiki/Technical_analysis#Charting_terms_and_indicators)

In coming up with your trading strategy, you may use one or more of the
technical analysis tools.

**Strategy 1**: _Buy APPL when it goes above 200dma, sell when it goes below_

![Strategy Graph]({{site.baseurl}}/images/aapl_sma200.png)

{% highlight r %}

#1-get data
getSymbols("AAPL") #getting data for the aapl
AAPL <- AAPL['2007-01-01::2013-06-19']

#2-Calculate the 200-Day SMAs:
smahi200=SMA(Hi(AAPL),200)
smaLo200=SMA(Lo(AAPL),200)

#3-Calculate the lagged trading signal vector:
signal=lag(ifelse(Cl(AAPL)>smaHi200,1,0)+ifelse(Cl(AAPL)<smaLo200,-1,0),1)

#clean up NAs
signal[is.na(signal)]=0

#calculate daily returns vector
buyAndHold=diff(log(Ad(AAPL))) #subtract yesterday from today
colnames(buyAndHold) <- "AAPL Buy & Hold"

#calculate strategy returns
strategyReturns=signal*buyAndHold
colnames(strategyReturns) <- "200dma Strategy"

#charts.PerformanceSummary(cbind(rets,stratRets))
charts.PerformanceSummary(strategyReturns, geometric=FALSE)

{% endhighlight %}

## Results/Performance
![Strategy Graph]({{site.baseurl}}/images/aapl_strategy1.png)

{% highlight r %}
SharpeRatio.annualized(combinedReturns3, scale=252)
                                AAPL.Buy...Hold X200dma.Strategy
Annualized Sharpe Ratio (Rf=0%)       0.5496045        0.5995742


Return.cumulative(combinedReturns3)
                  AAPL.Buy...Hold X200dma.Strategy
Cumulative Return        2.301742         2.361772
{% endhighlight %}

***

# Strategy 2: Introducing the framework & parameter optimization
Lets see whether we can improve our strategy.
![Strategy Graph]({{site.baseurl}}/images/aapl_sma50_200.png)

**Framework**
{% highlight r %}

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
trainingEndDate <- as.Date("2012-06-19")
outofSampleStartDate <- as.Date("2012-06-20")
outofSampleEndDate <- as.Date("2014-01-01")

#1. Get Data
trainingData = StrategyData("AAPL", trainingStartDate, trainingEndDate, outofSampleStartDate, outofSampleEndDate)$trainingData
testData <- StrategyData("AAPL", trainingStartDate, trainingEndDate, outofSampleStartDate, outofSampleEndDate)$testData

#index returns
indexReturns <- Delt(Cl(window(stockData$AAPL, start = outofSampleStartDate, end = outofSampleEndDate))) #calculate returns for out of sample
colnames(indexReturns) <- "AAPL Buy & Hold"

pTab <- FindOptimumStrategy(trainingData) #performance table of each strategy

#test: TODO select top strategy and test against benchmark
dev.new() #doesn't work in rstudio
#manually specify a strategy
outofSampleReturns <- TradingStrategy(testData, mavga_period=11, mavgb_period=24)
finalReturns <- cbind(outofSampleReturns, indexReturns)
charts.PerformanceSummary(finalReturns, main=paste(nameOfStrategy, "- Out of Sample"), geometric=FALSE)

{% endhighlight %}

_the files are in the repository here:_[framework](https://github.com/bertomartin/stat4701/tree/master/framework){:target="_blank"}

### Results/Performance

{% highlight r %}

[1] "Calculating Performance Metric:  colSums"
[1] "Calculating Performance Metric:  SharpeRatio.annualized"
[1] "Calculating Performance Metric:  maxDrawdown"
[1] "Calculating Performance Metric:  sd.annualized"
[1] "Performance Table"
                   Profit  SharpeRatio MaxDrawDown Standard Deviation
MAVGa9.b20  -8.580160e-02 -0.263464880   0.4247071          0.2154974
MAVGa9.b21  -1.239758e-02 -0.129562881   0.3509601          0.2154939
MAVGa9.b22   1.372839e-01  0.156942103   0.2651973          0.2151037
MAVGa9.b23   2.610891e-01  0.407980327   0.2242422          0.2149014
MAVGa9.b24   3.030262e-01  0.496106574   0.2133214          0.2148145
MAVGa9.b25   2.608954e-01  0.407900345   0.2267513          0.2147898
MAVGa9.b26   2.643678e-01  0.415232725   0.2234586          0.2147472
MAVGa9.b27   1.854916e-01  0.253573326   0.2315723          0.2148017
MAVGa9.b28   1.828007e-01  0.248343293   0.2180627          0.2147171

{% endhighlight %}

![Strategy Graph]({{site.baseurl}}/images/appl_multiple_averages.png)

***

![Strategy Graph]({{site.baseurl}}/images/aapl_outof_sample.png)


