# Felipe: hallazgos del mapeo institucional para elegir los datos

6 de noviembre de 2026.

Fuentes revisadas: `notes-felipe.md` (Aníbal, 30 de octubre), la presentación `Propuestas_Economia_Politica_Felipe_Arenas_v3.pptx` (diapositivas y notas) y el mapeo institucional de plazas públicas (`Plazas_publicas_Chile_diagramas_y_fuentes.zip`: 28 vías, 3 diagramas transversales y 42 fuentes). Además se revisaron los datos ya descargados en `datos/` para contrastar el mapeo con lo que efectivamente tenemos.

Advertencia sobre el mapeo: es una reconstrucción analítica hecha con GPT a partir de normas y documentos oficiales. No verifiqué cada fuente. Antes de citar un umbral o un procedimiento en el trabajo, hay que confirmarlo en la fuente original (las fichas indican el localizador S01–S42).

## 0. Resumen

1. **Construir y mantener se pagan con presupuestos distintos.** La obra nueva suele financiarla el GORE, SUBDERE o el MINVU. La mantención habitual es gasto corriente municipal. Por eso la restricción única $c_k k + c_m m = B$ del modelo no describe bien el caso: para el alcalde, la obra nueva es casi gratis y la mantención no.
2. **"Mantener" son tres cosas distintas.** Mantención habitual (riego, aseo, poda), conservación como inversión y conservación de parques del MINVU. Solo la primera es una decisión directa y recurrente del alcalde. La mejor medida es el gasto de SINIM en mantención de jardines, no la conservación del BIP.
3. **El BIP mide lo que el alcalde pide, no lo que recibe.** Él formula y postula, pero el gobernador y el CORE asignan. Sirve para medir la demanda del alcalde, siempre que se controle por el ciclo y la afinidad política del gobierno regional.
4. **Varias vías no pasan por el alcalde ni por el BIP:** cesiones de loteos, aportes urbanos, programas del MINVU y PMU. El stock de plazas de SINIM mezcla todas esas vías, así que no sirve como medida de la decisión del alcalde.
5. **Hay dos problemas en los datos actuales:** la marca `NUEVO` no identifica la primera postulación, y el BIP cubre solo dos elecciones (2021 y 2024). SINIM cubre cinco (2008–2024).
6. **Del mapeo sale una mejora del modelo.** Cada obra nueva crea una obligación futura de mantención. Si el alcalde probablemente no estará, esa carga la paga su sucesor. Es el mismo mecanismo de horizonte ($p$) de Dal Bó y Rossi, pero visto desde los costos.

## 1. Qué busca el trabajo (contexto)

**Notas de Aníbal.** La pregunta es por qué el gasto municipal se inclina por inaugurar obras y descuida la mantención, y si ese sesgo aumenta cuando el horizonte del alcalde es corto (año electoral, último mandato permitido). El modelo base es el de actividades con distintos horizontes de retorno del capítulo 2 (Dal Bó y Rossi, 2011): el alcalde reparte un presupuesto $B$ entre obra nueva $k$ y mantención $m$, con $B_R(k)=b_k k$ y $B_L(m)=\delta p\, b_m m$. Las predicciones son: más obra nueva cuando $p$ baja, en años electorales y en el último mandato. También se plantea una explicación rival: la obra nueva se paga con fondos externos y la mantención con fondos propios.

**Presentación.** Es una versión discreta del mismo mecanismo: hay dos intervenciones de igual costo y se elige una. La presentación agrega la visibilidad $v_j$ y separa el bienestar social ($W_j = B_{0j} + \beta B_{1j}$) del retorno político ($U_j = v_j B_{0j} + \delta p\, v_j B_{1j}$). El umbral es $p^* = v_N B / (\delta v_M H)$: se construye cuando $p<p^*$.

**Diferencias entre ambas versiones que conviene resolver:**

- La presentación supone costos iguales y que el electorado no es estratégico. Las notas suponen una restricción presupuestaria común. El mapeo muestra que ninguno de los dos supuestos se cumple: los costos que enfrenta el alcalde no son iguales y los presupuestos están separados (ver §2).
- La nota 11 de la presentación advierte: "No identifico automáticamente una elección próxima con un p más bajo". Las notas de Aníbal sí usan el año electoral como horizonte corto. Hay que decidir si la variable es **cercanía de la elección** (visibilidad: inaugurar antes de votar) o **probabilidad de continuar** (horizonte $p$: último mandato, margen). Son predicciones distintas y pueden ir en sentidos opuestos. La predicción 3 de las notas ya lo anticipa.

## 2. Hallazgos del mapeo y qué implican

### 2.1 Obra y mantención: presupuestos y decisores distintos

