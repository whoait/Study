USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_DCW002Import]    Script Date: 2016/01/28 15:49:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[stp_DCW002Import]
(
	
	@fileNo		varchar(5),
	@vechicleClassification char(1)	,
	@vechicleRegistrationNo varchar(24)	,
	@numberPlate char(1) ,
	@chassisNo varchar(25)	,
	@motorModel	varchar(12)	,	
	@formType char(1),
	@createUser_CD varchar(10)

	--@CurrentDateTime datetime

)
AS
---------------------------------------------------------------------------
-- Version			: 1.0
-- Designer			: Dhanya.Ratheesh
-- Programmer		: Dhanya.Ratheesh
-- Created Date		: 2015/02/15
-- Comment			: Store Import csv DCW002
---------------------------------------------------------------------------
BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- stp process
	-------------------------------------------------------------------------
	SELECT CONVERT (time, SYSDATETIME())

--SELECT GETDATE() AS CurrentDateTime	

 INSERT INTO [dbo].[TT_DOC_UKETORI_IF]
 (
	 
	  [TT_DOC_UKETORI_IF].RAC_FILE_NO
	 ,[TT_DOC_UKETORI_IF].KEI_CAR_FLG					-----Vechicle classification		
	 ,[TT_DOC_UKETORI_IF].TOROKU_NO						-----Vechicle No
	 ,[TT_DOC_UKETORI_IF].HYOBAN_TYPE					------The number plate
	 ,[TT_DOC_UKETORI_IF].CHASSIS_NO					------The chassis no
	 ,[TT_DOC_UKETORI_IF].GENDOKI_KATASHIKI				------Motor Model
	 ,[TT_DOC_UKETORI_IF].REPORT_TYPE					------Form Type
	,[TT_DOC_UKETORI_IF].CREATE_DATE					------Date and Time of Creation
	,[TT_DOC_UKETORI_IF].CREATE_USER_CD				------Created By
--	 ,[TT_DOC_UKETORI_IF].CREATE_PG_CD					------CreationProgram Code
--	 ,[TT_DOC_UKETORI_IF].UPDATE_DATE					------Date Modified
--	 ,[TT_DOC_UKETORI_IF].UPDATE_USER_CD				------Updated By
--	 ,[TT_DOC_UKETORI_IF].UPDATE_PG_CD					------Update Program Code
--	 ,[TT_DOC_UKETORI_IF].DELETE_DATE					------Deletion Date
--	 ,[TT_DOC_UKETORI_IF].DELETE_FLG					------Deletion Date
)
Values 
(
	
	@fileNo		,
	@vechicleClassification	,
	@vechicleRegistrationNo	,
	@numberPlate ,
	@chassisNo	,
	@motorModel		,
	@formType,
	SYSDATETIME(),
	@createUser_CD
	
)
	
END


GO

