-- Name        : db_info.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Information about this database and it's instance
-- ---------------------------------------------------------------------
-- 2017-07-20 : MB : recovery area info added
-- 2017-01-12 : MB : Initial Version

@settings.sql

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

select * 
from   V$RECOVERY_AREA_USAGE
/
