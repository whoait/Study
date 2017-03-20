USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_UpdateAACancel]    Script Date: 2016/01/28 15:58:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[stp_UpdateAACancel]
(	
	 @CarID			char(16)							
	,@CarSubID		char(3)				
	,@ShopCD		char(6)
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
		-- Update AA Cancel
		-------------------------------------------------------------------------
		UPDATE  [TT_DOC_CONTROL] SET
			 URIAGE_AA_KAIJO = NULL		
			,AA_KAISAI_KAISU = NULL		
			,AA_KAISAI_DATE  = NULL		
			,AA_SHUPPIN_NO   = NULL
			,UPDATE_DATE     = getdate()
			,UPDATE_PG_CD    = 'UPDATE_DOC'
		WHERE 		
				CAR_ID = @CarID
			AND CAR_SUB_ID = @CarSubID
			AND RAKUSATSU_SHOP_CD = @ShopCD
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

