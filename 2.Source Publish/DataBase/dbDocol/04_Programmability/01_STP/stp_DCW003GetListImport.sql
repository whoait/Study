USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW003GetListImport]    Script Date: 2016/01/28 15:52:10 ******/
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

