require("ggplot2")
period <- GSPC['2009-06-01/2010-09-01']
period_closing <- Cl(period)

indicatorValuesBBands <- BBands(Cl(period), n=20, sd=2)
periodRSI <- CCI(period)


################################# strategy 1: DVI ########################
require(quantmod)
require(PerformanceAnalytics)

#step 1: Get Data
getSymbols("^GSPC")
gspc <- GSPC['2014-01-01/2015-03-16']

#step 2: create indicator
dvi <- DVI(Cl(gspc))
sig1 <- ifelse(dvi$dvi < 0.5, 1, -1)
sig <- Lag(sig1)

################## strategy 2: open/close #############
getSymbols("^GSPC", from = '2007/01/01')
retVec=Delt(Op(GSPC),Cl(GSPC))

################## experiments ###################
# https://tradingposts.wordpress.com/2013/06/page/2/
getSymbols("^GSPC", from = '2007/01/01')
vol=volatility(GSPC,n=25,N=252,calc="close")
chartSeries(vol)

########### strategy 1 ########
getSymbols("^GSPC", from = '2007/01/01')
SPY <- GSPC['2007-01-01/']
retVec=Delt(Op(SPY),Cl(SPY))

#strategy
binaryVec=lag(ifelse(Cl(SPY)>Op(SPY),1,0),1) #buy or stay out

#calculate returns.
stratVec=retVec*binaryVec

#chart returns
charts.PerformanceSummary(stratVec)
