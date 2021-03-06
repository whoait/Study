IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003SearchCondition' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003SearchCondition
GO

CREATE PROC [dbo].[stp_DCW003SearchCondition]
(	
	@ShuppinnTorokuNo varchar(8)						-- oio^Ô
	,@ListTorokuNo	DCW003TorokuNo	READONLY
	,@ListChassisNo	DCW003ChassisNo READONLY
	, @RadioType char(1)								-- Type search
	, @ChassisNo varchar(25)							-- ÔäÔ
	, @ShohinType char(3)								-- DN - AA
	, @ShopCd char(6)									-- oiXÜ
	, @ShopName	varchar(60)								-- oiXÜ¼Ì
	, @RakusatsuShopCd char(6)							-- DXÜ
	, @RakusatsuShopName varchar(60)					-- DXÜ¼Ì
	, @DocStatus102 int								-- ÞXe[^X - ÛÇ
	, @DocStatus103 int								-- ÞXe[^X - ©Ð¼
	, @DocStatus104 int								-- ÞXe[^X - Á
	, @DocStatus105 int								-- ÞXe[^X - ÛÇÈµ(­Ï)
	, @FileNo char(5)									-- t@CÔ
	, @KeiCarFlg0 char(1)								-- Ôçqæª - ÊÔ
	, @KeiCarFlg1 char(1)								-- Ôçqæª - y
	, @JishameiFlg char(1)								-- Þæª - ©Ð¼tO
	, @MasshoFlg char(1)								-- Þæª - ÁtO
	, @AaDnDateStart datetime							-- ¬ñú/DJÃú - START
	, @AaDnDateEnd datetime								-- ¬ñú/DJÃú - END
	, @ShoruiLimitDateStart datetime					-- ÞLøúÀ - START
	, @ShoruiLimitDateEnd datetime						-- ÞLøúÀ - END
	, @DocNyukoDateStart datetime						-- ÞüÉú - START
	, @DocNyukoDateEnd datetime							-- ÞüÉú - END
	, @DocShukkoDateStart datetime						-- ÞoÉú - START
	, @DocShukkoDateEnd datetime						-- ÞoÉú - END
	, @JishameiIraiShukkoDateStart datetime				-- ©Ð¼ËoÉú - START
	, @JishameiIraiShukkoDateEnd datetime				-- ©Ð¼ËoÉú - END
	, @JishameiKanryoNyukoDateStart datetime			-- ©Ð¼®¹oÉú - START
	, @JishameiKanryoNyukoDateEnd datetime				-- ©Ð¼®¹oÉú - END
	, @MasshoIraiShukkoDateStart datetime				-- ÁËoÉú - START
	, @MasshoIraiShukkoDateEnd datetime					-- ÁËoÉú - END
	, @MasshoKanryoNyukoDateStart datetime				-- Á®¹oÉú - START
	, @MasshoKanryoNyukoDateEnd datetime				-- Á®¹oÉú - END
	, @ShakenLimitDateStart datetime					-- Ô¹ú - START
	, @ShakenLimitDateEnd datetime						-- Ô¹ú - END
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
		,[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- ÞÇÔ
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- düDNoiÔ
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- ãDNoiÔ
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- ÔäÔ
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- oiXîñ
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'')+' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- DXîñ
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- düAAïê
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- ãAAïê
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- N®
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- Ôçqæª
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AAJÃú
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- [J[
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- Ô¼
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- O[h
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AAÔ
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN¬ñú
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- ^®
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg
		,[TT_DOC_CONTROL].SHOP_CD						AS ShopCd	
		,[TT_DOC_CONTROL].CC							AS CcName		
		,[TT_DOC_CONTROL].JOSHA_TEIIN_NUM				AS JoshaTeiinNum				

		,(CASE [TT_DOC_CONTROL].JISHAMEI_FLG
			 WHEN '1' THEN '1'
			 ELSE '0'
		 END) AS JishameiFlg
		
		--[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- ©Ð¼æª
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- ÞXe[^X
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- o^io[
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- ÞLøúÀ
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- t@CÔ
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- düÔ
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- Ô¹ú
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- ÞüÉú
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- ©Ð¼Ëú
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- ÁËú
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- ÞoÉú
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- ©Ð¼®¹ú
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- Á®¹ú
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- 
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
										(SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = 'ÞÛ¯XÜ')
									)
				)

			OR (
					@ModeSearch = 3 AND (
								TT_DOC_CONTROL.RAKUSATSU_SHOP_CD NOT IN 
								(SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = 'ÞÛ¯XÜ')
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
		--			NOT IN (SELECT VALUE FROM TM_CONST WHERE TM_CONST.TYPE = 'ÞÛ¯XÜ')
		--		OR (@KeiCarFlg0 = '0' AND @KeiCarFlg1 = '0')
		--	)

		) AS SearchInfoTempTable
		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1

END


GO
