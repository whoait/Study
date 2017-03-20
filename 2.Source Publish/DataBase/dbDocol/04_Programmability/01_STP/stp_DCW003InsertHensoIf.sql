USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003InsertHensoIf]    Script Date: 2016/01/28 17:09:54 ******/
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

