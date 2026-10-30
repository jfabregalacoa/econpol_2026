# Iniciativas de inversión del Banco Integrado de Proyectos (BIP), 2019 en adelante.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/01_descargar_bip.R cache/ datos/
#   1. Pide al portal de datos del Ministerio de Desarrollo Social la lista de archivos
#      anuales (un CSV por año presupuestario, unos 45 MB cada uno) y descarga los que
#      no estén en la caché.
#   2. Clasifica cada iniciativa por tipo de obra, usando la primera palabra del nombre
#      (el BIP nombra cada iniciativa como "proceso + objeto + lugar": "CONSTRUCCION PLAZA...",
#      "CONSERVACION AREAS VERDES...").
#   3. Escribe:
#      - bip_municipal.csv.gz: iniciativas cuyo responsable es una municipalidad.
#      - bip_panel_comuna_anio.csv: iniciativas municipales por comuna, año y tipo de obra.

suppressMessages({library(dplyr); library(readr); library(stringr); library(jsonlite)})

args   <- commandArgs(TRUE)
cache  <- if (length(args) >= 1) args[1] else "cache"
salida <- if (length(args) >= 2) args[2] else "datos"
dir.create(cache, showWarnings = FALSE, recursive = TRUE)
dir.create(salida, showWarnings = FALSE, recursive = TRUE)

# 1. Descarga -------------------------------------------------------------------
api <- "https://bid-ckan.ministeriodesarrollosocial.gob.cl/api/3/action/package_show?id=registro-de-proyectos-de-inversion"
rec <- fromJSON(api)$result$resources
rec <- rec[str_detect(rec$name, "^Iniciativas de Inversi.n \\d{4}$"), ]   # un archivo por año (no el combinado)
for (i in seq_len(nrow(rec))) {
  anio <- str_extract(rec$name[i], "\\d{4}")
  f <- file.path(cache, paste0("inversiones_", anio, ".csv"))
  completo <- file.exists(f) && !is.na(rec$size[i]) && file.size(f) == rec$size[i]
  if (completo) next
  for (intento in 1:2) {                      # a veces la descarga se corta: se reintenta una vez
    download.file(rec$url[i], f, quiet = TRUE, mode = "wb")
    if (is.na(rec$size[i]) || file.size(f) == rec$size[i]) break
  }
  Sys.sleep(2)
}

# 2. Unir y clasificar ---------------------------------------------------------
fs <- list.files(cache, pattern = "^inversiones_\\d{4}\\.csv$", full.names = TRUE)
d <- bind_rows(lapply(fs, read_delim, delim = ";", col_types = cols(.default = "c"),
                      locale = locale(encoding = "UTF-8"), progress = FALSE))

nombre <- str_squish(toupper(iconv(d$EBI_NOMBRE, from = "UTF-8", to = "ASCII//TRANSLIT")))
d$proceso <- word(nombre, 1)
d$tipo <- case_when(
  d$proceso %in% c("CONSTRUCCION", "INSTALACION")                       ~ "nueva",
  d$proceso %in% c("CONSERVACION", "MANTENCION", "MANTENIMIENTO",
                   "REPARACION")                                        ~ "conservacion",
  d$proceso %in% c("MEJORAMIENTO", "REPOSICION", "AMPLIACION", "HABILITACION",
                   "NORMALIZACION", "RESTAURACION", "RECUPERACION")      ~ "mejoramiento",
  TRUE                                                                  ~ "otro")   # estudios, adquisiciones, programas
d$espacio_publico <- str_detect(nombre, "PLAZA|PLAZOLETA|AREAS? VERDES?|PARQUE|BANDEJON|PASEO PEATONAL")
d$municipal <- str_detect(toupper(d$EBI_INS_RESPONSABLE), "MUNICIPALIDAD")
d$cut <- str_pad(d$CMN_CLAVE, 5, pad = "0")

# 3. Salidas -------------------------------------------------------------------
m <- d %>% filter(municipal) %>%
  transmute(anio = as.integer(EBI_ANO_POSTULA), codigo_bip = EBI_CODIGO, parte = EBI_PARTE,
            cut, responsable = EBI_INS_RESPONSABLE, nombre = EBI_NOMBRE, proceso, tipo, espacio_publico,
            situacion = EBI_SITUACION, etapa = EBI_ETAPA_POSTULA, fuente = EBI_FUENTES_FINAN,
            costo_total_mm = as.numeric(EBI_COSTO_TOTAL), solicitado_mm = as.numeric(EBI_SOLICITADO),
            asignado_mm = as.numeric(EBI_ASIGNADO_VIGENTE), gasto_mm = as.numeric(EBI_GASTO_VIGENTE))
write_csv(m, file.path(salida, "bip_municipal.csv.gz"))

m %>% group_by(cut, anio, tipo) %>%
  summarise(n = n(), n_nuevas = sum(situacion == "NUEVO", na.rm = TRUE),
            n_espacio_publico = sum(espacio_publico),
            costo_total_mm = sum(costo_total_mm, na.rm = TRUE), .groups = "drop") %>%
  arrange(cut, anio, tipo) %>%
  write_csv(file.path(salida, "bip_panel_comuna_anio.csv"))

cat("Iniciativas:", nrow(d), "| municipales:", nrow(m), "| comunas:", n_distinct(m$cut), "\n")
print(table(m$anio, m$tipo))
