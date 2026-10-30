# Transferencias de los municipios a terceros (registro de la Ley 19.862), 2014 en adelante.
#
# Uso (desde proyects/camila/):
#   Rscript scripts/01_descargar_transferencias_municipales.R cache/ datos/ ../../playground/datos-apoyo/sinim/sinim_panel_largo.csv
#   1. Descarga un CSV por año de decreto desde el reporte público de transferencias
#      (https://registros19862.gob.cl/reporte/transferencias), filtrando por emisor
#      "Municipalidad". Si el archivo ya está en la caché, no lo vuelve a pedir.
#   2. Une los años, clasifica cada transferencia y asigna el código de comuna (CUT)
#      del municipio que transfiere, usando el panel de SINIM.
#   3. Escribe:
#      - muni_transferencias.csv.gz: una fila por transferencia.
#      - muni_panel_comuna_mes.csv: subvenciones chicas por comuna, año y mes del decreto.

suppressMessages({library(dplyr); library(readr); library(stringr)})

args  <- commandArgs(TRUE)
cache <- if (length(args) >= 1) args[1] else "cache"
salida <- if (length(args) >= 2) args[2] else "datos"
sinim <- if (length(args) >= 3) args[3] else "../../playground/datos-apoyo/sinim/sinim_panel_largo.csv"
dir.create(cache, showWarnings = FALSE, recursive = TRUE)
dir.create(salida, showWarnings = FALSE, recursive = TRUE)

# 1. Descarga (una petición por año, con pausa) ------------------------------
anio_fin <- as.integer(format(Sys.Date(), "%Y"))
for (y in 2014:anio_fin) {
  f <- file.path(cache, sprintf("muni_%d.csv", y))
  if (file.exists(f) && y < anio_fin) next   # el año en curso se vuelve a pedir
  url <- paste0("https://registros19862.gob.cl/reporte/transferencias?",
                "trans%5Bemisora%5D%5Bclase%5D%5B0%5D=2",
                "&trans%5Bdesde%5D=", y, "-01-01&trans%5Bhasta%5D=", y, "-12-31",
                "&trans%5Bfecha%5D=d&trans%5Bejecutar%5D=&csv=1")
  download.file(url, f, quiet = TRUE, mode = "wb")
  Sys.sleep(3)
}

# 2. Unir y clasificar ---------------------------------------------------------
fs <- list.files(cache, pattern = "^muni_\\d{4}\\.csv$", full.names = TRUE)
d <- bind_rows(lapply(fs, read_delim, delim = ";", col_types = cols(.default = "c"),
                      locale = locale(encoding = "UTF-8"), progress = FALSE)) %>%
  distinct(FOLIO, .keep_all = TRUE) %>%
  mutate(monto = as.numeric(MONTO),
         fecha_decreto = as.Date(FECHA_DECRETO, "%d-%m-%Y"),
         fecha_ingreso = as.Date(FECHA_INGRESO, "%d-%m-%Y"),
         anio = as.integer(format(fecha_decreto, "%Y")),
         mes  = as.integer(format(fecha_decreto, "%m")))

# Tipo de transferencia. "subv_chica" es la medida de gasto clientelar: subvenciones
# de hasta 20 millones a organizaciones privadas (juntas de vecinos, clubes, etc.).
priv <- d$RECEPTORA_CLASE == "Institución privada"
corp <- str_detect(toupper(d$RECEPTORA_NOMBRE),
                   "CORPORACI.N MUNICIPAL|CORPORACION DE (EDUCACION|DESARROLLO SOCIAL)|BOMBEROS")
d$tipo <- case_when(
  priv & corp                ~ "corporacion_bomberos",  # educación y salud vía corporación, bomberos
  priv & d$monto <= 2e7      ~ "subv_chica",
  priv                       ~ "privado_grande",
  TRUE                       ~ "otro")                   # otros organismos públicos

# Comuna del municipio que transfiere: nombre del emisor -> CUT de SINIM
clave <- function(x) str_squish(str_remove_all(toupper(iconv(x, to = "ASCII//TRANSLIT")), "[\"'`^~]"))
arreglos <- c("TREGUACO" = "TREHUACO", "SAN VICENTE DE TAGUA TAGUA" = "SAN VICENTE",
              "PAIHUANO" = "PAIGUANO", "LA CALERA" = "CALERA", "MARCHIGUE" = "MARCHIHUE",
              "SAN FRANCISCO DE MOSTAZAL" = "MOSTAZAL")
comunas <- read_csv(sinim, col_types = cols(cut = "c", .default = "c")) %>%
  distinct(cut, comuna) %>% mutate(k = clave(comuna))
d$k <- clave(d$EMISORA_NOMBRE) %>%
  str_remove("^(I\\.? ?|ILUSTRE )?MUNICIPALIDAD (DE |DEL )?") %>% str_squish()
d$k <- ifelse(d$k %in% names(arreglos), arreglos[d$k], d$k)
d <- d %>% left_join(comunas %>% select(cut, k), by = "k")

# 3. Salidas -------------------------------------------------------------------
d %>% transmute(folio = FOLIO, anio, mes, fecha_decreto, fecha_ingreso,
                cut, emisor = EMISORA_NOMBRE, tipo, clasificacion = CLASIFICACION,
                receptor_rut = RECEPTORA_RUT, receptor = RECEPTORA_NOMBRE,
                receptor_clase = RECEPTORA_CLASE, comuna_receptor = COMUNA, monto,
                objetivo = OBJETIVO_APORTE) %>%
  write_csv(file.path(salida, "muni_transferencias.csv.gz"))

# Ojo: un mes sin filas puede ser "no hubo subvenciones" o "el municipio no reportó".
d %>% filter(!is.na(cut), tipo == "subv_chica") %>%
  group_by(cut, anio, mes) %>%
  summarise(n = n(), monto = sum(monto), .groups = "drop") %>%
  arrange(cut, anio, mes) %>%
  write_csv(file.path(salida, "muni_panel_comuna_mes.csv"))

cat("Transferencias:", nrow(d), "| municipios:", n_distinct(d$cut, na.rm = TRUE),
    "| sin CUT:", sum(is.na(d$cut)), "\n")
print(table(d$tipo))
