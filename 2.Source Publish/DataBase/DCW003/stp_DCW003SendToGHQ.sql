IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003SendToGHQ' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003SendToGHQ
GO

CREATE PROC [dbo].[stp_DCW003SendToGHQ]
(	
	@ListSendGHQ		DCW003SendGHQ		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2015/01/12
-- Comment			: Store insert TT_DOC_CONTROL to TT_GHQ_DOC_UKETORI_OUTPUT
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_GHQ_DOC_UKETORI_OUTPUT
	(
		TT_GHQ_DOC_UKETORI_OUTPUT.CHASSIS_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHOP_CD
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHUPPINN_TOROKU_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.CAR_TYPE
		,TT_GHQ_DOC_UKETORI_OUTPUT.UKETORIJI_SHORUI_TYPE
		,TT_GHQ_DOC_UKETORI_OUTPUT.LICENSE_PLATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHORUI_FINISH_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHORUI_LIMIT_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.Incompleteness
		,TT_GHQ_DOC_UKETORI_OUTPUT.JISHAMEI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.DOC_CONTROL_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.RENKEI_ZUMI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.NOTE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_USER_CD
		,TT_GHQ_DOC_UKETORI_OUTPUT.DELETE_FLG
	)
	SELECT
		 List.ChassisNo
		,List.ShopCd
		,List.ShiireShuppinnTorokuNo
		,List.KeiCarFlg
		,List.MasshoFlg
		,List.TorokuNo
		,CONVERT(VARCHAR(8),GETDATE(),112)
		,CASE
					WHEN List.ShoruiLimitDate IS NULL THEN '00000000'
					ELSE (CONVERT(VARCHAR(8),List.ShoruiLimitDate,112))
				 END
		,'2'
		,List.JishameiFlg
		,List.DocControlNo
		,'0'
		,''
		,GETDATE()
		,@User
		,'0'
	FROM @ListSendGHQ  List 

END
GO


