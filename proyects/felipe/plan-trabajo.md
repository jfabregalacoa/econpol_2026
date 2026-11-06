# Felipe: plan de trabajo

Actualizado el 6 de noviembre de 2026.

**El proyecto.** ¿Por qué los municipios inauguran plazas y descuidan su mantención, y se acentúa ese sesgo cuando el alcalde no puede seguir en el cargo? La base es el horizonte de apropiación del capítulo 2 (Dal Bó y Rossi, 2011), aplicado a la variación que creó el límite a la reelección de la Ley 21.238 (2020): 69 alcaldes no pudieron repostular en 2024. El entregable es el informe en `informe/`, que parte de las notas de Aníbal (`notes-felipe.md`).

**Roles.** La interpretación de los resultados y su redacción son de Felipe. Claude prepara datos, estimaciones, tablas, figuras, derivaciones formales y la descripción técnica de lo que se estimó, y discute las lecturas posibles, pero no redacta la interpretación del informe.

## 1. Estado en una mirada

| Frente | Estado | Lo próximo |
|---|---|---|
| Modelo | Escrito en el informe: proposiciones 1 a 4, con y sin reelección. Falta la visibilidad. | Incorporar la visibilidad como eje, a la luz de los resultados (§3.1). |
| Datos | Base unificada lista: 345 comunas × 2008–2025 (SINIM + BIP + Servel). | Revisar la muestra de 200 obras y mejorar la medida de mantención (§3.2). |
| Estimación | H1, H2 y H3 estimadas: ninguna muestra el efecto que predice la "cuenta al sucesor". | Visibilidad, ciclo electoral, H4 a H6 y robustez (§3.3). |
| Informe | Borrador de las secciones 1 a 6 y 8; la de Resultados está vacía. | Felipe revisa el borrador y redacta Resultados con su interpretación (§3.4). |
| Presentación | La v4 refleja el proyecto antes de las estimaciones. | Actualizarla al final, con el informe (§3.5). |
| Coordinación | Todo está en la rama `felipe/plazas-mantencion`, sin pull request. | Revisión de Aníbal, datos de 2008, avisar a Camila y Abraham (§3.6). |

## 2. Resultados hasta ahora

Todas las estimaciones comparan las 69 comunas cuyo alcalde no podía repostular en 2024 con el resto, antes (2017–2020) y durante su último mandato (2022–2024), con efectos fijos de comuna y año y errores agrupados por comuna. Nada es estadísticamente distinto de cero.

| Hipótesis | Qué se estimó | Resultado | Script |
|---|---|---|---|
| H1: los impedidos mantienen menos | Si contratan mantención; gasto contratado por m² (138 comunas que contratan siempre) | Sin efecto en el margen extensivo; +23% en el intensivo (p = 0,13), sentido contrario a H1. Sin tendencias previas (p = 0,42). | `08_estimar_h1.R` |
| H3: los impedidos prefieren obra nueva a mejoramiento | Composición de lo inaugurable (Poisson, efectos fijos comuna × año) | −0,09 en espacio público (p = 0,77) y −0,09 con todas las obras municipales (p = 0,50). Descarta un sesgo fuerte hacia obras nuevas. | `09_estimar_h3.R` |
| H2: cuántas obras inaugurables | Conteos por tipo | Algo menos de obras nuevas (−10%) y los mismos mejoramientos, sin significancia. | `09_estimar_h3.R` |

**Lecturas posibles, para conversar** (la interpretación es de Felipe). Una lectura que surgió en la discusión: la "cuenta al sucesor" no aparece, y el patrón (menos obras nuevas, mismos mejoramientos) sería compatible con que domine el motivo electoral; la proposición 4 del informe anticipa que el resultado se invierte si la obra nueva se ve más que el mejoramiento. Otra posibilidad es que simplemente no haya efecto, o que la muestra no alcance para detectarlo. Todas descansan en estimaciones no significativas; la prueba de visibilidad (§3.3) ayuda a distinguirlas.

**Limitaciones de medición que pesan sobre H1.** SINIM solo registra la mantención contratada (entre 94 y 128 comunas por año reportan cero porque mantienen con personal propio), y los contratos de mantención son plurianuales, así que el gasto de 2022–2024 puede venir de decisiones del período anterior.

