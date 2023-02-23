-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █          Création de la BD          █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█


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


CREATE TABLE Offer.Enterprise
(
	EnterpriseID		INT			NOT NULL		IDENTITY(1,1),
	Name				NVARCHAR(50)	NOT NULL		UNIQUE,
	ProductionInterval	DATETIME		NOT NULL, 

	CONSTRAINT 	PK_Enterprise_EnterpriseID 	PRIMARY KEY 	(EnterpriseID),
)

CREATE TABLE Offer.Contract
(
	ContractID		INT				NOT NULL		IDENTITY(1,1),
	Name			NVARCHAR(50)		NOT NULL,
	Importance		INT				NOT NULL,
	EmployeeID		INT				NOT NULL,		-- FK
	EnterpriseID	INT				NOT NULL,		-- FK

	CONSTRAINT 	PK_Contract_ContractID 		PRIMARY KEY 	(ContractID),
)

CREATE TABLE Offer.Production
(
	ProductionID	INT				NOT NULL		IDENTITY(1,1),
	Date			DATETIME			NOT NULL,		-- FK
	Quantity		INT				NOT NULL,

	CONSTRAINT 	PK_Production_ProductionID 	PRIMARY KEY 	(ProductionID),
)

CREATE TABLE Offer.Product
(
	ProductID		INT				NOT NULL		IDENTITY(1,1),
	Name			NVARCHAR(50)		NOT NULL,
	IsService		BIT				NOT NULL,
	Value			MONEY				NOT NULL,
	Complexity		INT				NOT NULL,

	CONSTRAINT 	PK_Product_ProductID 		PRIMARY KEY 	(ProductID),
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
	Balance			MONEY				NOT NULL,
	SenderID			INT				NOT NULL,		-- FK
	ReceiverID			INT				NOT NULL,		-- FK
	ProductInstanceID		INT				NOT NULL,		-- FK

	CONSTRAINT 	PK_Transaction_TransactionID 		PRIMARY KEY 	(TransactionID),
)

CREATE TABLE Demand.Bozo
(
	BozoID	INT			NOT NULL		IDENTITY(1,1),
	FirstName	NVARCHAR(50)	NOT NULL,
	LastName	NVARCHAR(50)	NOT NULL,
	Nickname	NVARCHAR(50)	NOT NULL,
	Honesty	INT			NOT NULL,
	
	CONSTRAINT 	PK_Bozo_BozoID 	PRIMARY KEY 	(BozoID)
)
GO


-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █ Création des contraintes de clé étrangère █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█





-- █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
-- █      Création des contraintes UC,DF,CK     █
-- █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

