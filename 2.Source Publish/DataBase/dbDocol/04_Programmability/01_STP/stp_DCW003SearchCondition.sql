USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003SearchCondition]    Script Date: 2016/01/28 15:55:29 ******/
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

