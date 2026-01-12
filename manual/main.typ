#set page(
  paper: "a4",
  margin: (
    top: 2.5cm,
    bottom: 2.5cm,
    left: 2.5cm,
    right: 2.5cm,
  ),
  numbering: "1",
  number-align: center,
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

// Heading styles
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(size: 16pt, weight: "bold")
  block(above: 2em, below: 1.5em, it)
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: "bold")
  block(above: 1.8em, below: 1.2em, it)
}

#show heading.where(level: 3): it => {
  set text(size: 12pt, weight: "bold")
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

// Figure styling (APA7: one blank line before and after)
#set figure(gap: 1em)
#show figure: it => {
  v(1.15em) // one blank line before (matching line spacing)
  it
  v(1.15em) // one blank line after
}
#show figure.caption: set text(size: 10pt)
#show figure.caption: it => {
  set par(justify: false, first-line-indent: 0em)
  set align(left)
  it
}

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
    Laura Weber\
    Gianna Hemm\
    Lisa Kipp\
    Linus Sehn \
    Maximilian Pöppe
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

// Abstract
#align(center)[
  #text(size: 12pt, weight: "bold")[Abstract]
]

#v(0.5em)

#set par(justify: true)
Angelehnt an das Stress- und Coping-Inventar (2., überarbeitete und neunormierte Version; @satow_sci_2024) erfasst die Kurzskala zur Erfassung von Stresssymptomen, Stressbelastung und Stressbewältigung (KSSB) sieben namensgebende Unterskalen, darunter 5 Stressbewältigungsskalen, mit insgesamt 15 Items. Inhaltlich untergliedern sich die Skalen Stresssymptome und Stressbelastung in weitere Unterdimensionen.

#v(0.5em)

*Schlüsselwörter:* Stress, Kurzskala, Bewältigung, Coping

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

// Main content starts here
= Einleitung

_Wird hinzugefügt_

= Theoretischer Hintergrund

_Wird hinzugefügt_

= Instrument

== Item- und Skalenkonstruktion
Zusammengenommen enthält die Kurzskala zur Erfassung von Stresssymptomen, Stressbelastung und Stressbewältigung (KSSB) sieben psychometrische Unterskalen mit insgesamt 15 Items. Die Skalen Stressbelastung und Stresssymptome umfassen je fünf Items, während jede der 5 Stressbewältigungsskalen von einem Item abgedeckt wird. Die Itemauswahl orientiert sich an der Struktur des Stress- und Coping-Inventars von #cite(<satow_sci_2024>, form: "prose"). Nachfolgend wird kurz auf die einzelnen Skalen eingegangen. Der vollständige Test findet sich ebenfalls im Anhang (Appendix A).

Die KSSB kann zur Erfassung von Stress allgemein und seiner Unterdimensionen in der Allgemeinbevölkerung ab 18 Jahren eingesetzt werden. Er lässt sich sowohl digital als auch als Paper-Pencil-Test durchführen und hat kein Zeitlimit. Bisherige Erhebungsdaten zeigen eine durchschnittliche Bearbeitungszeit von 6 Minuten.

== Allgemeine Instruktion
Die Instruktion, die den Proband*innen zu Beginn der Erhebung präsentiert wurde, war: „Im Folgenden werden Ihnen Aussagen zu Situationen oder Symptomen präsentiert. Es gibt kein Richtig oder Falsch. Bitte antworten Sie wahrheitsgemäß und ehrlich, wie sehr die Aussage auf Sie zutrifft. Denken Sie dabei an die letzten drei Monate."

=== Stresssymptome
Die Skala Stresssymptome erfasst mit 5 Items inhaltlich die Dimensionen körperliche Beschwerden (SYMP_PHYS), Schlaf (SYMP_SLEP), Kognition (SYMP_COGN), Stimmung (SYMP_MOOD) und soziale Symptome (SYMP_SOCI), welche typische mit Stress assoziierte Symptome darstellen. Die Antworten werden über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert eine hohe Ausprägung repräsentiert.

_Instruktion:_ „Bitte kreuzen Sie an, welche Symptome Sie in den letzten drei Monaten bei sich beobachtet haben."

_Items:_

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
Die Skala Stressbelastung erfasst mit 5 Items inhaltlich die Dimensionen Zukunftssorgen (STRS_FUTU), Finanzen (STRS_FINA), Beziehungen (STRS_RELA), Leistungsdruck (STRS_PERF) und Gesundheit (STRS_HEAL), welche die subjektive Belastung in verschiedenen Lebensbereichen abdeckt. Die Antworten werden ebenfalls über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert einer hohen Ausprägung entspricht.

