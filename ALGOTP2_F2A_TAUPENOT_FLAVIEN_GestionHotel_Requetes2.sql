/*Classement des clients par nomre d'occupations*/
SELECT TCLIENT.CLI_ID, CLI_NOM, CLI_PRENOM, TIT_CODE, CLI_ENSEIGNE, count(TJCHBPLNCLI.CLI_ID)
FROM TCLIENT, TJCHBPLNCLI
WHERE TCLIENT.CLI_ID=TJCHBPLNCLI.CLI_ID
GROUP BY TJCHBPLNCLI.CLI_ID
ORDER BY count(TJCHBPLNCLI.CLI_ID) desc

/*classement des clients par montant dépensé dans l'hôtel*/
SELECT TCLIENT.CLI_ID, CLI_NOM, CLI_PRENOM, TIT_CODE, CLI_ENSEIGNE, sum(LIF_MONTANT*LIF_QTE)
FROM TCLIENT, TFACTURE, TLIGNEFACTURE
WHERE TCLIENT.CLI_ID=TFACTURE.CLI_ID AND TFACTURE.FAC_ID=TLIGNEFACTURE.FAC_ID
GROUP BY TFACTURE.CLI_ID
ORDER BY sum(LIF_MONTANT*LIF_QTE) desc

/*classement des occupations par mois*/
SELECT strftime('%m',PLN_JOUR) as Mois, count(CHB_ID)
FROM TJCHBPLNCLI
GROUP BY strftime('%m',PLN_JOUR)
ORDER BY count(CHB_ID) desc

/*classement des occupations par trimestre*/
SELECT cast((((strftime('%m',PLN_JOUR))-1)/3)+1 as int) as trimestre, count(CHB_ID)
FROM TJCHBPLNCLI
GROUP BY cast((((strftime('%m',PLN_JOUR))-1)/3)+1 as int)
ORDER BY count(CHB_ID) desc

/*montant TTC de chaque ligne de facture avec remises*/
SELECT LIF_ID, (((LIF_MONTANT*((LIF_TAUX_TVA+100.0)/100.0))*((100.0-(ifnull(LIF_REMISE_POURCENT,0.0)))/100.0)-ifnull(LIF_REMISE_MONTANT,0.0))*LIF_QTE) as 'Montant TTC'
FROM TLIGNEFACTURE

/*classement du montant TTC des factures avec remises*/
SELECT TFACTURE.FAC_ID, sum(((LIF_MONTANT*((LIF_TAUX_TVA+100.0)/100.0))*((100.0-(ifnull(LIF_REMISE_POURCENT,0.0)))/100.0)-ifnull(LIF_REMISE_MONTANT,0.0))*LIF_QTE) as 'Montant TTC'
FROM TFACTURE, TLIGNEFACTURE
WHERE TFACTURE.FAC_ID=TLIGNEFACTURE.FAC_ID
GROUP BY TFACTURE.FAC_ID
ORDER BY sum(((LIF_MONTANT*((LIF_TAUX_TVA+100.0)/100.0))*((100.0-(ifnull(LIF_REMISE_POURCENT,0.0)))/100.0)-ifnull(LIF_REMISE_MONTANT,0.0))*LIF_QTE) desc

/*tarif moyen des chambres par années croissantes*/
SELECT  strftime('%Y',TRF_DATE_DEBUT) as 'Année', avg(TRF_CHB_PRIX) as 'Tarif moyen chambre'
FROM TJTRFCHB
GROUP BY strftime('%Y',TRF_DATE_DEBUT)
ORDER BY strftime('%Y',TRF_DATE_DEBUT) asc

/*tarif moyen des chambres par étage et années croissantes*/
SELECT  strftime('%Y',TRF_DATE_DEBUT) as 'Année', CHB_ETAGE as 'Etage', avg(TRF_CHB_PRIX) as 'Tarif moyen chambre'
FROM TCHAMBRE, TJTRFCHB
WHERE TCHAMBRE.CHB_ID=TJTRFCHB.CHB_ID
GROUP BY CHB_ETAGE, strftime('%Y',TRF_DATE_DEBUT)
ORDER BY strftime('%Y',TRF_DATE_DEBUT) asc

/*chambre la plus cher et en quelle année*/
SELECT  strftime('%Y',TRF_DATE_DEBUT) as 'Année', CHB_ID as 'Chambre', TRF_CHB_PRIX as 'Prix'
FROM TJTRFCHB
where TRF_CHB_PRIX>=(select max(TRF_CHB_PRIX) from TJTRFCHB)

