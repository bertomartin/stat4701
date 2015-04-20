#http://www.quintuitive.com/2012/11/10/back-testing-rules/
library(quantmod)

getSymbols("^GSPC", from=2000-01-01)

gspc = GSPC["/2012-09-15"]

print( last(EMA(Cl(gspc), 20 )))

print(last(EMA( tail(Cl(gspc), 60), 20  )))
