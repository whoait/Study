IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetMasterYear' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003GetMasterYear
GO

CREATE PROC [dbo].[stp_DCW003GetMasterYear]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_CONST.VALUE			AS Value
		,TM_CONST.TYPE_VALUE	AS Text
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TM_CONST WITH(NOLOCK)
	WHERE TM_CONST.TYPE = '�[�ŔN�x�\��'
	AND TM_CONST.DELETE_FLG = 0

	ORDER BY TM_CONST.VALUE

END

GO
