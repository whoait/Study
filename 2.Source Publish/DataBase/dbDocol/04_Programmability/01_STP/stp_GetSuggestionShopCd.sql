USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_GetSuggestionShopCd]    Script Date: 2016/01/28 15:56:39 ******/
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

