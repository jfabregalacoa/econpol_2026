# Dependencias para ejecutar el libro; no requiere renv.
paquetes <- c("dplyr", "tidyr", "purrr", "ggplot2", "plotly", "knitr", "rmarkdown")
faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltantes)) install.packages(faltantes, repos = "https://cloud.r-project.org")
faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltantes)) {
  stop("No se pudieron instalar o cargar: ", paste(faltantes, collapse = ", "))
}
