IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003InsertDocUketoriDetail' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003InsertDocUketoriDetail
GO

CREATE PROC [dbo].[stp_DCW003InsertDocUketoriDetail]
(	
	@ListDocUketoriDetail		DCW003DocUketoriDetail		READONLY
	,@ListDocUketoriUpdate		DCW003DocUketoriUpdate		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/05
-- Comment			: Store insert TT_DOC_AUTO_SEARCH of DCW003
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- UPDATE
	-------------------------------------------------------------------------
	UPDATE TT_DOC_CONTROL SET
		[TT_DOC_CONTROL].SHORUI_LIMIT_DATE = [ListUpdate].ShoruiLimitDate
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE = [ListUpdate].MeihenShakenTorokuDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE = [ListUpdate].ShakenLimitDate
		,[TT_DOC_CONTROL].UPDATE_DATE = GETDATE()
		,[TT_DOC_CONTROL].UPDATE_USER_CD = @User
		,[TT_DOC_CONTROL].JISHAMEI_FLG = ListUpdate.JishameiFlag
	FROM
		[TT_DOC_CONTROL]
	INNER JOIN @ListDocUketoriUpdate ListUpdate
	ON [TT_DOC_CONTROL].DOC_CONTROL_NO = [ListUpdate].DocControlNo
	WHERE [TT_DOC_CONTROL].DELETE_FLG = 0

	-------------------------------------------------------------------------
	-- DELETE
	-------------------------------------------------------------------------
	DELETE FROM TT_DOC_UKETORI_DETAIL
	WHERE TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO IN (SELECT DocControlNo FROM @ListDocUketoriUpdate)
	--OR TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO IN (
	--							SELECT DOC_CONTROL_NO FROM TT_DOC_CONTROL
	--							WHERE JISHAMEI_FLG = 1 
	--							AND DOC_CONTROL_NO IN (SELECT  DocControlNo FROM @ListDocUketoriUpdate)
	--							)

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_DOC_UKETORI_DETAIL
	(
		[TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO
		,[TT_DOC_UKETORI_DETAIL].DOC_FUZOKUHIN_CD
		,[TT_DOC_UKETORI_DETAIL].DOC_COUNT
		,[TT_DOC_UKETORI_DETAIL].DOC_HAKKO_DATE
		,[TT_DOC_UKETORI_DETAIL].DOC_UKE_DATE
		,[TT_DOC_UKETORI_DETAIL].NOTE
		,[TT_DOC_UKETORI_DETAIL].CREATE_DATE
		,[TT_DOC_UKETORI_DETAIL].CREATE_USER_CD
		,[TT_DOC_UKETORI_DETAIL].UPDATE_DATE
		,[TT_DOC_UKETORI_DETAIL].UPDATE_USER_CD
		,[TT_DOC_UKETORI_DETAIL].DELETE_FLG
	)
	SELECT
		List.DocControlNo
		--,CASE 
		--	WHEN TT_DOC_CONTROL.MASSHO_FLG = 0 THEN 101
		--	ELSE
		--		List.DocFuzokuhinCd
		--	END		
		,List.DocFuzokuhinCd
		,'1'
		,CASE 
			WHEN TT_DOC_CONTROL.MASSHO_FLG = 0 THEN TT_DOC_CONTROL.SHAKEN_LIMIT_DATE
			ELSE
				NULL
			END
		--,GETDATE()
		,CONVERT(VARCHAR(11),GETDATE(),111)
		--,CASE
		--	WHEN TT_DOC_CONTROL.JISHAMEI_FLG = 1 AND (List.Note IS NULL) THEN '���Ж���'
		--	ELSE List.Note
		--	END
		,List.Note
		,GETDATE()
		,@User
		,GETDATE()
		,@User
		,0
	FROM @ListDocUketoriDetail List 
		INNER JOIN TT_DOC_CONTROL WITH(NOLOCK)
		ON List.DocControlNo = TT_DOC_CONTROL.DOC_CONTROL_NO
END
GO
