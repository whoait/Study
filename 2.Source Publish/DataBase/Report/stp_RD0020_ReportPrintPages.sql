IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_RD0020_ReportPrintPages' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_RD0020_ReportPrintPages
GO

--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2015/12/03 
-- Comment                      : Store PrintPage 
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0020_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
	DC.RAKUSATSU_SHOP_CD AS SHOP_CD
	, DC.CHASSIS_NO
	, DC.CAR_NAME, DC.SHIIRE_NO
	, S1.TEMPO_NAME AS 'TEMPO_NAME', DJ.SHOP_CD AS DJ_SHOPCD, S2.TEMPO_NAME AS 'TEMPO_NAME_DJ'
	--, CONCAT(DC.RACK_NO,DC.FILE_NO) AS CONTROL_NUMBER
	, ISNULL(DC.RACK_NO,'') + ISNULL(DC.FILE_NO,'')  AS CONTROL_NUMBER
	--, (
	--SELECT CT.VALUE FROM TM_CONST WHERE CT.TYPE ='自社名依頼書表示用'
	--)
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_FAX'
	) AS 'FAX'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_TEL'
	) AS 'TEL'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = '送付元チーム名'
	) AS 'DN'

	 FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
	 LEFT JOIN TT_DOC_JISHAMEI_MASSHO_IF AS DJ WITH(NOLOCK) ON DJ.DOC_CONTROL_NO = DC.DOC_CONTROL_NO
	 AND DJ.DELETE_FLG = 0
	 LEFT JOIN TM_SHOP AS S1 WITH(NOLOCK) ON DC.RAKUSATSU_SHOP_CD = S1.TEMPO_CD
	 AND S1.DELETE_FLG = 0
	 LEFT JOIN TM_SHOP AS S2 WITH(NOLOCK) ON DJ.SHOP_CD = S2.TEMPO_CD
	 AND S2.DELETE_FLG = 0
	 INNER JOIN @list AS lst ON DC.DOC_CONTROL_NO = lst.Item
	 WHERE DC.DELETE_FLG = 0
	 ORDER BY lst.ID
END