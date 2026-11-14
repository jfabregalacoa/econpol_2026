# Un modelo formal para *We did not see it coming*

**Nombramientos, reputación y polarización en el Tribunal Constitucional de Chile**

Borrador de trabajo, noviembre de 2026.

Este documento hace tres cosas:

1. Propone un **modelo formal** para el paper de Fábrega, Sajuria y Drobny, construido con los modelos del curso Economía Política Formal 2026 (secciones 1 a 5).
2. **Replica** el resultado principal del paper con su método (idealstan) y sus datos (sección 7).
3. **Pone a prueba** las predicciones con datos reales, con **tres estimadores** de la ideología y **dos bases** de votos. Compara el período anterior y el posterior a la reforma de 2005, y contrasta la explicación del paper con la de Pardow y Verdugo (2015) (secciones 7 y 8).

Cada parte del modelo se presenta en tres pasos:

- **La idea**, en palabras.
- **Formalmente**, con las ecuaciones y su derivación.
- **Qué significa**, para el paper y para los datos.

> **Resultado principal.**
>
> - **La réplica funciona: no hay error en nuestros datos ni en nuestro código.** Con los datos y el método del paper (idealstan, un IRT dinámico bayesiano) se reproducen sus resultados: la validación (0,57 contra 0,56), el aumento de la dispersión después de 2005 y sus Tablas 2 y 3, con los mismos signos y la misma significancia (sección 7.4).
> - **El salto de la dispersión en 2005 depende del estimador.** Con **los mismos datos**, los dos estimadores de Martin y Quinn (emIRT y MCMCpack) no encuentran aumento en ninguna de las dos bases: la dispersión después de 2005 es igual o menor que antes. Año por año, los tres métodos ordenan a los ministros casi igual (correlación de 0,7 a 0,98). Lo que cambia es cómo conectan la "regla" de medir entre épocas. Antes de 2006, idealstan **da vuelta** la orientación y usa una **unidad de menos de la mitad del tamaño** que después: una unidad de Martin y Quinn equivale a unas 2,5 de idealstan antes de la reforma y a unas 5,5 justo después. Ese cambio de regla, justo en 2005, basta para duplicar la dispersión. Su Tabla 2 (la subida concentrada en los nombrados por políticos) sigue el mismo patrón: positiva con idealstan y negativa con Martin y Quinn, en las dos bases.
> - **Un resultado del paper se sostiene solo en parte:** los nombrados por el Ejecutivo quedan más lejos del mediano que el resto (su Tabla 3). En la base del paper se cumple con cualquier método, con significancia débil con Martin y Quinn (p ≈ 0,08). En la base nueva el signo se repite con Martin y Quinn (p = 0,12), pero no con idealstan. Lo que el paper no prueba es que eso ocurra **solo después de la reforma**: su tabla no incluye esa interacción, y al estimarla no es significativa con ningún método ni base.
> - **Ninguna de las demás predicciones encuentra apoyo robusto.** La prueba de diferencias en diferencias del paper (P1) no es significativa con ningún método ni base, una vez que se considera que las posiciones están estimadas con error. El efecto de horizonte (el mecanismo reputacional) no aparece con los datos actuales, se agrupen o no las series repetidas. Los académicos no son más activistas, como sostienen Pardow y Verdugo.
> - **Antes de 2006 los datos no alcanzan para ubicar a los ministros en el eje izquierda-derecha.** Hay pocos fallos con disidencia, y en ningún método la escala de esos años se relaciona con el lado político de quien nombró al ministro. Por eso la comparación antes y después de la reforma depende tanto del método.

---

## 1. Punto de partida

### Qué dice el paper

El paper sostiene que la reforma constitucional de 2005 polarizó al Tribunal Constitucional (TC). Su explicación es **reputacional** (Garoupa y Ginsburg):

- Los ministros nombrados por actores políticos cuidan su reputación ante su sector político.
- Los nombrados por la Corte Suprema la cuidan ante el poder judicial.
- La reforma dio más cupos a los actores políticos, así que "importó" la polarización al Tribunal.

| | Antes de 2005 (7 ministros) | Después de 2005 (10 ministros) |
|---|---|---|
| Corte Suprema | 3 | 3 |
| Presidente | 1 | 3 |
| Congreso | 1 (Senado, mayoría simple) | 4 (Senado y Cámara, dos tercios) |
| COSENA | 2 | 0 |

**Lo que encontró:**

1. La dispersión ideológica sube después de 2005.
2. La subida se concentra en los nombrados por poderes políticos (diferencias en diferencias contra la Corte Suprema).
3. Después de 2005, los más lejanos del mediano son los nombrados por el Ejecutivo y el Legislativo.
4. El efecto lo genera el **Ejecutivo**; el del Legislativo no es significativo.

### La explicación alternativa: Pardow y Verdugo (2015)

En *"El Tribunal Constitucional chileno y la reforma de 2005. Un enroque entre jueces de carrera y académicos"*, Pardow y Verdugo sostienen que después de 2005 el Tribunal se volvió más activo frente al Ejecutivo. Para ellos la causa **no es quién nombra, sino quién llega**: académicos que reemplazaron a jueces de carrera.

### Qué le falta al paper

- **No hay modelo formal.** El argumento no tiene jugadores, utilidades ni equilibrio.
- **La prueba no distingue mecanismos.** La distancia de un ministro al mediano puede venir de *a quién se nombró* (selección) o de *cómo vota una vez adentro* (incentivos).
- **No descarta a Pardow y Verdugo.** La reforma y el cambio de carrera ocurrieron al mismo tiempo.

---

## 2. Las piezas del curso

| Capítulo | Modelo | Uso aquí |
|---|---|---|
| 1 | Modelo espacial, votante mediano, control de agenda, veto | **Etapa 1:** quién nombra a quién, según la regla |
| 4 | Voto espacial con incentivos, $\Delta U$ = preferencia + incentivo electoral + incentivo partidario, y estimación de puntos ideales | **Etapa 2:** cómo vota el ministro; también la estimación de la ideología |
| 2 | Dal Bó y Rossi: horizonte del mandato | El incentivo reputacional crece al acercarse el fin del mandato |

---

## 3. Etapa 1: el juego de nominación

### La idea

Cada órgano que nombra quiere un ministro que piense como él. Lo que cambia es **la regla**:

- El Presidente nombra solo.
- La Corte Suprema vota internamente.
- El Congreso necesita dos tercios, así que cada bloque puede vetar.

Con las mismas preferencias, reglas distintas producen ministros distintos: $x^* = f(\text{preferencias}, \text{reglas}, \text{situación inicial})$, como en el capítulo 1.

### Formalmente

Hay una dimensión ideológica. Cada nominador $k$ tiene un ideal $x_k$ y obtiene $u_k(\theta) = -(\theta - x_k)^2$ si nombra a alguien en $\theta$, o $-c$ si el cupo queda vacante.

**Presidente (agenda sin veto):**

$$\boxed{\theta_P^* = x_P}$$

**Corte Suprema (votante mediano de la Corte):**

$$\boxed{\theta_{CS}^* = m_{CS}}$$

**Congreso, un cupo con dos tercios.** Los bloques están en $x_A = \bar x + h$ y $x_B = \bar x - h$. Le toca proponer a $A$, y $B$ acepta si $|\theta - x_B| \le \sqrt c$. Entonces

$$\boxed{\theta_1^* = \min\{x_A,\; x_B + \sqrt c\}}$$

Es la fórmula del capítulo 1, $p^*=\min\{x_S, 2x_m-q\}$: la vacancia hace de status quo. Hay acuerdo solo si $c \ge h^2$; si no, el cupo queda vacante, como ocurrió con los cupos de la Cámara entre 2022 y 2024.

**Congreso con dos cupos en paquete (la "regla del empate").** $B$ acepta el par $(\theta_A,\theta_B)$ si $(\theta_A - x_B)^2 + (\theta_B - x_B)^2 \le 2c$. Con bloques simétricos, cada nombrado queda a una distancia $s$ del centro y la pérdida de $B$ es $2s^2 + 2h^2$. Entonces

$$\boxed{\theta_{paq}^* = \bar x \pm \min\{h,\; \sqrt{c-h^2}\}}$$

