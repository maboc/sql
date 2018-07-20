-- Name        : db_info.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Information about this database and it's instance
-- ---------------------------------------------------------------------
-- 2 : 2017-07-20 : MB : recoverys parameters added
-- 1 : 2017-07-20 : MB : recovery area info added
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
from   V$RECOVERY_AREA_USAGE
/
