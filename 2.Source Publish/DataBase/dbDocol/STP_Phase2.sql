USE [dbDocPH2]
GO

/****** Object:  StoredProcedure [dbo].[USP_GET_SAIBAN]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* *****************************************************************************
 *  System Name				: 
 *  Component Name			: USP_GET_SAIBAN
 *
 *  Create Date				: 
 *  Creator					: 
 *  Contents				: 新規に各種IDを採番し、そのIDを返す。
 * 
 *  ParmeterInfomation		@p_saiban_kbn				VARCHAR(3),				--採番区分
 *							@p_sys_kbn					VARCHAR(3),				--システム区分
 *							@p_pgm_cd					VARCHAR(50),			--プログラムコード
 *							@p_user_cd					VARCHAR(6),				--ユーザコード
 *							@p_saiban_value				VARCHAR(16),			--採番値
 *							@p_result_id				INT,					--結果ID(ユーザ定義エラー:-1)
 *							@p_result_msg				VARCHAR(2000),			--結果メッセージ
 *  Update Date				: 2011/03/03
 *  Updater					: Atsushi Takahashi
 *  Update Contents			: 自律型トランザクションに変更
 * 
 * *****************************************************************************/

CREATE PROCEDURE [dbo].[USP_GET_SAIBAN]
(
	@p_saiban_kbn				VARCHAR(3),					--採番区分
	--@p_sys_kbn					VARCHAR(3),					--システム区分
	@p_pgm_cd					VARCHAR(50),				--プログラムコード
	@p_user_cd					VARCHAR(6),					--ユーザコード
	@p_saiban_value				VARCHAR(16)		OUTPUT,		--採番値
	@p_result_id				INT				OUTPUT,		--結果ID
	@p_result_msg				VARCHAR(2000)	OUTPUT		--結果メッセージ
)
AS
	/***************/ 
	/*  変数	　*/
	/***************/
	DECLARE @active_spid		INT				--アクティブなサーバープロセスID
	DECLARE @login_time			DATETIME		--ログイン時刻
	DECLARE	@p_inner_result		INT				--内部処理の実行結果
	
BEGIN
    SET NOCOUNT ON;

	--SET @active_spid = sysdb.ssma_oracle.get_active_spid()
	--SET @login_time = sysdb.ssma_oracle.get_active_login_time()

	/********************/ 
	/*  Try			*/
	/********************/
	BEGIN TRY
		--EXECUTE 
	--	master.dbo.xp_ora2ms_exec2
	--		@active_spid,
	--		@login_time, 
	----		'"dbCLAIM"',
	--		'dbo',
			EXECUTE dbo.USP_GET_SAIBAN_SUBSTANCE
			@p_saiban_kbn,
			--@p_sys_kbn,
			@p_pgm_cd,
			@p_user_cd,
			@p_saiban_value OUTPUT,
			@p_result_id OUTPUT,
			@p_result_msg OUTPUT,
			@p_inner_result OUTPUT
			
			--SET @p_saiban_value = 'AAA'
			RETURN @p_inner_result
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

		IF (@p_result_id = 0)
		BEGIN
			SET @p_result_id = ERROR_NUMBER()
		END
		IF (@p_result_msg IS NULL) OR (@p_result_msg = '')
		BEGIN
			SET @p_result_msg = ERROR_MESSAGE()
		END

		RETURN 1
	END CATCH
END


GO

/****** Object:  StoredProcedure [dbo].[USP_GET_SAIBAN_SUBSTANCE]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* *****************************************************************************
 *  System Name				: 
 *  Component Name			: USP_GET_SAIBAN_SUBSTANCE
 *
 *  Create Date				: 
 *  Creator					: 
 *  Contents				: 新規に各種IDを採番し、そのIDを返す。
 * 
 *  ParmeterInfomation		@p_saiban_kbn				VARCHAR(3),				--採番区分
 *							@p_pgm_cd					VARCHAR(50),			--プログラムコード
 *							@p_user_cd					VARCHAR(6),				--ユーザコード
 *							@p_saiban_value				VARCHAR(16),			--採番値
 *							@p_result_id				INT,					--結果ID(ユーザ定義エラー:-1)
 *							@p_result_msg				VARCHAR(2000),			--結果メッセージ
 *							@p_inner_result				INT						--結果コード
 *  Update Date				: 
 *  Updater					: 
 *  Update Contents			: 
 * 
 * *****************************************************************************/

CREATE PROCEDURE [dbo].[USP_GET_SAIBAN_SUBSTANCE]
(
	@p_saiban_kbn				VARCHAR(3),					--採番区分
	@p_pgm_cd					VARCHAR(50),				--プログラムコード
	@p_user_cd					VARCHAR(6),					--ユーザコード
	@p_saiban_value				VARCHAR(16)		OUTPUT,		--採番値
	@p_result_id				INT				OUTPUT,		--結果ID
	@p_result_msg				VARCHAR(2000)	OUTPUT,		--結果メッセージ
	@p_inner_result				INT				OUTPUT		--結果コード
)
AS
	/***************/ 
	/*  定数	　*/
	/***************/
	DECLARE @CON_NUMBER_TYPE				VARCHAR(30) = '採番値桁数';	--定数マスタ_区分（採番値桁数）

	/***************/ 
	/*  変数	　*/
	/***************/
	DECLARE	@formatNum				INT				--成型桁数
	DECLARE	@sysDate				DATETIME		--システム日付
	DECLARE	@wkSaibanVal			INT				--採番値（一時格納）
	
BEGIN
    SET NOCOUNT ON;

	/***************/ 
	/*  初期化	　 */
	/***************/
	----- 変数  -----
	SET @p_result_id =0			--OUTPUT結果ID
	SET @p_result_msg = ''		--OUTPUT結果メッセージ
	SET @formatNum= 0			--成型桁数


	/***************/ 
	/*  処理	　 */
	/***************/
	SET	LOCK_TIMEOUT 60000                      --1分待機

	/********************/ 
	/*  Try			*/
	/********************/
	BEGIN TRY

		BEGIN TRANSACTION
			/*----- システム日付取得 -----*/
			SET @sysDate = CONVERT(varchar, GETDATE(), 112)

			/*----- 採番テーブル値取得 -----*/
			SELECT 
				@wkSaibanVal = COUNTER_VALUE				--カウンタ値
			FROM 
				TM_NUMBERING_CONTROL					--採番管理テーブル
			WITH
				(ROWLOCK, UPDLOCK)							--行ロック、更新ロック
			WHERE
				NUMBERING_TYPE = @p_saiban_kbn			--採番区分
			AND ADMIN_DATE = @sysDate					--管理日付

			IF(@wkSaibanVal IS NULL) OR (@wkSaibanVal = '')
			BEGIN
				SET @wkSaibanVal = 1
				/*----- 採番テーブル値追加 -----*/
				INSERT INTO				
					TM_NUMBERING_CONTROL
					(
					NUMBERING_TYPE,						--採番区分
					ADMIN_DATE,							--管理日付
					COUNTER_VALUE,						--カウンタ値
					CREATE_DATE,						--作成日時
					CREATE_USER_CD,						--作成ユーザコード
					CREATE_PG_CD,						--作成プログラムコード
					UPDATE_DATE,						--更新日時
					UPDATE_USER_CD,						--更新ユーザコード
					UPDATE_PG_CD,						--更新プログラムコード
					DELETE_FLG							--削除フラグ
					)
				VALUES
					(
					@p_saiban_kbn,
					@sysDate,
					@wkSaibanVal,
					GETDATE(),
					@p_user_cd,
					@p_pgm_cd,
					GETDATE(),
					@p_user_cd,
					@p_pgm_cd,
					'0'
					)
			END
			ELSE
			BEGIN
				/*----- 採番テーブル値インクリメント -----*/
				SET @wkSaibanVal = @wkSaibanVal + 1			--インクリメント
				UPDATE
					TM_NUMBERING_CONTROL
				SET
					COUNTER_VALUE = @wkSaibanVal,			--カウンタ
					UPDATE_DATE = GETDATE(),				--更新日時
					UPDATE_USER_CD = @p_user_cd,			--更新ユーザコード
					UPDATE_PG_CD = @p_pgm_cd,				--更新プログラムコード
					DELETE_FLG = '0'						--削除フラグ
				WHERE
						NUMBERING_TYPE = @p_saiban_kbn			--採番区分
					AND ADMIN_DATE = @sysDate					--管理日付
			END

		/*----- 採番値成型 -----*/
		/*----- 成型のための桁数取得 -----*/
			/*----- 採番値成型 -----*/
			/*----- 成型のための桁数取得 -----*/
			SELECT
				@formatNum = CAST(VALUE AS INT)	--値
			FROM
				TM_CONST					--定数マスタ
			WITH
				(NOLOCK)						--行ロックなし
			WHERE
				TYPE = @CON_NUMBER_TYPE					--区分
			AND TYPE_VALUE = @p_saiban_kbn					--区分値
			AND DELETE_FLG = '0'							--削除フラグ

		IF LEN(CONVERT(varchar, @wkSaibanVal)) > @formatNum
		BEGIN
			/*-- 有効桁数オーバー --*/
			IF @@TRANCOUNT <> 0
			BEGIN
				ROLLBACK TRANSACTION
			END

			SET @p_result_id = -1
			SET @p_result_msg = '採番可能な数値を超えています'
			SET @p_inner_result = 1
			RETURN 1
		END

		/*----- 成型 -----*/
		SET @p_saiban_value = CONVERT(varchar, @sysDate,112) + RIGHT(REPLICATE('0', @formatNum) + CONVERT(varchar, @wkSaibanVal), @formatNum)
		COMMIT TRANSACTION

		SET @p_inner_result = 0
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

		IF (@p_result_id = 0)
		BEGIN
			SET @p_result_id = ERROR_NUMBER()
		END
		IF (@p_result_msg IS NULL) OR (@p_result_msg = '')
		BEGIN
			SET @p_result_msg = ERROR_MESSAGE()
		END

		SET @p_inner_result = 1
		RETURN 1
	END CATCH
END


GO

/****** Object:  StoredProcedure [dbo].[USP_MAKE_HISTORY]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* *****************************************************************************
 *  System Name				: DOC_DB
 *  Component Name			: USP_MAKE_HISTORY
 *
 *  Create Date				: 
 *  Creator					: 
 *  Contents				: 履歴登録処理
 *
 *  ParmeterInfomation	
 *	@p_doc_control_no						CHAR(13)					伝票番号
 *	@p_pgm_cd							VARCHAR(50)					プログラムコード
 *	@p_user_cd							VARCHAR(6)					ユーザコード
 *	@p_seq_upd_history					CHAR(15)		OUTPUT,		SEQ更新履歴
 *	@p_resultId							INT				OUTPUT,		結果ID
 *	@p_result_msg						VARCHAR(2000)	OUTPUT		結果メッセージ
 *
 *  Update Date				:
 *  Updater					:
 *  Update Contents			:
 *
 *  Copyright(c) 
 * *****************************************************************************/

CREATE PROCEDURE [dbo].[USP_MAKE_HISTORY]
(
	@p_doc_control_no						CHAR(13),						--書類管理番号
	@p_pgm_cd							VARCHAR(50),					--プログラムコード
	@p_user_cd							VARCHAR(6),						--ユーザコード
	@p_seq_upd_history					CHAR(15)		OUTPUT,			--履歴番号
	@p_result_id						INT				OUTPUT,			--結果ID			
	@p_result_msg						VARCHAR(2000)	OUTPUT			--結果メッセージ

)
AS
	/***************/ 
	/*  定数	　*/
	/***************/
	DECLARE	@CON_RESULT_SUCCESS INT		= 0	--成功（実行結果）
	DECLARE @CON_SAIBAN_KBN_SEQ_UPDATE_HISTORY 		CHAR(3)	= '102'	--履歴番号


	/***************/ 
	/*  変数	　*/
	/***************/
	DECLARE	@innerResult 		INT		= 0	--内部処理の実行結果
	DECLARE @active_spid		INT			--アクティブなサーバープロセスID
	DECLARE @login_time		DATETIME		--ログイン時刻
	DECLARE	@p_inner_result		INT			--内部処理の実行結果
	
BEGIN
    SET NOCOUNT ON;

	/***************/ 
	/*  初期化	　 */
	/***************/

	----- 変数  -----
	SET @p_result_id =0								--OUTPUT結果ID
	SET @p_result_msg = ''							--OUTPUT結果メッセージ
	SET @p_seq_upd_history = ''						--OUTPUT結果SEQ更新履歴

	/********************/
	/*  Try				*/
	/********************/
	BEGIN TRY

		/*-- 個車更新チェック --*/
		IF @p_doc_control_no IS NOT NULL AND @p_doc_control_no != ''	--書類管理番号
		BEGIN
			--SET @active_spid = sysdb.ssma_oracle.get_active_spid()
			--SET @login_time = sysdb.ssma_oracle.get_active_login_time()

