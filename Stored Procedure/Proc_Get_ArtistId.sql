USE [MusicApp]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Get_ArtistId]    Script Date: 8/2/2013 3:59:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[Proc_Get_ArtistId]
(
	@ArtistMbId		varchar(50),	--NN
	@ArtistName			varchar(max) OUTPUT,
	@ArtistId			uniqueidentifier OUTPUT
	
)
WITH RECOMPILE AS
BEGIN
	SET NOCOUNT ON

	If @ArtistMbId IS NULL AND @ArtistName IS NULL
		Begin
			 raiserror('This search requires an ArtistName or ArtistMbId.', 18, 1)
			 return -1
		End	
	
	if (SELECT COUNT(*) FROM Artist Where MbId = @ArtistMbId) = 1
		Begin
			Select @ArtistId = ArtistId, @ArtistName = ArtistName From Artist Where MbId = @ArtistMbId
		End
	else if (SELECT COUNT(*) FROM  Artist Where ArtistName = @ArtistName) = 1
		Begin
			Select @ArtistId = ArtistId, @ArtistName = ArtistName From Artist Where ArtistName = @ArtistName
		End 
	else
		Begin
			raiserror('Cant find the ArtistName or MusicBrainz Id in our database.', 18, 1)
			return -1
		End

END
