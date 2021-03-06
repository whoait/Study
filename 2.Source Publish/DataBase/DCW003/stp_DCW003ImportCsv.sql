IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003ImportCsv' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003ImportCsv
GO


CREATE PROC [dbo].[stp_DCW003ImportCsv]
(	
	@ListCsv			DCW003Csv		READONLY
	,@User				varchar(10)
	,@ListError			varchar(8000)	OUT
	,@ListErrorExist	varchar(8000)	OUT
	,@ListNoMap			varchar(8000)	OUT
	,@ListImport		varchar(8000)	OUT
	,@ListDocControlNo	varchar(8000)	OUT
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

	DECLARE @ct_CHASSIS_NO varchar(20)
	DECLARE @ct_RACFILE_NO varchar(5)
	DECLARE @ct_RESULT	int
	DECLARE @ct_RACK_FILE_NO	int
	DECLARE @ct_DOC_CONTROL_NO	char(13)
	DECLARE @ct_DOC_STATUS	char(3)
	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)
	DECLARE @CON_SAIBAN_KBN_SEQ 					CHAR(3)	= '101'
	DECLARE @ct_REPORT_TYPE char(1)
	DECLARE @ct_TOROKUNO varchar(24)

	DECLARE csv_cursor CURSOR 
	FOR SELECT ChassisNo, RacFileNo, ReportType, TorokuNo FROM @ListCsv

	OPEN csv_cursor
	FETCH NEXT FROM csv_cursor INTO @ct_CHASSIS_NO, @ct_RACFILE_NO, @ct_REPORT_TYPE, @ct_TOROKUNO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Check exist in TT_DN_CAR_INFO
		IF(
			NOT EXISTS(SELECT 1  
					FROM TT_DN_CAR_INFO WITH(NOLOCK)	
					WHERE [TT_DN_CAR_INFO].CHASSIS_NO = @ct_CHASSIS_NO
					AND [TT_DN_CAR_INFO].DELETE_FLG = 0)
		)
		BEGIN
			--SET @ListNoMap = CONCAT(@ListNoMap,', '+ @ct_CHASSIS_NO)
			SET @ListNoMap = ISNULL(@ListNoMap,'') + ', '+ ISNULL(@ct_CHASSIS_NO,'')
			SET @ct_RESULT = NULL
			FETCH NEXT FROM csv_cursor INTO @ct_CHASSIS_NO, @ct_RACFILE_NO, @ct_REPORT_TYPE, @ct_TOROKUNO
		END
		ELSE
		BEGIN
			--Check exist in TT_DOC_CONTROL
			SELECT TOP 1 
				@ct_RESULT			=	1
				,@ct_DOC_STATUS		=	[TT_DOC_CONTROL].DOC_STATUS
				,@ct_DOC_CONTROL_NO	=	[TT_DOC_CONTROL].DOC_CONTROL_NO
			FROM TT_DOC_CONTROL 
			WHERE [TT_DOC_CONTROL].CHASSIS_NO = @ct_CHASSIS_NO 
			
			AND [TT_DOC_CONTROL].DOC_STATUS <> '105'

			SELECT TOP 1
				@ct_RACK_FILE_NO = 1
			FROM TT_DOC_CONTROL
			WHERE [TT_DOC_CONTROL].CHASSIS_NO = @ct_CHASSIS_NO 
			AND ([TT_DOC_CONTROL].RACK_NO + [TT_DOC_CONTROL].FILE_NO) = @ct_RACFILE_NO
			AND [TT_DOC_CONTROL].DOC_STATUS IN ('102','103','104')

			IF (@ct_RESULT IS NULL AND @ct_RACK_FILE_NO IS NULL)
			BEGIN
				
				EXEC USP_GET_SAIBAN @CON_SAIBAN_KBN_SEQ,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
	
				-------------------------------------------------------------------------
				-- Insert 
				-------------------------------------------------------------------------
				INSERT INTO TT_DOC_CONTROL
				(
				[TT_DOC_CONTROL].DOC_CONTROL_NO
				,[TT_DOC_CONTROL].SHOHIN_TYPE
				,[TT_DOC_CONTROL].CHASSIS_NO
				,[TT_DOC_CONTROL].DOC_STATUS
				,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO
				,[TT_DOC_CONTROL].SHOP_CD
				,[TT_DOC_CONTROL].RAKUSATSU_SHOP_CD
				,[TT_DOC_CONTROL].DN_SEIYAKU_DATE
				,[TT_DOC_CONTROL].BBNO
				,[TT_DOC_CONTROL].SHIIRE_NO
				,[TT_DOC_CONTROL].NENSHIKI
				,[TT_DOC_CONTROL].MAKER_NAME
				,[TT_DOC_CONTROL].CAR_NAME
				,[TT_DOC_CONTROL].GRADE_NAME
				,[TT_DOC_CONTROL].KATASHIKI
				,[TT_DOC_CONTROL].CC
				,[TT_DOC_CONTROL].JOSHA_TEIIN_NUM
				,[TT_DOC_CONTROL].KEI_CAR_FLG
				,[TT_DOC_CONTROL].TOROKU_NO
				,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE
				,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE
				,[TT_DOC_CONTROL].MASSHO_FLG
				,[TT_DOC_CONTROL].RACK_NO
				,[TT_DOC_CONTROL].FILE_NO
				,[TT_DOC_CONTROL].CAR_ID
				,[TT_DOC_CONTROL].CAR_SUB_ID
				,[TT_DOC_CONTROL].CREATE_DATE
				,[TT_DOC_CONTROL].CREATE_USER_CD
				,[TT_DOC_CONTROL].UPDATE_DATE
				,[TT_DOC_CONTROL].UPDATE_USER_CD
				,[TT_DOC_CONTROL].DELETE_FLG
				,[TT_DOC_CONTROL].SHIIRE_CANSEL_FLG
			)
			SELECT TOP 1
				@p_saiban_value								
				,'101'					
				,[TT_DN_CAR_INFO].CHASSIS_NO		
				,'101'						
				,[TT_DN_CAR_INFO].SHUPPINN_TOROKU_NO
				,[TT_DN_CAR_INFO].SHOP_CD								
				,[TT_DN_CAR_INFO].RAKUSATSU_SHOP_CD						
				,[TT_DN_CAR_INFO].DN_SEIYAKU_DATE						
				,[TT_DN_CAR_INFO].BBNO									
				,[TT_DN_CAR_INFO].SHIIRE_NO								
				,[TT_DN_CAR_INFO].NENSHIKI								
				,[TT_DN_CAR_INFO].MAKER_NAME							
				,[TT_DN_CAR_INFO].CAR_NAME								
				,[TT_DN_CAR_INFO].GRADE_NAME							
				,[TT_DN_CAR_INFO].KATASHIKI								
				,[TT_DN_CAR_INFO].CC								
				,[TT_DN_CAR_INFO].JOSHA_TEIIN_NUM
				,[TT_DN_CAR_INFO].KEI_CAR_FLG
				, @ct_TOROKUNO
				--,[TT_DN_CAR_INFO].TOROKU_NO
				,CASE
					WHEN @ct_REPORT_TYPE = '2' OR @ct_REPORT_TYPE = '4' THEN NULL
					ELSE [TT_DN_CAR_INFO].SHAKEN_LIMIT_DATE
				 END
				--,[TT_DN_CAR_INFO].SHAKEN_LIMIT_DATE
				,[TT_DN_CAR_INFO].SHORUI_LIMIT_DATE			
				,CASE 
					WHEN @ct_REPORT_TYPE = '1' THEN 0 
					WHEN @ct_REPORT_TYPE = '2' OR @ct_REPORT_TYPE = '4' THEN 1					
					ELSE [TT_DN_CAR_INFO].MASSHO_FLG
				 END
				--,[TT_DN_CAR_INFO].MASSHO_FLG
				,LEFT(@ct_RACFILE_NO,1)
				,RIGHT(@ct_RACFILE_NO,4)
				,[TT_DN_CAR_INFO].CAR_ID
				,[TT_DN_CAR_INFO].CAR_SUB_ID
				,GETDATE()							
				,@User						
				,GETDATE()							
				,@User						
				,0
				,CASE
					WHEN [TT_DN_CAR_INFO].CANCEL_FLG = '1' THEN 1
					ELSE ''			
				 END					
											
			FROM TT_DN_CAR_INFO WITH(NOLOCK)	
			WHERE [TT_DN_CAR_INFO].CHASSIS_NO = @ct_CHASSIS_NO
			AND [TT_DN_CAR_INFO].DELETE_FLG = 0
			ORDER BY [TT_DN_CAR_INFO].DN_SEIYAKU_DATE DESC

				SET @ListDocControlNo = ISNULL(@ListDocControlNo,'') + ','+ ISNULL(@p_saiban_value,'')
				SET @ListImport = ISNULL(@ListImport,'') + ', '+ ISNULL(@ct_CHASSIS_NO,'')

				-------------------------------------------------------------------------
				-- Insert History
				-------------------------------------------------------------------------
				EXEC USP_MAKE_HISTORY @ct_DOC_CONTROL_NO,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT


				--SET @ListDocControlNo = CONCAT(@ListDocControlNo,','+ @p_saiban_value)
				--SET @ListImport = CONCAT(@ListImport,', '+ @ct_CHASSIS_NO)
			
			END

			ELSE IF (@ct_RESULT IS NOT NULL AND @ct_DOC_STATUS = '101' AND @ct_RACK_FILE_NO IS NULL)
			BEGIN
				
				-------------------------------------------------------------------------
				-- Update 
				-------------------------------------------------------------------------
				UPDATE TT_DOC_CONTROL SET
				[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO = [DN_INFO].SHUPPINN_TOROKU_NO
				,[TT_DOC_CONTROL].SHOP_CD = [DN_INFO].SHOP_CD
				,[TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [DN_INFO].RAKUSATSU_SHOP_CD
				,[TT_DOC_CONTROL].DN_SEIYAKU_DATE = [DN_INFO].DN_SEIYAKU_DATE
				,[TT_DOC_CONTROL].BBNO = [DN_INFO].BBNO
				,[TT_DOC_CONTROL].SHIIRE_NO = [DN_INFO].SHIIRE_NO
				,[TT_DOC_CONTROL].NENSHIKI = [DN_INFO].NENSHIKI
				,[TT_DOC_CONTROL].MAKER_NAME = [DN_INFO].MAKER_NAME
				,[TT_DOC_CONTROL].CAR_NAME = [DN_INFO].CAR_NAME
				,[TT_DOC_CONTROL].GRADE_NAME = [DN_INFO].GRADE_NAME
				,[TT_DOC_CONTROL].KATASHIKI = [DN_INFO].KATASHIKI
				,[TT_DOC_CONTROL].CC = [DN_INFO].CC
				,[TT_DOC_CONTROL].JOSHA_TEIIN_NUM = [DN_INFO].JOSHA_TEIIN_NUM
				,[TT_DOC_CONTROL].KEI_CAR_FLG = [DN_INFO].KEI_CAR_FLG
				,[TT_DOC_CONTROL].TOROKU_NO = @ct_TOROKUNO
				, [TT_DOC_CONTROL].SHAKEN_LIMIT_DATE=
				CASE
					WHEN @ct_REPORT_TYPE = '2' OR @ct_REPORT_TYPE = '4' THEN NULL
					ELSE [DN_INFO].SHAKEN_LIMIT_DATE
				 END
				--,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE = [DN_INFO].SHAKEN_LIMIT_DATE
				,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE = [DN_INFO].SHORUI_LIMIT_DATE
				,[TT_DOC_CONTROL].MASSHO_FLG = 
				CASE 
					WHEN @ct_REPORT_TYPE = '1' THEN 0 
					WHEN @ct_REPORT_TYPE = '2' OR @ct_REPORT_TYPE = '4' THEN 1					
					ELSE  [DN_INFO].MASSHO_FLG
				 END
				--,[TT_DOC_CONTROL].MASSHO_FLG = [DN_INFO].MASSHO_FLG
				,[TT_DOC_CONTROL].RACK_NO = LEFT(@ct_RACFILE_NO,1)
				,[TT_DOC_CONTROL].FILE_NO = RIGHT(@ct_RACFILE_NO,4)
				,[TT_DOC_CONTROL].CAR_ID = [DN_INFO].CAR_ID
				,[TT_DOC_CONTROL].CAR_SUB_ID = [DN_INFO].CAR_SUB_ID
				,[TT_DOC_CONTROL].UPDATE_DATE = GETDATE()
				,[TT_DOC_CONTROL].UPDATE_USER_CD = @User
				,[TT_DOC_CONTROL].SHIIRE_CANSEL_FLG =
				CASE
					WHEN [DN_INFO].CANCEL_FLG = '1' THEN 1
					ELSE ''			
				 END

				FROM
				(SELECT TOP 1 * FROM TT_DN_CAR_INFO 
					WHERE [TT_DN_CAR_INFO].CHASSIS_NO	= @ct_CHASSIS_NO
					AND [TT_DN_CAR_INFO].DELETE_FLG = 0		
					ORDER BY TT_DN_CAR_INFO.DN_SEIYAKU_DATE DESC) AS DN_INFO

				WHERE [TT_DOC_CONTROL].CHASSIS_NO = @ct_CHASSIS_NO
				AND [TT_DOC_CONTROL].DOC_STATUS = '101'
				AND [TT_DOC_CONTROL].DELETE_FLG = 0
				
				SET @ListDocControlNo = ISNULL(@ListDocControlNo,'') +  ','+ ISNULL(@ct_DOC_CONTROL_NO,'')
				SET @ListImport = ISNULL(@ListImport,'') + ', '+ ISNULL(@ct_CHASSIS_NO,'')

				-------------------------------------------------------------------------
				-- Insert History
				-------------------------------------------------------------------------
				EXEC USP_MAKE_HISTORY @ct_DOC_CONTROL_NO,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT


				--SET @ListDocControlNo = CONCAT(@ListDocControlNo,','+ @ct_DOC_CONTROL_NO)
				--SET @ListImport = CONCAT(@ListImport,', '+ @ct_CHASSIS_NO)

			END
			ELSE
			BEGIN
				--SET @ListError = CONCAT(@ListError,'||'+ @ct_CHASSIS_NO)
				IF (@ct_RACK_FILE_NO = 1)
				BEGIN
					SET @ListErrorExist = ISNULL(@ListErrorExist,'') + ', ファイルNO ' + ISNULL(@ct_RACFILE_NO,'') + ',車台番号' + ISNULL(@ct_CHASSIS_NO,'')
				END

				ELSE

				BEGIN
					SET @ListError = ISNULL(@ListError,'') + ', ファイルNO '+ ISNULL(@ct_RACFILE_NO,'') + ',車台番号' + ISNULL(@ct_CHASSIS_NO,'')
				END

			END

			SET @ct_RESULT = NULL
			SET @ct_RACK_FILE_NO = NULL
			FETCH NEXT FROM csv_cursor INTO @ct_CHASSIS_NO, @ct_RACFILE_NO, @ct_REPORT_TYPE, @ct_TOROKUNO
		END
	END

	CLOSE csv_cursor
    DEALLOCATE csv_cursor     
	
END
GO