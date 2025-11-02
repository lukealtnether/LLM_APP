json_ui <- fluidPage(
  titlePanel("JSON Schema Creator"),
  fluidRow(
    column(4,
      textInput("title", "Schema Title"),
      textInput("description", "Description"),
      
      tags$div(
        class = "form-label",
        tags$label("Schema Type"),
        tooltip(
          span(icon("circle-info", lib = "font-awesome")),
          "Object schemas extract a single row (object) of information from each unstructured text. Array schemas should be used when multiple rows (objects) could be extracted from a single unstructured text.",
          placement = "right"
        )
      ),
      selectInput("schema_type", NULL,
        choices = c("Object" = "object", "Array" = "array")
      ),
      
      tags$hr(),
      
      h4(
        tooltip(
          span("Add Properties ", icon("circle-info", lib = "font-awesome")),
          "Add the properties of the objects you want to extract. All properties should have some level of formatting. Unconstrained properties are more likely to hallucinate and are highly discouraged.",
          placement = "right"
        )
      ),
      
      textInput("prop_name", "Property Name", placeholder = "snake_case_recommended"),
      
      selectInput("prop_type", "Property Type",
        choices = c("Select a type..." = "", "string", "number", "integer")
      ),
      
      conditionalPanel(
        condition = "input['prop_type'] != ''",
        tags$div(
          class = "form-label",
          tags$label("Enumerations (one per line)"),
          tooltip(
            span(icon("circle-info", lib = "font-awesome"), style = "margin-left: 5px; cursor: help;"),
            "Enumerations are a list of possible choices. 'Left' and 'Right' would force the LLM to respond only with 'Left' or 'Right'.",
            placement = "right"
          )
        ),
        textAreaInput("enum_list", NULL, placeholder = "Enter one value per line")
      ),
      
      conditionalPanel(
        condition = "input['prop_type'] == 'string'",
        tags$div(
          class = "form-label",
          tags$label("String Format"),
          tooltip(
            span(icon("circle-info", lib = "font-awesome"), style = "margin-left: 5px; cursor: help;"),
            "If applicable, choose a natively supported string format in JSON. All LLM responses for this property will conform to the format.",
            placement = "right"
          )
        ),
        selectInput("format_type", NULL,
          choices = c(
            "None" = "",
            "date-time (2023-04-01T12:00:00Z)" = "date-time",
            "date (2023-04-01)" = "date",
            "time (14:30:00)" = "time",
            "email (user@example.com)" = "email",
            "phone number (123-456-7891)" = "phone",
            "hostname (www.example.com)" = "hostname",
            "ipv4 (192.168.1.1)" = "ipv4",
            "ipv6 (2001:0db8::1)" = "ipv6",
            "uri (https://example.com)" = "uri",
            "uuid (550e8400-e29b-41d4-a716-446655440000)" = "uuid",
            "regex (^[A-Z]{3}-\\d{4}$)" = "regex",
            "byte (U29mdHdhcmU=)" = "byte",
            "binary (01010101)" = "binary",
            "password (masked input)" = "password"
          )
        ),
        
        tags$div(
          class = "form-label",
          tags$label("Pattern (regex)"),
          tooltip(
            span(icon("circle-info", lib = "font-awesome"), style = "margin-left: 5px; cursor: help;"),
            "If applicable, create your own custom string formatting using regular expressions. Start your regular expression with ^ and end with $. To allow 'upper', 'posterior', 'upper lateral', 'mid lateral posterior' but never 'lateral upper', input ^(upper|mid|lower)? ?(medial|lateral)? ?(anterior|posterior|midline)?$. All LLM responses for this property will conform to the format.",
            placement = "right"
          )
        ),
        textInput("string_pat", NULL)
      ),
      
      conditionalPanel(
        condition = "input['prop_type'] == 'number' || input['prop_type'] == 'integer'",
        textInput("min_num", "Minimum"),
        textInput("max_num", "Maximum")
      ),
      
      checkboxInput("ob_req", "Allow Null", value = TRUE),
      
      fluidRow(
        column(4,
          actionButton("add_prop", "Add", class = "btn btn-success", width = "100%")
        ),
        column(4,
          actionButton("remove_prop", "Remove", class = "btn btn-danger", width = "100%")
        )
      )
    ),
    column(6,
      h4("Schema Preview"),
      verbatimTextOutput("json_preview"),
      tags$br(),
      textInput("filename", "Enter file name (without extension):", value = ""),
      downloadButton("download_json", "Download JSON", class = "btn btn-warning")
    )
  )
)