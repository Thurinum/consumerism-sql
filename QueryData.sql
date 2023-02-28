-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     5 requêtes dont une avec une sous-requête     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

SELECT E.Name, AVG(B.Honesty) AS AverageEmployeeHonesty
FROM Offer.Contract as C
INNER JOIN Demand.Bozo as B
ON C.EmployeeID = B.BozoID
INNER JOIN Offer.Enterprise as E
ON C.EnterpriseID = E.EnterpriseID
GROUP BY C.EnterpriseID, E.Name
HAVING AVG(B.Honesty) > 50
ORDER BY AVG(B.Honesty) DESC
GO

-- Obtient le nom, le prix, et la date de transaction des 10 premiers produits (s'il y en a) 
-- achetés de type service dont la valeur de base (sans taxes et frais de livraison)
-- est supérieure à 500 000$, triés par ordre décroissant de prix.
SELECT TOP 10 P.Name as 'Nom du produit', LTRIM(ROUND(Amount, 2)) + ' $' as 'Montant avec taxes', FORMAT(Date, 'yyyy-MM-dd à HH:mm:ss') as 'Date-heure transaction'
FROM Demand.[Transaction] AS T
INNER JOIN Offer.ProductInstance AS PI
ON T.ProductInstanceID = PI.ProductInstanceID
INNER JOIN Offer.Product AS P
ON PI.ProductID = P.ProductID
WHERE PI.ProductID IN (SELECT ProductID
           FROM Offer.Product as P
           WHERE P.IsService = 1
           AND P.BaseValue > 500000)
ORDER BY Amount DESC