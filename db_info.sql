-- Name        : db_info.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Information about this database and it's instance
-- ---------------------------------------------------------------------
-- 3 : 2018-07-20 : MB : some slashback info added
-- 2 : 2018-07-20 : MB : recovery parameters added
-- 1 : 2018-07-20 : MB : recovery area info added
-- 0 : 2017-01-12 : MB : Initial Version

@settings.sql
--lokale settings
col name for a35

select banner from v$version;

select dbid,
       name,
       created,
       log_mode,
       open_mode,
       force_logging,
       flashback_on
from   v$database;

select database_role,
       protection_mode,
       protection_level,
       dataguard_broker,
       switchover_status
from   v$database;

select instance_name,
       host_name,
       version,
       startup_time,
       status,
       archiver,
       logins,
       shutdown_pending,
       database_status,
       instance_role,
       edition
from   v$instance;

select NAME, 
       value,
       DESCRIPTION 
from   v$parameter 
where  name in ('db_recovery_file_dest',
                'db_recovery_file_dest_size');

select * 
from   V$RECOVERY_AREA_USAGE;

select OLDEST_FLASHBACK_SCN,
       OLDEST_FLASHBACK_TIME,
       RETENTION_TARGET,
       round(FLASHBACK_SIZE/(1024*1024*1024),2) SIZE_GB,
       ESTIMATED_FLASHBACK_SIZE,CON_ID
from   v$flashback_database_log
/
