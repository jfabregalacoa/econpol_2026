// Quarto books consolidate explicit #refs blocks in the first chapter.
// Keep session 6's citeproc-generated bibliography visible and its links local,
// without changing the bibliography behavior of the preceding chapters.
const outputDir = Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR") || "_book";
const path = `${outputDir}/chapters/sesion_06_burocracia_capacidad_estatal.html`;
let html;
try {
  html = await Deno.readTextFile(path);
} catch (error) {
  if (error instanceof Deno.errors.NotFound) Deno.exit(0);
  throw error;
}

if (!/<div\b[^>]*\bid="refs"/.test(html)) {
  throw new Error("La sesión 6 no contiene la bibliografía generada por citeproc.");
}
const ids = new Set([...html.matchAll(/\bid="(ref-[^"]+)"/g)].map(m => m[1]));
html = html.replace(
  /(<div\b[^>]*\bid="refs"[^>]*?)\sstyle="display: none"/g,
  "$1",
);
html = html.replace(/<a\b[^>]*>/g, tag => {
  if (!/\brole="doc-biblioref"/.test(tag)) return tag;
  return tag.replace(/\bhref="[^"]*#(ref-[^"]+)"/, (_, id) => {
    if (!ids.has(id)) throw new Error(`Referencia local ausente: ${id}`);
    return `href="#${id}"`;
  });
});
await Deno.writeTextFile(path, html);
