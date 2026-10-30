# Figura 1: subvenciones a organizaciones (hasta 50 millones) registradas por cada
# gobierno regional, según el año del decreto. Sirve para ver los huecos de reporte.
#
# Uso (desde proyects/abraham/):
#   Rscript scripts/02_figura1_cobertura.R datos/gore_transferencias.csv.gz figs/

suppressMessages({library(dplyr); library(readr); library(tidyr); library(ggplot2)})

args <- commandArgs(TRUE)
entrada <- if (length(args) >= 1) args[1] else "datos/gore_transferencias.csv.gz"
salida  <- if (length(args) >= 2) args[2] else "figs"

# Código de región -> nombre, en orden norte a sur
regiones <- c("15" = "Arica y Parinacota", "01" = "Tarapacá", "02" = "Antofagasta", "03" = "Atacama",
              "04" = "Coquimbo", "05" = "Valparaíso", "13" = "Metropolitana", "06" = "O'Higgins",
              "07" = "Maule", "16" = "Ñuble", "08" = "Biobío", "09" = "La Araucanía",
              "14" = "Los Ríos", "10" = "Los Lagos", "11" = "Aysén", "12" = "Magallanes")

d <- read_csv(entrada, col_types = cols(gore = "c", .default = col_guess())) %>%
  filter(instrumento == "subv_org", anio >= 2014, anio <= 2025) %>%
  count(gore, anio) %>%
  complete(gore = names(regiones), anio = 2014:2025, fill = list(n = 0)) %>%
  mutate(region = factor(regiones[gore], levels = rev(regiones)),
         pocas  = n < 20,                                   # menos de 20 registros: celda gris
         texto  = formatC(n, big.mark = ".", decimal.mark = ",", format = "d"))

azules <- c("#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b")

p <- ggplot(d, aes(factor(anio), region)) +
  geom_tile(aes(fill = ifelse(pocas, NA, n)), colour = "white", linewidth = 0.8) +
  geom_text(aes(label = texto, colour = ifelse(!pocas & n > 900, "blanco", "negro")), size = 2.3) +
  scale_colour_manual(values = c(blanco = "#ffffff", negro = "#0b0b0b"), guide = "none") +
  scale_fill_gradientn(colours = azules, trans = "log10", na.value = "#f0efec",
                       name = "Subvenciones\n(escala log)", breaks = c(30, 100, 300, 1000, 3000),
                       labels = c("30", "100", "300", "1.000", "3.000")) +
  geom_vline(xintercept = 7.5, colour = "#52514e", linewidth = 0.5, linetype = "22") +
  annotate("text", x = 7.6, y = 16.9, label = "gobernadores electos (jul. 2021)",
           hjust = 0, size = 2.6, colour = "#52514e") +
  coord_cartesian(clip = "off") +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 9) +
  theme(panel.grid = element_blank(), axis.text = element_text(colour = "#0b0b0b"),
        legend.key.height = unit(0.5, "cm"),
        legend.title = element_text(size = 7.5, colour = "#52514e"),
        legend.text = element_text(size = 7, colour = "#52514e"),
        plot.margin = margin(14, 4, 4, 4))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(salida, "fig1_cobertura.png"), p, width = 6.6, height = 3.9, dpi = 300, bg = "white")
cat("Figura guardada en", file.path(salida, "fig1_cobertura.png"), "\n")