--			EXECUTE master.dbo.xp_ora2ms_exec2
--				@active_spid,
--				@login_time, 
----				'"dbCLAIM"',
--				'dbo',
				EXECUTE dbo.USP_GET_SAIBAN_SUBSTANCE
				@CON_SAIBAN_KBN_SEQ_UPDATE_HISTORY,
				@p_pgm_cd,
				@p_user_cd,
				@p_seq_upd_history	OUTPUT,
				@p_result_id	OUTPUT,
				@p_result_msg	OUTPUT,
				@p_inner_result	OUTPUT

			IF @p_inner_result != @CON_RESULT_SUCCESS
			BEGIN
				/*-- 採番エラー	--*/
				RETURN 1
			END
			
			/*-- 書類管理 --*/
			INSERT INTO TH_DOC_CONTROL	
			(
			HISTORY_NO
			,HISTORY_TOROKU_DATE
			,DOC_CONTROL_NO
			   ,SHOHIN_TYPE
			   ,CHASSIS_NO
			   ,DOC_STATUS
			   ,SHIIRE_SHUPPINN_TOROKU_NO
			   ,URIAGE_SHUPPINN_TOROKU_NO
			   ,SHOP_CD
			   ,RAKUSATSU_SHOP_CD
			   ,SHIIRE_AA_KAIJO
			   ,URIAGE_AA_KAIJO
			   ,AA_KAISAI_KAISU
			   ,AA_KAISAI_DATE
			   ,AA_SHUPPIN_NO
			   ,DN_SEIYAKU_DATE
			   ,BBNO
			   ,SHIIRE_NO
			   ,NENSHIKI
			   ,MAKER_NAME
			   ,CAR_NAME
			   ,GRADE_NAME
			   ,KATASHIKI
			   ,CC
			   ,JOSHA_TEIIN_NUM
			   ,KEI_CAR_FLG
			   ,TOROKU_NO
			   ,SHAKEN_LIMIT_DATE
			   ,SHORUI_LIMIT_DATE
			   ,MEIHEN_SHAKEN_TOROKU_DATE
			   ,JISHAMEI_FLG
			   ,MASSHO_FLG
			   ,DOC_NYUKO_DATE
			   ,DOC_SHUKKO_DATE
			   ,JISHAMEI_IRAI_SHUKKO_DATE
			   ,JISHAMEI_KANRYO_NYUKO_DATE
			   ,MASSHO_IRAI_SHUKKO_DATE
			   ,MASSHO_KANRYO_NYUKO_DATE
			   ,RACK_NO
			   ,FILE_NO
			   ,MEMO
			   ,CAR_ID
			   ,CAR_SUB_ID
			   ,CREATE_DATE	           --作成日時
			   ,CREATE_USER_CD	           --作成ユーザコード
			   ,CREATE_PG_CD	           --作成プログラムコード
			   ,UPDATE_DATE	           --更新日時
			   ,UPDATE_USER_CD	           --更新ユーザコード
			   ,UPDATE_PG_CD	           --更新プログラムコード
			   ,DELETE_DATE	           --削除日時
			   ,DELETE_FLG	           --削除フラグ
			 )
			(
			SELECT 
					@p_seq_upd_history						 --履歴番号
				   ,GETDATE()	           --履歴番号登録日時
				   ,DOC_CONTROL_NO
				   ,SHOHIN_TYPE
				 ,CHASSIS_NO
				,DOC_STATUS
				   ,SHIIRE_SHUPPINN_TOROKU_NO
				   ,URIAGE_SHUPPINN_TOROKU_NO
				   ,SHOP_CD
				   ,RAKUSATSU_SHOP_CD
				   ,SHIIRE_AA_KAIJO
				   ,URIAGE_AA_KAIJO
				   ,AA_KAISAI_KAISU
				   ,AA_KAISAI_DATE
				   ,AA_SHUPPIN_NO
				   ,DN_SEIYAKU_DATE
				   ,BBNO
				   ,SHIIRE_NO
				   ,NENSHIKI
				   ,MAKER_NAME
				   ,CAR_NAME
				   ,GRADE_NAME
				   ,KATASHIKI
				   ,CC
				   ,JOSHA_TEIIN_NUM
				   ,KEI_CAR_FLG
				   ,TOROKU_NO
				   ,SHAKEN_LIMIT_DATE
				   ,SHORUI_LIMIT_DATE
				   ,MEIHEN_SHAKEN_TOROKU_DATE
				   ,JISHAMEI_FLG
				   ,MASSHO_FLG
				   ,DOC_NYUKO_DATE
				   ,DOC_SHUKKO_DATE
				   ,JISHAMEI_IRAI_SHUKKO_DATE
				   ,JISHAMEI_KANRYO_NYUKO_DATE
				   ,MASSHO_IRAI_SHUKKO_DATE
				   ,MASSHO_KANRYO_NYUKO_DATE
				   ,RACK_NO
				   ,FILE_NO
				   ,MEMO
				   ,CAR_ID
				   ,CAR_SUB_ID
				   ,CREATE_DATE	           --作成日時
				   ,CREATE_USER_CD	           --作成ユーザコード
				   ,CREATE_PG_CD	           --作成プログラムコード
				   ,UPDATE_DATE	           --更新日時
				   ,UPDATE_USER_CD	           --更新ユーザコード
				   ,UPDATE_PG_CD	           --更新プログラムコード
				   ,DELETE_DATE	           --削除日時
				   ,DELETE_FLG	           --削除フラグ
				FROM 
					TT_DOC_CONTROL 
				WHERE
					DOC_CONTROL_NO = @p_doc_control_no
				AND
					DELETE_FLG = '0'
			)

			/*-- 書類受取詳細 --*/
			INSERT INTO TH_DOC_UKETORI_DETAIL	
			(
			   HISTORY_NO	 --履歴番号
			   ,HISTORY_TOROKU_DATE	           --履歴登録日時
				,DOC_CONTROL_NO	
				  ,DOC_FUZOKUHIN_CD
				  ,DOC_COUNT					
				  ,DOC_HAKKO_DATE					
				  ,DOC_UKE_DATE					
				  ,NOTE					
				  ,CREATE_DATE					
				  ,CREATE_USER_CD					
				  ,CREATE_PG_CD					
				  ,UPDATE_DATE					
				  ,UPDATE_USER_CD					
				  ,UPDATE_PG_CD					
				  ,DELETE_DATE					
				  ,DELETE_FLG
			 )
			(
			SELECT 
					@p_seq_upd_history						 --履歴番号
				   ,GETDATE()	           --履歴番号登録日時			
				,DOC_CONTROL_NO	
				  ,DOC_FUZOKUHIN_CD
				  ,DOC_COUNT					
				  ,DOC_HAKKO_DATE					
				  ,DOC_UKE_DATE					
				  ,NOTE					
				  ,CREATE_DATE					
				  ,CREATE_USER_CD					
				  ,CREATE_PG_CD					
				  ,UPDATE_DATE					
				  ,UPDATE_USER_CD					
				  ,UPDATE_PG_CD					
				  ,DELETE_DATE					
				  ,DELETE_FLG
			FROM				 
				   TT_DOC_UKETORI_DETAIL 
			  WHERE
				  DOC_CONTROL_NO = @p_doc_control_no
			  AND
				  DELETE_FLG = '0'
			)
			
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

		IF (@p_result_id = 0)
		BEGIN
			SET @p_result_id = ERROR_NUMBER()
		END

		IF (@p_result_msg IS NULL) OR (@p_result_msg = '')
		BEGIN
			SET @p_result_msg = ERROR_MESSAGE()
		END
		RETURN 1
	END CATCH
END








GO

