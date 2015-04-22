#trend trading strategy
#idea: buy and hold if security price is above a certain length moving average price. 
# sell and hold if the security price is below a certain length moving average.

#choosing the length of the moving average price is important obviously, and so it will 
#help if you're familiar with the length of time a security is likely to continue trending
#for example, you if you expect that the a new technology will take hold, such as solar, 
#you can probably choose a relatively longer period moving average.

#we could use a parameter optimization technique to choose the right lenth sma. However, there's 
#the risk of over-optimizing or fitting the data too closely, where you end up optimizing for noise

#one important point to keep in mind is that backtesting can only be used to reject strategies, 
#not to accept them



require(quantmod)
require(PerformanceAnalytics)

#1-get data
getSymbols("^GSPC") #getting data for the s&p 500
SPY <- GSPC['2007-01-01::2013-06-19']

#2-Calculate the 200-Day SMAs:
smaHi200=SMA(Hi(SPY),200)
smaLo200=SMA(Lo(SPY),200)

#3-Calculate the lagged trading signal vector:
binVec=lag(ifelse(Cl(SPY)>smaHi200,1,0)+ifelse(Cl(SPY)<smaLo200,-1,0),1)

#clean up NAs
binVec[is.na(binVec)]=0

#calculate daily returns vector
rets=diff(log(Ad(SPY))) #subtract yesterday from today

#calculate strategy returns
stratRets=binVec*rets

#charts.PerformanceSummary(cbind(rets,stratRets))
charts.PerformanceSummary(stratRets)

#table of strategy performance
combinedReturns3=cbind(rets,stratRets)
charts.PerformanceSummary(combinedReturns3)



