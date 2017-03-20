USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003ExportCSVLinkGHQ]    Script Date: 2016/01/28 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
	FROM @ListExportCSVLinkGHQ  List 

END

GO

