# Proyecto de Carlos — resumen del paper base

**Paper:** *We did not see it coming: The unintended polarisation induced by an
institutional reform. The case of the Chilean Constitutional Tribunal*
**Autores:** Jorge Fábrega (UDD), Javier Sajuria (QMUL), Sammy Drobny (UDD)

> Este archivo es solo un resumen. Los datos y el código del paper no se copian
> a este repositorio.

## Pregunta

¿Puede una reforma institucional diseñada para equilibrar fuerzas políticas
generar, sin quererlo, polarización ideológica dentro de un tribunal? El caso es
la reforma constitucional chilena de 2005 al Tribunal Constitucional (TC).

## Argumento

- Los jueces del TC no pueden ser removidos por el contenido de sus fallos, así
  que la polarización no se explica por presión directa de quienes los nombran.
- La explicación propuesta es **reputacional** (Garoupa y Ginsburg): los jueces
  nombrados por actores políticos cuidan su reputación individual ante
  audiencias externas (su sector político); los nombrados por la Corte Suprema
  cuidan la reputación colectiva ante audiencias internas (el poder judicial).
- Por lo tanto, una reforma que da más peso a actores políticos en los
  nombramientos debería "importar" la polarización política al Tribunal.

## La reforma de 2005

| | Antes de 2005 (7 miembros) | Después de 2005 (10 miembros) |
|---|---|---|
| Corte Suprema | 3 (votación secreta, jueces de la propia Corte) | 3 (mismo método, pero puede nombrar externos) |
| Presidente | 1 | 3 |
| Congreso | 1 (Senado, mayoría simple) | 4 (Senado y Cámara, dos tercios) |
| COSENA | 2 | 0 (pierde la facultad) |

La regla de dos tercios en el Congreso buscaba moderación. Pero convive con una
regla informal, la **"regla del empate"**: izquierda y derecha se turnan los
nombramientos, y cada bloque elige a alguien de su sector cuando le toca.

## Datos y método

- Votos de los ministros del TC desde 1990, a partir de las sentencias publicadas
  y los votos disidentes, que son obligatorios y permiten observar desacuerdos.
  Solo se incluyen ministros con al menos 10 votos.
- **Puntos ideales bayesianos** (paquete `idealstan` en R): se estima la
  ideología latente de cada ministro por período, con la fuente de nombramiento
  como covariable.
- Validación: la ideología estimada se correlaciona (−0,56) con una
  clasificación manual de 18 ministros con afiliación partidaria conocida
  (izquierda/derecha).
- Distancia de cada ministro al juez mediano del año de su nombramiento:
  δ = |Î − m|.
- Regresiones:
  1. Diferencias en diferencias sobre la dispersión ideológica (tratados =
     nombrados por los poderes políticos; control = Corte Suprema).
  2. MCO: δ = a + b·Reforma + c·Político + d·Reforma×Político.

## Resultados

1. **Más dispersión después de 2005.** La desviación estándar anual de las
   ideologías sube tras la reforma y se mantiene más allá de los años cubiertos
   por estudios anteriores (Carroll y Tiede 2012; Pardow y Verdugo 2015).
2. **La dispersión se concentra en los nombrados por los poderes políticos.** El
   coeficiente de diferencias en diferencias (tratado × reforma) es
   significativo: 0,478 para Ejecutivo + Legislativo y 0,530 solo para el
   Ejecutivo (N = 54).
3. **La relación se invierte.** Antes de la reforma, los nombrados por COSENA y
   la Corte Suprema estaban más lejos del mediano; después, los más lejanos son
   los nombrados por el Ejecutivo y el Legislativo.
4. **El efecto lo genera el Ejecutivo.** Al controlar por la reforma, los
   nombrados por el Presidente están significativamente más lejos del mediano
   (≈ 0,37–0,38, N = 36). El efecto del Legislativo tiene el mismo signo pero no
   es significativo, lo que sugiere que la regla de dos tercios moderó la lógica
   de cuotas.
5. Se discute la explicación alternativa de Pardow y Verdugo: el cambio sería
   cultural (académicos que reemplazan a jueces de carrera). El test de distancia
   al mediano al momento del nombramiento apunta a la ideología.

## Conclusión

Quienes diseñaron la reforma se concentraron en eliminar los enclaves
autoritarios (senadores designados, COSENA) y no anticiparon el efecto
polarizador. Las reglas formales operan sobre reglas informales (el empate entre
coaliciones), y eso cambia los incentivos. En países con baja confianza en el
poder judicial, como Chile, esta polarización pone en riesgo la legitimidad del
Tribunal, al que se ha llegado a llamar "tercera cámara".

## Conexión con el curso

- Diseño institucional y consecuencias no previstas.
- Reglas de votación (mayoría simple frente a supermayoría) y teorema del votante
  mediano aplicado a cuerpos colegiados.
- Reglas formales frente a informales (cuotas, turnos entre coaliciones).
- Incentivos reputacionales y audiencias de los agentes nombrados.
