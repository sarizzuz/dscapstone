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
                          h4("App:"),
                          p("This application predicts the next word for a given word or phrase"),
                          h4("How to use:"),
                          p("Wait until the Output Box shows ''App is ready'' then  
          begin typing the phrase you want to get a prediction for in the Input Box."),
                          p(),
                          p("The Output Box will update to show the next predicted word."),
                          br(),
                          p("Note: Input which only have numbers or symbols are not accepted as a valid input."),
                          br(),
                          p("More information about the App can be found in the ''Application Details'' and ''References'' tabs.")
                      ),
                      
                      #Main panel with tabs containing the text prediction app and a separate tab for app details
                      mainPanel(
                          tabsetPanel(type = "tabs", 
                                      tabPanel("App",
                                               br(),
                                               p("Input Box"),
                                               textInput('words', label = NULL, placeholder = "Enter word or phrase here", width = "100%"),
                                               br(),
                                               p("Output Box"),
                                               verbatimTextOutput('wordprediction')
                                        
                                      ),
                                      tabPanel("App Information",
                                               br(),
                                               includeMarkdown("NWP_about.Rmd")
                                      ),
                                      tabPanel("References",
                                               br(),
                                               includeMarkdown("NWP_references.Rmd"))
                          )
                      )
                  )
))
