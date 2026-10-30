# Figura 2: lo que predice el modelo (ilustrativo, no son datos).
# Alza de las subvenciones en los meses previos a la elección municipal, según el
# régimen de voto y según si el alcalde en ejercicio va a la reelección.
#
# Uso (desde proyects/camila/):
#   Rscript scripts/03_figura2_predicciones.R figs/

suppressMessages({library(dplyr); library(ggplot2)})

salida <- if (length(commandArgs(TRUE)) >= 1) commandArgs(TRUE)[1] else "figs"

d <- tibble(
  regimen = factor(rep(c("2016\nvoto voluntario", "2024\nvoto obligatorio"), each = 2),
                   levels = c("2016\nvoto voluntario", "2024\nvoto obligatorio")),
  alcalde = factor(rep(c("repostula", "no repostula"), 2),
                   levels = c("repostula", "no repostula")),
  alza = c(1.00, 0.15, 0.45, 0.15))

azul <- "#2a78d6"; gris_barra <- "#c3c2b7"; gris <- "#52514e"

p <- ggplot(d, aes(regimen, alza, fill = alcalde)) +
  geom_col(position = position_dodge(width = 0.78), width = 0.7) +
  geom_text(aes(label = alcalde, y = alza + 0.04), position = position_dodge(width = 0.78),
            vjust = 0, size = 2.6, colour = gris) +
  annotate("curve", x = 0.86, xend = 1.74, y = 1.13, yend = 0.58, colour = "#0b0b0b", curvature = -0.25,
           linewidth = 0.4, arrow = arrow(length = unit(0.12, "cm"), type = "closed")) +
  annotate("text", x = 1.45, y = 1.08, hjust = 0, size = 2.6, colour = "#0b0b0b", lineheight = 0.95,
           label = "el alza se achica:\nla multa hace parte\ndel trabajo de la máquina") +
  scale_fill_manual(values = c(azul, gris_barra), guide = "none") +
  scale_y_continuous(limits = c(0, 1.3), breaks = NULL) +
  labs(x = NULL, y = "Alza preelectoral de las subvenciones\n(ilustrativo)") +
  theme_minimal(base_size = 9) +
  theme(panel.grid = element_blank(), axis.text.x = element_text(colour = "#0b0b0b", size = 8.5),
        axis.title.y = element_text(colour = gris, size = 8))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(salida, "fig2_predicciones.png"), p, width = 5.4, height = 3.2, dpi = 300, bg = "white")
cat("Figura guardada en", file.path(salida, "fig2_predicciones.png"), "\n")
