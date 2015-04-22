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
getSymbols("AAPL") #getting data for the aapl
AAPL <- AAPL['2007-01-01::2013-06-19']

#2-Calculate the 200-Day SMAs:
smaHi200=SMA(Hi(AAPL),200)
smaLo200=SMA(Lo(AAPL),200)

#3-Calculate the lagged trading signal vector:
signal=lag(ifelse(Cl(AAPL)>smaHi200,1,0)+ifelse(Cl(AAPL)<smaLo200,-1,0),1)

#clean up NAs
signal[is.na(signal)]=0

#calculate daily returns vector
buyAndHold=diff(log(Ad(AAPL))) #subtract yesterday from today
colnames(buyAndHold) <- "AAPL Buy & Hold"

#calculate strategy returns
strategyReturns=signal*buyAndHold
colnames(strategyReturns) <- "200dma Strategy"

#charts.PerformanceSummary(cbind(rets,stratRets))
charts.PerformanceSummary(strategyReturns, geometric=FALSE)

#table of strategy performance
combinedReturns3=cbind(buyAndHold,strategyReturns)
charts.PerformanceSummary(combinedReturns3, geometric=FALSE)



