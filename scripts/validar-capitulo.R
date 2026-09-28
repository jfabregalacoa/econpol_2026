# Ejecuta todos los chunks, incluido el fallback estático, y verifica los modelos.
archivo <- "chapters/01-interaccion-instituciones-agenda.qmd"
codigo <- tempfile(fileext = ".R")
grafico <- tempfile(fileext = ".pdf")
knitr::purl(archivo, output = codigo, documentation = 0, quiet = TRUE)
pdf(grafico)
entorno <- new.env()
sys.source(codigo, envir = entorno)
dev.off()
unlink(c(codigo, grafico))

with(entorno, {
  stopifnot(nrow(spatial_utilities) == 1203)
  stopifnot(all(spatial_utilities$utility <= 0))
  stopifnot(all(rr_upper_accept(20, c(25, 50, 75)) == c(30, 80, 130)))
  for (ideales in electorates) {
    mediana <- median(ideales)
    esperado <- ifelse(q_grid < mediana, 2 * mediana - q_grid, q_grid)
    calculado <- vapply(q_grid, rr_certainty_outcome, numeric(1), ideals = ideales)
    stopifnot(isTRUE(all.equal(calculado, esperado)))
  }
  stopifnot(rr_certainty_outcome(50, ideals_rr) == 50)
  stopifnot(rr_certainty_outcome(100, ideals_rr) == 100)
  for (r in c(0.1, 0.5, 0.9)) {
    propuestas <- seq(20, 140, length.out = 250)
    probabilidades <- vapply(propuestas, rr_pass_probability, numeric(1),
                            q = 20, ideals = ideals_rr, abstention = r)
    stopifnot(all(probabilidades >= 0 & probabilidades <= 1))
    stopifnot(all(diff(probabilidades) <= 0))
    resultado <- rr_uncertain_outcome(20, ideals_rr, r)
    gasto <- 20 + (propuestas - 20) * probabilidades
    stopifnot(isTRUE(all.equal(resultado$expected_expenditure, max(gasto))))
    stopifnot(resultado$proposal == propuestas[which.max(gasto)])
    extremo <- rr_uncertain_outcome(100, ideals_rr, r)
    stopifnot(extremo$proposal == 100, extremo$expected_expenditure == 100)
  }
  stopifnot(nrow(rr_frames) == 51)
  stopifnot(nrow(rr_uncertainty_frames) == 459)
  stopifnot(length(unique(rr_uncertainty_frames$frame)) == 9)
  stopifnot(all(is.finite(rr_uncertainty_frames$expected_expenditure)))
  stopifnot(all(rr_uncertainty_frames$expected_expenditure >= rr_uncertainty_frames$q))
})
cat("Validación correcta: preferencias, certeza, incertidumbre y fallback estático.\n")
