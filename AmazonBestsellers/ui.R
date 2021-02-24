library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
df <- read.csv(file="/Users/emilywang/Documents/NYCDSA/Shiny/AmazonBestsellers/bestsellers.csv")

shinyUI(
    dashboardPage(skin="yellow",

        dashboardHeader(title="Bestselling Books Analysis"),
        
        dashboardSidebar(
            sidebarMenu(
            menuItem("Introduction", tabName="intro", icon = icon("amazon")),
            menuItem("Top Performers", tabName="top", icon=icon("award")),
            menuItem("Genre Breakdown", tabName="genre", icon=icon("book")),
            menuItem("User Ratings", tabName="reviews", icon=icon("star", lib="glyphicon")),
            menuItem("Price Analysis", tabName="price", icon=icon("dollar-sign"))
        )),

dashboardBody(

    tabItems(
        # First tab content- Intro
        tabItem(tabName = "intro",
                fluidPage(HTML('<center><img src="Anne-Logo_Black.png" height="120"></center>')),
                fluidRow(
                    valueBoxOutput("ratingbox"),
                    valueBoxOutput("reviewbox"),
                    valueBoxOutput("pricebox")),
              
            fluidRow(h3(strong("Questions to Explore:")),box(width =12, p(
                "- Which books and authors are the most popular on Amazon, appearing most frequently on the bestseller list?
                (As a reader, this is very interesting and can be a great source for finding what to read next.)"),
                p("- Are there more nonfiction or fiction books that become bestsellers? Does one genre consistently outsell the other every year?"),
                p("- Amazon has a reputation for its robust product ratings and reviews.
                Are all bestsellers rated very highly, and are there any patterns or trends in the reviews?"),
                p("- Can we glean any additional insight from evaluating book prices?")
            )),
                
                 p("Analysis is based on a Kaggle dataset of the top 50 bestselling books on Amazon from 2009-2019."),
                  (HTML('<a href="https://www.kaggle.com/sootersaalu/amazon-top-50-bestselling-books-2009-2019" target="_blank">Link to dataset</a>'))),
        
        # Second tab content- top authors and titles
        tabItem(tabName = "top",
                fluidPage(
                    p("  These 'top performers' appear in the dataset most frequently, which indicates that they made the Amazon Bestseller list multiple times within the 10-year span.
                       Jeff Kinney is the most popular author. His 12 appearances in the dataset indicate he's had multiple bestsellers within the same year."),
                    plotOutput("top_authors", height = 600),
            
                    sliderInput("authorslide", "Number of bestsellers per author", min=3, max=12, value=8, round=TRUE)),
                
                fluidPage(plotOutput("top_books", height = 600),
                    sliderInput("nameslide", "Number of years on bestseller list", min=3, max=10, value=6, round=TRUE)),
                
                p("  Further research can be done to compare the yearly rankings of these titles and authors if the data were made available. This is a limitation in the Kaggle dataset.")
                    ),
        
        #Third tab content- Genre
        tabItem(tabName="genre",
                box(fluidPage(
                    plotOutput("genreplot", height = 300))),
                box(p("56% of the books in the total dataset are classified as nonfiction, and 44% are fiction."),
                    p("Interestingly, nonfiction books outsold fiction in every year except 2014.
                       This anolmalous year was followed in 2015 by the largest gap in genre sales,
                      when nonfiction books came back strong over fiction.")),
                box(width=12, fluidPage(
                    plotOutput("genreyear", height=350)
                ))
                ),
        
        # Fourth tab content- Reviews
        tabItem(tabName = "reviews",
                fluidRow(
                  
                    box(plotOutput("review_plot", height = 300)),
                    
                    box(selectizeInput(inputId = "revgenre",
                                       label = "Genre",
                                       choices = c(unique(df$Genre))
                                       ))
                    ),
                fluidRow(
                    box(plotOutput("reviewYr", height = 300)),
                    box(p("Unsurprisingly, both nonfiction and fiction bestsellers tend to be rated very highly by users, with an overall average score of 4.62 stars.
                           This average is showing a slight upward trend although it has stayed consistently within two tenths of a point
                           for nonfiction titles and three tenths for fiction.")),
                    box(p("The dataset is somewhat limited by having only two genres.
                          Further analysis can be done after sorting books into more detailed genres, e.g., Children's, Mystery, Biography, etc.
                          to determine whether users have a 'favorite' category that tends rate higher."))
                )),
        #Fifth tab content- Pricing
        tabItem(tabName = "price",
                fluidRow(
                    box(plotlyOutput("priceYr", height=300)),
                    box(selectizeInput(inputId = "pricegenre",
                                       label = "Genre",
                                       choices = c(unique(df$Genre))
                    )),
                    
                    box(p("Overall, bestseller book prices on Amazon are trending downwards for  both genres.
                           Note that the dataset does not account for any of Amazon's price fluctuations(e.g., preorder promotions, Black Friday sales, etc), which could have significantly impacted sales."))
                ),
                fluidRow(
                    box(plotlyOutput("priceplot", height=300)),
                    box(p("While the majority of bestselling books seem to be priced in the $10-15 range, a wide range of pricing is represented in the dataset.
                          A handful of titles show a price of zero, which means Amazon likely offers a digital version for free.
                          At the same time, a reference book by the American Psychiatric Association is priced at $105, and the Twilight Saga Collection, priced  at $82, is actually a book bundle."))
                ))
        )
    
)))
