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



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Test de la fonction scalaire (SELECT)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

SELECT 
      P.ProductID AS 'ID du produit',
      P.Name AS 'Nom du produit',
      Offer.EnterprisesForProduct(P.ProductID) AS NbEnterprises
FROM Offer.Product AS P
WHERE Offer.EnterprisesForProduct(P.ProductID) > 0
GO 



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Test de la fonction scalaire (DELETE, fails)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

-- Ajoute une instance d'un produit pour qu'il soit fabriqué par au moins une entreprise
INSERT INTO Offer.ProductInstance (ProductID, ProductionID)
VALUES (1, 1)
GO

SELECT ProductID AS "Devrait être 1"
FROM Offer.Product
WHERE ProductID = 1
GO

-- Essaie de supprimer le produit
DELETE FROM Offer.Product
WHERE ProductID = 1
AND Offer.EnterprisesForProduct(ProductID) = 0
GO

-- Doit avoir échoué car le produit est fabriqué par au moins une entreprise
SELECT ProductID AS "Devrait être 1"
FROM Offer.Product
WHERE ProductID = 1
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Test de la fonction scalaire (DELETE, success)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

-- Ajoute un produit qui n'est fabriqué par aucune entreprise
INSERT INTO Offer.Product
VALUES ('Test', 0, 0, 0)
GO

-- Obtient l'ID du produit ajouté
DECLARE @ProductID INT = (SELECT SCOPE_IDENTITY())

SELECT ProductID AS 'Devrait être rempli'
FROM Offer.Product
WHERE ProductID = @ProductID

-- Essaie de supprimer le produit
DELETE FROM Offer.Product
WHERE ProductID = @ProductID
AND Offer.EnterprisesForProduct(ProductID) = 0

-- Doit avoir réussi car le produit n'est fabriqué par aucune entreprise
SELECT ProductID AS "Devrait être vide"
FROM Offer.Product
WHERE ProductID = @ProductID
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Procédure stockée (requête générique)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Offer.GetProducts') IS NOT NULL
      DROP PROCEDURE Offer.GetProducts
GO

-- Obtient les details d'un produit
CREATE PROCEDURE Offer.GetProducts
      @MinValue MONEY = 0,
	@MaxValue MONEY = 999999999999.99,
	@MinComplexity INT = 0,
	@MaxComplexity INT = 100,
	@MinEnterprises INT = 0,
	@MaxEnterprises INT = 2147483647,
	@IsService BIT = NULL
AS
BEGIN
      SELECT 
            P.ProductID,
            P.Name,
            P.BaseValue,
            P.IsService,
            P.Complexity
      FROM Offer.Product AS P
      WHERE
		P.BaseValue 
			BETWEEN @MinValue AND @MaxValue
		AND P.Complexity 
			BETWEEN @MinComplexity AND @MaxComplexity
		AND Offer.EnterprisesForProduct(P.ProductID) 
			BETWEEN @MinEnterprises AND @MaxEnterprises
		AND (@IsService 
			IS NULL OR P.IsService = @IsService)
END
GO

-- Obtient les produits qui ont une valeur comprise entre 50 000$ et 1000$
EXEC Offer.GetProducts 
	@MinValue = 600000, 
	@MinComplexity = 10, 
	@MaxComplexity = 50, 
	@MinEnterprises = 1
	-- @IsService = 0
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Procédure stockée (intervalle de dates)         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

IF OBJECT_ID('Demand.GetTransactions') IS NOT NULL
      DROP PROCEDURE Demand.GetTransactions
GO

-- Obtient les details de transactions
CREATE PROCEDURE Demand.GetTransactions
	@BuyerNameLike VARCHAR(50) = NULL,
      @MinDate DATETIME = '1900-01-01',
	@MaxDate DATETIME = '9999-12-31',
	@MinAmount MONEY = 0,
	@MaxAmount MONEY = 999999999999.99
AS
BEGIN
	SELECT *
	FROM Top1000Transactions
	WHERE
		TransactionDateTime BETWEEN @MinDate AND @MaxDate
		AND PriceWithTaxes BETWEEN @MinAmount AND @MaxAmount
		AND (@BuyerNameLike 
			IS NULL OR SenderFullName LIKE @BuyerNameLike)
	ORDER BY TransactionDateTime DESC
END
GO

-- Obtient les transactions effectuées par des bozos dont le nom commence par
-- les lettres A,L,J,M,S,D,C et qui ont eu lieu entre le 1er janvier 2014 et 
-- le 31 décembre 2018.
EXEC Demand.GetTransactions
	@BuyerNameLike = '[A,L,J,M,S,D,C]%',
	@MinDate = '2014-01-01',
	@MaxDate = '2018-12-31'
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Triggers (2)        █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█