Como $\sqrt{c-h^2} \ge \sqrt c - h$ siempre que haya acuerdo, **el paquete produce nombrados más extremos que el cupo suelto**. Cada bloque "paga" el extremo del otro con el propio.

### Qué significa

- **Proposición 1:** la reforma aumenta la dispersión si los presidentes que nombran se alternan entre bloques y si bloquear en el Congreso es caro ($c$ alto).
- **Proposición 2:** después de 2005, la distancia al mediano sigue el orden $\delta_{Presidente} \ge \delta_{Congreso} \ge \delta_{CS}$.
- **Proposición 3:** para que la diferencias en diferencias del paper sea positiva, los presidentes de 1990–2005 deben haber nombrado ministros relativamente moderados (Anexo A).

---

## 4. Etapa 2: cómo vota un ministro

### La idea

Un ministro del TC no puede ser removido ni reelegido. Lo que arriesga con su voto es su **reputación**, que vale para su carrera posterior. Según el paper, la cuida ante audiencias distintas:

- **Nombrado por políticos:** ante su sector político.
- **Nombrado por la Corte Suprema:** ante el poder judicial, que premia el consenso.

### Formalmente

Se modifica la ecuación del capítulo 4, cambiando la reelección por la reputación. En el caso $j$, el ministro $i$ (nombrado por $k$) vota por acoger si $\Delta U_{ij} \ge 0$:

$$
\boxed{\Delta U_{ij} = \underbrace{2(a_j - r_j)(\theta_i - m_j)}_{\text{preferencia}} + \underbrace{\beta^{\,T_i-t} R\, \Delta\rho^k_{ij}}_{\text{reputación}} + \varepsilon_{ij}}
$$

- **Preferencia.** $(r-\theta)^2 - (a-\theta)^2 = 2(a-r)(\theta - m_j)$, donde $m_j$ es el punto de corte del caso.
- **Reputación.** $\Delta\rho = +1$ si acoger agrada a su audiencia.
- **Horizonte.** $\beta^{T_i-t}$ crece al acercarse el fin del mandato $T_i$, como en Dal Bó y Rossi.

### Qué significa

- **Proposición 4:** los nombrados por políticos votan como si estuvieran más cerca de su bloque.
- **Proposición 5:** el empuje es mayor en los nombrados por el Congreso, que llegan moderados por el veto.
- **Proposición 6:** el empuje **crece hacia el final del mandato**.

---

## 5. Qué mide la ideología estimada

Un modelo de puntos ideales supone que solo la ideología explica el voto. Si también pesa la reputación, el modelo la mete dentro de la posición estimada:

$$
\hat\theta_{it} \approx \underbrace{\theta_i}_{\text{selección (etapa 1)}} + \underbrace{\pi_i(t)}_{\text{reputación (etapa 2)}} .
$$

La selección se fija el día del nombramiento; la reputación cambia con el horizonte del mandato. Por eso **la posición tiene que poder cambiar de un año a otro**, y por eso se usa un **IRT dinámico** (sección 7.3).

---

## 6. Predicciones y resultados

| Prueba | Pregunta | Predicción | Resultado |
|---|---|---|---|
| Hecho 1 | ¿La dispersión salta después de 2005? | Sí (Proposición 1) | **Depende del estimador.** Sí con idealstan (el método del paper); no con Martin y Quinn, con los mismos datos |
| Tabla 3 del paper | ¿Los nombrados por el Presidente quedan más lejos del mediano que el resto? | Sí (Proposición 2: $\delta_{Presidente} \ge \delta_{Congreso} \ge \delta_{CS}$) | **En parte.** Signo positivo en 3 de 4 combinaciones de base y método; significativo solo en la base del paper |
| **P1** | ¿Los nombrados por políticos quedan más lejos del mediano después de 2005? | Sí (selección) | **No significativo** con ningún método ni base; el signo cambia según el método |
| **P2** | ¿Los nombrados por políticos disienten más después de 2005? | Sí | **Cambia de signo según la base**; no significativo |
| **P3** | ¿Pesa más quién nombró o la carrera del ministro? | Quién nombró (paper) o la carrera (Pardow y Verdugo) | **Depende de la base.** Los académicos no son más activos, como afirman Pardow y Verdugo |
| **P4** | ¿Los nombrados por políticos se alejan del mediano al final del mandato? | Sí (reputación) | **No**, con emIRT y con MCMCpack, se agrupen o no las series |
| — | ¿Los paquetes del Congreso producen nombrados más extremos? | Sí | No se puede probar: casi todos fueron en paquete |

---

## 7. Pruebas con datos reales

Los coeficientes quedan en `modelo/resultados/` y las figuras en `modelo/figuras/`. La sección 10 lista los scripts y el orden en que se corren.

### 7.1 Los datos: disidencias antiguas y fechas imposibles

El script 2 (`codigo/2_descargar_sitio_antiguo.R`) no reconocía varias fórmulas de disidencia de los PDF de 1981–2007:

- "con **los votos** en contra", en plural;
- "Acordad**o**";
- "contra el voto de", "contra la opinión de";
- "y la disidencia, los Ministros...";
- "El Ministro X disiente / discrepa";
- "El Ministro X, estuvo por...".

Además exigía los dos apellidos, y en los años noventa las sentencias nombran a los disidentes **solo por el primer apellido**. Se corrigió todo eso. Se agregó un control (los disidentes siempre son minoría) y se dejan fuera las prevenciones.

| 1990–2005 | Versión anterior | Versión nueva |
|---|---|---|
| Fallos con disidencia en la base nueva | 20 | **58** (la del paper tiene 54) |
| Disidencias de la base del paper que también capta la nueva | 15 de 85 (18 %) | **43 de 85 (51 %)** |

La versión nueva también encuentra 42 disidencias que la base del paper no tiene. En una muestra revisada a mano, casi todas están efectivamente en el texto de la sentencia. Las diferencias que quedan vienen sobre todo de **disidencias parciales**, que cada base codifica distinto; se cuentan como disidencia (`DISIDENCIAS_PARCIALES <- TRUE`). El acuerdo general con la base del paper queda en 79,6 % (kappa 0,513).

**Fechas imposibles.** El buscador del TC fecha mal algunos fallos. El rol se asigna al ingresar la causa y crece cada año, y un fallo no puede dictarse antes de ingresar. Sin embargo, el rol 15308 (de alrededor de 2024) aparece dictado en 2011, el 2690 (de alrededor de 2014) en 2007 y el 13081 (de alrededor de 2022) en 2018. Con esas fechas, el IRT dinámico ponía a ministros en años en que no estaban en el Tribunal: por ejemplo, ocho ministros de 2024 votando en 2011, y a las anclas (Aróstica y García Pino) votando en 2007.

El script 3 descarta ahora los fallos cuyo rol supera el doble del rol alto de su año (percentil 95) más 200, y los lista en pantalla. Son esos 3 fallos y 24 votos. La base queda en 61.447 votos y 7.285 fallos, el acuerdo con la base del paper no cambia, y **todas las estimaciones de la base nueva de este documento se rehicieron con la base corregida**.

### 7.2 Las inaplicabilidades en serie se agrupan

Entre 2015 y 2020 el TC falló miles de requerimientos casi idénticos: misma norma impugnada, mismo año, misma votación. Cada uno no dice nada nuevo sobre quién piensa qué, pero pesaría como un caso distinto. El paper no los agrupa, pero llega solo hasta 2016 y casi no los tiene.

**Criterio** (`AGRUPAR_SERIES <- TRUE` en `modelo/comun.R`): son un solo caso los fallos con el mismo año, la misma norma impugnada y **exactamente la misma votación**. Si no hay norma registrada, cuentan la misma fecha y la misma votación. La base final no se modifica; se agrupa solo para el análisis.

| Fallos con disidencia, base nueva | 1990–2005 | 2006–2014 | 2015–2022 | 2023–2026 |
|---|---|---|---|---|
| Sin agrupar | 58 | 320 | **4.789** | 634 |
| Agrupados | 58 | 253 | **2.362** | 514 |

La serie más grande tenía 118 fallos idénticos.

### 7.3 La ideología: tres estimadores del IRT dinámico

