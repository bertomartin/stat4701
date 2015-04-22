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

## Results
![Strategy Graph]({{site.baseurl}}/images/aapl_strategy1.png)
