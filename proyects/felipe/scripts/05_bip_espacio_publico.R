# Obras municipales de espacio público en el BIP histórico (1997-2027): una fila por obra y panel comuna-año.
#
# Uso (desde proyects/felipe/):
#   Rscript scripts/05_bip_espacio_publico.R cache/bip_historico/inversiones_202610.rdata datos/ datos/sinim_felipe.csv
#
# El .rdata se descarga del Banco Integrado de Proyectos del MDSF (dataset "proyectos-de-inversion-rdata",
# foto mensual) en https://bid-ckan.ministeriodesarrollosocial.gob.cl/dataset/proyectos-de-inversion-rdata
#
#   1. Se queda con las iniciativas cuyo responsable es una municipalidad (excluye asociaciones de municipios).
#   2. Asigna la comuna (CUT actual) por el nombre del municipio responsable, porque el código de comuna del
#      BIP cambia con las reformas territoriales (Arica y Parinacota y Los Ríos en 2007, Marga Marga en 2010,
#      Ñuble en 2018). Si el nombre no calza, usa el código si es un CUT vigente.
#   3. Marca las obras de espacio público (plazas, parques, áreas verdes, paseos peatonales, espacios
#      públicos) y las clasifica por la primera palabra del nombre:
#        nueva          CONSTRUCCION, INSTALACION
#        mejoramiento   MEJORAMIENTO, REPOSICION, AMPLIACION, HABILITACION, NORMALIZACION, RESTAURACION, RECUPERACION
#        conservacion   CONSERVACION, MANTENCION, MANTENIMIENTO, REPARACION
#        otro           estudios, diseños, adquisiciones y el resto
#   4. Cuenta cada obra una sola vez, en el año en que aparece por primera vez (la marca NUEVO del BIP no
#      identifica la primera postulación). Las obras que ya aparecen en 1997 pueden venir de antes.
#   5. Escribe:
#      - bip_ep_obras.csv.gz: una fila por obra (código BIP).
#      - bip_ep_panel_comuna_anio.csv: comuna x año de primera postulación x tipo, con ceros.
#      - bip_ep_muestra_revision.csv: 200 obras al azar para revisar a mano la clasificación.

suppressMessages({library(dplyr); library(readr); library(stringi); library(tidyr)})

args   <- commandArgs(TRUE)
entrada <- if (length(args) >= 1) args[1] else "cache/bip_historico/inversiones_202610.rdata"
salida  <- if (length(args) >= 2) args[2] else "datos"
sinim   <- if (length(args) >= 3) args[3] else "datos/sinim_felipe.csv"
dir.create(salida, showWarnings = FALSE, recursive = TRUE)

norm  <- function(s) toupper(trimws(gsub("\\s+", " ", stri_trans_general(s, "Latin-ASCII"))))
clave <- function(s) gsub("[^A-Z]", "", norm(s))

# 1. Cargar y filtrar ----------------------------------------------------------------
e <- new.env(); load(entrada, envir = e); d <- as.data.frame(e[[ls(e)[1]]]); rm(e)
cat("Filas en el BIP histórico:", nrow(d), "\n")
resp <- norm(d$EBI_INS_RESPONSABLE)
d <- d[grepl("MUNICIPALIDAD", resp) & !grepl("ASOCIACION", resp), ]
cat("Filas con responsable municipal:", nrow(d), "\n")

# 2. Comuna por nombre del municipio ------------------------------------------------------
cuts <- read_csv(sinim, col_types = cols(cut = "c"), show_col_types = FALSE) %>%
  distinct(cut, comuna) %>% mutate(k = clave(comuna)) %>% distinct(k, .keep_all = TRUE)
# Nombres del BIP que no calzan con SINIM (agregar aquí si aparecen nuevos).
manual <- c(PAIHUANO = "PAIGUANO", LLAYLLAY = "LLAILLAY", MARCHIGUE = "MARCHIHUE", COIHAIQUE = "COYHAIQUE",
            AISEN = "AYSEN", TREHUACO = "TREHUACO", LACALERA = "CALERA", OHIGGINS = "OHIGGINS",
            NAVIDAD = "NAVIDAD", CABODEHORNOSEXNAVARINO = "CABODEHORNOS", CABODEHORNOS = "CABODEHORNOS",
            PADRELASCASAS = "PADRELASCASAS", ALTOBIOBIO = "ALTOBIOBIO", TILTIL = "TILTIL")
nombre_mun <- norm(d$EBI_INS_RESPONSABLE)
nombre_mun <- sub("^.*MUNICIPALIDAD (DE )?", "", nombre_mun)       # conserva artículos: LA UNION, LOS LAGOS
nombre_mun <- sub("\\(.*\\)|REGION .*$", "", nombre_mun)           # quita "(REGION XIV)", "REGION DE LOS RIOS"
k <- clave(nombre_mun); k <- ifelse(k %in% names(manual), manual[k], k)
d$cut <- cuts$cut[match(k, cuts$k)]
cod <- sprintf("%05d", suppressWarnings(as.integer(d$CMN_CLAVE)))
# Control: cuando el código del BIP es un CUT vigente, debería coincidir con la comuna asignada por nombre.
dif <- !is.na(d$cut) & cod %in% cuts$cut & cod != d$cut
cat("Filas donde el nombre y un código vigente discrepan:", sum(dif), "\n")
if (any(dif)) print(head(as.data.frame(count(d[dif, ], EBI_INS_RESPONSABLE, CMN_CLAVE, cut, sort = TRUE)), 10))
por_codigo <- is.na(d$cut) & cod %in% cuts$cut
d$cut[por_codigo] <- cod[por_codigo]
sin <- d %>% filter(is.na(cut)) %>% count(EBI_INS_RESPONSABLE, sort = TRUE)
cat("Filas asignadas por nombre:", sum(!is.na(d$cut)) - sum(por_codigo), " por código:", sum(por_codigo),
    " sin comuna:", sum(is.na(d$cut)), "\n")
