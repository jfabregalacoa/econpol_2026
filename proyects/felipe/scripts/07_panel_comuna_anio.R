# Panel comuna-año 2008-2025: SINIM (mantención y controles) + BIP (obras de espacio público) + Servel (horizonte).
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/07_panel_comuna_anio.R
#
# Entradas (todas en proyects/felipe/):
#   datos/sinim_felipe.csv                          panel SINIM de la ayudantía, 2001-2025, en pesos corrientes
#   fuentes/sinim/sinim_municipios_2013_2024.xlsx   exportación SINIM con más variables, 2013-2023, en pesos de 2023
#   datos/bip_ep_panel_comuna_anio.csv              scripts/05_bip_espacio_publico.R
#   datos/servel_alcaldes_comuna.csv                scripts/04_servel_alcaldes.R
# Salida:
#   datos/panel_comuna_anio.csv                     una fila por comuna y año, 345 comunas x 2008-2025
#
# Decisiones:
# - Montos en pesos corrientes. La exportación SINIM viene en pesos de 2023; se pasa a corrientes con la razón
#   entre ambas fuentes, que es la misma para todas las comunas en cada año (un deflactor implícito). Las
#   estimaciones con efectos fijos de año absorben la inflación común.
# - Cada año se asigna al alcalde en ejercicio el 1 de enero. Los alcaldes electos en octubre asumen en
#   diciembre, así que el año siguiente ya es suyo. 2021 es un año de transición: el alcalde electo en 2016
#   gobernó hasta el 28 de junio y el electo en mayo de 2021, el resto del año (anio_transicion = TRUE).
# - "ultimo_mandato": el alcalde no puede repostular en la elección siguiente por la Ley 21.238 (tres períodos
#   seguidos). Antes de la ley no había límite, así que es FALSE para los períodos 2012 y 2016. Para el período
#   2008-2012 no hay datos del Servel (NA).

suppressMessages({library(dplyr); library(readr); library(readxl); library(tidyr)})

num <- function(v) suppressWarnings(as.numeric(v))
anios <- 2008:2025
elecciones <- c(2004, 2008, 2012, 2016, 2021, 2024, 2028)

