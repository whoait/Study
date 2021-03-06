USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertDocAutoSearch]    Script Date: 2016/01/28 15:52:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003InsertDocAutoSearch]
(	
	@ListUpdate		DCW003ListUpdate		READONLY
	,@User			varchar(5)
	,@ListSucess	varchar(500)	OUT
	,@ListError		varchar(500)	OUT
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

	DECLARE @ct_RACK_NO		char(1)
	DECLARE @ct_FILE_NO		char(4)
	DECLARE @ct_CHASSIS_NO	varchar(25)
	DECLARE @ct_FLG			int = 0

	DECLARE auto_cursor CURSOR 
	FOR SELECT RackNo, FileNo, ChassisNo	FROM @ListUpdate

	OPEN auto_cursor

	FETCH NEXT FROM auto_cursor INTO @ct_RACK_NO, @ct_FILE_NO, @ct_CHASSIS_NO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@ct_RACK_NO IS NOT NULL AND @ct_FILE_NO IS NOT NULL)
		BEGIN
			IF @ct_FLG = 0
			BEGIN
				DELETE FROM TT_DOC_AUTO_SEARCH
				SET @ct_FLG = 1
			END

			IF(
				EXISTS (
					SELECT *
						FROM [TT_DOC_AUTO_SEARCH] WITH(NOLOCK)					
					WHERE 
						[TT_DOC_AUTO_SEARCH].FILE_NO = @ct_FILE_NO
					AND [TT_DOC_AUTO_SEARCH].RACK_NO = @ct_RACK_NO
					)			
			)
			BEGIN
				INSERT INTO TT_DOC_AUTO_SEARCH
				(
					[TT_DOC_AUTO_SEARCH].RACK_NO
					,[TT_DOC_AUTO_SEARCH].FILE_NO
					,[TT_DOC_AUTO_SEARCH].CHASSIS_NO
					,[TT_DOC_AUTO_SEARCH].CREATE_DATE
					,[TT_DOC_AUTO_SEARCH].CREATE_USER_CD
					,[TT_DOC_AUTO_SEARCH].UPDATE_DATE
					,[TT_DOC_AUTO_SEARCH].UPDATE_USER_CD
					,[TT_DOC_AUTO_SEARCH].DELETE_FLG
				)
				VALUES
				(	@ct_RACK_NO
					,@ct_FILE_NO
					,@ct_CHASSIS_NO
					,GETDATE()
					,@User
					,GETDATE()
					,@User
					,0
				)
			END
			
			--SET @ListSucess = CONCAT(@ListSucess,','+@ct_CHASSIS_NO)
			SET @ListSucess = ISNULL(@ListSucess,'') + ', '+ ISNULL(@ct_CHASSIS_NO,'')
		END
		ELSE
		BEGIN
			--SET @ListError = CONCAT(@ListError,','+@ct_CHASSIS_NO)
			SET @ListError = ISNULL(@ListError,'') + ', ' + ISNULL(@ct_CHASSIS_NO,'')
		END
		FETCH NEXT FROM auto_cursor INTO @ct_RACK_NO, @ct_FILE_NO, @ct_CHASSIS_NO
	END

	CLOSE auto_cursor
    DEALLOCATE auto_cursor   
END

GO

