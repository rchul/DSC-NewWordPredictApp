library(quanteda)
library(data.table)

newPred2 <- function (x) {
  #Parse sentence
  sento <- tokens(x, remove_symbols = T, remove_punct = T, remove_url = T)
  if (length(sento[[1]]) > 0) {
    getW <- tolower(tail(sento[[1]],4))
  } else {
    error <- "Error[1]: No input"
    return(error)
  }
  #Length of vector
  inputL <- length(getW)
  #Create string for index search
  givenW <- paste(getW[1:inputL], collapse = "_")
  #Table # for prediction
  tabN <- inputL + 1
  #List of possible predictions
  wi_list <- allN[[tabN]][givenW,.(pred,count)]
  #Prepare BO count
  BOcount <- 0
  while (is.na(wi_list[1,1])) {
    #if empty we back-off once
    BOcount <- BOcount + 1
    #change table used
    tabN  <- tabN - 1
    #if table used is below 2 return no result
    if (tabN < 2) {
      #Return no result
      error <- paste("Error[2]: ",BOcount,givenW,"no result")
      return(error)
    } else {
      #new string for search
      #skip first word of the vector by BOcount + 1
      givenW <- paste(getW[(BOcount+1):inputL], collapse = "_")
      wi_list <- allN[[tabN]][givenW,.(pred,count)]
    }
  }
  #Get w-1
  if (inputL == 1) {
    wi1W_1 <- getW[inputL]
    wi_1 <- allN[[tabN-1]][wi1W_1,count]
  } else {
    wi1W_1 <- paste(getW[(BOcount+1):(inputL-1)], collapse = "_")
    wi1W_2 <- getW[inputL]
    wi_1 <- allN[[tabN-1]][.(wi1W_1,wi1W_2),count]
  }
  #Get Results
  suggestTable <- wi_list[,count:=(0.4^BOcount)*(count/wi_1)][order(-count)]
  print(paste(x,"/",givenW,"/",BOcount))
  getTop <- suggestTable[1:3]$pred
  return(getTop)
}