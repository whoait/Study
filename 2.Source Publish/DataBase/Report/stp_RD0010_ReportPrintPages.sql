IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_RD0010_ReportPrintPages' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_RD0010_ReportPrintPages
GO

--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2015/12/03 
-- Comment                      : Store PrintPage RD0020
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0010_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
	DHF.SHOP_CD AS 'ShopCd'
	, S.TEMPO_NAME AS 'ShopName'
	, DC.CAR_NAME AS 'CarName'
	, DC.CHASSIS_NO AS 'ChassisNo'
	, DC.SHIIRE_SHUPPINN_TOROKU_NO AS 'TorokuNo'
	, DHF.DOC_HENSO_RIYU AS 'HensoRiyu'
	, DHF.NOTE AS 'Note'
	, DHF.TANTOSHA_NAME AS 'TantoshaName'
	, DHF.JISHAMEI_DOC_MAKE_YOUHI AS 'Jishamei'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_FAX'
	) AS 'FAX'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_TEL'
	) AS 'TEL'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = '送付元チーム名'
	) AS 'DN'

	 FROM TT_DOC_HENSO_IF AS DHF WITH(NOLOCK)
		INNER JOIN TT_DOC_CONTROL AS DC WITH(NOLOCK)
		ON
			DC.CHASSIS_NO = DHF.CHASSIS_NO
			AND (
					DHF.SHUPPINN_TOROKU_NO = DC.SHIIRE_SHUPPINN_TOROKU_NO
					OR DHF.SHUPPINN_TOROKU_NO = DC.URIAGE_SHUPPINN_TOROKU_NO
				)
			AND DHF.HENSO_ZUMI_FLG = '1'
			AND DHF.DELETE_FLG = 0
		LEFT JOIN TM_SHOP AS S WITH(NOLOCK)
		ON
			DHF.SHOP_CD = S.TEMPO_CD
			AND S.DELETE_FLG = 0
		INNER JOIN @list AS lst
		ON DC.DOC_CONTROL_NO = lst.Item
	 ORDER BY lst.ID

END