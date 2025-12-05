library(shiny)
library(plotly)

shinyUI(
  fluidPage(
    titlePanel("2024 Local Election Results in Turkey"),
    
    # Center and widen the plot
    fluidRow(
      column(
        width = 12,
        div(
          style = "text-align:center;",
          plotlyOutput("map_plot", height = "575px")
        )
      )
    ),
    
    # Placeholder for City Results (will fill in Step 2)
    fluidRow(
      column(
        width = 12,
        div(
          style = "margin-top:0px;",
          h3("Province Election Results"),
          uiOutput("city_results")   # will remain empty for now
        )
      )
    )
  )
)
