USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetFuzokuhin]    Script Date: 2016/01/28 15:51:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetFuzokuhin]
(	
	@ListDocControlNo	DCW003DocControlNo		READONLY
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: Store seach of DCW003
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		[TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_UKETORI_DETAIL].DOC_FUZOKUHIN_CD				AS DocFuzoKuhinCd
		,[TT_DOC_UKETORI_DETAIL].NOTE							AS Note
		,TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO					AS HisUketoriDocControlNo
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_UKETORI_DETAIL WITH(NOLOCK)
		INNER JOIN @ListDocControlNo List
		ON [TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO = [List].DocControlNo
		LEFT JOIN TH_DOC_UKETORI_DETAIL WITH(NOLOCK)
		ON TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO = TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO
	WHERE
		[TT_DOC_UKETORI_DETAIL].DELETE_FLG = 0

END



GO

