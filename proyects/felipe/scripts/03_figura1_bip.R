# Figura 1: iniciativas municipales nuevas en el BIP, por año y tipo de obra.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/03_figura1_bip.R datos/bip_municipal.csv.gz figs/

suppressMessages({library(dplyr); library(readr); library(ggplot2)})

args    <- commandArgs(TRUE)
entrada <- if (length(args) >= 1) args[1] else "datos/bip_municipal.csv.gz"
salida  <- if (length(args) >= 2) args[2] else "figs"

etiquetas <- c(nueva = "Construcción (obra nueva)", mejoramiento = "Mejoramiento o reposición",
               conservacion = "Conservación")
colores   <- c(nueva = "#2a78d6", mejoramiento = "#eb6834", conservacion = "#1baf7a")

d <- read_csv(entrada, col_types = cols(cut = "c")) %>%
  filter(situacion == "NUEVO", anio >= 2019, anio <= 2026, tipo %in% names(etiquetas)) %>%
  count(anio, tipo)
print(tidyr::pivot_wider(d, names_from = tipo, values_from = n))

fin <- d %>% filter(anio == max(anio)) %>% mutate(texto = etiquetas[tipo])

p <- ggplot(d, aes(anio, n, colour = tipo)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.6) +
  geom_text(data = fin, aes(label = texto), hjust = 0, nudge_x = 0.15, size = 2.5) +
  scale_colour_manual(values = colores, guide = "none") +
  scale_x_continuous(breaks = 2019:2026, expand = expansion(add = c(0.3, 2.6))) +
  scale_y_continuous(limits = c(0, NA), labels = function(x) format(x, big.mark = ".", decimal.mark = ",")) +
  labs(x = NULL, y = "Iniciativas nuevas postuladas") +
  theme_minimal(base_size = 9) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#e1e0d9", linewidth = 0.3),
        axis.text = element_text(colour = "#52514e"), axis.title.y = element_text(colour = "#52514e", size = 8))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(salida, "fig1_bip_tipos.png"), p, width = 6.2, height = 3.2, dpi = 300, bg = "white")
cat("Figura guardada en", file.path(salida, "fig1_bip_tipos.png"), "\n")