**Por qué dinámico.** Si se estima un modelo para cada período (por mes, por año, o antes y después de 2005), cada estimación queda centrada en *su* tribunal. Si todo el tribunal se corre en bloque, un ministro que se corre con él aparece en el mismo lugar en ambos períodos. El modelo dinámico estima todos los años juntos, conectados por los ministros que siguen en el cargo, y deja que cada posición cambie gradualmente:

$$
\theta_{i,t} = \theta_{i,t-1} + \eta_{it}, \qquad \Pr(\text{acoger}_{ij}) = \Phi(\alpha_j + \beta_j\theta_{i,t(j)})
$$

Es la ecuación de voto de la sección 4 (con $\beta_j\theta_i + \alpha_j$ en lugar de $2(a_j - r_j)(\theta_i - m_j)$) más un paseo aleatorio que conecta los años. Las tres versiones estiman **el mismo modelo**; difieren en cómo se calcula y en cómo se fija la escala.

| | emIRT | MCMCpack | idealstan |
|---|---|---|---|
| Qué es | Martin y Quinn, aproximación variacional (Imai, Lo y Olmsted 2016) | Martin y Quinn por MCMC (muestreo de Gibbs) | IRT dinámico por MCMC con Stan (Kubinec); **el método del paper** |
| Entrega | Una posición por ministro-año | Miles de posiciones posibles por ministro-año (la incertidumbre) | Igual que MCMCpack |
| Varianza del paseo aleatorio | Fija: $\omega^2 = 0{,}1$, la de Martin y Quinn | Fija: 0,1, igual que emIRT | **Se estima libremente para cada ministro** |
| Cómo se fija la escala | Previa de las posiciones ($N(0,1)$) y dos anclas que dan el sentido | Igual en la base del paper; en la base nueva, además, anclas **fijadas en ±1** (ver "Convergencia") | Dos anclas **fijadas en ±2** y nada más |
| Covariable "quién lo nombró" | No permite | No permite | Permite (el paper la usa) |
| Tiempo, base nueva | ~1 min | ~12 a 14 h por cadena | ~3,5 h |

Las anclas son las mismas en todos: Aróstica (derecha) y García Pino (izquierda), presentes en ambas bases. Se estima por **años**: un mes tiene muy pocos fallos con disidencia.

**Mismos datos para comparar.** Para que una diferencia entre métodos sea del método y no de los datos, los tres se estimaron con los mismos datos: solo fallos con disidencia (en los unánimes no se distingue a nadie), con al menos 3 votantes, ministros con al menos 10 votos y series agrupadas. Aparte, se hizo una **réplica fiel del paper** con idealstan y los datos tal como los usó el paper (sección 7.4).

**Convergencia.** Un MCMC entrega resultados válidos solo si las cadenas llegaron a la distribución que buscan.

| Estimación | Diagnóstico | Resultado |
|---|---|---|
| MCMCpack, base del paper (2 cadenas de 20.000 iteraciones) | Geweke: % de parámetros con \|z\| > 1,96 (se espera ~5 %); R-hat | Geweke 4 % y 9 %; R-hat máximo 1,03, ninguno sobre 1,1: **convergió** |
| MCMCpack, base nueva, anclas solo con signo (2 cadenas de 15.000 iteraciones) | R-hat de Gelman-Rubin; Geweke | R-hat > 1,1 en 32 % (máximo 5,5); Geweke 35 % y 29 %: **no convergió** |
| MCMCpack, base nueva, **anclas fijas en ±1** (2 cadenas de 15.000 iteraciones, ~14 h) | R-hat; Geweke | R-hat > 1,1 en 7 % (máximo 1,42): **0 % en 2006–2014 y 2 % en 2015–2022**; Geweke 12 % y 20 %: **converge desde 2006**; antes de 2006 y desde 2023, con reservas |
| idealstan, 5 estimaciones (2 cadenas cada una) | Divergencias; R-hat máximo (se espera < 1,1) | 0 divergencias (2 en una); R-hat máximo entre 1,02 y 1,06, salvo la base nueva con covariable (1,13, pero solo el 0,1 % de los parámetros sobre 1,1): **convergió** |

**Por qué MCMCpack no convergía en la base nueva con las anclas habituales.** Martin y Quinn fija el sentido de la escala con dos anclas de signo conocido: Aróstica positivo y García Pino negativo. Eso fija el signo, pero no la distancia. Con esa versión, las dos cadenas ordenaban a los ministros casi igual (correlación de 0,94 entre ellas), pero **el tamaño de la escala no se estabilizaba**: García Pino, por ejemplo, quedaba en −3,6 en una cadena y en −6,1 en la otra.

`modelo/diagnosticar_mcmcpack.R` muestra por qué: **las cadenas seguían moviéndose al final**. En una cadena, la dispersión de 2015–2022 bajaba sin parar (correlación de −0,91 con el número de iteración). En la otra no tenía tendencia (0,19), pero terminó en otro nivel: 2,4, frente a 1,7 en la primera. Si todos los ministros se alejan y los fallos "discriminan" menos, los votos se explican casi igual, así que el muestreador recorre esa dirección. Con miles de fallos por año, lo hace a pasos diminutos y harían falta muchas más iteraciones. La base del paper, con muchos menos fallos, no tiene ese problema.

![Diagnóstico de MCMCpack, anclas solo con signo](figuras/diag_mcmcpack_nueva.png)

**Diagnóstico de MCMCpack, base nueva, anclas solo con signo.** Cada color es una cadena. Las cadenas no se juntan y al menos una sigue con tendencia al terminar.

**La solución: anclas fijas.** Si el problema es que la escala no tiene un tamaño fijo, hay que fijar las anclas en valores exactos: Aróstica = +1 y García Pino = −1 (`estimar_ideologia_bayes.R nueva 5000 10000 10 <cadena> fijas`). Así se fija la unidad de medida, como hace idealstan con sus anclas en ±2. Con el mismo número de iteraciones que la versión anterior:

| % de parámetros con R-hat > 1,1 | 1990–2005 | 2006–2014 | 2015–2022 | 2023–2026 | R-hat máximo |
|---|---|---|---|---|---|
| Anclas solo con signo | 54 | 33 | 26 | 2 | 5,5 (García Pino) |
| **Anclas fijas** | 16 | **0** | **2** | 12 | 1,42 (Silva Gallinato) |

- **La escala dejó de estirarse.** La dispersión de 2015–2022 ya no tiene tendencia (correlación con la iteración de 0,04 y −0,24), y las cadenas casi no cambian entre la primera y la segunda mitad (cambio medio de 0,05 y 0,09).
- **Lo que falta converger está en los años sin anclas.** Aróstica y García Pino votan entre 2010–2011 y 2022. Antes de 2006 y desde 2023, la escala se conecta solo a través de los ministros que cruzan de una época a otra. Antes de 2006, además, hay pocos fallos con disidencia (58). Los ministros que peor convergen son de esos años (Silva Gallinato, García Rodríguez, Aburto, Faúndez). Por eso esos períodos se leen con reservas, y por eso la base del paper sigue siendo la principal antes de 2006. En 2023–2026, la versión con anclas solo con signo tiene menos parámetros sin converger (2 % frente a 12 %), pero no sirve de comparación, porque el tamaño de su escala no está fijo.

![Diagnóstico de MCMCpack, anclas fijas](figuras/diag_mcmcpack_nueva_fijas.png)

**Diagnóstico de MCMCpack, base nueva, anclas fijas.** Cada color es una cadena. Los tres primeros paneles son los parámetros que peor convergen (Silva Gallinato, 2023–2025): las cadenas se separan en un tramo, pero vuelven a juntarse. El último panel muestra que la dispersión de 2015–2022 ya no tiene tendencia.

**Desde aquí, "MCMCpack en la base nueva" es la versión con anclas fijas.** En la base del paper se mantiene la versión con anclas solo con signo, que convergió.

En idealstan, el tamaño efectivo de muestra mínimo es bajo en algunos parámetros (14 a 305), suficiente para medianas y desviaciones estándar por año, pero más iteraciones darían intervalos más precisos.

**W-NOMINATE** (el método del laboratorio del capítulo 4) se intentó como comparación, y con estos datos da resultados internamente inconsistentes: clasifica más votos de los que cada ministro emitió. Con el ejemplo del propio paquete funciona bien. La razón probable es que W-NOMINATE supone un parlamento donde todos votan en el mismo período, y en el TC los ministros se reemplazan a lo largo de décadas. No se usa.

