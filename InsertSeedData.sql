
-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     Insertion de données dans les tables     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

-- global variable for max number of generated data
EXEC sp_set_session_context 'max', 100
GO

-- obtient le nombre de rangees d'une table
IF OBJECT_ID('dbo.TABLESIZE') IS NOT NULL
  DROP FUNCTION dbo.TABLESIZE
GO

CREATE FUNCTION dbo.TABLESIZE(@tableName NVARCHAR(128))
RETURNS INT
AS
BEGIN
      DECLARE @count INT = (
            SELECT SUM([rows])
            FROM sys.partitions
            WHERE object_id=object_id(@tableName)
            AND index_id IN (0,1))
      RETURN @count
END
GO

-- equivalent de Math.max() en sql server
IF OBJECT_ID('dbo.MAX') IS NOT NULL
  DROP FUNCTION dbo.MAX
GO

CREATE FUNCTION dbo.MAX(@a INT, @b INT)
RETURNS INT
AS
BEGIN
      RETURN (SELECT 0.5 * ((@a + @b) + ABS(@a - @b)) )
END
GO

-- demand.bozo
DECLARE @i INT = dbo.TABLESIZE(N'Demand.Bozo')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Demand.Bozo
      VALUES (
            'FirstName ' + LTRIM(@i), 
            'LastName ' + LTRIM(@i), 
            'Nickname ' + LTRIM(@i), 
            RAND() * 100
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des BOZOS terminée.'
GO

-- offer.enterprise
DECLARE @i INT = dbo.TABLESIZE(N'Offer.Enterprise')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Offer.Enterprise
      VALUES (
            'Name ' + LTRIM(@i), 
            DATEADD(DAY, RAND() * 1000, '2000-01-01')
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des ENTREPRISES terminée.'
GO

-- offer.contract
DECLARE @i INT = dbo.TABLESIZE(N'Offer.Contract')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Offer.Contract
      VALUES (
            'Description ' + LTRIM(@i), 
            RAND() * 100, 
            dbo.MAX(1, RAND() * @max),
            dbo.MAX(1, RAND() * @max)
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des CONTRATS terminée.'
GO

-- offer.production
DECLARE @i INT = dbo.TABLESIZE(N'Offer.Production')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Offer.Production
      VALUES (
            DATEADD(DAY, RAND() * 1000, '2000-01-01T00:00:00'),
            RAND() * 100000, 
            dbo.MAX(1, RAND() * @max)
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des PRODUCTIONS terminée.'
GO

-- offer.product
DECLARE @i INT = dbo.TABLESIZE(N'Offer.Product')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Offer.Product
      VALUES (
            'Name ' + LTRIM(@i),
            (CASE WHEN RAND() < 0.5 THEN 1 ELSE 0 END),
            RAND() * 1000000, 
            RAND() * 100
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des PRODUITS terminée.'
GO

-- offer.productinstance
DECLARE @i INT = dbo.TABLESIZE(N'Offer.ProductInstance')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Offer.ProductInstance
      VALUES (
            dbo.MAX(1, RAND() * @max),
            dbo.MAX(1, RAND() * @max)
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des INSTANCES DE PRODUITS terminée.'
GO

-- demand.transaction
DECLARE @i INT = dbo.TABLESIZE(N'Demand.Transaction')
DECLARE @max INT = @i + CONVERT(INT, SESSION_CONTEXT(N'max'))
WHILE @i < @max
BEGIN
      INSERT INTO Demand.[Transaction]
      VALUES (
            DATEADD(DAY, RAND() * 1000, '2000-01-01'),
            RAND() * 1000000, 
            dbo.MAX(1, RAND() * @max),
            dbo.MAX(1, RAND() * @max),
            dbo.MAX(1, RAND() * @max)
      )      
      SET @i = @i + 1
END
PRINT 'Insertion des TRANSACTIONS terminée.'
GO

PRINT 'Nous avons généré ' + CONVERT(varchar(50), SESSION_CONTEXT(N'max')) + ' données par table.'

-- afficher les résultats
EXEC sp_MSForEachTable 'exec sp_spaceused [?]'