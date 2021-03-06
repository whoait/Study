IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003InsertDocUketoriIf' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003InsertDocUketoriIf
GO

CREATE PROC [dbo].[stp_DCW003InsertDocUketoriIf]
(	
	@ListCsv	DCW003Csv READONLY
	,@User		varchar(10)
	,@ErrorMsg	varchar(5)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/05
-- Comment			: Store insert of DCW003
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- DELETE TABLE
	-------------------------------------------------------------------------
	DELETE FROM TT_DOC_UKETORI_IF

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_DOC_UKETORI_IF
	(
		[TT_DOC_UKETORI_IF].KEI_CAR_FLG
		,[TT_DOC_UKETORI_IF].TOROKU_NO
		,[TT_DOC_UKETORI_IF].HYOBAN_TYPE
		,[TT_DOC_UKETORI_IF].CHASSIS_NO
		,[TT_DOC_UKETORI_IF].GENDOKI_KATASHIKI
		,[TT_DOC_UKETORI_IF].REPORT_TYPE
		,[TT_DOC_UKETORI_IF].CREATE_DATE
		,[TT_DOC_UKETORI_IF].CREATE_USER_CD
		,[TT_DOC_UKETORI_IF].UPDATE_DATE
		,[TT_DOC_UKETORI_IF].UPDATE_USER_CD
		,[TT_DOC_UKETORI_IF].DELETE_FLG
		,[TT_DOC_UKETORI_IF].RACK_FILE_NO
	)
	SELECT
		[List].KeiCarFlg 
		,[List].TorokuNo
		,[List].HyobanType 
		,[List].ChassisNo
		,[List].GendokiKatashiki
		,[List].ReportType
		,GETDATE()
		,@User
		,GETDATE()
		,@User
		,0
		,[List].RacFileNo
	FROM @ListCsv List 

	IF	@@ROWCOUNT = 0
	BEGIN
		SET @ErrorMsg = 'E0010'
	END	
END
GO


