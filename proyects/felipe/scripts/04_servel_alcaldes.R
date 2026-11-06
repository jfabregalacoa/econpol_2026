# Elecciones de alcalde 2012, 2016, 2021 y 2024 (Servel): candidatos y resumen por comuna.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/04_servel_alcaldes.R fuentes/servel cache/servel datos/ datos/sinim_felipe.csv
#
#   1. Descomprime los archivos del Servel ("20XX_..._Alcaldes_Datos_Eleccion.rar/.zip", guardados en
#      fuentes/servel/) y lee la hoja "Votación por comuna": una fila por candidato y comuna,
#      con el electo marcado en la columna Cargo.
#   2. Asigna el código de comuna (CUT) con los nombres de SINIM.
#   3. Sigue a cada alcalde entre elecciones por comuna + apellidos + al menos un nombre de pila en
#      común (el Servel no siempre registra todos los nombres) y calcula si el alcalde en ejercicio repostula, cuántos
#      períodos seguidos lleva el electo y quién quedó impedido de repostular en 2024 (Ley 21.238:
#      a lo más dos reelecciones seguidas; electo en 2012, 2016 y 2021).
#   4. Escribe:
#      - servel_alcaldes_candidatos.csv: una fila por candidato, comuna y elección.
#      - servel_alcaldes_comuna.csv: una fila por comuna y elección.
#
# Limitaciones: no incluye 2008, así que los períodos seguidos de quien ganó en 2012 parten en 1
# (censurados) y no se sabe si en 2012 había un alcalde en ejercicio repostulando. El cruce por
# nombres puede confundir familiares con los mismos apellidos y primer nombre; revisar los casos
# que imprime el script.

suppressMessages({library(dplyr); library(readr); library(readxl); library(stringi); library(tidyr)})

args    <- commandArgs(TRUE)
origen  <- if (length(args) >= 1) args[1] else "fuentes/servel"
cache   <- if (length(args) >= 2) args[2] else "cache/servel"
salida  <- if (length(args) >= 3) args[3] else "datos"
sinim   <- if (length(args) >= 4) args[4] else "datos/sinim_felipe.csv"
dir.create(cache, showWarnings = FALSE, recursive = TRUE)
dir.create(salida, showWarnings = FALSE, recursive = TRUE)

anios <- c(2012, 2016, 2021, 2024)
norm  <- function(s) toupper(trimws(gsub("\\s+", " ", stri_trans_general(s, "Latin-ASCII"))))

# 1. Descomprimir y leer --------------------------------------------------------
# El tar de Windows (bsdtar) abre .rar y .zip; el de Git Bash no abre .rar.
tar <- if (file.exists("C:/Windows/System32/tar.exe")) "C:/Windows/System32/tar.exe" else "tar"

leer <- function(y) {
  dir_y <- file.path(cache, y)
  xlsx  <- list.files(dir_y, pattern = "\\.xlsx$", full.names = TRUE)
  if (length(xlsx) == 0) {
    comp <- list.files(origen, pattern = paste0("^", y, "_.*Alcaldes.*\\.(rar|zip)$"), full.names = TRUE)
    if (length(comp) == 0) stop("No encuentro el archivo del Servel para ", y, " en ", origen)
    dir.create(dir_y, showWarnings = FALSE)
    system2(tar, c("-xf", shQuote(comp[1]), "-C", shQuote(dir_y)))
    xlsx <- list.files(dir_y, pattern = "\\.xlsx$", full.names = TRUE)
  }
  x <- suppressMessages(read_excel(xlsx[1], sheet = "Votación por comuna", col_names = FALSE,
                                   col_types = "text"))
  h <- which(apply(x, 1, function(r) any(r %in% "Comuna")))[1]   # fila de encabezados
  names(x) <- as.character(unlist(x[h, ]))
  x[-(1:h), ] %>%
    filter(!is.na(Comuna), !is.na(Nombres)) %>%
    transmute(anio = y, comuna_servel = Comuna, region = `Nro.Región`, pacto = Pacto, partido = Partido,
              nombres = norm(Nombres), apellido1 = norm(`Primer apellido`),
              apellido2 = norm(coalesce(`Segundo apellido`, "")),
              votos = as.numeric(Votos), electo = !is.na(Cargo))
}
cand <- bind_rows(lapply(anios, leer))