## 3. Próximos pasos por frente

Responsable sugerido entre corchetes. **Prioridad:** (A) alta, (M) media, (B) baja.

### 3.1 Modelo

1. (A) **Visibilidad.** Permitir que la obra nueva sea más visible que el mejoramiento ($\theta_N > \theta_R$) y derivar cuándo domina el motivo electoral. Es lo que sugieren los resultados y lo que pedía la predicción 4 de Aníbal. [Felipe + Claude]
2. (M) **Cercanía de la elección.** Formalizar que $\theta$ crece al acercarse la votación, para la predicción de ciclo de H2. [Claude]
3. (M) **Votantes estratégicos.** Decidir si basta con $\theta$ como forma reducida o se deriva la regla de voto (capítulo 4, Ferejohn). Decisión para Aníbal. [Felipe]
4. (B) **Continuidad de la coalición** (H5): el peso $\lambda$ ya está planteado; falta cerrarlo cuando haya pactos homologados.

### 3.2 Datos

1. (A) **Revisar a mano la muestra de 200 obras** (`datos/bip_ep_muestra_revision.csv`): llenar `tipo_revisado`, `es_espacio_publico` y `comentario`. [Felipe]
2. (A) **Mantención directa.** Buscar en SINIM una medida del personal o gasto de aseo y ornato, para cubrir a las comunas que mantienen con personal propio. [Claude]
3. (A) **Medida de visibilidad** para la heterogeneidad: densidad urbana, población, ruralidad o plazas céntricas (por ejemplo, nombres con "PLAZA DE ARMAS"). [Felipe + Claude]
4. (M) **Pactos homologados entre elecciones** (H5) y **afinidad política** con el gobernador regional (faltan los resultados de gobernador de 2021 y 2024) y con el gobierno central (Corvalán, Cox y Osorio, 2018, muestran que el gobierno central transfiere más en años electorales a los alcaldes de su coalición). [Claude]
5. (M) **Obras originadas por el gobierno regional** para la falsificación de H6: en el BIP, iniciativas con responsable GORE por comuna. [Claude]
6. (M) **Transferencias de SUBDERE** (PMU, PMB) desde el registro de la Ley 19.862, adaptando el script de Abraham sin modificar su carpeta. [Claude]
7. (M) **Contratos de mantención en Mercado Público**: fecha, monto y duración, para ver cuándo se renuevan y probar la regla de los dos tercios del concejo. Es la mejor forma de medir la decisión del alcalde sobre mantención. [Felipe + Claude; carga alta]
8. (B) **Cobertura del BIP**: revisar por qué hay menos filas en 2005–2010 y un salto en 2011.
9. (B) **IPC anual 2008–2025** para tablas descriptivas en pesos reales. Hoy los montos van en pesos corrientes; los efectos fijos de año absorben la inflación en las estimaciones.
10. (B) **Permisos de edificación del INE**, como control de loteos que crean plazas sin decisión municipal.

### 3.3 Estimación

1. (A) **Heterogeneidad por visibilidad** en H2 y H3: si domina el motivo electoral, la diferencia entre impedidos y el resto debe ser mayor donde inaugurar se ve más. [Claude]
2. (A) **Ciclo electoral** (H2): postulaciones según los años que faltan para la elección, comparando alcaldes que pueden y no pueden repostular. Usa todo el período 2008–2025. [Claude]
3. (M) **H4, cuenta al sucesor y mantención atrasada**: mantención y conservaciones del período siguiente en función de las obras nuevas y de la mantención del período anterior. [Claude]
4. (M) **H6, falsificación**: obras del gobierno regional, estudios y diseños, y alcaldes con margen previo muy amplio ("sin competencia real", de las notas de Aníbal). [Claude]
5. (M) **Robustez**: panel balanceado (pedido de Aníbal), estudio de eventos para H3, muestra de espacio público frente a todas las obras. [Claude]
6. (B) **H1 con mejores medidas**, cuando estén las del §3.2.

### 3.4 Informe

