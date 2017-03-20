IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetFuzokuhin' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003GetFuzokuhin
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
		List.DocControlNo					AS DocControlNo							-- èëóﬁä«óùî‘çÜ
		,TT_DOC_UKETORI_DETAIL.DOC_FUZOKUHIN_CD				AS DocFuzoKuhinCd
		,TT_DOC_UKETORI_DETAIL.NOTE							AS Note
		,(CASE WHEN List.DocControlNo IN (
				SELECT DOC_CONTROL_NO
				FROM TH_DOC_UKETORI_DETAIL
				INNER JOIN @ListDocControlNo List
				ON TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO = List.DocControlNo
			) THEN '1'
			ELSE '0'
			END
		) AS HisUketoriDocControlNo
		--,TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO					AS HisUketoriDocControlNo
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM
		@ListDocControlNo AS List
		LEFT JOIN TT_DOC_UKETORI_DETAIL WITH(NOLOCK)
		ON TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO = [List].DocControlNo
	--WHERE
	--	TT_DOC_UKETORI_DETAIL.DELETE_FLG = 0
	--ORDER BY CREATE_DATE DESC

END


GO



