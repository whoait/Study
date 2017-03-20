IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_RD0030_ReportPrintPages' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_RD0030_ReportPrintPages
GO

--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2016/01/22 
-- Comment                      : Store PrintPage 
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0030_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
		 DC.AA_KAISAI_KAISU AS 'AA_KAISAI_KAISU'
		,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(MONTH, DC.AA_KAISAI_DATE)),2) AS 'AA_KAISAI_MONTH'
		,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, AA_KAISAI_DATE)),2) AS 'AA_KAISAI_DATE'
		,DC.AA_SHUPPIN_NO AS 'AA_SHUPPIN_NO'
		,AA.KAIIN_NO AS 'URIAGE_AA_KAIJO_CD'
		,DC.CAR_NAME AS 'CAR_NAME'
		,DC.CHASSIS_NO AS 'CHASSIS_NO'
	FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
	INNER JOIN @list AS lst ON DC.DOC_CONTROL_NO = lst.Item
	LEFT JOIN TM_AA_KAIJO AS AA WITH(NOLOCK)
	ON AA.AA_KAIJO_CD = DC.URIAGE_AA_KAIJO
	WHERE DC.DELETE_FLG = 0
	ORDER BY lst.ID
END