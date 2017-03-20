IF EXISTS ( SELECT * FROM sys.types WHERE name = 'DCW003ChassisNo' AND user_name(schema_id) = 'dbo')
	DROP TYPE DCW003ChassisNo
GO

CREATE TYPE [dbo].[DCW003ChassisNo] AS TABLE(
	[ChassisNo] [varchar](25) NULL
)
GO