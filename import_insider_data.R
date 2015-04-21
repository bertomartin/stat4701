library(XML)
#install.packages('RCurl')
library(RCurl)
URL <- "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000320193&type=&dateb=&owner=only&start=0&count=1000&output=atom"
doc <- xmlParse(URL) 
src <- getNodeSet(doc, "//x:filing-href", c(x = "http://www.w3.org/2005/Atom")) 

con = getCurlHandle( ftp.use.epsv = FALSE)
contents=list()
for (i in 1:length(src)) {
  url = paste("ftp://ftp.sec.gov",substr(xmlValue(src[[i]][1]$text),28,65),sep="")
  filenames=getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames = paste(url, strsplit(filenames, "\r*\n")[[1]], sep = "")
  filenames = filenames[grepl('.xml',filenames)]
  contents[i] = getURL(filenames[1], curl = con)
  names(contents[i]) = filenames[1]
}
