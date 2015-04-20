#plotting with ggplot

library(quantmod)
getSymbols("^GSPC")
period <- GSPC['2012-06-01/2015-03-01']
x <- Vo(period)
c <- Cl(period)



library(ggplot2)
d <- data.frame( time = index(x), volume=drop(coredata(x)))
ggplot(d, aes(time, volume)) + geom_point(shape=1)

dd <- data.frame( time = index(c), closing=drop(coredata(c)))
ggplot(dd, aes(time, closing)) + geom_point(shape=1)
