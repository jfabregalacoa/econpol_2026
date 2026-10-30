# Transferencias de los gobiernos regionales (registro de la Ley 19.862), 2014 en adelante.
#
# Uso (desde proyects/abraham/):
#   Rscript scripts/01_descargar_transferencias.R cache/ datos/ ../../playground/datos-apoyo/sinim/sinim_panel_largo.csv
#   1. Descarga un CSV por año de decreto desde el reporte público de transferencias
#      (https://registros19862.gob.cl/reporte/transferencias), filtrando por emisor
#      "Gobierno regional". Si el archivo ya está en la caché, no lo vuelve a pedir.
#   2. Une los años, clasifica cada transferencia en un instrumento y asigna el código
#      de comuna (CUT) con el panel de SINIM.
#   3. Escribe gore_transferencias.csv.gz (una fila por transferencia) y
#      gore_panel_comuna_anio.csv (comuna x año de decreto x instrumento).

suppressMessages({library(dplyr); library(readr); library(stringr); library(tidyr)})

args  <- commandArgs(TRUE)
cache <- args[1]; salida <- args[2]
sinim <- if (length(args) >= 3) args[3] else "../../playground/datos-apoyo/sinim/sinim_panel_largo.csv"
dir.create(cache, showWarnings = FALSE, recursive = TRUE)
dir.create(salida, showWarnings = FALSE, recursive = TRUE)

# 1. Descarga (una petición por año, con pausa) ------------------------------
anio_fin <- as.integer(format(Sys.Date(), "%Y"))
for (y in 2014:anio_fin) {
  f <- file.path(cache, sprintf("gore_%d.csv", y))
  if (file.exists(f) && y < anio_fin) next   # el año en curso se vuelve a pedir
  url <- paste0("https://registros19862.gob.cl/reporte/transferencias?",
                "trans%5Bemisora%5D%5Bclase%5D%5B0%5D=7",
                "&trans%5Bdesde%5D=", y, "-01-01&trans%5Bhasta%5D=", y, "-12-31",
                "&trans%5Bfecha%5D=d&trans%5Bejecutar%5D=&csv=1")
  download.file(url, f, quiet = TRUE, mode = "wb")
  Sys.sleep(3)
}

# 2. Unir y clasificar ---------------------------------------------------------
fs <- list.files(cache, pattern = "^gore_\\d{4}\\.csv$", full.names = TRUE)
d <- bind_rows(lapply(fs, read_delim, delim = ";", col_types = cols(.default = "c"),
                      locale = locale(encoding = "UTF-8"), progress = FALSE)) %>%
  distinct(FOLIO, .keep_all = TRUE) %>%
  mutate(monto = as.numeric(MONTO),
         fecha_decreto = as.Date(FECHA_DECRETO, "%d-%m-%Y"),
         fecha_ingreso = as.Date(FECHA_INGRESO, "%d-%m-%Y"),
         anio = as.integer(format(fecha_decreto, "%Y")))

n <- toupper(d$EMISORA_NOMBRE)
d$gore <- case_when(
  str_detect(n, "ARICA") ~ "15", str_detect(n, "TARAPAC") ~ "01", str_detect(n, "ANTOFAGASTA") ~ "02",
  str_detect(n, "ATACAMA") ~ "03", str_detect(n, "COQUIMBO") ~ "04", str_detect(n, "VALPARA") ~ "05",
  str_detect(n, "METROPOLITANO") ~ "13", str_detect(n, "OHIGGINS|VI REGION") ~ "06",
  str_detect(n, "VII REGION") ~ "07", str_detect(n, "UBLE") ~ "16", str_detect(n, "BIO BIO") ~ "08",
  str_detect(n, "ARAUCAN") ~ "09", str_detect(n, "LOS R") ~ "14", str_detect(n, "LOS LAGOS") ~ "10",
  str_detect(n, "AYSEN") ~ "11", str_detect(n, "MAGALLANES") ~ "12", TRUE ~ NA_character_)

priv    <- d$RECEPTORA_CLASE == "Institución privada"
capital <- str_detect(d$CLASIFICACION, "capital")
d$instrumento <- case_when(
  priv & !capital & d$monto <= 5e7 ~ "subv_org",        # el 8 %: actividades de organizaciones
  priv & !capital                  ~ "conv_grande",     # bomberos, corporaciones, universidades
  d$RECEPTORA_CLASE == "Municipalidad" ~ "muni",        # FRIL y otras obras chicas
  TRUE ~ "otro")

# Comunas: nombre del registro -> CUT de SINIM
clave <- function(x) str_squish(str_remove_all(toupper(iconv(x, to = "ASCII//TRANSLIT")), "[\"'`^~]"))
arreglos <- c("TREGUACO" = "TREHUACO", "SAN VICENTE DE TAGUA TAGUA" = "SAN VICENTE",
              "SAN JAVIER DE LONCOMILLA" = "SAN JAVIER", "PAIHUANO" = "PAIGUANO",
              "LA CALERA" = "CALERA", "MARCHIGUE" = "MARCHIHUE",
              "SAN FRANCISCO DE MOSTAZAL" = "MOSTAZAL", "RINCONADA DE LOS ANDES" = "RINCONADA")
comunas <- read_csv(sinim, col_types = cols(cut = "c", .default = "c")) %>%
  distinct(cut, comuna) %>% mutate(k = clave(comuna))
d$k <- clave(d$COMUNA); d$k <- ifelse(d$k %in% names(arreglos), arreglos[d$k], d$k)
d <- d %>% left_join(comunas %>% select(cut, k), by = "k") %>%
  mutate(misma_region = substr(cut, 1, 2) == gore)

# 3. Salidas -------------------------------------------------------------------
d %>% transmute(folio = FOLIO, anio, fecha_decreto, fecha_ingreso, periodo = PERIODO,
                gore, emisor = EMISORA_NOMBRE, instrumento, clasificacion = CLASIFICACION,
                receptor_rut = RECEPTORA_RUT, receptor = RECEPTORA_NOMBRE, receptor_clase = RECEPTORA_CLASE,
                comuna_registro = COMUNA, cut, misma_region, monto,
                objetivo = OBJETIVO_APORTE, marco_legal = MARCO_LEGAL) %>%
  write_csv(file.path(salida, "gore_transferencias.csv.gz"))

d %>% filter(!is.na(cut), misma_region, instrumento %in% c("subv_org", "muni")) %>%
  group_by(cut, anio, instrumento) %>%
  summarise(n = n(), monto = sum(monto), .groups = "drop") %>%
  arrange(cut, anio, instrumento) %>%
  write_csv(file.path(salida, "gore_panel_comuna_anio.csv"))

cat("Transferencias:", nrow(d), "| sin CUT:", sum(is.na(d$cut)),
    "| fuera de la región emisora:", sum(!d$misma_region, na.rm = TRUE), "\n")
