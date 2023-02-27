-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █          Création de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

USE master
GO

DROP DATABASE Consumerism
GO

CREATE DATABASE Consumerism
GO

USE Consumerism
GO


-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █          Création d'au moins deux schémas         █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█


CREATE SCHEMA Offer
GO

CREATE SCHEMA Demand
GO


-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █ Création des tables + contraintes (id, null?, pk) █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

CREATE TABLE Demand.Bozo
(
	BozoID	INT			NOT NULL		IDENTITY(1,1),
	FirstName	NVARCHAR(50)	NOT NULL,
	LastName	NVARCHAR(50)	NOT NULL,
	Nickname	VARCHAR(50)		NULL,			-- no weird characters in nickname
	Honesty	INT			NOT NULL,		-- CK
	
	CONSTRAINT 	PK_Bozo_BozoID 	PRIMARY KEY 	(BozoID)
)

CREATE TABLE Offer.Contract
(
	ContractID		INT				NOT NULL		IDENTITY(1,1),
	Description		NVARCHAR(75)		NOT NULL,
	Importance		INT				NOT NULL,		-- CK (>= 0, <= 100)
	EmployeeID		INT				NOT NULL,		-- FK
	EnterpriseID	INT				NOT NULL,		-- FK

	CONSTRAINT 	PK_Contract_ContractID 		PRIMARY KEY 	(ContractID),
)

CREATE TABLE Offer.Enterprise
(
	EnterpriseID		INT			NOT NULL		IDENTITY(1,1),
	Name				NVARCHAR(50)	NOT NULL,		-- UC
	ProductionInterval	DATETIME		NOT NULL, 

	CONSTRAINT 	PK_Enterprise_EnterpriseID 	PRIMARY KEY 	(EnterpriseID),
)

CREATE TABLE Offer.Production
(
	ProductionID	INT				NOT NULL		IDENTITY(1,1),
	Date			DATETIME			NOT NULL,
	Quantity		INT				NOT NULL,		-- CK (>= 0)
	ContractID		INT				NOT NULL,		-- FK

	CONSTRAINT 	PK_Production_ProductionID 	PRIMARY KEY 	(ProductionID),
)

CREATE TABLE Offer.ProductInstance
(
	ProductInstanceID		INT					NOT NULL		IDENTITY(1,1),
	ProductID			INT					NOT NULL,		-- FK
	ProductionID		INT					NOT NULL,		-- FK

	CONSTRAINT 	PK_ProductInstance_ProductInstanceID 	PRIMARY KEY 	(ProductInstanceID),
)

CREATE TABLE Demand.[Transaction]
(
	TransactionID		INT				NOT NULL		IDENTITY(1,1),
	Date				DATETIME			NOT NULL,
	Amount			MONEY				NOT NULL,		-- CK (>= 0)
	SenderID			INT				NOT NULL,		-- FK
	ReceiverID			INT				NOT NULL,		-- FK
	ProductInstanceID		INT				NOT NULL,		-- FK

	CONSTRAINT 	PK_Transaction_TransactionID 		PRIMARY KEY 	(TransactionID),
)

CREATE TABLE Offer.Product
(
	ProductID		INT				NOT NULL		IDENTITY(1,1),
	Name			NVARCHAR(50)		NOT NULL,
	IsService		BIT				NOT NULL,
	BaseValue		MONEY				NOT NULL,	
	Complexity		INT				NOT NULL,		-- CK (>= 0, <= 100)

	CONSTRAINT 	PK_Product_ProductID 		PRIMARY KEY 	(ProductID),
)

GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █ Création des contraintes de clé étrangère █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

ALTER TABLE Offer.Contract
ADD CONSTRAINT FK_Contract_BozoID FOREIGN KEY (EmployeeID) REFERENCES Demand.Bozo(BozoID) 
ON UPDATE CASCADE
ON DELETE CASCADE -- contract binds an employee to an enterprise

ALTER TABLE Offer.Contract
ADD CONSTRAINT FK_Contract_EnterpriseID FOREIGN KEY (EnterpriseID) REFERENCES Offer.Enterprise(EnterpriseID)
ON UPDATE CASCADE
ON DELETE CASCADE -- contract binds an employee to an enterprise

ALTER TABLE Offer.Production
ADD CONSTRAINT FK_Production_ContractID FOREIGN KEY (ContractID) REFERENCES Offer.Contract(ContractID)
ON UPDATE CASCADE
ON DELETE CASCADE -- production must be bound to a contract

ALTER TABLE Offer.ProductInstance
ADD CONSTRAINT FK_ProductInstance_ProductID FOREIGN KEY (ProductID) REFERENCES Offer.Product(ProductID)
ON UPDATE CASCADE
ON DELETE CASCADE -- product instance cannot exist without a product

ALTER TABLE Offer.ProductInstance
ADD CONSTRAINT FK_ProductInstance_ProductionID FOREIGN KEY (ProductionID) REFERENCES Offer.Production(ProductionID)
ON UPDATE CASCADE
ON DELETE CASCADE -- product instance must have been produced

ALTER TABLE Demand.[Transaction]
ADD CONSTRAINT FK_Transaction_SenderID FOREIGN KEY (SenderID) REFERENCES Demand.Bozo(BozoID)
ON UPDATE CASCADE
ON DELETE CASCADE -- transaction must have a sender

-- handling cascades too complicated for those since SQL Server only supports 1 cascade for the same referenced key
-- I'd have to use a trigger with INSTEAD OF DELETE, but can't bother with that lol
ALTER TABLE Demand.[Transaction]
ADD CONSTRAINT FK_Transaction_ReceiverID FOREIGN KEY (ReceiverID) REFERENCES Demand.Bozo(BozoID)

ALTER TABLE Demand.[Transaction]
ADD CONSTRAINT FK_Transaction_ProductInstanceID FOREIGN KEY (ProductInstanceID) REFERENCES Offer.ProductInstance(ProductInstanceID)

GO



-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █      Création des contraintes UC,DF,CK     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

ALTER TABLE Demand.Bozo
ADD CONSTRAINT UC_Bozo_Nickname UNIQUE (Nickname)

ALTER TABLE Demand.Bozo
ADD CONSTRAINT DF_Bozo_Honesty DEFAULT (100) FOR Honesty

ALTER TABLE Demand.Bozo
ADD CONSTRAINT CK_Bozo_Honesty CHECK (Honesty >= 0 AND Honesty <= 100)

ALTER TABLE Offer.Contract
ADD CONSTRAINT CK_Contract_Importance CHECK (Importance >= 0 AND Importance <= 100)

ALTER TABLE Offer.Production
ADD CONSTRAINT CK_Production_Quantity CHECK (Quantity >= 0)

ALTER TABLE Offer.Product
ADD CONSTRAINT CK_Product_Complexity CHECK (Complexity >= 0 AND Complexity <= 100)

ALTER TABLE Offer.Product
ADD CONSTRAINT CK_Product_BaseValue CHECK (BaseValue >= 0)

GO