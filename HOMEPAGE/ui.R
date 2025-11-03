homepage_ui <-  fluidPage(
  tags$style(HTML("
      
      /* Make images responsive */
      img {
        max-width: 100%;
        height: auto;
        display: block;
        margin: 0 auto;
      }
      
      /* Style figures */
      figure {
        text-align: center;
        margin: 20px 0;
      }
      
      figcaption {
        font-style: italic;
        color: #666;
        margin-top: 8px;
      }
    ")),
  
  includeMarkdown("README.md")
)