from build_plazas import *
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, Color, white
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, Table, TableStyle
from reportlab.lib.styles import ParagraphStyle
import fitz

FONT='/usr/share/fonts/truetype/dejavu/'
pdfmetrics.registerFont(TTFont('DVS',FONT+'DejaVuSans.ttf'))
pdfmetrics.registerFont(TTFont('DVS-Bold',FONT+'DejaVuSans-Bold.ttf'))
pdfmetrics.registerFontFamily('DVS',normal='DVS',bold='DVS-Bold')
W,H=1100,820
INK='#17324C'; MUTED='#586C80'; BLUE='#326A99'; TEAL='#267F79'; RULE='#D5E0EA'
PAGE_PLACEMENTS=[]; PAGE_TITLES=[]; OVERFLOWS=[]

INTRO='Este informe reconstruye las vías institucionales estandarizadas que pueden producir, recuperar o mantener plazas públicas en Chile. Distingue quién propone, formula, evalúa, financia, contrata y mantiene. Los diagramas son una síntesis analítica de normas y documentos oficiales; no son flujogramas emitidos por los organismos.'
SCOPE='Corte documental: 6 de noviembre de 2026. Se mapean familias nacionales y variantes regionales verificadas, no todas las combinaciones contractuales posibles ni las convocatorias de las 16 regiones. La existencia de una vía legal no implica que haya recursos o una postulación abierta en la fecha de lectura.'
MAINT='Construcción, recuperación y mantención no son una sola cadena presupuestaria. La obra puede financiarla un ministerio o un GORE y terminar bajo administración municipal; el riego, aseo, jardinería y reparaciones posteriores requieren otra decisión de organización y gasto.'

ACTORS=[
 ('Alcalde / alcaldesa','Propone prioridades y presupuesto; representa al municipio, presenta proyectos y dicta actos de ejecución y contratación dentro de sus atribuciones.','S01'),
 ('Concejo municipal','Aprueba presupuesto y actos que la ley le reserva. Contratos ≥500 UTM: mayoría absoluta; si exceden período alcaldicio: dos tercios. También interviene en concesiones.','S01 art. 65'),
 ('SECPLA / profesional formulador','Traduce demanda en cartera, perfil, diseño, presupuesto y postulación. Puede haber arquitectos municipales o consultores. No existe un cargo único de arquitecto SECPLA obligatorio para toda plaza.','S01 art. 21'),
 ('Director de Obras Municipales','Revisa permisos y recepciones urbanísticas cuando proceden; dirige construcciones de responsabilidad municipal en el marco de su competencia.','S01 art. 24; S03'),
 ('Jefatura de áreas verdes / aseo y ornato','Programa o controla construcción, conservación y administración de áreas verdes. Nombre y organización de la unidad varían entre municipios.','S01 art. 25'),
 ('Gobernador regional','Órgano ejecutivo del GORE: impulsa cartera, propone distribución y ejecuta acuerdos y presupuesto regional. No es superior jerárquico del alcalde ni de las SEREMI.','S02'),
 ('Consejo Regional · CORE','Aprueba marcos y presupuesto; asignación individual sobre 7.000 UTM de ejecución y estudios/diseños que los originan; aprueba convenios de programación.','S02 art. 36'),
 ('Equipos técnicos del GORE','Planifican, revisan pertinencia, analizan y gestionan inversiones según estructura e instructivos regionales. DIPLADER y DIPIR no cumplen la misma función.','S02; S12'),
 ('SEREMI MINVU / director SERVIU','SEREMI coordina política y programación sectorial regional; SERVIU formula o contrata proyectos y ejecuta obras. Sus roles cambian según el programa.','S18; S19'),
 ('Analista MDSF / SEREMI de Desarrollo Social','Evalúa inversión cuando corresponde. Un resultado favorable habilita técnicamente; no asigna el presupuesto político de la plaza.','S05; S34'),
 ('SUBDERE / jefe URS / equipo central','Revisa y tramita programas de inversión local. URS conecta al municipio con el nivel central; hay diferencias entre programas y líneas.','S09; S24; S26; S27'),
 ('Comunidad organizada / CVD / EP','Vecinos plantean y priorizan necesidades; el CVD tiene un papel formal en Quiero Mi Barrio. La Entidad Patrocinante desarrolla y tramita proyectos DS 27.','S16; S17'),
 ('Proyectista / constructor / inspector','El proyectista diseña; el contratista construye; ITO o inspector fiscal controla obra. Inspector de servicios controla mantenimiento contratado: no son funciones intercambiables.','S01; S18; S31; S33'),
]

