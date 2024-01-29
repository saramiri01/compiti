

CREATE DATABASE Modulo
USE Modulo

CREATE TABLE Prodotto(
IDProdotto INT,
NomeProdotto VARCHAR (50),
Categoria VARCHAR (50),
Prezzo DECIMAL (10,2),
ProdottoFinito BIT,
Disponibilità BIT, 
CONSTRAINT Pk_IDProdotto PRIMARY KEY (IDProdotto)
)

INSERT INTO Prodotto 
VALUES
(1, 'Barbie', 'Bambola', 9, 1, 1),
(2, 'Tombola', 'Svago', 15, 1, 1),
(3, 'Lego', 'Svago', 60, 1, 0),
(4, 'Carte UNO', 'Carte', 5, 1, 1),
(5, 'Risiko', 'Gioco da tavola', 30, 1, 0 ),
(6, 'XBOX', 'Console', 400, 0, 1)

CREATE TABLE Regione (
IDRegione INT,
NomeRegione VARCHAR (50),
Stato VARCHAR (50),
CONSTRAINT Pk_IDRegione PRIMARY KEY (IDRegione)
);

INSERT INTO Regione
VALUES 
(01, 'Europa', 'Francia'),
(02, 'Asia', 'India'),
(03, 'Europa', 'Svizzera'),
(04, 'Africa', 'Egitto'),
(05, 'NordAmerica', 'USA'),
(06, 'Asia', ' Russia')


CREATE TABLE Vendite (
IDVendite INT,
IDProdotto INT,
IDRegione INT,
DataVendita DATE,
Quantità INT,
ImportoVendite DECIMAL(10,2),
CONSTRAINT Pk_IDVendite PRIMARY KEY (IDVendite),
CONSTRAINT Fk_IDProdotto FOREIGN KEY (IDProdotto) REFERENCES Prodotto (IDProdotto),
CONSTRAINT Fk_IDRegione FOREIGN KEY (IDRegione) REFERENCES Regione (IDRegione)
);
 


 INSERT INTO Vendite 
 VALUES 
 (001, 1, 01, '12-06-2022', 60, 140),
 (002, 2, 02, '04-08-2022', 72, 320),
 (003, 3, 03, '15-12-2023', 23, 260),
 (004, 4, 04, '10-05-2022', 35, 170),
 (005, 5, 05, '26-02-2021', 18, 280),
 (006, 6, 06, '07-09-2023', 49, 129);

 --Richiesta 1: Verificare che i campi definiti come PK siano univoci. In altre parole, scrivi una query per determinare l’univocità dei valori di ciascuna PK (una query per tabella implementata).

 SELECT COUNT(*)IDProdotto
 FROM Prodotto
 GROUP BY IDProdotto
 HAVING COUNT(*) >1;


 SELECT COUNT(*)IDRegione
 FROM Regione
 GROUP BY IDRegione
 HAVING COUNT(*) >1;


 SELECT COUNT(*)IDVendite
 FROM Vendite
 GROUP BY IDVendite
 HAVING COUNT(*) >1;

 --Richiesta2: Esporre l’elenco delle transazioni indicando nel result set il codice documento, la data, il nome del prodotto, la categoria del prodotto, il nome dello stato, il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati più di 180 giorni dalla data vendita o meno (>180 -> True, <= 180 -> False)

 SELECT v.IDVendite AS CodiceDocumento,
        v.DataVendita AS DataV,
		p.NomeProdotto,
		p.Categoria,
		r.Stato,
		r.NomeRegione,
 CASE WHEN DATEDIFF(DAY, v.DataVendita,GETDATE())> 180 THEN 'TRUE' ELSE 'FALSE' END AS Passati180Giorni
 FROM Vendite AS v
 INNER JOIN Prodotto AS p 
 ON v.IDProdotto=p.IDProdotto
 INNER JOIN Regione AS r 
 ON v.IDRegione=r.IDRegione;


--Richiesta3: Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno. 

SELECT   p.IDProdotto, 
         p.NomeProdotto,
         YEAR (v.DataVendita) AS AnnoVendita,
         SUM (p.Prezzo * V.Quantità) AS FatturatoTot
FROM Prodotto AS P
INNER JOIN Vendite AS v
ON p.IDProdotto=v.IDProdotto
GROUP BY YEAR (v.DataVendita),
         p.IDProdotto,
         p.NomeProdotto;

--Richiesta4: Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.

SELECT   p.IDProdotto,
         r.Stato,
         YEAR (v.DataVendita) AS Anno,
         SUM (p.Prezzo * V.Quantità) AS FatturatoTot
FROM Prodotto AS P
INNER JOIN Vendite AS v
ON p.IDProdotto = v.IDProdotto
INNER JOIN Regione AS r
ON v.IDRegione=r.IDRegione
GROUP BY  p.IDProdotto,
          r.Stato,
          YEAR (v.DataVendita)
ORDER BY Anno DESC,
         FatturatoTot DESC;

--Richiesta 5: Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?
 
 SELECT MAX(Categoria) AS MaggiorRichiesta
 FROM Prodotto AS p

 --Richiesta 6: Rispondere alla seguente domanda: quali sono, se ci sono, i prodotti invenduti? Proponi due approcci risolutivi differenti.
 --1)
 SELECT NomeProdotto,
        ProdottoFinito
 FROM Prodotto
 WHERE ProdottoFinito = 0
 --2)
SELECT NomeProdotto,
       ProdottoFinito,
CASE WHEN ProdottoFinito=0 THEN 'NON VENDUTO'
ELSE 'VENDUTO' END AS StatoVendita
FROM Prodotto;

--Richiesta 7: Esporre l’elenco dei prodotti cona la rispettiva ultima data di vendita (la data di vendita più recente).
 
 SELECT  NomeProdotto,
         MAX(DataVendita) AS DataVRecente
 FROM Vendite AS v 
 INNER JOIN Prodotto AS P 
 ON v.IDProdotto=p.IDProdotto
 GROUP BY p.NomeProdotto

--Richiesta 8: Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni utili (codice prodotto, nome prodotto, nome categoria)

CREATE VIEW VW_SA_Prodotto AS (
SELECT IDProdotto,
       NomeProdotto,
	   Categoria
FROM Prodotto)

SELECT*
FROM VW_SA_Prodotto

--Richiesta 9: Creare una vista per restituire una versione “denormalizzata” delle informazioni geografiche

CREATE VIEW VW_SA_InfoGeografiche AS (
SELECT r.IDRegione,
       p.NomeProdotto,
       r.NomeRegione,
       r.Stato,
	   v.DataVendita
FROM Regione AS r
INNER JOIN Vendite AS v
ON r.IDRegione=v.IDRegione
INNER JOIN Prodotto AS p
ON p.IDProdotto=v.IDProdotto
GROUP BY r.IDRegione,
       p.NomeProdotto,
	   r.NomeRegione,
       r.Stato,
	   v.DataVendita);

SELECT*
FROM VW_SA_InfoGeografiche 

--Richiesta 10
CREATE VIEW VW_SA_Vendite AS(
SELECT v.IDRegione,
       v.IDVendite,
       p.IDProdotto,
       p.NomeProdotto,
	   v.DataVendita,
	   SUM (p.Prezzo * V.Quantità) AS FatturatoTot
FROM Vendite AS v
INNER JOIN Prodotto AS p
ON v.IDProdotto=p.IDProdotto 
GROUP BY v.IDRegione,
         v.IDVendite,
		 p.IDProdotto,
         p.NomeProdotto,
		 v.DataVendita);

SELECT*
FROM VW_SA_Vendite


