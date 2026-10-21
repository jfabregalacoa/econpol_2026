# ------------------------------------------------------------------------------
# ECONOMIA POLITICA FORMAL - SESION 4
# Principal-agente, elecciones, corrupcion y posiciones ideologicas
# Laboratorio: estimaciones publicadas y votaciones de la Camara chilena
# Datos: Fabrega (2025), Data in Brief 63:112163.
# Repositorio: https://github.com/jfabregalacoa/monitor_congreso
# ------------------------------------------------------------------------------

# Ejecutar solo una vez, si faltan paquetes:
# install.packages(c("data.table", "ggplot2", "pscl", "wnominate"))

library(data.table)
library(ggplot2)

base_url <- paste0(
  "https://raw.githubusercontent.com/jfabregalacoa/",
  "monitor_congreso/master/Harvard%20Dataverse/"
)

url_posiciones <- paste0(
  base_url,
  "Ideology%20estimates/",
  "ideologia_congreso_chile_2002_2026_long_format.csv"
)
url_votaciones <- paste0(
  base_url, "Roll%20calls/matriz__periodo_2022_26.csv"
)

# ========== PARTE 0. SIMULAR LA REGLA DE FEREJOHN ============================
# Es un ejercicio teorico, sin datos observados.
M <- seq(0, 2, length.out = 200)
K_optimo <- pmin(0.5, M / 2)
plot(M, K_optimo, type = "l", lwd = 2,
     xlab = "Valor descontado de conservar el cargo: M",
     ylab = "Umbral retrospectivo optimo: K",
     main = "Ferejohn: regla retrospectiva optima")

# ========== PARTE I. EXPLORAR ESTIMACIONES PUBLICADAS ==========================

posiciones <- fread(url_posiciones, na.strings = c("", "NA"))
print(names(posiciones))
print(posiciones[, .N, by = Period][order(Period)])

p6 <- copy(posiciones[
  Period == "Periodo_6" &
  !is.na(wnom_ideology),
  .(DiputadoId = as.character(Id),
    Name, party_1, wnom_ideology, bay_ideology, dim_ideology)
])

cat("Diputados con estimacion W-NOMINATE:", nrow(p6), "\n")
print(summary(p6$wnom_ideology))

# Distribucion unidimensional: no deducir distancia a votantes sin datos externos.
g1 <- ggplot(p6, aes(x = wnom_ideology)) +
  geom_histogram(bins = 25, fill = "grey55", color = "white") +
  labs(x = "Punto ideal estimado (W-NOMINATE)", y = "Diputados",
       title = "Distribucion de posiciones legislativas, 2022-2026") +
  theme_minimal()
print(g1)

# Las escalas de metodos distintos no se pueden comparar restando puntos.
# Una correlacion es solo una comprobacion exploratoria.
cat("Correlacion W-NOMINATE / bayesiano (signo depende de orientacion):\n")
print(cor(p6$wnom_ideology, p6$bay_ideology,
          use = "pairwise.complete.obs"))

# Comparacion descriptiva ENTRE afiliaciones partidarias presentes en el archivo.
p6_partidos <- p6[!is.na(party_1) & nzchar(trimws(party_1))]
frecuencia <- p6_partidos[, .N, by = party_1][order(-N)]
print(frecuencia)
partidos_muestra <- frecuencia[N >= 4, party_1]

if (length(partidos_muestra) > 0) {
  g2 <- ggplot(p6_partidos[party_1 %in% partidos_muestra],
               aes(x = reorder(party_1, wnom_ideology, median),
                   y = wnom_ideology)) +
    geom_boxplot(fill = "grey80") +
    coord_flip() +
    labs(x = "Afiliacion consignada en los datos", y = "Punto ideal",
         title = "Posiciones estimadas por partido") +
    theme_minimal()
  print(g2)
}

# Resumen del grado de dispersion dentro de cada partido
partidos_resumen <- p6_partidos[
  , .(n = .N,
      mediana = median(wnom_ideology),
      desviacion = sd(wnom_ideology),
      rango_intercuartil = IQR(wnom_ideology)),
  by = party_1
][order(-n)]
print(partidos_resumen)

# ========== PARTE II. ESTIMAR PUNTOS IDEALES DESDE VOTOS ========================
# Puede tomar mas tiempo que la primera parte. Ejecutar opcionalmente.

library(pscl)
library(wnominate)

datos <- fread(url_votaciones)
stopifnot("DiputadoId" %in% names(datos), ncol(datos) >= 6)

# De acuerdo con la estructura documentada del archivo,
# columnas 1:5 son identificadores; las siguientes son votaciones.
votos_dt <- datos[, 6:ncol(datos), with = FALSE]

codificar <- function(x) {
  x <- trimws(as.character(x))
  ifelse(x == "Afirmativo", 1L,
         ifelse(x == "En Contra", 0L, NA_integer_))
}

votos_01 <- as.matrix(votos_dt[, lapply(.SD, codificar)])
storage.mode(votos_01) <- "numeric"
rownames(votos_01) <- as.character(datos$DiputadoId)

# Los votos ausentes/abstenciones quedan como NA, nunca como votos negativos.
# Excluir votaciones casi unanimes o con muy escasa participacion.
no_faltantes <- colSums(!is.na(votos_01))
a_favor <- colSums(votos_01 == 1, na.rm = TRUE)
en_contra <- colSums(votos_01 == 0, na.rm = TRUE)
conservar <- no_faltantes >= 30 & a_favor >= 5 & en_contra >= 5
votos_01 <- votos_01[, conservar, drop = FALSE]

