USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_InsertAAFax]    Script Date: 2016/01/28 15:57:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[stp_InsertAAFax]
(	
	 @ShuppinnTorokuNo		varchar(8)							
	,@Result		int OUT
)

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: BinhVT5
-- Programmer		: BinhVT5
-- Created Date		: 2016/01/26
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	SET @Result =0

	BEGIN TRY
		BEGIN
		-------------------------------------------------------------------------
		-- INSERT TT_AA_BIHIN_SOFU_SHIJI_FAX
		-------------------------------------------------------------------------
		INSERT INTO [dbo].[TT_AA_BIHIN_SOFU_SHIJI_FAX]
           ([SHUPPINN_TOROKU_NO]
           ,[RENKEI_ZUMI_FLG]
           ,[CREATE_DATE]
           ,[CREATE_USER_CD]
           ,[CREATE_PG_CD]
           ,[UPDATE_DATE]
           ,[UPDATE_USER_CD]
           ,[UPDATE_PG_CD]
           ,[DELETE_DATE]
           ,[DELETE_FLG])
		VALUES
           (@ShuppinnTorokuNo
           ,'0'
           ,GETDATE()
           ,NULL
           ,'BAT_AA_FAX'
           ,GETDATE()
           ,NULL
           ,'BAT_AA_FAX'
           ,NULL
           ,'0')
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

