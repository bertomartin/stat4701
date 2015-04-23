---
layout: post
title: Sentiment Analysis
---

# News Sentiments

## Overview
One of the strategies we wanted to test was a trading strategy that is purely based on news sentiments collected from one or more news sources such as Google Finance News or Yahoo Finance News. With the abundance of so much news and other data online updated every second, we decided to experiment with financial news about the selected stock to find signals that inform us whether it is time to buy, sell or hold the stock.

There are many media outlets on the internet, which produce so much information that it is not quite easy to collect, process and analyze all the news in time to make the trade and benefit from it. However, we decided to still look into this and see if by collecting sample news and chatter about a selected stock (AAPL for example), we can have a better understanding of where the company is and how the stock is performing. We also presumed that by using the publicly accessible data on internet and calculating and aggregating the sentiments, we would obtain a feature that can be used by an algorithm in training to predict whether to buy, sell or hold a stock.

## Data Collection, Processing and Modeling

Most of the data collection and processing was done in Python. The submodule in the repository named, [Market Sentimentalism](https://github.com/EHDEV/market_sentimentalism2) is a python application that uses the Flask web framework to process ETL requests and return json outputs to the client.

This was born out of a script that was wrote to pull news data from Yahoo. However, we ran into some difficulties getting the historical data that we wanted. In addition, we weren't sure exactly which api to use, what data source to collect the news from, and how to perform the sentiment calculation. Therefore, this app was created to handle predefined requests for data with some flexibility in that the user would make an http request with option of passing some parameters. 

## Tools
In developing this strategy of understanding a stock's performance and recommending the action to take the next day, we used python with the [Flask](http://flask.pocoo.org/) framework for ETL and the [Jinja](http://jinja.pocoo.org/) template engine to render visualizations. In scraping news sites, we make great use of the [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/) and the [requests](http://docs.python-requests.org/en/latest/) library. Further, most of the sentiment analysis was done using the [AlchemyAPI](http://www.alchemyapi.com/) tool. 

## Code

Here are some snippets of code used in collecting, processing and visualizing the datasets used,

Some python libraries used:


Here is the code for some of the major functions to collect, process, model and visualize the data.

[gist of python code](https://gist.github.com/EHDEV/724a90302e514eeda82f)


Finally, a basic linear regression was performed by using data from 04/01 - 04/20 for training, to test the open price of 04/21. We obtained the following result:

http://localhost:5000/forecast/



{

    actual: 128,
    variance score: 0,
    rmse: 2.5693,
    features: [
        "trend",
        "score",
        "Close",
        "Volume"
    ],
    predicted: 125,
    recommendation: 0,
    coefs: [
        2.045,
        -0.0659,
        0.2468,
        -1.6672
    ],
    target: "Open Price"

}

### Example ETL Outputs


http://localhost:5000/fb/Apple-Inc?access_token=xxxx


{
    category: "Company",
    talking_about_count: 5784,
    description: "Apple Inc. is an American multinational corporation headquartered ...
    has_added_app: false,
    can_post: false,
    location: {
    city: "Cupertino",
    zip: "95014",
    country: "United States",
    longitude: -122.03065555422,
    state: "CA",
    street: "1 Infinite Loop",
    latitude: 37.33158849705
},
    name: "Apple Inc.",
    phone: "(408) 996-1010",
    link: "https://www.facebook.com/pages/Apple-Inc/105596369475033",
    likes: 9191836,
    parking: {
    street: 0,
    lot: 0,
    valet: 0
    },
    is_community_page: true,
    were_here_count: 169646,
    checkins: 169646,
    id: "105596369475033",
    is_published: true
}


Here is a sample of the scraped twitter data that will be returned by the url above:

http://localhost:5000/tweets/AAPL?start_date=2015-04-04&end_date=2015-04-05


{
    "2015-04-04": [
            "
    The iPhone is clearly the world's preferred tech luxury item. $AAPL unbeatable in #China: http://www.forbes.com/sites/kenrapoza/2015/04/04/apple-takes-bigger-bite-of-xiaomis-smartphone-market-in-china/\u00a0\u2026

    ",
            "
    New Apple Store front display for Apple Watch, new gold model details revealed http://dlvr.it/9Fm521\u00a0 #9to5Mac $AAPL pic.twitter.com/gjM8LvzHwg

    ",
            "
    Logging in now to live stock chat http://www.optionmillionaires.com/\u00a0 $GOOG $AAPL $FB $EBAY #options #stocks #daytrading pic.twitter.com/GhY3dvPtzo
    ",
            "
    Apple Watch In-Store Reservations Available Beginning April 10: Apple on Friday updated its online store... http://bit.ly/1ETWGgq\u00a0 $AAPL
    ",
            "
    STRIKER9 PRO Binary Options System That Can Make Upto $201K Per Month Trading AAPL And GOOG! http://bit.ly/IfC4E1\u00a0\n#BinaryOptions
    ",
            "
    Why everyone should disregard a \"head & shoulders top\" $AAPL @SlopeOfHope http://slopeofhope.com/2012/12/apple-the-technical-picture-gets-uglier.html\u00a0\u2026
    ",
            "
    Hope I win this #iPad mini from @ValueWalk! $AAPL http://www.valuewalk.com\u00a0 http://lockerdo.me/5~psk\u00a0
    "
        ]
}
```

### Visualizations

Most of the visualizations for this project were done in ggplot2 but we also have a few in HighCharts that are part of the MarketSentimentalism module. Here are a few simple line plots to compare the movement of Apple's stock against the the four variables we used for this strategy.

[Opening Price, Google Trend]({{site.baseurl}}/images/open_trend.png)


[Opening Price, Sentiment]({{site.baseurl}}/images/open_sentiment.png)


[Opening Price, Volume]({{site.baseurl}}/images/open_volume.png)


[All Plots]({{site.baseurl}}/images/all.png)