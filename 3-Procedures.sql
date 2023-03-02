-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Vue         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Transactions') IS NOT NULL
    DROP VIEW Transactions
GO

-- Obtient les details complets de toutes les transactions
CREATE VIEW Transactions AS
SELECT 
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
GO

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
FROM Transactions
ORDER BY [Est une arnaque], Date DESC



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Fonction scalaire         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 


-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Procedures stockees (2)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█




-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Triggers (2)        █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█