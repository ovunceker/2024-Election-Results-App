library(shiny)
library(plotly)
library(sf)
library(readxl)
library(dplyr)
library(stringi)
library(stringr)
library(purrr)


shinyServer(function(input, output, session) {
  
  
  
  results <- read_excel("oylar .xlsx")
  results <- as.data.frame(results)
  results <- results[,-c(3,5)]
  names(results) <- c("Province", "Party", "Vote.Percentage")
  results$Vote.Percentage <- gsub("%","",results$Vote.Percentage)
  results$Vote.Percentage <- gsub(",",".",results$Vote.Percentage)
  results$Vote.Percentage <- as.numeric(results$Vote.Percentage)
  
  turkey <- st_read("tr.json")
  
  turkey <- turkey %>%
    mutate(clean_name = tolower(name),
           clean_name = stri_trans_general(clean_name, "Latin-ASCII"))
  results <- results %>%
    mutate(clean_name = tolower(Province),
           clean_name = stri_trans_general(clean_name, "Latin-ASCII"))
  turkey$clean_name <- gsub("kinkkale", "kirikkale", turkey$clean_name)
  turkey$clean_name <- gsub("zinguldak", "zonguldak", turkey$clean_name)
  turkey$clean_name <- gsub("k. maras", "kahramanmaras", turkey$clean_name)
  merged <- merge(turkey, results, by = "clean_name")
  merged$clean_name <- str_to_title(merged$clean_name)
  
  party_colors <- c(
    "CHP" = "#E60000",   # red
    "AKP" = "#FFCC00",   # yellow
    "DEM" = "#6AB547",   # green
    "MHP" = "#8B0000",   # dark red
    "İYİ" = "#0099CC",   # blue
    "BBP" = "gray80",
    "YRP" = "#800080"
  )
  
  output$map_plot <- renderPlotly({
    
    merged$VoteText <- paste0(merged$Vote.Percentage, "%")
    
    centroids <- st_centroid(merged)
    
    # Prepare hover text
    hover_text <- paste0(
      "Province: ", merged$clean_name,
      "<br>Winner: ", merged$Party,
      "<br>Vote Percentage: ", merged$VoteText
    )
    
    # Calculate the bounding box of Turkey
    bbox <- st_bbox(merged)
    
    # Add a small buffer (1% of the range) to make sure edges aren't cut off
    x_range <- bbox$xmax - bbox$xmin
    y_range <- bbox$ymax - bbox$ymin
    buffer_x <- x_range * 0.01
    buffer_y <- y_range * 0.01
    
    # Create the plot with adjusted view
    p <- plot_ly() %>%
      # polygons (no hover)
      add_sf(
        data = merged,
        split = ~Party,
        color = ~Party,
        colors = party_colors,
        hoverinfo = "skip"
      ) %>%
      # centroid markers for hover + colored tooltips
      add_markers(
        data = centroids,
        x = ~st_coordinates(centroids)[,1],
        y = ~st_coordinates(centroids)[,2],
        text = hover_text,
        hoverinfo = "text",
        marker = list(size = 1, opacity = 0),
        hoverlabel = list(
          bgcolor = ~party_colors[merged$Party],  # use party color
          bordercolor = ~party_colors[merged$Party],
          font = list(color = "white")
        )
      ) %>%
      layout(
        hovermode = "closest",
        # Minimal margins - but leave some space for legend on right
        margin = list(
          l = 0,    # left
          r = 120,  # right (space for legend)
          t = 0,   # top (for title)
          b = 0     # bottom
        ),
        # Set the plot area to fit Turkey tightly
        xaxis = list(
          scaleanchor = "y",
          scaleratio = 1,
          showgrid = FALSE,
          zeroline = FALSE,
          showticklabels = FALSE,
          showline = FALSE,
          # Add buffer to ranges
          range = c(bbox$xmin - buffer_x, bbox$xmax + buffer_x),
          fixedrange = TRUE  # Prevent zooming
        ),
        yaxis = list(
          showgrid = FALSE,
          zeroline = FALSE,
          showticklabels = FALSE,
          showline = FALSE,
          # Add buffer to ranges
          range = c(bbox$ymin - buffer_y, bbox$ymax + buffer_y),
          fixedrange = TRUE  # Prevent zooming
        ),
        # Force plot to fill available space
        autosize = TRUE,
        # Remove default plot background padding
        plot_bgcolor = 'rgba(0,0,0,0)',
        paper_bgcolor = 'rgba(0,0,0,0)',
        legend = list(
          orientation = "v",
          x = 1.05,  # Slightly more to the right
          y = 0.5,
          xanchor = "left",
          yanchor = "middle",
          bgcolor = "rgba(255,255,255,0.8)",
          bordercolor = "black",
          borderwidth = 1
        ),
        title = list(
          text = "2024 Local Election Results in Turkey",
          x = 0.5,
          y = 0.95,  # Slightly lower to avoid clipping
          xanchor = "center",
          yanchor = "top",
          font = list(size = 18)
        )
      )
    
    return(p)
  })
  
  path <- "province_votes.xlsx"
  
  sheets <- excel_sheets(path)
  
  provinces <- map(sheets, ~read_excel(path,sheet = .x))
  names(provinces) <- sheets
  
  for (name in sheets){
    provinces[[name]] <- as.data.frame(provinces[[name]])
  }
  
  for (name in sheets){
    names(provinces[[name]]) <- c("Party", "Candidate", "Votes", "Percentage")
  }
  
  for (name in sheets){
    v <- provinces[[name]]$Votes
    v <- as.numeric(v)
    frac <- abs(v - floor(v))
    to_fix <- which(frac > 1e-9)
    v_fixed <- v
    v_fixed[to_fix] <- round(v[to_fix] * 1000)
    v_fixed <- as.integer(v_fixed)
    provinces[[name]]$Votes <- v_fixed
    print(paste0(name, ": ", all(diff(v_fixed) <= 0)))
  }
  
  provinces$Ankara[1,3]<-1999281
  provinces$Ankara[2,3]<-1048076
  
  provinces$Istanbul[1,3]<-4432862
  provinces$Istanbul[2,3]<-3431588
  
  provinces$Izmir[1,3]<-1292118
  
  for (name in sheets){
    provinces[[name]]$Party<-gsub("Bağımsız","Independent",provinces[[name]]$Party)
  }
  
  for (name in sheets){
    provinces[[name]]$Party<-gsub("AK Parti","AKP",provinces[[name]]$Party)
  }
  
  for (name in sheets){
    provinces[[name]]$Party<-gsub("Yeniden Refah","YRP",provinces[[name]]$Party)
  }
  
  for (name in sheets){
    provinces[[name]]$Party<-gsub("Partisi","Party",provinces[[name]]$Party)
  }
  
  for (name in sheets){
    provinces[[name]]$Party<-gsub("Parti","Party",provinces[[name]]$Party)
  }
  
  clicked_province <- reactive({
    click <- event_data("plotly_click")
    if (is.null(click)) return(NULL)
    merged$clean_name[click$pointNumber + 1]
  })
  
  # --- Render the table for clicked province ---
  output$city_results <- renderUI({
    
    if (is.null(clicked_province())) {
      # Nothing clicked yet → show instruction
      HTML("<i>Click on a province to see the detailed results.</i>")
    } else {
      tagList(
        h3(paste("Detailed Results for", clicked_province())),
        tableOutput("results_table")
      )
    }
  })
  
  output$results_table <- renderTable({
    req(clicked_province())
    province_name <- clicked_province()
    
    # Access the table directly from provinces list
    df <- provinces[[province_name]]
    
  }, striped = TRUE, hover = TRUE)
  
})
