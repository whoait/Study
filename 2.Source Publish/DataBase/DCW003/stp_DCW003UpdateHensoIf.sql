IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003UpdateHensoIf' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003UpdateHensoIf
GO

CREATE PROC [dbo].[stp_DCW003UpdateHensoIf]

AS
---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: TramD
-- Programmer		: TramD
-- Created Date		: 2016/01/26
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	
	DECLARE @ct_ID					int

	DECLARE auto_cursor CURSOR 
	FOR SELECT ID
			FROM TT_DOC_HENSO_IF WITH(NOLOCK)
				INNER JOIN TT_DOC_CONTROL WITH(NOLOCK)
				ON TT_DOC_HENSO_IF.CHASSIS_NO = TT_DOC_CONTROL.CHASSIS_NO
				AND (
						TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO
						OR
						TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO
					)
			 WHERE HENSO_ZUMI_FLG = 0
	OPEN auto_cursor 
	FETCH NEXT FROM auto_cursor INTO @ct_ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE TT_DOC_HENSO_IF SET
			[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG				= 1
			--,[UPDATE_DATE] = GETDATE()
			WHERE
			TT_DOC_HENSO_IF.ID = @ct_ID
		FETCH NEXT FROM auto_cursor INTO @ct_ID
	END

		--UPDATE TT_DOC_HENSO_IF SET
		--	[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG				= 1
		--	--,[UPDATE_DATE] = GETDATE()
		--	WHERE
		--	[TT_DOC_HENSO_IF].CHASSIS_NO IN (
		--						SELECT TT_DOC_HENSO_IF.CHASSIS_NO FROM TT_DOC_HENSO_IF WITH(NOLOCK)
		--							INNER JOIN TT_DOC_CONTROL WITH(NOLOCK)
		--							ON TT_DOC_HENSO_IF.CHASSIS_NO = TT_DOC_CONTROL.CHASSIS_NO
		--							AND (
		--								TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO
		--								OR
		--								TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO
		--								)
		--							WHERE HENSO_ZUMI_FLG = 0
		--					)
	
	CLOSE auto_cursor
    DEALLOCATE auto_cursor 					
END
GO