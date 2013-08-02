USE [MusicApp]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Get_SongId]    Script Date: 8/2/2013 3:56:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[Proc_Get_SongId]
(
	
    @URL			varchar(max),	--NN- Must have SongMbId OR the URL
	@SongMbId		varchar(50),	--NN-
	@SongId			uniqueidentifier OUTPUT,
	@Title			varchar(max) OUTPUT
)
WITH RECOMPILE AS
BEGIN
	SET NOCOUNT ON

	If @URL IS NULL AND @SongMbId IS NULL
		Begin
			 raiserror('This search requires a fileURL or a SongMbId.', 18, 1)
			 return -1
		End
	
	if (SELECT COUNT(*) FROM Song Where URL = @URL) = 1
		Begin
			Select @SongId = SongId, @Title = Title From Song Where URL = @URL
		End
	else if (SELECT COUNT(*) FROM Song Where MbId = @SongMbId) = 1
		Begin
			Select @SongId = SongId, @Title = Title From Song Where MbId = @SongMbId
		End
	else
		Begin
			raiserror('Cant find the URL or MusicBrainz Id in our database.', 18, 1)
			return -1
		End

END