USE [dbDOC_ph2]
GO

/****** Object:  Table [dbo].[TT_AA_SHUPPIN_INFO]    Script Date: 2016/01/28 18:18:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TT_AA_SHUPPIN_INFO](
	[AA_DAIKO_NO] [int] NOT NULL,
	[CAR_ID] [char](16) NULL,
	[CAR_SUB_ID] [char](3) NULL,
	[SHOP_CD] [char](6) NULL,
	[BBNO] [varchar](14) NULL,
	[SHIIRE_NO] [varchar](10) NULL,
	[AA_KAIJO_CD] [char](6) NULL,
	[AA_KAISAI_KAISU] [int] NULL,
	[AA_KAISAI_DATE] [datetime] NULL,
	[AA_SHUPPIN_NO] [varchar](5) NULL,
	[AA_URIKIRI_KAKAKU] [decimal](11, 0) NULL,
	[AA_SAISHU_OSATSU_KINGAKU] [decimal](11, 0) NULL,
	[AA_SEIYAKU_KINGAKU] [decimal](11, 0) NULL,
	[AA_BAIBAI_STATUS] [char](1) NULL,
	[AA_KAIJO_HYOKATEN] [varchar](5) NULL,
	[AA_STATUS_TYPE] [varchar](3) NULL,
	[AA_RAKUSATSU_FLG] [char](1) NULL,
	[CREATE_DATE] [datetime] NULL,
	[CREATE_USER_CD] [varchar](6) NULL,
	[CREATE_PG_CD] [varchar](50) NULL,
	[UPDATE_DATE] [datetime] NULL,
	[UPDATE_USER_CD] [varchar](6) NULL,
	[UPDATE_PG_CD] [varchar](50) NULL,
	[DELETE_DATE] [datetime] NULL,
	[DELETE_FLG] [char](1) NULL,
 CONSTRAINT [PK_TT_AA_SHUPPIN_INFO] PRIMARY KEY CLUSTERED 
(
	[AA_DAIKO_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [dbDOC_DATA]
) ON [dbDOC_DATA]

GO

SET ANSI_PADDING OFF
GO

