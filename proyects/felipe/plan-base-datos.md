# Felipe: plan para armar la base de datos

6 de noviembre de 2026. Plan, no ejecución: nada de esto está descargado todavía.

Se apoya en `hallazgos-mapeo-institucional.md`. La idea es medir por separado lo que el alcalde **inaugura** ($k$, obra externa) y lo que **mantiene** ($m$, gasto propio), y unirlo con el **horizonte** del alcalde.

## Estado (actualizado el 6 de noviembre)

**Bloque B, BIP histórico: verificado.** La foto de octubre de 2026 (`cache/bip_historico/inversiones_202610.rdata`, 330 MB, objeto `base_bip`: 521.043 filas × 86 columnas) cubre los **años presupuestarios 1997–2027**, con entre 5.000 y 10.500 filas de responsable municipal por año. Abarca **siete elecciones municipales** (2000, 2004, 2008, 2012, 2016, 2021 y 2024), no dos. Precisiones:
- `EBI_INSTITUCION_FP` y `EBI_INSTITUCION_FI` **no** identifican a quien formula ni a quien financia: casi siempre traen al evaluador (MDS o SEREMI de Desarrollo Social). Para separar el origen municipal del regional se usa `EBI_INS_RESPONSABLE`.
- `EBI_FECHA_POSTULACION_SNI` viene como fecha (POSIXct): permite fechar la postulación al día.
- `EBI_RATE` está en el 61% de las filas municipales (RS, FI, OT…).
- Hay que revisar los cambios de cobertura: menos filas en 2005–2010 y un salto en 2011.
- Espacio público municipal, por año de primera aparición del código: entre 30 y 110 obras nuevas por año hasta 2010, y entre 65 y 250 desde 2011. La conservación sigue siendo escasa.

**Bloque C, Servel: script listo.** `scripts/04_servel_alcaldes.R` escribe `datos/servel_alcaldes_candidatos.csv` y `datos/servel_alcaldes_comuna.csv` (346 comunas × 4 elecciones). Detalles:
- Un alcalde es la misma persona entre elecciones si coinciden los dos apellidos y al menos un nombre de pila. El Servel a veces registra solo el nombre de uso, y la regla separa a hermanos con los mismos apellidos (Río Claro, Pemuco).
- Resultado: **69 alcaldes impedidos de repostular en 2024**, igual que la cifra de prensa.
- Antártica queda sin CUT porque no está en SINIM.
- Falta 2008. Sin esa elección, en 2012 no se sabe quién era alcalde en ejercicio, y los períodos seguidos parten censurados.

**Archivos de origen** (en `fuentes/`):

- **`fuentes/servel/`: archivos del Servel de 2012, 2016, 2021 y 2024; base del bloque C** (ver arriba). La elección de 2008 se agrega aquí cuando esté descargada.
- **`fuentes/sinim/sinim_municipios_2013_2024.xlsx` (SINIM, 345 comunas, 2013–2023; 2024 viene vacío): amplía el bloque A.** Trae unas 500 variables, entre ellas IADM93–95, `BSMJSC` (mantención de jardines **de la comunidad**, separada de las dependencias municipales: es una medida más limpia de $m$) e `IADM15`/`IADM16` (porcentaje de la inversión con recursos propios o externos: sirve para la explicación financiera). Es más corto que el panel de Aníbal (2001–2025), así que conviene combinarlos por CUT y año. Usa "No Recepcionado" para los datos faltantes.

**Estructura de la carpeta `proyects/felipe/`:**

| Carpeta | Contenido |
|---|---|
| `fuentes/` | Archivos originales tal como se descargaron (Servel, SINIM) |
| `cache/` | Descargas grandes y archivos descomprimidos (BIP histórico, Servel); se regeneran y no se suben a git |
| `datos/` | Bases procesadas por los scripts |
| `scripts/` | Un script numerado por paso |
| `figs/` | Figuras |
| `mapeo-institucional/` | Mapeo de plazas públicas: informe PDF, versión editable, diagramas y fuentes |
| `presentacion/` | Presentación del proyecto |

## Estructura de la base

