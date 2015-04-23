---
layout: post
title: Sentiment Analysis 
---



<div class="message">
  We will use QuantTradr to investigate how sentiments from various news
  sources can be used as a predictor for future prices.
</div>

# Why Sentiment Analysis ? #

##Early News Detection##

* How did Dataminr learn about bin Laden's death before most of the rest of the world? 
* It came down primarily to 19 tweets seen in a five-minute period.
* Dataminr sent out an alert about Osama bin Laden's death 23 minutes before it was reported in the news.
* First move in S&P Futures caused by bin Laden's death occurred 4 minutes before Bloomberg reported news.


##Twitter for stock market##


![twitter mood predicts stock market]({{site.baseurl}}/images/twittermood.png)



## Using News to Predict trends ##



![uk oil co]({{site.baseurl}}/images/uk_oil.png)



![twitter stock rises]({{site.baseurl}}/images/google_twitter.png)



##Resources for Analysis##


* Twitter - @Yahoonews,@googlenews,@Yahoofinance,@ftfinancialtimes,@cnnmoney,@cnbcfastmoney,#Apple,$AAPL
* Google trends
* Yahoo News,Google News, Yahoo Finance, Seeking Alpha

{% highlight r %}
##Libraries used##

library(tm)

library(tm.plugin.webmining)

library(slam)

library(twitteR)

library(stringr)

## Extract the tweets using @YahooFinance
apple_yahoonewstweets_apr13 = searchTwitter("@YahooFinance",lang="en",since='2015-04-13',until='2015-04-14',n=400)

apple_yahoonewstweets_apr14 = searchTwitter("@YahooFinance",lang="en",since='2015-04-14',until='2015-04-15',n=400)

apple_yahoonewstweets_apr15 = searchTwitter("@YahooFinance",lang="en",since='2015-04-15',until='2015-04-16',n=400)

apple_yahoonewstweets_apr16 = searchTwitter("@YahooFinance",lang="en",since='2015-04-16',until='2015-04-17',n=400)

apple_yahoonewstweets_apr17 = searchTwitter("@YahooFinance",lang="en",since='2015-04-17',until='2015-04-18',n=400)

apple_yahoonewstweets_apr18 = searchTwitter("@YahooFinance",lang="en",since='2015-04-18',until='2015-04-19',n=400)

apple_yahoonewstweets_apr19 = searchTwitter("@YahooFinance",lang="en",since='2015-04-19',until='2015-04-20',n=400)

apple_yahoonewstweets_apr20 = searchTwitter("@YahooFinance",lang="en",since='2015-04-20',until='2015-04-21',n=400)

apple_yahoonewstweets_apr21 = searchTwitter("@YahooFinance",lang="en",since='2015-04-21',until='2015-04-22',n=400)

##Get the text##

apple_yahoonewstext = sapply(apple_yahoonewstweets_apr21, function(x) x$getText())

## Clean the data ##
apple_yahoonewstext=str_replace_all(apple_yahoonewstext_apr21,"[^[:graph:]]", " ")

#Use the searchterm to filter

searchTerm="Apple"

#filter for Apple news

apple_yahoonewstext_apr=unique(apple_yahoonewstext_apr20[grepl(searchTerm,apple_yahoonewstext_apr)])


 ## Calculate the Sentiment Score ##
 
 scoreCorpus <- function(text, pos, neg) {
  corpus <- Corpus(VectorSource(text)) 
  termfreq_control <- list(removePunctuation = TRUE,stemming=FALSE, stopwords=TRUE, wordLengths=c(2,100)) 
  
  dtm <-DocumentTermMatrix(corpus, control=termfreq_control)
  
  ## term frequency matrix
  
  tfidf <- weightTfIdf(dtm)
  
  # identify positive terms
  
  which_pos <- Terms(dtm) %in% pos
  
  # identify negative terms
  
  which_neg <- Terms(dtm) %in% neg
  
  # number of positive terms in each row
  
  score_pos <- row_sums(dtm[, which_pos])
  
  # number of negative terms in each row
  
  score_neg <- row_sums(dtm[, which_neg])
  
  # number of rows having positive score makes up the net score 
  
  net_score <- sum((score_pos-score_neg)>0)
  
  # length is the total number of instances in the corpus
  
  length <- length(score_pos-score_neg)
  score <- net_score /length
  return(score) 
}