### 7.4 La réplica del paper: qué se reproduce y qué depende del método

Esta sección responde una pregunta previa a cualquier crítica: **si nuestros resultados difieren de los del paper, ¿el error es nuestro?** Para responderla se separan tres posibles causas de una diferencia: los **datos** (la base nueva), la **implementación** (nuestro código) y el **método** (el estimador de la ideología).

#### Paso 1. Los datos y el método del paper: la réplica funciona

`modelo/replicar_paper_idealstan.R` repite el procedimiento del paper con **su base** y **su método** (idealstan): todos los votos de 1990–2016, sin agrupar series, ministros con al menos 10 votos y la covariable "nombrado por políticos" dentro del modelo. `modelo/probar_idealstan.R` calcula después sus Tablas 2 y 3 **tal como se publicaron**.

| | Paper | Réplica, con covariable (como el paper) | Réplica, sin covariable |
|---|---|---|---|
| Votos / fallos / ministros | 11.013 / 1.265 / 40 | 11.047 / 1.270 / 39 | igual |
| Validación (correlación con el lado político) | 0,56 | **0,57** | 0,39 |
| Dispersión, 1990–2005 → 2006–2016 (su Figura 3) | sube | 2,16 → 4,75 (×2,2) | 2,10 → 4,38 (×2,1) |
| **Tabla 2**, Ejecutivo + Legislativo (tratado × reforma) | +0,478*** | **+2,60*** ** | +2,14*** |
| **Tabla 2**, solo Ejecutivo | +0,530** | **+3,37*** ** | +1,57** |
| **Tabla 3**, M1: nombrado por político | +0,308* | +1,64* | +1,15 (p = 0,12) |
| **Tabla 3**, M4: Ejecutivo (controlando reforma) | +0,369** | **+1,82** ** | +0,76 (p = 0,31) |
| **Tabla 3**, M5: Ejecutivo (controlando Legislativo y reforma) | +0,384** | +1,68* | +0,78 (p = 0,34) |
| **Tabla 3**, Legislativo | +0,048 | +0,26 | +0,77 |

\* p < 0,1; \*\* p < 0,05; \*\*\* p < 0,01, con errores estándar clásicos, como el paper.

**Con la covariable, como hizo el paper, la réplica reproduce sus resultados**: los mismos signos, la misma significancia y el mismo patrón (Ejecutivo sí, Legislativo no). Los coeficientes son unas 5 veces más grandes porque nuestra escala es más ancha (la dispersión de control antes de 2005 es 0,95 en la réplica y 0,17 en el paper), pero **en proporción son casi iguales**: en la Tabla 2, el efecto equivale a 2,8 veces la dispersión de control en el paper y a 2,7 veces en la réplica.

**Conclusión del paso 1:** ni nuestra base ni nuestro código explican las diferencias. Con lo mismo que usó el paper, obtenemos lo mismo que el paper.

![Figura 11](figuras/fig11_replica_idealstan_paper_mcmc.png)

#### Paso 2. Los mismos datos, otro método: qué se sostiene

Para ver si los resultados dependen del estimador, las mismas Tablas 2 y 3 se calcularon con **los mismos datos** (la base del paper, fallos con disidencia, sin covariable) estimados con idealstan y con Martin y Quinn (MCMCpack, que convergió en esta base; se juntan sus dos cadenas).

| | Paper | idealstan | Martin y Quinn (MCMCpack) |
|---|---|---|---|
| Dispersión, 1990–2005 → 2006–2016 | sube | 3,46 → 5,31: **sube** | 1,09 → 0,95: **no sube** |
| **Tabla 2**, Ejecutivo + Legislativo | +0,478*** | +1,30** | **−0,30*** (p = 0,08) |
| **Tabla 2**, solo Ejecutivo | +0,530** | +0,24 (p = 0,75) | **−1,00*** ** |
| **Tabla 3**, M4: Ejecutivo | +0,369** | +2,08** | **+0,44*** (p = 0,09) |
| **Tabla 3**, M5: Ejecutivo | +0,384** | +2,16** | **+0,54*** (p = 0,07) |
| **Tabla 3**, Legislativo | +0,048 | +0,39 | −0,01 |

**Qué se sostiene con cualquier método, en la base del paper:**

- **Los nombrados por el Ejecutivo quedan más lejos del mediano que el resto** (Tabla 3). El signo se repite en todos los métodos. Con Martin y Quinn el tamaño es incluso parecido al del paper (0,44 contra 0,37), aunque la significancia es más débil (p ≈ 0,08).
- **Los nombrados por el Legislativo no se distinguen** del resto, como dice el paper.

**Qué depende del método:**

- **El aumento de la dispersión después de 2005** (Figura 3 del paper): idealstan lo encuentra y Martin y Quinn no (sección 7.6 explica por qué).
- **Que ese aumento se concentre en los nombrados por políticos** (Tabla 2): con Martin y Quinn el signo se invierte. No es un problema de convergencia: en la base del paper MCMCpack convergió (dos cadenas, R-hat máximo 1,03).

**Por qué la Tabla 2 cambia de signo.** En todos los métodos, los nombrados por políticos están más dispersos que el resto, antes y después de la reforma (por eso la Tabla 3 se sostiene). Si un método agranda toda la escala después de 2005 por un factor $k > 1$, la brecha entre los grupos crece sola: la interacción de la Tabla 2 vale $(k-1)(\text{sd}_{\text{políticos}} - \text{sd}_{\text{resto}}) > 0$, aunque el tribunal no haya cambiado. idealstan agranda su escala en 2005 (×1,5 con estos datos; sección 7.6) y Martin y Quinn no. **La Tabla 2 positiva es exactamente lo que produciría un cambio de escala**, así que no permite distinguir polarización real de un efecto del estimador.

#### Paso 3. La base nueva: el patrón entre métodos se repite

Las mismas Tablas 2 y 3 con la **base nueva** (fuentes oficiales; fallos con disidencia, series agrupadas, 1990–2016 como el paper). Martin y Quinn es MCMCpack con anclas fijas, que convergió desde 2006 (sección 7.3).

| | Paper | idealstan, con covariable | idealstan, sin covariable | Martin y Quinn (MCMCpack) |
|---|---|---|---|---|
| Validación (correlación con el lado político) | 0,56 | 0,46 | 0,47 | 0,42 |
| Dispersión, 2006–2016 menos 1990–2005 | sube | +4,6: **sube** | +4,7: **sube** | −0,12: **no sube** |
| **Tabla 2**, Ejecutivo + Legislativo | +0,478*** | +3,19*** | +3,96*** | −0,11 (p = 0,52) |
| **Tabla 2**, solo Ejecutivo | +0,530** | +0,47 (p = 0,71) | +1,37 (p = 0,31) | **−0,64*** ** |
| **Tabla 3**, M1: nombrado por político | +0,308* | +1,99 (p = 0,21) | +1,79 (p = 0,27) | +0,26 (p = 0,26) |
| **Tabla 3**, M4: Ejecutivo | +0,369** | +0,32 (p = 0,85) | −0,04 (p = 0,98) | +0,40 (p = 0,12) |
| **Tabla 3**, M5: Ejecutivo | +0,384** | +0,59 (p = 0,74) | +0,24 (p = 0,90) | +0,45 (p = 0,12) |
| **Tabla 3**, Legislativo | +0,048 | +2,34 (p = 0,18) | +2,43 (p = 0,17) | −0,07 (p = 0,78) |

Errores estándar clásicos, como el paper. La Tabla 3 tiene 31 ministros (el paper, 36).

- **La Tabla 2 se repite tal cual:** positiva y significativa con idealstan, negativa con Martin y Quinn. Es el mismo patrón de la base del paper, así que la explicación por el cambio de escala vale también aquí. Con la incertidumbre de las posiciones (Rubin), la Tabla 2 de idealstan baja a p = 0,085 con covariable y p = 0,065 sin ella.
- **La Tabla 3 no se repite.** Con Martin y Quinn, los nombrados por el Ejecutivo vuelven a quedar más lejos del mediano, con un tamaño casi igual al de la base del paper (+0,40 contra +0,44), pero sin significancia (p = 0,12). Con idealstan el efecto del Ejecutivo desaparece (+0,32 y −0,04), y los que quedan más lejos son los nombrados por el Legislativo (+2,3; p = 0,17), lo contrario de lo que dice el paper.

