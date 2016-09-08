# Doel

De pingpongprestaties van Jeroen Van Der Hooft analyseren, zowel doorheen de tijd als in vergelijking met zijn clubgenoten.

# Vragen

- Hoe is de rating van JVDH geëvolueerd?
- Wat waren de meest opmerkelijke overwinningen/nederlagen?
- Is de evolutie van de rating van JVDH een typisch patroon?
- Heeft JVDH zijn zwarte beesten?

De evolutie van de rating wordt zowel binnen de club als over alle clubs heen bekeken. Zwarte beesten zijn tegenstanders waartegen meermaals werd verloren.

# Data

Data is te vinden op [http://competitie.vttl.be](competitie.vttl.be). Per seizoen kunnen per club van alle leden de resultaten bekeken worden.

## Ledenlijst

Eerst werd de ledenlijst opgehaald. Data voor TCC Maldegem is beschikbaar van seizoen 2006-2007 tot 2016-2017.

## Resultaten leden

Seizoen verwijst altijd naar het jaar waarin het seizoen gestart is (vb. 2004-2005 wordt 2004).

# Analyse

## Opmerkelijke overwinningen/nederlagen

### Klassering of ELO?

Er zijn 2 methodes om het verschil in kwaliteit met de tegenstander te meten: ELO en klassering. Het verschil in ELO waarde met de tegenstander kan eenvoudig berekend worden, om het verschil in klassering te berekenen moet de klassering eerst in een numerieke waarde worden omgezet. De klasseringen in de dataset gaan van B0 tot NG. Daarnaast zijn er nog wedstrijden waarbij de tegenstander een klassering van ofwel A26 ofwel A7 heeft. Aangezien de betekenis van deze klassering niet direct duidelijk was, zijn deze wedstrijden verwijderd. De numerieke waardes zijn als volgt gekozen: B0 krijgt de waarde 1, B2 de waarde 2, enz... tot NG bereikt wordt.

### Nadelen klassering

Aan het gebruik van de klassering zijn twee grote nadelen verbonden:

* er is een bias naar hogere klasseringen toe
* er is een zekere variatie in kwaliteit binnen de klassering zelf

Het eerste nadeel wordt geïllustreerd door de volgende grafiek:

![](https://www.dropbox.com/s/fipdgiod9gvye30/graph_bias_higher_categories.png?dl=1)

Een speler met klassering NG kan geen opmerkelijke nederlagen lijden aangezien er geen klassement lager bestaat, een speler met klassering C0 kan geen opmerkelijke overwinningen boeken aangezien er geen klassement hoger bestaat.

Het tweede nadeel is dat kwaliteitsverschillen binnen eenzelfde klassement bestaan, zelfs groot kunnen zijn:

![](https://www.dropbox.com/s/r1rv3glv5t3pumg/graph_elo_within_category.png?dl=1)

We stellen bijvoorbeeld vast dat een speler met klassement D4 een ELO kan hebben tussen 1000 en 1400 wat toch een aanzienlijk verschil uitmaakt. Op basis van de vorige twee nadelen blijkt de klassering geen goede indicatie van het kwaliteitsverschil tussen twee spelers.

### Nadelen ELO

De hoop is dus dat het ELO-systeem beter de kwaliteitsverschillen tussen spelers reflecteert.

![](https://www.dropbox.com/s/cyob0gl9ex59o77/graph_expected_score_difference.png?dl=1)

Per definitie zal bij spelers met dezelfde ELO-waardes het altijd kop of punt zijn waardoor de grafiek piekt bij 50%. Wat tegenvalt is dat het percentage incorrecte voorspellingen slechts traag daalt naarmate het verschil tussen de spelers groter wordt. ELO is dus niet perfect, maar de weg van het minste kwaad.

