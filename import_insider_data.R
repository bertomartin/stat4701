library(XML)
#install.packages('RCurl')
library(RCurl)
con<-getCurlHandle( ftp.use.epsv = FALSE)
insiderID <- character()
isOfficer <- logical()
isDirector <- logical()
isTenPctOwner <- logical()
isDerivTxn <- logical()
securityType <- character()
transDate <- character()
#class(transDate) <- "Date"
transCode <- character()
transShareQty <- integer()
transSharePrice <- numeric()
transCodeAcqDisp <- character()
postTransSharesHeld <- integer()
fileName <- character()
start <- 0
checkstart <- 0
#loaded up to start=423 4/22/2015
URL <- paste("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000320193&type=&dateb=&owner=only&start=",start,"&count=100&output=atom",sep="")
doc <- xmlParse(URL) 
src <- getNodeSet(doc, "//x:filing-href", c(x = "http://www.w3.org/2005/Atom")) 
while (length(src)>0){
for (i in 1:length(src)) {
  if (length(src)==0){next}
  url = paste("ftp://ftp.sec.gov",substr(xmlValue(src[[i]][1]$text),28,65),sep="")
  filenames=getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames = paste(url, strsplit(filenames, "\r*\n")[[1]], sep = "")
  filenames = filenames[grepl('.xml',filenames)]
  contents = getURL(filenames[1], curl = con)
  #names(contents[i]) = filenames[1]
  contents <- xmlParse(contents)
  r<- xmlRoot(contents)
  if (xmlValue(r[[2]])!=4) {next}
  checkstart <- checkstart + 1
  #nonderivative transactions
  for (j in 1:xmlSize(r[['nonDerivativeTable']])){
    if ((xmlSize(r[['nonDerivativeTable']]))==0){next}
    if (xmlName(r[['nonDerivativeTable']][[j]])!='nonDerivativeTransaction'){next}
    fileName <- c(fileName,filenames[1])
    insiderID <- c(insiderID, xmlValue(r[['reportingOwner']][['reportingOwnerId']][['rptOwnerCik']]))
    isOfficer <- c(isOfficer, xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isOfficer']]))
    isDirector <- c(isDirector, xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isDirector']]))
    isTenPctOwner <- c(isTenPctOwner,xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isTenPercentOwner']]))  
    isDerivTxn <- c(isDerivTxn, FALSE)
    securityType <- c(securityType,xmlValue(r[['nonDerivativeTable']][[j]][['securityTitle']]))
    transDate <- c(transDate,xmlValue(r[['nonDerivativeTable']][[j]][['transactionDate']]))
    transCode <- c(transCode,xmlValue(r[['nonDerivativeTable']][[j]][['transactionCoding']][['transactionCode']]))
    transShareQty <- c(transShareQty,xmlValue(r[['nonDerivativeTable']][[j]][['transactionAmounts']][['transactionShares']]))
    transSharePrice <- c(transSharePrice,xmlValue(r[['nonDerivativeTable']][[j]][['transactionAmounts']][['transactionPricePerShare']]))
    transCodeAcqDisp <- c(transCodeAcqDisp,xmlValue(r[['nonDerivativeTable']][[j]][['transactionAmounts']][['transactionAcquiredDisposedCode']]))
    postTransSharesHeld <- c(postTransSharesHeld,xmlValue(r[['nonDerivativeTable']][[j]][['postTransactionAmounts']][['sharesOwnedFollowingTransaction']]))
  }
  #derivative transactions
  for (j in 1:xmlSize(r[['derivativeTable']])){
    if ((xmlSize(r[['derivativeTable']]))==0){next}
    if (xmlName(r[['derivativeTable']][[j]])!='derivativeTransaction'){next}
    fileName <- c(fileName,filenames[1])
    insiderID <- c(insiderID, xmlValue(r[['reportingOwner']][['reportingOwnerId']][['rptOwnerCik']]))
    isOfficer <- c(isOfficer, xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isOfficer']]))
    isDirector <- c(isDirector, xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isDirector']]))
    isTenPctOwner <- c(isTenPctOwner,xmlValue(r[['reportingOwner']][['reportingOwnerRelationship']][['isTenPercentOwner']]))  
    isDerivTxn <- c(isDerivTxn, TRUE)
    securityType <- c(securityType,xmlValue(r[['derivativeTable']][[j]][['securityTitle']]))
    transDate <- c(transDate,xmlValue(r[['derivativeTable']][[j]][['transactionDate']]))
    transCode <- c(transCode,xmlValue(r[['derivativeTable']][[j]][['transactionCoding']][['transactionCode']]))
    transShareQty <- c(transShareQty,xmlValue(r[['derivativeTable']][[j]][['transactionAmounts']][['transactionShares']]))
    transSharePrice <- c(transSharePrice,xmlValue(r[['derivativeTable']][[j]][['transactionAmounts']][['transactionPricePerShare']]))
    transCodeAcqDisp <- c(transCodeAcqDisp,xmlValue(r[['derivativeTable']][[j]][['transactionAmounts']][['transactionAcquiredDisposedCode']]))
    postTransSharesHeld <- c(postTransSharesHeld,xmlValue(r[['derivativeTable']][[j]][['postTransactionAmounts']][['sharesOwnedFollowingTransaction']]))
  }
  start <- start + 1
}
URL <- paste("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000320193&type=&dateb=&owner=only&start=",start,"&count=100&output=atom",sep="")
doc <- xmlParse(URL) 
src <- getNodeSet(doc, "//x:filing-href", c(x = "http://www.w3.org/2005/Atom")) 
}
