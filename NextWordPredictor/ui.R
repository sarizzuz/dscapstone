#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(markdown)
library(shinythemes)

shinyUI(fluidPage(theme=shinytheme("superhero"),
                  
                  titlePanel("Next Word Predictor"),
                  
                  #Side bar with instructions for using the app
                  sidebarLayout(
                      sidebarPanel(
                          h4("Background:"),
                          p("This application predicts the next word for a given phrase"),
                          h4("How to use:"),
                          p("On the ''Word Predictions'' tab, wait until you see the ''App is ready'' message then  
          begin typing the phrase you want to get a prediction for. You may need to wait for 
          10-20 seconds for the message to appear."),
                          p("Your input phrase along with suggested next words will be shown below the textbox as 
          you start typing."),
                          p("Note that the application cannot provide predictions if you only input numbers or symbols. 
          For example, ''24 hours'' is a valid input but ''24'' is not."),
                          p("If you want to know more details about how this application was created, 
          you may refer to the ''Application Details'' tab.")
                      ),
                      
                      #Main panel with tabs containing the text prediction app and a separate tab for app details
                      mainPanel(
                          tabsetPanel(type = "tabs", 
                                      tabPanel("Word Predictions",
                                               br(),
                                               textInput('words', label="Input Phrase", width = "100%"),
                                               verbatimTextOutput('predictedsentence')
                                      ),
                                      tabPanel("Application Details",
                                               br(),
                                               includeMarkdown("include.md")
                                      ),
                                      tabPanel("About",
                                               br(),
                                               includeMarkdown("NWP_about.Rmd"))
                          )
                      )
                  )
))
