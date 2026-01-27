#set page(
  paper: "a4",
  margin: (
    top: 2.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ),
  numbering: "1",
  number-align: right,
  header: context {
    // APA7: Running head on all pages
    if counter(page).get().first() > 1 [
      #set text(size: 10pt)
      #smallcaps[Kurzskala Stress (KSSB)]
      #h(1fr)
      #counter(page).display("1")
    ]
  }
)

// Font and text settings
#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "de",
  hyphenate: true,
)

// Paragraph settings
#set par(
  justify: true,
  leading: 1.15em,
  first-line-indent: 1.27cm, // APA7 requires 0.5 inch (1.27cm) paragraph indent
)

// Heading styles (APA7)
#set heading(numbering: none)
// Level 1: Centered, Bold, Title Case
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 12pt, weight: "bold")
  set align(center)
  block(above: 2em, below: 1em, it)
}
// Level 2: Left-aligned, Bold, Title Case
#show heading.where(level: 2): it => {
  set text(size: 12pt, weight: "bold")
  block(above: 1.5em, below: 1em, it)
}
// Level 3: Left-aligned, Bold Italic, Title Case
#show heading.where(level: 3): it => {
  set text(size: 12pt, weight: "bold", style: "italic")
  block(above: 1.5em, below: 1em, it)
}

// Link styling
#show link: set text(fill: blue)

// Bibliography configuration (APA 7 style)
#set bibliography(style: "apa", title: none)

// Table styling
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 1pt + black)
  } else if y == 1 {
    (top: 0.5pt + black)
  },
  inset: 8pt,
)
#show table: set text(size: 10pt)

// Figure and Table styling (APA7: caption above)
#set figure(gap: 1em)
#show figure: it => {
  // APA7: Number and title above for both figures and tables
  set align(left)
  v(1em)

  // Caption above (number + title)
  if it.caption != none {
    block[
      #text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering)]
      #linebreak()
      #text(style: "italic")[#it.caption.body]
    ]
    v(1em)
  }

  // The figure/table content
  it.body

  v(1em)
}
#show figure.caption: none // Hide default caption since we're showing it manually above

// Title page
#align(center)[
  #v(2cm)
  #text(size: 18pt, weight: "bold")[
    Kurzskala zur Erfassung von Stressbelastung,\
    Stresssymptomen und Bewältigungsstrategien\
    (KSSB)
  ]
  #v(0.5em)
  #text(size: 12pt, style: "italic")[
    Testmanual
  ]
  #v(1.5cm)
  #text(size: 11pt)[
    E1: Diagnostisches Praktikum I\
    Prof. Dr. Beatrice Rammstedt
  ]
  #v(1.5cm)
  #text(size: 12pt)[
    Laura Weber -- laura.weber\@students.uni-mannheim.de -- 2008944\
    Gianna Hemm -- gianna.hemm\@students.uni-mannheim.de -- 2008130 \
    Lisa Eileen Kipp -- lisa.kipp\@students.uni-mannheim.de -- 2008567 \
    Linus Sehn -- linus.sehn\@students.uni-mannheim.de -- 2008592 \
    Maximilian David Pöppe -- maximilian.poeppe\@students.uni-mannheim.de -- 2017027\
  ]
  #v(1cm)
  #text(size: 11pt)[
    Fakultät für Sozialwissenschaften\
    Fachbereich Psychologie\
    Universität Mannheim
  ]
  #v(1.5cm)
  #text(size: 12pt)[
    HWS 2025
  ]
  #v(0.5em)
  #text(size: 11pt)[
    Abgabe: 30.01.2026
  ]
]

#pagebreak()

#align(center)[
  #text(size: 12pt, weight: "bold")[Zusammenfassung]
]

#v(0.5em)

// APA7: Abstract block should not have first-line indent
#par(first-line-indent: 0em, justify: true)[
  Angelehnt an das Stress- und Coping-Inventar (2. überarbeitete und neunormierte Version; Satow, #cite(<satow_sci_2024>, form: "year")) erfasst die Kurzskala zur Erfassung von Stresssymptomen, Stressbelastung und Stressbewältigung (KSSB) sieben namensgebende Unterskalen, darunter fünf Stressbewältigungsskalen, mit insgesamt 15 Items. Inhaltlich untergliedern sich die Skalen Stresssymptome und Stressbelastung in weitere Unteraspekte. Die KSSB eignet sich für die Anwendung in der Allgemeinbevölkerung (n = 180), allen voran studentische Stichproben (64.4%), wodurch Stress als breites Konstrukt in etwa 3 Minuten erhoben werden kann. Insgesamt weist die KSSB zufriedenstellende Kennwerte mit einer bestätigten Faktorenstruktur auf, auch im Vergleich mit etablierten Maßen.
]

#v(1em)

#par(first-line-indent: 0em)[
  _Schlüsselwörter:_ Stress, Kurzskala, Bewältigung, Coping
]

#pagebreak()

// Table of Contents
#align(center)[
  #text(size: 14pt, weight: "bold")[Inhaltsverzeichnis]
]
#v(1em)
#set par(leading: 0.65em)
#outline(
  title: none,
  indent: auto,
  depth: 3,
)
#set par(leading: 1.15em)

#pagebreak()

= Einleitung

Die Kurzskala zur Erfassung von Stressbelastung, Stresssymptomen und Bewältigungsstrategien (KSSB) wurde entwickelt, um möglichst kurz und effizient Stress in der Allgemeinbevölkerung zu erfassen.Laut einem Bericht der Techniker Krankenkasse ist der Anteil, derer Menschen in Deutschland, die sich in ihrem Alltag oder Berufsleben manchmal oder häufig gestresst fühlen, um knapp 10 Prozentpunkte zwischen 2013 und 2021 auf 66% gestiegen @noauthor_tk-stressreport_2025.

Zwar ermöglicht Stress persönliches Wachstum durch Anforderungen an unseren Alltag @gerrig_psychologie_2018, doch vor allem negativer Stress wird mit Gesundheitsbeeinträchtigungen in Verbindung gebracht@kiecolt-glaser_emotions_2002@natelson_stress_2004@pinel_biopsychologie_2017. Beispielsweise zeigte die Forschung, dass schon negative Alltagsprobleme mit erhöhten Entzündungsmarkern im Blut assoziiert sind, welche einen Risikofaktor für kardiovaskuläre Erkrankungen darstellen @jain_effects_2007. Insbesondere lang andauernde oder häufig wiederkehrende Belastungen, also chronischer Stress, wirken gesundheitsschädigend und verändern biologische Prozesse in unserem Körper @gerrig_psychologie_2018. Nach Wissen der Autoren dieser Arbeit existiert bisher keine Kurzskala, welche Stress inklusiver seiner Unterfacetten erfassen kann, sowie für Erhebungen in der Allgemeinbevölkerung geeignet ist.