/****** Object:  StoredProcedure [dbo].[stp_DCW001CheckDomainLogin]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW001CheckDomainLogin]
(
	@domain_Login	NVARCHAR(100)			-- UserName

)
AS
---------------------------------------------------------------------------
-- Version			: 1.0
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2015/14/12
-- Comment			: Create new
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	
	
	
SELECT
	TM_CONST.VALUE
FROM [dbo].[TM_CONST] WITH (NOLOCK)
WHERE
	TM_CONST.VALUE = @domain_Login
	AND
	TM_CONST.TYPE_VALUE = 1
	AND
	TM_CONST.TYPE IN('遷移許可URL');
	
END
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW001UserLogin]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[stp_DCW001UserLogin]
(
	@userName	NVARCHAR(40),			-- UserName
	@password	VARCHAR(20)				-- Password
)
AS
---------------------------------------------------------------------------
-- Version			: 1.0
-- Designer			: Dhanya.Ratheesh
-- Programmer		: Dhanya.Ratheesh
-- Created Date		: 2015/02/15
-- Comment			: Create new
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- Declare constants
	-------------------------------------------------------------------------
	DECLARE @ct_Check_Souce_Flg			SMALLINT		=	1
			, @ct_Current_Date			DATETIME		=	CONVERT(DATE,GETDATE())

	-------------------------------------------------------------------------
	-- Get user
	-------------------------------------------------------------------------
	
	
SELECT
	  [TANTOSHA_CD]
	 ,[TANTOSHA_NAME]
	 ,[PASSWORD]
	 ,[RACK_SEACH_KANO_FLG]
	 ,[EXIST_FLG]
FROM [dbo].[TM_TANTOSHA] WITH (NOLOCK)
WHERE
	[TANTOSHA_CD] = @userName
	AND
	[PASSWORD] = @password
	AND
	[DELETE_FLG] = 0
END







GO

/****** Object:  StoredProcedure [dbo].[stp_DCW002Import]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[stp_DCW002Import]
(
	
	@fileNo		varchar(5),
	@vechicleClassification char(1)	,
	@vechicleRegistrationNo varchar(24)	,
	@numberPlate char(1) ,
	@chassisNo varchar(25)	,
	@motorModel	varchar(12)	,	
	@formType char(1),
	@createUser_CD varchar(10)

	--@CurrentDateTime datetime

)
AS
---------------------------------------------------------------------------
-- Version			: 1.0
-- Designer			: Dhanya.Ratheesh
-- Programmer		: Dhanya.Ratheesh
-- Created Date		: 2015/02/15
-- Comment			: Store Import csv DCW002
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- stp process
	-------------------------------------------------------------------------
	SELECT CONVERT (time, SYSDATETIME())

--SELECT GETDATE() AS CurrentDateTime	

 INSERT INTO [dbo].[TT_DOC_UKETORI_IF]
 (
	 
	  [TT_DOC_UKETORI_IF].RAC_FILE_NO
	 ,[TT_DOC_UKETORI_IF].KEI_CAR_FLG					-----Vechicle classification		
	 ,[TT_DOC_UKETORI_IF].TOROKU_NO						-----Vechicle No
	 ,[TT_DOC_UKETORI_IF].HYOBAN_TYPE					------The number plate
	 ,[TT_DOC_UKETORI_IF].CHASSIS_NO					------The chassis no
	 ,[TT_DOC_UKETORI_IF].GENDOKI_KATASHIKI				------Motor Model
	 ,[TT_DOC_UKETORI_IF].REPORT_TYPE					------Form Type
	,[TT_DOC_UKETORI_IF].CREATE_DATE					------Date and Time of Creation
	,[TT_DOC_UKETORI_IF].CREATE_USER_CD				------Created By
--	 ,[TT_DOC_UKETORI_IF].CREATE_PG_CD					------CreationProgram Code
--	 ,[TT_DOC_UKETORI_IF].UPDATE_DATE					------Date Modified
--	 ,[TT_DOC_UKETORI_IF].UPDATE_USER_CD				------Updated By
--	 ,[TT_DOC_UKETORI_IF].UPDATE_PG_CD					------Update Program Code
--	 ,[TT_DOC_UKETORI_IF].DELETE_DATE					------Deletion Date
--	 ,[TT_DOC_UKETORI_IF].DELETE_FLG					------Deletion Date
)
Values 
(
	
	@fileNo		,
	@vechicleClassification	,
	@vechicleRegistrationNo	,
	@numberPlate ,
	@chassisNo	,
	@motorModel		,
	@formType,
	SYSDATETIME(),
	@createUser_CD
	
)
	
END


GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003CheckInputTorokuno]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003CheckInputTorokuno]
(	
	@UriageShuppinnTorokuNo		varchar(8)
	,@DocControlNo				varchar(13)		
	,@User						varchar(10)
	,@ErrorMsg					varchar(5)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2016/01/19
-- Comment			: Store check input torokuno
---------------------------------------------------------------------------
BEGIN
	IF(@UriageShuppinnTorokuNo IS NOT NULL
		AND
		EXISTS (
			SELECT 1
			FROM TT_DN_CAR_INFO WITH(NOLOCK)
			INNER JOIN TT_DOC_CONTROL WITH(NOLOCK)
			ON TT_DN_CAR_INFO.CAR_ID = TT_DOC_CONTROL.CAR_ID
			AND TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = @UriageShuppinnTorokuNo
			WHERE 
			TT_DOC_CONTROL.DOC_CONTROL_NO = @DocControlNo
		)			
	)
			SET @ErrorMsg = ''
	ELSE
			SET @ErrorMsg = 'W0003'

END




GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003ExportCSVLinkGHQ]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003ExportCSVLinkGHQ]
(	
	@ListExportCSVLinkGHQ		DCW003ExportCSVLinkGHQ		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2015/01/12
-- Comment			: Store insert TT_DOC_CONTROL to TT_GHQ_DOC_MEIHEN_OUTPUT
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_GHQ_DOC_MEIHEN_OUTPUT
	(
		TT_GHQ_DOC_UKETORI_OUTPUT.KEI_CAR_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_YEAR
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_MONTH
		,TT_GHQ_DOC_UKETORI_OUTPUT.TOROKU_DAY
		,TT_GHQ_DOC_UKETORI_OUTPUT.CHASSIS_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.JOSHA_TEIIN_NUM
		,TT_GHQ_DOC_UKETORI_OUTPUT.CC
		,TT_GHQ_DOC_UKETORI_OUTPUT.NOTE
		,TT_GHQ_DOC_UKETORI_OUTPUT.RENKEI_ZUMI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_USER_CD


	)
	SELECT
		 List.KeiCarFlg
		,List.TorokuNo
		,CONVERT(VARCHAR(2),
		(SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE='西暦変換' AND TM_CONST.TYPE_VALUE = YEAR(List.JishameiKanryoNyukoDate))
		)
		,CONVERT(VARCHAR(2),MONTH(List.JishameiKanryoNyukoDate))
		,CONVERT(VARCHAR(2),DAY(List.JishameiKanryoNyukoDate))
		,List.ChassisNo
		,List.JoshaTeiinNum
		,List.CcName
		,''
		,'0'
		,GETDATE()
		,@User
	FROM @ListExportCSVLinkGHQ  List 

END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetDocControlExist]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetDocControlExist]
(	
	@ListCsv		DCW003Csv	READONLY
	,@ModeSearch	int
	, @PageIndex int = 1
	, @PageSize int = 10
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT * FROM(
	SELECT 
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- ‘—ÞŠÇ—”Ô†
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- Žd“üDNo•i”Ô†
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- ”„ãDNo•i”Ô†
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- ŽÔ‘ä”Ô†
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- o•i“Xî•ñ
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- —ŽŽD“Xî•ñ
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- Žd“üAA‰ïê
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- ”„ãAA‰ïê
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- ”NŽ®
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- ŽÔçq‹æ•ª
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AAŠJÃ“ú
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- ƒ[ƒJ[
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- ŽÔ–¼
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- ƒOƒŒ[ƒh
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA”Ô†
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN¬–ñ“ú
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- Œ^Ž®
		,(CASE
			WHEN [List].ReportType = '1' THEN '0'
			WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN '1' 
			ELSE [TT_DOC_CONTROL].MASSHO_FLG
			END) AS MasshoFlg
		,TT_DN_CAR_INFO.MASSHO_FLG AS DnMasshoFlg
		--,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- ‘—Þ‹æ•ª
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- Ž©ŽÐ–¼‹æ•ª
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- ‘—ÞƒXƒe[ƒ^ƒX
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- “o˜^ƒiƒ“ƒo[
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- ‘—Þ—LŒøŠúŒÀ
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ƒtƒ@ƒCƒ‹”Ô†
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- Žd“ü”Ô†
		,(CASE
			WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN NULL 
			ELSE [TT_DOC_CONTROL].SHAKEN_LIMIT_DATE
			END) AS ShakenLimitDate
		--,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- ŽÔŒŸ–ž—¹“ú
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- ‘—Þ“üŒÉ“ú
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- Ž©ŽÐ–¼ˆË—Š“ú
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- –•ÁˆË—Š“ú
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- ‘—ÞoŒÉ“ú
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- Ž©ŽÐ–¼Š®—¹“ú
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- –•ÁŠ®—¹“ú
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- ƒƒ‚
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, [List].ID					AS ID
		,COUNT (*) OVER() AS [RowCount]
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	LEFT JOIN TT_DN_CAR_INFO WITH(NOLOCK)
	ON (
		TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO
		OR TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO
		)
	AND TT_DN_CAR_INFO.DELETE_FLG = 0
	INNER JOIN @ListCsv List
	ON [TT_DOC_CONTROL].CHASSIS_NO = [List].ChassisNo
	WHERE (@ModeSearch = 1 
			AND	(([List].ReportType = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '103')
				OR (([List].ReportType = 2 OR [List].ReportType = 4) AND [TT_DOC_CONTROL].DOC_STATUS = '104'))
			AND [TT_DOC_CONTROL].RACK_NO = LEFT([List].RacFileNo,1)
			AND [TT_DOC_CONTROL].FILE_NO = RIGHT([List].RacFileNo,4))
		OR (@ModeSearch = 2 AND [TT_DOC_CONTROL].DOC_STATUS <> '101' AND [TT_DOC_CONTROL].DOC_STATUS <> '105' )
		OR (@ModeSearch = 3 AND [TT_DOC_CONTROL].DOC_STATUS = '102')
		--Add by TramD start
		OR (@ModeSearch = 5 AND [TT_DOC_CONTROL].DOC_STATUS <> '105')
		--Add by TramD end
	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
		ORDER BY SearchInfoTempTable.ID
END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetDocControlMaster]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetDocControlMaster]
(	
	@ListRFID	DCW003RFID	READONLY
	, @PageIndex int = 1
	, @PageSize int = 10
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT * FROM(
	SELECT
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- 車台番号
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- 出品店情報
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') + ' ' +ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- 落札店情報
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- 仕入AA会場
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- 売上AA会場
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- 年式
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- 車輌区分
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AA開催日
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- メーカー
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- 車名
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- グレード
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA番号
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN成約日
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- 型式
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- 書類区分
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- 自社名区分
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- 書類ステータス
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- 登録ナンバー
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- 書類有効期限
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ファイル番号
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- 仕入番号
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- メモ
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo								-- ファイル番号
		,[List].ID										AS ID	
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, COUNT (*) OVER() AS [RowCount]
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	INNER JOIN TM_DOC_FILE_NO
	ON [TT_DOC_CONTROL].RACK_NO = TM_DOC_FILE_NO.RACK_NO
	AND [TT_DOC_CONTROL].FILE_NO = TM_DOC_FILE_NO.FILE_NO
	INNER JOIN @ListRFID List
	ON TM_DOC_FILE_NO.RFID_KYE = [List].RFIDKey
	WHERE TT_DOC_CONTROL.DOC_STATUS NOT IN ('101','105')
	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
		ORDER BY SearchInfoTempTable.ID

END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetFuzokuhin]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetFuzokuhin]
(	
	@ListDocControlNo	DCW003DocControlNo		READONLY
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: Store seach of DCW003
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		[TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_UKETORI_DETAIL].DOC_FUZOKUHIN_CD				AS DocFuzoKuhinCd
		,[TT_DOC_UKETORI_DETAIL].NOTE							AS Note
		,TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO					AS HisUketoriDocControlNo
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_UKETORI_DETAIL WITH(NOLOCK)
		INNER JOIN @ListDocControlNo List
		ON [TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO = [List].DocControlNo
		LEFT JOIN TH_DOC_UKETORI_DETAIL WITH(NOLOCK)
		ON TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO = TH_DOC_UKETORI_DETAIL.DOC_CONTROL_NO
	WHERE
		[TT_DOC_UKETORI_DETAIL].DELETE_FLG = 0

END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetHensoIf]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetHensoIf]
(
	@ListCsv		DCW003Csv	READONLY
	,@ModeSearch	int
	, @PageIndex int = 1
	, @PageSize int = 10
)
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
	SELECT * FROM(
	SELECT 
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- 車台番号
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- 出品店情報
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- 落札店情報
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- 仕入AA会場
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- 売上AA会場
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- 年式
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- 車輌区分
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AA開催日
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- メーカー
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- 車名
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- グレード
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA番号
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN成約日
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- 型式
		--,(CASE
		--	WHEN [List].ReportType = '1' THEN '0'
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN '1' 
		--	ELSE [TT_DOC_CONTROL].MASSHO_FLG
		--	END) AS MasshoFlg
		,TT_DN_CAR_INFO.MASSHO_FLG AS DnMasshoFlg
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- 書類区分
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- 自社名区分
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- 書類ステータス
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- 登録ナンバー
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- 書類有効期限
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ファイル番号
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- 仕入番号
		--,(CASE
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN NULL 
		--	ELSE [TT_DOC_CONTROL].SHAKEN_LIMIT_DATE
		--	END) AS ShakenLimitDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- メモ
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, TT_DOC_HENSO_IF.ID					AS ID
		,COUNT (*) OVER() AS [RowCount]
		,TT_DOC_HENSO_IF.HENSO_ZUMI_FLG AS HensoFlg
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	INNER JOIN TT_DOC_HENSO_IF WITH(NOLOCK)
	ON(
		TT_DOC_HENSO_IF.HENSO_ZUMI_FLG = '0'
		AND
		TT_DOC_CONTROL.CHASSIS_NO = TT_DOC_HENSO_IF.CHASSIS_NO
		AND
		(
			TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO = TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO
			OR
			TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO = TT_DOC_HENSO_IF.SHUPPINN_TOROKU_NO
		)
	) 
	
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	LEFT JOIN TT_DN_CAR_INFO WITH(NOLOCK)
	ON (
		TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO
		OR TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO
		)
	--AND TT_DN_CAR_INFO.DELETE_FLG = 0
	
	WHERE 
	(
		(@ModeSearch = 2 AND [TT_DOC_CONTROL].DOC_STATUS <> '101' AND [TT_DOC_CONTROL].DOC_STATUS <> '105' ))
		OR (@ModeSearch = 3 AND [TT_DOC_CONTROL].DOC_STATUS = '102')
		--Add by TramD start
		OR (@ModeSearch = 5 AND [TT_DOC_CONTROL].DOC_STATUS <> '105')
		--Add by TramD end

	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
		ORDER BY SearchInfoTempTable.ID
		--GROUP BY DocControlNo,ShiireShuppinnTorokuNo,UriageShuppinnTorokuNo
		--,ChassisNo,ShopName,RakusatsuShopName,ShiireAaKaijo,UriageAaKaijo,Nenshiki,KeiCarFlg
		--,AaKaisaiDate,MakerName,CarName,GradeName,AaShuppinNo,DnSeiyakuDate,Katashiki,DnMasshoFlg
		--,MasshoFlg,JishameiFlg,DocStatus,TorokuNo,ShoruiLimitDate,FileNo,RacNo,ShiireNo,ShakenLimitDate
		--,DocNyukoDate,JishameiIraiShukkoDate,MasshoIraiShukkoDate,DocShukkoDate,JishameiKanryoNyukoDate
		--,MasshoKanryoNyukoDate,Memo,MeihenShakenTorokuDate,RowNum,ID,[RowCount],HensoFlg, UpdateDate, CreateDate

END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetHensoIfExist]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetHensoIfExist]
(	
	@ListCsv		DCW003Csv	READONLY
	, @ModeSearch int
	, @PageIndex int = 1
	, @PageSize int = 10
)
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
	SELECT * FROM(
	SELECT 
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- 車台番号
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- 出品店情報
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- 落札店情報
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- 仕入AA会場
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- 売上AA会場
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- 年式
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- 車輌区分
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AA開催日
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- メーカー
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- 車名
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- グレード
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA番号
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN成約日
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- 型式
		--,(CASE
		--	WHEN [List].ReportType = '1' THEN 0 
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN 1 
		--	ELSE [TT_DOC_CONTROL].MASSHO_FLG
		--	END) AS MasshoFlag
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- 書類区分
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- 自社名区分
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- 書類ステータス
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- 登録ナンバー
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- 書類有効期限
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ファイル番号
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- 仕入番号
		--,(CASE
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN NULL 
		--	ELSE [TT_DOC_CONTROL].SHAKEN_LIMIT_DATE
		--	END) AS ShakenLimitDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- メモ
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, [List].ID					AS ID
		,COUNT (*) OVER() AS [RowCount]
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	INNER JOIN @ListCsv List
	ON [TT_DOC_CONTROL].CHASSIS_NO = [List].ChassisNo
	AND (
		[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO = List.TorokuNo
		OR
		[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO = List.TorokuNo
	)
	AND TT_DOC_CONTROL.DELETE_FLG = 0
	WHERE (@ModeSearch = 1 
			AND	(([List].ReportType = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '103')
				OR (([List].ReportType = 2 OR [List].ReportType = 4) AND [TT_DOC_CONTROL].DOC_STATUS = '104'))
			AND [TT_DOC_CONTROL].RACK_NO = LEFT([List].RacFileNo,1)
			AND [TT_DOC_CONTROL].FILE_NO = RIGHT([List].RacFileNo,4))
		OR (@ModeSearch = 2 AND [TT_DOC_CONTROL].DOC_STATUS <> '101' AND [TT_DOC_CONTROL].DOC_STATUS <> '105' )
		OR (@ModeSearch = 3 AND [TT_DOC_CONTROL].DOC_STATUS = '102')
		--Add by TramD start
		OR (@ModeSearch = 5 AND [TT_DOC_CONTROL].DOC_STATUS <> '105')
		OR( @ModeSearch = 6 AND [TT_DOC_CONTROL].DOC_STATUS <> '101')
		--Add by TramD end
	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
		ORDER BY SearchInfoTempTable.ID

END


GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetJapanYear]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetJapanYear]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2016/18/01
-- Comment			: Store get JapanYear
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_CONST.TYPE_VALUE as Year
		,TM_CONST.VALUE as JapanYear
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM
		TM_CONST
	WHERE
		TM_CONST.TYPE = '西暦変換'
		AND
		TM_CONST.DELETE_FLG = '0'

END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetListImport]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetListImport]
(	
	@ListDocControlNo	DCW003DocControlNo	READONLY	
	, @PageIndex int = 1
	, @PageSize int = 10
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT * FROM(
	SELECT
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- ‘—ÞŠÇ—”Ô†
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- Žd“üDNo•i”Ô†
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- ”„ãDNo•i”Ô†
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- ŽÔ‘ä”Ô†
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- o•i“Xî•ñ
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- —ŽŽD“Xî•ñ
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- Žd“üAA‰ïê
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- ”„ãAA‰ïê
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- ”NŽ®
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- ŽÔçq‹æ•ª
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AAŠJÃ“ú
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- ƒ[ƒJ[
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- ŽÔ–¼
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- ƒOƒŒ[ƒh
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA”Ô†
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN¬–ñ“ú
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- Œ^Ž®
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- ‘—Þ‹æ•ª
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- Ž©ŽÐ–¼‹æ•ª
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- ‘—ÞƒXƒe[ƒ^ƒX
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- “o˜^ƒiƒ“ƒo[
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- ‘—Þ—LŒøŠúŒÀ
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ƒtƒ@ƒCƒ‹”Ô†
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- Žd“ü”Ô†
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- ŽÔŒŸ–ž—¹“ú
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- ‘—Þ“üŒÉ“ú
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- Ž©ŽÐ–¼ˆË—Š“ú
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- –•ÁˆË—Š“ú
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- ‘—ÞoŒÉ“ú
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- Ž©ŽÐ–¼Š®—¹“ú
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- –•ÁŠ®—¹“ú
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- ƒƒ‚
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, COUNT (*) OVER() AS [RowCount]
		,TT_DN_CAR_INFO.MASSHO_FLG						AS DnMasshoFlg
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	LEFT JOIN TT_DN_CAR_INFO WITH(NOLOCK)
	ON (
		TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO
		OR TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO
		)
	AND TT_DN_CAR_INFO.DELETE_FLG = 0
	INNER JOIN @ListDocControlNo List
	ON [TT_DOC_CONTROL].DOC_CONTROL_NO = [List].DocControlNo
	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetMasterDocStatus]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetMasterDocStatus]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_CONST.VALUE			AS Value
		,TM_CONST.TYPE_VALUE	AS Text
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TM_CONST WITH(NOLOCK)
	WHERE TM_CONST.TYPE = '書類ステータス'
	AND TM_CONST.DELETE_FLG = 0

	ORDER BY TM_CONST.VALUE

END


GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetMasterFuzokuhin]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetMasterFuzokuhin]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_DOC_FUZOKUHIN.DOC_FUZOKUHIN_CD				AS	DocFuzokuhinCd
		,TM_DOC_FUZOKUHIN.DOC_FUZOKUHIN_DISP_NAME		AS	DocFuzokuhinName
		,TM_DOC_FUZOKUHIN.DOC_FUZOKUHIN_TYPE_CD			AS	DocFuzokuhinType
		,TM_DOC_FUZOKUHIN.UKETORIJI_DEFALT_CHECK_TYPE	AS	DefaulCheckType
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TM_DOC_FUZOKUHIN WITH(NOLOCK)
	WHERE TM_DOC_FUZOKUHIN.DISP_ORDER <> 0
	AND TM_DOC_FUZOKUHIN.DELETE_FLG = 0
	
	ORDER BY TM_DOC_FUZOKUHIN.DOC_FUZOKUHIN_TYPE_CD, TM_DOC_FUZOKUHIN.DISP_ORDER

END


GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetMasterYear]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003GetMasterYear]

AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		TM_CONST.VALUE			AS Value
		,TM_CONST.TYPE_VALUE	AS Text
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TM_CONST WITH(NOLOCK)
	WHERE TM_CONST.TYPE = '納税年度表示'
	AND TM_CONST.DELETE_FLG = 0

	ORDER BY TM_CONST.VALUE

END


GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003ImportCsv]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertDocAutoSearch]    Script Date: 2016/01/28 18:31:50 ******/
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

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertDocUketoriDetail]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003InsertDocUketoriDetail]
(	
	@ListDocUketoriDetail		DCW003DocUketoriDetail		READONLY
	,@ListDocUketoriUpdate		DCW003DocUketoriUpdate		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT

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
	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)
	DECLARE @ct_DOC_CONTROL_NO varchar(13)
	DECLARE @ct_DOC_FUZOKUHIN_CD char(3)
	-------------------------------------------------------------------------
	-- UPDATE
	-------------------------------------------------------------------------
	UPDATE TT_DOC_CONTROL SET
		[TT_DOC_CONTROL].SHORUI_LIMIT_DATE = [ListUpdate].ShoruiLimitDate
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE = [ListUpdate].MeihenShakenTorokuDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE = [ListUpdate].ShakenLimitDate
		,[TT_DOC_CONTROL].UPDATE_DATE = GETDATE()
		,[TT_DOC_CONTROL].UPDATE_USER_CD = @User
		,[TT_DOC_CONTROL].JISHAMEI_FLG = ListUpdate.JishameiFlag
	FROM
		[TT_DOC_CONTROL]
	INNER JOIN @ListDocUketoriUpdate ListUpdate
	ON [TT_DOC_CONTROL].DOC_CONTROL_NO = [ListUpdate].DocControlNo
	WHERE [TT_DOC_CONTROL].DELETE_FLG = 0

	-------------------------------------------------------------------------
	-- DELETE
	-------------------------------------------------------------------------
	DELETE FROM TT_DOC_UKETORI_DETAIL
	WHERE TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO IN (SELECT DocControlNo FROM @ListDocUketoriUpdate)
	--OR TT_DOC_UKETORI_DETAIL.DOC_CONTROL_NO IN (
	--							SELECT DOC_CONTROL_NO FROM TT_DOC_CONTROL
	--							WHERE JISHAMEI_FLG = 1 
	--							AND DOC_CONTROL_NO IN (SELECT  DocControlNo FROM @ListDocUketoriUpdate)
	--							)

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_DOC_UKETORI_DETAIL
	(
		[TT_DOC_UKETORI_DETAIL].DOC_CONTROL_NO
		,[TT_DOC_UKETORI_DETAIL].DOC_FUZOKUHIN_CD
		,[TT_DOC_UKETORI_DETAIL].DOC_COUNT
		,[TT_DOC_UKETORI_DETAIL].DOC_HAKKO_DATE
		,[TT_DOC_UKETORI_DETAIL].DOC_UKE_DATE
		,[TT_DOC_UKETORI_DETAIL].NOTE
		,[TT_DOC_UKETORI_DETAIL].CREATE_DATE
		,[TT_DOC_UKETORI_DETAIL].CREATE_USER_CD
		,[TT_DOC_UKETORI_DETAIL].UPDATE_DATE
		,[TT_DOC_UKETORI_DETAIL].UPDATE_USER_CD
		,[TT_DOC_UKETORI_DETAIL].DELETE_FLG
	)
	SELECT
		List.DocControlNo
		--,CASE 
		--	WHEN TT_DOC_CONTROL.MASSHO_FLG = 0 THEN 101
		--	ELSE
		--		List.DocFuzokuhinCd
		--	END		
		,List.DocFuzokuhinCd
		,'1'
		,CASE 
			WHEN TT_DOC_CONTROL.MASSHO_FLG = 0 THEN TT_DOC_CONTROL.SHAKEN_LIMIT_DATE
			ELSE
				NULL
			END
		--,GETDATE()
		,CONVERT(VARCHAR(11),GETDATE(),111)
		--,CASE
		--	WHEN TT_DOC_CONTROL.JISHAMEI_FLG = 1 AND (List.Note IS NULL) THEN '自社名済'
		--	ELSE List.Note
		--	END
		,List.Note
		,GETDATE()
		,@User
		,GETDATE()
		,@User
		,0
	FROM @ListDocUketoriDetail List 
		INNER JOIN TT_DOC_CONTROL WITH(NOLOCK)
		ON List.DocControlNo = TT_DOC_CONTROL.DOC_CONTROL_NO

