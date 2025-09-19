ALTER DATABASE name_of_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE name_of_db
FROM DISK = '/var/opt/mssql/backup/name_of_db.bak'
WITH 
    MOVE 'name_of_db' TO '/var/opt/mssql/data/name_of_db.mdf',
    MOVE 'name_of_db_log' TO '/var/opt/mssql/data/name_of_db_log.ldf',
    REPLACE, RECOVERY;

ALTER DATABASE name_of_db SET MULTI_USER;