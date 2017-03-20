IF EXISTS ( SELECT * FROM sys.objects WHERE name = 'stp_DCW003CheckInputTorokuno' AND user_name(schema_id) = 'dbo')
	DROP PROC stp_DCW003CheckInputTorokuno
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