# 2. Código de comuna -------------------------------------------------------------
clave <- function(s) gsub("[^A-Z]", "", norm(sub("\\(.*\\)", "", s)))   # sin tildes, espacios ni paréntesis
cuts <- read_csv(sinim, col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  distinct(cut, comuna) %>% mutate(k = clave(comuna)) %>% distinct(k, .keep_all = TRUE)
# Nombres del Servel que no calzan con SINIM (agregar aquí si aparecen nuevos). Antártica no está en
# SINIM y queda sin CUT.
manual <- c(PAIHUANO = "PAIGUANO", LLAYLLAY = "LLAILLAY", MARCHIGUE = "MARCHIHUE")
cand <- cand %>%
  mutate(k = clave(comuna_servel), k = ifelse(k %in% names(manual), manual[k], k)) %>%
  left_join(select(cuts, k, cut, comuna = comuna), by = "k") %>% select(-k)
sin_cut <- cand %>% filter(is.na(cut)) %>% distinct(comuna_servel)
if (nrow(sin_cut) > 0) { cat("Comunas del Servel sin CUT (revisar):\n"); print(sin_cut, n = Inf) }

# 3. Seguimiento de alcaldes ---------------------------------------------------------
# Misma persona: mismos dos apellidos y al menos un nombre de pila en común. El Servel a veces
# registra solo el nombre que se usa ("BERNARDO" en vez de "JUAN BERNARDO"); exigir un nombre en
# común separa a los hermanos con los mismos apellidos (p. ej., Río Claro 2016 y 2021).
misma <- function(ap_a, nom_a, ap_b, nom_b) {
  !is.na(ap_a) & !is.na(ap_b) & ap_a == ap_b &
    mapply(function(x, y) length(intersect(strsplit(x, " ")[[1]], strsplit(y, " ")[[1]])) > 0,
           coalesce(nom_a, ""), coalesce(nom_b, ""))
}

cand <- cand %>%
  mutate(apellidos = paste(apellido1, apellido2)) %>%
  group_by(anio, comuna_servel) %>%
  mutate(pct = votos / sum(votos), lugar = rank(-votos, ties.method = "first")) %>%
  ungroup()

com <- cand %>%
  group_by(anio, cut, comuna, comuna_servel) %>%
  summarise(n_candidatos = n(),
            alcalde = paste(nombres[electo], apellidos[electo])[1],
            ap_electo = apellidos[electo][1], nom_electo = nombres[electo][1],
            pacto_electo = pacto[electo][1], partido_electo = partido[electo][1],
            pct_electo = pct[electo][1],
            margen = sort(pct, decreasing = TRUE)[1] - coalesce(sort(pct, decreasing = TRUE)[2], 0),
            cand_ap = list(apellidos), cand_nom = list(nombres), .groups = "drop") %>%
  arrange(comuna_servel, anio) %>%
  group_by(comuna_servel) %>%
  mutate(incumbente = lag(alcalde), inc_ap = lag(ap_electo), inc_nom = lag(nom_electo),
         incumbente_repostula = ifelse(is.na(inc_ap), NA,
           mapply(function(a, n, ca, cn) any(misma(a, n, ca, cn)), inc_ap, inc_nom, cand_ap, cand_nom)),
         incumbente_gana = ifelse(is.na(inc_ap), NA, misma(ap_electo, nom_electo, inc_ap, inc_nom)),
         periodos_seguidos = {                                                  # del electo, censurado en 2012
           r <- integer(n()); for (i in seq_len(n())) r[i] <- if (isTRUE(incumbente_gana[i])) r[i - 1] + 1L else 1L; r },
         impedido_proxima = periodos_seguidos >= 3) %>%                         # Ley 21.238
  ungroup() %>%
  select(-cand_ap, -cand_nom, -inc_ap, -inc_nom, -ap_electo, -nom_electo)

# 4. Revisión y salida -------------------------------------------------------------
imp <- com %>% filter(anio == 2021, impedido_proxima)
cat("Alcaldes electos en 2012, 2016 y 2021 (impedidos en 2024):", nrow(imp), "\n")
sosp <- com %>% filter(anio == 2024, incumbente_repostula, comuna_servel %in% imp$comuna_servel)
if (nrow(sosp) > 0) {
  cat("Revisar: el alcalde impedido aparece como candidato en 2024:\n")
  print(select(sosp, comuna_servel, incumbente, alcalde), n = Inf)
}
cat("\nResumen por elección:\n")
print(com %>% group_by(anio) %>%
        summarise(comunas = n(), repostula = sum(incumbente_repostula, na.rm = TRUE),
                  reelecto = sum(incumbente_gana, na.rm = TRUE), margen_mediano = round(median(margen), 3)))

write_csv(select(cand, anio, cut, comuna, comuna_servel, region, pacto, partido, nombres, apellido1,
                 apellido2, votos, pct, lugar, electo),
          file.path(salida, "servel_alcaldes_candidatos.csv"))
write_csv(com, file.path(salida, "servel_alcaldes_comuna.csv"))
cat("\nEscrito en", salida, "\n")
