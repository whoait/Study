IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetListImport' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003GetListImport
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
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- 車台番号
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- 出品店情報
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- 落札店情報
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
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- 仕入番号
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- メモ
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


