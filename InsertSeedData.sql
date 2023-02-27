
-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █         Utilisation de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE Consumerism
GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █     Insertion de données dans les tables     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

EXEC sp_set_session_context 'max', 100
GO

-- obtient le nombre de rangees d'une table
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

-- Math.max()
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
GO