1. (A) **Revisión de Felipe** del borrador del informe y de los resultados. Las secciones actuales las redactó Claude a partir de lo conversado; Felipe decide qué conserva y reescribe con su voz lo que corresponda. [Felipe]
2. (A) **Sección de Resultados.** Claude prepara las tablas de H1, H2 y H3, la Figura 3 y una descripción técnica de lo estimado (muestras, especificaciones, limitaciones de medición). Felipe redacta la interpretación. [Felipe; apoyo de Claude]
3. (M) **Actualizar el modelo y las hipótesis** con la visibilidad (§3.1). Claude hace las derivaciones; Felipe decide el argumento y lo redacta.
4. (M) **Sección de Datos**: describir la base unificada y la medición en dos márgenes de la mantención. [Claude, parte técnica]
5. (B) **Disposición transitoria de la Ley 21.238**: confirmar el texto y si hubo alcaldes impedidos en 2021.

### 3.5 Presentación

1. (M) **Actualizar la v4** cuando el informe tenga resultados: cuatro tipos de intervención, modelo con reelección (proposiciones 1 a 4), hipótesis H1 a H6, figura del BIP y resultados. Sin contenido tipo bitácora. Claude arma el diseño y los gráficos; las conclusiones salen de la redacción de Felipe en el informe. [Claude + Felipe]

### 3.6 Coordinación

1. (A) **Revisión de Aníbal**: el modelo (proposiciones 1 a 4) es una propuesta propia y conviene validarlo antes de seguir; también los resultados y la lectura provisional. [Felipe]
2. (A) **Elección de 2008 por Ley de Transparencia** al Servel (los sitios históricos están caídos). Texto sugerido en la conversación del 6 de noviembre. [Felipe]
3. (M) **Avisar a Camila y Abraham** que los datos del Servel procesados están en `datos/servel_alcaldes_*.csv` de esta rama. [Felipe]
4. (M) **Pull request** de `felipe/plazas-mantencion` a `main` cuando el informe esté listo para revisión del profesor. [Felipe]

## 4. Decisiones abiertas

1. ¿El motivo electoral pasa a ser el mecanismo central del informe, en vez de la cuenta al sucesor?
2. ¿Votantes como forma reducida ($\theta$) o modelados explícitamente?
3. ¿Mercado Público entra en esta etapa? Es la mejor medida de la decisión sobre mantención, pero la de más trabajo.
4. ¿Qué medida de visibilidad?
5. ¿La conservación del BIP se trata como inaugurable o como huella de mantención atrasada? (Hoy, lo segundo.)

## 5. Inventario

### Scripts (desde `proyects/felipe/`)

| Script | Qué hace | Produce |
|---|---|---|
| `01_descargar_bip.R` | Versión inicial de Aníbal: BIP 2019–2027 en CSV. Reemplazado por el 05 (cuenta la misma obra cada año que repostula). | `datos/bip_municipal.csv.gz`, `datos/bip_panel_comuna_anio.csv` |
| `02_extraer_sinim.R` | Extrae las variables de SINIM desde el panel de la ayudantía (material de Aníbal, no está en el repositorio). | `datos/sinim_felipe.csv` |
| `03_figura1_bip.R` | Figura 1 de las notas de Aníbal. Reemplazada por la 06. | `figs/fig1_bip_tipos.png` |
| `04_servel_alcaldes.R` | Elecciones de alcalde 2012–2024: candidatos, alcalde en ejercicio, repostulación, períodos seguidos, impedidos. | `datos/servel_alcaldes_*.csv` |
| `05_bip_espacio_publico.R` | BIP histórico: obras municipales por tipo, una por código, comuna por nombre del municipio. | `datos/bip_ep_*`, `datos/bip_todas_panel_comuna_anio.csv` |
| `06_figura2_bip_ep.R` | Obras de espacio público por año y tipo, con las elecciones. | `figs/fig2_bip_ep_tipos.png` |
| `07_panel_comuna_anio.R` | Une SINIM, BIP y Servel en la base comuna-año. | `datos/panel_comuna_anio.csv` |
| `08_estimar_h1.R` | H1: diferencias en diferencias y estudio de eventos para la mantención. | `datos/h1_resultados.csv`, `figs/fig3_h1_eventos.png` |
| `09_estimar_h3.R` | H3 y H2: composición y conteos de obras inaugurables, en dos muestras. | `datos/h3_resultados.csv` |

