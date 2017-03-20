USE [dbDocPH2]
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ChassisNo]    Script Date: 2016/01/28 18:30:47 ******/
CREATE TYPE [dbo].[DCW003ChassisNo] AS TABLE(
	[ChassisNo] [varchar](25) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003Csv]    Script Date: 2016/01/28 18:30:47 ******/
CREATE TYPE [dbo].[DCW003Csv] AS TABLE(
	[ID] [int] NULL,
	[RacFileNo] [varchar](5) NULL,
	[KeiCarFlg] [char](1) NULL,
	[TorokuNo] [varchar](24) NULL,
	[HyobanType] [char](1) NULL,
	[ChassisNo] [varchar](25) NULL,
	[GendokiKatashiki] [varchar](12) NULL,
	[ReportType] [char](1) NULL,
	[DocControlNo] [varchar](13) NULL,
	[IraiDate] [datetime] NULL,
	[ShopCd] [char](6) NULL,
	[GenshaLocation] [varchar](25) NULL,
	[CarName] [varchar](100) NULL,
	[JMType] [char](3) NULL,
	[Note] [varchar](1000) NULL,
	[HensoIraiDate] [datetime] NULL,
	[ShopName] [char](100) NULL,
	[TantoshaName] [varchar](40) NULL,
	[ShiireSaki] [varchar](20) NULL,
	[HensoRiyu] [varchar](1000) NULL,
	[JishameiYouhi] [varchar](1000) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003DocControlNo]    Script Date: 2016/01/28 18:30:47 ******/
CREATE TYPE [dbo].[DCW003DocControlNo] AS TABLE(
	[DocControlNo] [varchar](13) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003DocUketoriDetail]    Script Date: 2016/01/28 18:30:47 ******/
CREATE TYPE [dbo].[DCW003DocUketoriDetail] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[DocFuzokuhinCd] [char](3) NULL,
	[DefaulCheckType] [char](4) NULL,
	[DocCount] [int] NULL,
	[Note] [varchar](200) NULL,
	[IsChecked] [int] NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003DocUketoriUpdate]    Script Date: 2016/01/28 18:30:47 ******/
CREATE TYPE [dbo].[DCW003DocUketoriUpdate] AS TABLE(
	[DocControlNo] [varchar](13) NULL,
	[JishameiFlag] [char](1) NULL,
	[ShakenLimitDate] [datetime] NULL,
	[ShoruiLimitDate] [datetime] NULL,
	[MeihenShakenTorokuDate] [datetime] NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ExportCSVLinkGHQ]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[DCW003ExportCSVLinkGHQ] AS TABLE(
	[ChassisNo] [varchar](25) NULL,
	[KeiCarFlg] [char](1) NULL,
	[CcName] [real] NULL,
	[JoshaTeiinNum] [int] NULL,
	[TorokuNo] [varchar](30) NULL,
	[JishameiKanryoNyukoDate] [datetime] NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ListResulImport]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[DCW003ListResulImport] AS TABLE(
	[lstDocControlNo] [varchar](13) NULL,
	[lstImport] [varchar](25) NULL,
	[lstError] [varchar](25) NULL,
	[lstNomap] [varchar](25) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003ListUpdate]    Script Date: 2016/01/28 18:30:48 ******/
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

/****** Object:  UserDefinedTableType [dbo].[DCW003RFID]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[DCW003RFID] AS TABLE(
	[ID] [int] NULL,
	[RFIDKey] [varchar](25) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[DCW003SendGHQ]    Script Date: 2016/01/28 18:30:48 ******/
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

/****** Object:  UserDefinedTableType [dbo].[DCW003TorokuNo]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[DCW003TorokuNo] AS TABLE(
	[TorokuNo] [varchar](8) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[PrintPages]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[PrintPages] AS TABLE(
	[ID] [varchar](10) NULL
)
GO

/****** Object:  UserDefinedTableType [dbo].[StringList]    Script Date: 2016/01/28 18:30:48 ******/
CREATE TYPE [dbo].[StringList] AS TABLE(
	[Item] [nvarchar](max) NULL,
	[ID] [int] NULL
)
GO

