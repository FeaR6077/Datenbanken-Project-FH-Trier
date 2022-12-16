
														#---------------------------------------#
														#anlegen der Datenbank & diese Verwenden
														#---------------------------------------#
CREATE DATABASE FH_TRIER;
USE FH_TRIER;
#DROP DATABASE FH_TRIER; 								#Möglichkeit Datenbank löschen (falls fehlerhaft)

														#----------------------------------------------------------------------------#
														#Falls bereits Tabellen mit folgenden Namen existieren, werden diese gelöscht
														#----------------------------------------------------------------------------#
DROP TABLE IF EXISTS Sekretär;
DROP TABLE IF EXISTS Assistent;
DROP TABLE IF EXISTS Mitarbeiter;
DROP TABLE IF EXISTS Mensamitarbeiter;
DROP TABLE IF EXISTS Professor;
DROP TABLE IF EXISTS Vorlesung;
DROP TABLE IF EXISTS Prüfung;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Tutor;
DROP TABLE IF EXISTS Tutorium;
DROP TABLE IF EXISTS ließt_vor;
DROP TABLE IF EXISTS umfasst;
DROP TABLE IF EXISTS stellt;
DROP TABLE IF EXISTS arbeitet_fuer;
DROP TABLE IF EXISTS hoert;
DROP TABLE IF EXISTS haelt;
DROP TABLE IF EXISTS umfasst;
DROP TABLE IF EXISTS Semester;
DROP TABLE IF EXISTS nimmt_teil;




														#--------------------#
														#Anlegen der Tabellen
														#---------------------#
														
CREATE TABLE Mitarbeiter ( 
Personalnummer MEDIUMINT PRIMARY KEY, 	#Gewählt unter der Annahme, dass eine Personalnummer kleiner ist als 8388607 
Vorname VARCHAR(30),				 				
Nachname VARCHAR(30),									
Geburtsdatum INT,										
Gehalt INT,
Strasse VARCHAR(30),
Ort VARCHAR (30),
Urlaubstage SMALLINT,					#Gewählt unter der Annahme, dass keine Urlaubstage > 365 existieren
PLZ decimal(5,0) ZEROFILL NOT NULL,		#Dezimalzahl mit genau 5 Stellen, wobei es keine Nachkommastellen gibt. Sinnvoll, da jede PLZ aus genau 5 Ziffern besteht. Außerdem wird Bei einer Eingabe von z.B. nur einer '1' die restlichen Stellen von links aus mit Nullen aufgefüllt.
check(PLZ >= 01001 ),					#Check, damit keine PLZ kleiner ist als 01001, was die kleinste Postleitzahl ist. Somit sind auch keine negativen PLZ erlaubt
check(Personalnummer > 0),				#Es sind keine negativen Personalnummern erlaubt
check(Urlaubstage>=20)					#Check ob mindestens 20 Urlaubstage (gesetzlich vorgeschrieben) erfüllt sind
);
														#-----------------------------------------------------------------------#
														#Erstellung der Subtypen Sekretär/Mensamitarbeiter/Assistent & Professor
														#-----------------------------------------------------------------------#
                                                        
CREATE TABLE Sekretär(
Personalnummer_sek MEDIUMINT PRIMARY KEY,							#MEDIUMINT da auf die Personal(Personalnummer) referneziert wird (CONSTRAINT). Da Personalnummer_sek einer Personalnummer entsprechen muss, muss auch der gleiche Datentyp vorliegen
Provision INT,
CONSTRAINT PersNR_Sek FOREIGN KEY(Personalnummer_sek) REFERENCES	#Um in der Sekretärs-Relation einen neuen Tupel erfolgreich anzulegen, muss die Personalnummer eines bereits existierenden Mitarbeites als Personalnummer_sek angegeben werden.
Mitarbeiter(Personalnummer) ON DELETE CASCADE ON UPDATE CASCADE		#Selbiges gilt für Professor/Mensamitarbeiter & Assistent. Über diesen Constraint-Befehl wird die 1:C-Beziehung implementiert (Beziehung Subtyp zu Supertyp).
);																	#Sollte ein Mitarbeiter gelöscht werden 'ON DELETE', so wird dieser auch in der jeweiligen Tabelle der Subtypen gelöscht 'Cascade'
																	#und bei einem Update der Personalnummer 'ON UPDATE', wird diese Veränderung in die jeweilige Tabelle übernommen 'Cascade'
																	
											
CREATE TABLE Mensamitarbeiter(										
Personalnummer_mensa MEDIUMINT PRIMARY KEY,							
Provision INT,
CONSTRAINT PersNR_Mensa FOREIGN KEY(Personalnummer_mensa) REFERENCES	#Selbe Constraint-Logik wie bei Sekretär
Mitarbeiter(Personalnummer) ON DELETE CASCADE ON UPDATE CASCADE			#Siehe Sekretär
);



