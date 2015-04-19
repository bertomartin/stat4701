require(quantmod)
require(PerformanceAnalytics)

#this can be classified as a momentum strategy. If a stock ends higher today, it's momentum 
#will carry over and it's likely to end higher the next day, so we buy at the beginning of the 
#following day and sell at the end.
#to calculate the strategy signal, we use a 1-day lag and 3-day lag. In the first instance, if the price
#increased the previous day, we buy at the start of the following and sell at the end of the following.
#in the second case, we did this if the price increased for the 3 previous days.

########### strategy 1 ########
getSymbols("^GSPC")
SPY <- GSPC['2010-06-01::2011-06-01']
retVec=Delt(Op(SPY),Cl(SPY))

#strategy
binaryVec=lag(ifelse(Cl(SPY)>Op(SPY),1,0),1) #buy or stay out
binaryVec[is.na(binaryVec)]=0

#calculate returns.
stratVec=retVec*binaryVec

#chart returns
charts.PerformanceSummary(stratVec)

#chart combined returns
combinedReturns=cbind(retVec,stratVec)

#annualized sharpe ratio of s&p
SharpeRatio.annualized(retVec, scale=252)
sd.annualized(retVec, scale=252)

############## startegy 1 extended: look back 3 days and make a decision on the 4th ################

####### strategy update 
binVec3Day=ifelse(((Cl(SPY)>Op(SPY))),1,0) * ifelse(lag(Cl(SPY),1)>lag(Op(SPY),1),1,0) * ifelse(lag(Cl(SPY),2)>lag(Op(SPY),2),1,0)
binVec3Day=lag(binVec3Day,1)
binVec3Day[is.na(binVec3Day)]=0

#calculate returns using strategy
stratVec3=retVec*binaryVec3Day

#chart returns
charts.PerformanceSummary(stratVec3)

# chart combined returns
combinedReturns3=cbind(retVec,stratVec)
charts.PerformanceSummary(combinedReturns3)



#idea: iterate from 1-5 days, and choose the one that works best.
#idea2: change time periods.


