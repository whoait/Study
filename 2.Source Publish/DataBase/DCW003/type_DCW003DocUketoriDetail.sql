IF EXISTS ( SELECT * FROM sys.types WHERE name = 'DCW003DocUketoriDetail' AND user_name(schema_id) = 'dbo')
	DROP TYPE DCW003DocUketoriDetail
GO

CREATE TYPE [dbo].[DCW003DocUketoriDetail] AS TABLE(

	[DocControlNo]			[varchar](13) NULL,
	[DocFuzokuhinCd]		[char](3) NULL,
	[DefaulCheckType]		[char](4) NULL,
	[HisUketoriDocControlNo] [varchar](13) NULL,
	[DocCount]				[int] NULL,
	[Note]					[varchar](200) NULL,
	[IsChecked]				[int] NULL
)
GO