_Instruktion:_ „Bitte kreuzen Sie an, wie sehr Sie sich durch die folgenden Situationen in den letzten drei Monaten belastet gefühlt haben."

_Items:_

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

Stressbewältigung sammelt unter sich 5 Skalen mit je einem Item zu einer Bewältigungsstrategie (auch Coping genannt). Die jeweilige Skala ist an dieser Stelle der Übersichtlichkeit halber _kursiv_ vor dem Item dokumentiert. Die Antworten werden je über eine 6-stufige verbale Likert-Skala erfasst, wobei ein hoher Wert eine hohe Ausprägung repräsentiert.

_Instruktion:_ "Bitte kreuzen Sie an, wie Sie mit Stress umgehen."

_Items:_

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

== Stichproben
An der Studie nahmen insgesamt 232 Personen teil. Nach Datenbereinigung und Ausschluss von Personen, die den Aufmerksamkeits nicht bestanden haben, umfasste die finale Stichprobe 180 Personen.

=== Demographische Merkmale
Das durchschnittliche Alter der Stichprobe betrug _M_ = 27.62 Jahre (_SD_ = 9.90 Jahre). Die Altersverteilung ist in Abbildung 1 dargestellt. Die Stichprobe war überwiegend weiblich (77.8%), in Beschäftigung als Studenten (64.4%) und wies ein hohes Bildungsniveau auf (52.2% mit Bachelor, Master oder Staatsexamen).

=== Ausreißeranalyse
Zur Qualitätssicherung der Daten wurde eine umfassende Ausreißeranalyse durchgeführt. Es wurden keine konsistenten Ausreißer aus den Hauptanalysen ausgeschlossen, da keine Hinweise auf Messfehler vorlagen. Details zur Ausreißeranalyse finden sich in den verfügbaren R-Skripten.

== Item- und Skalenkennwerte
Im Folgenden werden die psychometrischen Kennwerte der KSSB dargestellt. Für jede Skala werden zunächst deskriptive Statistiken auf Skalenebene berichtet, gefolgt von einer detaillierten Darstellung der Itemkennwerte. Dabei liegt der Fokus auf Mittelwerten, Standardabweichungen und part-whole-korrigierten Trennschärfen der einzelnen Items, die Aufschluss über die Itemqualität geben. Zusätzlich werden Reliabilitätskennwerte (Cronbachs Alpha) sowie Informationen zur Normierungsstrategie der jeweiligen Skalen berichtet. Die Retest-Reliabilitäten (_N_ = 21, Zeitintervall ≈ 2 Wochen) waren durchweg akzeptabel bis gut (Median _r_#sub[tt] = .77), was auf eine zeitliche Stabilität der Messungen hinweist.

=== Stresssymptome
Die Skala Stresssymptome umfasst 5 Items und zeigte in der Validierungsstichprobe (_N_ = 180) einen Skalenmittelwert von _M_ = 3.45 (_SD_ = 1.12) bei einer Spannweite von 1.00 bis 6.00. Die interne Konsistenz der Skala erwies sich mit Cronbachs α = .812 (95% CI [.765, .853]) als gut. Die Itemkennwerte sind in Tabelle 1 dargestellt.

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
  caption: [Itemkennwerte der Skala Stresssymptome (_N_ = 180). Trennschärfen sind part-whole-korrigiert. Retest-Reliabilitäten basieren auf _N_ = 21.]
)

Alle Items wiesen zufriedenstellende bis gute Trennschärfen auf (_r_#sub[it] = .507 bis .701), wobei Item SYMP_SLEP (Schlechter Schlaf/Träume) die höchste Trennschärfe zeigte. Die Retest-Reliabilitäten der Items waren überwiegend gut bis exzellent (_r_#sub[tt] = .582 bis .862), was auf eine hohe zeitliche Stabilität der Messung hinweist. Die Skala wird auf Basis einer gemeinsamen Norm für die Gesamtstichprobe ausgewertet, da keine signifikanten Gruppenunterschiede identifiziert wurden.

=== Stressbelastung
Die Skala Stressbelastung besteht aus 5 Items und wies in der Validierungsstichprobe (_N_ = 180) einen Skalenmittelwert von _M_ = 3.90 (_SD_ = 0.95) mit einer Spannweite von 1.20 bis 6.00 auf. Die interne Konsistenz betrug Cronbachs α = .710 (95% CI [.637, .772]) und ist damit als akzeptabel zu bewerten. Die Itemkennwerte sind in Tabelle 2 dargestellt.

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
  caption: [Itemkennwerte der Skala Stressbelastung (_N_ = 180). Trennschärfen sind part-whole-korrigiert. Retest-Reliabilitäten basieren auf _N_ = 21.]
)

