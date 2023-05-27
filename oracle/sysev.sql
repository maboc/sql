-- Name        : sysev.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : On which events is the system waiting
-- ---------------------------------------------------------------------
-- 2023-05-26 : MB : Initial Version

@@settings.sql

select event,
       total_waits,
       time_waited,
       time_waited/total_waits,
       WAIT_CLASS
from   v$system_event
where    wait_class not in ('Idle')
order by time_waited
/
