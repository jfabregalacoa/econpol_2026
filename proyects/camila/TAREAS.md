# Camila: tareas en curso

Proyecto: voto obligatorio y clientelismo municipal. El detalle está en [notes-camila.md](notes-camila.md).

**Pregunta.** Cuando el voto pasó a ser obligatorio, ¿se achicó el alza de subvenciones a organizaciones que los alcaldes que van a la reelección hacen antes de la elección (2016 frente a 2024)? *Secundaria:* ¿ocurrió lo mismo con el gasto municipal en educación?

## Modelo

- [ ] Calcular el ahorro $S_V - S_O$ y responder: ¿puede ser negativo? ¿en qué comunas es más grande?
- [ ] Llevar el modelo a la estructura de decisiones del capítulo 3 (Stokes), agregando la abstención.
- [ ] Decidir qué hace el alcalde con lo que ahorra: comprar votos, gasto programático (educación) u otro.
- [ ] Derivar las predicciones de la sección 6 de las notas.

## Datos

- [x] Subvenciones municipales del registro de la Ley 19.862, 2014–2026 (`datos/`).
- [ ] Resultados electorales por comuna (Servel): participación 2016, 2021 y 2024; alcalde electo en 2016 y 2021; quién repostuló en 2024 y quién estaba impedido.
- [ ] Gasto municipal anual en educación y en transferencias (SINIM).

## Diseño

- [ ] Fijar qué meses cuentan como "previos" a la elección.
- [ ] Definir el grupo de comparación: solo los alcaldes impedidos o también los que se retiran.
- [ ] Escribir la ecuación de regresión (sección 7 de las notas).
