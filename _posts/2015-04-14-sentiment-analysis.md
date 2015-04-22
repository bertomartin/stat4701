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


##Twitter mood predicts the stock market##

![twitter mood predicts stock market](Users/rob2056/Desktop/twittermood.png)



## Using News to Predict trends ##

![uk oil co](Users/rob2056/Desktop/uk_oil.png)

![twitter stock rises](Users/rob2056/Desktop/google_twitter.png)


##Resources ##

* Twitter - @Yahoonews,@googlenews,@Yahoofinance,@ftfinancialtimes,@cnnmoney,@cnbcfastmoney,#Apple,$AAPL
* Google trends
* Yahoo News,Google News, Yahoo Finance, Seeking Alpha


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

 ##Calculate the Sentiment Score##
 
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


![uk oil co](Users/rob2056/Documents/STAT4701/Final_Project/yahoofinance_apr21.png)



## lets see the AAPL stock during this time ##

![uk oil co](Users/rob2056/Documents/STAT4701/Final_Project/AAPL_yahoofinance.png)




## Similarly, we analyzed the tweets of @SAlphaAAPL##

({{site.baseurl}}/images/seeking_alphaAAPL_correlates_volume.png)
##AAPL stock Volume during this time ##






