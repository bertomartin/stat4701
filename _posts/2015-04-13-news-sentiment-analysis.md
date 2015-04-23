### News Sentiments
### Overview
One of the strategies we wanted to test was a trading strategy that is purely based on news sentiments collected from one or more news sources such as Google Finance News or Yahoo Finance News. With the abundance of so much news and other data online updated every second, we decided to experiment with financial news about the selected stock to find signals that inform us whether it is time to buy, sell or hold the stock.

There are many media outlets on the internet, which produce so much information that it is not quite easy to collect, process and analyze all the news in time to make the trade and benefit from it. However, we decided to still look into this and see if by collecting sample news and chatter about a selected stock (AAPL for example), we can have a better understanding of where the company is and how the stock is performing. We also presumed that by using the publicly accessible data on internet and calculating and aggregating the sentiments, we would obtain a feature that can be used by an algorithm in training to predict whether to buy, sell or hold a stock.

### Data Collection, Processing and Modeling

Most of the data collection and processing was done in Python. The submodule in the repository named, [Market Sentimentalism](https://github.com/EHDEV/market_sentimentalism2) is a python application that uses the Flask web framework to process ETL requests and return json outputs to the client.

This was born out of a script that was wrote to pull news data from Yahoo. However, we ran into some difficulties getting the historical data that we wanted. In addition, we weren't sure exactly which api to use, what data source to collect the news from, and how to perform the sentiment calculation. Therefore, this app was created to handle predefined requests for data with some flexibility in that the user would make an http request with option of passing some parameters. 

###  Tools
In developing this strategy of understanding a stock's performance and recommending the action to take the next day, we used python with the [Flask](http://flask.pocoo.org/) framework for ETL and the [Jinja](http://jinja.pocoo.org/) template engine to render visualizations. In scraping news sites, we make great use of the [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/) and the [requests](http://docs.python-requests.org/en/latest/) library. Further, most of the sentiment analysis was done using the [AlchemyAPI](http://www.alchemyapi.com/) tool. 

### Code

