USE [dbDOC]
GO

/****** Object:  Table [dbo].[TM_DOC_FILE_NO]    Script Date: 2016/01/11 8:25:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TM_DOC_FILE_NO](
	[RACK_NO] [char](1) NOT NULL,
	[FILE_NO] [char](4) NOT NULL,
	[RFID_KYE] [varchar](25) NOT NULL,
	[CREATE_DATE] [datetime] NULL,
	[CREATE_USER_CD] [varchar](10) NULL,
	[CREATE_PG_CD] [varchar](10) NULL,
	[UPDATE_DATE] [datetime] NULL,
	[UPDATE_USER_CD] [varchar](10) NULL,
	[UPDATE_PG_CD] [varchar](10) NULL,
	[DELETE_DATE] [datetime] NULL,
	[DELETE_FLG] [char](1) NULL,
 CONSTRAINT [PK_TM_DOC_FILE_NO] PRIMARY KEY CLUSTERED 
(
	[RACK_NO] ASC,
	[FILE_NO] ASC,
	[RFID_KYE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [dbDOC_DATA]
) ON [dbDOC_DATA]

GO

SET ANSI_PADDING OFF
GO
