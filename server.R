#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

source("getData.R")

# Define server logic 
shinyServer(function(input, output) {
  ###### translate data according to inputs #####
  tLate <- reactive({
    yA <- tsSub(tsA,tsA$Province.State %in% input$stateFinderHosp)
    splitter(yA, 
             time = dates, 
             tth = input$timeToHosp, 
             fracCrit = input$fracCrit/100,
             fracSev = input$fracSev/100,
             det = input$det/100,
             tInICU = input$tICU)
  })
  
  # ##### Severe by day #####
  output$sevPlot <-renderPlot({
    yH <- tLate()
    projSev <- projSimple(yH$severe, yH$hDate, extWindow = 5)
    yMax <- max(c(projSev$y[,"fit"], yH$severe), na.rm = TRUE)
    yTxt <- "Severe cases (Ward beds)"
    plot(yH$severe~yH$hDate,
         xlim = c(min(dates), max(projSev$x)),
         ylim = c(0, yMax),
         pch = 19,
         bty = "u",
         xlab = "Date",
         ylab = yTxt,
         main = paste("Ward beds,", input$stateFinderHosp))
    axis(side = 4)
    # lines(projSev$y[, "fit"]~projSev$x, lty = 1)
    # lines(projSev$y[, "lwr"]~projSev$x, lty = 2)
    # lines(projSev$y[, "upr"]~projSev$x, lty = 2)
  })
  
  # ##### Critical by day #####
  output$critPlot <-renderPlot({
    yH <- tLate()
    projCrit <- projSimple(yH$critical, yH$icuDate, inWindow = input$timeToHosp+6, extWindow = 2)
    yMax <- max(c(projCrit$y[,"fit"], yH$critical), na.rm = TRUE)
    yTxt <- "Critical cases (ICU Beds)"
    plot(yH$critical~yH$icuDate,
         xlim = c(min(dates), max(projCrit$x)),
         ylim = c(0, yMax),
         pch = 19,
         bty = "u",
         xlab = "Date",
         ylab = yTxt,
         main = paste("ICU Beds,", input$stateFinderHosp))
    axis(side = 4)
    # lines(projCrit$y[, "fit"]~projCrit$x, lty = 1)
    # lines(projCrit$y[, "lwr"]~projCrit$x, lty = 2)
    # lines(projCrit$y[, "upr"]~projCrit$x, lty = 2)
  })
  
  output$dDay <- renderText({
    yH <- tLate()
    projCrit <- projSimple(yH$critical, yH$icuDate, extWindow = 5)
    nBeds <- beds$ICUBeds[beds$state==input$stateFinderHosp]*(input$percAvail/100)
    dDay <- min(projCrit$x[projCrit$y[,"fit"]>nBeds])
    if (is.infinite(dDay)) dDay <- "Beyond forecast horizon" else format(dDay, format = "%d/%m/%y")  
  })
  
  output$caseTab <- renderTable({
    yH <-tLate()
    #projSev <- projSimple(yH$severe, yH$hDate, extWindow = 5)
    #projCrit <- projSimple(yH$critical, yH$icuDate, inWindow = input$timeToHosp+6, extWindow = 2)
    sevSS <- which(yH$hDate==Sys.Date())
    sevSS <-sevSS:length(yH$hDate)
    critSS <- which(yH$icuDate==Sys.Date())
    critSS <-critSS:length(yH$icuDate)
    wBeds <- c(yH$severe[sevSS], rep(NA, length(critSS)-length(sevSS)))
    data.frame(Date = format(yH$icuDate[critSS], "%d/%m"), "Ward beds" = wBeds, "ICU beds" = yH$critical[critSS])
  })

})
