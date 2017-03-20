USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003RFID]    Script Date: 2016/01/28 15:46:00 ******/
CREATE TYPE [dbo].[DCW003RFID] AS TABLE(
	[ID] [int] NULL,
	[RFIDKey] [varchar](25) NULL
)
GO