**Conclusión del paso 3:** lo que depende del método en la base del paper (el salto de 2005 y la Tabla 2) sigue dependiendo del método en la base nueva. Lo que parecía robusto en la base del paper (el Ejecutivo más lejos, Tabla 3) tiene el signo del paper en tres de las cuatro combinaciones de base y método, pero solo es significativo en la base del paper.

#### Paso 4. Lo que el paper no prueba

- **"Solo después de la reforma."** El texto del paper concluye que los nombrados por el Ejecutivo están más lejos del mediano "but only after the reform". Pero la Tabla 3 publicada **no incluye la interacción** Ejecutivo × reforma que permitiría afirmarlo: sus modelos 4 y 5 suman el efecto del Ejecutivo y el de la reforma por separado. La ecuación 4 del texto sí incluye esa interacción ($d\,R{\cdot}D$). Cuando se estima, **no es significativa con ningún método ni base** (sección 7.7; en la réplica fiel, +2,66 con p = 0,087 y, con la incertidumbre de las posiciones, p = 0,34).
- **Errores estándar demasiado chicos en la Tabla 2.** Sus 54 observaciones son 27 años × 2 grupos, pero los mismos ministros aparecen en muchos años seguidos, así que las observaciones no son independientes. Además, las posiciones son estimaciones, no datos exactos. Al sumar esa incertidumbre (reglas de Rubin), el efecto de la Tabla 2 pasa de p < 0,001 a p = 0,04 en la réplica, y en la versión con los mismos datos que Martin y Quinn deja de ser significativo (p = 0,40).
- **La covariable dentro del modelo.** El paper incluye "nombrado por políticos" dentro del modelo que estima la ideología y luego prueba si los nombrados por políticos están más lejos del mediano. Parte del resultado puede ser mecánico. En la réplica fiel, el efecto del Ejecutivo en la Tabla 3 es significativo con la covariable (p = 0,04) y no sin ella (p = 0,31).

#### ¿Podemos estar equivocados nosotros?

Sí, en tres puntos concretos, y conviene decirlos:

1. **Detalles que el paper no especifica.** El texto no dice qué unidad de tiempo usa (años, semestres, períodos de mandato), qué proceso sigue la ideología en el tiempo (paseo aleatorio u otro), cómo fija la escala (qué anclas o restricciones) ni cómo entra exactamente la covariable. Nuestras elecciones (años, paseo aleatorio, anclas Aróstica y García Pino) reproducen sus resultados, pero **la escala del paper es unas 5 veces más angosta que la nuestra**, señal de que su identificación fue distinta. Justamente la identificación de la escala es lo que separa a idealstan de Martin y Quinn (sección 7.6).
2. **Martin y Quinn también supone cosas.** Su paseo aleatorio con varianza fija (0,1) podría estar suavizando un cambio real después de 2005. No hay forma de saber, con estos datos, cuál de los dos estimadores conecta mejor las épocas.
3. **Nuestra base nueva** difiere de la del paper (kappa 0,51), pero **no explica las diferencias entre métodos**: los pasos 1, 2 y 4 usan la base del paper, y en el paso 3 el mismo contraste entre métodos aparece con la base nueva. Lo que sí cambia con la base es la Tabla 3.

**Cómo resolverlo:** pedir a los autores el código original de la estimación con idealstan. Con él se sabría si su identificación de la escala es distinta de la nuestra y si, con ella, el salto de 2005 se mantiene con Martin y Quinn.

### 7.5 Hecho 1: ¿la dispersión salta en 2005? Tres métodos, dos bases

La dispersión de un año es la desviación estándar de las posiciones (medianas posteriores) de los ministros que votaron ese año; se promedia por período. **Las unidades de cada método son distintas** (idealstan fija las anclas en ±2; Martin y Quinn usa una escala cercana a la normal estándar, y en MCMCpack de la base nueva, anclas en ±1), así que lo comparable es **cuánto cambia** cada método de un período a otro, no el nivel.

| Dispersión media (mismos datos) | 1990–2005 | 2006–2014 | 2015–2022 | 2023–2026 | Después / antes de 2005 |
|---|---|---|---|---|---|
| **Base del paper** | | | | | |
| emIRT | 0,94 | 0,90 | 1,27 (2015–16) | — | **×0,96** |
| MCMCpack (2 cadenas) | 1,02 | 0,88 | 1,04 (2015–16) | — | **×0,86** |
| idealstan | 2,8 | 5,1 | 5,3 (2015–16) | — | **×1,8** |
| **Base nueva** | | | | | |
| emIRT | 1,06 | 0,75 | 1,10 | 1,08 | **×0,71** |
| MCMCpack (anclas fijas, 2 cadenas) | 0,87 | 0,86 | 0,87 | 1,47 | **×0,99** |
| idealstan | 2,3 | 6,9 | 13,3 | 10,7 | **×3,0** |

Con MCMCpack se puede calcular la dispersión en cada muestra de la posterior y obtener un intervalo (`probar_bayes.R`). La diferencia 2006–2014 menos 1990–2005 es:

- base del paper: −0,17, intervalo de 95 % [−0,57; 0,20], probabilidad de que la dispersión haya subido 0,19;
- base nueva: −0,10, intervalo [−0,39; 0,15], probabilidad 0,23.

Calculada así, la dispersión de MCMCpack en la base nueva antes de 2006 es algo mayor (1,00) que con las medias posteriores de la tabla (0,87), porque esos años tienen más incertidumbre. La conclusión no cambia.

**2023–2026.** Los tres métodos muestran más dispersión en el tribunal actual que en 2006–2014: ×1,4 con emIRT, ×1,7 con MCMCpack y ×1,6 con idealstan. Son años sin anclas en el tribunal y con menos convergencia (sección 7.3), así que es un resultado para revisar, no una conclusión.

![Figura 7](figuras/fig7_dispersion_anual.png)

**Figura 7.** Dispersión por año con emIRT, en las dos bases.

![Figura 10](figuras/fig10_dispersion_bayes.png)

**Figura 10.** Dispersión por año con MCMCpack, con su intervalo de 95 %, en la base del paper y en la base nueva (anclas fijas).

**Qué significa.** Con los mismos datos, idealstan dice que la dispersión se duplicó o triplicó en 2005 y Martin y Quinn dice que no cambió, en las dos bases. La sección siguiente muestra de dónde viene la diferencia.

### 7.6 Por qué los métodos discrepan: la escala entre épocas

`modelo/comparar_metodos.R` compara, año por año, las posiciones de idealstan con las de Martin y Quinn estimadas con los mismos datos. Para cada año calcula dos cosas:

- La **correlación** entre los dos métodos: si ordenan igual a los ministros.
- La **pendiente**: cuántas unidades de idealstan equivalen a una de Martin y Quinn. Si es constante, los dos métodos usan la misma regla con distinta unidad. Si cambia con los años, uno de los dos estira o encoge su regla en el tiempo.

| Promedios por período | 1990–2005 | 2006–2014 | 2015–2022 | 2023–2026 |
|---|---|---|---|---|
| **Base del paper** (contra MCMCpack) | | | | |
| Correlación | **−0,96** | 0,95 | 0,96 (2015–16) | — |
| Pendiente | **−2,7** | 5,5 | 4,9 | — |
| **Base nueva** (contra MCMCpack, anclas fijas) | | | | |
| Correlación | **−0,80** | 0,89 | 0,86 | 0,98 |
| Pendiente | **−2,2** | 7,0 | 13,3 | 7,2 |
| **Base nueva** (contra emIRT) | | | | |
| Correlación | **−0,74** | 0,83 | 0,91 | 0,88 |
| Pendiente | **−1,7** | 8,3 | 11,1 | 9,2 |

![Figura 12a](figuras/fig12_escala_metodos_paper_mcmcpack.png)

![Figura 12b](figuras/fig12_escala_metodos_nueva_mcmcpack_fijas.png)

![Figura 12c](figuras/fig12_escala_metodos_nueva_emirt.png)