CREATE TABLE Professor(
Personalnummer_prof MEDIUMINT PRIMARY KEY,
Fachbereich VARCHAR(40),
Personalnummer_sek MEDIUMINT NOT NULL,									#Ein Professor hat immer auch einen Sekretär, der für ihn Vorlesunge/Prüfungen/Tutorien verwaltet (1:N-Beziehung & NOT NULL).
CONSTRAINT PersNR_Prof FOREIGN KEY(Personalnummer_prof) REFERENCES		#Somit NOT NULL, damit ein Professor nur angelegt werden kann, wenn diesem ein Sekretär zugeordnet wird.
Mitarbeiter(Personalnummer) ON DELETE CASCADE ON UPDATE CASCADE,		#Ein Professor soll immer gelöscht werden können, Updates sollen übernommen werden (Änderung der Personalnummer)
CONSTRAINT PersNRSEK_Prof FOREIGN KEY(Personalnummer_sek) REFERENCES 	#Constraint stellt sicher, dass es sich bei der Personalnummer der Sekretärs auch wirklich um einen zuvor angelegten Sekretär handelt
Sekretär(Personalnummer_sek) ON DELETE NO ACTION ON UPDATE CASCADE		#Ein Sekretär kann erst gelöscht werden, wenn er für keinen Professor mehr arbeitet, Updates sollen übernommen werden (Änderung der Personalnummer)
);																		#Bzw. ein Professor wird beim löschen eines Sekretärs nicht mitgelöscht

CREATE TABLE Assistent(
Personalnummer_ass MEDIUMINT PRIMARY KEY,								
Fachbereich VARCHAR(40),												
ProfessorNr MEDIUMINT,													#Implementiert die 1:N-Beziehung zwischen Assistent und Professor, Null werte sollen möglich sein!
CONSTRAINT PersNR_Assistent FOREIGN KEY (Personalnummer_ass) REFERENCES	#Constraint stellt wieder sicher, dass die Personalnummer des Mitarbeiters bereits in der Mitarbeiterrelation angelegt wurde.
Mitarbeiter(Personalnummer) ON DELETE CASCADE ON UPDATE CASCADE,		#Wird der Mitarbeiter gelöscht, so wird er auch als Assistent gelöscht, Aktualisierungen seiner Personalnummer werden übernommen
CONSTRAINT Prof_Assistent FOREIGN KEY (ProfessorNR) REFERENCES			#Nur existierenden Professoren (vorhandene Personalnummer_prof in Professor-Relation) können Assistenten zugeteilt werden
Professor(Personalnummer_prof)ON DELETE SET NULL ON UPDATE CASCADE		#ein Assistent verliert seine Assistentenstelle nicht, wenn ein Professor gelöscht wird (SET NULL) er kann einem neuen Prof. zugeordnet werden, Updates werden auch hier übernommen
);

CREATE TABLE Student(
Matrikelnr DECIMAL(6,0) PRIMARY KEY,	#Wie bei der PLZ soll die Länge der Matrikelnr genau 6 Ziffern sein, ohne Nachkommastellen
Vorname VARCHAR(30),
Nachname VARCHAR(30),
ECTS SMALLINT,							#Maximale ECTS-Punkte <32767, aber ECTS>127 (TINYINT) somit aus Speicherplatzgründen die Wahl des SMALLINTs
Geburtsdatum DATE,	
Einschreibungsdatum DATE,
Strasse VARCHAR(30),
Ort VARCHAR(30),
PLZ decimal(5,0) ZEROFILL NOT NULL,
check(PLZ >= 01000 ),					#PLZ check wie bei Mitarbeiter
check(Matrikelnr >= 0)					#Keine negativen Matrikelnr under der Prämisse, dass Matrikelnummern der Geburtsjahre 2000-2009 mit 00XXXX/09XXXX anfangen, wodurch die Matrikelnr 000000 möglich wäre
);										

CREATE TABLE TUTOR(
Tutnr DECIMAL(6,0) PRIMARY KEY,			#Muss Decimal(6,0) sein, da Tutnr auf Matrikelnr(DECIMAL(6,0)) referenziert
Fachbereich VARCHAR (40),
Beschreibung VARCHAR (30),
Gehalt INT,
CONSTRAINT Matrikel_Tut FOREIGN KEY (Tutnr) REFERENCES Student(Matrikelnr)	#Constraint stellt sicher, dass die Matrikelnr des Tutors auch einer Matrikelnr in der Relation Student entspricht (1:C-Beziehung)
ON DELETE CASCADE ON UPDATE CASCADE											#Wenn der Student gelöscht wird (DELETE) wird er auch als Tutor gelöscht (Nur Studenten können Tutoren sein)
);																			#Bei Änderung der Matrikelnummer des Studenten, soll diese Änderung in der Tutor-Relation übernommen werden.
																			
																			
CREATE TABLE Semester(					
Bezeichnung VARCHAR(15) PRIMARY KEY,							#Gedacht als Beschreibung des Semesters z.B.'WS20'
Anfangsdatum DATE,
Enddatum DATE
);
																		
