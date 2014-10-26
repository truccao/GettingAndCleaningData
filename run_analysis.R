library(knitr)
library(markdown)
# change the current working directory where this R script is located before executing it.
setwd("~/coursera/datacleanup")
knit("run_analysis.Rmd", encoding="ISO8859-1")
markdownToHTML("run_analysis.md", "run_analysis.html")