**Figura 12.** Pendiente y correlación entre idealstan y Martin y Quinn, año por año: (a) base del paper, contra MCMCpack; (b) base nueva, contra MCMCpack con anclas fijas; (c) base nueva, contra emIRT.

**Cuatro hallazgos:**

1. **Dentro de cada año los métodos coinciden.** Ordenan a los ministros casi igual (correlación promedio por período de 0,74 a 0,98 en valor absoluto).
2. **Antes de 2006, idealstan da vuelta la escala.** La correlación es negativa en casi todos los años hasta 2005 y pasa a positiva justo en 2006: lo que un método llama izquierda, el otro lo llama derecha. Las anclas (Aróstica y García Pino) votan desde 2010–2011, así que el sentido de la escala antes de 2006 depende de unos pocos ministros que cruzan la reforma.
3. **La regla de idealstan cambia de tamaño justo en 2005.** En valor absoluto, la pendiente contra MCMCpack es de unos 2,5 antes de 2006 y de unos 5,5 en 2006, en las dos bases. Es decir, la misma distancia entre dos ministros (según Martin y Quinn) mide menos de la mitad en idealstan antes de la reforma que después. Ese cambio de unidad basta para que la dispersión de idealstan "se duplique" sin que el tribunal haya cambiado según Martin y Quinn.
4. **En la base nueva, la regla de idealstan sigue creciendo después de 2006.** Contra MCMCpack, la pendiente pasa de 5,5 en 2006 a 15,6 en 2020–2021; contra emIRT, de 3,4 a 13. Los dos estimadores de Martin y Quinn coinciden en esto. Por eso la dispersión de idealstan casi se duplica entre 2006–2014 y 2015–2022 (6,9 → 13,3), mientras que con MCMCpack no cambia (0,86 → 0,87). Una versión anterior de este documento decía lo contrario (pendiente constante contra MCMCpack), pero eso venía de que MCMCpack no había convergido justamente en esos años.

**¿Cuál orientación es la correcta antes de 2006?** Se correlacionó la posición media de cada ministro en cada época con el lado político de quien lo nombró (sin contar las anclas).

| Correlación con "nombrado por la derecha" | Antes de 2006 | Desde 2006 |
|---|---|---|
| Base del paper: MCMCpack / idealstan | +0,29 / −0,31 (N = 5) | 0,48 / 0,52 (N = 13) |
| Base del paper: emIRT / idealstan | +0,09 / −0,31 (N = 5) | 0,61 / 0,52 (N = 13) |
| Base nueva: MCMCpack / idealstan | +0,25 / −0,27 (N = 5) | 0,46 / 0,52 (N = 15) |
| Base nueva: emIRT / idealstan | −0,08 / −0,27 (N = 5) | 0,69 / 0,52 (N = 15) |

Desde 2006 todos los métodos producen una escala izquierda-derecha razonable. **Antes de 2006 ninguno lo hace de forma confiable**: con 5 ministros de lado conocido, las correlaciones van de −0,31 a +0,29 y cambian de signo según el método. Martin y Quinn tiende a dar el signo esperado (3 de 4 versiones); idealstan da siempre el contrario, pero con N = 5 eso no prueba nada. Los fallos con disidencia de esos años (58 en la base nueva, 54 en la del paper), en su mayoría de control preventivo de leyes, no ordenan a los ministros en el eje izquierda-derecha.

**Por qué ocurre (identificación).** Un modelo de puntos ideales solo identifica posiciones **relativas**: se puede estirar, correr o dar vuelta toda la escala y los votos se explican igual. Para comparar épocas, el modelo tiene que fijar la regla, y cada método lo hace distinto:

- **Martin y Quinn** fija la escala con una previa de las posiciones parecida a una normal estándar y con un paseo aleatorio de varianza chica. Eso tiende a mantener **constante** la dispersión entre años. Si el tribunal de verdad se polarizó, este método podría estar **escondiendo** ese cambio. (En la base nueva, MCMCpack fija además las anclas en ±1, como idealstan las fija en ±2, y la conclusión es la misma.)
- **idealstan** fija solo las dos anclas en ±2 y estima libremente la varianza del paseo de cada ministro. Lejos de las anclas (antes de 2006), la regla queda poco amarrada y puede estirarse o darse vuelta. Este método podría estar **inventando** un cambio que no existe.

**Los datos no permiten decidir cuál de los dos tiene razón**, porque antes de 2006 hay muy poca información para conectar las épocas. Lo que sí se puede afirmar: **el resultado principal del paper depende de una decisión de estimación**, no de un patrón que aparezca con cualquier método.

### 7.7 P1. La reforma y la distancia al mediano (la prueba del paper)

Distancia de cada ministro al mediano del año de su nombramiento. El coeficiente $d$ es la diferencias en diferencias: cuánto más se alejan los nombrados por políticos después de 2005, comparados con los de la Corte Suprema. Los valores de $d$ no se comparan entre métodos (unidades distintas); importan el signo y la significancia.

| Método | Base del paper | Base nueva |
|---|---|---|
| emIRT (sin incertidumbre) | +0,44 (p = 0,47) | −0,15 (p = 0,80) |
| MCMCpack (Rubin) | −0,12 (p = 0,86) | −0,11 (p = 0,85) |
| idealstan, mismos datos, sin covariable (Rubin) | +0,92 (p = 0,74) | +1,13 (p = 0,74) |
| idealstan, con covariable (Rubin) | réplica fiel: +1,95 (p = 0,34) | +0,87 (p = 0,79) |

Detalle de emIRT por grupo (distancia media):

| | Políticos antes | Políticos después | Corte Suprema antes | Corte Suprema después |
|---|---|---|---|---|
| Base nueva | 0,91 | 0,74 | 0,59 | 0,57 |
| Base del paper | 0,68 | 1,01 | 0,63 | 0,52 |

![Figura 8](figuras/fig8_reforma_grupos.png)

**Qué significa.** Con idealstan el signo va en la dirección del paper en las dos bases, pero nunca es significativo. Con Martin y Quinn el signo es negativo, salvo con emIRT en la base del paper. Con 4 a 19 ministros por grupo, esta prueba **no puede distinguir** si la reforma tuvo efecto.

### 7.8 P2. La reforma y la disidencia

Esta prueba no usa la ideología estimada, así que no depende del método.

| Disidencia media por ministro-año | Políticos antes | Políticos después | Corte Suprema antes | Corte Suprema después | Diferencias en diferencias |
|---|---|---|---|---|---|
| Base nueva | 5,2 % | 20,8 % | 3,3 % | 20,7 % | −2,9 puntos (p = 0,39) |
| Base del paper | 4,3 % | 10,3 % | 3,6 % | 7,3 % | +2,0 puntos (p = 0,24) |

Todos disienten más después de 2005. Que los nombrados por políticos aumenten *más* depende de la base.

### 7.9 P3. ¿Quién nombra o la carrera? Pardow y Verdugo

![Figura 9](figuras/fig9_enroque_carrera.png)

**El enroque existe.** Los jueces de carrera pasan de cerca del 43 % antes de 2005 a casi ninguno después. Coincide con la reforma, así que se separa ministro por ministro:

$$\text{resultado} = b_1\,\text{académico} + b_2\,\text{político} + \text{año} + e$$

| Resultado | Base | Académico ($b_1$) | Nombrado por políticos ($b_2$) |
|---|---|---|---|
| Disidencia | paper | −0,008 (p = 0,58) | **+0,023 (p = 0,02)** |
| | nueva | **+0,044 (p = 0,046)** | −0,011 (p = 0,64) |
| "Activismo" (votar por acoger más que el resto) | paper | −0,061 (p = 0,51) | **+0,181 (p = 0,03)** |
| | nueva | **−0,183 (p = 0,03)** | +0,103 (p = 0,26) |
| Distancia al mediano (emIRT) | paper | +0,14 (p = 0,78) | +0,23 (p = 0,57) |
| | nueva | +0,42 (p = 0,34) | +0,02 (p = 0,96) |

**Qué significa:**

