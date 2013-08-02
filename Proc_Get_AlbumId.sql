USE [MusicApp]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Get_AlbumId]    Script Date: 8/2/2013 3:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[Proc_Get_AlbumId]
(
	@AlbumMbId		varchar(50),	--NN
	@AlbumName		varchar(max) OUTPUT,
	@AlbumId		uniqueidentifier OUTPUT
	
)
WITH RECOMPILE AS
BEGIN
	SET NOCOUNT ON

	If @AlbumMbId IS NULL AND @AlbumName IS NULL
		Begin
			 raiserror('This search requires an AlbumName or AlbumMbId.', 18, 1)
			 return -1
		End	
	
	if (SELECT COUNT(*) FROM Album Where MbId = @AlbumMbId) = 1
		Begin
			Select @AlbumId = AlbumId, @AlbumName = AlbumName From Album Where MbId = @AlbumMbId
		End
	else if (SELECT COUNT(*) FROM  Album Where AlbumName = @AlbumName) = 1
		Begin
			Select @AlbumId = AlbumId, @AlbumName = AlbumName From Album Where AlbumName = @AlbumName
		End 
	else
		Begin
			raiserror('Cant find the AlbumName or MusicBrainz Id in our database.', 18, 1)
			return -1
		End

END
