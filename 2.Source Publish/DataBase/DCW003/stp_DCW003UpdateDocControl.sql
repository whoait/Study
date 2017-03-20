IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003UpdateDocControl' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003UpdateDocControl
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


