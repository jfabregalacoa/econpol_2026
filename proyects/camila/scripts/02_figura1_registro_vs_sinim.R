# Figura 1: ¿sirve el registro de transferencias para medir el gasto clientelar municipal?
# Compara, año por año, la suma de las subvenciones chicas del registro con la cuenta
# "Transferencias corrientes a organizaciones comunitarias" (IADM87) de SINIM, y muestra
# cuántos municipios reportan al registro.
#
# Uso (desde proyects/camila/):
#   Rscript scripts/02_figura1_registro_vs_sinim.R datos/muni_panel_comuna_mes.csv ../../playground/datos-apoyo/sinim/sinim_panel_largo.csv figs/

suppressMessages({library(dplyr); library(readr); library(tidyr); library(ggplot2)})

args   <- commandArgs(TRUE)
panel  <- if (length(args) >= 1) args[1] else "datos/muni_panel_comuna_mes.csv"
sinim  <- if (length(args) >= 2) args[2] else "../../playground/datos-apoyo/sinim/sinim_panel_largo.csv"
salida <- if (length(args) >= 3) args[3] else "figs"

reg <- read_csv(panel, col_types = cols(cut = "c")) %>%
  filter(anio >= 2014, anio <= 2025) %>%
  group_by(anio) %>%
  summarise(registro = sum(monto) / 1e9, municipios = n_distinct(cut))
sin <- read_csv(sinim, col_types = cols(cut = "c")) %>%
  filter(variable == "IADM87", anio >= 2014, anio <= 2025) %>%
  group_by(anio) %>% summarise(sinim = sum(valor, na.rm = TRUE) / 1e6)   # M$ -> miles de millones

d <- reg %>% left_join(sin, by = "anio")
print(d %>% mutate(razon = round(registro / sinim, 2)))

azul <- "#2a78d6"; naranjo <- "#eb6834"; gris <- "#52514e"

montos <- d %>% select(anio, registro, sinim) %>%
  pivot_longer(-anio, names_to = "fuente", values_to = "v") %>%
  mutate(panel = "A. Monto anual (miles de millones de pesos nominales)")
munis <- d %>% transmute(anio, fuente = "municipios", v = municipios,
                         panel = "B. Municipios que reportan subvenciones al registro")
etiquetas <- tibble(
  panel = c(montos$panel[1], montos$panel[1]),
  anio = c(2025.2, 2025.2),
  v = c(d$registro[d$anio == 2025], d$sinim[d$anio == 2025]),
  fuente = c("registro", "sinim"),
  texto = c("Registro 19.862\n(subvenciones chicas)", "SINIM\n(IADM87)"))

p <- ggplot(bind_rows(montos, munis), aes(anio, v, colour = fuente)) +
  annotate("rect", xmin = 2019.5, xmax = 2021.5, ymin = -Inf, ymax = Inf, fill = "#f0efec") +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.6) +
  geom_blank(data = tibble(anio = 2014, v = 300, fuente = "municipios", panel = munis$panel[1])) +
  geom_text(data = etiquetas, aes(label = texto), hjust = 0, size = 2.4, lineheight = 0.9) +
  facet_wrap(~panel, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = c(registro = azul, sinim = naranjo, municipios = gris), guide = "none") +
  scale_x_continuous(breaks = 2014:2025, expand = expansion(add = c(0.3, 2.4))) +
  scale_y_continuous(limits = c(0, NA), labels = function(x) format(x, big.mark = ".", decimal.mark = ",")) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 9) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#e1e0d9", linewidth = 0.3),
        strip.text = element_text(hjust = 0, colour = "#0b0b0b", size = 8.5),
        axis.text = element_text(colour = gris))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(salida, "fig1_registro_vs_sinim.png"), p, width = 6.4, height = 4.6, dpi = 300, bg = "white")
cat("Figura guardada en", file.path(salida, "fig1_registro_vs_sinim.png"), "\n")
