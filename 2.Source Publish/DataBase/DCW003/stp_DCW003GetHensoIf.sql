IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003GetHensoIf' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003GetHensoIf
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
		[TT_DOC_CONTROL].DOC_CONTROL_NO					AS DocControlNo							-- ���ފǗ��ԍ�
		,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO		AS ShiireShuppinnTorokuNo				-- �d��DN�o�i�ԍ�
		,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO		AS UriageShuppinnTorokuNo				-- ����DN�o�i�ԍ�
		,[TT_DOC_CONTROL].CHASSIS_NO					AS ChassisNo							-- �ԑ�ԍ�
		,ISNULL([SHOP].TEMPO_CD,'') +' '+ISNULL([SHOP].TEMPO_NAME,'')								AS ShopName								-- �o�i�X���
		,ISNULL([RAKUSATSU_SHOP].TEMPO_CD,'') +' '+ISNULL([RAKUSATSU_SHOP].TEMPO_NAME,'')			AS RakusatsuShopName					-- ���D�X���
		,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO				AS ShiireAaKaijo						-- �d��AA���
		,[TT_DOC_CONTROL].URIAGE_AA_KAIJO				AS UriageAaKaijo						-- ����AA���
		,[TT_DOC_CONTROL].NENSHIKI						AS Nenshiki								-- �N��
		,[TT_DOC_CONTROL].KEI_CAR_FLG					AS KeiCarFlg							-- ���q�敪
		,[TT_DOC_CONTROL].AA_KAISAI_DATE				AS AaKaisaiDate							-- AA�J�Ó�
		,[TT_DOC_CONTROL].MAKER_NAME					AS MakerName							-- ���[�J�[
		,[TT_DOC_CONTROL].CAR_NAME						AS CarName								-- �Ԗ�
		,[TT_DOC_CONTROL].GRADE_NAME					AS GradeName							-- �O���[�h
		,[TT_DOC_CONTROL].AA_SHUPPIN_NO					AS AaShuppinNo							-- AA�ԍ�
		,[TT_DOC_CONTROL].DN_SEIYAKU_DATE				AS DnSeiyakuDate						-- DN�����
		,[TT_DOC_CONTROL].KATASHIKI						AS Katashiki							-- �^��
		--,(CASE
		--	WHEN [List].ReportType = '1' THEN '0'
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN '1' 
		--	ELSE [TT_DOC_CONTROL].MASSHO_FLG
		--	END) AS MasshoFlg
		,TT_DN_CAR_INFO.MASSHO_FLG AS DnMasshoFlg
		,[TT_DOC_CONTROL].MASSHO_FLG					AS MasshoFlg							-- ���ދ敪
		,[TT_DOC_CONTROL].JISHAMEI_FLG					AS JishameiFlg							-- ���Ж��敪
		,[TT_DOC_CONTROL].DOC_STATUS					AS DocStatus							-- ���ރX�e�[�^�X
		,[TT_DOC_CONTROL].TOROKU_NO						AS TorokuNo								-- �o�^�i���o�[
		,[TT_DOC_CONTROL].SHORUI_LIMIT_DATE				AS ShoruiLimitDate						-- ���ޗL������
		,[TT_DOC_CONTROL].FILE_NO						AS FileNo								-- �t�@�C���ԍ�
		,[TT_DOC_CONTROL].RACK_NO						AS RacNo
		,[TT_DOC_CONTROL].SHIIRE_NO						AS ShiireNo								-- �d���ԍ�
		--,(CASE
		--	WHEN [List].ReportType = '2' OR [List].ReportType = '4' THEN NULL 
		--	ELSE [TT_DOC_CONTROL].SHAKEN_LIMIT_DATE
		--	END) AS ShakenLimitDate
		,[TT_DOC_CONTROL].SHAKEN_LIMIT_DATE				AS ShakenLimitDate						-- �Ԍ�������
		,[TT_DOC_CONTROL].DOC_NYUKO_DATE				AS DocNyukoDate							-- ���ޓ��ɓ�
		,[TT_DOC_CONTROL].JISHAMEI_IRAI_SHUKKO_DATE		AS JishameiIraiShukkoDate				-- ���Ж��˗���
		,[TT_DOC_CONTROL].MASSHO_IRAI_SHUKKO_DATE		AS MasshoIraiShukkoDate					-- �����˗���
		,[TT_DOC_CONTROL].DOC_SHUKKO_DATE				AS DocShukkoDate						-- ���ޏo�ɓ�
		,[TT_DOC_CONTROL].JISHAMEI_KANRYO_NYUKO_DATE	AS JishameiKanryoNyukoDate				-- ���Ж�������
		,[TT_DOC_CONTROL].MASSHO_KANRYO_NYUKO_DATE		AS MasshoKanryoNyukoDate				-- ����������
		,[TT_DOC_CONTROL].MEMO							AS Memo									-- ����
		,[TT_DOC_CONTROL].MEIHEN_SHAKEN_TOROKU_DATE		AS MeihenShakenTorokuDate
		, ROW_NUMBER() OVER(ORDER BY TT_DOC_CONTROL.DOC_CONTROL_NO) AS RowNum
		,List.ID	AS ID
		--, TT_DOC_HENSO_IF.ID					AS ID
		,COUNT (*) OVER() AS [RowCount]
		--,TT_DOC_HENSO_IF.HENSO_ZUMI_FLG AS HensoFlg
		--,TT_DOC_HENSO_IF.CREATE_DATE AS CreateDate
	-------------------------------------------------------------------------
	-- Source table
	-------------------------------------------------------------------------
	FROM	
		TT_DOC_CONTROL WITH(NOLOCK)
	INNER JOIN @ListCsv List
	ON (
		TT_DOC_CONTROL.CHASSIS_NO = List.ChassisNo
		AND(
			TT_DOC_CONTROL.SHIIRE_SHUPPINN_TOROKU_NO = List.TorokuNo
			OR
			TT_DOC_CONTROL.URIAGE_SHUPPINN_TOROKU_NO = List.TorokuNo
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
		OR (@ModeSearch = 3 AND [TT_DOC_CONTROL].DOC_STATUS <> '101')
		--Add by TramD start
		OR (@ModeSearch = 5 AND [TT_DOC_CONTROL].DOC_STATUS <> '105')
		--Add by TramD end
		--GROUP BY TT_DOC_HENSO_IF.CREATE_DATE,[TT_DOC_CONTROL].DOC_CONTROL_NO,[TT_DOC_CONTROL].SHIIRE_SHUPPINN_TOROKU_NO
		--,[TT_DOC_CONTROL].URIAGE_SHUPPINN_TOROKU_NO,[TT_DOC_CONTROL].CHASSIS_NO
		--,[TT_DOC_CONTROL].SHIIRE_AA_KAIJO,[SHOP].TEMPO_CD,[SHOP].TEMPO_NAME
		--,[RAKUSATSU_SHOP].TEMPO_CD,[RAKUSATSU_SHOP].TEMPO_NAME,[TT_DOC_CONTROL].URIAGE_AA_KAIJO
		--,TT_DOC_CONTROL.NENSHIKI,TT_DOC_CONTROL.KEI_CAR_FLG,TT_DOC_CONTROL.AA_KAISAI_DATE
		--,TT_DOC_CONTROL.MAKER_NAME,TT_DOC_CONTROL.CAR_NAME,TT_DOC_CONTROL.GRADE_NAME,TT_DOC_CONTROL.AA_SHUPPIN_NO
		--,TT_DOC_CONTROL.DN_SEIYAKU_DATE,TT_DOC_CONTROL.KATASHIKI,TT_DN_CAR_INFO.MASSHO_FLG,TT_DOC_CONTROL.MASSHO_FLG
		--,TT_DOC_CONTROL.JISHAMEI_FLG,TT_DOC_CONTROL.DOC_STATUS
	) AS SearchInfoTempTable

		WHERE RowNum > @PageSize * (@PageIndex - 1) AND RowNum < @PageSize * @PageIndex + 1
		ORDER BY SearchInfoTempTable.ID

END
GO