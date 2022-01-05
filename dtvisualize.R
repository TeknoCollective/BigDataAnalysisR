#Required library
library(mongolite)
library(ggplot2)
library(shiny)

# fetch the data from mongodb
ukdbplot <- mongo(collection = "ukplot",
                  db = "ukdata",
                  url = "mongodb://localhost")
usadbplot <- mongo(collection = "usaplot",
                   db = "usadata",
                   url = "mongodb://localhost")
canadadbplot <- mongo(collection = "canadaplot",
                      db = "canadadata",
                      url = "mongodb://localhost")

ukplotdb<-as.data.frame(ukdbplot$find())
usaplotdb<-as.data.frame(usadbplot$find())
canadaplotdb<-as.data.frame(canadadbplot$find())

# data visualization 
ui <- fluidPage(
  titlePanel("USA,UK,CANADA countries Sentiment Analysis"),
    mainPanel(
      tabsetPanel(type = "tab",
                  tabPanel("UK",plotOutput("pl1")),
                  tabPanel("USA",plotOutput("pl2")),
                  tabPanel("CANADA",plotOutput("pl3"))
                  
      )
    )
  )

server <- function(input, output) {
  
  output$pl1 <- renderPlot(ggplot(ukplotdb,aes(x=sentiment,y=Score))+geom_bar(aes(fill=sentiment),stat = "identity")+
                             theme(legend.position="none",text=element_text(size = 20))+
                             xlab("Sentiments")+ylab("scores")+ggtitle("Sentiments of people behind the tweets On UK"))
  output$pl2 <- renderPlot(ggplot(usaplotdb,aes(x=sentiment,y=Score))+geom_bar(aes(fill=sentiment),stat = "identity")+
                             theme(legend.position="none",text=element_text(size = 20))+
                             xlab("Sentiments")+ylab("scores")+ggtitle("Sentiments of people behind the tweets On USA"))
  output$pl3 <- renderPlot(ggplot(canadaplotdb,aes(x=sentiment,y=Score))+geom_bar(aes(fill=sentiment),stat = "identity")+
                             theme(legend.position="none",text=element_text(size = 20))+
                             xlab("Sentiments")+ylab("scores")+ggtitle("Sentiments of people behind the tweets On CANADA"))
  
}
shinyApp(ui = ui, server = server)