- En la base del paper, lo que predice disidencia y activismo es quién nombró al ministro.
- En la nueva, los académicos disienten más, pero **son menos activistas, no más**.
- La afirmación específica de Pardow y Verdugo (los académicos hicieron al Tribunal más activo) **no se sostiene en ninguna de las dos bases**.
- Que pese más quién nombra o la carrera depende de la base.

### 7.10 P4. El horizonte del mandato (la reputación)

Se usa la ideología **año a año**, con efectos fijos de ministro y de año. El coeficiente es "años que faltan × político": negativo significa que los nombrados por políticos se alejan del mediano al acercarse el fin del mandato, comparados con los de la Corte Suprema.

| | Disidencia | Distancia al mediano |
|---|---|---|
| Base nueva, después de 2005 (emIRT) | −0,006 (p = 0,70) | −0,039 (p = 0,47) |
| Base nueva, antes de 2005 / cambio después (emIRT) | +0,011 / −0,018 (p = 0,34) | +0,086 / −0,125 (p = 0,25) |
| Base nueva, después de 2005 (MCMCpack, Rubin) | — | +0,014 (p = 0,76) |
| Base del paper, después de 2005 (emIRT) | −0,008 (p = 0,48) | −0,037 (p = 0,58) |
| Base del paper, antes / cambio después (emIRT) | +0,006 / −0,014 (p = 0,24) | −0,040 / +0,002 (p = 0,98) |
| Base del paper, después de 2005 (MCMCpack, Rubin) | — | −0,076 (p = 0,31) |

**Robustez (base nueva, distancia, desde 2006, emIRT):**

| $\omega^2$ | Todo 2006+ | Sin 2015–2020 | Ponderado por votos |
|---|---|---|---|
| 0,05 | −0,010 (p = 0,86) | −0,064 (p = 0,49) | −0,076 (p = 0,35) |
| 0,10 | −0,010 (p = 0,85) | −0,069 (p = 0,47) | −0,069 (p = 0,35) |
| 0,20 | −0,010 (p = 0,84) | −0,071 (p = 0,46) | −0,061 (p = 0,36) |

La tabla de robustez (`robustez_horizonte.R`) usa todos los ministro-año que estima el IRT; la tabla anterior, solo los que tienen al menos 10 votos ese año. Por eso su columna "Todo 2006+" no coincide exactamente con la fila de emIRT de la tabla anterior.

**Prueba placebo.** Al asignar al azar quién es "nombrado por político", el 40 % de las veces sale un efecto igual o mayor.

**Sin agrupar las series.** Con los datos actuales, el efecto tampoco aparece sin agrupar: −0,054 (p = 0,44) en la tabla principal y −0,028 (p = 0,67) en la de robustez.

**Qué significa.** **No hay evidencia de efecto de horizonte.** El signo suele ser negativo (con MCMCpack en la base nueva, positivo), pero el efecto es chico y no significativo en ninguna versión. Una versión anterior de este documento sí lo encontraba (−0,13, p = 0,013), con la lectura antigua de disidencias y sin agrupar series. Era frágil: dependía de unos pocos votos.

---

## 8. Balance

1. **La réplica del paper funciona, así que las diferencias no vienen de nuestros datos ni de nuestro código.** Con su base, su método (idealstan con la covariable) y sus criterios se reproducen la validación (0,57 contra 0,56), el salto de la dispersión después de 2005 y sus Tablas 2 y 3, con los mismos signos y la misma significancia.
2. **Las diferencias vienen del estimador.** Con los mismos datos, los dos estimadores de Martin y Quinn no encuentran aumento de la dispersión en 2005, en ninguna de las dos bases, y la Tabla 2 cambia de signo. Los métodos coinciden dentro de cada año; difieren en cómo conectan las épocas. Antes de 2006 idealstan da vuelta la escala y usa una unidad de menos de la mitad del tamaño, y los datos de esos años son demasiado escasos para decidir qué conexión es la correcta. En la base nueva, además, la regla de idealstan sigue creciendo después de 2006, según los dos estimadores de Martin y Quinn.
3. **Lo que se sostiene en parte:** los nombrados por el Ejecutivo quedan más lejos del mediano que el resto (Tabla 3 del paper). En la base del paper se cumple con cualquier método, con significancia débil con Martin y Quinn; en la base nueva, solo con Martin y Quinn y sin significancia (p = 0,12). Con idealstan en la base nueva, los más lejanos son los nombrados por el Legislativo, aunque tampoco es significativo.
4. **Que la distancia de los nombrados por políticos crezca después de la reforma (la interacción de la ecuación 4) no es significativo** con ningún método ni base al considerar que las posiciones son estimadas (reglas de Rubin). Con idealstan el signo coincide con el paper; con Martin y Quinn es casi siempre negativo.
5. **No hay apoyo para el mecanismo reputacional.** El efecto de horizonte es chico y no significativo con emIRT y con MCMCpack, se agrupen o no las series.
6. **Pardow y Verdugo:** el enroque existe, pero los académicos no resultan más activistas.
7. **Lo que sí se puede decir:** después de 2006 la ideología estimada es una escala izquierda-derecha razonable con cualquier método. **La comparación con el tribunal anterior a la reforma**, que es la pregunta del paper, **no tiene una respuesta que no dependa del método.**
8. **Por qué cambió respecto de versiones anteriores de este documento:**
   - con un modelo estático, la base del paper mostraba un salto en 2005;
   - con la lectura antigua de disidencias faltaba información anterior a 2006;
   - con esa lectura antigua y sin agrupar las series, aparecía un efecto de horizonte;
   - el buscador fechaba mal 3 fallos (sección 7.1), lo que ponía a ministros en años en que no estaban en el Tribunal.

   Ninguna de estas cosas era un patrón de los datos: venían del método o de errores de lectura y fecha, ya corregidos.

### Siguientes pasos posibles

- **Pedir a los autores el código original** de la estimación con idealstan (unidad de tiempo, anclas, previas, cómo entra la covariable). Es la forma más directa de confirmar que la diferencia es de identificación y no de implementación.
- **Una medida que no dependa del estimador:** por ejemplo, la tasa de desacuerdo entre pares de ministros en cada fallo, o la proporción de fallos con disidencia, controlando por tipo de causa. No mide ideología, pero no necesita conectar escalas entre épocas.
- **Sensibilidad de idealstan:** anclas de la época anterior a 2006 (o una en cada época) y varianza del paseo fija, para ver si el salto sobrevive.
- **Más información antes de 2006:** incluir las prevenciones o las votaciones de fallos sin disidencia que tengan votos separados.

---

## 9. Supuestos y límites

- **Pocos ministros:** 29 a 46 con datos suficientes por base, y de 4 a 19 por grupo en las comparaciones antes y después. Poco poder estadístico.
- **Muchas pruebas:** se hicieron muchas, así que algún resultado significativo puede ser casualidad. Por eso se agregó la prueba placebo.
- **Antes de 2005 hay pocos fallos con disidencia por año** (2 a 10), tanto en la base nueva como en la del paper. Ese problema ya lo tenía el paper, y es la razón de que los métodos discrepen.
- **Escala entre épocas:** ningún método puede comprobar que la unidad de medida sea la misma antes y después de 2005 (sección 7.6).
- **MCMCpack en la base nueva converge solo con las anclas fijas en ±1** (sección 7.3), y converge bien solo desde 2006. Antes de 2006 y desde 2023 la convergencia es parcial (16 % y 12 % de los parámetros con R-hat > 1,1). Fijar las anclas en ±1 en vez de solo su signo es una decisión de identificación más.
- **Fechas del buscador del TC:** se descartan 3 fallos con fecha imposible (sección 7.1). La regla solo detecta errores grandes; un fallo fechado uno o dos años antes de lo debido no se detectaría.
- **Disidencias parciales:** cada base las codifica distinto, y eso explica buena parte de los desacuerdos entre bases.
- **Criterio para agrupar series:** exige una votación idéntica. Series con un ministro distinto no se agrupan.
- **Períodos de los ministros nombrados desde 2018:** salen de Wikipedia; hay que verificarlos con el Diario Oficial.
- **Codificación de carrera:** Romero Guzmán aparece como juez de carrera, lo que hay que revisar. La carrera de los nombrados desde 2018 no está registrada.
- **Una dimensión ideológica.** Bloques unitarios y $c$ fijo en la etapa 1.

---

## 10. Archivos y cómo reproducir

