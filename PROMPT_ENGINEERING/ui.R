prompt_ui <- fluidPage(
  useShinyjs(),
  titlePanel("Prompt Engineering"),
  tags$hr(),
  fluidRow(
    column(
      width = 6,
      fluidRow(
        column(6, fileInput("json_file", "Upload JSON Schema (.json)")),
        column(6, uiOutput("example_file_ui"))
      ),
      tags$hr(),
      fluidRow(
        column(
          4,
          tags$div(
            class = "form-label",
            tags$label("ID Column"),
            tooltip(
              span(icon("circle-info", lib = "font-awesome")),
              "Only applicable for array schema. For analysis, within each example, objects must be compared by an id column. Objects will otherwise be compared by row order - which may differ from the ground truth vs LLM output.",
              placement = "right"
            )
          ),
          selectInput("id_column", NULL, choices = "", selected = "")
        ),
        column(
          4,
          tags$div(
            class = "form-label",
            tags$label("Context window"),
            tooltip(
              span(icon("circle-info", lib = "font-awesome")),
              "Context window is the working memory of the LLM. Each query consists of a prompt + schema + example. A token is the smallest language unit the LLM understands. An estimated token count is given based on prompt word count and longest example, with ~0.75 tokens/word. Context windows are commonly rounded to the thousands. Context windows that are too small will truncate the example/prompt. Context windows that are too large can lead to inefficient LLM response times.",
              placement = "right"
            )
          ),
          textInput("llm_context", NULL, value = "4000")
        ),
        column(2, uiOutput("word_count_info"))
      ),
      fluidRow(
        column(3, textInput("llm_address", "IP Address", value = "172.18.227.86")),
        column(5, selectInput("llm_model", "Model", choices = c("Need to specify IP address first")))
      )
    ),
    
    column(
      width = 6,
      fluidRow(  
        column(
          width = 6,
          h4(
            tooltip(
              span("Overall Statistics ", icon("circle-info", lib = "font-awesome")),
              "Basic overall statistics evaluating the prompt. Objects refer to schema objects and can be thought of as rows in the database. Hallucinated objects refer to objects in the LLM response not present in the ground truth. Omissions are the opposite. Accuracy is defined by the formula (True LLM Output Values) / (All LLM Output Values) and is a representation of how correct the output is - including empty values. Jaccard Similarity ignores all empty values, then defined by (True LLM Output values) / (All Unique Values in LLM Output + Ground Truth) and represents the similarity between two datasets. Hallucinated and Omitted Objects count as a false in every property for overall metrics. However, for the variable metrics to the right, only shared objects are factored to truly assess each property.",
              placement = "right"
            )
          ),
          tableOutput("obs_acc"),
          plotOutput("venn_plot", height = "200px")
        ),
        column(
          width = 6,
          h4(
            tooltip(
              span("Variable Statistics ", icon("circle-info", lib = "font-awesome")),
              "Stats are given for each object property. Formulas are the same as for the total statistics. However, only shared objects are factored to give a better representation of each property description.",
              placement = "right"
            )
          ),
          tableOutput("prop_acc")
        )
      )  
    )
  ),
  
  tags$hr(),
  
  fluidRow(
    column(
      width = 4,
      h4("Prompt"),
      uiOutput("dynamic_prompt_inputs"),
      actionButton("submit_query", "Submit", class = "btn btn-success")
    ),
    column(
      width = 5,
      h4("Example"),
      verbatimTextOutput("example_check"),
      fluidRow(
        column(6, actionButton("previous_button", label = NULL, icon = icon("arrow-left"), style = "width: 100%;")),
        column(6, actionButton("next_button", label = NULL, icon = icon("arrow-right"), style = "width: 100%;"))
      )
    ),
    column(
      width = 3,
      h4("Differences"),
      tableOutput("differences_df"),
      verbatimTextOutput("omissssion_ex"),
      verbatimTextOutput("hallucinations_ex"),
      h4("LLM Output"),
      tableOutput("llm_output"),
      h4("Ground Truth"),
      tableOutput("key_output")
    )
  ),
  
  tags$hr(),
  
  textInput("filename_prompt", "Enter file name (without extension):", value = ""),
  downloadButton("download_prompt", "Download prompt")
)