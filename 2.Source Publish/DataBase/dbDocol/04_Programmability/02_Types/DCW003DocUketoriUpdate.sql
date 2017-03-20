USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003DocUketoriUpdate]    Script Date: 2016/01/28 15:45:22 ******/
CREATE TYPE [dbo].[DCW003DocUketoriUpdate] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[JishameiFlag] [char](1) NULL,
	[ShakenLimitDate] [datetime] NULL,
	[ShoruiLimitDate] [datetime] NULL,
	[MeihenShakenTorokuDate] [datetime] NULL
)
GO

