# Datos de la sesión 5

Fuente: Brollo, Nannicini, Perotti y Tabellini, depósito oficial
[openICPSR E112657, V1](https://doi.org/10.3886/E112657V1).

Los datos y los `.do` oficiales no están incluidos en este repositorio. La descarga
consultada el 26 de octubre de 2026 redirige al inicio de sesión de ICPSR.
Obtenga el paquete desde el depósito con su propia cuenta y respete sus términos.
Conserve su estructura bajo `data/originales/`; esa carpeta y `data/derivados/`
están excluidas de Git. Ningún script contiene credenciales.

## Evidencia disponible y verificación pendiente

Las notas de las tablas 8 y 9 (pp. 1791–1792) indican controles de macroregión y
período, un polinomio de tercer orden de población normalizada y errores estándar
agrupados por municipio. La fila Overall effect reúne siete umbrales, 2.877
observaciones y elecciones donde el incumbente busca reelegirse. Las transferencias
efectivas y teóricas están en unidades de 100.000 reales a precios de 2000.
College es la proporción de oponentes con título universitario.

Las ecuaciones 5–7 mencionan efectos de estado; las notas de las tablas 4, 5, 8 y 9
mencionan macroregión. Los nombres reales de los `.do`, archivos de datos,
variables, filtros, ponderaciones, transformaciones, fórmula de normalización y
posibles interacciones del polinomio no pudieron comprobarse sin el paquete.
El código R del capítulo es provisional y permanece con `eval: false`.

## Importación

Desde la raíz del proyecto, cargue
`source("scripts/ECONPOL_Sesion_5_Importacion_R.R")`.
La función `importar_brollo(archivo, armonizar, verificacion)` lee un archivo Stata
con `haven`, aplica una función de armonización aportada a partir de los `.do`
revisados y escribe `data/derivados/brollo_sesion05_seleccion.rds`.
La interfaz esperada se describe en el capítulo. Si se requieren uniones de
archivos, deben formar parte de esa función y documentarse.

`verificacion` es una lista de textos con los campos `archivos_do`, `variables`,
`filtros`, `ponderaciones`, `unidades`, `normalizacion`, `polinomio` y
`controles_geograficos`. Debe registrar decisiones verificadas en los originales.
La función incorpora esa documentación y el MD5 del archivo de entrada al RDS.
La función específica de armonización sigue pendiente; no se genera un RDS vacío
ni se sustituyen datos oficiales por simulaciones.

## Comparación de referencia

| Resultado | Coeficiente publicado | EE publicado | N publicado |
|---|---:|---:|---:|
| Primera etapa, tabla 8 | 0,732 | 0,024 | 2.877 |
| Forma reducida College, tabla 8 | -0,006 | 0,003 | 2.877 |
| IV College, tabla 9 | -0,008 | 0,004 | 2.877 |

La reconstrucción algebraica ejecutable calcula -0,006 / 0,732 = -0,008196721.
Este cociente usa cifras publicadas redondeadas. No constituye una estimación
con microdatos ni permite reconstruir el error estándar de 2SLS.
Cuando los originales estén disponibles, verifique cada especificación antes de
activar los chunks y compare coeficientes, errores estándar y muestras efectivas.
