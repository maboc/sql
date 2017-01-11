-- Name        : busy_sessions.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which sessions have the most waitevents in the last 5 minutes (ASH)
-- ---------------------------------------------------------------------
-- 2017-01-11 : MB : Initial Version

@settings.sql

select   ash.session_id,
         ash.session_serial#,
         ses.username,
         ses.machine,
         ses.program,
         ses.logon_time,
         count(*) n
from     v$active_session_history ash,
         v$session ses
where    ash.sample_time between sysdate-(5/(24*60)) and sysdate
         and ses.sid=ash.session_id
         and ses.serial#=ash.session_serial#
group by ash.session_id,
         ash.session_serial#,
         ses.username,
         ses.machine,
         ses.program,
         ses.logon_time
order by ses.logon_time
/
