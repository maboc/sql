-- Name        : busy_session.sql
-- Author      : Martijn Bos
-- Input       : Session ID
--               serial#
-- Description : What is a session waiting for, the last 5 minutes (ASH)
--                 events
--                 SQL 
-- ---------------------------------------------------------------------
-- 2017-01-09 : MB : Initial Version

@settings.sql

accept sidje prompt 'What SID : '
accept serial prompt 'What serial# : '

select event,
       count(*) n
from   v$active_session_history ash
where  session_id=&&sidje
       and session_serial#=&&serial
       and sample_time between sysdate-(5/(24*60)) and sysdate
group by event
order by n;

select ash.sql_id,
       ash.sql_child_number,
       count(*) n,
       substr(sql.sql_text,0,50) txt
from   v$active_session_history ash,
       v$sql sql
where  session_id=&&sidje
       and session_serial#=&&serial
       and sample_time between sysdate-(5/(24*60)) and sysdate
       and sql.sql_id=ash.sql_id
       and sql.child_numner=ash.sql_child_number
group by ash.sql_id,
         ash.sql_child_number,
         substr(sql.sql_text,0,50)
order by n
/
