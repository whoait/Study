USE [dbDOC]
GO

/****** Object:  Table [dbo].[TT_DN_CAR_INFO]    Script Date: 2016/01/11 8:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TT_DN_CAR_INFO](
	[SHUPPINN_TOROKU_NO] [varchar](8) NOT NULL,
	[CHASSIS_NO] [varchar](25) NULL,
	[SHOP_CD] [char](6) NULL,
	[RAKUSATSU_SHOP_CD] [char](6) NULL,
	[DN_SEIYAKU_DATE] [datetime] NULL,
	[BBNO] [varchar](14) NULL,
	[SHIIRE_NO] [varchar](50) NULL,
	[NENSHIKI] [varchar](8) NULL,
	[MAKER_NAME] [varchar](50) NULL,
	[CAR_NAME] [varchar](100) NULL,
	[GRADE_NAME] [varchar](100) NULL,
	[KATASHIKI] [varchar](24) NULL,
	[CC] [real] NULL,
	[JOSHA_TEIIN_NUM] [int] NULL,
	[KEI_CAR_FLG] [char](1) NULL,
	[TOROKU_NO] [varchar](30) NULL,
	[SHAKEN_LIMIT_DATE] [datetime] NULL,
	[SHORUI_LIMIT_DATE] [datetime] NULL,
	[MASSHO_FLG] [char](3) NULL,
	[CAR_ID] [char](16) NULL,
	[CAR_SUB_ID] [char](3) NULL,
	[CANCEL_FLG] [char](1) NULL,
	[CREATE_DATE] [datetime] NULL,
	[CREATE_USER_CD] [varchar](10) NULL,
	[CREATE_PG_CD] [varchar](10) NULL,
	[UPDATE_DATE] [datetime] NULL,
	[UPDATE_USER_CD] [varchar](10) NULL,
	[UPDATE_PG_CD] [varchar](10) NULL,
	[DELETE_DATE] [datetime] NULL,
	[DELETE_FLG] [char](1) NULL,
 CONSTRAINT [PK_TT_DN_CAR_INFO] PRIMARY KEY CLUSTERED 
(
	[SHUPPINN_TOROKU_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [dbDOC_DATA]
) ON [dbDOC_DATA]

GO

SET ANSI_PADDING OFF
GO

