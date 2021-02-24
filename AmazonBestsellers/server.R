library(shiny)
library(shinydashboard)

df <- read.csv(file="/Users/emilywang/Documents/NYCDSA/Shiny/AmazonBestsellers/bestsellers.csv")

#DATA CLEANING
#Fixing a capitalization inconsistency that separates the below into 2 separate titles
df <- df %>% mutate(Name = case_when(
  Name == "The 5 Love Languages: The Secret to Love That Lasts" ~ "The 5 Love Languages: The Secret to Love that Lasts", TRUE ~ Name))
#Fixing a spacing inconsistency with author .K. Rowling
df<-df %>% mutate(Author= case_when(
  Author=="J. K. Rowling" ~ "J.K. Rowling", TRUE ~ Author))

shinyServer(function(input, output) {

#First tab output
  output$ratingbox <- renderValueBox({
    valueBox(round(mean(df$User.Rating), digits=2), "Average Customer Rating", icon=icon("star"), color = "aqua")
  })  
  output$reviewbox <-renderValueBox({
    valueBox(round(mean(df$Reviews), digits=0), "Average # Reviews", icon=icon("comments"), color = "teal")
  }) 
  output$pricebox <-renderValueBox({
    valueBox(mean(df$Price), "Average Book Price($)", icon=icon("file-invoice-dollar"), color = "olive")
  }) 
  output$value <- renderPrint({ input$select }) 
  
#Second tab output
    output$top_books <- renderPlot(
      df %>% group_by(Name) %>% summarise(Count=n()) %>% filter(Count>= input$nameslide) %>% 
            ggplot(aes(y=reorder(Name, Count), x=Count))+geom_col(fill="darkred", width=0.7)+labs(y="Title")+
            ggtitle("Most Popular Titles")+theme(axis.text.y = element_text(size=12))
      )
    
    output$top_authors <- renderPlot(
      df %>% group_by(Author) %>% summarise(Count=n())%>% filter(Count>= input$authorslide) %>% 
      ggplot(aes(y=reorder(Author, Count), x=Count)) + geom_col(fill="darkblue", width=0.7) +labs(y="Author")+
      ggtitle("Most Popular Authors")+theme(axis.text.y = element_text(size=12))
    )
#Third tab output
    output$genreplot <- renderPlot(
      df %>% group_by(Genre) %>% summarise(n=n()) %>% mutate(ratio=n/sum(n)) %>% ggplot(aes(x="", y=n, fill=Genre))+
        geom_bar(position="dodge", stat="identity")+ geom_text(aes(label=n), position=position_dodge(width=0.9), vjust=-0.25)+
        scale_fill_brewer(palette="Paired")+ggtitle("Bestseller Genres")+labs(y="Total Count"))
    
    output$genreyear <- renderPlot(
      df %>% group_by(Genre, Year) %>% summarise(n=n()) %>% ggplot(aes(x=Year, y=n, color=Genre))+scale_x_continuous(breaks=seq(2009, 2019, 2))+
        geom_line()+geom_point()+ggtitle("Comparing Genre by Year")+scale_color_brewer(palette="Paired")+labs(y="Count")
    )
      
#Fourth tab output   
  output$review_plot <- renderPlot(
    df %>% filter(Genre== input$revgenre) %>%
      ggplot(mapping=aes(x=User.Rating)) + geom_bar(stat = "count", fill="darkblue") + ggtitle("User Ratings by Genre (2009-2019)")+labs(x="User Rating")
  )
  
  output$reviewYr <- renderPlot(
    df %>% group_by(Year, Genre)%>% summarise(avg.rating=mean(User.Rating))%>%filter(Genre==input$revgenre) %>% 
      ggplot(aes(x=Year, y=avg.rating)) +
      geom_line()+geom_point()+labs(y="Rating") +ggtitle("Average User Rating by Year")+ scale_x_continuous(breaks=seq(2009, 2019, 2))
  )
  
#Fifth tab output: plotly :-)
  output$priceYr <- renderPlotly(ggplotly(
    df %>% filter(Genre==input$pricegenre)%>% group_by(Year) %>% summarise(avg.price=mean(Price)) %>% 
        ggplot(aes(x=Year, y=avg.price))+geom_line()+geom_point()+labs(y="Price")+ggtitle(
          "Average Price by Year")+scale_x_continuous(breaks=seq(2009, 2019, 2)))
  )
  
  output$priceplot <- renderPlotly(
    ggplotly (
      df %>% filter(Genre==input$pricegenre) %>% ggplot(
        aes(group=Year, x=Year, y=Price, fill=Year, name=Name))+geom_boxplot()+scale_x_continuous(
        breaks=seq(2009, 2019, 2))+ggtitle("Price Distribution by Year")+theme(legend.position = "none"))
  )
})