Alle Items erreichten akzeptable Trennschärfen (_r_#sub[it] = .376 bis .539), wobei Item STRS_FINA (Geldprobleme) die höchste Trennschärfe aufwies. Die Retest-Reliabilitäten lagen durchweg im akzeptablen bis guten Bereich (_r_#sub[tt] = .659 bis .774) und belegen die zeitliche Stabilität der Messung. Für diese Skala wird eine altersspezifische Normierung empfohlen, da signifikante Altersunterschiede identifiziert wurden. Es werden separate Normtabellen für drei Altersgruppen bereitgestellt (jung: $<$30 Jahre, mittel: 30–45 Jahre, alt: $>$45 Jahre).

=== Stressbewältigung
Die Stressbewältigung wird über fünf Einzelitems erfasst, die jeweils eine spezifische Bewältigungsstrategie abbilden. Da es sich um Einzelitems handelt, kann keine interne Konsistenz berechnet werden.

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
  caption: [Itemkennwerte der Stressbewältigungsitems (_N_ = 180). Retest-Reliabilitäten basieren auf _N_ = 21.]
)

Die Items zeigen eine breite Streuung in ihren Mittelwerten, was die unterschiedliche Häufigkeit der Nutzung verschiedener Bewältigungsstrategien widerspiegelt. Soziale Unterstützung (COPE_SOCI) wurde am häufigsten berichtet (_M_ = 4.73), während Substanzkonsum (COPE_DRUG) die geringste Zustimmung erhielt (_M_ = 1.91). Die Retest-Reliabilitäten der Einzelitems variierten zwischen _r_#sub[tt] = .567 (COPE_REAP) und _r_#sub[tt] = .910 (COPE_DRUG), wobei die meisten Items eine gute bis exzellente zeitliche Stabilität aufwiesen. Die Normierung erfolgt für vier Items (COPE_DRUG, COPE_RELI, COPE_SOCI und COPE_REAP) auf Basis gemeinsamer Normen. Für Item COPE_ACTI (Aktive Bewältigung) werden aufgrund signifikanter Geschlechtsunterschiede geschlechtsspezifische Normen bereitgestellt.

== Validität
Die Validität der KSSB wurde durch konvergente Validitätsanalysen überprüft, bei denen Korrelationen mit theoretisch verwandten Konstrukten berechnet wurden. Als Validierungskriterien dienten Lebenszufriedenheit @beierlein_kurzskala_2015, Neurotizismus (Big Five) und Resilienz. Zusätzlich wurde die faktorielle Struktur der KSSB mittels konfirmatorischer Faktorenanalyse (CFA) überprüft.

=== Konvergente Validität
Die Skala Stressbelastung zeigte substanzielle Korrelationen mit allen drei Validierungskriterien. Mit Lebenszufriedenheit korrelierte die Skala negativ (_r_ = –.44, _p_ < .001), was die Annahme bestätigt, dass höhere Stressbelastung mit geringerer Lebenszufriedenheit einhergeht. Erwartungsgemäß zeigte sich eine positive Korrelation mit Neurotizismus (_r_ = .51, _p_ < .001), da neurotische Personen stressauslösende Situationen häufiger als belastend erleben. Die negative Korrelation mit Resilienz (_r_ = –.43, _p_ < .001) unterstreicht, dass resiliente Personen Stressoren besser bewältigen und als weniger belastend wahrnehmen.

Die Skala Stresssymptome wies durchweg höhere Korrelationen mit den Validierungskriterien auf als die Stressbelastungsskala. Die negative Korrelation mit Lebenszufriedenheit war stark ausgeprägt (_r_ = –.61, _p_ < .001), ebenso die positive Korrelation mit Neurotizismus (_r_ = .60, _p_ < .001) und die negative Korrelation mit Resilienz (_r_ = –.54, _p_ < .001). Diese Befunde bestätigen, dass Stresssymptome eng mit psychischem Wohlbefinden und Persönlichkeitsmerkmalen verknüpft sind.