CREATE TABLE Vorlesung(
VorlesungsID INT PRIMARY KEY AUTO_INCREMENT,					#Möglichkeit, beim Erstellen eines neuen Tupels in dieser Relation, keine VorlesungsID angeben zu müssen. Die Vorherige VorlesungsID wird um +1 erhöht
Beschreibung VARCHAR(50) ,
Semester VARCHAR(15) NOT NULL REFERENCES Semester(Bezeichnung)	#NOT NULL zur Realisierung der 1:M-Beziehung zwischen Vorlesung und Semester. Durch Reference + NOT NULL wird sichergestellt, dass die Vorlesung immer einem Semester zugeordnet wird.
ON DELETE NO ACTION ON UPDATE CASCADE,							#Ein Semester kann erst gelöscht werden, wenn in diesem keine Vorlesungen/Tutorien/Prüfunden mehr stattfinden (NO ACTION) & bei Änderung der Semesterbeschreibung (Tippfehler wie SS13/SSS13) wird diese auch in dieser Relation geupdated (CASCADE)
Raum VARCHAR(4),												#Annahme, dass Beschreibung des Raum = max. 4 Character (L103/X22)
Wochentag VARCHAR(10),																	
Uhrzeit TIME
);

CREATE TABLE Tutorium(
TutID INT PRIMARY KEY AUTO_INCREMENT,								#Siehe Vorlesung
VorlesungID INT NOT NULL,											#Ein Tutorium bezieht sich immer auf eine Vorlesung (NOT NULL), jedoch können meherer Tutorien für eine Vorlesung existieren (z.B ein Tutorium an zwei unterschiedlichen Tagen/Zeitpunkten). Durch NOT NULL Realisierung der 1:M-Beziehung
Semester VARCHAR(15) NOT NULL REFERENCES Semester(Bezeichnung)		#Ordnet das Tutorium einem Semester zu / Realisierung der 1:M-Beziehung zwischen Semester und Tutorium
ON DELETE NO ACTION ON UPDATE CASCADE,								#Siehe Vorlesung 
Raum CHAR(4),													
Uhrzeit TIME,
Wochentag CHAR(10),
CONSTRAINT Tut_Vor FOREIGN KEY (VorlesungID) REFERENCES Vorlesung(VorlesungsID)	
ON DELETE CASCADE ON UPDATE CASCADE									#Wird eine Vorlesung gelöscht, so wird auch das dazugehörtige Tutorium gelöscht (Cascade), Änderungen der VorlesungsID sollen jedoch geupdated werden.
);																	#Auch möglich = NO ACION -> Eine Vorlesung kann erst gelöscht werden, wenn das dazugehörtige Tutorium gelöscht wurde

CREATE TABLE PRÜFUNG(			
PrüfungsID BIGINT PRIMARY KEY AUTO_INCREMENT,						#Siehe Vorlesung BIGINT gewählt aufgrund hoher erwaretetn Prüfungsanmeldungen
Matrikelnr DECIMAL(6,0) NOT NULL,									#DECIMAL (6,0) dies dem Dantentyp auf Student(Matrikelnr) entspricht. NOT NULL damit die Prüfung immer auf einen Studenten zurückgeführt werden kann.(Realisierung 1:M-Beziehung zwischen Student und Prüfung)
Semester VARCHAR(15) NOT NULL REFERENCES Semester(Bezeichnung)
ON DELETE NO ACTION ON UPDATE CASCADE,																
Raum Char(4) NOT NULL,												#NOT NULL da für eine Prüfung immer ein Raum angegeben werden soll
Note NUMERIC(2,1),																		#Eine Note besteht immer aus 2 Ziffern, wobei eine davon eine Nachkommastelle ist. Kann NULL sein, solange noch keine Note eingetragen, oder die Prüfung noch nicht geschrieben wurde
Datum DATETIME, 																		#Datum und Zeit wird hier angegeben
CONSTRAINT Matrikel_Student FOREIGN KEY (Matrikelnr) REFERENCES Student(Matrikelnr)		#Wird ein Student gelöscht, wird auch seine Prüfungsanmeldung gelöscht (Exmatrikuliert) (cascade)
ON UPDATE CASCADE ON DELETE CASCADE														#Verändert sich die Matrikelnr des Studenten, so ist er immer noch zur Prüfung angemeldet (cascade)
);


														#-----------------------------------#
														#Erstellung der Beziehungsrelationen
														#-----------------------------------#

CREATE TABLE hoert(
Vorlesung INT,
Matrikelnr DECIMAL(6,0),																#DECIMAL(6,0) da CONSTRAINT auf Student(Matrikelnr) referenziert
CONSTRAINT PK1 PRIMARY KEY (Vorlesung, Matrikelnr),										#Vorlesung&Matrikelnr bilden zusammen den Primary Key
CONSTRAINT hoert_Vorlesung FOREIGN KEY (Vorlesung) REFERENCES Vorlesung(VorlesungsID)	#Es können nur Exisierende Vorlesungen gehört werden
ON DELETE CASCADE ON UPDATE CASCADE,													#Wird die Vorlesung gelöscht, kann sie nicht mehr gehört werden, wird die VorlesungsID geändert, wird diese Änderung übernommen
CONSTRAINT hoert_MatrikelNR FOREIGN KEY (Matrikelnr) REFERENCES Student(Matrikelnr)		#Nur Existierende Studenten können Vorlesungen hören (angegebene Student(Matrikelnr) muss vorhanden sein)
ON DELETE CASCADE ON UPDATE CASCADE														#Exmatrikulierte (gelöschte) Studenten können keine Vorlesung besuchen & bei aktualisierung der Matrikelnummer soll dies übernommen werden.
);

