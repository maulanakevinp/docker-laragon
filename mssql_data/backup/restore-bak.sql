-- Active: 1758792704135@@127.0.0.1@1433@master
-- Langkah 1: Cek logical names yang ada di backup file
RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/uais.bak';

-- Langkah 2: Gunakan hasil dari query di atas untuk mengetahui LogicalName yang benar
-- Kemudian jalankan restore dengan logical names yang tepat:

-- Contoh jika logical names adalah 'lecturer_Data' and 'lecturer_Log':
ALTER DATABASE uais SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE uais
FROM DISK = '/var/opt/mssql/backup/uais.bak'
WITH 
    MOVE 'uais' TO '/var/opt/mssql/data/uais.mdf',
    MOVE 'uais_log' TO '/var/opt/mssql/data/uais_log.ldf',
    REPLACE, RECOVERY;

ALTER DATABASE uais SET MULTI_USER;

-- ATAU gunakan script otomatis di bawah ini: