# H3: dentro de lo que se inaugura, ¿postulan los alcaldes impedidos más obras nuevas frente a mejoramientos?
# También H2 (cuántas obras inaugurables en total), cuyo signo el modelo deja ambiguo.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/09_estimar_h3.R
#
# Entradas (script 05 y script 07):
#   datos/bip_ep_panel_comuna_anio.csv      obras de espacio público (muestra principal)
#   datos/bip_todas_panel_comuna_anio.csv   todas las obras municipales (robustez, mucha más muestra)
#   datos/panel_comuna_anio.csv             grupo G
# Salida: datos/h3_resultados.csv
#
# Tiempo: el BIP registra el año presupuestario al que se postula. La fecha de postulación, cuando existe (40%
# de las obras), cae casi siempre el año anterior. Por eso cada obra se asigna al alcalde en ejercicio en el
# "año de decisión" = año presupuestario − 1. Post: años de decisión 2022-2024 (período completo de los
# impedidos). Pre: 2017-2020. Se excluye 2021, año de transición entre alcaldes.
#
# Composición (H3): una fila por comuna, año y tipo (obra nueva o mejoramiento), regresión de Poisson con
# efectos fijos comuna×año. Esos efectos absorben cuánto postula cada comuna cada año, así que el coeficiente
# de G × Post × Nueva mide solo el cambio en la mezcla: si los impedidos desplazan su cartera hacia obras nuevas.

suppressMessages({library(dplyr); library(readr); library(tidyr); library(fixest); library(modelsummary)})

grupo <- read_csv("datos/panel_comuna_anio.csv", col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  filter(eleccion_periodo == 2021) %>% distinct(cut, G = as.integer(G_impedido_2024), periodos_2021 = periodos_seguidos)

estimar <- function(archivo, muestra) {
  b <- read_csv(archivo, col_types = cols(cut = "c"), show_col_types = FALSE) %>%
    mutate(decision = anio - 1) %>%
    filter(decision %in% c(2017:2020, 2022:2024)) %>%
    inner_join(grupo, by = "cut") %>%
    mutate(post = as.integer(decision >= 2022), inaugurables = n_nueva + n_mejoramiento)
  largo <- b %>%
    select(cut, decision, G, post, periodos_2021, nueva = n_nueva, mejoramiento = n_mejoramiento) %>%
    pivot_longer(c(nueva, mejoramiento), names_to = "tipo", values_to = "n") %>%
    mutate(es_nueva = as.integer(tipo == "nueva"))

  cat("\n==========", muestra, "==========\n")
  desc <- b %>% group_by(Grupo = if_else(G == 1, "Impedido", "Puede repostular"),
                         Periodo = if_else(post == 1, "2022-2024", "2017-2020")) %>%
    summarise(comunas = n_distinct(cut), nuevas = sum(n_nueva), mejoramientos = sum(n_mejoramiento),
              pct_nueva = round(100 * nuevas / (nuevas + mejoramientos), 1), .groups = "drop")
  print(as.data.frame(desc))

  m <- list(
    "H3 composición" = fepois(n ~ G:post:es_nueva + post:es_nueva + G:es_nueva | cut^decision + tipo^decision,
                              largo, cluster = ~cut),
    "H3 vs. 2.º período" = fepois(n ~ G:post:es_nueva + post:es_nueva + G:es_nueva | cut^decision + tipo^decision,
                                  filter(largo, G == 1 | periodos_2021 == 2), cluster = ~cut),
    "H2 inaugurables" = fepois(inaugurables ~ G:post | cut + decision, b, cluster = ~cut),
    "H2 obras nuevas" = fepois(n_nueva ~ G:post | cut + decision, b, cluster = ~cut),
    "H2 mejoramientos" = fepois(n_mejoramiento ~ G:post | cut + decision, b, cluster = ~cut))
  modelsummary(m, coef_map = c("G:post:es_nueva" = "Impedido × Post × Obra nueva", "G:post" = "Impedido × Post"),
               gof_map = c("nobs"), stars = TRUE, output = "markdown") |> print()

  bind_rows(lapply(names(m), function(n) {
    ct <- coeftable(m[[n]]); i <- intersect(c("G:post:es_nueva", "G:post"), rownames(ct))[1]
    tibble(muestra = muestra, modelo = n, termino = i, coef = ct[i, 1], ee = ct[i, 2], p = ct[i, 4],
           n = nobs(m[[n]]), razon_tasas = exp(ct[i, 1]))
  }))
}

res <- bind_rows(estimar("datos/bip_ep_panel_comuna_anio.csv", "Espacio público"),
                 estimar("datos/bip_todas_panel_comuna_anio.csv", "Todas las obras municipales"))
cat("\n"); print(as.data.frame(mutate(res, across(where(is.numeric), ~ signif(.x, 3)))))
write_csv(res, "datos/h3_resultados.csv")
