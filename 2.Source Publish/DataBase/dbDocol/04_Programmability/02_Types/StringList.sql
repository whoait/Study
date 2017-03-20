USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[StringList]    Script Date: 2016/01/28 15:46:43 ******/
CREATE TYPE [dbo].[StringList] AS TABLE(
	[Item] [nvarchar](max) NULL,
	[ID] [int] NULL
)
GO