END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertDocUketoriIf]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertHensoIf]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003InsertHensoIf]
(	
	@ListCsv		DCW003Csv		READONLY
	,@User			varchar(20)
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: TramD
-- Programmer		: TramD
-- Created Date		: 2016/1/12
-- Comment			: Store insert update TT_DOC_HENSO_IF
---------------------------------------------------------------------------

BEGIN
	SET NOCOUNT ON

	DECLARE @ct_HENSO_IRAI_DATE		datetime
	DECLARE @ct_SHOP_CD				char(6)
	DECLARE @ct_SHOP_NAME			varchar(40)
	DECLARE @ct_TANTOSHA_NAME		varchar(40)
	DECLARE @ct_CAR_NAME			varchar(100)
	DECLARE @ct_CHASSIS_NO			varchar(25)
	DECLARE @ct_SHIIRE_SAKI			varchar(20)
	DECLARE @ct_TOROKUNO			varchar(8)
	DECLARE @ct_HENSO_RIYU			varchar(1000)
	DECLARE @ct_NOTE				varchar(1000)
	DECLARE @ct_JISHAMEI_YOUHI		varchar(1000)
	DECLARE @ct_DOC_STATUS			char(3)
	
	DECLARE auto_cursor CURSOR 
	FOR SELECT HensoIraiDate
			 , ShopCd
			 , TantoshaName
			 , CarName
			 , ChassisNo
			 , ShiireSaki
			 , TorokuNo
			 , HensoRiyu
			 , Note
			 , JishameiYouhi
			 , JMType
			FROM @ListCsv

	OPEN auto_cursor 

	FETCH NEXT FROM auto_cursor INTO  @ct_HENSO_IRAI_DATE
									, @ct_SHOP_CD
									, @ct_TANTOSHA_NAME
									, @ct_CAR_NAME
									, @ct_CHASSIS_NO
									, @ct_SHIIRE_SAKI
									, @ct_TOROKUNO
									, @ct_HENSO_RIYU
									, @ct_NOTE
									, @ct_JISHAMEI_YOUHI
									, @ct_DOC_STATUS
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(
			EXISTS(
				SELECT 1
				FROM TT_DOC_HENSO_IF WITH(NOLOCK)
				WHERE
				[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
					AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
					AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = 0
					AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
					)		
		)
			BEGIN
								UPDATE TT_DOC_HENSO_IF SET
								[TT_DOC_HENSO_IF].HENSO_IRAI_DATE				= @ct_HENSO_IRAI_DATE
								,[TT_DOC_HENSO_IF].SHOP_CD						= @ct_SHOP_CD
								,[TT_DOC_HENSO_IF].TANTOSHA_NAME				= @ct_TANTOSHA_NAME
								,[TT_DOC_HENSO_IF].CAR_NAME						= @ct_CAR_NAME
								,[TT_DOC_HENSO_IF].CHASSIS_NO					= @ct_CHASSIS_NO
								,[TT_DOC_HENSO_IF].SHIIRE_SAKI					= @ct_SHIIRE_SAKI
								,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO			= @ct_TOROKUNO
								,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU				= @ct_HENSO_RIYU
								,[TT_DOC_HENSO_IF].NOTE							= @ct_NOTE
								,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI		= @ct_JISHAMEI_YOUHI
								,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG				= 0
								,[TT_DOC_HENSO_IF].UPDATE_DATE					= GETDATE()
								,[TT_DOC_HENSO_IF].UPDATE_USER_CD				= @User
								WHERE
									[TT_DOC_HENSO_IF].CHASSIS_NO				= @ct_CHASSIS_NO
									AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO	= @ct_TOROKUNO
									AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG		= 0
									AND [TT_DOC_HENSO_IF].DELETE_FLG			= 0
			END
		ELSE
		BEGIN
			IF(
			NOT EXISTS(
					SELECT 1
					FROM TT_DOC_HENSO_IF WITH(NOLOCK)
					WHERE 
					[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
					AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
					--AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = 0
					AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
				)
		)
			BEGIN
				INSERT INTO TT_DOC_HENSO_IF
				(
					[TT_DOC_HENSO_IF].HENSO_IRAI_DATE
					,[TT_DOC_HENSO_IF].SHOP_CD
					,[TT_DOC_HENSO_IF].TANTOSHA_NAME
					,[TT_DOC_HENSO_IF].CAR_NAME
					,[TT_DOC_HENSO_IF].CHASSIS_NO
					,[TT_DOC_HENSO_IF].SHIIRE_SAKI
					,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO
					,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU
					,[TT_DOC_HENSO_IF].NOTE
					,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI
					,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG
					,[TT_DOC_HENSO_IF].CREATE_DATE
					,[TT_DOC_HENSO_IF].CREATE_USER_CD
					,[TT_DOC_HENSO_IF].UPDATE_DATE
					,[TT_DOC_HENSO_IF].UPDATE_USER_CD
					,[TT_DOC_HENSO_IF].DELETE_FLG
				)
				VALUES
				(
					@ct_HENSO_IRAI_DATE
					,@ct_SHOP_CD
					,@ct_TANTOSHA_NAME
					,@ct_CAR_NAME
					,@ct_CHASSIS_NO
					,@ct_SHIIRE_SAKI
					,@ct_TOROKUNO
					,@ct_HENSO_RIYU
					,@ct_NOTE
					,@ct_JISHAMEI_YOUHI
					,0
					,GETDATE()
					,@User
					,GETDATE()
					,@User
					,0
				)
			END

			IF(
			EXISTS(
					SELECT 1
					FROM TT_DOC_HENSO_IF WITH(NOLOCK)
					WHERE 
					[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
					AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
					AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = 1
					AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
				)
			)
			BEGIN
					INSERT INTO TT_DOC_HENSO_IF
				(
					[TT_DOC_HENSO_IF].HENSO_IRAI_DATE
					,[TT_DOC_HENSO_IF].SHOP_CD
					,[TT_DOC_HENSO_IF].TANTOSHA_NAME
					,[TT_DOC_HENSO_IF].CAR_NAME
					,[TT_DOC_HENSO_IF].CHASSIS_NO
					,[TT_DOC_HENSO_IF].SHIIRE_SAKI
					,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO
					,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU
					,[TT_DOC_HENSO_IF].NOTE
					,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI
					,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG
					,[TT_DOC_HENSO_IF].CREATE_DATE
					,[TT_DOC_HENSO_IF].CREATE_USER_CD
					,[TT_DOC_HENSO_IF].UPDATE_DATE
					,[TT_DOC_HENSO_IF].UPDATE_USER_CD
					,[TT_DOC_HENSO_IF].DELETE_FLG
				)
				VALUES
				(
					@ct_HENSO_IRAI_DATE
					,@ct_SHOP_CD
					,@ct_TANTOSHA_NAME
					,@ct_CAR_NAME
					,@ct_CHASSIS_NO
					,@ct_SHIIRE_SAKI
					,@ct_TOROKUNO
					,@ct_HENSO_RIYU
					,@ct_NOTE
					,@ct_JISHAMEI_YOUHI
					,0
					,GETDATE()
					,@User
					,GETDATE()
					,@User
					,0
				)
			END
		END

		--IF(
		--	NOT EXISTS(
		--			SELECT 1
		--			FROM TT_DOC_HENSO_IF WITH(NOLOCK)
		--			WHERE 
		--			[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
		--			AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--			--AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = 0
		--			AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
		--		)
		--)
		--	BEGIN
		--		INSERT INTO TT_DOC_HENSO_IF
		--		(
		--			[TT_DOC_HENSO_IF].HENSO_IRAI_DATE
		--			,[TT_DOC_HENSO_IF].SHOP_CD
		--			,[TT_DOC_HENSO_IF].TANTOSHA_NAME
		--			,[TT_DOC_HENSO_IF].CAR_NAME
		--			,[TT_DOC_HENSO_IF].CHASSIS_NO
		--			,[TT_DOC_HENSO_IF].SHIIRE_SAKI
		--			,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO
		--			,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU
		--			,[TT_DOC_HENSO_IF].NOTE
		--			,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI
		--			,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG
		--			,[TT_DOC_HENSO_IF].CREATE_DATE
		--			,[TT_DOC_HENSO_IF].CREATE_USER_CD
		--			,[TT_DOC_HENSO_IF].UPDATE_DATE
		--			,[TT_DOC_HENSO_IF].UPDATE_USER_CD
		--			,[TT_DOC_HENSO_IF].DELETE_FLG
		--		)
		--		VALUES
		--		(
		--			@ct_HENSO_IRAI_DATE
		--			,@ct_SHOP_CD
		--			,@ct_TANTOSHA_NAME
		--			,@ct_CAR_NAME
		--			,@ct_CHASSIS_NO
		--			,@ct_SHIIRE_SAKI
		--			,@ct_TOROKUNO
		--			,@ct_HENSO_RIYU
		--			,@ct_NOTE
		--			,@ct_JISHAMEI_YOUHI
		--			,0
		--			,GETDATE()
		--			,@User
		--			,GETDATE()
		--			,@User
		--			,0
		--		)
		--	END
		

		--IF(
		--	EXISTS(
		--			SELECT 1
		--			FROM TT_DOC_HENSO_IF WITH(NOLOCK)
		--			WHERE 
		--			[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
		--			AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--			AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = 1
		--			AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
		--		)
		--)
		--	BEGIN
		--			INSERT INTO TT_DOC_HENSO_IF
		--		(
		--			[TT_DOC_HENSO_IF].HENSO_IRAI_DATE
		--			,[TT_DOC_HENSO_IF].SHOP_CD
		--			,[TT_DOC_HENSO_IF].TANTOSHA_NAME
		--			,[TT_DOC_HENSO_IF].CAR_NAME
		--			,[TT_DOC_HENSO_IF].CHASSIS_NO
		--			,[TT_DOC_HENSO_IF].SHIIRE_SAKI
		--			,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO
		--			,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU
		--			,[TT_DOC_HENSO_IF].NOTE
		--			,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI
		--			,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG
		--			,[TT_DOC_HENSO_IF].CREATE_DATE
		--			,[TT_DOC_HENSO_IF].CREATE_USER_CD
		--			,[TT_DOC_HENSO_IF].UPDATE_DATE
		--			,[TT_DOC_HENSO_IF].UPDATE_USER_CD
		--			,[TT_DOC_HENSO_IF].DELETE_FLG
		--		)
		--		VALUES
		--		(
		--			@ct_HENSO_IRAI_DATE
		--			,@ct_SHOP_CD
		--			,@ct_TANTOSHA_NAME
		--			,@ct_CAR_NAME
		--			,@ct_CHASSIS_NO
		--			,@ct_SHIIRE_SAKI
		--			,@ct_TOROKUNO
		--			,@ct_HENSO_RIYU
		--			,@ct_NOTE
		--			,@ct_JISHAMEI_YOUHI
		--			,0
		--			,GETDATE()
		--			,@User
		--			,GETDATE()
		--			,@User
		--			,0
		--		)
		--	END
		

		--IF(
		--	NOT EXISTS(
		--			SELECT 1
		--			FROM TT_DOC_HENSO_IF WITH(NOLOCK)
		--			WHERE 
		--			[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
		--			AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--			AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
		--		)
		--	AND 
		--	NOT EXISTS(
		--			SELECT 1
		--			FROM TT_DOC_CONTROL WITH(NOLOCK)
		--			WHERE
		--			TT_DOC_CONTROL.CHASSIS_NO = @ct_CHASSIS_NO
		--			AND (
		--					TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--					OR
		--					TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--				)
		--		)
		--)
		--	BEGIN
		--		INSERT INTO TT_DOC_HENSO_IF
		--	(
		--		[TT_DOC_HENSO_IF].HENSO_IRAI_DATE
		--		,[TT_DOC_HENSO_IF].SHOP_CD
		--		,[TT_DOC_HENSO_IF].TANTOSHA_NAME
		--		,[TT_DOC_HENSO_IF].CAR_NAME
		--		,[TT_DOC_HENSO_IF].CHASSIS_NO
		--		,[TT_DOC_HENSO_IF].SHIIRE_SAKI
		--		,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO
		--		,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU
		--		,[TT_DOC_HENSO_IF].NOTE
		--		,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI
		--		,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG
		--		,[TT_DOC_HENSO_IF].CREATE_DATE
		--		,[TT_DOC_HENSO_IF].CREATE_USER_CD
		--		,[TT_DOC_HENSO_IF].UPDATE_DATE
		--		,[TT_DOC_HENSO_IF].UPDATE_USER_CD
		--		,[TT_DOC_HENSO_IF].DELETE_FLG
		--	)
		--	VALUES
		--	(
		--		@ct_HENSO_IRAI_DATE
		--		,@ct_SHOP_CD
		--		,@ct_TANTOSHA_NAME
		--		,@ct_CAR_NAME
		--		,@ct_CHASSIS_NO
		--		,@ct_SHIIRE_SAKI
		--		,@ct_TOROKUNO
		--		,@ct_HENSO_RIYU
		--		,@ct_NOTE
		--		,@ct_JISHAMEI_YOUHI
		--		,0
		--		,GETDATE()
		--		,@User
		--		,GETDATE()
		--		,@User
		--		,0
		--	)
		--	END

		
		--IF(
		--	EXISTS (
		--		SELECT 1 FROM TT_DOC_HENSO_IF WITH(NOLOCK)
		--		WHERE
		--		[TT_DOC_HENSO_IF].CHASSIS_NO = @ct_CHASSIS_NO
		--		AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--		AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG = '0'
		--		AND [TT_DOC_HENSO_IF].DELETE_FLG = 0
		--	) 
		--	AND
		--	NOT EXISTS(
		--		SELECT 1
		--		FROM TT_DOC_CONTROL WITH(NOLOCK)
		--		WHERE
		--		TT_DOC_CONTROL.CHASSIS_NO = @ct_CHASSIS_NO
		--		AND (
		--				TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--				OR
		--				TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO = @ct_TOROKUNO
		--			)
		--	)
		--)
		--	BEGIN
		--					UPDATE TT_DOC_HENSO_IF SET
		--					[TT_DOC_HENSO_IF].HENSO_IRAI_DATE				= @ct_HENSO_IRAI_DATE
		--					,[TT_DOC_HENSO_IF].SHOP_CD						= @ct_SHOP_CD
		--					,[TT_DOC_HENSO_IF].TANTOSHA_NAME				= @ct_TANTOSHA_NAME
		--					,[TT_DOC_HENSO_IF].CAR_NAME						= @ct_CAR_NAME
		--					,[TT_DOC_HENSO_IF].CHASSIS_NO					= @ct_CHASSIS_NO
		--					,[TT_DOC_HENSO_IF].SHIIRE_SAKI					= @ct_SHIIRE_SAKI
		--					,[TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO			= @ct_TOROKUNO
		--					,[TT_DOC_HENSO_IF].DOC_HENSO_RIYU				= @ct_HENSO_RIYU
		--					,[TT_DOC_HENSO_IF].NOTE							= @ct_NOTE
		--					,[TT_DOC_HENSO_IF].JISHAMEI_DOC_MAKE_YOUHI		= @ct_JISHAMEI_YOUHI
		--					,[TT_DOC_HENSO_IF].HENSO_ZUMI_FLG				= 0
		--					,[TT_DOC_HENSO_IF].UPDATE_DATE					= GETDATE()
		--					,[TT_DOC_HENSO_IF].UPDATE_USER_CD				= @User
		--					WHERE
		--					[TT_DOC_HENSO_IF].CHASSIS_NO					= @ct_CHASSIS_NO
		--					AND [TT_DOC_HENSO_IF].SHUPPINN_TOROKU_NO		= @ct_TOROKUNO
		--					AND [TT_DOC_HENSO_IF].HENSO_ZUMI_FLG			= 0
		--					AND [TT_DOC_HENSO_IF].DELETE_FLG				= 0
		--	END


		FETCH NEXT FROM auto_cursor INTO @ct_HENSO_IRAI_DATE
									, @ct_SHOP_CD
									, @ct_TANTOSHA_NAME
									, @ct_CAR_NAME
									, @ct_CHASSIS_NO
									, @ct_SHIIRE_SAKI
									, @ct_TOROKUNO
									, @ct_HENSO_RIYU
									, @ct_NOTE
									, @ct_JISHAMEI_YOUHI
									, @ct_DOC_STATUS
	END

	CLOSE auto_cursor
    DEALLOCATE auto_cursor   
END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertHisUketoriDetail]    Script Date: 2016/01/28 18:31:50 ******/
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

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertJishameiMassho]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[stp_DCW003SearchCondition]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003SearchCondition]
(	
	@ShuppinnTorokuNo varchar(8)						-- 出品登録番号
	,@ListTorokuNo	DCW003TorokuNo	READONLY
	,@ListChassisNo	DCW003ChassisNo READONLY
	, @RadioType char(1)								-- Type search
	, @ChassisNo varchar(25)							-- 車台番号
	, @ShohinType char(3)								-- DN - AA
	, @ShopCd char(6)									-- 出品店舗
	, @ShopName	varchar(60)								-- 出品店舗名称
	, @RakusatsuShopCd char(6)							-- 落札店舗
	, @RakusatsuShopName varchar(60)					-- 落札店舗名称
	, @DocStatus102 int								-- 書類ステータス - 保管中
	, @DocStatus103 int								-- 書類ステータス - 自社名中
	, @DocStatus104 int								-- 書類ステータス - 抹消中
	, @DocStatus105 int								-- 書類ステータス - 保管なし(発送済)
	, @FileNo char(5)									-- ファイル番号
	, @KeiCarFlg0 char(1)								-- 車輌区分 - 普通車
	, @KeiCarFlg1 char(1)								-- 車輌区分 - 軽
	, @JishameiFlg char(1)								-- 書類区分 - 自社名フラグ
	, @MasshoFlg char(1)								-- 書類区分 - 抹消フラグ
	, @AaDnDateStart datetime							-- 成約日/落札開催日 - START
	, @AaDnDateEnd datetime								-- 成約日/落札開催日 - END
	, @ShoruiLimitDateStart datetime					-- 書類有効期限 - START
	, @ShoruiLimitDateEnd datetime						-- 書類有効期限 - END
	, @DocNyukoDateStart datetime						-- 書類入庫日 - START
	, @DocNyukoDateEnd datetime							-- 書類入庫日 - END
	, @DocShukkoDateStart datetime						-- 書類出庫日 - START
	, @DocShukkoDateEnd datetime						-- 書類出庫日 - END
	, @JishameiIraiShukkoDateStart datetime				-- 自社名依頼出庫日 - START
	, @JishameiIraiShukkoDateEnd datetime				-- 自社名依頼出庫日 - END
	, @JishameiKanryoNyukoDateStart datetime			-- 自社名完了出庫日 - START
	, @JishameiKanryoNyukoDateEnd datetime				-- 自社名完了出庫日 - END
	, @MasshoIraiShukkoDateStart datetime				-- 抹消依頼出庫日 - START
	, @MasshoIraiShukkoDateEnd datetime					-- 抹消依頼出庫日 - END
	, @MasshoKanryoNyukoDateStart datetime				-- 抹消完了出庫日 - START
	, @MasshoKanryoNyukoDateEnd datetime				-- 抹消完了出庫日 - END
	, @ShakenLimitDateStart datetime					-- 車検満了日 - START
	, @ShakenLimitDateEnd datetime						-- 車検満了日 - END
	, @ModeSearch int
	--Add HoaVV fix bug CR84 start
	, @IsCanselflg char(1)
	, @NoCanselflg char(1)
	--Add HoaVV fix bug CR84 end
	, @PageIndex int = 1
	, @PageSize int = 10
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/03
-- Comment			: Store seach of DCW003
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	declare @countlist int
	declare @chassis1 varchar(25)
	set @countlist= (SELECT COUNT(*) from @ListChassisNo)
	set @chassis1 = (SELECT TOP 1 * FROM @ListChassisNo)
	--SELECT top 1 @chassis1= ChassisNo  from @ListChassisNo;

	--IF(@countlist < 2)
	--BEGIN
	--	SET @chassis1 = 1
	--END	
	



	SELECT * FROM(
	SELECT
		[TT_DOC_CONTROL].DOC_STATUS
		,[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- 車台番号
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- 出品店情報
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'')+' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- 落札店情報
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- 仕入AA会場
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- 売上AA会場
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- 年式
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- 車輌区分
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AA開催日
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- メーカー
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- 車名
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- グレード
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA番号
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN成約日
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- 型式
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg
		,[TT_DOC_CONTROL].SHOP_CD						AS ShopCd	
		,[TT_DOC_CONTROL].CC							AS CcName		
		,[TT_DOC_CONTROL].JOSHA_TEIIN_NUM				AS JoshaTeiinNum				

		,(CASE [TT_DOC_CONTROL].JISHAMEI_FLG
			 WHEN '1' THEN '1'
			 ELSE '0'
		 END) AS JishameiFlg
		
		--[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- 自社名区分
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- 書類ステータス
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- 登録ナンバー
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- 書類有効期限
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- ファイル番号
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- 仕入番号
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- メモ
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_CANSEL_FLG				AS ShiireCancelFlg
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		,[TT_DOC_CONTROL].URIAGE_CANSEL_FLG				AS UriageCancelFlg
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		, COUNT (*) OVER() AS [RowCount]
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	LEFT JOIN TM_SHOP SHOP
	ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
	AND [SHOP].DELETE_FLG = 0
	LEFT JOIN TM_SHOP RAKUSATSU_SHOP
	ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
	AND [RAKUSATSU_SHOP].DELETE_FLG = 0
	-------------------------------------------------------------------------
	-- Condition
	-------------------------------------------------------------------------
	WHERE
		( @ShuppinnTorokuNo IS NULL OR [TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO IN (SELECT TorokuNo FROM @ListTorokuNo)
			OR [TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO IN (SELECT TorokuNo FROM @ListTorokuNo) 
		)
		AND (
				( 
					@ChassisNo IS NULL OR 
						(
							@countlist < 2 AND
							@RadioType = 1 AND [TT_DOC_CONTROL].CHASSIS_NO LIKE '%' + RIGHT(@chassis1,4) COLLATE JAPANESE_BIN
						) 
				)
			OR ( 
					@ChassisNo IS NULL OR 
						(
							@countlist < 2 AND
							@RadioType = 2 AND [TT_DOC_CONTROL].CHASSIS_NO = @chassis1 
						) 
				)
			OR (
					@ChassisNo IS NULL OR 
						(
							@countlist < 2 AND
							@RadioType = 3 AND [TT_DOC_CONTROL].CHASSIS_NO LIKE  @chassis1 + '%' COLLATE JAPANESE_BIN
						) 
				)
			OR ( 
					@ChassisNo IS NULL OR 
						(
							@countlist < 2 AND
							@RadioType = 4 AND [TT_DOC_CONTROL].CHASSIS_NO LIKE '%' + @chassis1 COLLATE JAPANESE_BIN
						) 
				)
			OR ( 
					@ChassisNo IS NULL OR
						( 
							@countlist >= 2 AND 
							[TT_DOC_CONTROL].CHASSIS_NO 
									IN (SELECT ChassisNo FROM @ListChassisNo) 
						)
				)
			)
		AND (
				(
					@ModeSearch = 2 AND (
								TT_DOC_CONTROL.RAKUSATSU_SHOP_CD NOT IN 
										(SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = '書類保留店舗')
									)
				)

			OR (
					@ModeSearch = 3 AND (
								TT_DOC_CONTROL.RAKUSATSU_SHOP_CD NOT IN 
								(SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = '書類保留店舗')
								)
				)
			OR (
					@ModeSearch <> 2 AND @ModeSearch <> 3
				)
		)

		AND ( @ShohinType IS NULL OR [TT_DOC_CONTROL].SHOHIN_TYPE = @ShohinType )
		AND ( @ShopCd IS NULL OR [TT_DOC_CONTROL].SHOP_CD = @ShopCd )
		AND ( @RakusatsuShopCd IS NULL OR [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = @RakusatsuShopCd )
		AND (
				( @DocStatus102 = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '102' )
			OR ( @DocStatus103 = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '103' )
			OR ( @DocStatus104 = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '104' )
			OR ( @DocStatus105 = 1 AND [TT_DOC_CONTROL].DOC_STATUS = '105' )
			OR ( 
				@DocStatus102 = 0 AND @DocStatus103 = 0 AND @DocStatus104 = 0 AND @DocStatus105 = 0 
				AND ([TT_DOC_CONTROL].DOC_STATUS IN ('102','103','104','105'))
				)
			)
		AND ( @FileNo IS NULL OR ISNULL([TT_DOC_CONTROL].RACK_NO,'')+ ISNULL([TT_DOC_CONTROL].FILE_NO,'') = @FileNo )
		AND (( @KeiCarFlg0 = '1' AND [TT_DOC_CONTROL].KEI_CAR_FLG = '0' )
			OR ( @KeiCarFlg1 = '1' AND [TT_DOC_CONTROL].KEI_CAR_FLG = '1' )
			OR (@KeiCarFlg0 = '0' AND @KeiCarFlg1 = '0' AND ([TT_DOC_CONTROL].KEI_CAR_FLG IN ('0','1') OR [TT_DOC_CONTROL].KEI_CAR_FLG IS NULL)))
		AND ( @JishameiFlg = '1' AND [TT_DOC_CONTROL].JISHAMEI_FLG = '1' 
			OR (@JishameiFlg = '0' AND ([TT_DOC_CONTROL].JISHAMEI_FLG IN ('0','1') OR [TT_DOC_CONTROL].JISHAMEI_FLG IS NULL)))
		AND ( @MasshoFlg = '1' AND [TT_DOC_CONTROL].MASSHO_FLG = '1' 
			OR (@MasshoFlg = '0' AND ([TT_DOC_CONTROL].MASSHO_FLG IN ('0','1') OR [TT_DOC_CONTROL].MASSHO_FLG IS NULL )))
		--Add HoaVV fix bug CR84 start
		AND (
			(@IsCanselflg = '1' AND @NoCanselflg = '1' )
			OR( @IsCanselflg = '0' AND @NoCanselflg = '0' )			
			OR (@IsCanselflg = '1' AND @NoCanselflg = '0' AND ([TT_DOC_CONTROL].SHIIRE_CANSEL_FLG = '1' OR [TT_DOC_CONTROL].URIAGE_CANSEL_FLG = '1'))
			OR (@IsCanselflg = '0'  AND @NoCanselflg = '1' AND (([TT_DOC_CONTROL].SHIIRE_CANSEL_FLG <> '1'OR [TT_DOC_CONTROL].SHIIRE_CANSEL_FLG IS NULL) AND ([TT_DOC_CONTROL].URIAGE_CANSEL_FLG <> '1' OR [TT_DOC_CONTROL].URIAGE_CANSEL_FLG IS NULL)))
			OR (@IsCanselflg IS NULL OR @NoCanselflg IS NULL)
			)
		--Add HoaVV fix bug CR84 end
		AND ( @AaDnDateStart IS NULL OR CAST([TT_DOC_CONTROL].AA_KAISAI_DATE AS date) >= CAST(@AaDnDateStart AS date) 
									 OR CAST([TT_DOC_CONTROL].DN_SEIYAKU_DATE AS date) >= CAST(@AaDnDateStart AS date) )
		AND ( @AaDnDateEnd IS NULL OR CAST([TT_DOC_CONTROL].AA_KAISAI_DATE AS date) <= CAST(@AaDnDateEnd AS date)
								   OR CAST([TT_DOC_CONTROL].DN_SEIYAKU_DATE AS date) <= CAST(@AaDnDateEnd AS date) )	
		AND ( @ShoruiLimitDateStart IS NULL OR CAST([TT_DOC_CONTROL].SHORUI_LIMIT_DATE AS date) >= CAST(@ShoruiLimitDateStart AS date) )
		AND ( @ShoruiLimitDateEnd IS NULL OR CAST([TT_DOC_CONTROL].SHORUI_LIMIT_DATE AS date) <= CAST(@ShoruiLimitDateEnd AS date) )
		AND ( @DocNyukoDateStart IS NULL OR CAST([TT_DOC_CONTROL].DOC_NYUKO_DATE AS date) >= CAST(@DocNyukoDateStart AS date) )
		AND ( @DocNyukoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].DOC_NYUKO_DATE AS date) <= CAST(@DocNyukoDateEnd AS date) )
		AND ( @DocShukkoDateStart IS NULL OR CAST([TT_DOC_CONTROL].DOC_SHUKKO_DATE AS date) >= CAST(@DocShukkoDateStart AS date) )
		AND ( @DocShukkoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].DOC_SHUKKO_DATE AS date) <= CAST(@DocShukkoDateEnd AS date) )
		AND ( @JishameiIraiShukkoDateStart IS NULL OR CAST([TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE AS date) >= CAST(@JishameiIraiShukkoDateStart AS date) )
		AND ( @JishameiIraiShukkoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE AS date) <= CAST(@JishameiIraiShukkoDateEnd AS date) )
		AND ( @JishameiKanryoNyukoDateStart IS NULL OR CAST([TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE AS date)>= CAST(@JishameiKanryoNyukoDateStart AS date ) )
		AND ( @JishameiKanryoNyukoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE AS date) <= CAST(@JishameiKanryoNyukoDateEnd AS date ) )
		AND ( @MasshoIraiShukkoDateStart IS NULL OR CAST([TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE AS date) >= CAST(@MasshoIraiShukkoDateStart AS date) )
		AND ( @MasshoIraiShukkoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE AS date) <= CAST(@MasshoIraiShukkoDateEnd AS date) )
		AND ( @MasshoKanryoNyukoDateStart IS NULL OR CAST([TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE AS date) >= CAST(@MasshoKanryoNyukoDateStart AS date) )
		AND ( @MasshoKanryoNyukoDateEnd IS NULL OR CAST([TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE AS date)<= CAST(@MasshoKanryoNyukoDateEnd AS date) )
		AND ( @ShakenLimitDateStart IS NULL OR CAST([TT_DOC_CONTROL].SHAKEN_LIMIT_DATE AS date) >= CAST(@ShakenLimitDateStart AS date) )
		AND ( @ShakenLimitDateEnd IS NULL OR CAST([TT_DOC_CONTROL].SHAKEN_LIMIT_DATE AS date) <= CAST(@ShakenLimitDateEnd AS date) )
		AND [TT_DOC_CONTROL].DELETE_FLG = 0
		--AND (
		--		(@KeiCarFlg0 = '1' OR @KeiCarFlg1 = '1')
		--			AND [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD 
		--			NOT IN (SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = '書類保留店舗')
		--		OR (@KeiCarFlg0 = '0' AND @KeiCarFlg1 = '0')
		--	)

		) AS SearchInfoTempTable
		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1

END



GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003SendToGHQ]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003SendToGHQ]
(	
	@ListSendGHQ		DCW003SendGHQ		READONLY
	,@User	varchar(5)
	,@ErrorMsg	varchar(10)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: HoaVV
-- Programmer		: HoaVV
-- Created Date		: 2015/01/12
-- Comment			: Store insert TT_DOC_CONTROL to TT_GHQ_DOC_UKETORI_OUTPUT
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	INSERT INTO TT_GHQ_DOC_UKETORI_OUTPUT
	(
		TT_GHQ_DOC_UKETORI_OUTPUT.CHASSIS_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHOP_CD
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHUPPINN_TOROKU_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.CAR_TYPE
		,TT_GHQ_DOC_UKETORI_OUTPUT.UKETORIJI_SHORUI_TYPE
		,TT_GHQ_DOC_UKETORI_OUTPUT.LICENSE_PLATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHORUI_FINISH_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.SHORUI_LIMIT_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.Incompleteness
		,TT_GHQ_DOC_UKETORI_OUTPUT.JISHAMEI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.DOC_CONTROL_NO
		,TT_GHQ_DOC_UKETORI_OUTPUT.RENKEI_ZUMI_FLG
		,TT_GHQ_DOC_UKETORI_OUTPUT.NOTE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_DATE
		,TT_GHQ_DOC_UKETORI_OUTPUT.CREATE_USER_CD
	)
	SELECT
		 List.ChassisNo
		,List.ShopCD
		,List.ShiireShuppinnTorokuNo
		,List.KeiCarFlg
		,List.MasshoFlg
		,List.TorokuNo
		,CONVERT(VARCHAR(8),GETDATE(),112)
		,CASE
					WHEN List.ShoruiLimitDate IS NULL THEN '00000000'
					ELSE (CONVERT(VARCHAR(8),List.ShoruiLimitDate,112))
				 END
		,'2'
		,List.JishameiFlg
		,List.DocControlNo
		,'0'
		,''
		,GETDATE()
		,@User

	FROM @ListSendGHQ  List 

END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003UpdateAllDocControl]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003UpdateAllDocControl]
(	
	@ListUpdate				DCW003ListUpdate	READONLY
	,@User						varchar(10)
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/05
-- Comment			: Store update all TT_DOC_CONTROL of DCW003 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON
	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)

	DECLARE @ct_DOC_CONTROL_NO				varchar(13)
	DECLARE @ct_DOC_STATUS					char(3)
	DECLARE @ct_JISHAMEI_FLG				char(1)
	DECLARE @ct_MASSHO_FLG					char(1)
	DECLARE @ct_URIAGE_SHUPPINN_TOROKU_NO	varchar(8)
	DECLARE @ct_DOC_NYUKO_DATE				datetime
	DECLARE @ct_DOC_SHUKKO_DATE				datetime
	DECLARE @ct_JISHAMEI_IRAI_SHUKKO_DATE	datetime
	DECLARE @ct_JISHAMEI_IRAI_NYUKO_DATE	datetime
	DECLARE @ct_MASSHO_IRAI_SHUKKO_DATE		datetime
	DECLARE @ct_MASSHO_IRAI_NYUKO_DATE		datetime
	DECLARE @ct_SHORUI_LIMIT_DATE			datetime
	DECLARE @ct_SHAKEN_LIMIT_DATE			datetime
	DECLARE @ct_MEMO						varchar(500)

	DECLARE doc_cursor CURSOR 
	FOR SELECT [DocControlNo]				
				,[MasshoFlg]				
				,[JishameiFlg]				
				,[DocStatus]					
				,[DocNyukoDate]				
				,[DocShukkoDate]
				,[UriageShuppinTorokuNo]				
				,[JishameiIraiShukkoDate]	
				,[JishameiIraiNyukoDate]	
				,[MasshoIraiShukkoDate]		
				,[MasshoIraiNyukoDate]	
				,[ShoruiLimitDate]	
				,[ShakenLimitDate]
				,[Memo]						 FROM @ListUpdate

	OPEN doc_cursor

	FETCH NEXT FROM doc_cursor INTO @ct_DOC_CONTROL_NO, @ct_MASSHO_FLG, @ct_JISHAMEI_FLG,@ct_DOC_STATUS, @ct_DOC_NYUKO_DATE, @ct_DOC_SHUKKO_DATE, @ct_URIAGE_SHUPPINN_TOROKU_NO
									, @ct_JISHAMEI_IRAI_SHUKKO_DATE, @ct_JISHAMEI_IRAI_NYUKO_DATE, @ct_MASSHO_IRAI_SHUKKO_DATE, @ct_MASSHO_IRAI_NYUKO_DATE,@ct_SHORUI_LIMIT_DATE,@ct_SHAKEN_LIMIT_DATE ,@ct_MEMO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		

		-------------------------------------------------------------------------
		-- Update
		-------------------------------------------------------------------------
		UPDATE TT_DOC_CONTROL SET
				[TT_DOC_CONTROL].DOC_STATUS						= @ct_DOC_STATUS
				,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		= @ct_URIAGE_SHUPPINN_TOROKU_NO
				,[TT_DOC_CONTROL].JISHAMEI_FLG					= @ct_JISHAMEI_FLG
				,[TT_DOC_CONTROL].MASSHO_FLG					= @ct_MASSHO_FLG
				,[TT_DOC_CONTROL].DOC_NYUKO_DATE				= @ct_DOC_NYUKO_DATE
				,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				= @ct_DOC_SHUKKO_DATE
				,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		= @ct_JISHAMEI_IRAI_SHUKKO_DATE
				,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	= @ct_JISHAMEI_IRAI_NYUKO_DATE
				,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		= @ct_MASSHO_IRAI_SHUKKO_DATE
				,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		= @ct_MASSHO_IRAI_NYUKO_DATE
				,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				= @ct_SHORUI_LIMIT_DATE
				,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				= @ct_SHAKEN_LIMIT_DATE
				,[TT_DOC_CONTROL].MEMO							= @ct_MEMO
				,[TT_DOC_CONTROL].UPDATE_DATE					= GETDATE()
				,[TT_DOC_CONTROL].UPDATE_USER_CD				= @User
		WHERE
				[TT_DOC_CONTROL].DOC_CONTROL_NO = @ct_DOC_CONTROL_NO
				AND [TT_DOC_CONTROL].DELETE_FLG = 0	

		UPDATE TT_DOC_CONTROL SET
				[TT_DOC_CONTROL].SHOP_CD						= TT_DN_CAR_INFO.SHOP_CD
				,[TT_DOC_CONTROL].RAKUSATSU_SHOP_CD				= TT_DN_CAR_INFO.RAKUSATSU_SHOP_CD
				,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				= TT_DN_CAR_INFO.DN_SEIYAKU_DATE
				,[TT_DOC_CONTROL].SHIIRE_NO						= TT_DN_CAR_INFO.SHIIRE_NO
				,[TT_DOC_CONTROL].CAR_SUB_ID					= TT_DN_CAR_INFO.CAR_SUB_ID
		FROM TT_DOC_CONTROL WITH(NOLOCK)
				INNER JOIN TT_DN_CAR_INFO WITH(NOLOCK)
				ON TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = @ct_URIAGE_SHUPPINN_TOROKU_NO
		WHERE
				[TT_DOC_CONTROL].DOC_CONTROL_NO = @ct_DOC_CONTROL_NO
				AND [TT_DOC_CONTROL].DELETE_FLG = 0	
		
		-------------------------------------------------------------------------
		-- Insert History
		-------------------------------------------------------------------------
		EXEC USP_MAKE_HISTORY @ct_DOC_CONTROL_NO,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT

		FETCH NEXT FROM doc_cursor INTO @ct_DOC_CONTROL_NO, @ct_MASSHO_FLG, @ct_JISHAMEI_FLG,@ct_DOC_STATUS, @ct_DOC_NYUKO_DATE, @ct_DOC_SHUKKO_DATE, @ct_URIAGE_SHUPPINN_TOROKU_NO
									, @ct_JISHAMEI_IRAI_SHUKKO_DATE, @ct_JISHAMEI_IRAI_NYUKO_DATE, @ct_MASSHO_IRAI_SHUKKO_DATE, @ct_MASSHO_IRAI_NYUKO_DATE ,@ct_SHORUI_LIMIT_DATE , @ct_SHAKEN_LIMIT_DATE, @ct_MEMO
	END
	
	CLOSE doc_cursor
    DEALLOCATE doc_cursor          

END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003UpdateDocControl]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_DCW003UpdateDocControl]
(	
	@DocControlNo				varchar(13)
	,@UriageShuppinnTorokuNo	varchar(8)
	,@MasshoFlg					char(1)
	,@JishameiFlg				char(1)
	,@DocStatus					char(3)
	,@DocNyukoDate				datetime
	,@DocShukkoDate				datetime
	,@JishameiIraiShukkoDate	datetime
	,@JishameiKanryoNyukoDate	datetime
	,@MasshoIraiShukkoDate		datetime
	,@MasshoKanryoNyukoDate		datetime
	,@ShoruiLimitDate			datetime
	,@ShakenLimitDate			datetime
	,@Memo						varchar(500)
	,@User						varchar(10)
	,@ErrorMsg					varchar(5)  OUT
)
AS

---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: NghiaDT1
-- Programmer		: NghiaDT1
-- Created Date		: 2015/12/05
-- Comment			: Store update TT_DOC_CONTROL of DCW003 
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	DECLARE @p_saiban_value	varchar(16)
	DECLARE @p_result_id	int
	DECLARE @p_result_msg	varchar(2000)
	
	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	UPDATE TT_DOC_CONTROL SET
		[TT_DOC_CONTROL].DOC_STATUS						= @DocStatus
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		= @UriageShuppinnTorokuNo 
		,[TT_DOC_CONTROL].JISHAMEI_FLG					= @JishameiFlg 
		,[TT_DOC_CONTROL].MASSHO_FLG					= @MasshoFlg
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				= @DocNyukoDate
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				= @DocShukkoDate
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		= @JishameiIraiShukkoDate
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	= @JishameiKanryoNyukoDate
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		= @MasshoIraiShukkoDate
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		= @MasshoKanryoNyukoDate
		,[TT_DOC_CONTROL].MEMO							= @Memo
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				= @ShoruiLimitDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				= @ShakenLimitDate
		,[TT_DOC_CONTROL].UPDATE_DATE					= GETDATE()
		,[TT_DOC_CONTROL].UPDATE_USER_CD				= @User
		WHERE
			[TT_DOC_CONTROL].DOC_CONTROL_NO	= @DocControlNo
		AND [TT_DOC_CONTROL].DELETE_FLG = 0
		
	UPDATE TT_DOC_CONTROL SET
		 [TT_DOC_CONTROL].SHOP_CD						= TT_DN_CAR_INFO.SHOP_CD
		,[TT_DOC_CONTROL].RAKUSATSU_SHOP_CD				= TT_DN_CAR_INFO.RAKUSATSU_SHOP_CD
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				= TT_DN_CAR_INFO.DN_SEIYAKU_DATE
		,[TT_DOC_CONTROL].SHIIRE_NO						= TT_DN_CAR_INFO.SHIIRE_NO
		,[TT_DOC_CONTROL].CAR_SUB_ID					= TT_DN_CAR_INFO.CAR_SUB_ID
			FROM TT_DOC_CONTROL WITH(NOLOCK)
				INNER JOIN TT_DN_CAR_INFO WITH(NOLOCK)
				ON  TT_DN_CAR_INFO.SHUPPINN_TOROKU_NO = @UriageShuppinnTorokuNo

			WHERE TT_DOC_CONTROL.DOC_CONTROL_NO = @DocControlNo
			AND TT_DOC_CONTROL.DELETE_FLG = 0


		---Reload data 
		SELECT
		ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')				AS ShopName
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'')+' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo						
				
		FROM [TT_DOC_CONTROL]WITH(NOLOCK)
			LEFT JOIN TM_SHOP SHOP
			ON [TT_DOC_CONTROL].SHOP_CD = [SHOP].TEMPO_CD
			LEFT JOIN TM_SHOP RAKUSATSU_SHOP
			ON [TT_DOC_CONTROL].RAKUSATSU_SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
			AND [RAKUSATSU_SHOP].DELETE_FLG = 0

		WHERE TT_DOC_CONTROL.DOC_CONTROL_NO = @DocControlNo
		AND TT_DOC_CONTROL.DELETE_FLG = 0
		
	-------------------------------------------------------------------------
	-- Insert History
	-------------------------------------------------------------------------
	EXEC USP_MAKE_HISTORY @DocControlNo,NULL,@User,@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT


	IF	@@ROWCOUNT = 0
	BEGIN
		SET @ErrorMsg = 'W0010'
	END	
END

GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003UpdateHensoIf]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[stp_GetMessageAll]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[stp_GetMessageAll]
AS


BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		MessageId
		, Class
		, Message
		, ButtonOK
		, ButtonNOK
		, ButtonCancel
		, DefaultButton
	FROM TM_MESSAGE WITH (NOLOCK)
END




GO

/****** Object:  StoredProcedure [dbo].[stp_GetSuggestionShopCd]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_GetSuggestionShopCd]
(
	@MaxResult					INT
	,@TextPattern				VARCHAR(60)
)
AS
-----------------------------------------------------------------------------
-- Version		: 001
-- Designer		: NghiaDT1
-- Programmer	: NghiaDT1
-- Date			: 2015/12/07
-- Comment		: Create new
-----------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------

	SELECT TOP (@MaxResult) 
		TEMPO_CD AS FieldCode
		,ISNULL(TEMPO_NAME, '') AS FieldName
	FROM
		TM_SHOP WITH (NOLOCK)
	WHERE
		TEMPO_CD LIKE '%'+@TextPattern+'%'COLLATE JAPANESE_BIN
		AND DELETE_FLG = 0
	ORDER BY
		TEMPO_CD ASC
END


GO

/****** Object:  StoredProcedure [dbo].[stp_GetSuggestionShopName]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[stp_GetSuggestionShopName]
(
	@MaxResult					INT
	,@TextPattern				VARCHAR(60)
)
AS
-----------------------------------------------------------------------------
-- Version		: 001
-- Designer		: NghiaDT1
-- Programmer	: NghiaDT1
-- Date			: 2015/12/07
-- Comment		: Create new
-----------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------

	SELECT TOP (@MaxResult) 
		TEMPO_CD AS FieldCode
		,ISNULL(TEMPO_NAME, '') AS FieldName
	FROM
		TM_SHOP WITH (NOLOCK)
	WHERE
		TEMPO_NAME LIKE '%'+@TextPattern+'%'COLLATE JAPANESE_BIN
		AND DELETE_FLG = 0
	ORDER BY
		TEMPO_CD ASC
END


GO

/****** Object:  StoredProcedure [dbo].[stp_InsertAAFax]    Script Date: 2016/01/28 18:31:50 ******/
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

/****** Object:  StoredProcedure [dbo].[stp_InsertDNFax]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[stp_InsertDNFax]
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
		-- INSERT TT_DN_BIHIN_SOFU_SHIJI_FAX
		-------------------------------------------------------------------------
		INSERT INTO [dbo].[TT_DN_BIHIN_SOFU_SHIJI_FAX]
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
           ,'BAT_DN_FAX'
           ,GETDATE()
           ,NULL
           ,'BAT_DN_FAX'
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

/****** Object:  StoredProcedure [dbo].[stp_RC002_ExportCsv]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD
-- Created Date        			: 2015/12/16 
-- Comment                      : Store Export CSV
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RC002_ExportCsv]
AS
BEGIN
	SELECT 
	  ISNULL(DC.RACK_NO,'') + ISNULL(DC.FILE_NO,'') AS FILE_NO
	, DC.CHASSIS_NO
	, DF.RFID_KYE 
	FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
		INNER JOIN TM_DOC_FILE_NO AS DF WITH(NOLOCK)
		ON DC.FILE_NO = DF.FILE_NO
		WHERE DC.DOC_STATUS IN ('102','103','104')
END
GO

/****** Object:  StoredProcedure [dbo].[stp_RD0010_ReportPrintPages]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2015/12/03 
-- Comment                      : Store PrintPage RD0020
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0010_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
	DHF.SHOP_CD AS 'ShopCd'
	, S.TEMPO_NAME AS 'ShopName'
	, DC.CAR_NAME AS 'CarName'
	, DC.CHASSIS_NO AS 'ChassisNo'
	, DC.SHIIRE_SHUPPINN_TOROKU_NO AS 'TorokuNo'
	, DHF.DOC_HENSO_RIYU AS 'HensoRiyu'
	, DHF.NOTE AS 'Note'
	, DHF.TANTOSHA_NAME AS 'TantoshaName'
	, DHF.JISHAMEI_DOC_MAKE_YOUHI AS 'Jishamei'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_FAX'
	) AS 'FAX'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_TEL'
	) AS 'TEL'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = '送付元チーム名'
	) AS 'DN'

	 FROM TT_DOC_HENSO_IF AS DHF WITH(NOLOCK)
		INNER JOIN TT_DOC_CONTROL AS DC WITH(NOLOCK)
		ON
			DC.CHASSIS_NO = DHF.CHASSIS_NO
			AND (
					DHF.SHUPPINN_TOROKU_NO = DC.SHIIRE_SHUPPINN_TOROKU_NO
					OR DHF.SHUPPINN_TOROKU_NO = DC.URIAGE_SHUPPINN_TOROKU_NO
				)
			--AND DHF.HENSO_ZUMI_FLG = '0'
			AND DHF.DELETE_FLG = 0
		LEFT JOIN TM_SHOP AS S WITH(NOLOCK)
		ON
			DHF.SHOP_CD = S.TEMPO_CD
			AND S.DELETE_FLG = 0
		INNER JOIN @list AS lst
		ON DC.DOC_CONTROL_NO = lst.Item
	 ORDER BY lst.ID

END
GO

/****** Object:  StoredProcedure [dbo].[stp_RD0020_ReportPrintPages]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2015/12/03 
-- Comment                      : Store PrintPage 
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0020_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
	DC.RAKUSATSU_SHOP_CD AS SHOP_CD
	, DC.CHASSIS_NO
	, DC.CAR_NAME, DC.SHIIRE_NO
	, S1.TEMPO_NAME AS 'TEMPO_NAME', DJ.SHOP_CD AS DJ_SHOPCD, S2.TEMPO_NAME AS 'TEMPO_NAME_DJ'
	--, CONCAT(DC.RACK_NO,DC.FILE_NO) AS CONTROL_NUMBER
	, ISNULL(DC.RACK_NO,'') + ISNULL(DC.FILE_NO,'')  AS CONTROL_NUMBER
	--, (
	--SELECT CT.VALUE FROM TM_CONST WHERE CT.TYPE ='自社名依頼書表示用'
	--)
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_FAX'
	) AS 'FAX'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = 'J-NET_TEL'
	) AS 'TEL'
	,(
		SELECT TM_CONST.VALUE FROM TM_CONST WHERE TM_CONST.TYPE_VALUE = '送付元チーム名'
	) AS 'DN'

	 FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
	 LEFT JOIN TT_DOC_JISHAMEI_MASSHO_IF AS DJ WITH(NOLOCK) ON DJ.DOC_CONTROL_NO = DC.DOC_CONTROL_NO
	 AND DJ.DELETE_FLG = 0
	 LEFT JOIN TM_SHOP AS S1 WITH(NOLOCK) ON DC.RAKUSATSU_SHOP_CD = S1.TEMPO_CD
	 AND S1.DELETE_FLG = 0
	 LEFT JOIN TM_SHOP AS S2 WITH(NOLOCK) ON DJ.SHOP_CD = S2.TEMPO_CD
	 AND S2.DELETE_FLG = 0
	 INNER JOIN @list AS lst ON DC.DOC_CONTROL_NO = lst.Item
	 WHERE DC.DELETE_FLG = 0
	 ORDER BY lst.ID
END
GO

/****** Object:  StoredProcedure [dbo].[stp_RD0030_ReportPrintPages]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD 
-- Created Date        			: 2016/01/22 
-- Comment                      : Store PrintPage 
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RD0030_ReportPrintPages]
	@list StringList READONLY
AS
BEGIN
	SELECT 
		 DC.AA_KAISAI_KAISU AS 'AA_KAISAI_KAISU'
		,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(MONTH, DC.AA_KAISAI_DATE)),2) AS 'AA_KAISAI_MONTH'
		,RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, AA_KAISAI_DATE)),2) AS 'AA_KAISAI_DATE'
		,DC.AA_SHUPPIN_NO AS 'AA_SHUPPIN_NO'
		,AA.KAIIN_NO AS 'URIAGE_AA_KAIJO_CD'
		,DC.CAR_NAME AS 'CAR_NAME'
		,DC.CHASSIS_NO AS 'CHASSIS_NO'
	FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
	INNER JOIN @list AS lst ON DC.DOC_CONTROL_NO = lst.Item
	LEFT JOIN TM_AA_KAIJO AS AA WITH(NOLOCK)
	ON AA.AA_KAIJO_CD = DC.URIAGE_AA_KAIJO
	WHERE DC.DELETE_FLG = 0
	ORDER BY lst.ID
END
GO

/****** Object:  StoredProcedure [dbo].[stp_UpdateAACancel]    Script Date: 2016/01/28 18:31:50 ******/
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

/****** Object:  StoredProcedure [dbo].[stp_UpdateAHCancel]    Script Date: 2016/01/28 18:31:50 ******/
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
			EXEC USP_MAKE_HISTORY @DocControlNo,NULL,'UPDATE_DOC',@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
			IF @p_result_id != 0
			BEGIN
				RETURN 1
			END
		-------------------------------------------------------------------------
		-- Update A => H Cancel
		-------------------------------------------------------------------------
			Update [dbo].TT_DOC_CONTROL SET									
					 SHIIRE_CANSEL_FLG ='1'
					,UPDATE_DATE =GETDATE()
					,UPDATE_PG_CD='UPDATE_DOC'					
			WHERE DOC_CONTROL_NO = @DocControlNo
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

/****** Object:  StoredProcedure [dbo].[stp_UpdateAHHBCancel]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[stp_UpdateAHHBCancel]
(	
	@DocControlNo		varchar(13)	
	,@ShopCD			char(6)
	,@RakusatsuShopCD   char(6)
	,@DNSeiyakuDate     datetime
	,@ShiireNo          varchar(5)
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
			EXEC USP_MAKE_HISTORY @DocControlNo,NULL,'UPDATE_DOC',@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
			IF @p_result_id != 0
			BEGIN
				RETURN 1
			END
		-------------------------------------------------------------------------
		-- Update A => H Cancel
		-------------------------------------------------------------------------
			Update TT_DOC_CONTROL SET												
						URIAGE_SHUPPINN_TOROKU_NO=  NULL									
						,SHOP_CD  = @ShopCD		
						,RAKUSATSU_SHOP_CD = @RakusatsuShopCD						
						,DN_SEIYAKU_DATE = @DNSeiyakuDate							
						,SHIIRE_NO = @ShiireNo 
						,CAR_SUB_ID= @CarSubID 
						,URIAGE_CANSEL_FLG ='1'								
						,UPDATE_DATE =GETDATE()
						,UPDATE_PG_CD='UPDATE_DOC'															
			WHERE DOC_CONTROL_NO = @DocControlNo
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

/****** Object:  StoredProcedure [dbo].[stp_UpdateNewAA]    Script Date: 2016/01/28 18:31:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[stp_UpdateNewAA]
(	
	 @CarID			char(16)							
	,@CarSubID		char(3)				
	,@ShopCD		char(6)
	,@AAKaijoCD		char(6)					
	,@AAKaisaiKaisu int					
	,@AAKaisaiDate	datetime				
	,@AAShuppinNO	varchar(5)
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
		-- Update NewAA
		-------------------------------------------------------------------------
		UPDATE  [TT_DOC_CONTROL] SET
			 URIAGE_AA_KAIJO = @AAKaijoCD		
			,AA_KAISAI_KAISU = @AAKaisaiKaisu		
			,AA_KAISAI_DATE = @AAKaisaiDate		
			,AA_SHUPPIN_NO = @AAShuppinNO
			,SHOHIN_TYPE = '201'
			,UPDATE_DATE = getdate()
			,UPDATE_PG_CD = 'UPDATE_DOC'
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

/****** Object:  StoredProcedure [dbo].[stp_UpdateNewDNNo]    Script Date: 2016/01/28 18:31:50 ******/
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
			EXEC USP_MAKE_HISTORY @DocControlNo,NULL,'UPDATE_DOC',@p_saiban_value OUT,@p_result_id OUT ,@p_result_msg OUT
			IF @p_result_id != 0
			BEGIN
				RETURN 1
			END
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

