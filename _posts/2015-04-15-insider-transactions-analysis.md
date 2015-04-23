---
layout: post
title: Insider Transactions Analysis 
---

<div class="message">
  Below, we investigate whether insider transactions can be used to make
  predictions about future prices.
</div>

#Intro
Corporate officers, directors, and beneficial owners of more than 10% of a company's registered stock are defined by the SEC as "insiders" and must report all of their purchases and sales of that stock to the SEC. Many believe that insiders have a more accurate handle on the future prospects of the companies they run and a more accurate notion of whether their company's current stock price accurately reflects these future prospects. It is therefore not uncommon to view insider purchases as a signal that the stock is currently undervalued and has high potential for near-term gain and vice-versa for insider sales.

There are of course many aspects to each insider's transaction that can make analysis more complex than simply "buy=good, sell=bad". Most share acquisitions by corporate insiders are under the aegis of stock options or similar compensation schemes, limiting how much of their own proverbial skin has been put into the game. Furthermore, since a large amount of an officer's compensation is often stock-based, a decision to sell is not necessarily indicative of negative outlook. Portfolio diversification, and personal cash liquidity needs now and in the near term future (e.g. impending high-dollar amount purchase such as a house, or retirement/tax/estate planning) are among the plausible reasons why an insider would sell their shares without negative sentiment on the company's future prospects. Our initial analysis of insider trading as the basis for a trading strategy will attempt to sidestep the complexities of differentiating between good, bad, and neutral insider transactions, and instead look at whether each insider is increasing or decreasing their net share position during rolling 6 month and 12 month periods.

#Source Data
All reported insider trading activity is available on the SEC website in XBRL (eXtensible Business Reporting Language) - the XML-based standard for financial reporting. Lists of desired filings and their respective URLs can be obtained as RSS feeds from the SEC website, and the XBRL data can be parsed and loaded into R using the XBRL and/or XML packages. In addition, there is a wide array of third party websites that also aggregate this publicly available data, which can be obtained via screen-scrape and/or direct download. 

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

[Linked here](https://github.com/bertomartin/stat4701/blob/master/import_insider_data.R) is the R markdown code used to pull a comprehensive list of all Form 4 filings for Apple via an RSS feed, import those XBRL/XML formatted filings via RCurl, and parse the data using R's XML package. The code could be adapted to pull any listed company's Form 4 filings by modifying the CIK value (a company's unique SEC assigned code).

We will not be using all of these data points in our initial analysis, but will import them nevertheless to facilitate anyone's interest in using alternative means to evaluate whether an insider's transaction seems good, bad or neutral. An additional external data point that might be of interest in that endeavor might be the age of each officer and director, in order to gauge their investing time-horizon and propensity to weight their portfolio towards cash.

#"Smart Money" Position Inference

Rather than apply a series of assumptions to each purchase and sale transaction in an attempt to divine the rationale for the transaction, we will focus on one question: does each insider's net share position in the company increase or decrease during various time intervals? For each transaction made, we sum the positive quantity bought or negative quantity sold with all other transaction quantities made by that insider during the subsequent 6 months and 12 months, and then assign that net quantity to the last day in that 6 or 12 month period. If the net quantity is positive, then the insider has increased their net holdings in the company over that time period, which we will infer as a vote of confidence for the company's outlook and score that as a 1. Conversely, a negative net quantity means they decreased their net holdings, which we will infer as a negative vote of confidence and score that as a -1. A perfectly balanced zero, or a total absence of buy or sell transactions, will be classified as neutral and assigned a score of 0. We will repeat this process for every insider on every date within our insider trading data date range (omitting transactions that have happened less than 6 or 12 months ago) and take the average score across all insiders' scores. This will give us an average score between -1 (most negative outlook) and 1 (most positive outlook), with 0 being neutral.

Following are the results of this analysis using a 6 month rolling period and a 12 month rolling period. We have also broken out the results by Officers and Directors to see if either group's transactions seem more or less savvy with respect to predicting future stock price increases. The average scores are plotted together with Apple's indexed stock price over the time period Jan 1, 2013 through Jan 1, 2015. [Click here](https://github.com/bertomartin/stat4701/blob/master/insider_data_analysis.R) to view the code that performs the calculations and generated these plots.

![](https://github.com/bertomartin/stat4701/blob/master/Insider6MoAll.png)
![](https://github.com/bertomartin/stat4701/blob/master/Insider6MoOff.png)
![](https://github.com/bertomartin/stat4701/blob/master/Insider6MoDirs.png)

![](https://github.com/bertomartin/stat4701/blob/master/Insider1YrAll.png)
![](https://github.com/bertomartin/stat4701/blob/master/Insider1YrOff.png)
![](https://github.com/bertomartin/stat4701/blob/master/Insider1YrDir.png)
