USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ListResulImport]    Script Date: 2016/01/28 15:45:45 ******/
CREATE TYPE [dbo].[DCW003ListResulImport] AS TABLE(
	[lstDocControlNo] [varchar](13) NULL,
	[lstImport] [varchar](25) NULL,
	[lstError] [varchar](25) NULL,
	[lstNomap] [varchar](25) NULL
)
GO

