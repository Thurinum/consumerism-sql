-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     5 requêtes dont une avec une sous-requête     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

-- DISAPPOINTING SALES
-- ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
-- Obtient le nom et le prix de tous les instances de produit
-- qui n'ont pas encore ete vendues, triés par ordre alphabétique du nom du produit.
SELECT 
      P.Name as 'Nom du produit', 
      LTRIM(ROUND(P.BaseValue, 2)) + ' $' as 'Prix du produit'
FROM Offer.ProductInstance AS PI
INNER JOIN Offer.Product AS P
ON PI.ProductID = P.ProductID
WHERE ProductInstanceID NOT IN (
      SELECT ProductInstanceID FROM Demand.[Transaction]
)
ORDER BY P.Name ASC

-- AIR TRAFFIC CONTROL
-- ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
-- Obtient les transactions effectuées entre le 11 septembre 2001 et le 11 mai 2011,
-- triées par ordre croissant de date, ainsi que le montant de la transaction avec taxes,
-- le nom du produit acheté, et le nom du bozo qui a acheté le produit.
SELECT 
      FORMAT(T.Date, 'yyyy-MM-dd à HH:mm:ss') as 'Date-heure transaction', 
      P.Name as 'Nom du produit', 
      B.FirstName + ' ' + B.LastName AS 'Nom du bozo',
      LTRIM(ROUND(T.Amount, 2)) + ' $' as 'Montant avec taxes'
FROM Demand.[Transaction] AS T
INNER JOIN Offer.ProductInstance AS PI
      ON T.ProductInstanceID = PI.ProductInstanceID
INNER JOIN Offer.Product AS P
      ON PI.ProductID = P.ProductID
INNER JOIN Demand.Bozo AS B
      ON T.SenderID = B.BozoID
WHERE T.Date BETWEEN '2001-09-11' AND '2011-05-11'
ORDER BY T.Date DESC
GO

-- PRIORITIES FIRST
-- ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
-- Obtient la liste des contrats dont l'importance est supérieure à 80,
-- triés par ordre décroissant de cette importance, ainsi que du bozo qui
-- est responsable de ce contrat.

-- NOTE: Il est possible qu'il n'y ait aucun contrat dont l'importance est supérieure à 80.
SELECT 
      C.[Description] AS 'Nom du contrat', 
      C.Importance AS 'Importance du contrat',
      B.FirstName + ' ' + B.LastName AS 'Nom du responsable'
FROM Offer.Contract AS C
INNER JOIN Demand.Bozo AS B
      ON C.EmployeeID = B.BozoID
WHERE C.Importance > 80
ORDER BY C.Importance DESC
GO

-- LE GRAIN DE L'IVRAIE
-- ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
-- Obtient le nom des entreprises dont l'honnêteté moyenne des employés est supérieure à 50,
-- triées par ordre décroissant de cette honnêteté moyenne.

-- NOTE: Il est possible que cette requête ne retourne aucun résultat si les données de test
--       ne contiennent pas d'employés honnêtes. Dans ce cas désolant, il suffit de changer
--       la valeur 50 à une valeur plus basse.
SELECT 
      E.Name as 'Nom de l''entreprise', 
      AVG(B.Honesty) AS 'Honnêteté moyenne des employés'
FROM Offer.Contract as C
INNER JOIN Demand.Bozo as B
      ON C.EmployeeID = B.BozoID
INNER JOIN Offer.Enterprise as E
      ON C.EnterpriseID = E.EnterpriseID
GROUP BY C.EnterpriseID, E.Name
HAVING AVG(B.Honesty) > 50
ORDER BY AVG(B.Honesty) DESC
GO

-- MARKET LAWS
-- ▀▀▀▀▀▀▀▀▀▀▀
-- Obtient le nom, le prix, et la date de transaction des 10 premiers produits 
-- achetés n'étant pas un service dont la valeur de base (sans taxes et frais de livraison)
-- est supérieure à 500 000$, triés par ordre décroissant de prix.

-- NOTE: Il est possible qu'il y ait moins de 10 produits qui correspondent à ces critères.
SELECT TOP 10 
      P.Name as 'Nom du produit', 
      LTRIM(ROUND(Amount, 2)) + ' $' as 'Montant avec taxes', 
      FORMAT(Date, 'yyyy-MM-dd à HH:mm:ss') as 'Date-heure transaction'
FROM Demand.[Transaction] AS T
INNER JOIN Offer.ProductInstance AS PI
      ON T.ProductInstanceID = PI.ProductInstanceID
INNER JOIN Offer.Product AS P
      ON PI.ProductID = P.ProductID
WHERE PI.ProductID IN (SELECT ProductID
           FROM Offer.Product as P
           WHERE P.IsService = 0
           AND P.BaseValue > 500000)
ORDER BY Amount DESC
GO