# 1. SINIM -----------------------------------------------------------------------------------------
a <- read_csv("datos/sinim_felipe.csv", col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  filter(anio %in% anios)

x <- read_excel("fuentes/sinim/sinim_municipios_2013_2024.xlsx", col_types = "text")
col <- function(codigo) { n <- names(x)[startsWith(names(x), paste0(codigo, " "))]; stopifnot(length(n) == 1); n }
b <- tibble(cut = sprintf("%05d", as.integer(num(x$CODIGO))), anio = as.integer(num(x$AÑO)),
            iadm120_2023 = num(x[[col("IADM120")]]),
            mant_jardines_comunidad_2023 = num(x[[col("BSMJSC")]]),
            mant_alumbrado_2023 = num(x[[col("IADM93")]]),
            mant_semaforos_2023 = num(x[[col("IADM94")]]),
            mant_senalizacion_2023 = num(x[[col("IADM95")]]),
            ingresos_propios_2023 = num(x[[col("IADM42")]]),
            pct_inversion_propia = num(x[[col("IADM15")]]),
            pct_inversion_externa = num(x[[col("IADM16")]]))

# Deflactor implícito: pesos corrientes / pesos de 2023, igual para todas las comunas en cada año.
deflactor <- inner_join(select(a, cut, anio, g = gasto_mantencion_jardines_miles), select(b, cut, anio, r = iadm120_2023),
                        by = c("cut", "anio")) %>%
  filter(g > 0, r > 0) %>% group_by(anio) %>%
  summarise(indice_corriente_2023 = median(g / r), dispersion = IQR(g / r), .groups = "drop")
stopifnot(all(deflactor$dispersion < 1e-3))   # si falla, las fuentes no difieren solo por un deflactor
b <- b %>% left_join(select(deflactor, anio, indice_corriente_2023), by = "anio") %>%
  mutate(across(ends_with("_2023") & !starts_with("iadm120"), ~ .x * indice_corriente_2023,
                .names = "{sub('_2023$', '_miles', .col)}")) %>%
  select(cut, anio, ends_with("_miles"), starts_with("pct_"), indice_corriente_2023)

sinim <- a %>%
  left_join(b, by = c("cut", "anio")) %>%
  mutate(mantencion_por_m2 = if_else(areas_verdes_mantencion_m2 > 0,
                                     gasto_mantencion_jardines_miles * 1000 / areas_verdes_mantencion_m2, NA_real_))

# 2. BIP ---------------------------------------------------------------------------------------------
bip <- read_csv("datos/bip_ep_panel_comuna_anio.csv", col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  filter(anio %in% anios) %>% select(-comuna) %>%
  rename_with(~ paste0("bip_", .x), -c(cut, anio))

# 3. Servel: alcalde en ejercicio el 1 de enero ------------------------------------------------------
periodo_de <- function(t) sapply(t, function(y) max(elecciones[elecciones < y]))
proxima_de <- function(t) sapply(t, function(y) min(elecciones[elecciones >= y]))
sv <- read_csv("datos/servel_alcaldes_comuna.csv", col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  filter(!is.na(cut)) %>%
  transmute(cut, eleccion_periodo = anio, alcalde, pacto_alcalde = pacto_electo, partido_alcalde = partido_electo,
            pct_electo, margen_eleccion = margen, periodos_seguidos, cambio_alcalde = !incumbente_gana,
            ultimo_mandato = if_else(anio >= 2021, impedido_proxima, FALSE))

horizonte <- expand_grid(cut = unique(sinim$cut), anio = anios) %>%
  mutate(eleccion_periodo = periodo_de(anio), eleccion_siguiente = proxima_de(anio),
         anios_a_eleccion = eleccion_siguiente - anio,
         anio_transicion = anio == 2021) %>%
  left_join(sv, by = c("cut", "eleccion_periodo"))

# Grupo del diseño de diferencias en diferencias: comunas cuyo alcalde del período 2021-2024 no podía repostular.
grupo <- sv %>% filter(eleccion_periodo == 2021) %>% transmute(cut, G_impedido_2024 = ultimo_mandato)

# 4. Unir ---------------------------------------------------------------------------------------------
panel <- sinim %>%
  left_join(bip, by = c("cut", "anio")) %>%
  mutate(across(starts_with("bip_"), ~ coalesce(.x, 0))) %>%
  left_join(horizonte, by = c("cut", "anio")) %>%
  left_join(grupo, by = "cut") %>%
  mutate(post_2022_2024 = anio %in% 2022:2024) %>%
  relocate(cut, comuna, anio, eleccion_periodo, alcalde, ultimo_mandato, G_impedido_2024, post_2022_2024) %>%
  arrange(cut, anio)

stopifnot(!anyDuplicated(panel[c("cut", "anio")]))
write_csv(panel, "datos/panel_comuna_anio.csv")

# 5. Resumen -----------------------------------------------------------------------------------------
cat("Panel:", nrow(panel), "filas,", n_distinct(panel$cut), "comunas,", min(panel$anio), "-", max(panel$anio), ",",
    ncol(panel), "columnas\n\n")
cat("Deflactor implícito (pesos corrientes / pesos de 2023):\n"); print(select(deflactor, -dispersion), n = Inf)
cat("\nComunas en el grupo impedido (G_impedido_2024):", sum(grupo$G_impedido_2024, na.rm = TRUE), "\n")
cat("\nCobertura por año (filas con dato):\n")
print(panel %>% group_by(anio) %>%
        summarise(mant_m2 = sum(!is.na(mantencion_por_m2)), jard_comunidad = sum(!is.na(mant_jardines_comunidad_miles)),
                  alcalde = sum(!is.na(alcalde)), ultimo_mandato = sum(ultimo_mandato, na.rm = TRUE),
                  obras_nuevas = sum(bip_n_nueva), mejoramientos = sum(bip_n_mejoramiento),
                  conservaciones = sum(bip_n_conservacion)), n = Inf)
cat("\nMantención por m² (pesos corrientes), mediana por grupo y período:\n")
print(panel %>% filter(anio %in% 2017:2024, !anio_transicion) %>%
        group_by(grupo = if_else(G_impedido_2024, "Impedido en 2024", "Puede repostular"),
                 periodo = if_else(post_2022_2024, "2022-2024", "2017-2020")) %>%
        summarise(comunas = n_distinct(cut), mediana = round(median(mantencion_por_m2, na.rm = TRUE)), .groups = "drop"))
