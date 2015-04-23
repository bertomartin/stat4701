---
layout: post
title: Insider Transactions Analysis 
---

<div class="message">
  Below, we investigate whether insider transactions can be used to make
  predictions about future prices.
</div>

#Introduction to (Legal) Insider Trading
Corporate officers, directors, and beneficial owners of more than 10% of a company's registered stock are defined by the SEC as "insiders" and must report all of their purchases and sales of that stock to the SEC. Many believe that insiders have a more accurate handle on the future prospects of the companies they run and a more accurate notion of whether their company's current stock price accurately reflects these future prospects. It is therefore not uncommon to view insider purchases as a signal that the stock is currently undervalued and has high potential for near-term gain and vice-versa for insider sales.

There are of course many aspects to each insider's transaction that can make analysis more complex than simply "buy=good, sell=bad". Most share acquisitions by corporate insiders are under the aegis of stock options or similar compensation schemes, limiting how much of their own proverbial skin has been put into the game. Furthermore, since a large amount of an officer's compensation is often stock-based, a decision to sell is not necessarily indicative of negative outlook. Portfolio diversification, and personal cash liquidity needs now and in the near term future (e.g. impending high-dollar amount purchase such as a house, or retirement/tax/estate planning) are among the plausible reasons why an insider would sell their shares without negative sentiment on the company's future prospects. Our initial analysis of insider trading as the basis for a trading strategy will attempt to sidestep the complexities of differentiating between good, bad, and neutral insider transactions, and instead look at whether each insider is increasing or decreasing their net share position during rolling 6 month and 12 month periods.

#Source Data
All reported insider trading activity is available on the SEC website in XBRL (eXtensible Business Reporting Language) - the XML-based standard for financial reporting. Lists of desired filings and their respective URLs can be obtained as RSS feeds from the SEC website, and the XBRL data can be parsed and loaded into R using the XBRL and/or XML packages. 

The relevant data we we wish to analyze are found in SEC Form 4, filed by an insider within 2 business days of a transection. The fields we shall extract from these forms are:
- Beneficial Owner (identity of each unique insider
- Type of insider (Officer, director, >10% owner)
- Price
- Transaction Date
- Transaction Code
    - buy/sell
    - open market / grant / option exercise
- # shares bought or sold in transaction
- Total shares owned post-transaction

We will not be using all of these data points in our initial analysis, but will import them nevertheless to facilitate anyone's interest in using alternative means to infer whether an insider's transaction seems good, bad or neutral. An additional external data point that might be of interest in that endeavor might be the age of each officer and director (found in the company's annual report) in order to gauge their investing time-horizon and propensity to weight their portfolio towards cash.

[Linked here](https://github.com/bertomartin/stat4701/blob/master/import_insider_data.R) is the R markdown code used to pull the comprehensive list of all available Form 4 filings for Apple via an [RSS feed from the SEC's website](https://www.sec.gov/spotlight/xbrl/filings-and-feeds.shtml), import the [XBRL/XML formatted filings](http://xbrl.sec.gov) into our R workspace, and then parse and curate that data into vectors that will ultimately be bonded together in a data frame. The code uses the [RCurl](http://cran.r-project.org/web/packages/RCurl/index.html) package to retrieve and read the RSS feed of filings and the [XML package](http://cran.r-project.org/web/packages/XML/index.html) for parsing the filing data according to the [spec document for Form 4](https://www.sec.gov/info/edgar/ownershipxmltechspec.htm). The code is currently set to pull Apple's filings, but could be used to pull any listed company by changing the companyCIK variable value in line 6 to any other company's unique SEC-assigned code, found [here](http://www.sec.gov/edgar/searchedgar/cik.htm).

#"Smart Money" Position Inference: Calculating the "Insider Sentiment Score"

Rather than apply a series of assumptions to each purchase and sale transaction in an attempt to divine the rationale for the transaction, we will focus on one question: does each insider's net share position in the company increase or decrease during various time intervals? For each transaction made, we take the sum aggregate of the positive quantity bought or negative quantity sold with all other transaction quantities made by that insider during the subsequent 6 months and 12 months, and then assign that net quantity to the last day in that 6 or 12 month period. If the net quantity is positive, then the insider has increased their net holdings in the company over that time period, which we will infer as a vote of confidence for the company's outlook and score that as a 1. Conversely, a negative net quantity means they decreased their net holdings, which we will infer as a negative vote of confidence and score that as a -1. A perfectly balanced net quantity of zero or a total absence of buy or sell transactions will be classified as neutral and assigned a score of 0. We will repeat this process for every insider on every date within our insider trading data date range (omitting transactions that have happened less than 6 or 12 months ago) and take the average score across all insiders' scores. This will give us an average score between -1 (most negative outlook) and 1 (most positive outlook), with 0 being neutral.

#The Results: 
##Can a correlation be seen between daily Insider Sentiment scores and future price movement?

Below are the results of this analysis broken out by 6 and 12 month rolling periods. We have also broken out the results by Officers and Directors to see if either group's transactions seem more or less savvy with respect to predicting future stock price increases. The average daily Insider Sentiment scores are plotted together with Apple's indexed stock price over the time period January 1, 2013 through January 1, 2015. [Click here](https://github.com/bertomartin/stat4701/blob/master/insider_data_analysis.R) to view the R code that performed the calculations and generated these plots using ggplot2. (Similar to the initial script, it is currently set up for Apple, but can be run for other companies by modifying the ticker symbol in lines 7 and 8).

The red lines depict the share price movement of Apple, using 0 as the baseline index for the beginning of the time-series. Its y-axis values represent the percentage of price increase or decrease relative to the baseline price on the first day represented in the chart. This depiction facilitates a very "visually friendly" common y-axis scale relative to the daily Insider Sentiment scores, depicted by the blue lines. Once again, that score ranges between -1 (most negative outook) and 1 (most positive outlook) with 0 being considered neutral. Since its score is formulated on whether insiders, on-average, increased to decreased their share holdings during the preceding 6 or 12 month period prior to each of those days, we assess how prescient their collective decisions were based on whether the red line trends upwards after points in time when the blue line is above 0 and vice-versa.

![]({{site.baseurl}}/images/Insider6MoAll.png)
![]({{site.baseurl}}/images/Insider6MoOff.png)
![]({{site.baseurl}}/images/Insider6MoDirs.png)

The difference in purchasing behavior of Officers and Directors over a 6 month rolling time period is not sufficient to have substantially different Sentiment scores (I rechecked the code several times to make sure it was not erroneously sampling the same data each time). There does appear to be potential correlations between a rise in the Sentiment score based on a rolling 6 month period and a rise in the stock price. Let's see if a rolling 12 month period shows us a firmer sense of correlation...

![]({{site.baseurl}}/images/Insider1YrAll.png)
![]({{site.baseurl}}/images/Insider1YrOff.png)
![]({{site.baseurl}}/images/Insider1YrDir.png)

Interestingly enough with a rolling 12 month period, there is observable difference in the Sentiment score between Officers and Directors. Curiously, the Directors seem to have a better track record over 2013-2014 in picking up shares just prior to a rise in share price. Nevertheless, the correlation seems to be stronger across a 12 month rolling period, so this would be the best candidate for creating and backtesting a trading strategy and signal - i.e. buy whenever the Sentiment score rises above a certain threshold value and sell whenever it falls below a certain threshold value.
