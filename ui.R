#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
useShinyjs()
shinyUI(fluidPage(useShinyjs(),
        tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "main.css")),
        fluidRow(column(width = 12, tags$h1("You type, I predict."))),
        fluidRow(column(width = 12, textAreaInput("txtInput", "")),
        fluidRow(column(width = 4, actionButton("pred2nd","")),
                 column(width = 4, actionButton("pred1st","")),
                 column(width = 4, actionButton("pred3rd","")))
    )
  )
)
