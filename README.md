# Economía Política Formal - 2026

Libro Quarto del curso. El repositorio estaba vacío al incorporar el primer capítulo.

## Render local

Requisitos: Quarto 1.10.18 y R 4.5.0 o compatibles. Desde la raíz:

```sh
Rscript scripts/instalar-dependencias.R
Rscript scripts/validar-capitulo.R
quarto render
quarto preview --no-browser
```

Las dependencias se declaran en `scripts/instalar-dependencias.R`; no se utiliza renv. El HTML queda en `_book/`. Los gráficos Plotly funcionan en el navegador sin Shiny; para otros formatos el capítulo conserva gráficos estáticos.

## Publicación

La única estrategia de publicación es `.github/workflows/publicar.yml`: instala dependencias, valida los modelos, renderiza el libro completo y publica `_book` mediante GitHub Pages.

Antes del primer push, seleccionar **Settings → Pages → Build and deployment → Source → GitHub Actions** en GitHub. El workflow se ejecuta al enviar cambios a `main` o manualmente desde Actions.

URL prevista: https://jfabregalacoa.github.io/econpol_2026/. La URL estará disponible después de habilitar Pages y completar el primer despliegue.

El render local no publica ni hace push. Los archivos generados se excluyen de Git.

## Validación realizada

- Libro completo renderizado con Quarto 1.10.18 y R 4.5.0.
- Todos los chunks R y las comprobaciones de `scripts/validar-capitulo.R` completados; también se ejecutaron las alternativas estáticas.
- HTML: 139 expresiones matemáticas, cuatro referencias bibliográficas resueltas, cinco gráficos estáticos y dos gráficos Plotly (51 y 9 cuadros).
- Ambos controles comprobados en navegador mediante animación y selección manual (punto de reversión 50 y abstención 0,5), sin errores de consola.
- Navegación entre presentación y capítulo comprobada; ningún recurso o enlace local faltante.
- R avisa que algunos paquetes se compilaron con revisiones posteriores de R 4.5; las pruebas y el render se completaron correctamente.

Ajustes técnicos al adjunto: delimitadores matemáticos compatibles con Quarto; eliminación de la columna `q` duplicada antes de `unnest()`; refresco de animaciones y etiquetas de Plotly. El contenido sustantivo se conserva. El código se puede desplegar con «Mostrar código».