cat("Dimensiones de la matriz para estimacion:\n")
print(dim(votos_01))
stopifnot(ncol(votos_01) >= 20)

# Separar votaciones para ESTIMACION y EVALUACION.
# Evita estimar ideologia con exactamente las decisiones que queremos explicar.
set.seed(1042026)
indices_train <- sample.int(ncol(votos_01),
                             size = floor(0.70 * ncol(votos_01)))
train <- votos_01[, indices_train, drop = FALSE]
test <- votos_01[, -indices_train, drop = FALSE]

roll <- pscl::rollcall(
  data = train,
  yea = 1,
  nay = 0,
  missing = NA,
  legis.names = rownames(train),
  vote.names = colnames(train),
  desc = "Chile 2022-2026: votaciones de entrenamiento"
)

# El ancla fija el sentido de la coordenada; no implica aprobacion politica.
# Lista de identificadores que utiliza el script original del repositorio.
anclas <- c("908", "865", "857", "942", "917", "1135")
ancla <- intersect(anclas, rownames(train))[1]
stopifnot(length(ancla) == 1, !is.na(ancla))

modelo <- wnominate::wnominate(
  rcObject = roll,
  dims = 1,
  polarity = ancla,
  minvotes = 20,
  lop = 0.025,
  trials = 3
)

ideales_entrenamiento <- data.table(
  DiputadoId = as.character(rownames(modelo$legislators)),
  theta_train = as.numeric(modelo$legislators$coord1D)
)
ideales_entrenamiento <- ideales_entrenamiento[!is.na(theta_train)]
print(summary(ideales_entrenamiento$theta_train))

# ========== PARTE III. DESVIACIONES RESPECTO DEL PARTIDO ========================
# Trabajo descriptivo, no una prueba causal de accountability electoral.

info_partido <- unique(
  p6[, .(DiputadoId, partido = as.character(party_1))],
  by = "DiputadoId"
)
info_partido <- info_partido[!is.na(partido) & nzchar(trimws(partido))]

ideales_partido <- merge(ideales_entrenamiento, info_partido,
                        by = "DiputadoId", all = FALSE)
ideales_partido[, mediana_partido := median(theta_train, na.rm = TRUE),
                by = partido]
ideales_partido[, distancia_partido := abs(theta_train - mediana_partido)]

# Convertir solo la submuestra de TEST a formato largo.
test_dt <- as.data.table(test)
test_dt[, DiputadoId := as.character(rownames(test))]
long <- melt(test_dt,
             id.vars = "DiputadoId",
             variable.name = "votacion",
             value.name = "voto",
             variable.factor = FALSE)

long <- merge(long, info_partido, by = "DiputadoId")
long <- long[!is.na(voto)]

# Mayoría del partido excluyendo el propio voto (leave-one-out).
# Evita que la decision del diputado determine mecanicamente el referente.
long[, `:=`(votos_favor = sum(voto == 1),
            votos_validos = .N), by = .(votacion, partido)]
long[, `:=`(otros_favor = votos_favor - voto,
            otros_validos = votos_validos - 1)]

# Exigir al menos otros tres parlamentarios del mismo partido,
# y excluir empates en el resto de la bancada.
long <- long[
  otros_validos >= 3 & (2 * otros_favor != otros_validos)
]
long[, mayoria_otros := as.integer(2 * otros_favor > otros_validos)]
long[, discrepancia := as.integer(voto != mayoria_otros)]

# Una tasa por diputado evita presentar los votos como observaciones independientes.
resumen_diputados <- long[
  , .(tasa_discrepancia = mean(discrepancia),
      n_votos_evaluados = .N),
  by = .(DiputadoId, partido)
]
resumen_diputados <- merge(
  resumen_diputados,
  ideales_partido[, .(DiputadoId, theta_train, distancia_partido)],
  by = "DiputadoId"
)
resumen_diputados <- resumen_diputados[n_votos_evaluados >= 10]

print(summary(resumen_diputados$tasa_discrepancia))

g3 <- ggplot(resumen_diputados,
             aes(x = distancia_partido, y = tasa_discrepancia)) +
  geom_point(aes(size = n_votos_evaluados), alpha = 0.65) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30") +
  labs(x = "Distancia al centro estimado del partido (TRAIN)",
       y = "Proporcion de discrepancias en votos reservados (TEST)",
       title = "Posiciones y votaciones: asociacion descriptiva") +
  theme_minimal()
print(g3)

ajuste_descriptivo <- lm(
  tasa_discrepancia ~ distancia_partido,
  weights = n_votos_evaluados,
  data = resumen_diputados
)
print(summary(ajuste_descriptivo))

# Interpretacion: las posiciones se estiman sobre train y la tasa sobre test.
# AUN ASI: partido_1 puede variar dentro del periodo; las votaciones comparten
# choques y agendas; las posiciones pueden reflejar disciplina partidaria;
# no contamos con preferencias de los electores ni incentivos de reeleccion.
# No presentar el coeficiente como efecto causal de ideologia o accountability.

# Opcional: exportar resultados locales para trabajar en el informe de clase.
# fwrite(resumen_diputados, "sesion4_resultados_laboratorio.csv")