CREATE TABLE ließt_vor(
Vorlesung INT,
Personalnummer_prof MEDIUMINT,															
CONSTRAINT PK2 PRIMARY KEY (Vorlesung, Personalnummer_prof),							#Primärschlüssen besteht aus den beiden Foreign Keys Vorlesung und Personalnummer_prof
CONSTRAINT lesen_VorlesungID FOREIGN KEY (Vorlesung) REFERENCES Vorlesung(VorlesungsID)	#nur existierende Vorlesungen können vom Prof gehalten werden
ON DELETE CASCADE ON UPDATE CASCADE,													#Wird eine Vorlesung gelöscht, kann sie kein Prof mehr halten. Beim Update der VorlesunsID soll die Vorlesung weiter dem Prof zugeordnet sein
CONSTRAINT lesen_Prof FOREIGN KEY (Personalnummer_prof) REFERENCES Professor(Personalnummer_prof)	#Nur existierende Professoren sollen Vorlesungen halten können
ON DELETE NO ACTION ON UPDATE CASCADE													#Ein Professor soll nur gelöscht werden können, wenn dieser keine Vorlesungen mehr ließt
);																						#Bei Änderung der Personalnummer soll der Prof die Vorlesung weiterlesen


CREATE TABLE nimmt_teil(
Matrikelnr DECIMAL(6,0),														
TutID INT,
CONSTRAINT PK3 PRIMARY KEY (TutID, Matrikelnr),											
CONSTRAINT teil_MatrikelNR FOREIGN KEY (Matrikelnr) REFERENCES Student(Matrikelnr)		#nur existierende Studenten können Tutorien besuchen
ON DELETE CASCADE ON UPDATE CASCADE,													#wenn Student gelöscht wird, wird er aus dem Tutorium gelöscht (aus der nimmt_teil Relation) / Bei Änderungen der Matrikelnr soll er weiter Teil der Tutoriums sein
CONSTRAINT teil_TutID FOREIGN KEY (TutID) REFERENCES Tutorium(TutID)					#nur an existierende Tutorien sollen von Studenten teilnehmen können
ON DELETE CASCADE ON UPDATE CASCADE														#wird ein Tutorium gelöscht, werden alle Studenten daraus entfernt / ändert sich die ID des Tutoriums, sollen alle Studenten von Teil des Tutoriums sein 
);

CREATE TABLE arbeitet_fuer(
Tutnr DECIMAL(6,0),
Personalnummer_prof MEDIUMINT,
CONSTRAINT PK4 PRIMARY KEY (Personalnummer_prof, Tutnr),								
CONSTRAINT arbeiten_tutor FOREIGN KEY (Tutnr) REFERENCES Tutor(Tutnr)								#Nur Existierende Tutoren sollen für Professoren arbeiten können
ON DELETE CASCADE ON UPDATE CASCADE,																#Wird der Tutor/Student gelöscht, kann er nicht mehr als Tutor für den Professoren arbeiten, ändert sich die Matrikelnr, arbeitet der Student weiterhin für den Professor
CONSTRAINT arbeiten_prof FOREIGN KEY (Personalnummer_prof) REFERENCES Professor(Personalnummer_prof)#Es soll nur für existierende Professoren gearbeitet werden dürfen (angegebene Professor(Mitarbeiternummer_prof) muss existieren)
ON DELETE CASCADE ON UPDATE CASCADE																	#Wird der Professor gelöscht (Kündigung/Rente) kann nicht mehr für ihn gearbeitet werden
);																									#Bei Änderung seiner Personalnummer, soll das Geschäftsverhältnis bestehen bleiben

CREATE TABLE haelt(
Tutnr DECIMAL(6,0),
TutID INT,
CONSTRAINT PK5 PRIMARY KEY (TutID, Tutnr),								
CONSTRAINT haelt_tutor FOREIGN KEY (Tutnr) REFERENCES Tutor(Tutnr)		#nur existierende Tutoren dürfen Tutorien halten
ON DELETE CASCADE ON UPDATE CASCADE,									#ist der Tutor kein Student mehr/kein Tutor mehr, soll er kein Tutorium mehr halten / wird seine Matrikelnr geändert, jedoch schon
CONSTRAINT haelt_tutID FOREIGN KEY (TutID) REFERENCES Tutorium(TutID)	#nur existierende Tutorien sollen vom Tutor gehalten werden dürfen (nur angebotene Tutorien)
ON DELETE CASCADE ON UPDATE CASCADE										#wird das angebot gelöscht, kann der Tutor kein Tutorium mehr halten, bei Änderung der TutID soll dies geupdated werden
);

