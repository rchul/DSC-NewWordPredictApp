#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(quanteda)
library(stringr)
library(data.table)

#Load data
allN <- readRDS("Q98TrainData.rds")

#Main predicting function
newPred2 <- function (x) {
  #Parse sentence
  sento <- tokens(x, remove_symbols = T, remove_punct = T, remove_url = T)
  if (length(sento[[1]]) > 0) {
    getW <- tolower(tail(sento[[1]],4))
  } else {
    error <- "Sorry[1]: No input"
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
      error <- "Sorry[2]: No result"
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
  getTop <- str_replace_na(getTop, replacement = "")
  return(getTop)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  hide(selector = ".btn")
  predResult <- reactiveValues(first = NA, second = NA, third = NA)
  txtToPred <- reactiveValues(txt = NA)
  observeEvent(input$txtInput, ignoreInit = TRUE, {
    if (isTruthy(input$txtInput)) {
    txtToPred$txt <- str_trim(input$txtInput, side = "right")
    prediction <- newPred2(txtToPred$txt)
    if (length(prediction) < 3) {
      disable("pred1st")
      disable("pred2nd")
      disable("pred3rd")
    } else {
      enable("pred1st")
      enable("pred2nd")
      enable("pred3rd")
    }
    #Store new prediction
    predResult$first <- prediction[1]
    predResult$second <- prediction[2]
    predResult$third <- prediction[3]
    #Update the buttons
    updateActionButton(session, "pred1st", label = prediction[1])
    updateActionButton(session, "pred2nd", label = prediction[2])
    updateActionButton(session, "pred3rd", label = prediction[3])
    delay(0, show(selector = ".btn"))
    }
  })
  observeEvent(input$pred1st, {
    txtout <- paste(txtToPred$txt,predResult$first,sep= " ")
    updateTextAreaInput(session, "txtInput", value = txtout)
  })
  observeEvent(input$pred2nd, {
    txtout <- paste(txtToPred$txt,predResult$second,sep= " ")
    updateTextAreaInput(session, "txtInput", value = txtout)
  })
  observeEvent(input$pred3rd, {
    txtout <- paste(txtToPred$txt,predResult$third,sep= " ")
    updateTextAreaInput(session, "txtInput", value = txtout)
  })
})
