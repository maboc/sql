-- Name        : logs.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Information about the (standby) logfile
-- ---------------------------------------------------------------------
-- 2022-09-05 : MB : Initial Version

@@settings.sql

-- local settings
col sz head 'Size|MB'
col members head Members


select group#,sequence#, bytes/(1024*1024) sz, members, archived, status from v$log;

select group#, dbid, sequence#, bytes/(1024*1024) sz, used, archived, status from v$standby_log;

select * from v$logfile;