CREATE TABLE umfasst(
PrüfungsID BIGINT,																	#gewählt aufgrund hoher erwaretetr Prüfungsanmeldungen
VorlesungsID INT,															
CONSTRAINT PK6 PRIMARY KEY (PrüfungsID, VorlesungsID),				
CONSTRAINT umfasst_pruefung FOREIGN KEY (PrüfungsID) REFERENCES PRÜFUNG(PrüfungsID)	#Nur Bestehende Prüfungen(Raum/Zeit) sollen Vorlesungen abfragen dürfen
ON UPDATE CASCADE ON DELETE CASCADE,												#Wird eine Prüfung gelöscht/zurückgezogen, so wird der Umfang der Vorlesung nicht abgefragt -> also auch gelöscht / Updates werden übernommen  
CONSTRAINT umfasst_vorlesung FOREIGN KEY (VorlesungsID) REFERENCES Vorlesung(VorlesungsID)	#Nur Bestehende Vorlesungen sollen geprüft werden (angegebene VorlesungsID muss in Relation Vorlesung vorhanden sein)
ON UPDATE CASCADE ON DELETE NO ACTION														#Eine Vorlesung kann erst gelöscht werden, wenn es keine Prüfungen mehr dazu gibt
);

CREATE TABLE stellt(
PrüfungsID BIGINT,
Personalnummer_prof MEDIUMINT,
CONSTRAINT PK7 PRIMARY KEY (PrüfungsID, Personalnummer_prof),
CONSTRAINT stellt_prüfung FOREIGN KEY (PrüfungsID) REFERENCES PRÜFUNG(PrüfungsID)					#nur angebotene Prüfungen sollen gestellt/erstellt/betreut werden können (angegebene PrüfungsID muss in Relation Prüfung existieren)
ON UPDATE CASCADE ON DELETE CASCADE,																#wird eine Prüfung gelöscht, muss sie von keinem Professor mehr gestellt werden.
CONSTRAINT stellt_prof FOREIGN KEY (Personalnummer_prof) REFERENCES Professor(Personalnummer_prof)	#nur Existierende Professoren sollen Prüfungen stellen/betreuen können
ON DELETE NO ACTION ON UPDATE CASCADE																#Ein Professor kann erst gelöscht werden, wenn dieser keine Prüfungen mehr betreut, Updates wie Aktualisierung der Personalnummer sollen übernommen werden
);

CREATE VIEW SEKRETÄR_VIEW AS(																		#für die Sekretär_VIEW wird die Relation Vorlesung mit den Relationen Prüfung/umfasst & Tutorium gejoint
Select DISTINCT v.VorlesungsID, v.Raum as VorlesungsRaum, v.Beschreibung as Vorlesungsbeschreibung, 			#Distinct ist wichtig, damit die ausgewählten Attribute nur einmal dargestellt werden
v.Uhrzeit as VorlesungsUhrzeit, p.Datum as Prüfungsdatum, p.Raum as Prüfungsraum, p.Datum as PrüfungsZeit,
t.Raum as TutoriumRaum, t.Uhrzeit as TutoriumUhrzeit
From Vorlesung v 
INNER JOIN umfasst u on u.VorlesungsID=v.VorlesungsID
INNER JOIN Prüfung p on p.PrüfungsID=u.PrüfungsID
INNER JOIN Tutorium t on t.VorlesungID=v.VorlesungsID);



CREATE VIEW PROF_VIEW AS(																			#für die PROF_VIEW wird die Relation Vorlesung mit den Relationen umfasst/Prüfung/Tutorium/haelt/Tutor & Student gejoint
SELECT DISTINCT																				
v.VorlesungsID, v.Raum as VorlesungsRaum, v.Beschreibung as Vorlesungsbeschreibung, 
v.Uhrzeit as VorlesungsUhrzeit, p.Datum as Prüfungsdatum, p.Raum as Prüfungsraum, p.Datum as PrüfungsZeit,
tm.Raum as TutoriumRaum, tm.Uhrzeit as TutoriumUhrzeit, concat(s.vorname, s.nachname) as TutorName,
s.Matrikelnr
From Vorlesung v 
INNER JOIN umfasst u on u.VorlesungsID=v.VorlesungsID
INNER JOIN Prüfung p on p.PrüfungsID=u.PrüfungsID
INNER JOIN Tutorium tm on tm.VorlesungID=v.VorlesungsID
inner join haelt h on h.TutID = tm.TutID
inner join tutor tu on tu.tutnr = h.tutnr
inner join student s on s.matrikelnr = tu.tutnr #Nur Tutoren
); 

#SELECT * FROM PROF_VIEW;
#SELECT * FROM SEKRETÄR_VIEW;

														#-------------------------#
														#Tabellen mit Daten füllen
														#-------------------------#
                                                        
#Mitarbeiter----------------------------------------------------------------------------------------------------------------------
INSERT INTO Mitarbeiter
	Values(1,'Hans', 'Maier',DATE '1950.10.31',3000,'Am Stockplatz 30','Trier',20,54290);
INSERT INTO Mitarbeiter
	Values(2,'Anna','Kraus',DATE'1975.07.09',4900,'Alsterkrugchaussee 61','Puschendorf',31,90617);
INSERT INTO Mitarbeiter
	Values(3,'Heinz','Forster',DATE'1990.05.19',4100,'Rankestraße 62','Dietfurt',31,92345);
INSERT INTO Mitarbeiter
	Values(4,'Maria','Rolle',DATE'1936.02.06',2100,'Kurfuerstendamm 29','Trier',31,74076);
INSERT INTO Mitarbeiter
	Values(5,'Johanna','Köster',DATE'1989.01.01',4100,'An Der Urania 66','Pellworm',31,25846);
