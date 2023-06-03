library(flexdashboard)
library(shiny)
library(shinydashboard)
library(plotly)
library(fmsb)
library(dplyr) # manipulation
library(factoextra) # cluster
library(ggiraphExtra) # cluster viz
library(ggplot2)
library(scales)
library(ggiraph)
library(glue)
library(plotly)

server <- function(input, output){
  # valuebox
  clusterInput <- reactive({
    input$clusterInput
  })
  
  output$clusterValueBox <- renderValueBox({
    valueBox(
      width = 4,
      value = input$clusterInput,
      subtitle = "Total cluster",
      icon = icon("square"),
      color = 'olive'
    )
  })
  
  output$graphcl <- renderggiraph({
    k <- input$clusterInput
    spotify_kmeans <- kmeans(spotify_num, centers = k)
    
    spotify$cluster <- spotify_kmeans$cluster
    ggRadar(spotify, mapping = aes(colours = cluster), interactive = T) 
  })
  
  output$spot_row <- DT::renderDataTable({
    spotify %>% select(-c("duration_in_min","artist","song", "explicit","year","popularity","key","mode","genre")) %>% group_by(cluster) %>% summarise_all(mean) 
  })
  
  output$trend <- renderPlotly({
    trend_s <- spotify %>% 
      filter(year >= 2000) %>% 
      filter(year < 2019) %>% 
      filter(!is.na(year)) %>%
      group_by(year = year) %>% 
      summarise(freq = n())%>% 
      ungroup() %>% 
      mutate(label = glue("Year: {year}
                      Total: {freq} total songs")) 
    
    plot1 <- ggplot(trend_s, mapping = aes(x = year, y = freq)) +
      geom_line() +
      geom_point(col = "green", aes(text = label)) +
      labs(title = 'Spotify Trends',
           x = "Year",
           y = NULL) +
      theme_minimal() +
      theme(legend.position = 'none') + theme(plot.title = element_text(face = "bold", hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
    
    
    ggplotly(plot1, tooltip = "text")
  })
  
  output$clsoo <- renderPlotly({
    clmin <- spotify %>% 
      group_by(cluster) %>% 
      summarise(total = n(), dur = mean(duration_in_min)) %>% ungroup() %>% mutate(label = glue("Cluster: {cluster}
                      Total Songs: {total}
                      Avg Duration: {comma(dur)}"))
    
    plot2 <- ggplot(clmin, aes(x = reorder(cluster, total), y = total)) + geom_col(aes(fill = total)) + geom_point(aes(col = cluster, text = label)) + labs(title = "Spotify Top Cluster", subtitle = 'Clustered by Similarity',y = 'Total Songs', x = NULL) + theme_minimal() +scale_fill_gradient(low = "black", high= "green") + theme(legend.position = 'none') + theme(plot.title = element_text(face = "bold", hjust = 0.5),
                                                                                                                                                                                                                                                                                                                                                                            plot.subtitle = element_text(hjust = 0.5))
    
    ggplotly(plot2, tooltip = "text")                                                                                                                                                                                                                                                                                                                                       
  })
  
  output$gensong <- renderPlotly({
    gen <- spotify %>% filter(genre == input$gen) %>% group_by(song) %>% 
      ungroup() %>% head() %>% mutate(label = glue("Artist : {artist}
                                                    Cluster : {cluster}
                                                   Released : {year}"))
    
    plot3 <- ggplot(gen, aes(x = popularity, y = reorder(song, popularity), text = label)) + geom_col(aes(fill = popularity)) +
      labs(title = paste("Top 6 Spotify Hits Song", input$gen, "Genres"),
           x = "Song Popularity",
           y = NULL) +
      scale_fill_gradient(low = "black", high= "green") +
      theme_minimal() +
      theme(legend.position = 'none') + theme(plot.title = element_text(face = "bold", hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))
    
    ggplotly(plot3, tooltip = "text")
  })
}