Angelehnt an das Stress- und Coping-Inventar (2., überarbeitete und neunormierte Version; Satow, #cite(<satow_sci_2024>, form: "year")) soll die KSSB mit insgesamt 15 Items sowohl Stresssymptome (5 Items) als auch Stressbelastungen (5 Items) und Stressbewältigungsstrategien (5 Items) in circa 3 Minuten erfassen. Validiert wurde diese an 180 Personen mit überwiegend Studierenden und Erwerbstätigen. Als Validierungskriterien dienten Lebenszufriedenheit, Neurotizismus und Resilienz. Insgesamt weist die KSSB zufriedenstellende bis gute Kennwerte auf, wobei sich die Reliabilitäten nach Cronbachs Alpha zwischen .71 und .812 bewegen während die Retest-Reliabilitäten der Skalen von 0,57  bis 0.91 gehen. Auch die Teststruktur weist einen akzeptablen Fit mittels konfirmatorischer Faktorenanalyse auf. Die KSSB eignet sich damit nicht nur als eigenständiges Instrument, sondern auch ergänzend zu anderen Erhebungsmaßen.


= Theoretischer Hintergrund

== Stressdefinition

In der klassischen Stressforschung wird Stress primär als eine "unspezifische Reaktion des Organismus auf jede Art von Anforderung" verstanden @selye_syndrome_1936. Der Fokus liegt hier auf der physiologischen Ebene mit  zwei wichtigen Bestandteilen, den Stressoren (auslösendes Ereignis) und der Stressantwort des Körpers.

In der psychologischen Forschung hingegen wird Stress als ein dynamischer und subjektiver Prozess aufgefasst, der über die bloße Einwirkung externer Reize hinausgeht @lazarus_stress_1984. Die KSSB basiert hauptsächlich auf der Definition nach Lazarus & Folkman, welche Stress als eine "Beziehung zwischen Person und Umwelt, die von der Person als ihre eigenen Ressourcen auslastend oder überschreitend und als ihr Wohlbefinden gefährdend bewertet wird" spezifiziert @lazarus_stress_1984[S.~19]. Folglich resultiert Stress nicht allein aus den objektiven Merkmalen einer Situation, sondern ist maßgeblich das Ergebnis individueller Bewertungs- und Bewältigungsprozesse.

== Antezedenzien

Stress gehen sowohl personenspezifische als auch umweltspezifische Faktoren voraus. Zu diesen sogenannten Antezedenzien gehören Zielhierarchien, Verpflichtungen, generalisierte Erwartungen und Überzeugungen (Überzeugungssystem) auf der personenspezifischen Ebene @bolger_framework_1995. Diese interagieren mit umweltspezifischen Stressoren, wie beispielsweise chronische Alltagsbelastungen, Arbeitsbelastungen, Alltagsprobleme (_Daily Hassles_), soziale Konflikte oder Lebensereignisse.

Die Intensität der Stressreaktion wird maßgeblich durch Persönlichkeitsmerkmale moderiert. So weisen Personen mit hohen Werten in Neurotizismus eine gesteigerte Stressanfälligkeit und stärkere emotionale Reaktionen auf Belastungen auf, sie erleben häufiger interpersonelle Konflikte und wenden weniger effektive Bewältigungsstrategien an. Dadurch kommt es zu einer höheren psychischen Belastung @gunthert_role_1999@bolger_framework_1995.  Demgegenüber fungieren Ressourcen wie Lebenszufriedenheit @fredrickson_role_2001, Selbstwirksamkeit, Resilienz und soziale Unterstützung (Stress-Buffering-Effect) als Schutzfaktoren , welche die negativen Auswirkungen von Stressoren abmildern können @cohen_stress_1985.

Die Entstehung von Stress liegt der Wahrnehmung der Person zugrunde. Nimmt diese eine Diskrepanz zwischen situativen Anforderungen und den verfügbaren Bewältigungsressourcen wahr, ist Stress die Folge @lazarus_stress_1984. Diese Definition verdeutlicht den subjektiven Charakter von Stress und seine Abhängigkeit von individuellen Bewertungsprozessen. Entscheidende Mediatoren sind hier die kognitive Bewertung, sowie Stressbewältigungsstrategien, auch genannt Coping, auf welche später näher eingegangen wird.

Allgemein werden zwei Formen von Stress unterschieden: Distress, welcher mit Belastung, Beanspruchung, Druck und negativer Beeinflussung verknüpft ist, sowie Eustress, der mit positiver Beeinflussung verknüpft ist. Auch hier spielt die kognitive Bewertung eine zentrale Rolle @serban_stress_1976.

== Stressmodelle

Verschiedene Stressmodelle sind heutzutage etabliert. Das ursprüngliche Stressmodell nach Hans Selye (1936) legt  den Fokus auf körperliche Reaktionen in Form von Anpassungsreaktionen, Entspannungs- und Erholungsphasen. Erwähnenswert ist noch das biopsychosoziale Modell @adler_engels_2009 welches biologische, psychologische und soziale Faktoren, sowie deren Interaktionen integriert.

Nach dem transaktionalen Modell von Lazarus und Folkman (1984) wird die Entstehung von Stress maßgeblich durch kognitive Bewertungsprozesse gesteuert, die in zwei wesentlichen Stufen verlaufen. In der primären Bewertung (Primary Appraisal) schätzt das Individuum ein, ob eine Situation für das eigene Wohlbefinden irrelevant oder positiv-angenehm ist oder ob sie eine potenzielle Belastung darstellt. Letztere kann dabei als bereits eingetretener Schaden oder Verlust, als drohende Bedrohung oder als positive Herausforderung bewertet werden. In der darauffolgenden sekundären Bewertung (Secondary Appraisal) analysiert die Person ihre verfügbaren Bewältigungsressourcen und prüft, ob die Anforderungen der Umwelt mit den eigenen Fähigkeiten bewältigt werden können. Ein Stresszustand manifestiert sich erst dann, wenn eine Diskrepanz zwischen den Anforderungen und den Ressourcen wahrgenommen wird @faltermaier_gesundheitspsychologie_2005.

== Coping

Der sich anschließende Prozess der Stressbewältigung - im folgenden Coping - umfasst sämtliche kognitiven und behavioralen Bemühungen, um die als belastend wahrgenommenen Anforderungen zu meistern oder zu reduzieren @lazarus_stress_1984. In der Forschung wird dabei häufig zwischen problemorientiertem Coping, welches direkt auf die Veränderung der Stressquelle abzielt, und emotionsorientiertem Coping, das die Regulation der emotionalen Belastung fokussiert, unterschieden. Ein wesentlicher Prädiktor für eine erfolgreiche psychische Anpassung ist die Coping-Flexibilität, also die Fähigkeit, Bewältigungsstrategien variabel und passgenau an unterschiedliche situative Anforderungen anzupassen @cheng_coping_2014. Während adaptive Strategien wie das „Positive Denken“ eine funktionale kognitive Umdeutung ermöglichen, bietet „aktive Stressbewältigung ein proaktives und handlungsorientiertes Vorgehen @satow_sci_2024. Im Gegensatz dazu führen maladaptive Muster und vermeidungsorientierte Strategien wie Substanzkonsum (z.B. Alkohol, Zigaretten, Cannabis, Medikamentenmissbrauch) zu einer Aufrechterhaltung und Verstärkung der psychischen Belastung @nolen-hoeksema_rethinking_2008. Dies führt kurzfristig zur Entspannung, verhindert langfristig jedoch die Auseinandersetzung mit der Problematik, sowie die effektive Problemlösung und verstärkt so die gesundheitliche Belastung.

Effektive Bewältigungsmechanismen können jedoch die schädlichen Auswirkungen von Stressoren signifikant abmildern. Ob ein Stressor tatsächlich zu negativen Outcomes führt, wird zudem durch verschiedene Moderatoren beeinflusst. Der Stress-Buffering-Effekt besagt, dass soziale Unterstützung den negativen Zusammenhang zwischen Stress und Outcomes abschwächt @cohen_stress_1985. So zeigen Personen mit einem stabilen sozialen Rückhalt unter Belastung geringere endokrine und psychische Stressreaktionen. Dennoch ist anzumerken, dass selbst hochgradig adaptive Strategien bei intensiven oder chronischen Belastungen an ihre Grenzen stoßen können, da sich physiologische und emotionale Schäden kumulieren können @chrousos_stress_2009@folkman_coping_2004.

Neben sozialen Faktoren dienen psychologische Ressourcen wie persönlicher Optimismus @majeed_dispositional_2021 und eine hohe Selbstwirksamkeitserwartung @schonfeld_effects_2016  als Puffer. Diese Ressourcen bestimmen nach der Theory of Conservation of Resources (COR; Hobfoll, #cite(<hobfoll_conservation_1989>, form: "year")) nicht nur die Widerstandsfähigkeit gegenüber Verlusten, sondern beeinflussen auch maßgeblich, ob eine Person im Vorfeld adaptive Coping-Strategien wählt oder in maladaptive Muster verfällt.

@nomological_network_theory veranschaulicht die theoretisch postulierten Zusammenhänge zwischen Stress, Coping, Resilienz, Lebenszufriedenheit und Neurotizismus.

== Relevanz von Stress

Die Auswirkungen von Stress lassen sich in kurz- und langfristige Outcomes unterteilen. Kurzfristig manifestiert sich Stress primär physiologisch durch die Aktivierung der Hypothalamus-Hypophysen-Nebennierenrinden-Achse (HPA-Achse). Dies führt  zu einem erhöhten Cortisolspiegel. Diese hormonelle Reaktion dient ursprünglich der Bereitstellung von Energie, beeinträchtigt jedoch bei Fehlregulation das emotionale Befinden und die kognitive Leistungsfähigkeit, insbesondere das Arbeitsgedächtnis und die Exekutivfunktionen @sapolsky_why_2004.

Bleibt die Belastung konstant und fehlt ein effektives Coping, entwickelt sich chronischer Stress. Die langfristigen Folgen sind gravierend: Sie reichen von physischen Erkrankungen wie kardiovaskulären Erkrankungen und einer Schwächung des Immunsystems @segerstrom_psychological_2004, Diabetes @eckert_stress-_2022, bis hin zur Entwicklung psychischer Erkrankungen wie klinischer Depressionen und dem Burnout-Syndrom @maslach_job_2001.
Diese Folgen verdeutlichen die Relevanz einer Kurzskala zu einer schnellen Erfassung von Stress- und Copingstrategien im klinischen und präventiven Bereich.

== Skalen

Aufgrund der Komplexität des Konstrukts wurden in der psychologischen Diagnostik zahlreiche Instrumente zur Erfassung von Stress und Coping entwickelt. Der Perceived Stress Questionnaire (PSQ) ermöglicht beispielsweise eine detaillierte Erfassung der subjektiven Belastung in Dimensionen wie Überlastung, Sorgen, Anspannung und Freudlosigkeit @fliege_psq_2023. Die Perceived Stress Scale (PSS) fokussiert hingegen primär darauf, wie unvorhersehbar und unkontrollierbar Personen ihr Leben im letzten Monat wahrgenommen haben @cohen_global_1983. Für spezifische Zielgruppen oder Fragestellungen bieten Instrumente wie der Everyday Stressors Index (ESI), der alltägliche Belastungen und Rollenkonflikte misst @jakel_esi_2009, oder die Depressions-Angst-Stress-Skalen (DASS), die als klinisches Screeningverfahren dienen @nilges_dass_2021, wertvolle Ergänzungen.

Coping lässt sich mit der Coping-Stil Skala erfassen. Diese erfasst einen umweltbezogenen Coping-Stil mit Hilfe von Situationsvignetten und darauf bezogenen Antwortmöglichkeiten @martens_coping-stil_1999.
Stress sollte jedoch nicht unabhängig von Coping betrachtet werden, da die beiden Konstrukte sich wechselseitig beeinflussen. Aus diesem Grund sollten beiden Konstrukte auch gemeinsam erfasst werden.

Das Stress-Coping-Inventar (SCI, 2. überarbeitete und neunormierte Version; Satow, #cite(<satow_sci_2024>, form: "year")) bietet ein empirisch validiertes Instrument, um die komplexen Wechselwirkungen zwischen Stressbelastung, Stressbewältigung und Stressymptomatik präzise abzubilden für den Einsatz in der Allgemeinbevölkerung. Dabei werden unter Stressbelastung verschiedene Aspekte in Bezug auf Leben, Arbeiten und Wohnen abgefragt, während Stresssymptome typische körperliche und kognitive Anzeichen von Stress (z.B. Bauchschmerzen oder Konzentrationsschwierigkeiten) erfasst.
Zusätzlich dazu werden fünf Coping-Strategien berücksichtigt: Positives Denken, Aktive Stressbewältigung, Soziale Unterstützung, Halt im Glauben und erhöhter Alkohol- und Zigarettenkonsum. Dabei spielt vor allem die kognitive Bewertung, sowie die wahrgenommenen Ressourcen eine zentrale Rolle für das Stressempfinden des Individuums (siehe auch transaktionales Modell @lazarus_stress_1984).
 Es ermöglicht somit einen Überblick über die subjektiv wahrgenommene Stressbelastung, die körperlichen Stresssymptome, sowie die verwendeten Coping-Strategien, welche in einem engen Zusammenhang mit der individuellen Stressbelastung stehen.

Trotz seiner diagnostischen Güte ist das SCI @satow_sci_2024 mit einem Umfang von 45 Items für viele Forschungskontexte, insbesondere bei zeitkritischen Online-Befragungen, zu ökonomisch belastend. Zudem deckt die Erfassung des Substanzkonsums lediglich Nikotin und Alkohol ab, ohne weitere potenziell relevante Substanzen einzubeziehen. Um diese methodische Lücke zu schließen und eine zeiteffiziente Erhebung zu ermöglichen, wurde die Kurzskala zur Erfassung von Stressbelastung, Stresssymptomen und Bewältigungsstrategien (KSSB) entwickelt. Diese orientiert sich eng am theoretischen Kern des SCI, wurde jedoch auf 15 Items adaptiert, um die zentralen Dimensionen des transaktionalen Modells benutzerfreundlich und innerhalb einer durchschnittlichen Bearbeitungszeit von circa 3 Minuten valide abzubilden.

= Instrument

== Item- und Skalenkonstruktion

Die Skalen Stressbewältigung und Stressbelastung wurden auf Basis des Stress- und Coping-Inventars (SCI; Satow, 2024) in einem mehrstufigen inhaltsanalytischen Verfahren überarbeitet und zu Kurzskalen mit jeweils fünf Items reduziert. Zwei unabhängige Rater analysierten die Originalitems hinsichtlich inhaltlicher Subdimensionen, ordneten sie neu und formulierten sie mit dem Ziel einer möglichst starken Reduktion um. Die resultierenden Versionen wurden von zwei weiteren Personen auf inhaltliche Repräsentativität geprüft und zu finalen Skalen zusammengeführt.

Für die Coping-Skalen war jeweils ein Item pro Skala vorgesehen. Da die Originalitems der Skalen soziale Unterstützung sowie Alkohol- und Zigarettenkonsum die intendierte Inhaltsbreite nicht ausreichend abbildeten, wurden hierfür zusätzliche Items nach demselben Verfahren entwickelt und gemeinsam mit den Originalitems @satow_sci_2024 getestet .

Alle Skalen wurden auf eine einheitliche 6-stufige Likert-Skala standardisiert. Nach einem Pretest zur Verständlichkeit wurde eine Online-Erhebung über SoSci Survey @leiner_sosci_2024 durchgeführt. Der Fragebogen enthielt alle neuen Items, die vollständigen SCI-Originalitems, demografische Angaben (Alter, Geschlecht, Bildung), die Kurzskala zur Erfassung der Allgemeinen Lebenszufriedenheit (L-1; Beierlein et al., #cite(<beierlein_kurzskala_2015>, form: "year")), die deutsche Version der Brief Resilience Scale @chmitorz_population-based_2018 sowie die Persönlichkeitsdimension Neurotizismus aus dem BFI-10 @rammstedt_bfi-10_2014.

Die Rekrutierung erfolgte über persönliche Kontakte, universitäre Verteiler und SurveyCircle @surveycircle_surveycircle_2016. Optional konnten Teilnehmende einen Retest absolvieren, der automatisiert zwei Wochen nach der ersten Teilnahme versendet wurde.

Die Datenanalyse erfolgte mit Rstudio @rstudio_team_rstudio_2019 und sind vollständig reproduzierbar (siehe Appendix C). Verglichen wurden die psychometrischen Eigenschaften der neuen Items mit denen der SCI-Originalskalen. Die finale Itemauswahl für die KSSB basierte auf statistischer Performanz und inhaltlicher Breite.

Zusammengenommen enthält die Kurzskala zur Erfassung von Stresssymptomen, Stressbelastung und Stressbewältigung (KSSB) sieben psychometrische Unterskalen mit insgesamt 15 Items. Die Skalen Stressbelastung und Stresssymptome umfassen je fünf Items, während jede der fünf Stressbewältigungsskalen von einem Item abgedeckt wird. Nachfolgend wird kurz auf die einzelnen Skalen eingegangen. Der vollständige Test findet sich im Anhang (Appendix A).

Die KSSB kann zur Erfassung von Stress allgemein, seiner Unterdimensionen und verschiedenen Bewältigungsstrategien in der Allgemeinbevölkerung ab 18 Jahren eingesetzt werden. Er lässt sich sowohl digital als auch als Paper-Pencil-Test durchführen und hat kein Zeitlimit.

Bisherige Erhebungszeiten zeigen eine Bearbeitungszeit von circa 3 Minuten, wodurch die KSSB auch ergänzend zu anderen Maßen eingesetzt werden kann. Ob die Skalen auch unabhängig voneinander eingesetzt werden können, wurde bisher nicht geprüft und wird deshalb nicht empfohlen. Ebenfalls sollte die KSSB nicht für die klinische oder Eignungsdiagnostik eingesetzt werden, da hierfür keine Validierung vorliegt.

== Allgemeine Instruktion

Zu Beginn wurde den Proband*innen folgende Instruktion präsentiert: "Im Folgenden werden Ihnen Aussagen zu Situationen oder Symptomen präsentiert. Es gibt kein Richtig oder Falsch. Bitte antworten Sie wahrheitsgemäß und ehrlich, wie sehr die Aussage auf Sie zutrifft. Denken Sie dabei an die letzten drei Monate."

=== Stresssymptome

Die Skala Stresssymptome erfasst mit 5 Items inhaltlich die Dimensionen körperliche Beschwerden (SYMP_PHYS), Schlaf (SYMP_SLEP), Kognition (SYMP_COGN), Stimmung (SYMP_MOOD) und soziale Symptome (SYMP_SOCI), welche typische mit Stress assoziierte Symptome darstellen. Die Antworten werden über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert eine hohe Ausprägung repräsentiert.

_Instruktion & Items:_ "Bitte kreuzen Sie an, welche Symptome Sie in den letzten drei Monaten bei sich beobachtet haben."

+ SYMP_PHYS: Ich leide unter körperlichen Beschwerden (z.B. Kopf-/Bauchschmerzen, Gewichtsveränderung).
+ SYMP_SLEP: Ich schlafe schlecht oder habe belastende/schlechte Träume.
+ SYMP_COGN: Ich kann mich schlecht konzentrieren.
+ SYMP_MOOD: Ich bin oft traurig oder grüble (häufig) über mein Leben nach.
+ SYMP_SOCI: Ich ziehe mich zurück oder habe auf nichts mehr Lust.

_Antwortskala:_

#table(
  columns: 6,
  align: center,
  [1], [2], [3], [4], [5], [6],
  [trifft überhaupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu]
)

=== Stressbelastung

Die Skala Stressbelastung erfasst mit 5 Items inhaltlich die Aspekte Zukunftssorgen (STRS_FUTU), Finanzen (STRS_FINA), Beziehungen (STRS_RELA), Leistungsdruck (STRS_PERF) und Gesundheit (STRS_HEAL), welche die subjektive Belastung in verschiedenen Lebensbereichen abdecken. Die Antworten werden ebenfalls über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert einer hohen Ausprägung entspricht.

_Instruktion & Items:_ "Bitte kreuzen Sie an, wie sehr Sie sich durch die folgenden Situationen in den letzten drei Monaten belastet gefühlt haben."

+ STRS_FUTU: Ich mache mir Sorgen um meine Zukunft.
+ STRS_FINA: Ich mache mir Sorgen um Geldprobleme (z.B. Schulden).
+ STRS_RELA: Ich fühle mich belastet durch Probleme mit Familie, Freunden oder Partner/innen.
+ STRS_PERF: Ich fühle mich unter Druck gesetzt durch Arbeit, Studium, Ausbildung oder Schule.
+ STRS_HEAL: Ich mache mir Sorgen wegen meinem Körper oder meiner Gesundheit.

_Antwortskala:_

#table(
  columns: 6,
  align: center,
  [1], [2], [3], [4], [5], [6],
  [trifft überhaupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu]
)

=== Stressbewältigung

Stressbewältigung beinhaltet 5 Skalen mit je einem Item zu einer Bewältigungsstrategie (auch Copingstrategie genannt). Die jeweilige Skala ist an dieser Stelle der Übersichtlichkeit halber _kursiv_ vor dem Item dokumentiert. Die Antworten werden je über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert eine hohe Ausprägung repräsentiert.

_Instruktion & Items:_ "Bitte kreuzen Sie an, wie Sie mit Stress umgehen."

+ COPE_RELI (_Religiöses Coping_): Bei Stress und Druck erinnere ich mich daran, dass es höhere Werte im Leben gibt.
+ COPE_SOCI (_Soziales Coping_): Egal wie schlimm es wird, ich habe Menschen, die für mich da sind.
+ COPE_DRUG (_Substanz-Coping_): Wenn mir alles zu viel wird, greife ich auch mal zu Alkohol, Zigaretten oder anderen Substanzen (z.B. Cannabis).
+ COPE_REAP (_Positive Neubewertung_): Ich sehe Stress und Druck als positive Herausforderung an.
+ COPE_ACTI (_Aktives Coping_): Ich versuche Stress schon im Vorfeld zu vermeiden.

_Antwortskala:_

#table(
  columns: 6,
  align: center,
  [1], [2], [3], [4], [5], [6],
  [trifft überhaupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu]
)

== Auswertung

Für die Skalen Stressbewältigung und Stresssymptome werden die Antworten in Rohpunktwerte entsprechend der Antwort von 1 bis 6 umgewandelt und je Skala gemittelt. Der entsprechende Normwert kann anschließend anhand des Mittelwerts in der Normtabelle abgelesen werden. Die Stressbewältigungsskalen werden einzeln betrachtet und geben Aufschluss über die bevorzugte Art mit Stress umzugehen.

== Stichprobe

Von den ursprünglich 211 Teilnehmenden wurden 31 Personen ausgeschlossen, die kein plausibles Alter angegaben oder den integrierten Aufmerksamkeitstest nicht bestanden haben, sodass eine finale Stichprobe von 180 Personen resultierte. Zusätzlich nahmen 21 Personen an einer Retest-Erhebung teil, die 2 Wochen nach der ersten Erhebung durchgeführt wurde und zur Bestimmung der Retest-Reliabilität diente.

=== Demographische Merkmale

Das durchschnittliche Alter der Stichprobe betrug _M_ = 27.62 Jahre (_SD_ = 9.90 Jahre). Die Altersverteilung ist in @age_distribution dargestellt. Die Stichprobe war überwiegend weiblich (77.8%), in Beschäftigung als Studierende (64.4%) und wies ein hohes Bildungsniveau auf (52.2% mit Bachelor, Master oder Staatsexamen).

=== Ausreißeranalyse

Zur Qualitätssicherung der Daten wurde eine umfassende Ausreißeranalyse durchgeführt. Es wurden keine konsistenten Ausreißer aus den Hauptanalysen ausgeschlossen, da keine Hinweise auf Messfehler vorlagen. Details zur Ausreißeranalyse finden sich in den verfügbaren R-Skripten (Appendix C).

== Item- und Skalenkennwerte

Im Folgenden werden die psychometrischen Kennwerte der KSSB dargestellt. Für jede Skala werden zunächst deskriptive Statistiken auf Skalenebene berichtet, gefolgt von einer detaillierten Darstellung der Itemkennwerte. Dabei liegt der Fokus auf Mittelwerten, Standardabweichungen und part-whole-korrigierten Trennschärfen der einzelnen Items, die Aufschluss über die Itemqualität geben. Zusätzlich werden Reliabilitätskennwerte sowie Informationen zur Normierungsstrategie der jeweiligen Skalen berichtet.

=== Stresssymptome

Die Skala Stresssymptome umfasst 5 Items und zeigte in der Validierungsstichprobe (n = 180) einen Skalenmittelwert von _M_ = 3.45 (_SD_ = 1.12) bei einer Spannweite von 1.00 bis 6.00. Die interne Konsistenz der Skala erwies sich mit Cronbachs α = .812 (95% CI [.765, .853]) als gut. Die Itemkennwerte sind in @tab_stresssymptome dargestellt.

Alle Items wiesen zufriedenstellende bis gute Trennschärfen auf (_r_#sub[it] = .507 bis .701), wobei Item SYMP_SLEP (Schlechter Schlaf/Träume) die höchste Trennschärfe zeigte. Die Retest-Reliabilitäten der Items waren überwiegend gut bis exzellent (_r_#sub[tt] = .582 bis .862), was auf eine hohe Reliabilität und zeitliche Stabilität der Messung hinweist. Die Skala wird auf Basis einer gemeinsamen Norm für die Gesamtstichprobe ausgewertet, da keine signifikanten Gruppenunterschiede identifiziert wurden.

=== Stressbelastung

Die Skala Stressbelastung besteht aus 5 Items und wies in der Validierungsstichprobe (n = 180) einen Skalenmittelwert von _M_ = 3.90 (_SD_ = 0.95) mit einer Spannweite von 1.20 bis 6.00 auf. Die interne Konsistenz betrug Cronbachs α = .710 (95% CI [.637, .772]) und ist damit als akzeptabel zu bewerten. Die Itemkennwerte sind in @tab_stressbelastung dargestellt.

Alle Items erreichten akzeptable Trennschärfen (_r_#sub[it] = .376 bis .539), wobei Item STRS_FINA (Geldprobleme) die höchste Trennschärfe aufwies. Die Retest-Reliabilitäten lagen durchweg im akzeptablen bis guten Bereich (_r_#sub[tt] = .659 bis .774) und belegen die Reliabilität und zeitliche Stabilität der Messung. Für diese Skala wird eine altersspezifische Normierung empfohlen, da signifikante Altersunterschiede identifiziert wurden. Es werden separate Normtabellen für drei Altersgruppen bereitgestellt (jung: $<$30 Jahre, mittel: 30–45 Jahre, alt: $>$45 Jahre).

=== Stressbewältigung

Die Stressbewältigung wird über fünf Einzelitems erfasst, die jeweils eine spezifische Bewältigungsstrategie abbilden. Da jedes Item eine eigene Dimension misst, kann weder die interne Konsistenz noch die Trennschärfe berechnet werden. Die Itemwerte werden in @tab_coping dargestellt.

 Die Retest-Reliabilitäten der Einzelitems variierten zwischen _r_#sub[tt] = .567 (COPE_REAP) und _r_#sub[tt] = .910 (COPE_DRUG), wobei die meisten Items eine gute bis exzellente Reliabilität aufwiesen. #underline[Die Normierung erfolgt für vier Items (COPE_DRUG, COPE_RELI, COPE_SOCI und COPE_REAP) auf Basis gemeinsamer Normen. Für Item COPE_ACTI (Aktive Bewältigung) werden aufgrund signifikanter Geschlechtsunterschiede geschlechtsspezifische Normen bereitgestellt.]

== Validität

Die Validität der KSSB wurde durch konvergente Validitätsanalysen überprüft, bei denen Korrelationen mit theoretisch verwandten Konstrukten berechnet wurden. Als Validierungskriterien dienten Lebenszufriedenheit @beierlein_kurzskala_2015, Neurotizismus @rammstedt_bfi-10_2014 und Resilienz @chmitorz_population-based_2018. Zusätzlich wurde die faktorielle Struktur der KSSB mittels einer konfirmatorischer Faktorenanalyse (CFA) überprüft. Außerdem wurde überprüft, ob es erwartungskonforme Mittelwertsunterschiede zwischen verschiedenen Gruppen gab.

=== Konvergente Validität

Die Skala Stressbelastung zeigte substanzielle Korrelationen mit allen drei Validierungskriterien. Mit Lebenszufriedenheit korrelierte die Skala negativ (_r_ = –.44, _p_ < .001), was die Annahme bestätigt, dass höhere Stressbelastung mit geringerer Lebenszufriedenheit einhergeht. Erwartungsgemäß zeigte sich eine positive Korrelation mit Neurotizismus (_r_ = .51, _p_ < .001), da neurotische Personen stressauslösende Situationen häufiger als belastend erleben. Die negative Korrelation mit Resilienz (_r_ = –.43, _p_ < .001) unterstreicht, dass resiliente Personen Stressoren besser bewältigen und als weniger belastend wahrnehmen.

Die Skala Stresssymptome korrelierte stark negativ mit Lebenszufriedenheit (_r_ = –.61, _p_ < .001), ebenso wie mit Neurotizismus (_r_ = .60, _p_ < .001) und mit Resilienz (_r_ = –.54, _p_ < .001).

Die fünf Bewältigungsstrategien zeigten differenzielle Validitätsmuster, die mit theoretischen Erwartungen übereinstimmen. Adaptive Strategien wie positive Neubewertung, und soziale Unterstützung korrelierten positiv mit Lebenszufriedenheit (_r_ = .39 bzw. .36, beide _p_ < .001) und negativ mit Neurotizismus und Stresssymptomen. Maladaptive Strategien wie Substanzkonsum zeigten hingegen positive Korrelationen mit Stressbelastung (_r_ = .18, _p_ = .017). Religiöses Coping korrelierte positiv mit Lebenszufriedenheit (_r_ = .21, _p_ = .006) und negativ mit Neurotizismus (_r_ = –.23, _p_ = .002). Aktive Bewältigung zeigte schwächere, aber konsistente Zusammenhänge mit den Validierungskriterien.

Diese Befunde decken sich mit theoretischen Erwartungen (dargestellt in @nomological_network_theory) sowie mit den Ergebnissen der Validierung des SCI #cite(<satow_sci_2024>). Die empirisch beobachteten Korrelationen sind in @nomological_network_empirical dargestellt.

=== Faktorielle Validität

Die faktorielle Validität der KSSB wurde mittels konfirmatorischer Faktorenanalyse (CFA) mit einer 2-Faktoren-Struktur (Stressbelastung und Stresssymptome, je 5 Items) überprüft. Die 5 Stressbewältigungsskalen konnten nicht per CFA analysiert werden, da sie aus jeweils nur einem Item bestehen. Die Modellfit-Indizes zeigten einen verbesserungswürdigen Fit (χ² = 100.74, _df_ = 34, _p_ < .001; CFI = .886; TLI = .849; RMSEA = .104 [.081, .128]; SRMR = .066). Alle Faktorladungen waren substanziell (.517–.845) und signifikant (_p_ < .001; siehe @cfa_heatmap). Die Korrelation zwischen den Faktoren betrug _r_ = .820 (_p_ < .001), was auf ausreichende Diskriminanz hinweist.

Die Composite Reliability lag bei CR = .715 (Stressbelastung) und CR = .817 (Stresssymptome). Die Average Variance Extracted (AVE) betrug .336 bzw. .479, was unter dem idealen Schwellenwert von .50 liegt.

Die Composite Reliability (CR) ist etwas niedriger als im SCI @satow_sci_2024, wo CR = .82 (Stressbelastung)  und CR = .86 (Stresssymptome) ist. Dennoch ist diese CR gut bis sehr gut und damit ausreichend für eine Kurzskala. Der schlechtere Modellfit im Vergleich zum SCI ist vermultich der kleinen Stichprobe geschuldet.

=== Subgruppenvalidität

Die Validität der Skalen wurde über verschiedene demographische Subgruppen (Geschlecht, Alter, Bildungsniveau, Beschäftigungsstatus) hinweg überprüft. Fisher-Z-Tests ergaben keine signifikanten Unterschiede in den konvergenten Validitätskoeffizienten zwischen den Gruppen, was auf eine robuste Validität über verschiedene Populationen hinweist.

=== Vergleich mit etabliertem Maß

Wie bereits erwähnt haben wir bei unserer ersten Erhebung den SCI @satow_sci_2024 vollständig miterhoben. Validitätsanalysen mit den SCI_Skalen und den KSSB-Skalen ergaben, dass die KSSB-Skalen alle stark mit ihren SCI-Entsprechungen korrelierten und dass sie die Validitätskriterien trotz ihrer Kürze nicht signifikant schlechter vorhersagen konnten. Dies testeten wir durch Partialkorrelationstests, wo wir die Vorhersagekraft der SCI-Skalen bei Kontrolle der KSSB-Skalen überprüften. Keiner dieser Tests erreichte Signifikanz (siehe Appendix C). Auch im Vergleich zu veröffentlichten Werten zum SCI schneidet die KSSB akzeptabel ab: Cronbachs Alpha für die SCI-Skalen bewegt sich zwischen 0,75 und 0,87; die KSSB-Skalen haben ein Alpha von 0,71 und 0,81, was in Angesicht der Kürze als gut zu bewerten ist. Die faktorielle Validität ist zwar eingeschränkt aber durch die hohen Korrelationen mit dem Original und die gute Vorhersagekraft für relevante Kriterien ist die KSSB als gut verwendbare Kurzform des SCI als validiert anzusehen.

== Normierung

Die Normierung der KSSB erfolgte differenziert nach Bedarf der einzelnen Skalen, basierend auf systematischen Analysen von Gruppenunterschieden. Für die Skala Stresssymptome wird eine gemeinsame Norm für die Gesamtstichprobe (n = 180, _M_ = 3.45, _SD_ = 1.12) bereitgestellt, da keine signifikanten Unterschiede zwischen demographischen Subgruppen identifiziert wurden.

Für die Skala Stressbelastung werden hingegen altersspezifische Normen empfohlen, da sich substanzielle Altersunterschiede zeigten: Jung (\<30 Jahre: n = 146, _M_ = 4.02, _SD_ = 0.92), Mittel (30-45 Jahre: n = 21, _M_ = 3.47, _SD_ = 0.81) und Alt (>45 Jahre: n = 13, _M_ = 3.34, _SD_ = 1.05).

Die Bewältigungsitems werden überwiegend mit gemeinsamen Normen ausgewertet (Drogen: _M_ = 1.91, _SD_ = 1.36; Religiös: _M_ = 3.44, _SD_ = 1.22; Sozial: _M_ = 4.73, _SD_ = 1.19; Positiv: _M_ = 3.07, _SD_ = 1.36), während für aktive Bewältigung geschlechtsspezifische Normen bereitgestellt werden (Männlich: n = 36, _M_ = 3.75, _SD_ = 1.11; Weiblich: n = 140, _M_ = 3.29, _SD_ = 1.11). Die Normtabellen im Anhang B ermöglichen die Umrechnung von Rohwerten in Z-Werte (Normalverteilung mit _M_ = 0, _SD_ = 1) und T-Werte (_M_ = 50, _SD_ = 10) zur standardisierten Interpretation der Testergebnisse.

#pagebreak()

= Fazit

Das vorliegende Manual dokumentiert die Entwicklung, psychometrische Validierung und Durchführung der Kurzskala zur Erfassung von Stressbelastung, Stresssymptomen und Bewältigungsstrategien (KSSB). In Anlehnung an das Stress- und Coping-Inventar @satow_sci_2024 wurde ein ökonomisches Erhebungsinstrument mit 15 Items konzipiert, das sieben Unterskalen umfasst: Stresssymptome, Stressbelastung sowie fünf Bewältigungsstrategien.

Die Validierung an einer überwiegend studentischen Stichprobe ergab zufriedenstellende bis gute psychometrische Eigenschaften. Die internen Konsistenzen der Skalen Stresssymptome (α = .81) und Stressbelastung (α = .71) liegen im akzeptablen bis guten Bereich. Die Retest-Reliabilitäten (Median r#sub[tt] = .77) belegen eine angemessene zeitliche Stabilität. Die konvergente Validität wurde durch erwartungskonforme Zusammenhänge mit Lebenszufriedenheit @beierlein_kurzskala_2015, Neurotizismus @rammstedt_bfi-10_2014 und Resilienz @chmitorz_population-based_2018 bestätigt. Die konfirmatorische Faktorenanalyse zeigte einen verbesserungswürdigen, aber akzeptablen Modellfit mit substanziellen Faktorladungen.

Mit einer durchschnittlichen Bearbeitungszeit von etwa 3 Minuten bietet die KSSB eine praktikable Alternative zu umfangreicheren Stressinventaren und eignet sich insbesondere für zeitökonomische Erhebungen in Forschung und Praxis. Vor allen Dingen ist die multidimensionale Erfassung von Stress dabei eine große Stärke der KSSB, um das übergeordnete Konstrukt Stress in mehreren Unterfacetten zu erfassen. Zukünftige Studien sollten die Validierung an größeren und heterogeneren Stichproben fortführen, sowie in klinischen Stichproben,  um die Generalisierbarkeit der Befunde zu erweitern und die Normierung zu optimieren.


#pagebreak()

= Literaturverzeichnis

#bibliography("zotero.bib")

#pagebreak()

// APA7: Tables section before figures, each on separate page
= Tabellen

// Table 1
#figure(
  table(
    columns: (auto, 2fr, 1fr, 1fr, 1fr, 1fr),
    align: (center, left, center, center, center, center),
    [*Nr.*], [*Item*], [*_M_*], [*_SD_*], [*Trennschärfe*], [*_r_#sub[tt]*],
    [SYMP_PHYS], [Körperliche Beschwerden], [3.66], [1.39], [.507], [.818],
    [SYMP_SLEP], [Schlechter Schlaf/Träume], [3.78], [1.42], [.701], [.862],
    [SYMP_COGN], [Konzentrationsprobleme], [3.24], [1.52], [.667], [.775],
    [SYMP_MOOD], [Traurigkeit/Grübeln], [3.28], [1.58], [.602], [.842],
    [SYMP_SOCI], [Rückzug/Lustlosigkeit], [3.28], [1.52], [.537], [.582],
  ),
  caption: [Itemkennwerte der Skala Stresssymptome (n = 180)],
  kind: table,
) <tab_stresssymptome>

#par(first-line-indent: 0em)[
  _Anmerkung._ Trennschärfen sind part-whole-korrigiert. Retest-Reliabilitäten basieren auf n = 21.
]

#pagebreak()

// Table 2
#figure(
  table(
    columns: (auto, 2fr, 1fr, 1fr, 1fr, 1fr),
    align: (center, left, center, center, center, center),
    [*Nr.*], [*Item*], [*_M_*], [*_SD_*], [*Trennschärfe*], [*_r_#sub[tt]*],
    [STRS_FUTU], [Sorgen um Zukunft], [4.24], [1.28], [.506], [.667],
    [STRS_FINA], [Geldprobleme], [3.38], [1.49], [.539], [.774],
    [STRS_RELA], [Probleme mit Bezugspersonen], [3.49], [1.48], [.434], [.661],
    [STRS_PERF], [Leistungsdruck], [4.52], [1.36], [.488], [.659],
    [STRS_HEAL], [Sorgen um Gesundheit], [3.88], [1.33], [.376], [.695],
  ),
  caption: [Itemkennwerte der Skala Stressbelastung (n = 180)],
  kind: table,
) <tab_stressbelastung>

#par(first-line-indent: 0em)[
  _Anmerkung._ Trennschärfen sind part-whole-korrigiert. Retest-Reliabilitäten basieren auf n = 21.
]

#pagebreak()

// Table 3
#figure(
  table(
    columns: (auto, 2fr, 1fr, 1fr, 1fr),
    align: (center, left, center, center, center),
    [*Nr.*], [*Item*], [*_M_*], [*_SD_*], [*_r_#sub[tt]*],
    [COPE_DRUG], [Drogen/Substanzen], [1.91], [1.36], [.910],
    [COPE_RELI], [Religion/Spiritualität], [3.44], [1.22], [.832],
    [COPE_SOCI], [Soziale Unterstützung], [4.73], [1.19], [.868],
    [COPE_REAP], [Positive Neubewertung], [3.10], [1.26], [.567],
    [COPE_ACTI], [Aktive Bewältigung], [3.68], [1.15], [.797],
  ),
  caption: [Itemkennwerte der Stressbewältigungsitems (n = 180)],
  kind: table,
) <tab_coping>

#par(first-line-indent: 0em)[
  _Anmerkung._ Retest-Reliabilitäten basieren auf n = 21.
]

#pagebreak()

// APA7: Figures section after tables, each on separate page
= Abbildungen

// Figure 1
#figure(
  [
    #image("plots/nomological_network_theory.png", width: 100%)

    #v(1em)

    #par(first-line-indent: 0em)[
      _Anmerkung._ Diese Abbildung zeigt die theoretisch postulierten Zusammenhänge zwischen den Stressskalen (Stresssymptome, Stressbelastung), Copingstrategien und den Validitätskriterien (Lebenszufriedenheit, Neurotizismus, Resilienz). Rote Linien zeigen negative Korrelationen, blaue Linien positive Korrelationen.
    ]
  ],
  caption: [Theoretisch erwartetes Korrelationsmuster der Stress- und Copingskalen und der Validitätskriterien],
  kind: image,
) <nomological_network_theory>