INSERT INTO Mitarbeiter
	Values(6,'Peter','Kraus',DATE'1967.11.21',4200,'Borstelmannsweg 18','Wernberg-Köblitz',31,92527);
INSERT INTO Mitarbeiter
	Values(7,'Katja','Klein',DATE'1981.03.18',5000,'Ziegelstr. 44','Triftern',31,84369);
INSERT INTO Mitarbeiter
	Values(8,'Sven','Bosch',DATE'1969.12.12',2100,'Karl-Liebknecht-Strasse 91','Hoyerhagen',31,27318);
INSERT INTO Mitarbeiter
	Values(9,'Jörg','Reinhard',DATE'1965.07.03',2100,'Hochstrasse 56','Dollerup',31,24989);
INSERT INTO Mitarbeiter
	Values(10,'Jana','Koertig',DATE'1987.03.12',2100,'Pappelallee 1','Thum',31,09416);
    
#Mensamitarbeiter-----------------------------------------------------------------------------------------------------------------
INSERT INTO Mensamitarbeiter
	Values(1,20);

#Sekretär-------------------------------------------------------------------------------------------------------------------------
INSERT INTO Sekretär
	Values(2,300);
INSERT INTO Sekretär
	Values(3,4000);    

#Professor------------------------------------------------------------------------------------------------------------------------
INSERT INTO Professor
	Values(4,'Wirtschaft',2);
INSERT INTO Professor
	Values(5,'Maschinenbau',2);
INSERT INTO Professor
	Values(6,'Ernährungswissenschaften',2);

#Assistenten----------------------------------------------------------------------------------------------------------------------
INSERT INTO Assistent
	VALUES(7,'Wirtschaft',4);
INSERT INTO Assistent
	VALUES(8,'Maschinenbau',5);
INSERT INTO Assistent
	VALUES(9,'Ernährungswissenschaften',6);
INSERT INTO Assistent
	VALUES(10,'Wirtschaft',NULL);

#Student--------------------------------------------------------------------------------------------------------------------------
INSERT INTO Student
	VALUES(965415,'Peter','Müller', 60, DATE'1996.10.31',DATE'2017.01.31','Hauptstrasse 12','Pluwig',54317);
INSERT INTO Student
	VALUES(003220,'Katharina','Nussbaum', 10, DATE'2000.12.3',DATE'2017.01.24','Schlossallee 1','Kaiserslautern',66862);
INSERT INTO Student
	VALUES(905201,'Dennis','Schultheiss', 90, DATE'1990.12.13',DATE'2013.06.14','Hoheluftchaussee 36','Gößnitz',04637);
INSERT INTO Student
	VALUES(982455,'Birgit','Dreher', 75, DATE'1998.03.24',DATE'2020.01.01','Fugger Strasse 42','Borken',46325);
INSERT INTO Student
	VALUES(925999,'René','Gottlieb', 60, DATE'1992.07.15',DATE'2015.04.01','Esplanade 88','Geiselhöring',94333);
INSERT INTO Student
	VALUES(993934,'Patrick','Goldschmidt', 180, DATE'1999.09.11',DATE'2019.11.03','Flotowstr. 44','Lutherstadt Wittenberg',06878 );
INSERT INTO Student
	VALUES(988532,'Lukas','Berger', 72, DATE'1998.03.03',DATE'2014.07.04','Landhausstraße 84','Schwedt',16294);
INSERT INTO Student
	VALUES(999823,'Diana','Eichmann', 100, DATE'1999.12.31',DATE'2018.05.23','Gruenauer Strasse 19','Oldendorf',21726);
INSERT INTO Student
	VALUES(999832,'Max','Holtzmann', 0, DATE'1999.01.01',DATE'2016.01.02','Sömmeringstr. 92','Vöhringen',89265);
INSERT INTO Student
	VALUES(939871,'Vanessa','Papst', 0, DATE'1993.08.06',DATE'2013.09.12','Brandenburgische Str. 12','Wannweil',72827);
INSERT INTO Student
	VALUES(969812,'Dieter','Schwarz', 75, DATE'1996.11.11',DATE'2014.05.23','Adenauerallee 97','Altenhof',16244);
INSERT INTO Student
	VALUES(951298,'Michelle','Hofmann', 20, DATE'1995.02.22',DATE'2012.08.21','Schoenebergerstrasse 24','Schönberg',84573);
    
#Tutor----------------------------------------------------------------------------------------------------------------------------
INSERT INTO Tutor
	VALUES(951298,'Wirtschaft','Grundlagen der BWL Tutorium',1200);
INSERT INTO Tutor
	VALUES(939871,'Maschinenbau','Statistik',1200);

#Semester-------------------------------------------------------------------------------------------------------------------------
INSERT INTO Semester
	VALUES('WS19',DATE'2019.09.30',DATE'2020.01.25');
INSERT INTO Semester
	VALUES('SS20',DATE'2020.01.03',DATE'2020.08.31');
INSERT INTO Semester
	VALUES('WS20',DATE'2020.09.01',DATE'2020.02.29');

