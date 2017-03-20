USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertHisUketoriDetail]    Script Date: 2016/01/28 15:55:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003InsertHisUketoriDetail]
(	
	@ListDocControlNo	DCW003DocControlNo	READONLY	
	,@User						varchar(20)
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: TramD
-- Programmer		: TramD
-- Created Date		: 2016/01/28
-- Comment			: Store insert TH_DOC_UKETORI_DETAIL
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON
	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)

	DECLARE @ct_DOC_CONTROL_NO				varchar(13)


	DECLARE doc_cursor CURSOR 
	FOR SELECT DocControlNo
			FROM @ListDocControlNo
	OPEN doc_cursor

	FETCH NEXT FROM doc_cursor INTO @ct_DOC_CONTROL_NO

		WHILE @@FETCH_STATUS = 0
		BEGIN
		-------------------------------------------------------------------------
		-- Insert History
		-------------------------------------------------------------------------
		EXEC USP_MAKE_HISTORY @ct_DOC_CONTROL_NO,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT

		FETCH NEXT FROM doc_cursor INTO @ct_DOC_CONTROL_NO

		END
	

	CLOSE doc_cursor
    DEALLOCATE doc_cursor 

END

GO

