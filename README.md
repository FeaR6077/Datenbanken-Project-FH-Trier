## Datenbanken Projekt von Julian Pretzsch, Matrikelnr: ------

![alt text](https://github.com/FeaR6077/Datenbanken-Project-FH-Trier/blob/main/ER-Modell_final.png?raw=true)

### Einführung

Das Datenbankprojekt soll mit knapp 1 8 Relationen ( 7 Beziehungsrelationen und 11 Entitäten), den
für einen Studenten am anstrengendsten Teil des Studiums an der Hochschule Trier, die
Klausurenphase, abbilden. Dabei bieten die beiden Supertypen **Mitarbeiter** und **Student** zunächst die
Möglichkeit, grundlegende Attribute über Studenten /Mitarbeiter zu speichern (1zuC-Beziehung).
Durch die Subtypen **Sekretär, Assistent** , **Mensamitarbeiter** und **Professor** bzw. **Tutor** lassen sich
weitere, spezifische Attribute hinzufügen. Dabei wurde der Struktur und Implementierung mehr
Aufmerksamkeit gewidmet, als den eigentlichen Daten und deren Sinnhaftigkeit. Die **Vorlesung** / **en** ,
das **Tutorium** / **en** und die **Prüfung** / **en** definieren als Entitäten die einzelnen Veranstaltungen, zu
denen sich ein Student innerhalb eines **Semesters** einträgt. Die übrigen Relationen implementieren
als Beziehungsrelationen die M:N-Beziehungen zwischen den einzelnen Entitäten.

## Die einzelnen Relationen

### Mitarbeiter (Starke Entität)

- Supertyp für die Entitäten Prof. /Sekretär/Mensamitarbeiter & Assistent (1:C-Beziehung)
- Hier gewählt, um Redundanzen in den 4 Subtypen zu vermeiden
- Fasst grundlegende Attribute eines Mitarbeiters zusammen
- Befindet sich in der 3ten Normalform nach B.C., da alle Attribute nur voll funktional vom
  Primärschlüssel abhängig sind

### Sekretär/Mensamitarbeiter (Schwache Entität)

- Subtyp von Mitarbeiter, mit dem zusätzlichen Attribut Provision
- Sind schwache Entitäten, da ihr eigener Primärschlüssel, auf Grund der Constraint-
  Anweisung, dem Primärschlüssel eines bereits angelegten Tupels des Supertypens
  entsprechen muss.
- Die Folge ist, dass beim Hinzufügen eines Tupels in eine der beiden Relationen, eine
  bereits existierende Mitarbeiternummer mit angegeben werden muss, da diese den
  Primärschlüssel des Subtypen definiert
- Beide Relationen Befinden sich in der 3ten Normalform nach B.C, da alle Attribute nur
  voll funktional vom Primärschlüssel abhängig sind
  (Personalnummer_sek -> Provision/Personalnummer_mensa->Provision)

### Professor (Schwache Entität)

- Subtyp von Mitarbeiter, und mittels der Constraint-Anweisung eine schwache Entität
- Die Relation befindet sich in der 3ten Normalform (Sekretäre können mehrere
  Professoren aus unterschiedlichen Fachrichtungen verwalten, wodurch keine funktionale
  Abhängigkeit zwischen Personalnummer_sek und Fachbereich existiert)

### Assistent (Schwache Entität)

- Subtyp von Mitarbeiter, woraus dieselbe Constraint-Anweisung folgt
- 1:M-Beziehung zu Professor (Professor kann mehrere Assistenten haben, aber ein
  Assistent arbeitet immer nur für einen Prof)
- Die Relation befindet sich in der 3ten Normalform, unter der Annahme, dass keine
  funktionale Abhängigkeit zwischen ProfessorNR und Fachbereich besteht. (Ein Assistent
  kann für einen Professor eines anderen Fachbereiches arbeiten)

### Student (Starke Entität)

- Supertyp für Tutor (1:C-Beziehung) und fasst, wie die Relation Mitarbeiter, die
  grundlegende Attribute eines Studenten aus Redundanzgründen zusammen.
- Befindet sich in der 3ten Normalform, da abseits des Primärschlüssels keine weiteren
  funktionalen Abhängigkeiten existieren.

### Tutor (Schwache Entität)

- Subtyp von Student & Schwache Entität, da auch hier über Constraint-Anweisungen der
  Primärschlüssel von Student „übernommen“ wird.
- Die Relation befindet sich in der 3ten Normalform (keine funkt. Abh. zwischen
  Beschreibung und Fachbereich, da mehrere Fachbereiche z.B. eine Statistikvorlesung
  anbieten)

### Semester

- Beinhaltet die Bezeichnung des Semesters (z.B. WS20) und definiert mit den Attributen
  Anfangsdatum und Enddatum den Zeitraum eines Semesters.
- Die 1:M-Beziehungen zu Vorlesung/Prüfung/Tutorium ordnet diesen Entitäten einen
  zeitlichen Kontext zu (Prüfung in Datenbanken wurde WS19 Bestanden)
- Die Relation befindet sich in der 3ten Normalform

### Prüfung

- Ein Student kann sich zu mehreren Prüfungen anmelden, jedoch ist eine Prüfung immer
  auf einen Studenten zurückzuführen (1:M-Beziehung)
- Die Relation befindet sich in der 3ten Normalform

### Vorlesung

- Befinden sich beide in der 3ten Normalform

### Tutorium

- Befindet sich in der 2ten Normalform, da die Determinante VorlesungsID das Semester
  voll funktional erklärt, jedoch kein Schlüsselkandidat ist, da sie die einzelnen Tupel nicht
  voneinander differenzieren kann

### Ließt_vor/stellt/umfasst/arbeitet_fuer/hoert/nimmt_teil/haelt

- Befinden sich alle in der 3ten Normalform, da alle Attribute Primärschlüssel sind
- Beschreiben als Beziehungsrelationen alle M:N-Beziehungen zwischen den einzelnen
  Entitäten

## VIEWS

### SEKRETÄR_VIEW/ PROF_VIEW

- Beinhaltet alle komplett/fertig angelegten Klausuren, die ein Tutorium und eine
  Vorlesung haben.
- Es werden alle Prüfungen dargestellt, in dessen Implementierung ein Tutorium und eine
  Vorlesung eingepflegt wurde. Weitere Verwaltung und Pflege ist die Aufgabe des
  Sekretärs.

### - Der Professor sieht zusätzlich noch den Namen und die Matrikelnr des Studenten
