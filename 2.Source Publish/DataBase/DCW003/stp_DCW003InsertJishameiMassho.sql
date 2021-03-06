IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003InsertJishameiMassho' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003InsertJishameiMassho
GO

CREATE PROC [dbo].[stp_DCW003InsertJishameiMassho]
(	
	@ListCsv		DCW003Csv		READONLY
	,@User			varchar(5)
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

	DECLARE @ct_DOC_CONTROL_NO	varchar(13)
	DECLARE @ct_IRAI_DATE		datetime
	DECLARE @ct_SHOP_CD			char(6)
	DECLARE @ct_GENSHA_LOCATION	varchar(25)
	DECLARE @ct_CAR_NAME		varchar(100)
	DECLARE @ct_JM_TYPE			char(3)
	DECLARE @ct_NOTE			varchar(1000)

	DECLARE auto_cursor CURSOR 
	FOR SELECT DocControlNo, IraiDate, ShopCd, GenshaLocation, CarName, JMType, Note	FROM @ListCsv

	OPEN auto_cursor

	FETCH NEXT FROM auto_cursor INTO @ct_DOC_CONTROL_NO, @ct_IRAI_DATE, @ct_SHOP_CD, @ct_GENSHA_LOCATION, @ct_CAR_NAME, @ct_JM_TYPE, @ct_NOTE

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(
			NOT EXISTS(SELECT 1  
					FROM TT_DOC_JISHAMEI_MASSHO_IF WITH(NOLOCK)	
					WHERE [TT_DOC_JISHAMEI_MASSHO_IF].DOC_CONTROL_NO = @ct_DOC_CONTROL_NO
					AND [TT_DOC_JISHAMEI_MASSHO_IF].DELETE_FLG = 0)
		)
		BEGIN
			--Insert
			INSERT INTO TT_DOC_JISHAMEI_MASSHO_IF
			(
				[TT_DOC_JISHAMEI_MASSHO_IF].DOC_CONTROL_NO
				,[TT_DOC_JISHAMEI_MASSHO_IF].IRAI_DATE
				,[TT_DOC_JISHAMEI_MASSHO_IF].SHOP_CD
				,[TT_DOC_JISHAMEI_MASSHO_IF].GENSHA_LOCATION
				,[TT_DOC_JISHAMEI_MASSHO_IF].CAR_NAME
				,[TT_DOC_JISHAMEI_MASSHO_IF].CHASSIS_NO
				,[TT_DOC_JISHAMEI_MASSHO_IF].JISHAME_MASSHO_TYPE
				,[TT_DOC_JISHAMEI_MASSHO_IF].NOTE
				,[TT_DOC_JISHAMEI_MASSHO_IF].CREATE_DATE
				,[TT_DOC_JISHAMEI_MASSHO_IF].CREATE_USER_CD
				,[TT_DOC_JISHAMEI_MASSHO_IF].UPDATE_DATE
				,[TT_DOC_JISHAMEI_MASSHO_IF].UPDATE_USER_CD
				,[TT_DOC_JISHAMEI_MASSHO_IF].DELETE_FLG
			)
			VALUES
			(
				@ct_DOC_CONTROL_NO
				,@ct_IRAI_DATE
				,@ct_SHOP_CD
				,@ct_GENSHA_LOCATION
				,@ct_CAR_NAME
				,@ct_CHASSIS_NO
				,@ct_JM_TYPE
				,@ct_NOTE
				,GETDATE()
				,@User
				,GETDATE()
				,@User
				,0
			)
		END
		ELSE
		BEGIN
			UPDATE TT_DOC_JISHAMEI_MASSHO_IF SET
			[TT_DOC_JISHAMEI_MASSHO_IF].IRAI_DATE				= @ct_IRAI_DATE
			,[TT_DOC_JISHAMEI_MASSHO_IF].SHOP_CD				= @ct_SHOP_CD
			,[TT_DOC_JISHAMEI_MASSHO_IF].GENSHA_LOCATION		= @ct_GENSHA_LOCATION
			,[TT_DOC_JISHAMEI_MASSHO_IF].CAR_NAME				= @ct_CAR_NAME
			,[TT_DOC_JISHAMEI_MASSHO_IF].CHASSIS_NO				= @ct_CHASSIS_NO
			,[TT_DOC_JISHAMEI_MASSHO_IF].JISHAME_MASSHO_TYPE	= @ct_JM_TYPE
			,[TT_DOC_JISHAMEI_MASSHO_IF].NOTE					= @ct_NOTE
			,[TT_DOC_JISHAMEI_MASSHO_IF].UPDATE_DATE			= GETDATE()
			,[TT_DOC_JISHAMEI_MASSHO_IF].UPDATE_USER_CD			= @User
			WHERE
			[TT_DOC_JISHAMEI_MASSHO_IF].DOC_CONTROL_NO			= @ct_DOC_CONTROL_NO
			AND [TT_DOC_JISHAMEI_MASSHO_IF].DELETE_FLG			=0
		END

		FETCH NEXT FROM auto_cursor INTO @ct_DOC_CONTROL_NO, @ct_IRAI_DATE, @ct_SHOP_CD, @ct_GENSHA_LOCATION, @ct_CAR_NAME, @ct_JM_TYPE, @ct_NOTE
	END

	CLOSE auto_cursor
    DEALLOCATE auto_cursor   
END
GO