El mapeo lo repite en casi todas las fichas: *"Construcción, recuperación y mantención no son una sola cadena presupuestaria"*. La obra entra por R01–R22. Al terminar, la plaza se entrega al municipio (T02) y su mantención pasa a R24 (ejecución directa) o R25 (contrato), con presupuesto municipal. Varios programas lo explicitan:

- El DS 312 del MINVU (R07) excluye la mantención del costo de la obra.
- Los proyectos de Recuperación de Espacios Públicos de la SPD (R12) exigen un compromiso del alcalde o del concejo de financiar la mantención.
- PMU (R05) debe "prever mantención posterior con recursos propios".

**Implicancia para el modelo.** El alcalde no reparte un único $B$ entre $k$ y $m$. Para él, el costo de $k$ es casi cero cuando la obra se financia con FNDR, PMU o MINVU (solo paga la formulación y, a veces, un aporte). El costo de $m$ sale del presupuesto corriente. Esto no es solo una "explicación rival": cambia los precios relativos del modelo. Propuesta: modelar dos fuentes, con $k$ financiada desde fuera (con probabilidad de aprobación $q$) y $m$ con presupuesto propio $B_m$.

**La mejora que sugiere el mapeo.** Cada plaza nueva aumenta la mantención futura necesaria (R24: "la incorporación de nuevas plazas aumenta necesidades de personal, agua, energía, equipos e insumos"). Si se agrega un costo futuro $\delta\, p\, \gamma k$ que paga el alcalde solo si sigue en el cargo, un $p$ bajo hace la obra nueva aún más atractiva: el alcalde **se lleva el crédito hoy y le deja la cuenta al sucesor**. Es el mecanismo de Dal Bó y Rossi aplicado a los costos, y se puede contrastar en los datos: después de un período con muchas obras nuevas, debería subir el gasto en mantención del período siguiente.

### 2.2 Qué cuenta como "mantener" (decisión abierta 1)

| Tipo (mapeo) | Fichas | Quién decide | Financiamiento | Dónde se observa |
|---|---|---|---|---|
| Mantención habitual | R24, R25 | Alcalde y concejo (presupuesto); jefatura de áreas verdes | Gasto corriente municipal | SINIM `IADM120` (gasto en mantención de jardines) y m² con mantención; licitaciones en Mercado Público |
| Conservación como inversión | R26 (regional), R27 (sectorial) | Alcalde postula; GORE o MDSF clasifican; gobernador y CORE asignan | FNDR o sectorial | BIP, tipo `conservacion` |
| Conservación de parques | R28 (DS 112) | MINVU selecciona; SERVIU contrata | MINVU + aportes | Fuera del BIP municipal; solo parques de más de 2 ha |

**Recomendación.** La medida principal de $m$ debería ser la **mantención habitual (SINIM)**: es la decisión del alcalde que mejor calza con el modelo (recurrente, poco visible, con fondos propios). La conservación del BIP es otra cosa: es una inversión postulada a fondos externos y, como reparación mayor, también puede inaugurarse. R28 queda fuera.

**El mejoramiento cuenta como inaugurar.** Recuperar o mejorar una plaza (R07, R13–R15) se inaugura igual que una obra nueva. En la lógica de visibilidad, el contraste correcto es *inaugurable* (nueva + mejoramiento) frente a *no inaugurable* (mantención habitual). Separar nueva de mejoramiento tiene sentido para describir los datos, pero no como prueba del mecanismo.

### 2.3 El BIP mide demanda municipal; el GORE decide

En las vías regionales (R02–R04) el alcalde y la SECPLA formulan y postulan, y la cartera la priorizan el **gobernador** (propone) y el **CORE** (aprueba marcos y proyectos de más de 7.000 UTM). En PMU (R05), el gobernador además visa cada proyecto. T01: "RS, elegibilidad o resultado técnico habilitante no son una promesa de financiamiento".

**Implicancias:**

- Para medir la decisión del alcalde hay que usar la **postulación** (la primera aparición del código BIP), no el monto asignado. En los datos, `asignado_mm` está en el 30% de las filas y `gasto_mm` en el 12%.
- Lo que se financia depende del gobierno regional. Hay que controlar por **afinidad política entre alcalde y gobernador** y por el ciclo del gobernador. Ojo: las elecciones de gobernador de 2021 y 2024 coincidieron con las municipales, así que el ciclo regional y el municipal se confunden.

### 2.4 Vías que no pasan por el alcalde ni por el BIP

| Vía | Fichas | Por qué importa |
|---|---|---|
| Fondos propios municipales | R01 | Pueden estar exentos del SNI y no aparecer en el BIP |
| PMU y otras líneas SUBDERE | R05, R06, R13–R16 | Se tramitan en SUBDERE en Línea. PMU tiene exención de MDSF bajo 2.500 UTM. **Es probable que gran parte del PMU no esté en el BIP** |
| Programas MINVU | R07–R11 | Seleccionan el MINVU o el SERVIU, que suele ejecutar. No quedan en el BIP con responsable municipal |
| Seguridad (SPD) | R12 | Recursos asignados por sistema, en SIEVAP |
| Urbanizadores y aportes | R18–R21 | Plazas que crea un privado o un loteo y recibe la DOM |

