---
layout: post
title: Introducing QuantTradR
---

<div class="message">
  QuantTradr is a back testing framework for investigating trading strategies.
  We will test various trading strategies including strategies based on Technical
  Analysis indicators, Twitter sentiments and Insider transactions.
</div>

### What is a trading strategy?
Generally, a trading strategy is a set of rules that gives you an edge in
trading. It consists of:

>* **A trading idea** - this will be used to create the signal
* **Trading Rules** - This includes money management rules, position sizing rules,
  stop protection, profit protection and possibly others.

It is important to test your trading strategy before using it with real money.
This is where backtesting comes in.

### Backtesting

As the name suggests, backtesting is applying your trading strategy over
historical data and seeing how it performs versus a benchmark. A suitable
benchmark is an index like the S&P 500. In comparing your strategy against the
index, you need a well defined set of performance measures.

### Performance Measures

The following are the most used set of metrics for measuring performance:

1. **Sharpe Ratio**
   -This is the risk adjusted returns. Basically, how much risk are you taking
    for excess returns above the risk-free rate (Treasuries). This is the
    industry standard measure of performance. Higher is better.
     
  2. **Cummulative Returns**
    -Total returns at the end of the investing period.

  3. **Drawdowns (and max drawdowns)**
   -The peak-to-trough decline during a specific period of an investment.

### Parameter Optimization

After looking at how your strategy performed based on the performance measures,
the next step is to optimize the parameter for a specified metric (usually the
Sharpe Ratio). Parameter optimization involves changing the values of the
parameters you use to generate your signal, and choosing the parameters that
give you the best value of your selected metric.