#pagebreak()

// Figure 2
#figure(
  [
    #image("plots/01_altersverteilung.png", width: 80%)

    #v(1em)

    #par(first-line-indent: 0em)[
      _Anmerkung._ Das Histogramm zeigt die Altersverteilung der Validierungsstichprobe (n = 180) mit einem Durchschnittsalter von _M_ = 27.62 Jahren (_SD_ = 9.90).
    ]
  ],
  caption: [Altersverteilung der Stichprobe],
  kind: image,
) <age_distribution>

#pagebreak()

// Figure 3
#figure(
  [
    #image("plots/nomological_network_empirical.png", width: 100%)

    #v(1em)

    #par(first-line-indent: 0em)[
      _Anmerkung._ Diese Abbildung zeigt die empirisch beobachteten Korrelationen zwischen den KSSB-Skalen und den Validitätskriterien. Rote Linien zeigen negative Korrelationen, blaue Linien positive Korrelationen. Die Linienstärke repräsentiert die Korrelationsstärke.
    ]
  ],
  caption: [Empirisch beobachtetes Korrelationsmuster der Stress- und Copingskalen und der Validitätskriterien],
  kind: image,
) <nomological_network_empirical>

#pagebreak()

// Figure 4
#figure(
  [
    #image("plots/50_final_cfa_kurzskalen_heatmap.png", width: 80%)

    #v(1em)

    #par(first-line-indent: 0em)[
      _Anmerkung._ Die Heatmap zeigt die standardisierten Faktorladungen der konfirmatorischen Faktorenanalyse (n = 180). Dunklere Farben repräsentieren höhere Faktorladungen. SYMP = Stresssymptome; STRS = Stressbelastung.
    ]
  ],
  caption: [Standardisierte Faktorladungen der konfirmatorischen Faktorenanalyse (CFA) für die KSSB-Kurzskalen],
  kind: image,
) <cfa_heatmap>