if (nrow(sin) > 0) { cat("Municipios sin comuna (revisar):\n"); print(head(as.data.frame(sin), 20)) }

# 3. Espacio público y tipo de obra ----------------------------------------------------------
N <- norm(d$EBI_NOMBRE)
d$espacio_publico <-
  grepl("\\bPLAZA|PLAZOLETA|AREAS? VERDES?|\\bPARQUE|ESPACIOS? PUBLICOS?|PASEO PEATONAL", N) &
  !grepl("ESTACIONAMIENTO|PARQUE (INDUSTRIAL|EOLICO|FOTOVOLTAICO|AUTOMOTRIZ|VEHICULAR)|VEHICUL|CEMENTERIO", N)
d$proceso <- sub(" .*", "", N)
d$tipo <- case_when(
  d$proceso %in% c("CONSTRUCCION", "INSTALACION") ~ "nueva",
  d$proceso %in% c("MEJORAMIENTO", "REPOSICION", "AMPLIACION", "HABILITACION", "NORMALIZACION",
                   "RESTAURACION", "RECUPERACION") ~ "mejoramiento",
  d$proceso %in% c("CONSERVACION", "MANTENCION", "MANTENIMIENTO", "REPARACION") ~ "conservacion",
  TRUE ~ "otro")
d$anio <- as.integer(d$EBI_ANO_POSTULA)
num <- function(x) suppressWarnings(as.numeric(x))

# 4. Una fila por obra -----------------------------------------------------------------------
obras <- d %>%
  filter(espacio_publico, !is.na(cut)) %>%
  arrange(EBI_CODIGO, anio) %>%
  group_by(codigo_bip = EBI_CODIGO) %>%
  summarise(anio_primera = first(anio), anio_ultima = last(anio), n_anios = n_distinct(anio),
            cut = first(cut), responsable = first(EBI_INS_RESPONSABLE), nombre = first(EBI_NOMBRE),
            proceso = first(proceso), tipo = first(tipo), etapa_primera = first(EBI_ETAPA_POSTULA),
            fuente_primera = first(EBI_FUENTES_FINAN),
            fecha_postulacion = suppressWarnings(min(as.Date(EBI_FECHA_POSTULACION_SNI), na.rm = TRUE)),
            costo_total_mm = first(num(EBI_COSTO_TOTAL)),
            rs_algun_anio = any(EBI_RATE %in% "RS"),
            asignado_algun_anio = any(num(EBI_ASIGNADO_VIGENTE) > 0, na.rm = TRUE),
            gasto_algun_anio = any(num(EBI_GASTO_VIGENTE) > 0, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(fecha_postulacion = if_else(is.finite(fecha_postulacion), fecha_postulacion, as.Date(NA)))
cat("\nObras de espacio público:", nrow(obras), " en", n_distinct(obras$cut), "comunas\n")
print(table(obras$tipo))

# 5. Panel comuna-año con ceros ------------------------------------------------------------------
anios <- seq(min(obras$anio_primera), max(obras$anio_primera))
panel <- obras %>%
  count(cut, anio = anio_primera, tipo) %>%
  pivot_wider(names_from = tipo, values_from = n, names_prefix = "n_", values_fill = 0) %>%
  right_join(expand_grid(cut = cuts$cut, anio = anios), by = c("cut", "anio")) %>%
  mutate(across(starts_with("n_"), ~ coalesce(.x, 0L))) %>%
  left_join(obras %>% group_by(cut, anio = anio_primera) %>%
              summarise(costo_nueva_mm = sum(costo_total_mm[tipo == "nueva"], na.rm = TRUE),
                        costo_mejoramiento_mm = sum(costo_total_mm[tipo == "mejoramiento"], na.rm = TRUE),
                        costo_conservacion_mm = sum(costo_total_mm[tipo == "conservacion"], na.rm = TRUE),
                        .groups = "drop"), by = c("cut", "anio")) %>%
  mutate(across(starts_with("costo_"), ~ coalesce(.x, 0))) %>%
  left_join(select(cuts, cut, comuna), by = "cut") %>%
  select(cut, comuna, anio, any_of(c("n_nueva", "n_mejoramiento", "n_conservacion", "n_otro")), starts_with("costo_")) %>%
  arrange(cut, anio)

# 6. Muestra para revisión manual --------------------------------------------------------------------
set.seed(2026)
muestra <- obras %>%
  group_by(tipo) %>% slice_sample(n = 50) %>% ungroup() %>%
  select(codigo_bip, anio_primera, responsable, nombre, tipo) %>%
  mutate(tipo_revisado = "", es_espacio_publico = "", comentario = "")

write_csv(obras, file.path(salida, "bip_ep_obras.csv.gz"))
write_csv(panel, file.path(salida, "bip_ep_panel_comuna_anio.csv"))
write_csv(muestra, file.path(salida, "bip_ep_muestra_revision.csv"))
cat("\nEscrito en", salida, ": bip_ep_obras.csv.gz, bip_ep_panel_comuna_anio.csv (", nrow(panel),
    "filas), bip_ep_muestra_revision.csv\n")