#Vorlesung------------------------------------------------------------------------------------------------------------------------
INSERT INTO Vorlesung (Beschreibung, Semester, Raum, Wochentag, Uhrzeit)
	VALUES
	('Datenbanken','WS19','L103','Dienstag','10:30'),
	('Grundlagen Buchführung und BWL','WS19','L103','Mittwoch','11:30'),
	('Statistik','WS19','HS2','Montag','8:00'),
	('Clientseitige Internettechnologie','WS19','L103','Dienstag','19:30'),
	('Mathematik','WS19','K04','Freitag','09:30'),
	('CMS','WS19','L103','Donnerstag','14:00'),
	('Kalkulation und Kontrolle','WS19','HS3','Montag','9:40'),
	('Programmierung','WS19','X22','Freitag','15:30'),
	('Grundlagen der Programmierung','WS19','X23','Dienstag','09:40');

#Tutorium-------------------------------------------------------------------------------------------------------------------------
INSERT INTO Tutorium (VorlesungID, Semester, Raum, Uhrzeit, Wochentag)
	VALUES
		(1,'WS19','HS1','15:30','Mittwoch'),
		(5,'WS19','HS1','11:30','Donnerstag'),
		(9,'WS19','HS1','9:40','Freitag'),
		(8,'WS19','HS1','8:40','Montag');
    
#Prüfung---------------------------------------------------------------------------------------------------------------------------
INSERT INTO Prüfung (Matrikelnr, Semester, Raum, Note, Datum)
	VALUES
    (939871,'WS19','Aula',NULL,'2020.02.28 9:40'),
	(939871,'WS19','X22',2.3,'2020.01.31 13:00'),
	(939871,'WS19','L3',NULL,'2020.03.15 15:30'),
    (905201,'WS19','L3',NULL,'2020.03.15 15:30'),
    (905201,'WS19','L3',NULL,'2020.03.15 15:30');
   
														#----------------------------------------------#
														#Verknüpfen der Daten über Beziehungsrelationen
														#----------------------------------------------#
#hoert-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO hoert						#Welcher Student hoert welche Vorlesung
	VALUES(1,965415);					# Bsp: Vorlesung 1 also Datenbanken wird von Matrikelnr 965415 also Peter Müller gehört
INSERT INTO hoert
	VALUES(2,965415);
INSERT INTO hoert
	VALUES(4,965415);
INSERT INTO hoert
	VALUES(6,965415);
INSERT INTO hoert
	VALUES(1,999832);
INSERT INTO hoert
	VALUES(2,969812);
INSERT INTO hoert
	VALUES(1,969812);
INSERT INTO hoert
	VALUES(2,905201);
INSERT INTO hoert
	VALUES(2,951298);
INSERT INTO hoert						
	VALUES(9,939871);					
INSERT INTO hoert
	VALUES(9,925999);
INSERT INTO hoert
	VALUES(3,993934);
INSERT INTO hoert
	VALUES(8,939871);
INSERT INTO hoert
	VALUES(4,925999);
INSERT INTO hoert
	VALUES(6,993934);
INSERT INTO hoert
	VALUES(7,993934);
INSERT INTO hoert
	VALUES(6,905201);
INSERT INTO hoert
	VALUES(7,925999);
    
#ließt_vor-------------------------------------------------------------------------------------------------------------------------
INSERT INTO ließt_vor			#Welcher Professor ließt welche Vorlesung?
	VALUES(4,5);				#Bsp: die Vorlesung 4 Clientseitige Internettechnologie wird vom Professor mit der der Mitarbeiternummer 5, also Johanna Köster gelesen
INSERT INTO ließt_vor			#Die Vorlesung Clientseitige Internettechnologie kann auch von 2 Professoren gelesen werden
	VALUES(4,4);
INSERT INTO ließt_vor
	VALUES(9,5);
INSERT INTO ließt_vor
	VALUES(8,6);
INSERT INTO ließt_vor
	VALUES(7,6);
INSERT INTO ließt_vor
	VALUES(6,6);
INSERT INTO ließt_vor
	VALUES(5,4);
INSERT INTO ließt_vor
	VALUES(3,4);
INSERT INTO ließt_vor
	VALUES(2,5);
INSERT INTO ließt_vor
	VALUES(1,5);
    
#nimmt_teil------------------------------------------------------------------------------------------------------------------------
INSERT INTO nimmt_teil						#Welches Tutorium wird von welchem Studenten besucht?
	VALUES(965415,1);						#Matrikelnr 965415, also Peter Müller nimmt am Tutorium 1, das sich auf die Vorlesung 1, Datenbanken, bezieht, teil
INSERT INTO nimmt_teil						#Natürlich können sich auch Tutoren in Tutorien teilnehmen, da sie selbst Studenten sind (Subtyp)
	VALUES(951298,2);						#Bsp: Die Studentin Michelle Hofmann mit der Matrikelnr 951298 (Tutor) nimmt im Tutorium 2 teil, dass sich auf die Vorlesung 5, Mathematik bezieht
INSERT INTO nimmt_teil
	VALUES(969812,3);
INSERT INTO nimmt_teil
	VALUES(965415,4);
INSERT INTO nimmt_teil
	VALUES(969812,1);
INSERT INTO nimmt_teil
	VALUES(965415,2);