#pagebreak()

= Anhang

== Appendix A: Kurzskala zur Erfassung von Stresssymptomen, Stressbelastung und Stressbewältigung (KSSB)

#table(
  columns: (auto, 1fr),
  stroke: none,
  [Versuchspersonennummer], [#box(width: 150pt, stroke: (bottom: 0.5pt), height: 1em)],
  [Testdatum], [#box(width: 150pt, stroke: (bottom: 0.5pt), height: 1em)],
  [Alter], [#box(width: 150pt, stroke: (bottom: 0.5pt), height: 1em)],
  [Geschlecht], [#box(width: 150pt, stroke: (bottom: 0.5pt), height: 1em)],
)

#v(1em)

*Allgemeine Anweisung:* Im Folgenden werden Ihnen Aussagen zu Situationen oder Symptomen präsentiert. Es gibt kein Richtig oder Falsch. Bitte antworten Sie wahrheitsgemäß und ehrlich, wie sie sehr die Aussage auf Sie zutrifft. Denken Sie dabei an die letzten drei Monate.

#v(1em)

=== Stresssymptome

_Bitte kreuzen Sie an, welche Symptome Sie in den letzten drei Monaten bei sich beobachtet haben._

#table(
  columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (left, center, center, center, center, center, center),
  [], [trifft über-\ haupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu],
  [Ich leide unter körperlichen Beschwerden (z.B. Kopf-/Bauchschmerzen, Gewichtsveränderung).], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich schlafe schlecht oder habe belastende/schlechte Träume.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich kann mich schlecht konzentrieren.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich bin oft traurig oder grüble (häufig) über mein Leben nach.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich ziehe mich zurück oder habe auf nichts mehr Lust.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
)

#v(1em)

=== Stressbelastung

_Bitte kreuzen Sie an, wie sehr Sie sich durch die folgenden Situationen in den letzten drei Monaten belastet gefühlt haben._

#table(
  columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (left, center, center, center, center, center, center),
  [], [trifft über-\ haupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu],
  [Ich mache mir Sorgen um meine Zukunft.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich mache mir Sorgen um Geldprobleme (z.B. Schulden).], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich fühle mich belastet durch Probleme mit Familie, Freunden oder Partner*Innen.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich fühle mich unter Druck gesetzt durch Arbeit, Studium, Ausbildung oder Schule.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich mache mir Sorgen wegen meinem Körper oder meiner Gesundheit.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
)

#v(1em)

=== Stressbewältigung

_Bitte kreuzen Sie an, wie Sie mit Stress umgehen._

#table(
  columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (left, center, center, center, center, center, center),
  [], [trifft über-\ haupt nicht zu], [trifft nicht zu], [trifft eher nicht zu], [trifft eher zu], [trifft zu], [trifft genau zu],
  [Bei Stress und Druck erinnere ich mich daran, dass es höhere Werte im Leben gibt.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Egal wie schlimm es wird, ich habe Menschen, die für mich da sind.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Wenn mir alles zu viel wird, greife ich auch mal zu Alkohol, Zigaretten oder anderen Substanzen (z.B. Cannabis).], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich sehe Stress und Druck als positive Herausforderung an.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
  [Ich versuche Stress schon im Vorfeld zu vermeiden.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
)

#pagebreak()

== Appendix B: Normtabellen

Die folgenden Normtabellen ermöglichen die Umrechnung von Rohwerten in standardisierte Z-Werte und T-Werte für die verschiedenen Skalen der KSSB.

=== Stresssymptome

Gemeinsame Norm für gesamte Stichprobe (n = 180, _M_ = 3.45, _SD_ = 1.12)

#let stresssymptome_data = csv("output/normtabellen/normtabelle_stresssymptome.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..stresssymptome_data.slice(9).flatten(),
)
]

