-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     5 requêtes dont une avec une sous-requête     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

-- Obtient la liste des entreprises 
-- dont les employes ont une honnetete moyenne superieure a 60
-- ============================================================
-- Name           AverageEmployeeHonesty
-- ------------------------------------------------------------
-- Dynabox	      70
-- Yoveo	      67
-- Skiba	      67
-- Lazz	      66
-- Dabshots	      65
-- Meevee	      63
-- Realpoint      62
-- Skinte	      62
-- Aibox	      62
-- Thoughtstorm   61
-- Roomm	      61
-- Zava	      61
-- Geba	      61

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

SELECT TOP 25 P.Name as 'Product Name', Amount as 'Valeur', Date
FROM Demand.[Transaction] AS T
INNER JOIN Offer.ProductInstance AS PI
ON T.ProductInstanceID = PI.ProductInstanceID
INNER JOIN Offer.Product AS P
ON PI.ProductID = P.ProductID
WHERE PI.ProductID IN (SELECT ProductID
           FROM Offer.Product as P
           WHERE P.IsService = 1
           AND P.BaseValue > 300000)
ORDER BY Date DESC