library(plyr)
library(ggplot2)
require(quantmod)

txnDate<-as.Date(transDate)
class(transShareQty)<-"integer"
class(transSharePrice)<-"numeric"
class(isOfficer)<-"integer"
class(isDirector)<-"integer"
class(isTenPctOwner)<-"integer"
class(isDerivTxn)<-"logical"

#change share qtys to negative values in sale txns
transShareQty[transCodeAcqDisp=="D"] <- 0-transShareQty[transCodeAcqDisp=="D"]
#normalize share qtys and prices for stock splits (June 9, 2014 7-for-1)
transShareQty[txnDate<'2014-06-09'] <- transShareQty[txnDate<'2014-06-09'] * 7 
transSharePrice[txnDate<'2014-06-09'] <- transSharePrice[txnDate<'2014-06-09'] / 7 

dfInsiderData <- data.frame(insiderID,isOfficer,isDirector,isTenPctOwner,isDerivTxn,securityType,txnDate,
                  transCode,transShareQty,transSharePrice,transCodeAcqDisp,postTransSharesHeld)

#Consolidate net share qty change by ID, and by date
dfNetPositionChanges <- ddply(dfInsiderData, c("insiderID","txnDate"), function(dfInsiderData)sum(dfInsiderData$transShareQty))

#Strategy 1: take 6 month rolling average of net share holding increase/decrease for each insiderID, neg=sell, pos=buy
maxTxnDate <- max(dfInsiderData$txnDate)
dfTrl6mNetPositionChg<-dfNetPositionChanges[dfNetPositionChanges$txnDate<(maxTxnDate-180),]
for (iID in unique(dfTrl6mNetPositionChg$insiderID)) {
  x<-dfNetPositionChanges[dfNetPositionChanges$insiderID==iID & dfNetPositionChanges$txnDate<(maxTxnDate-180),]
  x$V1 <- sapply(x$txnDate, function(a) sum(dfNetPositionChanges[dfNetPositionChanges$insiderID==iID & dfNetPositionChanges$txnDate>=a & dfNetPositionChanges$txnDate<=(a+180),c("V1")]))
  x$txnDate <- x$txnDate + 180
  dfTrl6mNetPositionChg[dfTrl6mNetPositionChg$insiderID==iID,] <- x
}

#Strategy 2: take 12 month rolling average of net share holding increase/decrease for each insiderID, neg=sell, pos=buy
dfTrl12mNetPositionChg<-dfNetPositionChanges[dfNetPositionChanges$txnDate<(maxTxnDate-365),]
for (iID in unique(dfTrl12mNetPositionChg$insiderID)) {
  x<-dfNetPositionChanges[dfNetPositionChanges$insiderID==iID & dfNetPositionChanges$txnDate<(maxTxnDate-365),]
  x$V1 <- sapply(x$txnDate, function(a) sum(dfNetPositionChanges[dfNetPositionChanges$insiderID==iID & dfNetPositionChanges$txnDate>=a & dfNetPositionChanges$txnDate<=(a+365),c("V1")]))
  x$txnDate <- x$txnDate + 365
  dfTrl12mNetPositionChg[dfTrl12mNetPositionChg$insiderID==iID,] <- x
}

getDailySentiment <- function(groupIDs, dfTrlNetPositionChg, trailDays){
  vDates <- seq(min(dfTrlNetPositionChg$txnDate),max(dfTrlNetPositionChg$txnDate),"days")
  vNumVotes <- rep.int(0,length(vDates))
  vAggVotes <- rep.int(0,length(vDates))
  for (iID in groupIDs) {
    df <- dfTrlNetPositionChg[dfTrlNetPositionChg$insiderID==iID,]
    lastVoteDate <- min(dfTrlNetPositionChg$txnDate) - trailDays
    for (i in 1:length(vDates)){
      if (length(df$V1[df$txnDate==vDates[i]])==0){
        if ((vDates[i] - trailDays)>=lastVoteDate){
          vote<-0
          ctVote<-0
        }
      }
      else{
        vote=sign(df$V1[df$txnDate==vDates[i]])
        ctVote<-1
        lastVoteDate <-vDates[i]
      }
      vNumVotes[i]<-vNumVotes[i]+ctVote
      vAggVotes[i]<-vAggVotes[i]+vote
    }
  }
  avgScores <- vAggVotes/vNumVotes
  return(data.frame(vDates,vAggVotes,vNumVotes,avgScores))
}

officerIDs <- unique(dfInsiderData$insiderID[dfInsiderData$isOfficer==1 & !is.na(dfInsiderData$isOfficer)])
directorIDs <- unique(dfInsiderData$insiderID[dfInsiderData$isDirector==1 & !is.na(dfInsiderData$isDirector)])
ownerIDs <- unique(dfInsiderData$insiderID[dfInsiderData$isTenPctOwner==1 & !is.na(dfInsiderData$isTenPctOwner)])

testOffSent365 <- getDailySentiment(officerIDs,dfTrl12mNetPositionChg,365)
testDirSent365<-getDailySentiment(directorIDs,dfTrl12mNetPositionChg,365)
testAllSent365<-getDailySentiment(unique(dfInsiderData$insiderID),dfTrl12mNetPositionChg,365)

testOffSent180 <- getDailySentiment(officerIDs,dfTrl6mNetPositionChg,180)
testDirSent180<-getDailySentiment(directorIDs,dfTrl6mNetPositionChg,180)
testAllSent180<-getDailySentiment(unique(dfInsiderData$insiderID),dfTrl6mNetPositionChg,180)

#Get AAPL prices
getSymbols("AAPL") 
#AAPL <- AAPL[paste(min(testAllSent180$vDates),'::',max(testAllSent180$vDates),sep="")]
AAPL <- AAPL['2013-01-01::2015-01-01']

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testAllSent180$avgScores[testAllSent180$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Officers and Directors Trailing 6 Month Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testOffSent180$avgScores[testOffSent180$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Officers Trailing 6 Month Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testDirSent180$avgScores[testDirSent180$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Directors Trailing 6 Month Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testAllSent365$avgScores[testAllSent365$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Officers and Directors Trailing 1 Year Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testOffSent365$avgScores[testOffSent365$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Officers Trailing 1 Year Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 

dfPlot<-(data.frame(index(AAPL),Ad(AAPL),testDirSent365$avgScores[testDirSent365$vDates %in% index(AAPL)]))

ggplot(dfPlot, aes(dfPlot[,1])) + 
  geom_line(aes(y = (dfPlot$AAPL.Adjusted-dfPlot$AAPL.Adjusted[1])/dfPlot$AAPL.Adjusted[1], colour = "Indexed Share Price")) + 
  geom_line(aes(y = dfPlot[,3], colour = "Insider Sentiment Score")) + labs(title="Insider Sentiment Score vs Indexed Share Price\nBased on Directors Trailing 1 Year Net Position Changes", x = "", y="") +
  theme(legend.direction="vertical", legend.title= element_blank()) 