=== Stressbelastung

Altersspezifische Normen werden empfohlen.

==== Jung (< 30 Jahre)

n = 146, _M_ = 4.02, _SD_ = 0.92

#let stressbelastung_jung_data = csv("output/normtabellen/normtabelle_stressbelastung_jung.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..stressbelastung_jung_data.slice(9).flatten(),
)
]

==== Mittel (30-45 Jahre)

n = 21, _M_ = 3.47, _SD_ = 0.81

#let stressbelastung_mittel_data = csv("output/normtabellen/normtabelle_stressbelastung_mittel.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..stressbelastung_mittel_data.slice(9).flatten(),
)
]

==== Alt (> 45 Jahre)

n = 13, _M_ = 3.34, _SD_ = 1.05

#let stressbelastung_alt_data = csv("output/normtabellen/normtabelle_stressbelastung_alt.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..stressbelastung_alt_data.slice(9).flatten(),
)
]

=== Coping: Drogen

Gemeinsame Norm (n = 180)

#let coping_drogen_data = csv("output/normtabellen/normtabelle_coping_drogen.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_drogen_data.slice(9).flatten(),
)
]

=== Coping: Religiös

Gemeinsame Norm (n = 180)

#let coping_religioes_data = csv("output/normtabellen/normtabelle_coping_religioes.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_religioes_data.slice(9).flatten(),
)
]

