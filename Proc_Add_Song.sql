USE [MusicApp]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Add_Song]    Script Date: 8/2/2013 3:59:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Proc_Add_Song]
(
	
    @URL			varchar(max),	--NN-
	@Title			varchar(max),	--NN-
	@SongMbId	  	varchar(50),	--N	
    @AlbumMbId		varchar(50),	--N
  	@AlbumName		varchar(max),	--NN-
    @ArtistMbId		varchar(50),	--N
    @ArtistName		varchar(max),	--NN-
    @AlbumYear		varchar(max),	--N
    @TotalTracks	int,			--N    
    @TrackNum		int,			--N
    @BitRate		int,			--N
    @Bpm		 	int,			--N    
    @FileType		varchar(max)	--N
)
WITH RECOMPILE AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SongId		uniqueidentifier
	DECLARE @AlbumId	uniqueidentifier
	DECLARE @ArtistId	uniqueidentifier
  DECLARE @AlbumYearDate Date

	If @ArtistName IS NULL OR @AlbumName IS NULL OR @Title IS NULL OR @URL IS NULL
		Begin
			 raiserror('A mandatory argument is null.', 18, 1)
			 return -1
		End
  
  SELECT @AlbumYearDate = CONVERT (date, @AlbumYear, 101)
	
	if (SELECT COUNT(*) FROM Artist Where ArtistName = @ArtistName OR MbId = @ArtistMbId) = 0
		Begin
			INSERT INTO [dbo].[Artist]
				([ArtistId]
				,[MbId]
				,[ArtistName])
			VALUES
				(NEWID()
				,@ArtistMbId
				,@ArtistName)
		End
		
	SELECT @ArtistId = ArtistId FROM Artist Where ArtistName = @ArtistName OR MbId = @ArtistMbId
	
	if (SELECT COUNT(*) FROM Album Where AlbumName = @AlbumName OR MbId = @AlbumMbId) = 0
		Begin
			INSERT INTO [dbo].[Album]
				   ([AlbumId]
				   ,[MbId]
				   ,[AlbumName]
				   ,[ArtistId]
				   ,[ArtistName]
				   ,[AlbumYear]
				   ,[TotalTracks])
			 VALUES
				   (NEWID()
				   ,@AlbumMbId
				   ,@AlbumName
				   ,@ArtistId
				   ,@ArtistName
				   ,@AlbumYear
				   ,@TotalTracks)
		End

	SELECT @AlbumId = AlbumId FROM Album Where AlbumName = @AlbumName OR MbId = @AlbumMbId

	if (SELECT COUNT(*) FROM Song Where URL = @URL) = 0
		Begin
			INSERT INTO [dbo].[Song]
				   ([SongId]
				   ,[MbId]
				   ,[AlbumId]
				   ,[Title]
				   ,[TrackNum]
				   ,[BitRate]
				   ,[Bpm]
				   ,[URL]
				   ,[FileType])
			 VALUES
				   (NEWID()
				   ,@SongMbId
				   ,@AlbumId
				   ,@Title
				   ,@TrackNum
				   ,@BitRate
				   ,@Bpm
				   ,@URL
				   ,@FileType)
		End
	else
		Begin
			raiserror('We already have this URL stored.', 18, 1)
			return -1
		End

END