Para regenerar todo, en orden: `04`, `05`, `06`, `07`, `08`, `09`. El `05` necesita el BIP histórico en `cache/` y el `04`, los archivos del Servel en `fuentes/servel/` (ninguno está en git; ver §6).

### Carpetas

| Carpeta | Contenido | ¿En GitHub? |
|---|---|---|
| `informe/` | Informe en Quarto (`informe.qmd`) y su PDF | Sí |
| `scripts/` | Un script numerado por paso | Sí |
| `datos/` | Bases procesadas | Sí |
| `figs/` | Figuras | Sí |
| `fuentes/sinim/` | Exportación de SINIM 2013–2024 (en pesos de 2023) | Sí |
| `fuentes/servel/` | Archivos originales del Servel (140 MB) | No |
| `cache/` | BIP histórico (330 MB) y archivos descomprimidos | No |
| `mapeo-institucional/` | Mapeo de las 28 vías para construir, recuperar o mantener plazas | Sí |
| `presentacion/` | Presentación (v4 vigente, v3 anterior) | Sí |
| `local/` | Archivos personales | No |

Documentos: `notes-felipe.md` (notas de Aníbal, base del informe; no se modifican), `hallazgos-mapeo-institucional.md` (qué implica el mapeo para los datos) y este plan.

## 6. Fuentes de datos

| Fuente | De dónde | Cobertura | Notas |
|---|---|---|---|
| BIP histórico (MDSF) | [CKAN del MDSF](https://bid-ckan.ministeriodesarrollosocial.gob.cl/dataset/proyectos-de-inversion-rdata), foto mensual en `.rdata` | Años presupuestarios 1997–2027 | Se usa la foto de octubre de 2026. Mide lo que el alcalde postula, no lo que recibe. |
| SINIM | Panel de la ayudantía y exportación en `fuentes/sinim/` | 2001–2025 y 2013–2023 | La exportación viene en pesos de 2023; el script 07 la pasa a corrientes. |
| Servel | Archivos "Alcaldes_Datos_Eleccion" en `fuentes/servel/` | 2012, 2016, 2021, 2024 | 2008 no está disponible en línea; pedir por transparencia. |
| Transferencias Ley 19.862 | [registros19862.gob.cl](https://registros19862.gob.cl/reporte/transferencias) | 2014– | Las del gobierno regional están en la carpeta de Abraham; faltan las de SUBDERE. |
| Mercado Público | [Descargas OCDS](https://datos-abiertos.chilecompra.cl/descargas/procesos-ocds) o [API](https://www.chilecompra.cl/api/) | — | Pendiente. |

## 7. Notas técnicas

- **Unidad y claves.** Comuna × año, CUT de 5 dígitos con ceros a la izquierda. Antártica no está en SINIM y queda fuera.
- **Comuna en el BIP.** Se asigna por el nombre del municipio responsable, porque los códigos cambiaron con las reformas territoriales (Arica y Parinacota y Los Ríos en 2007, Marga Marga en 2010, Ñuble en 2018). En 101 de 240.000 filas el código apunta a otra comuna: son obras del municipio fuera de su territorio y quedan en la comuna del municipio.
- **Conteo de obras.** Cada código BIP una vez, en su año de primera aparición. La marca `NUEVO` no sirve: 14.721 códigos aparecen como `NUEVO` en más de un año.
- **Tiempo en el BIP.** El año es el presupuestario; la postulación suele hacerse el año anterior. Las estimaciones asignan cada obra al alcalde en ejercicio en el año presupuestario − 1.
- **Alcalde de cada año.** El que estaba en el cargo el 1 de enero. 2021 es año de transición (el electo en 2016 gobernó hasta el 28 de junio) y se excluye de las estimaciones.
- **Mismo alcalde entre elecciones.** Mismos dos apellidos y al menos un nombre de pila en común. Separa a hermanos con los mismos apellidos (Río Claro, Pemuco) y da 69 impedidos en 2024, igual que la prensa.
- **Campos del BIP que no sirven.** `EBI_INSTITUCION_FP` y `EBI_INSTITUCION_FI` traen al evaluador (MDS o SEREMI), no a quien formula ni a quien financia.
