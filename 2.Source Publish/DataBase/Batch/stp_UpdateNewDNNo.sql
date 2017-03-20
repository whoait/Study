USE [dbDocol_Test]
GO

/****** Object:  StoredProcedure [dbo].[stp_UpdateNewDNNo]    Script Date: 2016/01/11 17:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[stp_UpdateNewDNNo]
(	
	@DocControlNo		varchar(13)	
	,@ShuppinnTorokuNo  varchar(8)
	,@ShopCD			char(6)
	,@RakusatsuShopCD   char(6)
	,@DNSeiyakuDate     datetime
	,@ShiireNo          varchar(50)
	,@CarSubID          char(3)
	,@Result		   int   OUT
	
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
			Update TT_DOC_CONTROL SET												
				URIAGE_SHUPPINN_TOROKU_NO = @ShuppinnTorokuNo				
				,SHOP_CD = @ShopCD						
				,RAKUSATSU_SHOP_CD = @RakusatsuShopCD							
				,DN_SEIYAKU_DATE = @DNSeiyakuDate					
				,SHIIRE_NO = @ShiireNo					
				,CAR_SUB_ID= @CarSubID								
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

