-- =============================================
-- CONFIGURATION: Change the paths below according to your directory.
-- =============================================
DECLARE @BackupPath NVARCHAR(255) = N'/var/opt/mssql/backup/'; -- Change to your backup folder location.
DECLARE @DataPath   NVARCHAR(255) = N'/var/opt/mssql/data/';   -- Change to your data (.mdf) folder location.
DECLARE @LogPath    NVARCHAR(255) = N'/var/opt/mssql/data/';   -- Change to your log (.ldf) folder location.
-- =============================================

SET NOCOUNT ON;

-- Create a temporary table to store the list of backup files
DECLARE @BackupFiles TABLE (FileName NVARCHAR(255));
INSERT INTO @BackupFiles (FileName)
SELECT file_or_directory_name FROM sys.dm_os_enumerate_filesystem('/var/opt/mssql/backup', N'*.bak');

-- Declare variables for use in the loop
DECLARE @CurrentFile      NVARCHAR(255);
DECLARE @DBName           NVARCHAR(128);
DECLARE @FullPath         NVARCHAR(512);
DECLARE @LogicalDataName  NVARCHAR(128);
DECLARE @LogicalLogName   NVARCHAR(128);
DECLARE @SQL              NVARCHAR(MAX);
-- Check if the temporary table #FileList exists, if not then create it
IF OBJECT_ID('tempdb..#FileList') IS NULL
BEGIN
    CREATE TABLE #FileList (
        LogicalName          NVARCHAR(128),
        PhysicalName         NVARCHAR(260),
        Type                 CHAR(1),
        FileGroupName        NVARCHAR(128),
        Size                 BIGINT,
        MaxSize              BIGINT,
        FileId               BIGINT,
        CreateLSN            NUMERIC(25,0),
        DropLSN              NUMERIC(25,0),
        UniqueId             UNIQUEIDENTIFIER,
        ReadOnlyLSN          NUMERIC(25,0),
        ReadWriteLSN         NUMERIC(25,0),
        BackupSizeInBytes    BIGINT,
        SourceBlockSize      INT,
        FileGroupId          INT,
        LogGroupGUID         UNIQUEIDENTIFIER,
        DifferentialBaseLSN  NUMERIC(25,0),
        DifferentialBaseGUID UNIQUEIDENTIFIER,
        IsReadOnly           BIT,
        IsPresent            BIT,
        TDEThumbprint        VARBINARY(32),
        SnapshotUrl          NVARCHAR(360)
    );
END

-- Loop for each backup file found
WHILE EXISTS (SELECT 1 FROM @BackupFiles)
BEGIN
    -- Get one file name to process
    SELECT TOP 1 @CurrentFile = FileName FROM @BackupFiles;
    SET @FullPath = @BackupPath + @CurrentFile;

    -- Determine database name from file name (e.g.: 'DBName.bak' -> 'DBName')
    SET @DBName = REPLACE(@CurrentFile, '.bak', '');

    -- Clear the file list table before use
    TRUNCATE TABLE #FileList;

    -- Get logical names of data and log files inside the .bak file
    BEGIN TRY
        INSERT INTO #FileList
        EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @FullPath + '''');

        SELECT @LogicalDataName = LogicalName FROM #FileList WHERE Type = 'D';
        SELECT @LogicalLogName  = LogicalName FROM #FileList WHERE Type = 'L';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Cannot read file list from: ' + @FullPath;
        -- Remove file from list and continue to next file
        DELETE FROM @BackupFiles WHERE FileName = @CurrentFile;
        -- CONTINUE is not supported, so just skip to the next iteration
        -- by using RETURN to exit the loop body early
        -- Or use a flag variable if more logic is needed
        -- Here, we use RETURN to exit the loop body
        RETURN;
    END CATCH

    -- Create new .mdf and .ldf file paths
    DECLARE @NewMdfPath NVARCHAR(512) = @DataPath + @DBName + '.mdf';
    DECLARE @NewLdfPath NVARCHAR(512) = @LogPath + @DBName + '_log.ldf';

    -- Build dynamic RESTORE command
    SET @SQL = N'RESTORE DATABASE [' + @DBName + ']' + CHAR(13) +
               N'FROM DISK = ''' + @FullPath + '''' + CHAR(13) +
               N'WITH MOVE ''' + @LogicalDataName + ''' TO ''' + @NewMdfPath + ''',' + CHAR(13) +
               N'     MOVE ''' + @LogicalLogName  + ''' TO ''' + @NewLdfPath + ''',' + CHAR(13) +
               N'     REPLACE, STATS = 5;';

    -- Print and execute the SQL command
    PRINT '===================================================================';
    PRINT 'Starting restore for database: ' + @DBName;
    PRINT 'From file: ' + @FullPath;
    PRINT @SQL;
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'SUCCESS: Database ' + @DBName + ' restored successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'FAILED: Restore database ' + @DBName + ' was not successful.';
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
    
    PRINT '===================================================================' + CHAR(13);

    -- Remove processed file from the list
    DELETE FROM @BackupFiles WHERE FileName = @CurrentFile;
END

-- Drop temporary table
DROP TABLE #FileList;

SET NOCOUNT OFF;