USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ExportCSVLinkGHQ]    Script Date: 2016/01/28 15:45:32 ******/
CREATE TYPE [dbo].[DCW003ExportCSVLinkGHQ] AS TABLE(
	[ChassisNo] [varchar](25) NULL,
	[KeiCarFlg] [char](1) NULL,
	[CcName] [real] NULL,
	[JoshaTeiinNum] [int] NULL,
	[TorokuNo] [varchar](30) NULL,
	[JishameiKanryoNyukoDate] [datetime] NULL
)
GO

