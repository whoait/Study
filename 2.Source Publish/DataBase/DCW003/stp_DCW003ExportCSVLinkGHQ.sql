IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003ExportCSVLinkGHQ' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003ExportCSVLinkGHQ
GO

CREATE PROC [dbo].[stp_DCW003ExportCSVLinkGHQ]
(	
	@ListExportCSVLinkGHQ		DCW003ExportCSVLinkGHQ		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2015/01/12
-- Comment			: Store insert TT_DOC_CONTROL to TT_GHQ_DOC_MEIHEN_OUTPUT
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_GHQ_DOC_MEIHEN_OUTPUT
	(
		TT_GHQ_DOC_UKETORI_OUTPUT.KEI_CAR_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_YEAR
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_MONTH
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_DAY
		,TT_GHQ_DOC_UKETORI_OUTPUT.CHASSIS_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.JOSHA_TEIIN_NUM
		,TT_GHQ_DOC_UKETORI_OUTPUT.CC
		,TT_GHQ_DOC_UKETORI_OUTPUT.NOTE
		,TT_GHQ_DOC_UKETORI_OUTPUT.RENKEI_ZUMI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_USER_CD
		,TT_GHQ_DOC_UKETORI_OUTPUT.DELETE_FLG


	)
	SELECT
		 List.KeiCarFlg
		,List.TorokuNo
		,CONVERT(VARCHAR(2),
		(SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE='西暦変換' AND TM_CONST.TYPE_VALUE = YEAR(List.JishameiKanryoNyukoDate))
		)
		,CONVERT(VARCHAR(2),MONTH(List.JishameiKanryoNyukoDate))
		,CONVERT(VARCHAR(2),DAY(List.JishameiKanryoNyukoDate))
		,List.ChassisNo
		,List.JoshaTeiinNum
		,List.CcName
		,''
		,'0'
		,GETDATE()
		,@User
		,'0'
	FROM @ListExportCSVLinkGHQ  List 

END
GO


