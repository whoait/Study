USE [dbDocol_Test_P2]
GO

/****** Object:  StoredProcedure [dbo].[stp_GetMessageAll]    Script Date: 2016/01/28 15:56:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[stp_GetMessageAll]
AS


BEGIN
	SET NOCOUNT ON

	-------------------------------------------------------------------------
	-- STP Process
	-------------------------------------------------------------------------
	SELECT
		MessageId
		, Class
		, Message
		, ButtonOK
		, ButtonNOK
		, ButtonCancel
		, DefaultButton
	FROM TM_MESSAGE WITH (NOLOCK)
END




GO

