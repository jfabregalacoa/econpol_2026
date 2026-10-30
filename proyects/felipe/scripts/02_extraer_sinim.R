# Variables de SINIM para el proyecto: plazas, parques, áreas verdes con mantención,
# gasto en mantención e inversión municipal, más controles. Una fila por comuna y año.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/02_extraer_sinim.R ../../playground/datos-apoyo/sinim/sinim_panel_largo.csv datos/
#
# El panel de entrada se arma con playground/datos-apoyo/sinim/sinim_panel.py, que descarga
# cada variable desde https://datos.sinim.gov.cl (uso no comercial, citando a SINIM,
# SUBDERE y el Ministerio del Interior).

suppressMessages({library(dplyr); library(readr); library(tidyr)})

args   <- commandArgs(TRUE)
panel  <- if (length(args) >= 1) args[1] else "../../playground/datos-apoyo/sinim/sinim_panel_largo.csv"
salida <- if (length(args) >= 2) args[2] else "datos"

variables <- c(
  MPZC    = "plazas_n",                 # N° de plazas (desde 2010)
  MMPZC   = "plazas_m2",                # m² de plazas
  MPQC    = "parques_n",                # N° de parques urbanos
  MMPQC   = "parques_m2",               # m² de parques urbanos
  MAVM    = "areas_verdes_mantencion_m2",
  ITER009 = "areas_verdes_mantencion_m2_hab",
  IADM120 = "gasto_mantencion_jardines_miles",
  IADM22  = "inversion_municipal_miles",
  ICAR004 = "poblacion",
  ICAR008 = "rural_pct",
  IADM01  = "ingresos_totales_miles",
  FCM001  = "fondo_comun_municipal_miles")

d <- read_csv(panel, col_types = cols(cut = "c")) %>%
  filter(variable %in% names(variables)) %>%
  mutate(variable = variables[variable]) %>%
  select(cut, comuna, anio, variable, valor) %>%
  pivot_wider(names_from = variable, values_from = valor) %>%
  arrange(cut, anio)

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
write_csv(d, file.path(salida, "sinim_felipe.csv"))
cat("Filas:", nrow(d), "| comunas:", n_distinct(d$cut), "| años:", paste(range(d$anio), collapse = "-"), "\n")
