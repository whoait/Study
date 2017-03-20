IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetJapanYear' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003GetJapanYear
GO

CREATE PROC [dbo].[stp_DCW003GetJapanYear]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2016/18/01
-- Comment			: Store get JapanYear
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_CONST.TYPE_VALUE as Year
		,TM_CONST.VALUE as JapanYear
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM
		TM_CONST
	WHERE
		TM_CONST.TYPE = '西暦変換'
		AND
		TM_CONST.DELETE_FLG = '0'

END


GO


