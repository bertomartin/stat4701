library("quantmod")

#Script to download prices from yahoo and save
#the prices to an RData file. The tickers will be loaded 
#from a csv file.

#NB: the prices are saved in a new environment: stockData. To 
#get at the stock prices, do it like this: stockData$GOOG for example.

#Params
tickerlist <- "stocks.csv" #tickers on rows
savefilename <- "stockdata.RData" #the file to save data in
startDate = as.Date("2010-01-13") #from date
maxretryattempts <- 5 #number of retries if there's an error

#Load the list from the csv file
stocksList <- read.csv("stocks.csv", header=F, stringsAsFactors = F)
stockData <- new.env() #Make a new environment for quantmod to store data
numstocks <- length(stocksList[,1]) #the number of stocks to download

#download the data
for (i in 1:numstocks){
  for (t in 1:maxretryattempts){
    
    tryCatch(
        {
          if(!is.null(eval(parse(text=paste("stockData$", stocksList[i,1], sep=""))))){
            #variable exists, no need to retry
            break
          }
          
          #the stock wasn't previously downloaded
          cat("(", i, "/", numstocks, ") ", "Downloading ", stocksList[i,1], "\t\t Attempt: ", t, "/", maxretryattempts, "\n")
          getSymbols(stocksList[i,1], env = stockData, src = "yahoo", from = startDate)
        }
        #specify the catch function, and finally function
        , error = function(e) print(e)
      )
    
  }
}

getSymbols("^GSPC", env = stockData, src = "yahoo") #download the s&p 500 index. csv doesn't like this format

#save the stock data to a data file
tryCatch(
{
  save(stockData, file=savefilename)
  cat("Successfully saved the stock data to ", savefilename)
}, error = function(e) print(e)
  )