library(flexdashboard)
library(shiny)
library(shinydashboard)
library(plotly)
library(fmsb)
library(dplyr) # manipulation
library(factoextra) # cluster
library(ggiraphExtra) # cluster viz
library(DT)
library(ggplot2)
library(scales)
library(ggiraph)
library(glue)
library(plotly)


ui <- fluidPage(
  dashboardPage(
    skin = "green",
    dashboardHeader(
      title = "Spotify Top Hits"
    ),
    dashboardSidebar(
      sidebarMenu(
        menuItem(text = "About Project", tabName = "info", icon = icon("info")),
        menuItem(text = "  Cluster", tabName = "clust", icon = icon("vector-square")),
        menuItem(text = "  Further Analysis", tabName = "ovr", icon = icon("line-chart")),
        menuItem(text = "  Source Code", tabName = "dataset", icon = icon("code"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = 'info',
                box(
                  width = 12,
                  h2(strong("Spotify Songs Analysis Project")),
                  HTML("<h6>Build and modified by <a href='https://github.com/rahmarania'>Rahma Fairuz Rania</a>J0303201065</h6>"),
                  hr(),
                  p("Shiny Dashboard is platform to build a dashboard and we can customize it. This project is builded for fulfill the pre-internship requirements. I am using k-means method to do clustering spotify top songs from 2000 to 2019. Cluster helps determine how well various cluster fit into our data."),
                  p('Clustering algorithm designed to grouping data based on their similarity, for example in this project, aspects like danceability, tempo, etc. K-means is unsupervised learning (means data without label) can be used to explore a dataset visually.'),
                  p('Visualization in this dashboard including graph radar to see how each aspects fit in each cluster, bar plot to see the category of songs with their numeric stats, and provided source code so people can use this dashboard as their study references.'),
                  p(strong("Some references and information that i use is below : ")),
                  p("1. Algoritma Data Science Bootcamp Materials"),
                  HTML("<p>2. <a href='https://rpubs.com/rahmarania/UL-KMeans'>K-means Spotify Clustering</a></p>"),
                  HTML("<p>3. <a href='https://kdestasio.shinyapps.io/fpr_final_project/'>Pokemon Clustering Projects</a></p>"),
                  HTML("<p>4. <a href='https://rahmarania.shinyapps.io/Anime_Dashboard/'>Anime Dashboard Projects</a></p>"),
                )
        ),
        tabItem(tabName = 'clust',
                fluidRow(
                  valueBox(width = 4,
                           value = n_distinct(spotify$song),
                           subtitle = "Total Songs",
                           icon = icon("music"),
                           color = 'red'),
                  valueBox(width = 4,
                           value= n_distinct(spotify$artist),
                           subtitle = "Total Artists Contributed",
                           icon = icon("person"),
                           color = 'light-blue'),
                  valueBoxOutput(outputId = "clusterValueBox")
                  #valueBox(width = 4,
                  #         value= n_distinct(spotify$cluster),
                  #         subtitle = "Total cluster",
                  #         icon = icon("square"),
                  #         color = 'olive'),
                ),
                box(
                  width = 5,
                  height = 565,
                  ggiraphOutput('graphcl')
                ),
                box(
                  width = 7,
                  sliderInput(inputId = "clusterInput",
                              label = "Total Cluster",
                              min = 1,
                              max = 6,
                              value = 4)
                ),
                box(width = 7,
                    plotlyOutput(outputId = "clsoo")
                ),
                box(
                  width = 12,
                  DT::dataTableOutput('spot_row')
                ),
        ),
        tabItem(tabName = 'ovr',
                fluidRow(
                  box(width = 12,
                      plotlyOutput(outputId = "trend"))
                ),
                fluidRow(
                  box(
                    width = 12,
                    selectInput(inputId = 'gen',
                                label = 'Choose Song Genre',
                                choices = unique(spotify$genre)
                    )
                  )
                ),
                fluidRow(
                  box(width = 12,
                      plotlyOutput(outputId = "gensong"))
                )
        ),
        tabItem(tabName = 'dataset',
                box(width = 12,
                h4(strong("Spotify Songs Analysis Project Code")),
                hr(),
                p("Your advice for my project can be sent to rahfairuzran@gmail.com"),
                HTML("<p>The original dataset can be found <a href='https://www.kaggle.com/datasets/paradisejoy/top-hits-spotify-from-20002019'>here</a></p>"),
                p("Spotify is application for listening music over the world. We focused on which groups all of hits song was clustered, show the trend over the time, show characteristic of each cluster, and see the list of the song each genres."),
                br(),
                h6(strong("Data Preparation")),
                p("Import all the library we need"),
                HTML("<code>library(flexdashboard) <br>
                            library(shiny) <br>
                            library(shinydashboard) <br>
                            library(plotly) <br>
                            library(fmsb) <br>
                            library(dplyr) <br>
                            library(factoextra) <br>
                            library(ggiraphExtra) <br>
                            library(DT) <br>
                            library(ggplot2) <br>
                            library(scales) <br>
                            library(ggiraph) <br>
                            library(glue) <br>
                            library(plotly)</code>"),
                br(),
                br(),
                p("Import Data"),
                p("Put .csv file in the same folder as our project. Do importing data and save it in the object spotify."),
                p(code("spotify <- read.csv('dt/songs_normalize.csv')")),
                br(),
                h6(strong("Data Wrangling")),
                p("Change duration from milisecond into minutes"),
                p(code("spotify <- spotify %>% mutate(duration_ms = duration_ms/60000) %>% rename(duration_in_min = duration_ms)")),
                br(),
                p("Select numeric column because K-means clustering operates on continuous numerical data such uses distance metrics, example Euclidean distance, to measure the dissimilarity between data points."),
                p(code("spotify_num <- spotify %>% select_if(is.numeric)")),
                br(),
                h6(strong("Clustering")),
                p("Use kmeans function with k value is 6. You can use k value based on optimum k in elbow method."),
                p(code("spotify_kmeans <- kmeans(spotify_num, centers = 6)")),
                br(),
                p("Put cluster into new column in spotify. Name the new column cluster. You can see which cluster does the song included"),
                p(code("spotify$cluster <- spotify_kmeans$cluster")),
                HTML("<p>You can see how shinyapps was developed, the code was in my <a href='https://github.com/rahmarania'>github<a></p>")
              )
            )
        
      )
    )
  )
)
