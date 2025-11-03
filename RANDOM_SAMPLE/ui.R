random_ui <- fluidPage(
  useShinyjs(),
  titlePanel("Run a Sample or Entire Batch"),
  tags$hr(),
  fluidRow(
    column(6,
      fluidRow(
        column(6, fileInput("batch_json", "Upload Schema (.json)")),
        column(6, fileInput("batch_prompt", "Upload Prompt (.txt)"))
      ),
      fluidRow(
        column(6,
          tags$div(
            class = "form-label",
            tags$label("Upload Batch (.xlsx)"),
            tooltip(
              span(icon("circle-info", lib = "font-awesome")),
              "Upload your database. Required formatting includes column names, and an input text column.",
              placement = "right"
            )
          ),
          fileInput("batch_xlsx", NULL)
        ),
        column(6, selectInput("input_column", "Input Column", 
          choices = c("Upload Batch first")))
      ),
      tags$hr(),
      fluidRow(
        column(4, textInput("batch_address", "IP Address", value = "172.18.227.")),
        column(4, selectInput("batch_model", "Model", choices = c("Enter IP address first")))
      ),
      fluidRow(
        column(4,
          tags$div(
            class = "form-label",
            tags$label("Sample Size"),
            tooltip(
              span(icon("circle-info", lib = "font-awesome")),
              "Select the sample size for your random sample. If you are running the entire batch, leave this blank. Around ~100 examples is usually sufficient to estimate accuracy. If the estimated accuracy is underpowered, increase the sample size of your random sample.",
              placement = "right"
            )
          ),
          textInput("sample_size", NULL)
        ),
        column(4, textInput("batch_context", "Context Window", value = "4000")),
        column(4, uiOutput("batch_word_count"))
      ),
      actionButton("submit_batch", "Submit", class = "btn btn-success")
    ),
    column(6, 
      h4("Validation instructions"),
      uiOutput("validation_instructions")
    )
  ),
  tags$hr(),
  fluidRow(
    column(4,
      textInput("filename_batch", "Enter file name (without extension):", value = ""),
      downloadButton("download_batch", "Download Run", class = "btn btn-warning")
    ),
    column(4,
      textInput("filename_manual", "Enter file name (without extension):", value = ""),
      downloadButton("download_manual", "Download Template", class = "btn btn-warning")
    )
  )
)