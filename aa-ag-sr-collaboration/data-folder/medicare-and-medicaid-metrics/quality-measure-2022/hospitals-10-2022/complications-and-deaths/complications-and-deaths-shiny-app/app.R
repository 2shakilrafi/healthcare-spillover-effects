library(shiny)
library(tidyverse)
library(janitor)
library(maps)
library(ggplot2)
library(ggforce)
library(sf)

# 1. Load and clean data
df <- read_csv("complications-and-deaths-state.csv") %>%
    clean_names() %>%
    rename_with(~str_replace_all(., "number_of_hospitals_", ""), starts_with("number_of_hospitals_")) %>%
    mutate(across(c(worse, same, better, too_few), as.numeric)) %>%
    mutate(
        not_available = if_else(is.na(worse) & is.na(same) & is.na(better) & is.na(too_few), 1, 0),
        state = toupper(state)
    ) %>%
    filter(state %in% state.abb)

# 2. US states map with sf
us_states <- map_data("state") %>%
    mutate(state = toupper(region)) %>%
    left_join(tibble(state = toupper(state.name), abb = state.abb), by = "state") %>%
    filter(!is.na(abb))

state_centroids <- us_states %>%
    group_by(abb) %>%
    summarise(long = mean(range(long)), lat = mean(range(lat))) %>%
    rename(state = abb)

# 3. Aggregate percentages
donut_data <- df %>%
    group_by(state, measure_id) %>%
    summarise(
        worse = sum(worse, na.rm = TRUE),
        same = sum(same, na.rm = TRUE),
        better = sum(better, na.rm = TRUE),
        too_few = sum(too_few, na.rm = TRUE),
        not_available = sum(not_available, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    left_join(state_centroids, by = "state") %>%
    pivot_longer(cols = c(worse, same, better, too_few, not_available),
                 names_to = "category", values_to = "count") %>%
    group_by(state, measure_id) %>%
    mutate(
        total = sum(count),
        pct = 100 * count / total,
        end = 2 * pi * cumsum(pct / 100),
        start = lag(end, default = 0),
        mid = (start + end) / 2
    ) %>%
    ungroup()

# ---- UI ----
ui <- fluidPage(
    titlePanel("US Hospital Outcomes by State and Measure"),
    sidebarLayout(
        sidebarPanel(
            selectInput("metric", "Select Measure ID:", choices = unique(df$measure_id)),
            textOutput("instructions")
        ),
        mainPanel(
            plotOutput("map", click = "map_click", height = "600px"),
            plotOutput("donut", height = "400px")
        )
    )
)

# ---- SERVER ----
server <- function(input, output, session) {
    output$instructions <- renderText({
        "Click a state to view its hospital outcome breakdown as a donut chart."
    })
    
    output$map <- renderPlot({
        map_data <- us_states
        ggplot(map_data, aes(long, lat, group = group)) +
            geom_polygon(fill = "gray90", color = "white") +
            coord_map("albers", lat0 = 39, lat1 = 45) +
            theme_void() +
            labs(title = paste("US States –", input$metric))
    })
    
    output$donut <- renderPlot({
        click <- input$map_click
        if (is.null(click)) return(NULL)
        
        # Get closest state
        clicked_state <- donut_data %>%
            filter(measure_id == input$metric) %>%
            mutate(dist = sqrt((long - click$x)^2 + (lat - click$y)^2)) %>%
            slice_min(dist, n = 1) %>%
            pull(state)
        
        if (length(clicked_state) == 0) return(NULL)
        
        state_df <- donut_data %>%
            filter(state == clicked_state, measure_id == input$metric)
        
        ggplot(state_df) +
            geom_arc_bar(
                aes(
                    x0 = 0, y0 = 0, r0 = 0.3, r = 1,
                    start = start, end = end, fill = category
                ),
                color = "white", size = 0.3
            ) +
            coord_fixed() +
            theme_void() +
            labs(title = paste("Hospital Outcome Percentages –", clicked_state)) +
            scale_fill_manual(values = c(
                better = "green",
                same = "gray",
                worse = "red",
                too_few = "orange",
                not_available = "skyblue"
            ))
    })
}

# ---- RUN ----
shinyApp(ui, server)