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


spotify <- read.csv('dt/songs_normalize.csv')

spotify <- spotify %>% mutate(duration_ms = duration_ms/60000) %>% rename(duration_in_min = duration_ms) 

spotify_num <- spotify %>% select_if(is.numeric)

# spotify_num <- scale(spotify_num)

spotify_kmeans <- kmeans(spotify_num, centers = 6)

spotify$cluster <- spotify_kmeans$cluster

