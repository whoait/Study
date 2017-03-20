USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_RC002_ExportCsv]    Script Date: 2016/01/28 15:57:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------- 
-- Version                      : 001 
-- Designer                     : TramD
-- Programmer          			: TramD
-- Created Date        			: 2015/12/16 
-- Comment                      : Store Export CSV
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[stp_RC002_ExportCsv]
AS
BEGIN
	SELECT 
	  ISNULL(DC.RACK_NO,'') + ISNULL(DC.FILE_NO,'') AS FILE_NO
	, DC.CHASSIS_NO
	, DF.RFID_KYE 
	FROM TT_DOC_CONTROL AS DC WITH(NOLOCK)
		INNER JOIN TM_DOC_FILE_NO AS DF WITH(NOLOCK)
		ON DC.FILE_NO = DF.FILE_NO
		WHERE DC.DOC_STATUS IN ('102','103','104')
END
GO