- **Unidad:** comuna × año (345 comunas, clave CUT de 5 dígitos con ceros a la izquierda).
- **Base auxiliar:** comuna × mes, solo para Mercado Público y transferencias (sirve para fechar respecto de la elección).
- **Período objetivo:** 2008–2025 (cinco elecciones municipales: 2008, 2012, 2016, 2021 y 2024), condicionado a lo que entregue el BIP histórico (bloque B).
- **Montos:** en pesos reales del mismo año (IPC del Banco Central), además de por habitante o por m².

## Bloques de datos

### A. Mantención ($m$): SINIM — prioridad alta

- **Qué:** IADM120 (gasto en mantención de jardines), MAVM (m² de áreas verdes con mantención), IADM93–95 (mantención de alumbrado, semáforos y señalización), más los controles que ya están (población, ruralidad, ingresos, FCM, inversión).
- **De dónde:** portal [datos.sinim.gov.cl](https://datos.sinim.gov.cl). El panel actual sale de `playground/datos-apoyo/sinim/`, que es material del ayudante y **no está en el repositorio**. Hay dos opciones: (1) pedirle a Aníbal el `sinim_panel_largo.csv` actualizado con IADM93–95, o (2) usar el cliente no oficial `mcp-sinim` de Python, que descarga por código de variable y tiene la opción `corrmon=True` para valores reales.
- **Esfuerzo:** bajo. Es el bloque más fácil y el más importante.

### B. Inauguraciones ($k$): BIP histórico — prioridad alta, verificar primero

- **Qué:** el MDSF publica una base **histórica** del BIP en `.rdata`, con una foto mensual (la última, de octubre de 2026, pesa unos 300 MB): [dataset en CKAN](https://bid-ckan.ministeriodesarrollosocial.gob.cl/dataset/proyectos-de-inversion-rdata). Los CSV que usamos hoy cubren solo 2019–2027.
- **Lo primero que hay que verificar:** desde qué año parte `EBI_ANO_POSTULA`. Si llega a 2008 o antes, el BIP pasa de dos a cinco elecciones y cambia todo el diseño.
- **Campos que no tenemos hoy y que el mapeo vuelve útiles** (según el [diccionario](https://bid-ckan.ministeriodesarrollosocial.gob.cl:443/dataset/d6caf65d-7ef4-4773-b01d-9f6262665468/resource/64b15f7a-e259-4deb-b098-09646f88c8b1/download/diccionario.csv)):
  - ~~`EBI_INSTITUCION_FP` frente a `EBI_INSTITUCION_FI`~~: verificado, no sirve, porque traen al evaluador. El origen (municipio en R02 o GORE en R03) se obtiene de `EBI_INS_RESPONSABLE`.
  - `EBI_FECHA_POSTULACION_SNI`, `EBI_FEC_RATE`: fechas exactas de postulación y resultado.
  - `EBI_RATE`: resultado de la evaluación (RS u otro).
  - `EBI_COSTO_LICITACION`, `EBI_DEVENGO_SIGFE`: indican si la obra llegó a contratarse y ejecutarse.
  - `EBI_VIDA_UTIL`, `EBI_DESCRIPCION`: la descripción permite clasificar mejor que solo la primera palabra del nombre.
- **Tareas al procesar:** primera aparición de cada código (no la marca `NUEVO`), corregir el patrón de espacio público (tildes, "espacio público", excluir bandejones viales) y revisar a mano una muestra de 200.
- **Esfuerzo:** medio. El archivo es grande pero nativo de R (`load()`).

### C. Horizonte del alcalde: Servel — prioridad alta, compartido

- **Qué:** resultados de alcalde por comuna (2004, 2008, 2012, 2016, 2021 y 2024): candidatos, votos, electo, partido y pacto. Con eso se construye:
  - si el alcalde repostula, su margen y su número de mandatos consecutivos;
  - **impedido de repostular en 2024** (Ley 21.238): se calcula con los electos de 2012, 2016 y 2021, en vez de la cifra de prensa de 69;
  - afinidad política con el gobernador (elecciones de gobernador de 2021 y 2024).
- **De dónde:** no encontré un CSV oficial descargable. Servel tiene resultados históricos consultables en su sitio y [elecciones.servel.cl](https://elecciones.servel.cl) para 2024. Hay que revisar a mano si cada elección ofrece Excel. Si no, se puede pedir por Ley de Transparencia (demora unos 20 días hábiles, así que conviene pedirlo ya).
- **Compartido:** Camila y Abraham necesitan exactamente lo mismo. Conviene que una sola persona lo arme para los tres proyectos.
- **Esfuerzo:** medio a alto, según el formato en que lo entregue Servel.

### D. Fondos externos para plazas: transferencias de la Ley 19.862 — prioridad media

- **Qué:** transferencias de capital a municipios desde el GORE (FRIL, FNDR) y desde SUBDERE (PMU, PMB). Sirven para medir el **financiamiento externo disponible** (control de la explicación financiera) y captar lo que el BIP no ve (PMU).
- **De dónde:** [registros19862.gob.cl](https://registros19862.gob.cl/reporte/transferencias). El script de Abraham (`proyects/abraham/scripts/01_descargar_transferencias.R`) ya lo hace para emisores GORE (clase 7). Para SUBDERE basta cambiar el filtro a clase 1 ("Ministerio o servicio público"), subclase "Subsecretaría de Desarrollo Regional y Administrativo".
- **Limitación:** en los datos del GORE, el objetivo suele decir solo "FRIL", sin el objeto. Sirve para montos por instrumento, no para identificar plazas.
- **Esfuerzo:** bajo (reutiliza código existente). Las transferencias GORE→municipio ya están descargadas.

### E. Contratos y fechas: Mercado Público — prioridad media, fase 2

- **Qué:** licitaciones municipales de (1) mantención de áreas verdes (monto, **duración del contrato**, fecha) y (2) obras de plazas (fecha de adjudicación). Permite fechar al mes y probar la regla de los dos tercios del concejo para contratos que exceden el período.
- **De dónde:** descarga masiva en formato OCDS desde [datos-abiertos.chilecompra.cl](https://datos-abiertos.chilecompra.cl/descargas/procesos-ocds), o la [API de ChileCompra](https://www.chilecompra.cl/api/) (requiere ticket con Clave Única). Ojo: ChileCompra está licitando una plataforma que reemplazará la API, así que el formato puede cambiar.
- **Esfuerzo:** alto (archivos grandes, clasificación por texto). Hacerlo solo si los bloques A–C funcionan.

### F. Controles — prioridad baja

- **Permisos y recepciones de edificación del INE:** controlan por loteos que generan plazas sin decisión municipal (vía R18).
- **IPC y UTM** (Banco Central y SII): para deflactar y convertir los umbrales en UTM del mapeo.

## Orden sugerido

1. **Verificación (1–2 días):** abrir el BIP histórico y ver la cobertura de años; revisar qué entrega Servel y, si no hay archivos, enviar la solicitud por transparencia; pedirle a Aníbal el panel SINIM.
2. **Núcleo:** A (SINIM) + B (BIP) + C (Servel), unidos por CUT y año.
3. **Complementos:** D (transferencias), y E (Mercado Público) si hay tiempo.

## Reparto propuesto

| Tarea | Responsable sugerido | Comentario |
|---|---|---|
| A. SINIM | Felipe (o Aníbal, si es solo actualizar su panel) | Rápido, desbloquea la variable de mantención |
| B. BIP histórico | Felipe + Claude | Es lo que más cambia el diseño. Verificar años antes de procesar |
| C. Servel | Una persona para los tres proyectos (Felipe, Camila, Abraham) | Coordinar con ellos; pedir por transparencia si no hay archivos |
| D. Transferencias SUBDERE | Felipe, adaptando el script de Abraham | Poco trabajo |
| E. Mercado Público | Fase 2, por decidir | Solo si el núcleo funciona |
| Diccionario y unión final | Felipe + Claude | Un script por fuente en `scripts/` y una tabla final comuna-año |

## Decisiones antes de partir

1. ¿El período es 2008–2025 (SINIM, cinco elecciones) aunque el BIP cubra menos? Depende del paso 1.
2. ¿Quién arma Servel para los tres proyectos?
3. ¿Mercado Público entra en esta etapa o queda para después?
