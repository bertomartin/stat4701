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
