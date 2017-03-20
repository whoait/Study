USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ListUpdate]    Script Date: 2016/01/28 15:45:53 ******/
CREATE TYPE [dbo].[DCW003ListUpdate] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[UriageShuppinTorokuNo] [varchar](8) NULL,
	[ChassisNo] [varchar](25) NULL,
	[RackNo] [char](1) NULL,
	[FileNo] [char](4) NULL,
	[MasshoFlg] [char](1) NULL,
	[JishameiFlg] [char](1) NULL,
	[DocStatus] [char](3) NULL,
	[DocNyukoDate] [datetime] NULL,
	[DocShukkoDate] [datetime] NULL,
	[JishameiIraiShukkoDate] [datetime] NULL,
	[JishameiIraiNyukoDate] [datetime] NULL,
	[MasshoIraiShukkoDate] [datetime] NULL,
	[MasshoIraiNyukoDate] [datetime] NULL,
	[ShoruiLimitDate] [datetime] NULL,
	[ShakenLimitDate] [datetime] NULL,
	[Memo] [varchar](500) NULL
)
GO

