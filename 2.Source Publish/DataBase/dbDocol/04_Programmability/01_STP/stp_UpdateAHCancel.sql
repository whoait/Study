USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_UpdateAHCancel]    Script Date: 2016/01/28 15:59:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_UpdateAHCancel]
(	
	@DocControlNo	varchar(13)	
	,@Result		int   OUT
	
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: BinhVT5
-- Programmer		: BinhVT5
-- Created Date		: 2015/12/21
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	
	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)
	SET @Result =0

	BEGIN TRY
		IF @DocControlNo IS NOT NULL AND @DocControlNo != ''
		BEGIN
		-------------------------------------------------------------------------
		-- Insert History
		-------------------------------------------------------------------------
			--EXEC USP_MAKE_HISTORY @DocControlNo,NULL,'UPDATE_DOC',@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
			--IF @p_result_id != 0
			--BEGIN
				--RETURN 1
			--END
		-------------------------------------------------------------------------
		-- Update A => H Cancel
		-------------------------------------------------------------------------
			Update [dbo].TT_DOC_CONTROL SET									
					 SHIIRE_CANSEL_FLG ='1'
					,UPDATE_DATE =GETDATE()
					,UPDATE_PG_CD='UPDATE_DOC'					
			WHERE DOC_CONTROL_NO = @DocControlNo
		-------------------------------------------------------------------------
		-- Insert History
		-------------------------------------------------------------------------
			EXEC USP_MAKE_HISTORY @DocControlNo,NULL,'UPDATE_DOC',@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
		END
		RETURN 0
	END TRY

	/********************/ 
	/*  ExceptionError  */
	/********************/
	BEGIN CATCH
		--異常終了
		IF @@TRANCOUNT <> 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		IF (@Result = 0)
		BEGIN
			SET @Result = ERROR_NUMBER()
		END
		RETURN 1
	END CATCH
END



GO

