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
        column(6, fileInput("batch_xlsx", label = list("Upload Batch (.xlsx)",
          bsButton("batch_info", label = "",
            icon = icon("info", lib = "font-awesome"),
            style = "default", size = "extra-small")
          ))),
        column(6, selectInput("input_column", "Input Column", 
          choices = c("Upload Batch first")))
      ),
      tags$hr(),
      fluidRow(
        column(4, textInput("batch_address", "IP Address", value = "172.18.227.")),
        column(4, selectInput("batch_model", "Model", choices = c("Enter IP address first"))),
      ),
      fluidRow(
        column(4, textInput("sample_size", label = list("Sample Size",
          bsButton("sample_info", label = "",
            icon = icon("info", lib = "font-awesome"),
            style = "default", size = "extra-small")
          ))),
        column(4, textInput("batch_context", "Context Window", value = "4000")),
        column(4, uiOutput("batch_word_count")),
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
      downloadButton("download_batch", "Download Run")
    ),
    column(4,
      textInput("filename_manual", "Enter file name (without extension):", value = ""),
      downloadButton("download_manual", "Download Manual Entry Template")
    ),
    
  ),
  bsPopover(
    "batch_info", "More Information", 
    content = HTML(paste(
      "Upload your database. Required formatting includes column names, and an input text column." 
    )),
    "right", trigger = "click",
    options = list(container = "body")
  ),
  bsPopover(
    "sample_info", "More Information", 
    content = HTML(paste(
      "Select the sample size for your random sample. If you are running the entire batch, leave this blank.",
      "Around ~100 examples is usually suffeceient to estimate accruacy.",
      "If the estimated accuracy is underpowered, increase the smaple size of your random sample."
    )),
    "right", trigger = "click",
    options = list(container = "body")
  )
)
