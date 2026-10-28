# Sesión 5: importación de un archivo oficial Stata y armonización revisada.
# Ejecutar desde la raíz del repositorio. No descarga ni altera originales.
# La función armonizar debe implementar los .do oficiales de las tablas 8 y 9.
# Sin esos archivos no se proporciona una correspondencia de variables ficticia.

importar_brollo <- function(archivo, armonizar, verificacion,
                           salida = "data/derivados/brollo_sesion05_seleccion.rds") {
  if (!requireNamespace("haven", quietly = TRUE)) {
    stop("Instale haven para leer los datos oficiales de Stata.")
  }
  if (!is.function(armonizar)) stop("Se requiere una función de armonización revisada.")
  campos <- c("archivos_do", "variables", "filtros", "ponderaciones",
              "unidades", "normalizacion", "polinomio", "controles_geograficos")
  if (!is.list(verificacion) || !all(campos %in% names(verificacion)) ||
      !all(vapply(verificacion[campos], function(x)
        is.character(x) && length(x) > 0L && all(!is.na(x) & nzchar(x)), logical(1)))) {
    stop("Documente los scripts originales y todas las decisiones de armonización.")
  }
  if (!file.exists("_quarto.yml")) stop("Ejecute desde la raíz del libro.")
  es_absoluta <- function(x) grepl("^([A-Za-z]:|/|\\\\)", x)
  if (es_absoluta(archivo) || es_absoluta(salida)) stop("Use rutas relativas.")
  if (!file.exists(archivo)) stop("Falta el archivo oficial: ", archivo)
  origen <- normalizePath(archivo, winslash = "/", mustWork = TRUE)
  carpeta <- normalizePath("data/originales", winslash = "/", mustWork = TRUE)
  if (!startsWith(origen, paste0(carpeta, "/"))) {
    stop("El archivo debe estar dentro de data/originales/.")
  }
  if (!identical(salida, "data/derivados/brollo_sesion05_seleccion.rds")) {
    stop("El derivado debe guardarse en la ruta prevista, separado del original.")
  }
  original <- haven::read_dta(archivo)
  d <- armonizar(original)
  requeridas <- c("municipio_id", "periodo", "macroregion", "dist_poblacion",
                 "fpm_teorico", "fpm_efectivo", "college", "escolaridad", "reeleccion")
  if (!is.data.frame(d) || !all(requeridas %in% names(d))) {
    stop("La armonización no produjo la interfaz requerida por el capítulo.")
  }
  if (anyDuplicated(d[c("municipio_id", "periodo")])) {
    stop("Hay observaciones municipio-período duplicadas; revise la unidad de análisis.")
  }
  numericas <- c("dist_poblacion", "fpm_teorico", "fpm_efectivo", "college",
                "escolaridad", "reeleccion")
  if (!all(vapply(d[numericas], is.numeric, logical(1)))) stop("Revise tipos numéricos.")
  if (any(d$college < 0 | d$college > 1, na.rm = TRUE)) stop("College debe ser proporción.")
  if (any(!is.na(d$reeleccion) & !d$reeleccion %in% c(0, 1))) stop("Reelección debe ser 0/1.")
  attr(d, "procedencia") <- list(doi = "10.3886/E112657V1", archivo = archivo,
                                  md5 = unname(tools::md5sum(archivo)),
                                  verificacion = verificacion)
  dir.create(dirname(salida), recursive = TRUE, showWarnings = FALSE)
  saveRDS(d, salida)
  invisible(d)
}