Die fünf Bewältigungsstrategien zeigten differenzielle Validitätsmuster, die mit theoretischen Erwartungen übereinstimmen. Adaptive Strategien wie positive Neubewertung, und soziale Unterstützung korrelierten positiv mit Lebenszufriedenheit (_r_ = .39 bzw. .36, beide _p_ < .001) und negativ mit Neurotizismus und Stresssymptomen. Maladaptive Strategien wie Substanzkonsum zeigten hingegen positive Korrelationen mit Stressbelastung (_r_ = .18, _p_ = .017). Religiöses Coping korrelierte positiv mit Lebenszufriedenheit (_r_ = .21, _p_ = .006) und negativ mit Neurotizismus (_r_ = –.23, _p_ = .002). Aktive Bewältigung zeigte schwächere, aber konsistente Zusammenhänge mit den Validierungskriterien.

Abbildung 1 zeigt ein Korrelationsnetzwerk, das die Zusammenhänge zwischen allen KSSB-Skalen und den Validierungskriterien visualisiert. Die Stärke der Korrelationen wird durch die Liniendicke repräsentiert, wobei blaue Linien positive und rote Linien negative Korrelationen darstellen. Das Netzwerk verdeutlicht die zentralen Zusammenhänge zwischen Stresssymptomen, Stressbelastung und den psychologischen Validierungskriterien.

#figure(
  image("plots/51_korrelationsnetzwerk_validitaet.png", width: 100%),
  caption: [Korrelationsnetzwerk der KSSB-Skalen und Validierungskriterien (_N_ = 180). Blaue Linien repräsentieren positive Korrelationen, rote Linien negative Korrelationen. Die Liniendicke entspricht der Stärke der Korrelation. Dargestellt sind nur signifikante Korrelationen (_p_ < .05, |_r_| ≥ .15).]
)

=== Faktorenstruktur
Die faktorielle Validität der KSSB wurde mittels konfirmatorischer Faktorenanalyse (CFA) mit einer 2-Faktoren-Struktur (Stressbelastung und Stresssymptome, je 5 Items) überprüft. Die Modellfit-Indizes zeigten einen verbesserungswürdigen Fit (χ² = 100.74, _df_ = 34, _p_ < .001; CFI = .886; TLI = .849; RMSEA = .104 [.081, .128]; SRMR = .066). Alle Faktorladungen waren substanziell (.517–.845) und signifikant (_p_ < .001; siehe Abbildung 4). Die Korrelation zwischen den Faktoren betrug _r_ = .820 (_p_ < .001), was auf ausreichende Diskriminanz hinweist.

Die Composite Reliability lag bei CR = .715 (Stressbelastung) und CR = .817 (Stresssymptome). Die Average Variance Extracted (AVE) betrug .336 bzw. .479, was unter dem idealen Schwellenwert von .50 liegt, jedoch durch die substanziellen Faktorladungen kompensiert wird.

#figure(
  image("plots/50_final_cfa_kurzskalen_heatmap.png", width: 80%),
  caption: [Standardisierte Faktorladungen der konfirmatorischen Faktorenanalyse (CFA) für die KSSB-Kurzskalen (_N_ = 180). Dunklere Farben repräsentieren höhere Faktorladungen.]
)

=== Subgruppenvalidität
Die Validität der Skalen wurde über verschiedene demographische Subgruppen (Geschlecht, Alter, Bildungsniveau, Beschäftigungsstatus) hinweg überprüft. Fisher-Z-Tests ergaben keine signifikanten Unterschiede in den konvergenten Validitätskoeffizienten zwischen den Gruppen, was auf eine robuste Validität über verschiedene Populationen hinweist.

#pagebreak()
= Zusammenfassung

#pagebreak()
= Literaturverzeichnis

#bibliography("zotero.bib")

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
  [Ich fühle mich belastet durch Probleme mit Familie, Freund*Innen oder Partner*Innen.], [$square$], [$square$], [$square$], [$square$], [$square$], [$square$],
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
Gemeinsame Norm für gesamte Stichprobe (_N_ = 180, _M_ = 3.45, _SD_ = 1.12)

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

_N_ = 146, _M_ = 4.02, _SD_ = 0.92

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

_N_ = 21, _M_ = 3.47, _SD_ = 0.81

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

_N_ = 13, _M_ = 3.34, _SD_ = 1.05

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
Gemeinsame Norm (_N_ = 180)

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
Gemeinsame Norm (_N_ = 180)

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
Gemeinsame Norm (_N_ = 180)

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
Gemeinsame Norm (_N_ = 180)

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

_N_ = 36, _M_ = 3.75, _SD_ = 1.11

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

_N_ = 140, _M_ = 3.29, _SD_ = 1.11

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