/*chambres réservées mais pas occupées*/
SELECT  CHB_ID, PLN_JOUR
FROM TJCHBPLNCLI
WHERE CHB_PLN_CLI_RESERVE=1 and CHB_PLN_CLI_OCCUPE=0

/*taux de résa par chambre*/
SELECT  CHB_ID, round((count(case when CHB_PLN_CLI_RESERVE = 1 then 1 else null end)*1.0/count(CHB_PLN_CLI_RESERVE)*100.0),2) as 'Taux de réservation'
FROM TJCHBPLNCLI
GROUP BY CHB_ID
ORDER BY (count(case when CHB_PLN_CLI_RESERVE = 1 then 1 else null end)*1.0/count(CHB_PLN_CLI_RESERVE)*1.0) desc

/*factures réglées avant leur édition*/
SELECT *
FROM TFACTURE
WHERE strftime(FAC_PMT_DATE)<=strftime(FAC_DATE) and ifnull(FAC_PMT_DATE,0)

/*par qui ces factures ont été payées*/
SELECT TCLIENT.CLI_ID, CLI_NOM, CLI_PRENOM
FROM TCLIENT, TFACTURE
WHERE TCLIENT.CLI_ID=TFACTURE.CLI_ID and strftime(FAC_PMT_DATE)<=strftime(FAC_DATE) and ifnull(FAC_PMT_DATE,0)

/*classement des modes de paiement par montant généré*/
SELECT PMT_CODE, round(sum(((LIF_MONTANT*((LIF_TAUX_TVA+100.0)/100.0))*((100.0-(ifnull(LIF_REMISE_POURCENT,0.0)))/100.0)-ifnull(LIF_REMISE_MONTANT,0.0))*LIF_QTE),2) as 'Montant généré'
FROM TFACTURE, TLIGNEFACTURE
WHERE TFACTURE.FAC_ID=TLIGNEFACTURE.FAC_ID and ifnull(FAC_PMT_DATE,0)
GROUP BY PMT_CODE
ORDER BY sum(((LIF_MONTANT*((LIF_TAUX_TVA+100.0)/100.0))*((100.0-(ifnull(LIF_REMISE_POURCENT,0.0)))/100.0)-ifnull(LIF_REMISE_MONTANT,0.0))*LIF_QTE) desc


/*Vous vous créez en tant que client*/
INSERT INTO TCLIENT (CLI_ID,CLI_NOM,CLI_PRENOM,TIT_CODE) VALUES (101,'TAUPENOT','F','M.')

/*Ne pas oublier les moyens de comm*/
INSERT INTO TADRESSE (ADR_ID,CLI_ID,ADR_LIGNE1,ADR_LIGNE2,ADR_CP,ADR_VILLE) VALUES (96,101,'5 rue Hannong','Appartement 1406',67000,'Strasbourg')
INSERT INTO TEMAIL (EML_ID,CLI_ID,EML_ADRESSE) VALUES (40,101,'flavien.taupenot@orange.fr')
INSERT INTO TTELEPHONE (TEL_ID,TYP_CODE,CLI_ID,TEL_NUMERO) VALUES (251,'TEL',101,'07-86-27-72-75')

/*créer une nouvelle chambre*/
INSERT INTO TCHAMBRE (CHB_ID,CHB_NUMERO,CHB_ETAGE,CHB_BAIN,CHB_DOUCHE,CHB_WC,CHB_COUCHAGE,CHB_POSTE_TEL) VALUES (21,22,'2e',1,1,1,3,121)
INSERT INTO TPLANNING (PLN_JOUR) VALUES ('2017-05-11')

/*3 occupants, prix 30% supérieur à la chambre la plus cher*/
INSERT INTO TJTRFCHB (CHB_ID,TRF_DATE_DEBUT,TRF_CHB_PRIX) VALUES (21,'2017-05-11',666)
INSERT INTO TJCHBPLNCLI (CLI_ID,CHB_ID,PLN_JOUR,CHB_PLN_CLI_NB_PERS,CHB_PLN_CLI_RESERVE,CHB_PLN_CLI_OCCUPE) VALUES (101,21,'2017-05-11',3,1,1)

/*facture réglée en CB*/
INSERT INTO TFACTURE (FAC_ID,CLI_ID,PMT_CODE,FAC_DATE,FAC_PMT_DATE) VALUES (2375,101,'CB','2017-05-11','2017-05-11')
INSERT INTO TLIGNEFACTURE (LIF_ID,FAC_ID,LIF_QTE,LIF_MONTANT,LIF_TAUX_TVA) VALUES (16791,2735,1,666,20.6)

/*édité pour rabais 10%*/
UPDATE TLIGNEFACTURE SET LIF_REMISE_POURCENT = 10 WHERE  LIF_ID = 16791