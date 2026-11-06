# Abraham: tareas en curso

Proyecto: gobernadores regionales y reparto territorial. El detalle está en [notes-abraham.md](notes-abraham.md).

**Pregunta.** ¿Hacia qué comunas dirigen los gobernadores regionales su gasto discrecional: hacia las que los apoyaron (el núcleo) o hacia las que estuvieron en disputa? ¿Depende la respuesta del instrumento (subvenciones a organizaciones u obras FRIL a través del municipio)?

## Modelo

- [ ] Especificar cómo se convierten las subvenciones y las obras en votos ($V$) en cada comuna.
- [ ] Derivar el reparto óptimo y revisar cuáles de las predicciones de la sección 6 salen del modelo.
- [ ] Decidir si las subvenciones son bienes públicos y visibles o bienes de club (decisión 1 de la sección 8).
- [ ] Agregar al alcalde, aliado u opositor, y la opción de rodearlo con subvenciones (Bueno 2018).

## Datos

- [x] Transferencias de los gobiernos regionales del registro de la Ley 19.862, 2014–2026 (`datos/`).
- [ ] Completar las subvenciones que faltan (Figura 1, celdas grises): Metropolitana 2019–2023, Atacama 2018–2023, Tarapacá 2020–2022, Valparaíso 2020 y 2022, O'Higgins 2014–2016 y 2020–2022, Biobío casi todos los años hasta 2022, Magallanes 2014–2020 y 2025, Coquimbo 2020, Maule 2016. Primero revisar si es un problema de descarga o de clasificación; si no, buscar otra fuente (transparencia activa de cada gobierno regional, actas del CORE, solicitud por Ley de Transparencia).
- [ ] Resultados electorales por comuna (Servel): gobernador 2021 (primera y segunda vuelta) y 2024; alcalde 2021 y 2024, con partido y pacto. Confirmar qué elecciones cubren los datos por mesa que ya tiene Abraham.
- [ ] Controles por comuna: pobreza, ruralidad, población, ingresos propios y número de organizaciones.
- [ ] Deflactar los montos.

## Diseño

- [ ] Elegir la medida del apoyo previo: primera vuelta, segunda vuelta o votación del pacto.
- [ ] Fijar la regla de alineamiento alcalde–gobernador (mismo pacto o mismo partido; qué hacer con los independientes).
- [ ] Definir la muestra de regiones y años según la cobertura de la Figura 1.
- [ ] Escribir la ecuación de regresión (sección 7 de las notas).
