# H1: ¿mantienen menos los alcaldes que no pueden repostular? Diferencias en diferencias y estudio de eventos.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/08_estimar_h1.R
#
# Entrada: datos/panel_comuna_anio.csv (scripts/07_panel_comuna_anio.R)
# Salidas: datos/h1_resultados.csv (coeficientes) y figs/fig3_h1_eventos.png
#
# Grupo tratado (G): comunas cuyo alcalde del período 2021-2024 estaba en su tercer período seguido y no podía
# repostular en 2024 (Ley 21.238). Post: 2022-2024, los años completos de ese período. Se excluye 2021, año de
# transición entre alcaldes. Comparación: el resto de las comunas y, en la especificación más exigente, solo
# las comunas cuyo alcalde estaba en su segundo período seguido (experiencia parecida, pero podía repostular).
#
# Medición: SINIM registra el gasto en servicios de mantención de jardines CONTRATADOS (vía R25 del mapeo).
# Entre 94 y 128 comunas por año reportan cero porque mantienen con personal propio (vía R24), cuyo costo no
# aparece en esa cuenta. Por eso se estiman dos márgenes:
#   - Extensivo: si la comuna contrata mantención ese año (modelo lineal de probabilidad, todas las comunas).
#   - Intensivo: log del gasto contratado por m² de área verde mantenida, en las comunas que contratan todos
#     los años de la ventana (así el cambio no viene de pasar de personal propio a contrato o al revés).
# Montos en pesos corrientes; los efectos fijos de año absorben la inflación común.

suppressMessages({library(dplyr); library(readr); library(fixest); library(modelsummary); library(ggplot2)})

p <- read_csv("datos/panel_comuna_anio.csv", col_types = cols(cut = "c"), show_col_types = FALSE)

per21 <- p %>% filter(eleccion_periodo == 2021) %>% distinct(cut, periodos_2021 = periodos_seguidos)
d <- p %>%
  left_join(per21, by = "cut") %>%
  filter(anio %in% 2013:2024, anio != 2021, !is.na(G_impedido_2024)) %>%
  mutate(G = as.integer(G_impedido_2024), post = as.integer(post_2022_2024),
         contrata = if_else(is.na(gasto_mantencion_jardines_miles), NA_integer_,
                            as.integer(gasto_mantencion_jardines_miles > 0)),
         y = if_else(mantencion_por_m2 > 0, log(mantencion_por_m2), NA_real_),
         log_pob = log(poblacion), log_ingresos = log(ingresos_totales_miles))

dd <- filter(d, anio >= 2017)
siempre <- dd %>% group_by(cut) %>% summarise(ok = all(!is.na(y))) %>% filter(ok) %>% pull(cut)
cat("Comunas tratadas:", n_distinct(d$cut[d$G == 1]), "de", n_distinct(d$cut),
    "| contratan todos los años 2017-2024:", length(siempre),
    "(tratadas:", n_distinct(dd$cut[dd$cut %in% siempre & dd$G == 1]), ")\n")
cat("Proporción que contrata, por grupo y período:\n")
print(as.data.frame(dd %>% group_by(G, post) %>% summarise(contrata = round(mean(contrata, na.rm = TRUE), 3), .groups = "drop")))

# 1. Diferencias en diferencias, 2017-2024 ---------------------------------------------------------------
ds <- filter(dd, cut %in% siempre)
m <- list(
  "(1) Contrata (todas)"         = feols(contrata ~ G:post + log_pob + log_ingresos | cut + anio, dd, cluster = ~cut),
  "(2) log $/m² (contratan)"     = feols(y ~ G:post | cut + anio, ds, cluster = ~cut),
  "(3) + controles"              = feols(y ~ G:post + log_pob + log_ingresos | cut + anio, ds, cluster = ~cut),
  "(4) vs. 2.º período"          = feols(y ~ G:post + log_pob + log_ingresos | cut + anio,
                                         filter(ds, G == 1 | periodos_2021 == 2), cluster = ~cut))
modelsummary(m, coef_map = c("G:post" = "Impedido × 2022–2024", "log_pob" = "log población",
                             "log_ingresos" = "log ingresos municipales"),
             gof_map = c("nobs", "r.squared"), stars = TRUE, output = "markdown") |> print()

res <- bind_rows(lapply(names(m), function(n) {
  ct <- coeftable(m[[n]]); i <- "G:post"
  tibble(modelo = n, coef = ct[i, 1], ee = ct[i, 2], p = ct[i, 4], n = nobs(m[[n]]))
}))
print(as.data.frame(res))
write_csv(res, "datos/h1_resultados.csv")

# 2. Estudio de eventos, 2013-2024 (2020 = referencia), margen intensivo ------------------------------------
siempre13 <- d %>% group_by(cut) %>% summarise(ok = all(!is.na(y))) %>% filter(ok) %>% pull(cut)
ev <- feols(y ~ i(anio, G, ref = 2020) + log_pob + log_ingresos | cut + anio, filter(d, cut %in% siempre13), cluster = ~cut)
ct <- coeftable(ev)
e <- tibble(termino = rownames(ct), coef = ct[, 1], ee = ct[, 2]) %>%
  filter(grepl("^anio::", termino)) %>%
  transmute(anio = as.integer(sub("anio::(\\d+):G", "\\1", termino)), coef, ee) %>%
  bind_rows(tibble(anio = 2020L, coef = 0, ee = 0)) %>% arrange(anio)
cat("\nEstudio de eventos (", length(siempre13), "comunas que contratan 2013-2024; ref. 2020):\n")
print(as.data.frame(e))
cat("Prueba conjunta de tendencias previas (2013-2019 = 0): p =",
    signif(wald(ev, keep = "anio::201[3-9]:G", print = FALSE)$p, 3), "\n")

g <- ggplot(e, aes(anio, coef)) +
  annotate("rect", xmin = 2021.5, xmax = 2024.5, ymin = -Inf, ymax = Inf, fill = "#f1efe8") +
  annotate("text", x = 2023, y = Inf, label = "Último mandato\n(impedidos)", vjust = 1.3, size = 2.3, colour = "#6b6a66") +
  geom_hline(yintercept = 0, colour = "#a9a8a1", linewidth = 0.3) +
  geom_errorbar(aes(ymin = coef - 1.96 * ee, ymax = coef + 1.96 * ee), width = 0, colour = "#2a78d6", linewidth = 0.5) +
  geom_point(colour = "#2a78d6", size = 1.8) +
  scale_x_continuous(breaks = c(2013:2020, 2022:2024)) +
  labs(x = NULL, y = "Diferencia en log mantención por m²\n(impedidos − resto, ref. 2020)") +
  theme_minimal(base_size = 9) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#e1e0d9", linewidth = 0.3),
        axis.text = element_text(colour = "#52514e"), axis.title.y = element_text(colour = "#52514e", size = 8))
ggsave("figs/fig3_h1_eventos.png", g, width = 6.2, height = 3.2, dpi = 300, bg = "white")
cat("Figura guardada en figs/fig3_h1_eventos.png\n")
