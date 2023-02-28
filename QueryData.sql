-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     5 requêtes dont une avec une sous-requête     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█



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