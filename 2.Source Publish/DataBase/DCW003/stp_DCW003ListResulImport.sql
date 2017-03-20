IF EXISTS ( SELECT * FROM sys.types WHERE name = 'DCW003ListResulImport' AND user_name(schema_id) = 'dbo')
	DROP TYPE DCW003ListResulImport
GO

CREATE TYPE [dbo].[DCW003ListResulImport] AS TABLE(
	[lstDocControlNo] [varchar](13) NULL,
	[lstImport] [varchar](25) NULL,
	[lstError] [varchar](25) NULL,
	[lstNomap] [varchar](25) NULL
)
GO