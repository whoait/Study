USE [dbDocol_Test_P2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003SendGHQ]    Script Date: 2016/01/28 15:46:13 ******/
CREATE TYPE [dbo].[DCW003SendGHQ] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[ShiireShuppinnTorokuNo] [varchar](8) NULL,
	[ShopCd] [varchar](6) NULL,
	[ChassisNo] [varchar](25) NULL,
	[KeiCarFlg] [char](2) NULL,
	[TorokuNo] [char](30) NULL,
	[ShoruiLimitDate] [datetime] NULL,
	[MasshoFlg] [char](2) NULL,
	[ShakenLimitDate] [datetime] NULL,
	[JishameiFlg] [char](1) NULL,
	[DocNyukoDate] [datetime] NULL
)
GO

