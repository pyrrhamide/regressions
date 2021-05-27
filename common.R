library(ymlthis)
library(usethis)
library(fs)

side_by_side <- function(path1, width1, path2, width2){
  style2 <- paste0("padding-left: 1rem; width: ", width2, "%;")
  style1 <- paste0("width: ", width1, "%;")
  
  htmltools::withTags(
    div(style = "display: flex;",
          div(style = style1, 
              htmltools::img(src = path1)), 
          div(style = style2, 
              htmltools::img(src = path2))
    )
  )
}