Desde RStudio con `TC.Rproj`, después de correr `codigo/1`, `2` y `3`. Todos los scripts se corren desde la carpeta raíz del proyecto, por ejemplo `Rscript modelo/estimar_ideologia.R`.

| Orden | Script | Qué hace | Tiempo |
|---|---|---|---|
| 1 | `modelo/estimar_ideologia.R` | IRT dinámico con emIRT, estático y W-NOMINATE, en las dos bases | ~2,5 min |
| 2 | `modelo/probar_predicciones.R` | Pruebas P1 a P4 y figuras 7 a 9 (emIRT) | ~10 s |
| 3 | `modelo/robustez_horizonte.R` | Robustez y placebo de P4 | ~1,5 min |
| 4 | `modelo/estimar_ideologia_bayes.R paper 5000 20000 10` | MCMCpack, base del paper | ~2 min |
| 4b | `modelo/estimar_ideologia_bayes.R nueva 5000 10000 10 1 fijas` (y `... 2 fijas`) | MCMCpack, base nueva, anclas fijas en ±1 (la versión principal); dos cadenas en paralelo. Parte de las posiciones de emIRT, así que va después del paso 1 | ~12 a 14 h |
| 4c | `modelo/estimar_ideologia_bayes.R nueva 5000 10000 10 1` (y `... 2`) | MCMCpack, base nueva, anclas solo con signo (no converge; sección 7.3) | ~12 a 14 h |
| 5 | `modelo/probar_bayes.R` | Dispersión, P1 y P4 con MCMCpack; R-hat; figura 10 | ~5 min |
| 5b | `modelo/diagnosticar_mcmcpack.R <nueva\|nueva_fijas>` | Dónde y por qué no converge MCMCpack | ~1 min |
| 6 | `modelo/replicar_paper_idealstan.R mcmc` (y `mcmc 500 sin_covariable`) | Réplica fiel del paper con idealstan | 20 a 40 min |
| 7 | `modelo/estimar_idealstan.R <paper\|nueva> [con_covariable\|sin_covariable]` | idealstan con los mismos datos que Martin y Quinn | paper ~6 min; nueva ~3,5 h |
| 8 | `modelo/probar_idealstan.R <mcmc\|mcmc_sincov> <paper\|paperprep\|nuevaprep>` o `modelo/probar_idealstan.R mcmcpack <paper\|nueva_fijas>` | Validación, dispersión, ecuación 4 y Tablas 2 y 3 del paper tal como se publicaron; con `mcmcpack` usa las muestras de Martin y Quinn; figura 11 | ~2 min |
| 9 | `modelo/comparar_metodos.R <paper\|nueva> [mcmcpack\|mcmcpack_fijas\|emirt]` | Comparación año a año entre métodos; figura 12 | ~1 min |
| — | `modelo/simular_modelo.R` | Simulación del Anexo A (opcional) | ~2 min |

**Paquetes:**

- `install.packages(c("emIRT", "pscl", "wnominate", "MCMCpack", "coda"))`.
- idealstan necesita además **Rtools 4.5** (Windows) y `cmdstanr`: `install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))`, luego `cmdstanr::install_cmdstan()` e `install.packages("idealstan")`.

`modelo/comun.R` tiene funciones compartidas y no se corre solo. Para repetir el análisis sin agrupar series, se cambia `AGRUPAR_SERIES <- FALSE`.

**Qué se sube a GitHub:** los scripts, este documento y `modelo/figuras/` (las figuras que muestra el documento). La carpeta `modelo/resultados/` no se sube: la crean los scripts, y las estimaciones de idealstan pesan hasta 150 MB cada una, más de lo que acepta GitHub. Al correr un script con otros argumentos aparecen figuras adicionales (por ejemplo, `fig11` para cada versión); el documento muestra solo las principales.

---

## Anexo A. Simulación (ilustrativa)

La simulación (`modelo/simular_modelo.R`) **no aporta evidencia**: sus números salen de supuestos. Sirvió para tres cosas:

1. **Revisar las derivaciones:** detectó un error en una primera versión de la fórmula del paquete.
2. **Ver qué resultados dependen de supuestos:** la diferencias en diferencias del paper solo sale positiva si los presidentes de 1990–2005 nombraban moderados.
3. **Mostrar el problema de la sección 5:** el estimador atribuye a la ideología lo que es reputación.

![Figura 1](figuras/fig1_composicion.png)

**Figura 1.** Tribunales simulados antes y después de 2005, y dispersión en 10.000 tribunales.

![Figura 2](figuras/fig2_distancia_origen.png)

**Figura 2.** Distancia simulada al mediano según quién nombró.

![Figura 3](figuras/fig3_costo_vacancia.png)

**Figura 3.** Dispersión simulada después de 2005 según el costo de la vacancia $c$.

![Figura 4](figuras/fig4_theta_estimado.png)

**Figura 4.** Posición verdadera y estimada en un tribunal simulado con reputación.

![Figura 5](figuras/fig5_horizonte.png)

**Figura 5.** En la simulación, el sesgo de la posición estimada crece al acercarse el fin del mandato (la predicción P4).

## Anexo B. Dónde están las fechas de los nombramientos

Las fechas no están en los fallos. Fuentes:

1. **[Wikipedia](https://es.wikipedia.org/wiki/Tribunal_Constitucional_de_Chile):** períodos y órgano que nombró.
2. **[Diario Oficial](https://www.diariooficial.interior.gob.cl):** decretos de nombramiento.
3. **[Tramitación del Senado](https://tramitacion.senado.cl):** acuerdos de nombramiento del Congreso.
4. **Prensa**, para los paquetes:
   - [Pauta 2022](https://www.pauta.cl/actualidad/2022/04/06/tribunal-constitucional-nombramientos-congreso-partidos-politicos.html)
   - [BioBío 2024](https://www.biobiochile.cl/noticias/nacional/chile/2024/01/10/senado-aprueba-a-4-nuevos-integrantes-del-tribunal-constitucional-son-de-la-dc-rn-ps-y-udi.shtml)
   - [CIPER 2014](https://www.ciperchile.cl/2014/12/18/sandias-caladas-para-el-tribunal-constitucional/)

---

## Referencias

- Black, D. (1948). On the rationale of group decision-making. *Journal of Political Economy*.
- Clinton, J., Jackman, S. y Rivers, D. (2004). The statistical analysis of roll call data. *American Political Science Review*.
- Dal Bó, E. y Rossi, M. (2011). Term length and the effort of politicians. *Review of Economic Studies*.
- Fábrega, J., Sajuria, J. y Drobny, S. *We did not see it coming: The unintended polarisation induced by an institutional reform. The case of the Chilean Constitutional Tribunal*. Borrador.
- Ferejohn, J. (1986). Incumbent performance and electoral control. *Public Choice*.
- Garoupa, N. y Ginsburg, T. (2015). *Judicial Reputation: A Comparative Theory*. University of Chicago Press.
- Gelman, A. y Rubin, D. (1992). Inference from iterative simulation using multiple sequences. *Statistical Science*.
- Imai, K., Lo, J. y Olmsted, J. (2016). Fast estimation of ideal points with massive data. *American Political Science Review*.
- Kubinec, R. (2019). Generalized ideal point models for time-varying and missing-data inference. Documento de trabajo; paquete `idealstan`.
- Martin, A. y Quinn, K. (2002). Dynamic ideal point estimation via Markov chain Monte Carlo for the U.S. Supreme Court, 1953–1999. *Political Analysis*.
- Pardow, D. y Verdugo, S. (2015). El Tribunal Constitucional chileno y la reforma de 2005. Un enroque entre jueces de carrera y académicos. *Revista de Derecho (Valdivia)*, 28(1).
- Poole, K. y Rosenthal, H. (1985). A spatial model for legislative roll call analysis. *American Journal of Political Science*.
- Romer, T. y Rosenthal, H. (1978). Political resource allocation, controlled agendas, and the status quo. *Public Choice*.
- Rubin, D. (1987). *Multiple Imputation for Nonresponse in Surveys*. Wiley.
- Capítulos 1, 2 y 4 del curso Economía Política Formal 2026 (J. Fábrega), <https://jfabregalacoa.github.io/econpol_2026/>.