=== Coping: Sozial

Gemeinsame Norm (n = 180)

#let coping_sozial_data = csv("output/normtabellen/normtabelle_coping_sozial.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_sozial_data.slice(9).flatten(),
)
]

=== Coping: Positiv

Gemeinsame Norm (n = 180)

#let coping_positiv_data = csv("output/normtabellen/normtabelle_coping_positiv.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_positiv_data.slice(9).flatten(),
)
]

=== Coping: Aktiv

Geschlechtsspezifische Normen werden empfohlen.

==== Männlich

n = 36, _M_ = 3.75, _SD_ = 1.11

#let coping_aktiv_maennlich_data = csv("output/normtabellen/normtabelle_coping_aktiv_maennlich.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_aktiv_maennlich_data.slice(9).flatten(),
)
]

==== Weiblich

n = 140, _M_ = 3.29, _SD_ = 1.11

#let coping_aktiv_weiblich_data = csv("output/normtabellen/normtabelle_coping_aktiv_weiblich.csv")

#align(center)[
#set text(size: 9pt)
#table(
  columns: 3,
  align: (center, center, center),
  inset: 5pt,
  [*Rohwert*], [*Z-Wert*], [*T-Wert*],
  ..coping_aktiv_weiblich_data.slice(9).flatten(),
)
]

#pagebreak()

== Appendix C: Reproduzierbarkeit und Code

Alle in diesem Manual berichteten Analysen sind vollständig reproduzierbar. Der gesamte Code zur Datenaufbereitung, statistischen Auswertung und Erstellung der Abbildungen ist öffentlich verfügbar auf GitHub:

#align(center)[
  #link("https://github.com/linozen/dipra")[https://github.com/linozen/dipra]
]

Das Repository enthält alle notwendigen R-Skripte, Dokumentation und Anweisungen zur Reproduktion der Analysen. Die Rohdaten können aus Datenschutzgründen nicht öffentlich bereitgestellt werden, sind aber auf begründete Anfrage bei den Autor*Innen erhältlich. Anfragen können als GitHub Issue im Repository oder per E-Mail an dipra [at] sehn.tech gestellt werden.