**Implicancias:**

- **El stock de plazas de SINIM (`plazas_n`, `plazas_m2`) no mide la decisión del alcalde**: incluye cesiones de loteos (R18), aportes (R20, R21) y obras del MINVU. Además es autoinformado y se corrige con rezago. Úsese como control o descríbase, pero no como variable dependiente.
- **Los permisos de edificación y recepciones del INE** pueden servir para controlar por la expansión urbana (loteos) que genera plazas sin decisión municipal.
- **Para cubrir PMU y FRIL** está el registro de transferencias de la Ley 19.862, que ya existe en `proyects/abraham/datos/` (GORE) y en `proyects/camila/datos/` (municipal). Hay que revisar si incluye transferencias de SUBDERE con el objetivo en texto.

### 2.5 El calendario de una obra y la inauguración

T02 describe la secuencia: postulación → evaluación → asignación → licitación → contrato → ejecución → recepción contractual → recepción DOM → entrega al operador. Entre postular y cortar la cinta pueden pasar uno a tres años. Para inaugurar antes de una elección, la decisión se toma mucho antes.

**Implicancia.** La variable dependiente debe fecharse en la etapa que el alcalde controla y que da visibilidad: la **adjudicación o el término de obra** (Mercado Público, con fecha exacta), no el año presupuestario del BIP. En el BIP, la etapa (`DISEÑO`, `EJECUCION`) indica cuánto falta.

### 2.6 Un detalle útil: los contratos que exceden el período

R25 y la ley municipal (art. 65): los contratos de 500 UTM o más requieren acuerdo del concejo, y los que **exceden el período alcaldicio requieren dos tercios**. Los contratos de mantención de áreas verdes suelen ser plurianuales. Cerca del fin del mandato, al alcalde le cuesta más comprometer mantención de largo plazo: el horizonte también actúa a través de una regla. Se puede revisar en Mercado Público (duración y fecha de las licitaciones de áreas verdes según el año del ciclo).

### 2.7 Lo que el mapeo no prueba

El propio mapeo lo dice: *"Los procesos no prueban motivaciones electorales, negociación informal ni tiempos efectivos. Para estudiar esas conductas se requieren expedientes, actas, series de proyectos o entrevistas"*. El mapeo sirve para **elegir qué datos miden la decisión del alcalde**, no para contrastar el modelo.

## 3. Lo que muestran los datos ya descargados

Revisión rápida de `datos/bip_municipal.csv.gz` y `datos/sinim_felipe.csv`.

**Fuentes de financiamiento del BIP municipal (filas `NUEVO`):**

| Fuente | Filas |
|---|---:|
| FNDR | 50.874 |
| Sectorial | 7.401 |
| Municipal + FNDR | 538 |
| Solo municipal | 526 |
| Otras combinaciones | 324 |

El BIP municipal es prácticamente el mundo del FNDR (85%). Solo 390 códigos tienen financiamiento únicamente municipal. **No hay variación suficiente en la fuente para separar la explicación política de la financiera dentro del BIP**: esa separación tiene que salir de comparar el BIP (externo) con SINIM (propio).

**Espacio público, filas `NUEVO`, por tipo y fuente:**

| Tipo | FNDR | Sectorial | Municipal | Total |
|---|---:|---:|---:|---:|
| Nueva | 1.832 | 49 | 26 | 1.909 |
| Mejoramiento | 3.093 | 142 | 16 | 3.253 |
| Conservación | 144 | 61 | 10 | 215 |

La conservación de espacio público es muy poco frecuente en el BIP (215 filas en nueve años, varias repetidas). Con eso no se sostiene una variable dependiente comuna-año. Es otra razón para medir la mantención con SINIM.

**Problemas encontrados:**

