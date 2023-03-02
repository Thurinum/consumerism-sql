-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Vue         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Top1000Transactions') IS NOT NULL
    DROP VIEW Top1000Transactions
GO

-- Obtient les details complets de toutes les Top1000Transactions
CREATE VIEW Top1000Transactions AS
SELECT TOP 1000
      T.TransactionID 
            AS TransactionID,
      T.Date
            AS TransactionDateTime, 
      
      Sender.BozoID
            AS SenderID,
      Sender.FirstName
            AS SenderFirstName,
      Sender.LastName
            AS SenderLastName,
      Sender.FirstName + ' ' + Sender.LastName
            AS SenderFullName,

      Receiver.BozoID
            AS ReceiverID,      
      Receiver.FirstName
            AS ReceiverFirstName,
      Receiver.LastName
            AS ReceiverLastName,
      Receiver.FirstName + ' ' + Receiver.LastName
            AS ReceiverFullName,

      P.Name
            AS ProductName, 
      P.BaseValue
            AS PriceWithoutTaxes,
      T.Amount
            AS PriceWithTaxes,
      P.IsService
            AS ProductIsService,
      P.Complexity
            AS ProductComplexity
FROM Demand.[Transaction] AS T
INNER JOIN Offer.ProductInstance AS PI
      ON T.ProductInstanceID = PI.ProductInstanceID
INNER JOIN Offer.Product AS P
      ON PI.ProductID = P.ProductID
INNER JOIN Demand.Bozo AS Sender
      ON T.SenderID = Sender.BozoID
INNER JOIN Demand.Bozo AS Receiver
      ON T.ReceiverID = Receiver.BozoID
WHERE T.Amount > 500000
ORDER BY T.Date DESC, T.Amount DESC
GO

-- Insert a fraudulent transaction
INSERT INTO Demand.[Transaction] (Date, SenderID, ReceiverID, ProductInstanceID, Amount)
VALUES (GETDATE(), 1, 1, 1, 690000.69)

-- Utilisation de la vue
SELECT 
      FORMAT(TransactionDateTime, 'dd MMMM yyyy')
            AS Date,
      (CASE WHEN ProductIsService = 1 THEN 'Service de ' ELSE '' END) + ProductName
            AS Produit,
      SenderFullName
            AS 'Acheté par',
      LTRIM(ROUND(PriceWithTaxes, 2)) + ' $'
            AS 'Prix, taxes incluses',
      (CASE WHEN SenderID = ReceiverID THEN 'Oui' ELSE 'Non' END)
            AS 'Est une arnaque'
FROM Top1000Transactions
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Fonction scalaire         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Offer.EnterprisesForProduct') IS NOT NULL
      DROP FUNCTION Offer.EnterprisesForProduct
GO

-- Obtient le nombre d'entreprises qui fabriquent un produit
CREATE FUNCTION Offer.EnterprisesForProduct(@ProductID INT)
RETURNS INT
AS
BEGIN
      RETURN 
      (
            SELECT COUNT(DISTINCT EnterpriseID)
            FROM Offer.Product as P
            INNER JOIN Offer.ProductInstance as PI
                  ON P.ProductID = PI.ProductID
            INNER JOIN Offer.Production as PR
                  ON PI.ProductionID = PR.ProductionID
            INNER JOIN Offer.Contract as C
                  ON PR.ContractID = C.ContractID
            WHERE P.ProductID = @ProductID
      )
END
GO

-- Liste de tous les produits et les entreprises qui les fabriquent
-- SELECT P.ProductID, C.EnterpriseID
-- FROM Offer.Product as P
-- INNER JOIN Offer.ProductInstance as PI
--       ON P.ProductID = PI.ProductID
-- INNER JOIN Offer.Production as PR
--       ON PI.ProductionID = PR.ProductionID
-- INNER JOIN Offer.Contract as C
--       ON PR.ContractID = C.ContractID
-- ORDER BY P.ProductID
-- GO

-- Test de la fonction scalaire (SELECT)
SELECT 
      P.ProductID AS 'ID du produit',
      P.Name AS 'Nom du produit',
      Offer.EnterprisesForProduct(P.ProductID) AS NbEnterprises
FROM Offer.Product AS P
WHERE Offer.EnterprisesForProduct(P.ProductID) > 0
GO

-- Test de la fonction scalaire (UPDATE)
ALTER TABLE Offer.Product
ADD Importance FLOAT
GO

UPDATE Offer.Product
SET Importance = 
      (CASE
            WHEN Offer.EnterprisesForProduct(ProductID) > 1 THEN 1
            WHEN Offer.EnterprisesForProduct(ProductID) = 1 THEN 0.5
            ELSE 0
      END) * Complexity / 100
WHERE Importance IS NULL
GO

SELECT P.Name, P.Importance
FROM Offer.Product AS P
GO

-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Procedures stockees (2)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Offer.GetProduct') IS NOT NULL
      DROP PROCEDURE Offer.GetProduct
GO

-- Obtient les details complets d'un produit
CREATE PROCEDURE Offer.GetProduct
      @ProductID INT
AS
BEGIN
      SELECT 
            P.ProductID,
            P.Name,
            P.BaseValue,
            P.IsService,
            P.Complexity
      FROM Offer.Product AS P
      WHERE P.ProductID = @ProductID
END
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Triggers (2)        █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█