##List of positive Worrds and negative words ##

hu.liu.pos = scan('~/Documents/STAT4701/sentimentanalysis/opinion-lexicon-English/positive_words.txt', what='character', comment.char=';')

hu.liu.neg = scan('~/Documents/STAT4701/sentimentanalysis/opinion-lexicon-English/negative_words.txt', what='character', comment.char=';')


##calculate the scores for each day##

score_apple=scoreCorpus(apple_yahoonewstext,hu.liu.pos,hu.liu.neg)


##plot the scores for each day ##

p=ggplot(scores_dat,aes(x=dates,y=scores,group=1))  
p + geom_line()
{% endhighlight %}

## Sentimental Score Plot of "Apple" using @Yahoofinance ##

![yahoo_finance]({{site.baseurl}}/images/yahoofinance_apr21.png)


## lets see the AAPL stock price during this time ##

![AAPL_yahoofinance]({{site.baseurl}}/images/AAPL_yahoofinance.png)

##Why this trend ? / What we are After?  ##

![AAPL_selloutnews]({{site.baseurl}}/images/apple_sellout_news.png)

![AAPL_watch_news]({{site.baseurl}}/images/apple_watch_news_april23.png)

![SAAPL_watch_news]({{site.baseurl}}/images/SAAPL_sellout.png)



The limitation with twitter is we can get only past 8 days of data,using the searchTwitter function.


But if we want to get the data for a specific user account,we can get upto 3200 tweets.This might give us data for over a month.



## Similarly, we analyzed the tweets of @SAlphaAAPL from March 18,2015 - April 23,2015 .This is a specific twitter account for AAPL news##

An example ...

![Seeking_alpha]({{site.baseurl}}/images/SAAPL_screenshot.png)

Sentimental Score Plot of "Apple" from account @SAlphaAAPL 

![Seeking_alpha]({{site.baseurl}}/images/SAlphaAAPL_apr23.png)



##AAPL stock Volume during this time ##

![Seeking_alpha]({{site.baseurl}}/images/AAPL_stock_seekingalpha.png)




## Predicting Stock Market trends using Google Trends Data ##

Google Trends gives us interest score on a scale of 1 - 100 through Google Searches.Below is data for the term AAPL for year Jan to April 2015.

Week | AAPL Score
-----| -----
01/04/15|	35
01/11/15|	32
01/18/15|	31
01/25/15|	81
02/01/15|	40
02/08/15|	50
02/15/15|	42
02/22/15|	48
03/01/15|	42
03/08/15|	55
03/15/15|	39
03/22/15|	34
03/29/15|	31
04/05/15|	35
04/12/15|	36
04/19/15|	32

##AAPL Gtrends score Jan - April 2015##

![gtrends_2015]({{site.baseurl}}/images/gtrends_2015.png)



##And the AAPL Stock volume for the same period##

![AAPLstock_gtrends_2015]({{site.baseurl}}/images/AAPL_stock_for_gtrends2015.png)


We can clearly see a correlation between the AAPL stock volume and the google trends interest score for AAPL.



##AAPL score(Google trends) vs AAPL stock volume- 2014 ##


![gtrends_2015]({{site.baseurl}}/images/AAPL_gtrends_2014.png)

![AAPLstock_gtrends_2015]({{site.baseurl}}/images/AAPL_stock_for_gtrends2014.png)



## AMZN score (Google trends) vs AMZN stock volume -2014 ##

![gtrends_2014]({{site.baseurl}}/images/gtrends_AMZN_2014.png)


![Amazon_stock_2014]({{site.baseurl}}/images/Amazon_stock_2014.png)


## Maybe More ... Predicting Sales ?? Samsung Galaxy S5 vs Iphone 6 Plus (Google trends) ##

![Iphone_samsung]({{site.baseurl}}/images/iphone_samsung_gtrends.png)



##What Next ? ##

-Collect Financial News over a period of time(Google News/Yahoo News/Seeking Alpha/Stocktwits).
-Grab headlines/description from the news.
-Aggregate with twitter Data(@yahoofinance and @SAlphaAAPL) and Google Trends Data.
-Use the data collected from the past to predict a signal for the future.
