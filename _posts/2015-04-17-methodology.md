---
layout: post
title: Backtesting Implementation 
---

<div class="message">
  We implement backtesting using the general process described below.
</div>

### Process
---
The process of backtesting includes a number of stages. We list and explain
them below:

* **Data Retrieval & Munging**
  - This was done using the tools **xts** & **quantmod**. Stock market data are
    timeseries data and as such may pose peculiar challenges in analysis. Using
    quantmod eases the burden quite a bit. The data we get back using quantmod is
    wrapped as an xts object. XTS is a class that gives us additional tools for
    managing time series information. These include easy ways to _limit_,
    _select_, _filter_ and _join_ data by time periods.
    {% highlight r %}
    getSymbols("^GSPC") #getting data for the s&p 500
SPY <- GSPC['2007-01-01::2013-06-19'] #selecting period of xts obj
spReturns=Delt(Op(SPY),Cl(SPY)) #daily returns for the s&p
head(SPY) #what does it look like?
               GSPC.Open GSPC.High GSPC.Low GSPC.Close GSPC.Volume
  2007-01-03   1418.03   1429.42  1407.86    1416.60  3429160000
  2007-01-04   1416.60   1421.84  1408.43    1418.34  3004460000
  2007-01-05   1418.34   1418.34  1405.75    1409.71  2919400000


    {% endhighlight %}

* **Signal Definition**
  - This is the kernel of the strategy you implement. This is where we define
    the rules of our strategy: when to buy and sell.
{% highlight r %}
sig=lag(ifelse(Cl(SPY)>Op(SPY),1,0),1) #buy only if close > open
sig[is.na(sig)]=0 #cleanup
{% endhighlight %}

* **Evaluate Returns using our strategy (aka Backtest)**
  - We now use the historical OHLC data and our signal to test how our strategy
    performs over a period of time. Analyzing the performance of our strategy as
    compared to a benchmark is essential in deciding whether or not to select or
    reject a strategy.
{% highlight r %}
# calculate strategy returns
strategyReturns=spReturns*sig

#chart returns
charts.PerformanceSummary(strategyReturns)

#chart combined returns
combinedReturns=cbind(spReturns,strategyReturns)
charts.PerformanceSummary(combinedReturns)

#annualized sharpe ratio and standard deviation of s&p
SharpeRatio.annualized(strategyReturns, scale=252)
sd.annualized(strategyReturns, scale=252) 
{% endhighlight %}

* **Parameter Optimization**
  - For any strategy, each parameter may assume multiple values. For example,
    in building a stragegy that is based on moving averages, how do we decide
    what is the optimal length of the moving average; or, what version of the
    moving average should we use (EMA or SMA).This is where parameter optimization comes
    in. It is actually a simple idea: test a number of different values for a
    given parameter (in our case, that parameter is moving average length), and
    optimize it for a value you care about, such as the Sharpe Ratio.
