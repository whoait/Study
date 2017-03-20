IF EXISTS ( SELECT * FROM sys.types WHERE name = 'DCW003ExportCSVLinkGHQ' AND user_name(schema_id) = 'dbo')
	DROP TYPE DCW003ExportCSVLinkGHQ
GO

CREATE TYPE [dbo].[DCW003ExportCSVLinkGHQ] AS TABLE(
	[ChassisNo]					[varchar](25) NULL,
	[KeiCarFlg]					[char](1) NULL,
	[CcName]					[real] NULL,
	[JoshaTeiinNum]				[int] NULL,
	[TorokuNo]					[varchar](30) NULL,
	[JishameiKanryoNyukoDate]	[datetime] NULL
)
GO