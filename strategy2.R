# improve strategy 1 by incorporating short selling

require(quantmod)
require(PerformanceAnalytics)

########### strategy 2: long short ########
getSymbols("^GSPC")
SPY <- GSPC['2011-06-01::2014-06-01']
retVec=Delt(Op(SPY),Cl(SPY))

#long
binVec3Day=ifelse(((Cl(SPY)>Op(SPY))),1,0) * ifelse(lag(Cl(SPY),1)>lag(Op(SPY),1),1,0) * ifelse(lag(Cl(SPY),2)>lag(Op(SPY),2),1,0)
binVec3Day=lag(binVec3Day,1)
binVec3Day[is.na(binVec3Day)]=0

#short
#rules: 1. if the closing price today < opening price today, -1
#2. if the closing price yesterday < opening price yesterday, -1
#3. if the closing
shortVec=ifelse( ((Cl(SPY)<Op(SPY))),-1,0) * ifelse(lag(Cl(SPY),1)<lag(Op(SPY),1),-1,0) * ifelse(lag(Cl(SPY),2)<lag(Op(SPY),2),-1,0)


shortVec=lag(shortVec,1)
shortVec[is.na(shortVec)]=0

longShortVec=binVec3Day+shortVec

#calculate returns.
stratVec=retVec*longShortVec

sd.annualized(stratVec, scale=252)
SharpeRatio.annualized(stratVec, scale=252)

# performance summary
charts.PerformanceSummary(stratVec)
