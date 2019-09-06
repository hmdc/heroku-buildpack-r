library(rmarkdown)
rmarkdownFiles <- list.files(path=".", pattern = "*.Rmd", recursive = TRUE, full.names=TRUE)
rmarkdownFilesLibIgnored <- rmarkdownFiles[ !grepl("packrat", rmarkdownFiles) ]
for (rmd in rmarkdownFilesLibIgnored) {
    rmarkdown::render(rmd)
}