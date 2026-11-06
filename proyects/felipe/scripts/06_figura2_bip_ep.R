# Figura 2: obras municipales de espacio público en el BIP, por año de primera postulación y tipo de obra.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/06_figura2_bip_ep.R datos/bip_ep_obras.csv.gz figs/
#
# Cuenta cada obra (código BIP) una sola vez, en el año en que se postula por primera vez, con los datos de
# scripts/05_bip_espacio_publico.R. Las líneas verticales marcan las elecciones municipales.

suppressMessages({library(dplyr); library(readr); library(ggplot2)})

args    <- commandArgs(TRUE)
entrada <- if (length(args) >= 1) args[1] else "datos/bip_ep_obras.csv.gz"
salida  <- if (length(args) >= 2) args[2] else "figs"
desde   <- 2008
hasta   <- 2026   # 2027 todavía está incompleto

etiquetas <- c(mejoramiento = "Mejoramiento", nueva = "Obra nueva", conservacion = "Conservación")
colores   <- c(nueva = "#2a78d6", mejoramiento = "#eb6834", conservacion = "#1baf7a")
elecciones <- c(2008, 2012, 2016, 2021, 2024)
tinta <- "#3d3c39"; tinta_suave <- "#6b6a66"

d <- read_csv(entrada, show_col_types = FALSE) %>%
  filter(anio_primera >= desde, anio_primera <= hasta, tipo %in% names(etiquetas)) %>%
  count(anio = anio_primera, tipo) %>%
  tidyr::complete(anio = desde:hasta, tipo = names(etiquetas), fill = list(n = 0))
print(tidyr::pivot_wider(d, names_from = tipo, values_from = n), n = Inf)

fin <- d %>% filter(anio == hasta) %>% mutate(texto = etiquetas[tipo])
techo <- max(d$n) * 1.08

p <- ggplot(d, aes(anio, n, colour = tipo)) +
  geom_vline(xintercept = elecciones, colour = "#c9c8c1", linewidth = 0.3, linetype = "dashed") +
  annotate("text", x = elecciones, y = techo, label = paste("Elección", elecciones),
           size = 2.1, colour = tinta_suave, hjust = -0.05, vjust = 1) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.6) +
  geom_text(data = fin, aes(label = texto), colour = tinta, hjust = 0, nudge_x = 0.35, size = 2.6) +
  scale_colour_manual(values = colores, guide = "none") +
  scale_x_continuous(breaks = seq(desde, hasta, 2), expand = expansion(add = c(0.4, 3.2))) +
  scale_y_continuous(limits = c(0, techo), expand = expansion(mult = c(0, 0.02)),
                     labels = function(x) format(x, big.mark = ".", decimal.mark = ",")) +
  labs(x = NULL, y = "Obras postuladas por primera vez") +
  theme_minimal(base_size = 9) +
  theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "#e1e0d9", linewidth = 0.3),
        axis.text = element_text(colour = "#52514e"), axis.title.y = element_text(colour = "#52514e", size = 8))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(salida, "fig2_bip_ep_tipos.png"), p, width = 6.2, height = 3.2, dpi = 300, bg = "white")
cat("Figura guardada en", file.path(salida, "fig2_bip_ep_tipos.png"), "\n")
