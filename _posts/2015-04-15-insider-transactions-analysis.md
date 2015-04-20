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

There are of course many aspects to each insider's transaction that make analysis more complex than simply "buy=good, sell=bad". Most share acquisitions by corporate insiders are under the aegis of stock options or similar compensation schemes, limiting how much of their own proverbial skin has been put into the game. Furthermore, since a large amount of an officer's compensation is often stock-based, a decision to sell is not necessarily indicative of negative outlook. Portfolio diversification, and personal cash liquidity needs now and in the near term future (e.g. impending high-dollar amount purchase such as a house, or retirement/tax/estate planning) are among the plausible reasons why an insider would sell their shares without negative sentiment on the company's future prospects. Our analysis of insider trading as the basis for a trading strategy therefore attempts to differentiate between good, bad, and neutral insider transactions, and use those as signals in a trading strategy.

#Source Data
All reported insider trading activity is available on the SEC website in XBRL (eXtensible Business Reporting Language) - the XML-based standard for financial reporting. Lists of desired filings and their respective URLs can be obtained as RSS feeds from the SEC website, and the XBRL data can be parsed and loaded into R using the XBRL and/or XML packages. In addition, there is a wide array of third party websites that also aggregate this publicly available data, which can be obtained via screen-scrape and/or direct download. 

The relevant data we we wish to analyze are found in SEC Form 3 (the initial filing one must make upon becoming a corporate insider), Form 4 (filed by an insider within 2 business days of a transection) and Form 5 (effectively Form 4 information, when the transaction was not reported within the mandates two days). The fields we shall extract from these forms are:
- Beneficial Owner (identity of each unique insider
- Type of insider (Officer, director, >10% owner)
- Price
- Transaction Date
- Transaction Code
    - buy/sell
    - open market / grant / option exercise
- # shares bought or sold in transaction
- Total shares owned post-transaction

The age of each insider (at a minimum the officers and directors) should be contained in the annual report data of any publicly traded company. This would be an additional external data point to bring in to gauge each individuals investing time-horizon and propensity to weight their portfolio towards cash.

#"Smart Money" Position Inference

Factors to weigh positively:
- open market purchase transactions at market price (highest positive rating)
- purchases made via exercise of options (the smaller the spread between the exercise price and market price, the higher the positive rating, with a larger spread skewing the score towards a neutral 0)
- long-term increase in net stock position 
- long average holding period of shares prior to selling (SEC rules state a 6 month holding period for insiders)

Factors to weigh negatively:
- sales, with potential to range from neutral to very negative
    - sales resulting in a net gain should be weighted towards neutral, with no penalty score if the gain is sufficiently large
    - sales resulting in a net loss to the insider should, all things being equal, result in a negative score, with a larger loss corresponding to a larger negative score
- long-term decrease in net stock position and/or short average holding period of shares prior to selling (SEC rules state a 6 month holding period for insiders)
    - this penalty would be weighted more or less based on the insider's age, the assumption being someone older would be more inclined to keep a larger share of their portfolio as cash


Potential Buy/Sell Signal:
- Each insider is given an aggregate score for their inferred outlook on the company stock, with 0 being a neutral outlook. A specified increase/decrease in the average weighted score among all insiders would be the buy/sell signal of the trading strategy. Potentially a company officer should be weighted more than directors, who themselves should be weighted more highly than >10% owners. The rationale being that the officers are in the "most inside" position of the insiders, while >10% owners that are not also officers or directors are less likely to have true inside information not available to the general public. Potentially we would only want to include officer transactions if inclusion of >10% owners and/or directors in the strategy does not yield improved backtesting results.