1. **`NUEVO` no es "primera postulación".** En el BIP, `NUEVO` frente a `ARRASTRE` es una categoría presupuestaria: `NUEVO` significa que la iniciativa aún no tiene contratos ni gasto comprometido. De 30.657 códigos con alguna fila `NUEVO`, **14.721 aparecen como `NUEVO` en más de un año** (las que se postulan de nuevo sin financiamiento). La Figura 1 y la columna `n_nuevas` cuentan la misma obra varias veces. Corrección: usar el año de **primera aparición del código BIP**. Ese año está censurado en 2019: lo que aparece ese año puede venir de antes.
2. **La marca `espacio_publico` deja cosas fuera.** El patrón no reconoce "ESPACIO(S) PÚBLICO(S)" (1.009 filas no marcadas) ni algunas tildes ("ÁREA VERDE", "BANDEJÓN": 55 filas). Además capta bandejones viales que no son plazas. Hay que revisar el patrón y una muestra a mano. Hay 195 filas con `espacio_publico` vacío.
3. **El BIP cubre solo dos elecciones.** Los años presupuestarios 2019–2027 abarcan las elecciones de mayo de 2021 y octubre de 2024. Con efectos fijos de año, el "año electoral" casi no tiene variación propia. El límite de reelección empieza a operar en 2024, así que hay un solo episodio.
4. **SINIM sí cubre cinco elecciones.** `gasto_mantencion_jardines_miles` (IADM120) está para unas 340 comunas por año entre 2008 y 2025: elecciones de 2008, 2012, 2016, 2021 y 2024. `areas_verdes_mantencion_m2` va desde 2001. Es el panel más largo y el que mide mejor $m$.

## 4. Recomendación: con qué datos trabajar

**Núcleo (prioridad alta):**

| Concepto | Medida | Fuente | Por qué |
|---|---|---|---|
| $m$: mantención | Gasto en mantención de jardines por m² de área verde mantenida (deflactado) | SINIM IADM120 / MAVM, 2008–2025 | Decisión directa del alcalde, con fondos propios y poco visible. Cinco elecciones |
| $k$: inaugurar | Postulaciones de espacio público nuevas o de mejoramiento, por primera aparición del código | BIP, 2019–2027 | Mide la demanda del alcalde por obras inaugurables |
| Horizonte | Año del ciclo, último mandato permitido, margen de la elección anterior, si repostuló | Servel (pendiente) | Separa cercanía de la elección (visibilidad) de probabilidad de continuar ($p$) |
| Control regional | Afinidad política entre alcalde y gobernador | Servel | El GORE decide qué se financia |

**Complementos (prioridad media):**

- **Transferencias de la Ley 19.862** (SUBDERE y GORE a municipios): cubren PMU y FRIL, que el BIP capta mal. Ya hay datos en los proyectos de Abraham y Camila.
- **Mercado Público**: licitaciones de mantención de áreas verdes (monto, duración, fecha) y de obras de plazas (fecha de adjudicación). Permiten fechar al mes y probar la regla de los dos tercios (§2.6).
- **Permisos y recepciones del INE**: controlar por expansión urbana (loteos que generan plazas sin decisión municipal).
- **SINIM IADM93–95** (mantención de alumbrado, semáforos y señalización): otra mantención poco visible que permite ver si el patrón se repite fuera de las áreas verdes.

**Usar con cautela o descartar:**

- **Stock de plazas de SINIM**: mezcla vías privadas y sectoriales, y tiene saltos por correcciones. Solo como descripción o control.
- **Conservación del BIP**: pocas observaciones y dependientes de la clasificación del GORE o del MDSF.
- **Programas MINVU (R07–R11, R28)**: los selecciona el MINVU. Pueden servir como **prueba de falsificación** (obras cuyo calendario no controla el alcalde no deberían seguir su ciclo), pero no como medida principal.
- **Montos asignados y gasto del BIP**: incompletos, y reflejan la decisión del GORE.

## 5. Ajustes propuestos al diseño (sección 7 de las notas)

1. **Dos ecuaciones en vez de una proporción.** (a) Mantención por m² (SINIM, 2008–2025) en función del horizonte. (b) Postulaciones inaugurables (BIP, 2019–2027) en función del horizonte. La proporción "nueva / conservación" del BIP mezcla dos presupuestos y dos decisores.
2. **Separar las dos hipótesis de horizonte:** cercanía de la elección (visibilidad) y último mandato ($p\approx 0$). El límite de reelección de 2024 da un contraste limpio, pero es un solo episodio.
3. **Probar la "cuenta al sucesor":** las obras nuevas en el período $t$ deberían predecir más gasto en mantención en $t+1$, sobre todo cuando cambia el alcalde.
4. **Falsificación con el mapeo:** las obras originadas por el GORE (R03) o el MINVU frente a las originadas por el municipio (R02). Solo las segundas deberían mostrar el ciclo del alcalde.
5. **Corregir el conteo del BIP** (primera aparición del código) y la marca de espacio público antes de rehacer la Figura 1.

## 6. Preguntas para la próxima reunión

1. ¿Se reformula la restricción presupuestaria con dos fuentes (externa para $k$, propia para $m$)? Esto cambia la explicación rival: deja de competir con el modelo y pasa a formar parte de él.
2. ¿La variable de horizonte es la cercanía de la elección o la probabilidad de continuar? ¿O ambas, con predicciones separadas?
3. ¿Se acepta medir $m$ con SINIM y no con la conservación del BIP?
4. ¿Vale la pena descargar Mercado Público para tener fechas al mes y la duración de los contratos de mantención?
