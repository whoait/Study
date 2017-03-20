USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003DocUketoriDetail]    Script Date: 2016/01/28 15:45:14 ******/
CREATE TYPE [dbo].[DCW003DocUketoriDetail] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[DocFuzokuhinCd] [char](3) NULL,
	[DefaulCheckType] [char](4) NULL,
	[DocCount] [int] NULL,
	[Note] [varchar](200) NULL,
	[IsChecked] [int] NULL
)
GO