def p(c,txt,x,y,w,size=14,lead=None,color=INK,bold=False):
    sty=ParagraphStyle('x',fontName='DVS-Bold' if bold else 'DVS',fontSize=size,leading=lead or size*1.4,textColor=HexColor(color),spaceAfter=0)
    para=Paragraph(txt,sty); ww,hh=para.wrap(w,10000)
    para.drawOn(c,x,y-hh)
    if y-hh<56 and y>56: OVERFLOWS.append((len(PAGE_TITLES),round(y-hh,2),txt[:90]))
    return y-hh

def base(c,section,title,subtitle=None):
    PAGE_TITLES.append(title)
    c.setFillColor(HexColor('#FAFCFE'));c.rect(0,0,W,H,fill=1,stroke=0)
    c.setFillColor(HexColor(TEAL));c.rect(40,776,38,5,fill=1,stroke=0)
    p(c,section.upper(),90,785,960,10.5,color=MUTED,bold=True)
    end=p(c,title,40,751,1020,29,35,bold=True)
    if subtitle: end=p(c,subtitle,40,end-10,1020,13.5,19,color=MUTED)
    c.setStrokeColor(HexColor(RULE));c.setLineWidth(.7);c.line(40,48,1060,48)
    p(c,'PLAZAS PÚBLICAS EN CHILE · MAPEO INSTITUCIONAL · 06 NOV 2026',40,34,950,9,color=MUTED)
    p(c,str(len(PAGE_TITLES)),1020,34,40,10,color=MUTED)
    return end-22

def finish(c):c.showPage()

def box(c,title,txt,x,y,w,accent=TEAL,size=15):
    c.setFillColor(HexColor(accent));c.roundRect(x,y-5,4,19,2,fill=1,stroke=0)
    z=p(c,title,x+15,y+15,w-15,17,bold=True,color=accent)
    z=p(c,txt,x+15,z-10,w-15,size)
    return z-26

def sources_line(c,ids,x=40,y=83,w=1020):
    refs=' · '.join(f'<a href="{html.escape(SOURCE[s]["url"],quote=True)}" color="{BLUE}">{s}</a>' for s in ids)
    p(c,'BASE DOCUMENTAL  '+refs+'  |  Referencias completas al final.',x,y,w,10.5,15,color=MUTED)

def route_page(c,r):
    y=base(c,r['id']+' · '+r['kind'],r['title'])
    y=p(c,r['scope'],40,y+4,1020,14.5,21)-14
    top=min(y,662)
    c.setFillColor(white);c.roundRect(40,104,704,top-104,12,fill=1,stroke=0)
    PAGE_PLACEMENTS.append((len(PAGE_TITLES)-1,str(OUT/'diagramas'/f'{r["id"]}.pdf'),(53,H-top+8,731,H-111)))
    z=top-2
    for title,txt in r['notes']:
        z=p(c,title.upper(),772,z,288,11,15,color=TEAL,bold=True)-6
        z=p(c,txt,772,z,288,12.5,17)-17
    if z<99: OVERFLOWS.append((len(PAGE_TITLES),'sidebar',r['id'],z))
    p(c,r['standard'],40,top-4,680,0.01,0.01) if False else None
    sources_line(c,r['sources'],y=86)
    finish(c)