INSERT INTO nimmt_teil
	VALUES(925999,3);
INSERT INTO nimmt_teil
	VALUES(925999,4);
INSERT INTO nimmt_teil
	VALUES(999832,4);

#arbeitet_fuer---------------------------------------------------------------------------------------------------------------------
INSERT INTO arbeitet_fuer					#Für welche Professoren arbeiten welche Tutoren. Es können mehrere Tutoren für einen Professor arbeiten und ein Tutoren kann bei mehreren Professoren angestellt sein
	VALUES(951298,4);
INSERT INTO arbeitet_fuer					#Vanessa Paps (Matrikelnr 939871) arbeitet für den Professor mit der Mitarbeiternummer 5 (Johanna Köster)
	VALUES(939871,5);
INSERT INTO arbeitet_fuer
	VALUES(951298,6);
INSERT INTO arbeitet_fuer
	VALUES(939871,4);
    
#haelt-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO haelt							#Welcher Tutor haelt welches Tutorium?
	VALUES(951298,1);						
INSERT INTO haelt
	VALUES(951298,2);						#Bsp: Michelle Hofmann 951298 hält das Tutorium 2, welches sich auf die Vorlesung 5, also Mathematik bezieht.
INSERT INTO haelt
	VALUES(939871,3);
INSERT INTO haelt
	VALUES(939871,4);
INSERT INTO haelt							#Mehrere Tutoren können das gleiche Tutorium halten
	VALUES(939871,2);

#umfasst---------------------------------------------------------------------------------------------------------------------------
INSERT INTO umfasst							#Welche Vorlesung wird mit welcher PrüfungsID abgefragt/ Welche Vorlesung umfasst die Prüfung?
	VALUES(1,3);							#Bsp: Die Prüfungsanmeldung 1, des Studenten 939871 (Vanessa Papst) umfasst die Vorlesung 3, also Statistik
INSERT INTO umfasst
	VALUES(2,9);
INSERT INTO umfasst
	VALUES(3,6);
INSERT INTO umfasst							#dabei ist es möglich, dass eine Klausur/Prüfung mehrere Vorlesungen umfasst!
	VALUES(3,7);

#stellt----------------------------------------------------------------------------------------------------------------------------
INSERT INTO stellt							#Welche Prüfung wird von welchem Professor gestellt/betreut?
	VALUES(1,4);							
INSERT INTO stellt
	VALUES(2,4);							#Die Prüfung mit der PrüfungsID 2, umfasst die Vorlesung 9 (Grundlagen der Programmierung), und wird von Professor Maria Rolle (Mirarbeiternr 4) gestellt
INSERT INTO stellt							#Dabei ist es möglich, dass eine Klausur von mehreren Professoren gestellt wird und ein Professor meherer Klausuren stellt
	VALUES(3,6);							
INSERT INTO stellt
	VALUES(3,5);

###############################################################DELETE##############################################################

			#---------------------------------------STUDENT---------------------------------------------------#
#Stundent löschen (immer möglich) Matrikelnr wird gelöscht in:

					#Student
					#nimmt_teil
					#hoert
					#Prüfung
					#umfasst (Prüfung wird gelöscht -> aus umfasst wird der Inhalt der Prüfung gelöscht)
			#Falls Tutor
					#Tutor
                    #arbeitet fuer
                    #haelt
                    
			#---------------------------------------MITARBEITER---------------------------------------------------#                   
#Mitarbeiter löschen (nicht immer möglich) Personalnummer wird gelöscht in:

			#Falls Mensamitarbeiter/Assistent
					#Mitarbeiter
					#Mensamitarbeiter/Assistent
                    
			#Falls Sekretäre (Sekretär darf keinen Professor mehr betreuen!)
					#Mitarbeiter
                    #UPDATE in Professor
                    #UPDATE 
                    #CODE Professor SET Personalnummer_sek = 3 Where Personalnummer_prof = 4;
                    
			#Falls Professor (Prof darf keine Prüfung mehr stellen (stellt) und keine Vorlesungen mehr halten (ließt_vor)
					#Assistent (SET NULL)
                    #stellt
                    #ließt vor
                    #arbeitet für
                    #CODE 	 delete from ließt_vor where personalnummer_prof = 4;
							#delete from stellt where personalnummer_prof = 4;
							#delete from Professor where personalnummer_prof = 4;
                    

			#--------------------------------------------Vorlesung---------------------------------------------------#
#Vorlesung löschen (nur wenn es keine Prüfungen mehr dazu gibt (umfasst)) VorlesungsID wird gelöscht in:

					#Vorlesung
					#umfasst
					#ließt_vor
					#Tutorium
                    #hoert
			#-------------------------------------------Semester-----------------------------------------------------#
#Semester löschen (nur möglich wenn im Semester keine Vorlesung/Prüfung/Tutorium mehr existiert) Bezeichnung/Semester gelöscht in:
					#Vorlesung
					#Tutorium
                    #Prüfung
			#-----------------------------------------------Rest-----------------------------------------------------#
#Prüfung löschen (durch Student jederzeit möglich)
#Tutorium löschen (jederzeit möglich)


#Name: Julian Pretzsch
#Matrikelnr: ------