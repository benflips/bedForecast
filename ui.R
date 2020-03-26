#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

source("getData.R")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Hospitalisation forecast"),
  navbarPage(p("As of", format(dates[length(dates)], "%d %b")),
  tabPanel("Hospitalisations",
           sidebarLayout(
             sidebarPanel(
               titlePanel("Location"),
               selectInput(inputId = "stateFinderHosp",
                           label = "Select State:",
                           choices = ddReg,
                           selected = ddNames[1]),
               sliderInput("det", "Percentage of cases detected", 5, 100, dRate*100, step=5, post = " percent"),
               sliderInput("timeToHosp", "Time from onset to hospitalisation", 3, 8, 6, step=1, post = " days"),
               sliderInput("fracCrit", "Critical symptomatic cases", 2, 8, 5, step=1, post = " percent"),
               sliderInput("fracSev", "Severe symptomatic cases", 10, 20, 15, step=1, post = " percent"),
               sliderInput("tICU", "Time in ICU", 5, 12, 8, step=1, post = " days"),
               #sliderInput("percAvail", "Percentage of ICU beds available", 20, 120, 20, step=10, post = " percent"),
               hr(),
               #h5("ICU saturation date:"),
               #textOutput(outputId = "dDay"),
               h5("Expected demand:"),
               tableOutput("caseTab")
             ),
             mainPanel(
               plotOutput("sevPlot"),
               plotOutput("critPlot"),
               #p("Red line indicates available ICU beds"),
               p("The obvious parameter to tune to match real cases today is detection.")
             )
           )    
  ),
  tabPanel("Model Description", br(),
           fluidRow(column(12,
                           withMathJax(),
                           includeMarkdown("Details.Rmd")
           )))
  )
))