def table(c,rows,widths,x,y,fontsize=13,head=True,padding=8):
    sty=ParagraphStyle('t',fontName='DVS',fontSize=fontsize,leading=fontsize*1.3,textColor=HexColor(INK))
    styh=ParagraphStyle('th',parent=sty,fontName='DVS-Bold',textColor=white)
    data=[[Paragraph(str(v),styh if head and i==0 else sty) for v in row] for i,row in enumerate(rows)]
    t=Table(data,colWidths=widths,hAlign='LEFT')
    commands=[('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),10),('RIGHTPADDING',(0,0),(-1,-1),10),('TOPPADDING',(0,0),(-1,-1),padding),('BOTTOMPADDING',(0,0),(-1,-1),padding),('LINEBELOW',(0,0),(-1,0),1,HexColor(TEAL))]
    if head: commands.append(('BACKGROUND',(0,0),(-1,0),HexColor(INK)))
    for i in range(1 if head else 0,len(rows)):
        commands.append(('BACKGROUND',(0,i),(-1,i),HexColor('#EDF3F8' if i%2 else '#FFFFFF')))
    t.setStyle(TableStyle(commands));tw,th=t.wrap(sum(widths),10000);t.drawOn(c,x,y-th)
    if y-th<58:OVERFLOWS.append((len(PAGE_TITLES),'table',y-th))
    return y-th

def cover(c):
    y=base(c,'Informe de investigación documental','Cómo se construyen, recuperan\ny mantienen las plazas públicas'.replace('\n','<br/>'),'Chile · Actores, decisiones y recorridos institucionales')
    y=p(c,INTRO,40,y,1010,17,25)-24
    y=box(c,'28 fichas de rutas y variantes · 3 diagramas transversales','Desde la demanda vecinal y la cartera de un alcalde hasta la inversión regional, los programas ministeriales, las obligaciones del urbanizador y el servicio de áreas verdes.',40,y,1010,size=16)
    y=box(c,'Una separación indispensable',MAINT,40,y,1010,size=16)
    y=box(c,'Alcance y grado de certeza',SCOPE+' Se incluye una ficha complementaria FOSIS, R23, con evidencia regional anterior y alcance expresamente limitado.',40,y,1010,size=15)
    y=box(c,'Cómo leer los diagramas','Cada caja identifica actor y acción; las flechas indican tramitación o entrega de antecedentes. Los rombos son decisiones; los retornos punteados muestran correcciones o ciclos. Son recorridos mínimos: los textos laterales fijan condiciones y límites.',40,y,1010,size=15)
    labels=[('Municipal','municipal'),('Regional','regional'),('Sectorial','sector'),('Evaluación / decisión','evaluation'),('Comunidad','community'),('Privado / contratista','private')]
    xx=40
    for label,grp in labels:
        c.setFillColor(HexColor(PALETTE[grp][0]));c.roundRect(xx,83,161,30,5,fill=1,stroke=0)
        p(c,label,xx+8,104,145,10,color=INK,bold=True);xx+=173
    finish(c)

def actors_page(c):
    y=base(c,'Actores y competencias','Quién decide qué','Los cargos representan funciones institucionales; no se atribuyen decisiones a personas actualmente en ejercicio.')
    rows=[['Actor','Función en el proceso','Base']]+ACTORS
    y=table(c,rows,[218,680,122],40,y,fontsize=10.8,padding=6)
    p(c,'La relación entre alcalde, gobernador y SEREMI es de coordinación entre competencias. Financiador, mandante, unidad técnica y operador pueden ser organismos distintos.',40,y-14,1020,12.5,color=MUTED)
    finish(c)

def index_page(c,start,end,num):
    y=base(c,'Guía de lectura',f'Catálogo de rutas · {num} de 2','Las fichas R22 y R23 requieren una lectura especial: modalidad transversal y vía complementaria acotada, respectivamente.')
    rows=[['Ficha / página','Vía institucional','Intervención / cobertura']]
    for i,r in enumerate(ROUTES[start:end],start):
        rows.append([f'{r["id"]} · p. {9+i}',r['title'],r['kind']])
    y=table(c,rows,[110,580,330],40,y,fontsize=13)
    p(c,'Diagramas comunes: T00 clasifica la intervención; T01 separa evaluación de financiamiento; T02 muestra contratación, recepción y operación. Una plaza puede combinar más de una ficha.',40,y-16,1020,13,color=MUTED)
    finish(c)

def gates_page(c):
    y=base(c,'Reglas de lectura','Las decisiones políticas y las puertas técnicas','No todas las aprobaciones tienen el mismo objeto ni el mismo efecto.')
    rows=[['Decisión','Quién interviene','Qué acredita / qué falta'],
    ['Incorporar una prioridad','Alcalde, gobernador o autoridad sectorial; comunidad según instrumento','Expresa intención o prioridad. Todavía faltan suelo, proyecto, evaluación y recursos.'],
    ['Aprobar presupuesto / aportes','Concejo, CORE, ministerio y autoridades presupuestarias según fuente','Autoriza gasto dentro de sus competencias. No reemplaza permisos, licitación ni recepción.'],
    ['Habilitar técnicamente','Formulador; evaluador MDSF o entidad competente en régimen especial','Consistencia, elegibilidad o conveniencia de inversión. Un RS no asigna dinero.'],
    ['Autorizar intervención del suelo','Propietario/administrador; DOM y otros órganos cuando procede','Disponibilidad y viabilidad jurídica/urbanística. El plan regulador por sí solo no financia una plaza.'],
    ['Contratar y controlar','Autoridad ejecutora; comisión evaluadora; inspector; contratista','Bases, adjudicación, contrato y prestaciones. El constructor no decide la prioridad pública.'],
    ['Recibir y mantener','Unidad técnica; DOM si corresponde; operador del activo','Recepción contractual, recepción urbanística y entrega son actos distintos. La inauguración no sustituye ninguno.']]
    y=table(c,rows,[215,335,470],40,y,fontsize=13.5)
    y=p(c,'<b>Participación:</b> el CVD tiene una posición contractual en Quiero Mi Barrio; otros programas usan diagnósticos, validación o consulta. No existe un veto vecinal vinculante universal para todas las plazas.',40,y-18,1020,13.5)
    p(c,'<b>Controles externos:</b> CMN, SEA, servicios sanitarios/eléctricos, autoridad marítima o Bienes Nacionales intervienen según suelo y proyecto. Contraloría puede controlar legalidad y rendición; no es una estación previa idéntica en todos los recorridos.',40,y-12,1020,13.5)
    sources_line(c,['S01','S02','S03','S05','S16','S37','S38']);finish(c)

def limits_page(c):
    y=base(c,'Método y límites','Qué queda acreditado y qué debe verificarse localmente')
    blocks=[
    ('Fuentes y jerarquía','Se consultaron leyes y reglamentos consolidados en BCN, Diario Oficial, normas SNI, presupuesto DIPRES, guías de SUBDERE, MINVU y SPD, e instrucciones y bases oficiales territoriales. Se privilegió la norma vigente sobre páginas divulgativas antiguas. Los PDF escaneados se leyeron con apoyo de OCR, sin basar las conclusiones en caracteres dudosos.'),
    ('Estandarización real','Los diagramas reconstruyen competencias, actos y secuencias documentadas. La estandarización es nacional en algunas rutas; en otras consiste en un marco nacional más bases regionales o un convenio. Las tareas operativas municipales se presentan como ciclo funcional, no como un manual obligatorio para todas las comunas.'),
    ('Cambios que importan para el análisis','DS 312: foco modificado en abril de 2026. FRC: cofinanciamiento GORE opcional en glosa 2026 y exigencia expresa de recomendación MDSF. Conservación: separación regional/mixta frente a sectorial. Contratación de servicios: considerar DS 661/2024, no copiar sin revisar referencias antiguas a DS 250.'),
    ('Cobertura sin falsa exhaustividad','No se certifica la vigencia de cada convocatoria, plazo o cupo regional. R23 conserva una limitación documental explícita. Convenios ad hoc, donaciones o apadrinamientos, presupuestos participativos y fondos complementarios no se convierten aquí en rutas nacionales autónomas sin procedimiento uniforme acreditado. Pueden alimentar una ruta municipal, sectorial o urbanística ya descrita.'),
    ('Cómo auditar una plaza concreta','Solicitar: código BIP u otro identificador; fuente y año presupuestario; dominio/administración del terreno; formulador y unidad técnica; resultado de evaluación o exención; acuerdos de concejo/CORE que procedan; resolución y convenio; expediente de contratación; recepciones; documento de entrega; presupuesto y contrato o programa de mantención.'),
    ('Qué no demuestra el mapa','Las fuentes normativas no prueban clientelismo, negociación informal, motivaciones electorales ni tiempos efectivos. Para estudiar esas conductas se requieren expedientes, actas, series de proyectos o entrevistas. El mapa permite identificar actores y decisiones observables, no atribuirles incentivos sin evidencia.')]
    for title,txt in blocks:
        y=p(c,title,40,y,1020,16,bold=True,color=TEAL)-7
        y=p(c,txt,40,y,1020,14,19.3)-18
    finish(c)

def bib_pages(c):
    vals=list(SOURCE.values())
    for start in range(0,len(vals),7):
        y=base(c,'Referencias primarias',f'Fuentes y localizadores · {start//7+1} de {(len(vals)+6)//7}','Todas las fuentes se consultaron para este informe. Los enlaces permiten volver al documento oficial; las versiones web pueden cambiar.')
        for s in vals[start:start+7]:
            y=p(c,f'{s["id"]}  {html.escape(s["title"])}',40,y,1020,14,bold=True)-4
            y=p(c,html.escape(s['locator']),40,y,1020,12.5,17,color=MUTED)-4
            u=html.escape(s['url'],quote=True)
            y=p(c,f'<a href="{u}" color="{BLUE}">Abrir fuente oficial ↗</a>',40,y,1020,11.5,16)-17
        finish(c)

def make_pdf(sample=False):
    PAGE_PLACEMENTS.clear();PAGE_TITLES.clear();OVERFLOWS.clear()
    temp=OUT/'base_temporal.pdf'
    c=canvas.Canvas(str(temp),pagesize=(W,H),pageCompression=1)
    c.setTitle('Plazas públicas en Chile: construcción, recuperación y mantención')
    c.setAuthor('Investigación documental preparada para Felipe Arenas con asistencia de IA')
    c.setSubject('Mapeo institucional de rutas estandarizadas; corte 6 de noviembre de 2026')
    if sample:route_page(c,ROUTES[1])
    else:
        cover(c);route_page(c,COMMON[0]);actors_page(c);index_page(c,0,14,1);index_page(c,14,28,2)
        route_page(c,COMMON[1]);route_page(c,COMMON[2]);gates_page(c)
        for r in ROUTES:route_page(c,r)
        limits_page(c);bib_pages(c)
    c.save()
    doc=fitz.open(temp)
    scales=[]
    for num,file,rect in PAGE_PLACEMENTS:
        graph=fitz.open(file); gr=graph[0].rect; target=fitz.Rect(rect)
        scale=min(target.width/gr.width,target.height/gr.height)
        scales.append(dict(page=num+1,id=Path(file).stem,node_font=round(17*scale,2),edge_font=round(14*scale,2)))
        doc[num].show_pdf_page(target,graph,0,keep_proportion=True)
        graph.close()
    doc.set_toc([[1,t,i+1] for i,t in enumerate(PAGE_TITLES)])
    path=OUT/('muestra.pdf' if sample else 'Plazas_publicas_Chile_mapeo_institucional.pdf')
    doc.save(path,garbage=4,deflate=True);doc.close();temp.unlink()
    (OUT/'control_calidad.json').write_text(json.dumps(dict(pages=len(PAGE_TITLES),overflows=OVERFLOWS,font_scales=scales),ensure_ascii=False,indent=2))
    print(json.dumps(dict(pdf=str(path),pages=len(PAGE_TITLES),overflows=OVERFLOWS,min_font=min(x['node_font'] for x in scales)),ensure_ascii=False))
    return path

def mermaid(r):
    lines=['flowchart TD']
    for n in r['nodes']:
        label=n['actor']+(' — '+n['action'] if n['action'] else '')
        label=label.replace('\n',' ').replace('"',"'")
        shape=('{"'+label+'"}') if n['group']=='decision' else ('["'+label+'"]')
        lines.append('    '+n['id']+shape)
    for e in r['edges']:
        lab=e['label'].replace('"',"'")
        lines.append('    '+e['source']+(' -->|"'+lab+'"| ' if lab else ' --> ')+e['target'])
    return '\n'.join(lines)

def companions():
    save_data()
    md=['# Plazas públicas en Chile: construcción, recuperación y mantención','', '**Corte documental: 6 de noviembre de 2026.**','',INTRO,'',SCOPE,'',MAINT,'','## Actores','', '| Actor | Función | Base |','|---|---|---|']
    md+=['| '+' | '.join(row)+' |' for row in ACTORS]
    md+=['','## Catálogo','', '| Ficha | Vía | Intervención |','|---|---|---|']
    md+=['| '+r['id']+' | '+r['title']+' | '+r['kind']+' |' for r in ROUTES]
    for r in COMMON+ROUTES:
        md+=['',f'## {r["id"]} · {r["title"]}','',r['scope'],'',f'**Estandarización:** {r["standard"]}','','```mermaid',mermaid(r),'```','']
        for title,txt in r['notes']:md+=[f'**{title}.** {txt}','']
        md+=['**Fuentes:** '+', '.join(f'[{s}]({SOURCE[s]["url"]})' for s in r['sources'])+'.','']
        (OUT/'diagramas'/f'{r["id"]}.mmd').write_text(mermaid(r))
    md+=['','## Alcance de uso','', 'Los procesos no prueban motivaciones electorales, negociación informal ni tiempos efectivos. Para estudiar esas conductas se requieren expedientes, actas, series de proyectos o entrevistas. Las convocatorias y bases regionales deben verificarse para la plaza y año concretos. R23 es un antecedente complementario de alcance regional y anterior, no una certificación de procedimiento nacional 2026.','', 'La exención de evaluación no elimina antecedentes, permisos ni controles. La recepción contractual, recepción urbanística y entrega al operador son actos distintos. Inaugurar no reemplaza recibir ni financiar la mantención.','','## Fuentes primarias','']
    for s in SOURCE.values():md+=[f'### {s["id"]} · {s["title"]}','',s['locator'],'',s['url'],'']
    (OUT/'Plazas_publicas_Chile_mapeo_editable.md').write_text('\n'.join(md))
    with (OUT/'fuentes.csv').open('w',newline='',encoding='utf-8-sig') as f:
        wr=csv.DictWriter(f,fieldnames=['id','title','locator','url']);wr.writeheader();wr.writerows(SOURCE.values())
    with (OUT/'comunicaciones.csv').open('w',newline='',encoding='utf-8-sig') as f:
        wr=csv.writer(f);wr.writerow(['ruta','origen_nodo','actor_origen','destino_nodo','actor_destino','acto_o_transicion','fuentes_del_recorrido'])
        for r in COMMON+ROUTES:
            nodes={n['id']:n for n in r['nodes']}
            for e in r['edges']:wr.writerow([r['id'],e['source'],nodes[e['source']]['actor'],e['target'],nodes[e['target']]['actor'],e['label'],'; '.join(r['sources'])])
    (OUT/'LEEME.md').write_text('''# Mapeo institucional de plazas públicas en Chile

Corte: 6 de noviembre de 2026. 28 fichas y 3 diagramas transversales.

- PDF: informe diagramado con referencias y localizadores.
- Markdown: versión editable con diagramas Mermaid.
- diagramas/: cada flujo como SVG vectorial, PDF, PNG, DOT y Mermaid.
- catalogo.json: actores, acciones, relaciones, notas y fuentes por ficha.
- comunicaciones.csv: relaciones dirigidas entre nodos; referencias del recorrido completo, no una codificación jurídica independiente de cada flecha.
- fuentes.csv: registro de fuentes y localizadores.
- build_plazas.py y render_plazas.py: fuentes de generación. Requieren Python, Graphviz, ReportLab, PyMuPDF y fuentes DejaVu.

Los flujos son reconstrucciones analíticas de documentos oficiales. No son flujogramas oficiales ni acreditan todas las convocatorias regionales. R23 tiene un alcance documental limitado expresamente indicado. Los cargos corresponden a funciones, no a personas actualmente en ejercicio.
''')

if __name__=='__main__':
    import sys
    if '--sample' in sys.argv:
        render_diagram(ROUTES[1]);make_pdf(True)
    else:
        for r in COMMON+ROUTES:render_diagram(r)
        make_pdf();companions()
