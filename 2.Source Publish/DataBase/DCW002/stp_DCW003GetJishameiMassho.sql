IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetJishameiMassho' AND user_name(schema_id) = 'dbo') 
DROP PROC stp_DCW003GetJishameiMassho
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetJishameiMassho]    Script Date: 12/19/2015 11:26:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------
-- Version			: 001
-- Designer			: TramD
-- Programmer		: TramD
-- Created Date		: 2015/12/19
-- Comment			: 
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_DCW003GetJishameiMassho]
	@List  DCW003JishameiMassho READONLY
AS


BEGIN
	SELECT 
		DC.DOC_CONTROL_NO					AS DocControlNo							-- 書類管理番号
		,DC.SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- 仕入DN出品番号
		,DC.URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- 売上DN出品番号
		,DC.CHASSIS_NO					AS ChassisNo							-- 車台番号
		,[SHOP].TEMPO_NAME								AS ShopName								-- 出品店情報
		,[RAKUSATSU_SHOP].TEMPO_NAME					AS RakusatsuShopName					-- 落札店情報
		,DC.SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- 仕入AA会場
		,DC.URIAGE_AA_KAIJO				AS UriageAaKaijo						-- 売上AA会場
		,DC.NENSHIKI						AS Nenshiki								-- 年式
		,DC.KEI_CAR_FLG					AS KeiCarFlg							-- 車輌区分
		,DC.AA_KAISAI_DATE				AS AaKaisaiDate							-- AA開催日
		,DC.MAKER_NAME					AS MakerName							-- メーカー
		,DC.CAR_NAME						AS CarName								-- 車名
		,DC.GRADE_NAME					AS GradeName							-- グレード
		,DC.AA_SHUPPIN_NO					AS AaShuppinNo							-- AA番号
		,DC.DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN成約日
		,DC.KATASHIKI						AS Katashiki							-- 型式
		,DC.MASSHO_FLG					AS MasshoFlg							-- 書類区分
		,DC.JISHAMEI_FLG					AS JishameiFlg							-- 自社名区分
		--, (SELECT CASE WHEN Jisame_Masso_Type = '自社名依頼' THEN '103' END,
		--	CASE WHEN Jisame_Masso_Type = '抹消依頼' THEN '104' END
		 --FROM @List AS List ) AS DocStatus
		 , CASE 
				WHEN List.Jisame_Masso_Type = '自社名依頼' 
				THEN '103' 
				WHEN List.Jisame_Masso_Type = '抹消依頼' 
				THEN '104' 
			END AS DocStatus
		--,DC.DOC_STATUS					AS DocStatus							-- 書類ステータス
		,DC.TOROKU_NO						AS TorokuNo								-- 登録ナンバー
		,DC.SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- 書類有効期限
		,DC.FILE_NO						AS FileNo								-- ファイル番号
		,DC.SHIIRE_NO						AS ShiireNo								-- 仕入番号
		,DC.SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- 車検満了日
		,DC.DOC_NYUKO_DATE				AS DocNyukoDate							-- 書類入庫日
		,GETDATE()		AS JishameiIraiShukkoDate				-- 自社名依頼日
		,GETDATE()		AS MasshoIraiShukkoDate					-- 抹消依頼日
		,DC.DOC_SHUKKO_DATE				AS DocShukkoDate						-- 書類出庫日
		,DC.JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- 自社名完了日
		,DC.MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- 抹消完了日
		,DC.MEMO							AS Memo									-- メモ
		, COUNT (*) OVER() AS [RowCount]
		, DJ.DOC_CONTROL_NO AS ID --書類管理番号
		, List.[IraiDate] AS IraiDate
		, List.[ShopCd] AS ShopCd
		, List.[GenshaLocation] AS GenshaLocation
		, List.[Jisame_Masso_Type] AS Jisame_Masso_Type
		, List.[CarName] AS CarNameJ
		, List.[ChassisNo] AS ChassisNoJ
		, List.Note AS Note
	FROM 
		TT_DOC_CONTROL AS DC WITH(NOLOCK)
		LEFT JOIN TM_SHOP SHOP WITH(NOLOCK)
		ON DC.SHOP_CD = [SHOP].TEMPO_CD
		AND [SHOP].DELETE_FLG = 0
		LEFT JOIN TM_SHOP RAKUSATSU_SHOP WITH(NOLOCK)
		ON DC.SHOP_CD = [RAKUSATSU_SHOP].TEMPO_CD
		AND [RAKUSATSU_SHOP].DELETE_FLG = 0
		INNER JOIN TM_DOC_FILE_NO WITH(NOLOCK)
		ON DC.RACK_NO = TM_DOC_FILE_NO.RACK_NO
		AND DC.FILE_NO = TM_DOC_FILE_NO.FILE_NO
		INNER JOIN @List AS List
		ON 
		(
			DC.CHASSIS_NO = List.ChassisNo
		)
		LEFT JOIN TT_DOC_JISHAMEI_MASSHO_IF AS DJ WITH(NOLOCK)
		ON DC.DOC_CONTROL_NO = DJ.DOC_CONTROL_NO

END